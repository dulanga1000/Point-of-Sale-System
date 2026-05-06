<%--
    Document   : edit_purchase_order
    Created on : May 21, 2025
    Author     : AI / Your Name
    Based on   : swift_database (28).sql
    MODIFIED TO INCLUDE UPDATE LOGIC IN JSP (NOT RECOMMENDED FOR PRODUCTION)
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat, java.util.Locale, java.time.LocalDate" %>

<%
    // General DB Connection Details (also used in user profile and data loading)
    String _URL = "jdbc:mysql://localhost:3306/swift_database";
    String _USER = "root";
    String _PASSWORD = ""; // Ensure this is secure in a real app

    String poMainIdForPage = request.getParameter("id");
    String updateFeedbackMessage = null;
    String updateErrorMessage = null;

    // --- BEGIN POST Request Handling (Form Submission Logic) ---
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        Connection updateConn = null;
        boolean autoCommitInitialState = true;

        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            updateConn = DriverManager.getConnection(_URL, _USER, _PASSWORD);
            autoCommitInitialState = updateConn.getAutoCommit();
            updateConn.setAutoCommit(false); // Start transaction

            // Retrieve main PO details from form
            int poMainId = Integer.parseInt(request.getParameter("po_main_id"));
            poMainIdForPage = String.valueOf(poMainId); // Keep for page rendering

            int supplierIdVal = Integer.parseInt(request.getParameter("supplier_id"));
            String orderDateFormVal = request.getParameter("order_date_form");
            String expectedDeliveryDateVal = request.getParameter("expected_delivery_date");
            String paymentTermsVal = request.getParameter("payment_terms");
            String shippingMethodVal = request.getParameter("shipping_method");
            String notesVal = request.getParameter("notes");
            String orderStatusVal = request.getParameter("order_status");
            
            double taxPercentageVal = Double.parseDouble(request.getParameter("tax_percentage"));
            double shippingFeeVal = Double.parseDouble(request.getParameter("shipping_fee"));

            // Retrieve and process item details
            String[] itemPoItemIds = request.getParameterValues("item_po_item_id");
            String[] itemQuantities = request.getParameterValues("item_quantity_ordered");
            String[] itemUnitPrices = request.getParameterValues("item_unit_price_at_order");

            double newSubtotal = 0;

            if (itemPoItemIds != null) {
                PreparedStatement pstmtUpdateItem = updateConn.prepareStatement(
                    "UPDATE swift_purchase_order_items SET quantity_ordered = ?, unit_price_at_order = ? WHERE po_item_id = ? AND po_main_id = ?"
                );
                for (int i = 0; i < itemPoItemIds.length; i++) {
                    int poItemId = Integer.parseInt(itemPoItemIds[i]);
                    int quantity = Integer.parseInt(itemQuantities[i]);
                    double unitPrice = Double.parseDouble(itemUnitPrices[i]);

                    newSubtotal += (quantity * unitPrice);

                    pstmtUpdateItem.setInt(1, quantity);
                    pstmtUpdateItem.setDouble(2, unitPrice);
                    pstmtUpdateItem.setInt(3, poItemId);
                    pstmtUpdateItem.setInt(4, poMainId);
                    pstmtUpdateItem.executeUpdate();
                }
                pstmtUpdateItem.close();
            }
            
            // Recalculate tax amount and grand total based on updated items
            double newTaxAmount = (newSubtotal * taxPercentageVal) / 100.0;
            double newGrandTotal = newSubtotal + newTaxAmount + shippingFeeVal;

            // Update swift_purchase_orders_main table
            PreparedStatement pstmtUpdatePoMain = updateConn.prepareStatement(
                "UPDATE swift_purchase_orders_main SET supplier_id = ?, order_date_form = ?, expected_delivery_date = ?, " +
                "payment_terms = ?, shipping_method = ?, notes = ?, order_status = ?, " +
                "subtotal = ?, tax_percentage = ?, tax_amount = ?, shipping_fee = ?, grand_total = ? " +
                "WHERE po_main_id = ?"
            );
            pstmtUpdatePoMain.setInt(1, supplierIdVal);
            pstmtUpdatePoMain.setString(2, orderDateFormVal);
            pstmtUpdatePoMain.setString(3, expectedDeliveryDateVal);
            pstmtUpdatePoMain.setString(4, paymentTermsVal);
            pstmtUpdatePoMain.setString(5, shippingMethodVal);
            pstmtUpdatePoMain.setString(6, notesVal);
            pstmtUpdatePoMain.setString(7, orderStatusVal);
            pstmtUpdatePoMain.setDouble(8, newSubtotal);
            pstmtUpdatePoMain.setDouble(9, taxPercentageVal);
            pstmtUpdatePoMain.setDouble(10, newTaxAmount);
            pstmtUpdatePoMain.setDouble(11, shippingFeeVal);
            pstmtUpdatePoMain.setDouble(12, newGrandTotal);
            pstmtUpdatePoMain.setInt(13, poMainId);
            
            int rowsAffected = pstmtUpdatePoMain.executeUpdate();
            pstmtUpdatePoMain.close();

            updateConn.commit(); // Commit transaction
            updateFeedbackMessage = "Purchase Order #" + request.getParameter("order_number_display") + " updated successfully!";
            // Optional: Redirect to view page after successful update
            // response.sendRedirect("view_purchase_order.jsp?id=" + poMainId + "&successMsg=" + java.net.URLEncoder.encode(updateFeedbackMessage, "UTF-8"));
            // return;


        } catch (Exception e) {
            if (updateConn != null) {
                try {
                    updateConn.rollback(); // Rollback transaction on error
                } catch (SQLException se) {
                    // Log rollback error
                }
            }
            updateErrorMessage = "Error updating Purchase Order: " + e.getMessage();
            e.printStackTrace(); // For server logs
        } finally {
            if (updateConn != null) {
                try {
                    updateConn.setAutoCommit(autoCommitInitialState); // Restore autocommit
                    updateConn.close();
                } catch (SQLException e) {
                    // Log closing error
                }
            }
        }
    }
    // --- END POST Request Handling ---
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Purchase Order - Swift POS</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        :root {
            --primary: #007bff; --secondary: #6c757d; --success: #28a745;
            --danger: #dc3545; --warning: #ffc107; --info: #17a2b8;
            --light: #f8f9fa; --dark: #343a40;
        }
        body { font-family: Arial, sans-serif; margin: 0; background-color: #f4f6f9; color: #333; }
        .dashboard { display: flex; }
        .main-content { flex-grow: 1; padding: 20px; }
        .header { display: flex; justify-content: space-between; align-items: center; padding-bottom: 15px; border-bottom: 1px solid #eee; margin-bottom: 20px; }
        .page-title { font-size: 1.8em; color: var(--dark); }
        .user-profile img { width: 40px; height: 40px; border-radius: 50%; margin-right: 10px; }

        .form-card { background-color: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); }
        .form-header { padding: 15px 20px; border-bottom: 1px solid #eee; background-color: var(--primary); color:white; border-top-left-radius: 8px; border-top-right-radius: 8px;}
        .form-header h2 { margin: 0; font-size: 1.4em; }
        .form-section { padding: 20px; }
        .form-section h3 { font-size: 1.2em; color: var(--primary); margin-top: 0; margin-bottom: 15px; border-bottom: 1px solid #eee; padding-bottom: 8px;}
        
        .form-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; font-weight: bold; color: #555; }
        .form-group input[type="text"],
        .form-group input[type="date"],
        .form-group input[type="number"],
        .form-group select,
        .form-group textarea {
            width: 100%; padding: 10px; border: 1px solid #ccc; border-radius: 4px;
            box-sizing: border-box; font-size: 0.95em;
        }
        .form-group textarea { min-height: 80px; resize: vertical; }
        .form-group input[readonly] { background-color: #e9ecef; cursor: not-allowed; }

        .items-table-edit { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .items-table-edit th, .items-table-edit td { padding: 10px; text-align: left; border-bottom: 1px solid #eee; }
        .items-table-edit thead th { background-color: var(--light); font-weight: bold; }
        .items-table-edit td input[type="number"] { width: 80px; text-align: right; }
        .items-table-edit td.action-cell { text-align: center; }
        .remove-item-btn { background-color: var(--danger); color:white; border:none; padding: 5px 8px; border-radius:3px; cursor:pointer; font-size:0.8em; }
        
        .totals-summary { margin-top: 20px; padding: 15px; background-color: var(--light); border-radius: 5px; }
        .totals-summary div { display: flex; justify-content: space-between; margin-bottom: 5px; font-size: 0.95em; }
        .totals-summary strong { font-weight: bold; }
        .totals-summary .grand-total strong, .totals-summary .grand-total span { font-size: 1.1em; color: var(--primary); }

        .form-actions { padding: 20px; text-align: right; border-top: 1px solid #eee; margin-top:10px;}
        .submit-btn { background-color: var(--success); color: white; padding: 12px 25px; border:none; border-radius:5px; cursor:pointer; font-weight:bold; font-size: 1em;}
        .cancel-btn { background-color: var(--secondary); color: white; padding: 12px 25px; border:none; border-radius:5px; cursor:pointer; font-weight:bold; font-size: 1em; margin-right:10px; text-decoration:none;}
        .footer { text-align: center; padding: 20px; margin-top: 30px; font-size: 0.9em; color: #777;}
        .feedback-message { padding: 15px; margin-bottom: 20px; border: 1px solid transparent; border-radius: .25rem; font-size: 1rem; text-align: center; }
        .feedback-message.success { color: #155724; background-color: #d4edda; border-color: #c3e6cb; }
        .feedback-message.error { color: #721c24; background-color: #f8d7da; border-color: #f5c6cb; }
    </style>
</head>
<body>
    <div class="dashboard">
        <div class="sidebar" id="sidebar">
             <div class="logo">
                <img src="${pageContext.request.contextPath}/Images/logo.png" alt="POS Logo">
                <h2>Swift</h2>
            </div>
            <jsp:include page="menu.jsp" />
        </div>

        <div class="main-content">
            <div class="header">
                <h1 class="page-title">Edit Purchase Order</h1>
                 <div class="user-profile">
                    <%
                        Connection _userConnLocal = null; PreparedStatement _userSqlLocal = null; ResultSet _userResultLocal = null;
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            _userConnLocal = DriverManager.getConnection(_URL, _USER, _PASSWORD);
                            _userSqlLocal = _userConnLocal.prepareStatement("SELECT first_name, profile_image_path FROM users WHERE role = 'admin' LIMIT 1");
                            _userResultLocal = _userSqlLocal.executeQuery();
                            if (_userResultLocal.next()) {
                    %>
                            <img src="${pageContext.request.contextPath}/<%= _userResultLocal.getString("profile_image_path") %>" alt="Admin Profile">
                            <div><h4><%= _userResultLocal.getString("first_name") %></h4></div>
                    <%      }
                        } catch (Exception ex) { out.println("<p class='text-danger'>Error loading user profile: " + ex.getMessage() + "</p>"); } 
                        finally {
                            if (_userResultLocal != null) try { _userResultLocal.close(); } catch (SQLException e) {}
                            if (_userSqlLocal != null) try { _userSqlLocal.close(); } catch (SQLException e) {}
                            if (_userConnLocal != null) try { _userConnLocal.close(); } catch (SQLException e) {}
                        }
                    %>
                </div>
            </div>
            
            <%-- Display Feedback Messages from POST handling --%>
            <% if (updateFeedbackMessage != null) { %>
                <div class="feedback-message success"><%= updateFeedbackMessage %></div>
            <% } %>
            <% if (updateErrorMessage != null) { %>
                <div class="feedback-message error"><%= updateErrorMessage %></div>
            <% } %>


            <%
                // String poMainIdStr = request.getParameter("id"); // Already fetched for POST, reuse poMainIdForPage
                if (poMainIdForPage == null || poMainIdForPage.trim().isEmpty()) {
                    out.println("<p class='feedback-message error'>No Purchase Order ID provided.</p>");
                    return; // Stop further rendering if ID is missing and not a POST request recovery
                }

                Connection dataLoadConn = null;
                PreparedStatement pstmtPoMain = null;
                ResultSet rsPoMain = null;
                PreparedStatement pstmtPoItems = null;
                ResultSet rsPoItems = null;
                PreparedStatement pstmtSuppliers = null;
                ResultSet rsSuppliers = null;

                String orderNumberDisplay = "", supplierId = "", orderDateForm = LocalDate.now().toString();
                String expectedDeliveryDate = LocalDate.now().plusDays(7).toString(), paymentTerms = "";
                String shippingMethod = "", notes = "", orderStatus = "Pending";
                double subtotal = 0, taxPercentage = 0, taxAmount = 0, shippingFee = 0, grandTotal = 0;
                
                List<Map<String, String>> poItemsList = new ArrayList<>();

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    dataLoadConn = DriverManager.getConnection(_URL, _USER, _PASSWORD);

                    String sqlPoMain = "SELECT * FROM swift_purchase_orders_main WHERE po_main_id = ?";
                    pstmtPoMain = dataLoadConn.prepareStatement(sqlPoMain);
                    pstmtPoMain.setInt(1, Integer.parseInt(poMainIdForPage));
                    rsPoMain = pstmtPoMain.executeQuery();

                    if (rsPoMain.next()) {
                        orderNumberDisplay = rsPoMain.getString("order_number_display");
                        supplierId = rsPoMain.getString("supplier_id");
                        orderDateForm = rsPoMain.getString("order_date_form");
                        expectedDeliveryDate = rsPoMain.getString("expected_delivery_date");
                        paymentTerms = rsPoMain.getString("payment_terms");
                        shippingMethod = rsPoMain.getString("shipping_method");
                        notes = rsPoMain.getString("notes");
                        subtotal = rsPoMain.getDouble("subtotal");
                        taxPercentage = rsPoMain.getDouble("tax_percentage");
                        taxAmount = rsPoMain.getDouble("tax_amount");
                        shippingFee = rsPoMain.getDouble("shipping_fee");
                        grandTotal = rsPoMain.getDouble("grand_total");
                        orderStatus = rsPoMain.getString("order_status");

                        String sqlPoItems = "SELECT poi.*, p.name AS product_name, p.sku AS product_sku " +
                                            "FROM swift_purchase_order_items poi " +
                                            "JOIN products p ON poi.product_id = p.id " +
                                            "WHERE poi.po_main_id = ?";
                        pstmtPoItems = dataLoadConn.prepareStatement(sqlPoItems);
                        pstmtPoItems.setInt(1, Integer.parseInt(poMainIdForPage));
                        rsPoItems = pstmtPoItems.executeQuery();
                        while(rsPoItems.next()){
                            Map<String, String> item = new HashMap<>();
                            item.put("po_item_id", rsPoItems.getString("po_item_id"));
                            item.put("product_id", rsPoItems.getString("product_id"));
                            item.put("product_name", rsPoItems.getString("product_name"));
                            item.put("product_sku", rsPoItems.getString("product_sku"));
                            item.put("quantity_ordered", rsPoItems.getString("quantity_ordered"));
                            item.put("unit_price_at_order", String.format("%.2f", rsPoItems.getDouble("unit_price_at_order")));
                            // row_total_at_order is a generated column, calculate for display consistency
                            item.put("row_total_at_order", String.format("%.2f", rsPoItems.getInt("quantity_ordered") * rsPoItems.getDouble("unit_price_at_order") ));
                            poItemsList.add(item);
                        }
            %>
            <div class="form-card">
                <%-- Submit to self to handle POST request within this JSP --%>
                <form action="edit_purchase_order.jsp?id=<%= poMainIdForPage %>" method="POST" id="editPoForm"> 
                    <input type="hidden" name="po_main_id" value="<%= poMainIdForPage %>">
                    <input type="hidden" name="order_number_display" value="<%= orderNumberDisplay %>">

                    <div class="form-header"><h2>Edit Order #<%= orderNumberDisplay %></h2></div>

                    <div class="form-section">
                        <h3>Header Information</h3>
                        <div class="form-grid">
                            <div class="form-group">
                                <label for="supplier_id">Supplier:</label>
                                <select name="supplier_id" id="supplier_id" required>
                                    <%
                                        pstmtSuppliers = dataLoadConn.prepareStatement("SELECT supplier_id, company_name FROM suppliers ORDER BY company_name");
                                        rsSuppliers = pstmtSuppliers.executeQuery();
                                        while(rsSuppliers.next()){
                                            String supId = rsSuppliers.getString("supplier_id");
                                            String supName = rsSuppliers.getString("company_name");
                                            boolean isSelected = supId.equals(supplierId);
                                    %>
                                    <option value="<%= supId %>" <%= isSelected ? "selected" : "" %>><%= supName %></option>
                                    <% } %>
                                </select>
                            </div>
                            <div class="form-group">
                                <label for="order_date_form">Order Date:</label>
                                <input type="date" id="order_date_form" name="order_date_form" value="<%= orderDateForm %>" required>
                            </div>
                             <div class="form-group">
                                <label for="expected_delivery_date">Expected Delivery Date:</label>
                                <input type="date" id="expected_delivery_date" name="expected_delivery_date" value="<%= expectedDeliveryDate %>" required>
                            </div>
                            <div class="form-group">
                                <label for="payment_terms">Payment Terms:</label>
                                <input type="text" id="payment_terms" name="payment_terms" value="<%= paymentTerms != null ? paymentTerms : "" %>">
                            </div>
                            <div class="form-group">
                                <label for="shipping_method">Shipping Method:</label>
                                <input type="text" id="shipping_method" name="shipping_method" value="<%= shippingMethod != null ? shippingMethod : "" %>">
                            </div>
                           <div class="form-group">
                                <label for="order_status">Order Status:</label>
                                <select name="order_status" id="order_status" required>
                                    <% String[] statuses = {"Draft", "Pending", "Approved", "Ordered", "Partially Received", "Received", "Shipped", "Cancelled", "Closed"};
                                       for(String s : statuses) {
                                           boolean isSelected = s.equalsIgnoreCase(orderStatus);
                                    %>
                                    <option value="<%= s %>" <%= isSelected ? "selected" : "" %>><%= s %></option>
                                    <% } %>
                                </select>
                            </div>
                        </div>
                         <div class="form-group">
                            <label for="notes">Notes:</label>
                            <textarea id="notes" name="notes" rows="3"><%= notes != null ? notes : "" %></textarea>
                        </div>
                    </div>

                    <div class="form-section">
                        <h3>Order Items</h3>
                        <table class="items-table-edit" id="poItemsTable">
                            <thead>
                                <tr>
                                    <th>Product</th>
                                    <th>SKU</th>
                                    <th>Quantity</th>
                                    <th>Unit Price (Rs.)</th>
                                    <th>Row Total (Rs.)</th>
                                </tr>
                            </thead>
                            <tbody>
                            <% for(int i=0; i < poItemsList.size(); i++) {
                                Map<String, String> item = poItemsList.get(i);
                            %>
                                <tr class="item-row">
                                    <%-- These hidden fields are crucial for submitting item data --%>
                                    <input type="hidden" name="item_po_item_id" value="<%= item.get("po_item_id") %>">
                                    <%-- Product ID is not editable here but needed if re-associating. For now, it's fixed. --%>
                                    <%-- <input type="hidden" name="item_product_id" value="<%= item.get("product_id") %>"> --%>
                                    <td><%= item.get("product_name") %></td>
                                    <td><%= item.get("product_sku") %></td>
                                    <td><input type="number" name="item_quantity_ordered" class="item-quantity" value="<%= item.get("quantity_ordered") %>" min="1" step="1" onchange="calculateRowTotal(this); calculateGrandTotal();" required></td>
                                    <td><input type="number" name="item_unit_price_at_order" class="item-price" value="<%= item.get("unit_price_at_order") %>" min="0" step="0.01" onchange="calculateRowTotal(this); calculateGrandTotal();" required></td>
                                    <td class="item-row-total"><%= String.format("%.2f", Double.parseDouble(item.get("quantity_ordered")) * Double.parseDouble(item.get("unit_price_at_order"))) %></td>
                                </tr>
                            <% } 
                                if (poItemsList.isEmpty()) {
                                    out.println("<tr><td colspan='5' style='text-align:center;'>No items in this order. Editing items is limited.</td></tr>");
                                }
                            %>
                            </tbody>
                        </table>
                    </div>

                    <div class="form-section">
                        <h3>Summary</h3>
                         <div class="form-grid">
                            <div class="form-group">
                                <label for="subtotal">Subtotal (Rs.):</label>
                                <input type="text" id="subtotal" name="subtotal" value="<%= String.format("%.2f", subtotal) %>" readonly>
                            </div>
                            <div class="form-group">
                                <label for="tax_percentage">Tax (%):</label>
                                <input type="number" id="tax_percentage" name="tax_percentage" value="<%= String.format("%.2f", taxPercentage) %>" min="0" step="0.01" onchange="calculateGrandTotal();">
                            </div>
                            <div class="form-group">
                                <label for="tax_amount">Tax Amount (Rs.):</label>
                                <input type="text" id="tax_amount" name="tax_amount" value="<%= String.format("%.2f", taxAmount) %>" readonly>
                            </div>
                            <div class="form-group">
                                <label for="shipping_fee">Shipping Fee (Rs.):</label>
                                <input type="number" id="shipping_fee" name="shipping_fee" value="<%= String.format("%.2f", shippingFee) %>" min="0" step="0.01" onchange="calculateGrandTotal();">
                            </div>
                         </div>
                         <div class="totals-summary" style="margin-top:10px; padding:10px; background-color:#f0f0f0;">
                            <div class="grand-total">
                                <strong>Grand Total (Rs.):</strong>
                                <span id="grand_total_display"><%= String.format("%.2f", grandTotal) %></span>
                                <input type="hidden" id="grand_total" name="grand_total" value="<%= String.format("%.2f", grandTotal) %>">
                            </div>
                        </div>
                    </div>

                    <div class="form-actions">
                        <a href="${pageContext.request.contextPath}/Admin/view_purchase_order.jsp?id=<%= poMainIdForPage %>" class="cancel-btn">Cancel</a>
                        <button type="submit" class="submit-btn">Update Purchase Order</button>
                    </div>
                </form>
            </div>
            <%
                    } else {
                        out.println("<p class='feedback-message error'>Purchase Order not found for editing.</p>");
                    }
                } catch (NumberFormatException nfe){
                    out.println("<p class='feedback-message error'>Invalid Purchase Order ID format.</p>");
                } catch (Exception e) {
                    out.println("<p class='feedback-message error'>Error loading purchase order for editing: " + e.getMessage() + "</p>");
                    e.printStackTrace();
                } finally {
                    // Close all data loading resources
                    if (rsPoItems != null) try { rsPoItems.close(); } catch (SQLException e) {}
                    if (pstmtPoItems != null) try { pstmtPoItems.close(); } catch (SQLException e) {}
                    if (rsPoMain != null) try { rsPoMain.close(); } catch (SQLException e) {}
                    if (pstmtPoMain != null) try { pstmtPoMain.close(); } catch (SQLException e) {}
                    if (rsSuppliers != null) try { rsSuppliers.close(); } catch (SQLException e) {}
                    if (pstmtSuppliers != null) try { pstmtSuppliers.close(); } catch (SQLException e) {}
                    if (dataLoadConn != null) try { dataLoadConn.close(); } catch (SQLException e) {}
                }
            %>
            <div class="footer">
                Swift © <%= java.time.Year.now().getValue() %>.
            </div>
        </div>
    </div>
<script>
    document.getElementById('mobileNavToggle').addEventListener('click', function() {
        document.getElementById('sidebar').classList.toggle('active');
    });

    function calculateRowTotal(inputElement) {
        const row = inputElement.closest('.item-row');
        const quantity = parseFloat(row.querySelector('.item-quantity').value) || 0;
        const price = parseFloat(row.querySelector('.item-price').value) || 0;
        const rowTotal = quantity * price;
        row.querySelector('.item-row-total').textContent = rowTotal.toFixed(2);
    }

    function calculateGrandTotal() {
        let currentSubtotal = 0;
        document.querySelectorAll('#poItemsTable tbody .item-row').forEach(row => {
            const quantityInput = row.querySelector('.item-quantity');
            const priceInput = row.querySelector('.item-price');
            if (quantityInput && priceInput) { // Ensure inputs exist
                 const quantity = parseFloat(quantityInput.value) || 0;
                 const price = parseFloat(priceInput.value) || 0;
                 currentSubtotal += quantity * price;
            }
        });
        document.getElementById('subtotal').value = currentSubtotal.toFixed(2);

        const taxPercent = parseFloat(document.getElementById('tax_percentage').value) || 0;
        const currentTaxAmount = (currentSubtotal * taxPercent) / 100;
        document.getElementById('tax_amount').value = currentTaxAmount.toFixed(2);

        const currentShippingFee = parseFloat(document.getElementById('shipping_fee').value) || 0;
        
        const currentGrandTotal = currentSubtotal + currentTaxAmount + currentShippingFee;
        document.getElementById('grand_total_display').textContent = currentGrandTotal.toFixed(2);
        document.getElementById('grand_total').value = currentGrandTotal.toFixed(2);
    }

    document.addEventListener('DOMContentLoaded', function() {
        calculateGrandTotal(); 
    });
</script>
</body>
</html>