<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*, java.text.*" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.sql.PreparedStatement" %>
<%@ page import="java.sql.ResultSet" %>
<%@ page import="java.sql.SQLException" %>
<%@ page import="dao.ProductDAO" %>
<%@ page import="util.DBConnection" %>

<%
    // --- DATABASE SAVE LOGIC ---
    Connection dbConn = null;
    String dbSaveError = null;
    boolean dbSaveSuccess = false;
    int savedSaleId = -1;
    
    try {
        dbConn = DBConnection.getConnection();
        if (dbConn != null) {
            // Get parameters required for database save
            String receiptNumber = request.getParameter("receiptNumber");
            String cashierName = request.getParameter("cashier");
            String cashierId = request.getParameter("cashierId"); // Assuming this is passed from previous page
            
            // Prepare subtotal, discount, tax and total amounts for DB (strip currency symbols)
            String subtotalParam = request.getParameter("subtotal");
            String discountParam = request.getParameter("discount");
            String taxParam = request.getParameter("tax");
            String totalParam = request.getParameter("total");
            
            String paymentMethod = request.getParameter("paymentMethod");
            String cashReceived = request.getParameter("cashReceived");
            String changeDue = request.getParameter("changeDue");
            String cardLast4 = request.getParameter("cardLast4");
            
            // Parse numerical values
            double subtotalAmount = 0.0;
            double discountAmount = 0.0;
            double taxAmount = 0.0;
            double totalAmount = 0.0;
            double amountTendered = 0.0;
            double changeGiven = 0.0;
            int cashierIdNum = -1;
            
            // Strip "Rs." and commas, then parse amounts
            if (subtotalParam != null) subtotalAmount = Double.parseDouble(subtotalParam.replace("Rs.", "").replace(",", "").trim());
            if (totalParam != null) totalAmount = Double.parseDouble(totalParam.replace("Rs.", "").replace(",", "").trim());
            
            // Handle discounts with percentages: "Rs.50.00 (10%)"
            if (discountParam != null && !discountParam.isEmpty()) {
                String discountValue = discountParam.replace("Rs.", "").trim();
                int parenthesisIndex = discountValue.indexOf("(");
                if (parenthesisIndex > 0) {
                    discountAmount = Double.parseDouble(discountValue.substring(0, parenthesisIndex).replace(",", "").trim());
                }
            }
            
            // Handle tax with percentages: "Rs.25.00 (5%)"
            if (taxParam != null && !taxParam.isEmpty()) {
                String taxValue = taxParam.replace("Rs.", "").trim();
                int parenthesisIndex = taxValue.indexOf("(");
                if (parenthesisIndex > 0) {
                    taxAmount = Double.parseDouble(taxValue.substring(0, parenthesisIndex).replace(",", "").trim());
                }
            }
            
            // Parse cash payment details
            if ("cash".equalsIgnoreCase(paymentMethod)) {
                if (cashReceived != null) amountTendered = Double.parseDouble(cashReceived.replace("Rs.", "").replace(",", "").trim());
                if (changeDue != null) changeGiven = Double.parseDouble(changeDue.replace("Rs.", "").replace(",", "").trim());
            }
            
            // Parse cashier ID if available
            if (cashierId != null && !cashierId.isEmpty()) {
                try {
                    cashierIdNum = Integer.parseInt(cashierId);
                } catch (NumberFormatException e) {
                    // Keep default -1 if parsing fails
                }
            }
            
            // Start transaction
            dbConn.setAutoCommit(false);
            
            // 1. Insert the main sale record
            String insertSaleSQL = "INSERT INTO pos_sales (receipt_number, transaction_time, cashier_id, cashier_name_snapshot, " +
                                   "subtotal_amount, discount_text, discount_amount, tax_text, tax_amount, total_amount, " +
                                   "payment_method, amount_tendered, change_given, card_last_four) " +
                                   "VALUES (?, NOW(), ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            
            PreparedStatement pstmtSale = dbConn.prepareStatement(insertSaleSQL, PreparedStatement.RETURN_GENERATED_KEYS);
            pstmtSale.setString(1, receiptNumber);
            if (cashierIdNum > 0) {
                pstmtSale.setInt(2, cashierIdNum);
            } else {
                pstmtSale.setNull(2, java.sql.Types.INTEGER);
            }
            pstmtSale.setString(3, cashierName);
            pstmtSale.setDouble(4, subtotalAmount);
            pstmtSale.setString(5, discountParam);
            pstmtSale.setDouble(6, discountAmount);
            pstmtSale.setString(7, taxParam);
            pstmtSale.setDouble(8, taxAmount);
            pstmtSale.setDouble(9, totalAmount);
            pstmtSale.setString(10, paymentMethod);
            
            if ("cash".equalsIgnoreCase(paymentMethod)) {
                pstmtSale.setDouble(11, amountTendered);
                pstmtSale.setDouble(12, changeGiven);
                pstmtSale.setNull(13, java.sql.Types.VARCHAR);
            } else if ("card".equalsIgnoreCase(paymentMethod)) {
                pstmtSale.setNull(11, java.sql.Types.DECIMAL);
                pstmtSale.setNull(12, java.sql.Types.DECIMAL);
                pstmtSale.setString(13, cardLast4);
            } else {
                pstmtSale.setNull(11, java.sql.Types.DECIMAL);
                pstmtSale.setNull(12, java.sql.Types.DECIMAL);
                pstmtSale.setNull(13, java.sql.Types.VARCHAR);
            }
            
            int saleRowsAffected = pstmtSale.executeUpdate();
            
            // Get the auto-generated sale_id
            ResultSet generatedKeys = pstmtSale.getGeneratedKeys();
            if (generatedKeys.next()) {
                savedSaleId = generatedKeys.getInt(1);
            }
            
            // 2. Insert sale items
            if (savedSaleId > 0) {
                ProductDAO productDAO = new ProductDAO(dbConn);
                String[] productIdsParam = request.getParameterValues("productId");
                String[] itemNames = request.getParameterValues("itemName");
                String[] itemQtys = request.getParameterValues("itemQty");
                String[] itemPrices = request.getParameterValues("itemPrice");
                
                if (itemNames != null && itemQtys != null && itemPrices != null && 
                    itemNames.length == itemQtys.length && itemNames.length == itemPrices.length) {
                    
                    String insertItemSQL = "INSERT INTO pos_sale_items (sale_id, product_id, product_name_snapshot, " +
                                           "quantity_sold, unit_price_at_sale, item_total_price) " +
                                           "VALUES (?, ?, ?, ?, ?, ?)";
                    
                    PreparedStatement pstmtItem = dbConn.prepareStatement(insertItemSQL);
                    
                    for (int i = 0; i < itemNames.length; i++) {
                        // Get product ID either from parameter or look it up by name
                        int productId = -1;
                        if (productIdsParam != null && i < productIdsParam.length && productIdsParam[i] != null && !productIdsParam[i].isEmpty()) {
                            try { 
                                productId = Integer.parseInt(productIdsParam[i]); 
                            } catch (NumberFormatException e) { 
                                // Keep -1 if parsing fails 
                            }
                        }
                        
                        // If product ID is not available, try to get it by name
                        if (productId == -1) {
                            productId = productDAO.getProductIdByName(itemNames[i]);
                        }
                        
                        // Parse quantity
                        int qty = 0;
                        try {
                            qty = Integer.parseInt(itemQtys[i]); // Assuming quantity won't have commas
                        } catch (NumberFormatException e) {
                            // Default to 0 if parsing fails
                        }
                        
                        // Parse unit price
                        double unitPrice = 0.0;
                        String unitPriceStr = itemPrices[i].replace("Rs.", "").replace(",", "").trim(); // Remove Rs. and commas
                        try {
                            unitPrice = Double.parseDouble(unitPriceStr);
                        } catch (NumberFormatException e) {
                            // Keep default 0.0 if parsing fails
                        }
                        
                        // Calculate total price
                        double itemTotalPrice = qty * unitPrice;
                        
                        // Skip records with invalid product ID or quantity
                        if (productId > 0 && qty > 0) {
                            pstmtItem.setInt(1, savedSaleId);
                            pstmtItem.setInt(2, productId);
                            pstmtItem.setString(3, itemNames[i]);
                            pstmtItem.setInt(4, qty);
                            pstmtItem.setDouble(5, unitPrice);
                            pstmtItem.setDouble(6, itemTotalPrice);
                            pstmtItem.addBatch();
                        } else {
                            // Track items that couldn't be saved
                            if (dbSaveError == null) {
                                dbSaveError = "Could not save item: " + itemNames[i];
                            } else {
                                dbSaveError += "<br>Could not save item: " + itemNames[i];
                            }
                        }
                    }
                    
                    // Execute batch for all items
                    int[] itemRowsAffected = pstmtItem.executeBatch();
                    
                    // Check if all items were saved
                    boolean allItemsSaved = true;
                    for (int count : itemRowsAffected) {
                        if (count <= 0) {
                            allItemsSaved = false;
                            break;
                        }
                    }
                    
                    if (allItemsSaved && itemRowsAffected.length > 0) {
                        // All items saved successfully
                        dbConn.commit();
                        dbSaveSuccess = true;
                    } else {
                        if (dbSaveError == null) dbSaveError = "Failed to save some or all items.";
                        dbConn.rollback();
                    }
                    
                    pstmtItem.close();
                } else {
                    dbSaveError = "Data mismatch for sale items. Database save aborted.";
                    dbConn.rollback();
                }
            } else {
                dbSaveError = "Failed to save main sale record.";
                dbConn.rollback();
            }
            
            pstmtSale.close();
            dbConn.setAutoCommit(true);
        } else {
            dbSaveError = "Database connection error. Bill details not saved.";
        }
    } catch (Exception e) {
        dbSaveError = "An error occurred while saving: " + e.getMessage();
        e.printStackTrace();
        try {
            if (dbConn != null) {
                dbConn.rollback();
                dbConn.setAutoCommit(true);
            }
        } catch (SQLException ex) {
            ex.printStackTrace();
        }
    }

    // --- STOCK UPDATE LOGIC (Same as before) ---
    String stockUpdateError = null;
    boolean overallStockUpdateSuccess = true;

    try {
        if (dbConn == null) { // dbConn might have been closed if save was successful
            dbConn = DBConnection.getConnection();
        }
        
        if (dbConn != null) {
            ProductDAO productDAO = new ProductDAO(dbConn);
            String[] productIdsParam = request.getParameterValues("productId");
            String[] itemNamesForStockUpdate = request.getParameterValues("itemName");
            String[] itemQuantitiesParam = request.getParameterValues("itemQty");

            if (itemQuantitiesParam != null) {
                int numItems = itemQuantitiesParam.length;
                if ((productIdsParam != null && productIdsParam.length != numItems) ||
                    (itemNamesForStockUpdate != null && itemNamesForStockUpdate.length != numItems)) {
                    stockUpdateError = "Data mismatch for cart items. Stock update aborted.";
                    overallStockUpdateSuccess = false;
                } else {
                    for (int i = 0; i < numItems; i++) {
                        int productId = -1;
                        String currentItemName = (itemNamesForStockUpdate != null && i < itemNamesForStockUpdate.length) ? itemNamesForStockUpdate[i] : "Unknown Item";
                        if (productIdsParam != null && i < productIdsParam.length && productIdsParam[i] != null && !productIdsParam[i].isEmpty()) {
                            try { productId = Integer.parseInt(productIdsParam[i]); } catch (NumberFormatException e) { /* log or ignore */ }
                        }
                        if (productId == -1 && itemNamesForStockUpdate != null && i < itemNamesForStockUpdate.length && itemNamesForStockUpdate[i] != null && !itemNamesForStockUpdate[i].isEmpty()) {
                           productId = productDAO.getProductIdByName(currentItemName);
                        }
                        int quantitySold = 0;
                        if (itemQuantitiesParam[i] != null && !itemQuantitiesParam[i].isEmpty()){
                            try { quantitySold = Integer.parseInt(itemQuantitiesParam[i]); } catch (NumberFormatException e) { overallStockUpdateSuccess = false; continue; }
                        }
                        if (productId != -1 && quantitySold > 0) {
                            if (!productDAO.decreaseStock(productId, quantitySold)) {
                                String errorForItem = "Stock update failed for " + currentItemName + ".";
                                stockUpdateError = (stockUpdateError == null) ? errorForItem : stockUpdateError + "<br/>" + errorForItem;
                                overallStockUpdateSuccess = false;
                            }
                        } else if (quantitySold > 0) {
                            String errorForItem = "Could not identify product '" + currentItemName + "' for stock update.";
                            stockUpdateError = (stockUpdateError == null) ? errorForItem : stockUpdateError + "<br/>" + errorForItem;
                            overallStockUpdateSuccess = false;
                        }
                    }
                }
            }
        } else {
             stockUpdateError = "Database connection error. Stock update failed.";
             overallStockUpdateSuccess = false;
        }
    } catch (Exception e) { // Catching generic Exception for brevity here
        stockUpdateError = "An error occurred during stock update: " + e.getMessage();
        overallStockUpdateSuccess = false;
        e.printStackTrace();
    } finally {
        if (dbConn != null) { try { dbConn.close(); } catch (SQLException e) { e.printStackTrace(); } }
    }

    // --- Retrieve Data for Display (Same as before) ---
    // These parameters are retrieved again for display. Values might still have commas if coming directly from form.
    request.setCharacterEncoding("UTF-8");
    String receiptNumber = request.getParameter("receiptNumber");
    String receiptDate = request.getParameter("receiptDate");
    String cashier = request.getParameter("cashier");
    String[] itemNames = request.getParameterValues("itemName"); // Used for display
    String[] itemQtys = request.getParameterValues("itemQty");   // Used for display
    String[] itemPrices = request.getParameterValues("itemPrice"); // Used for display
    String subtotal = request.getParameter("subtotal");
    String discount = request.getParameter("discount");
    String tax = request.getParameter("tax");
    String total = request.getParameter("total");
    String paymentMethod = request.getParameter("paymentMethod");
    String cashReceived = request.getParameter("cashReceived");
    String changeDue = request.getParameter("changeDue");
    String cardLast4 = request.getParameter("cardLast4");

    // Defaults
    if (receiptNumber == null) receiptNumber = "N/A-" + System.currentTimeMillis()%10000;
    if (receiptDate == null) receiptDate = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss").format(new Date());
    if (cashier == null) cashier = "System";
    if (subtotal == null) subtotal = "Rs.0.00";
    if (discount == null) discount = "Rs.0.00 (0%)";
    if (tax == null) tax = "Rs.0.00 (0%)";
    if (total == null) total = "Rs.0.00";
    if (paymentMethod == null) paymentMethod = "Unknown";
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Transaction Receipt - <%= receiptNumber %></title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="stylesheet" href="${pageContext.request.contextPath}/Cashier/styles.css">
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4; color: #333; }
        .receipt-container { background-color: #fff; max-width: 400px; margin: 20px auto; padding: 20px; border: 1px solid #ddd; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .receipt-header { text-align: center; border-bottom: 1px dashed #ccc; margin-bottom: 15px; padding-bottom: 10px; }
        .receipt-header img.logo-img { max-width: 80px; margin-bottom: 5px; }
        .receipt-header h2 { margin-top: 5px; margin-bottom: 5px; font-size: 1.4em; }
        .receipt-header p { margin: 2px 0; font-size: 0.9em; }
        .receipt-details, .receipt-items, .receipt-summary, .payment-details-section, .receipt-footer { margin-bottom: 15px; padding-bottom: 10px; border-bottom: 1px dashed #eee; }
        .receipt-footer { border-bottom: none; padding-bottom: 0;}
        .receipt-row, .receipt-item, .payment-method-row { display: flex; justify-content: space-between; margin-bottom: 5px; font-size: 0.95em; }
        .receipt-item-header { font-weight: bold; border-bottom: 1px solid #ccc; margin-bottom: 8px; padding-bottom: 5px; }
        .receipt-item .item-name, .receipt-item-header .item-name { flex: 2.5; text-align: left; }
        .receipt-item .item-qty, .receipt-item-header .item-qty { flex: 0.75; text-align: center; }
        .receipt-item .item-unit-price, .receipt-item-header .item-unit-price { flex: 1.25; text-align: right; }
        .receipt-item .item-total-price, .receipt-item-header .item-total-price { flex: 1.5; text-align: right; }
        .receipt-summary .total { font-weight: bold; font-size: 1.1em; margin-top: 10px; padding-top: 10px; border-top: 1px solid #555;}
        .receipt-summary span:last-child, .payment-details-section span:last-child { text-align: right; }
        .receipt-footer p { text-align: center; font-size: 0.85em; margin: 5px 0;}
        .barcode img { display: block; margin: 10px auto 0 auto; max-height: 40px; }
        .action-buttons { text-align: center; margin-top: 20px; padding-bottom: 20px; }
        .action-buttons button { padding: 10px 15px; margin: 0 5px; cursor: pointer; background-color: #007bff; color: white; border: none; border-radius: 4px; font-size: 1em; transition: background-color 0.2s; }
        .action-buttons button:hover { background-color: #0056b3; }
        .action-buttons button:disabled { background-color: #ccc; cursor: not-allowed; }
        .action-buttons i { margin-right: 8px; }
        .status-message { text-align: center; margin-top: 10px; font-weight: bold; }
        .success { color: green; }
        .error { color: red; }
        .db-status { padding: 10px; margin-bottom: 15px; border-radius: 4px; font-weight: bold; text-align: center; }
        .db-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .db-error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        .error-message-box { background-color: #ffebee; color: #c62828; border: 1px solid #ef9a9a; padding: 10px; margin-bottom: 15px; border-radius: 4px; text-align: left; }
        @media print {
            body { margin: 0; background-color: #fff; -webkit-print-color-adjust: exact; print-color-adjust: exact;}
            .receipt-container { margin: 0 auto; border: none; box-shadow: none; max-width: 98%; width: 300px; padding: 5px; font-size: 10pt;}
            .receipt-header h2 {font-size: 12pt;}
            .receipt-header p, .receipt-row, .receipt-item, .payment-method-row {font-size: 9pt;}
            .receipt-summary .total {font-size: 10pt;}
            .action-buttons, .status-message, .db-status { display: none; }
            .error-message-box, .db-error, .db-success { border: 1px solid #000 !important; color: #000 !important; background-color: #fff !important;}
            .barcode img {max-height: 30px;}
        }
    </style>
</head>
<body>

<% if (dbSaveError != null) { %>
    <div class="db-status db-error">
        <i class="fas fa-exclamation-circle"></i> Database Error: <%= dbSaveError %>
    </div>
<% /* Success message block was removed previously */ %>
<% } %>

<div class="receipt-container" id="receiptContent">
    <div class="receipt-header">
        <div class="store-logo" id="store-logo">
            <img src="${pageContext.request.contextPath}/Images/logo.png" alt="Store Logo" class="logo-img" style="filter: brightness(0); -webkit-filter: brightness(0);">
        </div>
        <h2>Swift POS Store</h2>
        <p>123/2, High level Road, Homagama.</p>
        <p>Tel: (+94) 76-2375055</p>
    </div>

    <% if (stockUpdateError != null) { %>
        <div class="error-message-box">
            <strong>Attention: Stock Update Issue</strong><br>
            <%= stockUpdateError %>
        </div>
    <% } %>

    <div class="receipt-details">
        <div class="receipt-row"><span>Receipt #:</span><span id="receiptNoDisplay"><%= receiptNumber %></span></div>
        <div class="receipt-row"><span>Date:</span><span id="receiptDateDisplay"><%= receiptDate %></span></div>
        <div class="receipt-row"><span>Cashier:</span><span id="cashierDisplay"><%= cashier %></span></div>
    </div>

    <div class="receipt-items">
        <div class="receipt-item-header">
            <span class="item-name">Item</span>
            <span class="item-qty">Qty</span>
            <span class="item-unit-price">Unit Price</span>
            <span class="item-total-price">Total</span>
        </div>
        <%
            if (itemNames != null && itemQtys != null && itemPrices != null && itemNames.length == itemQtys.length && itemNames.length == itemPrices.length) {
                for (int i = 0; i < itemNames.length; i++) {
                    // Parse values for calculations for display
                    int qty = 1;
                    try {
                        qty = Integer.parseInt(itemQtys[i]);
                    } catch (NumberFormatException e) {
                        // Default to 1 if parsing fails
                    }
                    
                    // Extract just the numeric price value without the "Rs." prefix or commas
                    String unitPriceStrDisplay = itemPrices[i].replace("Rs.", "").replace(",", "").trim();
                    double unitPriceDisplay = 0.0;
                    try {
                        unitPriceDisplay = Double.parseDouble(unitPriceStrDisplay);
                    } catch (NumberFormatException e) {
                        // Keep default 0.0 if parsing fails
                    }
                    
                    // Calculate total price for display
                    double totalPriceDisplay = qty * unitPriceDisplay;
        %>
            <div class="receipt-item" data-name="<%= itemNames[i] %>" data-qty="<%= itemQtys[i] %>" data-price="<%= itemPrices[i] %>" data-total-price="<%= String.format("%.2f", totalPriceDisplay) %>">
                <span class="item-name"><%= itemNames[i] %></span>
                <span class="item-qty"><%= itemQtys[i] %></span>
                <span class="item-unit-price">Rs.<%= String.format("%.2f", unitPriceDisplay) %></span>
                <span class="item-total-price">Rs.<%= String.format("%.2f", totalPriceDisplay) %></span>
            </div>
        <%
                }
            } else {
        %>
            <div class="receipt-item"><span colspan="4" style="text-align:center;">No items found.</span></div>
        <%
            }
        %>
    </div>

    <div class="receipt-summary">
        <div class="receipt-row"><span>Subtotal:</span><span id="subtotalDisplay"><%= subtotal %></span></div>
        <div class="receipt-row"><span>Discount:</span><span id="discountDisplay"><%= discount %></span></div>
        <div class="receipt-row"><span>Tax:</span><span id="taxDisplay"><%= tax %></span></div>
        <div class="receipt-row total"><span>Total:</span><span id="totalDisplay"><%= total %></span></div>
    </div>

    <div class="payment-details-section">
         <div class="receipt-row payment-method-row">
            <span>Payment Method:</span>
            <span id="paymentMethodDisplay"><%= paymentMethod != null ? (paymentMethod.substring(0, 1).toUpperCase() + paymentMethod.substring(1)) : "N/A" %></span>
        </div>
        <% if ("cash".equalsIgnoreCase(paymentMethod) && cashReceived != null && changeDue != null) { %>
            <div class="receipt-row payment-method-row"><span>Cash Received:</span><span id="cashReceivedDisplay"><%= cashReceived %></span></div>
            <div class="receipt-row payment-method-row"><span>Change:</span><span id="changeDueDisplay"><%= changeDue %></span></div>
        <% } else if ("card".equalsIgnoreCase(paymentMethod) && cardLast4 != null) { %>
            <div class="receipt-row payment-method-row"><span>Card Used:</span><span id="cardLast4Display">**** **** **** <%= cardLast4 %></span></div>
        <% } %>
    </div>

    <div class="receipt-footer">
        <p>Thank you for shopping with us!</p>
        <p>Return policy: Items can be returned within 30 days with receipt</p>
        <div class="barcode">
            <img src="https://barcode.tec-it.com/barcode.ashx?data=<%= receiptNumber %>&code=Code128&translate-esc=on" alt="Barcode">
        </div>
    </div>
</div>

<div class="action-buttons">
    <button onclick="window.print();"><i class="fas fa-print"></i> Print Receipt</button>
    <button id="emailReceiptBtn" onclick="sendReceiptByEmail();"><i class="fas fa-envelope"></i> Email Receipt</button>
    <button onclick="window.location.href='${pageContext.request.contextPath}/Cashier/cashier_dashboard.jsp';"><i class="fas fa-arrow-left"></i> New Sale</button>
</div>
<div id="emailStatusMessage" class="status-message"></div>

<script>
    function sendReceiptByEmail() {
        const emailButton = document.getElementById('emailReceiptBtn');
        const statusMessage = document.getElementById('emailStatusMessage');

        let recipientEmail = prompt("Please enter the recipient's email address:", "");
        if (!recipientEmail) {
            statusMessage.textContent = "Email address not provided.";
            statusMessage.className = 'status-message error';
            return;
        }
        // Basic email validation
        if (!/^\S+@\S+\.\S+$/.test(recipientEmail)) {
            statusMessage.textContent = "Invalid email address format.";
            statusMessage.className = 'status-message error';
            return;
        }

        emailButton.disabled = true;
        statusMessage.textContent = "Sending email...";
        statusMessage.className = 'status-message';

        // Prepare data to send to the servlet
        const receiptData = {
            recipientEmail: recipientEmail,
            receiptNumber: "<%= receiptNumber %>",
            receiptDate: "<%= receiptDate %>",
            cashier: "<%= cashier %>",
            subtotal: "<%= subtotal %>", // These are original strings from parameters
            discount: "<%= discount %>",
            tax: "<%= tax %>",
            total: "<%= total %>",
            paymentMethod: "<%= paymentMethod %>",
            cashReceived: "<%= cashReceived %>",
            changeDue: "<%= changeDue %>",
            cardLast4: "<%= cardLast4 %>",
            items: []
        };

        const itemElements = document.querySelectorAll('.receipt-item');
        itemElements.forEach(itemEl => {
            const name = itemEl.dataset.name; // Using data attributes set in JSP loop
            const qty = itemEl.dataset.qty;
            const unitPrice = itemEl.dataset.price; // This is the original string like "Rs.1,234.00"
            const totalPrice = itemEl.dataset.totalPrice; // This is calculated in display loop Rs.XXXX.XX
            if (name && qty && unitPrice) { // Ensure all parts are present
                 receiptData.items.push({ 
                    name: name, 
                    qty: qty, 
                    unitPrice: unitPrice, // Send original string
                    totalPrice: "Rs." + totalPrice // Re-add Rs. if dataset.totalPrice is just number
                });
            }
        });
        
        // AJAX request to the EmailReceiptServlet
        fetch('${pageContext.request.contextPath}/emailReceiptAction', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(receiptData)
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                statusMessage.textContent = "Email sent successfully to " + recipientEmail + "!";
                statusMessage.className = 'status-message success';
            } else {
                statusMessage.textContent = "Failed to send email: " + (data.message || "Unknown error");
                statusMessage.className = 'status-message error';
            }
        })
        .catch(error => {
            console.error('Error sending email:', error);
            statusMessage.textContent = "Error sending email. Please check console for details.";
            statusMessage.className = 'status-message error';
        })
        .finally(() => {
            emailButton.disabled = false;
        });
    }

    // Check for database save status on page load
    window.onload = function() {
        <% if (dbSaveSuccess) { %>
            console.log("Receipt data saved to database with Sale ID: <%= savedSaleId %>");
        <% } else if (dbSaveError != null) { %>
            // Sanitize dbSaveError for JavaScript string literal
            var dbErrorMsg = "<%= dbSaveError != null ? dbSaveError.replace("\"", "\\\"").replace("\n", " ").replace("\r", " ") : "" %>";
            console.error("Database save error: " + dbErrorMsg);
        <% } %>

        <% if (overallStockUpdateSuccess == false && stockUpdateError != null) { %>
            var stockErrorMsg = "<%= stockUpdateError != null ? stockUpdateError.replace("\"", "\\\"").replace("<br/>", "\\n").replace("<br>", "\\n").replace("\n", " ").replace("\r", " ") : "" %>";
            console.warn("Stock Update Issue: " + stockErrorMsg);
        <% } %>
    };
</script>

</body>
</html>