<%--
    Document   : add_purchase_order (Modified for supplier company name snapshot and email clarity)
    Created on : May 16, 2025, 9:30:15 AM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="model.User" %>
<%@ page import="model.Supplier" %>
<%@ page import="model.Product" %>
<%@ page import="dao.SupplierDAO" %>
<%@ page import="dao.ProductDAO" %>
<%@ page import="util.EmailUtil" %>
<%@ page import="java.text.DecimalFormat" %>

<%
// SERVER-SIDE PROCESSING FOR PURCHASE ORDER SUBMISSION
if ("POST".equalsIgnoreCase(request.getMethod())) {
    Connection conn_post = null;
    PreparedStatement pstmtMain = null;
    PreparedStatement pstmtItems = null;
    ResultSet generatedKeys = null;

    String URL_POST = "jdbc:mysql://localhost:3306/swift_database"; 
    String USER_POST = "root";
    String PASSWORD_POST = ""; // Your DB password

    User loggedInUser_post = (User) session.getAttribute("loggedInUser");
    int createdByUserId = 0;
    String createdByUserFullName = "System";
    String orderNumberDisplay = ""; 

    if (loggedInUser_post != null) {
        createdByUserId = loggedInUser_post.getId(); 
        createdByUserFullName = loggedInUser_post.getFirstName() + " " + loggedInUser_post.getLastName();
    } else {
        session.setAttribute("poMessage", "Error: User not logged in. Please login to create a purchase order.");
        session.setAttribute("poMessageType", "error");
        response.sendRedirect(request.getRequestURI());
        return;
    }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn_post = DriverManager.getConnection(URL_POST, USER_POST, PASSWORD_POST);
        conn_post.setAutoCommit(false); 

        orderNumberDisplay = request.getParameter("order_id");
        
        String supplierIdParam = request.getParameter("supplier_id");
        if (supplierIdParam == null || supplierIdParam.trim().isEmpty()) {
            throw new Exception("Supplier ID is missing. Please select a supplier.");
        }
        int supplierId = Integer.parseInt(supplierIdParam);

        // *** NEW: Fetch supplier company name for snapshot ***
        String supplierCompanyNameSnapshot = null;
        PreparedStatement pstmtFetchSupplierName = null;
        ResultSet rsFetchSupplierName = null;
        try {
            pstmtFetchSupplierName = conn_post.prepareStatement("SELECT company_name FROM suppliers WHERE supplier_id = ?");
            pstmtFetchSupplierName.setInt(1, supplierId);
            rsFetchSupplierName = pstmtFetchSupplierName.executeQuery();
            if (rsFetchSupplierName.next()) {
                supplierCompanyNameSnapshot = rsFetchSupplierName.getString("company_name");
            } else {
                // This should ideally not happen if supplier_id is from a valid selection
                throw new Exception("Selected supplier with ID " + supplierId + " not found in database. Cannot retrieve company name.");
            }
        } finally {
            if (rsFetchSupplierName != null) try { rsFetchSupplierName.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (pstmtFetchSupplierName != null) try { pstmtFetchSupplierName.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
        // *** END NEW ***

        String orderDateForm = request.getParameter("order_date");
        String expectedDeliveryDate = request.getParameter("expected_date");
        String paymentTerms = request.getParameter("payment_terms");
        String shippingMethod = request.getParameter("shipping_method");
        String notes_param = request.getParameter("notes");

        String taxPercentageParam = request.getParameter("tax_percentage");
        if (taxPercentageParam == null || taxPercentageParam.trim().isEmpty()) {
            throw new Exception("Tax percentage is missing.");
        }
        double taxPercentage = Double.parseDouble(taxPercentageParam);

        String shippingFeeParam = request.getParameter("shipping_cost");
         if (shippingFeeParam == null || shippingFeeParam.trim().isEmpty()) {
            throw new Exception("Shipping cost is missing.");
        }
        double shippingFee = Double.parseDouble(shippingFeeParam);
        
        String orderStatus = "Pending";

        String[] productIdsStr = request.getParameterValues("product_id[]");
        String[] quantitiesStr = request.getParameterValues("quantity[]");
        String[] unitPricesAtOrderStr = request.getParameterValues("unit_price_at_order_hidden[]"); 

        if (productIdsStr == null || quantitiesStr == null || unitPricesAtOrderStr == null || productIdsStr.length == 0) {
            throw new Exception("No product items found in the order. Please add at least one product.");
        }
        if (productIdsStr.length != quantitiesStr.length || productIdsStr.length != unitPricesAtOrderStr.length) {
            throw new Exception("Mismatch in product items data. Please check your entries.");
        }

        List<Map<String, Object>> orderItems = new ArrayList<>();
        double subtotal = 0;
        
        // Assuming ProductDAO constructor can accept a Connection object
        ProductDAO productDAO_for_names = new ProductDAO(conn_post); 

        for (int i = 0; i < productIdsStr.length; i++) {
            if (productIdsStr[i] == null || productIdsStr[i].trim().isEmpty() || "null".equalsIgnoreCase(productIdsStr[i]) || "".equals(productIdsStr[i])) {
                continue; 
            }
            if (quantitiesStr[i] == null || quantitiesStr[i].trim().isEmpty()) {
                throw new Exception("Quantity is missing for one of the products.");
            }
            int quantityOrdered = Integer.parseInt(quantitiesStr[i]);
            if (quantityOrdered <= 0) {
                 throw new Exception("Invalid quantity for product. Quantity must be greater than 0.");
            }

            int productId = Integer.parseInt(productIdsStr[i]);
            double unitPriceForPOItem = 0;
            try {
                unitPriceForPOItem = Double.parseDouble(unitPricesAtOrderStr[i]);
                 if (unitPriceForPOItem <= 0) { // Also check if price is zero or negative
                       Product tempProd = productDAO_for_names.getProductById(productId);
                       String tempProdName = tempProd != null ? tempProd.getName() : "ID: " + productId;
                      throw new Exception("Product '" + tempProdName + "' has an invalid (zero, negative, or undefined) unit price. Please ensure it is correctly set up.");
                 }
            } catch (NumberFormatException nfe){
                throw new Exception("Invalid unit price format for one of the products.");
            }


            double rowTotalAtOrder = quantityOrdered * unitPriceForPOItem;
            subtotal += rowTotalAtOrder;

            Map<String, Object> item = new HashMap<>();
            item.put("product_id", productId);
            item.put("quantity_ordered", quantityOrdered);
            item.put("unit_price_at_order", unitPriceForPOItem); 
            item.put("row_total_at_order", rowTotalAtOrder);
            orderItems.add(item);
        }
        
        if (orderItems.isEmpty()) {
             throw new Exception("No valid product items were processed. Please ensure products are selected and quantities are valid.");
        }

        double taxAmount = (subtotal * taxPercentage) / 100;
        double grandTotal = subtotal + taxAmount + shippingFee;

        // *** MODIFIED SQL INSERT Statement ***
        String sqlMain = "INSERT INTO swift_purchase_orders_main (order_number_display, supplier_id, order_date_form, expected_delivery_date, payment_terms, shipping_method, notes, subtotal, tax_percentage, tax_amount, shipping_fee, grand_total, order_status, created_by_user_id, created_by_user_full_name, supplier_company_name) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        pstmtMain = conn_post.prepareStatement(sqlMain, Statement.RETURN_GENERATED_KEYS);
        pstmtMain.setString(1, orderNumberDisplay);
        pstmtMain.setInt(2, supplierId);
        pstmtMain.setDate(3, java.sql.Date.valueOf(orderDateForm));
        pstmtMain.setDate(4, java.sql.Date.valueOf(expectedDeliveryDate));
        pstmtMain.setString(5, paymentTerms);
        pstmtMain.setString(6, shippingMethod);
        pstmtMain.setString(7, notes_param);
        pstmtMain.setDouble(8, subtotal);
        pstmtMain.setDouble(9, taxPercentage);
        pstmtMain.setDouble(10, taxAmount);
        pstmtMain.setDouble(11, shippingFee);
        pstmtMain.setDouble(12, grandTotal);
        pstmtMain.setString(13, orderStatus);
        pstmtMain.setInt(14, createdByUserId);
        pstmtMain.setString(15, createdByUserFullName);
        pstmtMain.setString(16, supplierCompanyNameSnapshot); // *** NEW Parameter ***

        int affectedRows = pstmtMain.executeUpdate();
        if (affectedRows == 0) {
            throw new SQLException("Creating purchase order main record failed, no rows affected.");
        }

        generatedKeys = pstmtMain.getGeneratedKeys();
        int poMainId;
        if (generatedKeys.next()) {
            poMainId = generatedKeys.getInt(1);
        } else {
            throw new SQLException("Creating purchase order main record failed, no ID obtained.");
        }

        String sqlItems = "INSERT INTO swift_purchase_order_items (po_main_id, product_id, quantity_ordered, unit_price_at_order, row_total_at_order) VALUES (?, ?, ?, ?, ?)";
        pstmtItems = conn_post.prepareStatement(sqlItems);

        for (Map<String, Object> item : orderItems) {
            pstmtItems.setInt(1, poMainId);
            pstmtItems.setInt(2, (Integer) item.get("product_id"));
            pstmtItems.setInt(3, (Integer) item.get("quantity_ordered"));
            pstmtItems.setDouble(4, (Double) item.get("unit_price_at_order"));
            pstmtItems.setDouble(5, (Double) item.get("row_total_at_order"));
            pstmtItems.addBatch();
        }
        pstmtItems.executeBatch();

        conn_post.commit(); 
        String poSuccessMessage = "Purchase Order " + orderNumberDisplay + " created successfully! PO ID: " + poMainId;

        // --- Send Email to Supplier ---
        // For the email, it's fine to use the supplierCompanyNameSnapshot if supplierDetails.getCompanyName() is the same,
        // or fetch fresh if needed, though snapshot is what was saved.
        SupplierDAO supplierDAO = new SupplierDAO(); // This DAO call is outside the transaction for email sending
        Supplier supplierDetails = supplierDAO.getSupplierById(supplierId); 
        String supplierEmail = null;
        // Use the snapshot for supplier name in email for consistency with what was stored in the PO.
        String supplierNameForEmail = supplierCompanyNameSnapshot; 

        if (supplierDetails != null) { 
            supplierEmail = supplierDetails.getContactEmail(); 
            if (supplierEmail != null) {
                 supplierEmail = supplierEmail.trim();
            }
        }

        if (supplierEmail != null && !supplierEmail.isEmpty()) { 
            String emailSubject = "New Purchase Order: " + orderNumberDisplay + " from Swift POS Store";
            DecimalFormat df = new DecimalFormat("#,##0.00");
            StringBuilder emailBodyHtml = new StringBuilder();
            
            emailBodyHtml.append("<html><body style='font-family: Arial, sans-serif; margin: 0; padding: 20px; background-color: #f4f4f4; color: #333;'>");
            emailBodyHtml.append("<div style='max-width: 680px; margin: 0 auto; background-color: #ffffff; padding: 30px; border-radius: 8px; box-shadow: 0 4px 10px rgba(0,0,0,0.1);'>");
            emailBodyHtml.append("<div style='text-align: center; margin-bottom: 25px; border-bottom: 2px solid #0056b3; padding-bottom: 15px;'><h1 style='color: #0056b3; margin:0; font-size: 28px;'>Purchase Order</h1></div>");
            emailBodyHtml.append("<p style='font-size: 1.1em;'>Dear ").append(supplierNameForEmail).append(",</p>"); // Using snapshot name
            emailBodyHtml.append("<p>Please find below the details of a new purchase order from <strong>Swift POS Store</strong>.</p>");
            emailBodyHtml.append("<div style='margin: 20px 0; padding: 15px; background-color: #e9f5ff; border-left: 4px solid #007bff; border-radius: 4px;'>");
            emailBodyHtml.append("<h3 style='margin-top:0; color: #0056b3;'>PO Number: ").append(orderNumberDisplay).append("</h3>");
            emailBodyHtml.append("<strong>Order Date:</strong> ").append(orderDateForm).append("<br>");
            emailBodyHtml.append("<strong>Expected Delivery Date:</strong> ").append(expectedDeliveryDate != null && !expectedDeliveryDate.isEmpty() ? expectedDeliveryDate : "N/A").append("<br>");
            emailBodyHtml.append("<strong>Payment Terms:</strong> ").append(paymentTerms).append("<br>");
            emailBodyHtml.append("<strong>Shipping Method:</strong> ").append(shippingMethod != null && !shippingMethod.isEmpty() ? shippingMethod : "N/A").append("</p>"); // This was </p>, should be <br> or separate <p>
            emailBodyHtml.append("</div>");
            emailBodyHtml.append("<h3 style='color: #0056b3; border-bottom: 1px solid #eee; padding-bottom: 5px; margin-top: 30px;'>Order Items:</h3>");
            emailBodyHtml.append("<table border='1' cellpadding='5' cellspacing='0' style='border-collapse:collapse; width:100%; font-family: Arial, sans-serif;'>")
                           .append("<tr style='background-color:#f2f2f2;'><th>Product</th><th>Quantity</th><th>Unit Price</th><th>Total</th></tr>");

            for (Map<String, Object> item : orderItems) {
                Product product = productDAO_for_names.getProductById((Integer)item.get("product_id"));
                String productNameForEmail = (product != null) ? product.getName() : "Unknown Product (ID: " + item.get("product_id") + ")";
                emailBodyHtml.append("<tr><td>").append(productNameForEmail).append("</td>")
                                 .append("<td style='text-align:center;'>").append(item.get("quantity_ordered")).append("</td>")
                                 .append("<td style='text-align:right;'>Rs.").append(df.format(item.get("unit_price_at_order"))).append("</td>")
                                 .append("<td style='text-align:right;'>Rs.").append(df.format(item.get("row_total_at_order"))).append("</td></tr>");
            }
            emailBodyHtml.append("</table>");
            emailBodyHtml.append("<div style='margin-top: 25px; padding-top:15px; border-top: 1px solid #eee;'>");
            emailBodyHtml.append("<table style='width: 100%; text-align: right;'>");
            emailBodyHtml.append("<tr><td style='padding: 5px;'>Subtotal:</td><td style='padding: 5px; font-weight: bold;'>Rs.").append(df.format(subtotal)).append("</td></tr>");
            emailBodyHtml.append("<tr><td style='padding: 5px;'>Tax (").append(df.format(taxPercentage)).append("%):</td><td style='padding: 5px; font-weight: bold;'>Rs.").append(df.format(taxAmount)).append("</td></tr>");
            emailBodyHtml.append("<tr><td style='padding: 5px;'>Shipping Cost:</td><td style='padding: 5px; font-weight: bold;'>Rs.").append(df.format(shippingFee)).append("</td></tr>");
            emailBodyHtml.append("<tr style='font-size: 1.2em;'><td style='padding: 8px 5px; border-top: 2px solid #333;'><strong>Total Amount:</strong></td><td style='padding: 8px 5px; border-top: 2px solid #333;'><strong>Rs.").append(df.format(grandTotal)).append("</strong></td></tr>");
            emailBodyHtml.append("</table></div>");
            if (notes_param != null && !notes_param.trim().isEmpty()) {
                emailBodyHtml.append("<div style='margin-top: 25px;'><h4 style='color: #0056b3;'>Additional Notes:</h4><p style='padding: 10px; background-color: #f9f9f9; border-radius: 4px; white-space: pre-wrap;'>").append(notes_param.replace("\n", "<br>")).append("</p></div>");
            }
            emailBodyHtml.append("<p style='margin-top: 30px;'>Please confirm receipt of this purchase order and provide an estimated shipping date at your earliest convenience.</p>");
            emailBodyHtml.append("<p>Thank you,<br>The Team at Swift POS Store</p>");
            emailBodyHtml.append("<div style='text-align: center; margin-top: 30px; padding-top: 15px; border-top: 1px solid #ddd; font-size: 0.9em; color: #777;'><p>Swift POS Store | 123/2, High level Road, Homagama. | dulanga1000@gmail.com</p></div>");
            emailBodyHtml.append("</div></body></html>");

            boolean emailSent = EmailUtil.sendHtmlEmail(supplierEmail, emailSubject, emailBodyHtml.toString());
            if (emailSent) {
                poSuccessMessage += " Email sent to " + supplierNameForEmail + ".";
            } else {
                poSuccessMessage += " FAILED to send email to " + supplierNameForEmail + ". Please check server logs for email system errors.";
            }
        } else {
             if (supplierDetails == null && supplierId > 0) { 
                poSuccessMessage += " Supplier details not found for ID " + supplierId + " (for email). Email not sent.";
            } else if (supplierId > 0) { 
                poSuccessMessage += " Supplier '" + supplierNameForEmail + "' does not have an email address configured. Email not sent.";
            } else { 
                 poSuccessMessage += " Invalid supplier selected. Email not sent.";
            }
        }
        session.setAttribute("poMessage", poSuccessMessage);
        session.setAttribute("poMessageType", "success"); 

    } catch (Exception e) {
        if (conn_post != null) {
            try {
                conn_post.rollback();
            } catch (SQLException ex) {
                System.err.println("Rollback failed: " + ex.getMessage()); 
            }
        }
        session.setAttribute("poMessage", "Error creating Purchase Order: " + e.getMessage());
        session.setAttribute("poMessageType", "error");
        e.printStackTrace(); 

    } finally {
        if (generatedKeys != null) try { generatedKeys.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (pstmtItems != null) try { pstmtItems.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (pstmtMain != null) try { pstmtMain.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn_post != null) {
            try {
                conn_post.setAutoCommit(true); 
                conn_post.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
        response.sendRedirect(request.getRequestURI()); 
    }
    return; 
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Create Purchase Order - Swift POS</title>
  <script src="${pageContext.request.contextPath}/Admin/script.js"></script>
  <link rel="Stylesheet" href="${pageContext.request.contextPath}/Admin/styles.css">
  <style>
    :root {
      --primary: #4f46e5;   /* Indigo 600 */
      --primary-light: #6366f1; /* Indigo 500 */
      --secondary: #475569;    /* Slate 600 */
      --dark: #1e293b;          /* Slate 800 */
      --light: #f8fafc;         /* Slate 50 */
      --danger: #ef4444;        /* Red 500 */
      --success: #10b981;       /* Emerald 500 */
      --warning: #f59e0b;       /* Amber 500 */
    }
    .po-form-container {
      background-color: white;
      border-radius: 8px;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
      padding: 20px;
      margin-bottom: 20px;
    }
    .form-row {
      display: flex;
      flex-wrap: wrap;
      margin: 0 -10px;
      margin-bottom: 15px;
    }
    .form-group {
      flex: 1;
      min-width: 200px;
      padding: 0 10px;
      margin-bottom: 15px;
    }
    .form-group label {
      display: block;
      margin-bottom: 8px;
      font-weight: 500;
      font-size: 14px;
      color: var(--dark);
    }
    .form-group input,
    .form-group select,
    .form-group textarea {
      width: 100%;
      padding: 10px 12px;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      font-size: 14px;
      background-color: #f8fafc;
      box-sizing: border-box;
    }
    .form-group textarea {
      min-height: 100px;
      resize: vertical;
    }
    .form-group.full-width {
      width: 100%;
      flex-basis: 100%;
    }
    .products-table {
      margin-top: 20px;
      width: 100%;
      border-collapse: collapse;
    }
    .products-table th {
      background-color: #f1f5f9;
      padding: 12px 15px;
      text-align: left;
      font-weight: 500;
      font-size: 14px;
      color: var(--dark);
    }
    .products-table td {
      padding: 12px 15px;
      border-bottom: 1px solid #f1f5f9;
    }
    .products-table tr:last-child td {
      border-bottom: none;
    }
    .product-select {
      width: 100%;
      padding: 8px 10px;
      border: 1px solid #e2e8f0;
      border-radius: 4px;
      background-color: #f8fafc;
    }
    .quantity-input {
      width: 60px;
      padding: 8px 10px;
      border: 1px solid #e2e8f0;
      border-radius: 4px;
      text-align: center;
      background-color: #f8fafc;
      -moz-appearance: textfield; /* Firefox */
    }
    .quantity-input::-webkit-outer-spin-button,
    .quantity-input::-webkit-inner-spin-button {
      -webkit-appearance: none;
      margin: 0;
    }
    .quantity-control {
      display: flex;
      align-items: center;
      justify-content: space-between;
      max-width: 130px;
    }
    .quantity-btn {
      width: 30px;
      height: 30px;
      display: flex;
      align-items: center;
      justify-content: center;
      background-color: var(--primary-light);
      color: white;
      border: none;
      border-radius: 4px;
      font-size: 16px;
      cursor: pointer;
      transition: background-color 0.2s;
    }
    .quantity-btn:hover {
      background-color: var(--primary);
    }
    .unit-price { 
      font-weight: 500;
      color: var(--dark);
    }
    .row-total {
      font-weight: 500;
      color: var(--primary);
    }
    .add-row-btn {
      display: block;
      width: 100%;
      background-color: #e0e7ff;
      border: 1px dashed #a5b4fc;
      color: var(--primary);
      padding: 10px;
      margin-top: 10px;
      border-radius: 6px;
      cursor: pointer;
      font-size: 14px;
      text-align: center;
      transition: background-color 0.2s;
    }
    .add-row-btn:hover {
      background-color: #c7d2fe;
    }
    .summary-box {
      background-color: #f1f5f9;
      border-radius: 8px;
      padding: 20px;
      margin-top: 20px;
      border: 1px solid #e2e8f0;
    }
    .summary-row {
      display: flex;
      justify-content: space-between;
      padding: 8px 0;
      border-bottom: 1px solid #e2e8f0;
      color: var(--dark);
    }
    .summary-row:last-child {
      border-bottom: none;
      padding-top: 15px;
      font-weight: 600;
      font-size: 18px;
      color: var(--primary);
    }
    .action-buttons {
      display: flex;
      justify-content: flex-end;
      margin-top: 30px;
      gap: 15px;
    }
    .action-btn {
      padding: 12px 24px;
      border-radius: 6px;
      font-weight: 500;
      cursor: pointer;
      border: none;
      font-size: 14px;
      transition: background-color 0.2s;
    }
    .btn-secondary {
      background-color: #e2e8f0;
      color: var(--dark);
    }
    .btn-secondary:hover {
      background-color: #cbd5e1;
    }
    .btn-primary {
      background-color: var(--primary);
      color: white;
    }
    .btn-primary:hover {
      background-color: #4338ca;
    }
    .remove-row {
      background: none;
      border: none;
      color: var(--danger);
      cursor: pointer;
      font-size: 18px;
      transition: transform 0.2s;
    }
    .remove-row:hover {
      transform: scale(1.1);
    }
    .message-container {
        padding: 10px;
        margin-bottom: 15px;
        border-radius: 5px;
        font-size: 14px;
        text-align: center;
    }
    .message-success {
        background-color: #d4edda;
        color: #155724;
        border: 1px solid #c3e6cb;
    }
    .message-error {
        background-color: #f8d7da;
        color: #721c24;
        border: 1px solid #f5c6cb;
    }
    @media (max-width: 768px) {
      .form-group {
        flex: 0 0 100%;
      }
      .action-buttons {
        flex-direction: column;
      }
      .action-btn {
        width: 100%;
      }
    }
  </style>
</head>
<body>
  <div class="mobile-top-bar">
    <div class="mobile-logo">
      <img src="${pageContext.request.contextPath}/Images/logo.png" alt="POS Logo">
      <h2>Swift</h2>
    </div>
    <button class="mobile-nav-toggle" id="mobileNavToggle">&#9776;</button>
  </div>
  
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
        <h1 class="page-title">Create Purchase Order</h1>
        <div class="user-profile">
          <img src="${pageContext.request.contextPath}/Images/logo.png" alt="Admin Profile"> 
          <div>
            <%
                User loggedInUser = (User) session.getAttribute("loggedInUser");
                String userDisplayName = "Admin User"; // Default
                if (loggedInUser != null) {
                    userDisplayName = loggedInUser.getFirstName() + " " + loggedInUser.getLastName();
                }
            %>
            <h4><%= userDisplayName %></h4>
          </div>
        </div>
      </div>

      <%
            String message = (String) session.getAttribute("poMessage");
            String messageType = (String) session.getAttribute("poMessageType");
            if (message != null) {
        %>
            <div class="message-container <%= "success".equals(messageType) ? "message-success" : "error".equals(messageType) ? "message-error" : "" %>">
                <%= message %>
            </div>
        <%
                session.removeAttribute("poMessage");
                session.removeAttribute("poMessageType");
            }
        %>
      
      <div class="po-form-container">
        <form method="post" action="<%= request.getRequestURI() %>" id="purchaseOrderForm">
          <div class="form-row">
            <div class="form-group">
              <label for="order_id">Purchase Order #</label>
              <input type="text" id="order_id" name="order_id" value="PO-<%= new java.util.Random().nextInt(900000) + 100000 %>" readonly>
            </div>
            <div class="form-group">
              <label for="order_date">Order Date</label>
              <input type="date" id="order_date" name="order_date" value="<%= LocalDate.now() %>" required>
            </div>
            <div class="form-group">
              <label for="expected_date">Expected Delivery Date</label>
              <input type="date" id="expected_date" name="expected_date" value="<%= LocalDate.now().plusDays(7) %>" required>
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label for="supplier_id">Select Supplier</label>
              <select id="supplier_id" name="supplier_id" required>
                <option value="">-- Select Supplier --</option>
                <%
                    String URL_JSP_LOAD = "jdbc:mysql://localhost:3306/swift_database"; 
                    String USER_JSP_LOAD = "root";
                    String PASSWORD_JSP_LOAD = ""; 

                    Connection conn_jsp_supplier = null;
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn_jsp_supplier = DriverManager.getConnection(URL_JSP_LOAD, USER_JSP_LOAD, PASSWORD_JSP_LOAD);
                        PreparedStatement sql_jsp_supplier = conn_jsp_supplier.prepareStatement("SELECT supplier_id, company_name FROM suppliers WHERE supplier_status = 'Active' ORDER BY company_name");
                        ResultSet result_jsp_supplier = sql_jsp_supplier.executeQuery();

                        while (result_jsp_supplier.next()) { %>
                          <option value="<%= result_jsp_supplier.getString("supplier_id") %>"><%= result_jsp_supplier.getString("company_name") %></option>
                        <% }
                        result_jsp_supplier.close();
                        sql_jsp_supplier.close();
                    } catch (Exception ex) {
                        out.println("<option value=''>Error loading suppliers: " + ex.getMessage() + "</option>");
                        ex.printStackTrace();
                    } finally {
                        if (conn_jsp_supplier != null) {
                            try { conn_jsp_supplier.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    }
                %>
              </select>
            </div>
            <div class="form-group">
              <label for="payment_terms">Payment Terms</label>
              <select id="payment_terms" name="payment_terms" required>
                <option value="Net 30">Net 30</option>
                <option value="Net 15">Net 15</option>
                <option value="Net 7">Net 7</option>
                <option value="Due on Receipt">Due on Receipt</option>
                <option value="Cash on Delivery">Cash on Delivery</option>
              </select>
            </div>
            <div class="form-group">
              <label for="shipping_method">Shipping Method</label>
              <select id="shipping_method" name="shipping_method" required>
                <option value="Standard Delivery">Standard Delivery</option>
                <option value="Express Delivery">Express Delivery</option>
                <option value="Pickup">Pickup from Supplier</option>
              </select>
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label for="tax_percentage">Tax Percentage (%)</label>
              <input type="number" id="tax_percentage" name="tax_percentage" min="0" max="100" step="0.01" value="15.00" required oninput="updateOrderSummary()">
            </div>
            <div class="form-group">
              <label for="shipping_cost">Shipping Cost (Rs.)</label>
              <input type="number" id="shipping_cost" name="shipping_cost" min="0" step="0.01" value="0.00" required oninput="updateOrderSummary()">
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group full-width">
              <label for="notes">Order Notes</label>
              <textarea id="notes" name="notes" placeholder="Enter any special instructions or notes for this order..."></textarea>
            </div>
          </div>
          
          <h3 style="margin-top: 30px; margin-bottom: 15px; font-size: 16px; color: var(--primary);">Order Items</h3>
          <table class="products-table">
            <thead>
              <tr>
                <th style="width: 40%;">Product</th>
                <th style="width: 15%;">Quantity</th>
                <th style="width: 20%;">Unit Price</th> 
                <th style="width: 20%;">Total</th>
                <th style="width: 5%;"></th>
              </tr>
            </thead>
            <tbody id="product-rows">
              <tr class="product-row">
                <td>
                  <select name="product_id[]" class="product-select" required onchange="updateProductInfo(this)">
                    <option value="">-- Select Product --</option>
                    <%
                        Connection conn_products = null;
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            conn_products = DriverManager.getConnection(URL_JSP_LOAD, USER_JSP_LOAD, PASSWORD_JSP_LOAD);
                            // Fetch product's cost_price if available and non-zero, otherwise use price (selling_price)
                            // For a PO, you'd typically use cost_price from supplier, but current product table has 'price' (selling) and 'cost_price'
                            // The JS logic uses 'data-price' which is populated by product.price (selling price)
                            // For a true PO, this 'price' should ideally be the 'cost_price' for the business.
                            // The JS function updateProductInfo takes data-price. If you want to use cost_price, 
                            // ensure data-price is populated with cost_price or modify JS.
                            // Current setup uses product.price (selling price) as the base for PO item unit price.
                            PreparedStatement sql_products = conn_products.prepareStatement(
                                "SELECT id, name, price, cost_price FROM products WHERE status = 'Active' ORDER BY name"
                            );
                            ResultSet result_products = sql_products.executeQuery();

                            while (result_products.next()) {  
                                double product_display_price = result_products.getDouble("price"); // Default to selling price
                                // Potentially, you might want to use cost_price for POs if it's maintained and accurate
                                // double costPrice = result_products.getDouble("cost_price");
                                // if (costPrice > 0) { product_display_price = costPrice; } 
                            %>
                              <option value="<%= result_products.getString("id") %>" data-price="<%= product_display_price %>">
                                <%= result_products.getString("name") %> - Price Rs.<%= String.format("%.2f", product_display_price) %>
                              </option>
                            <% }
                                result_products.close();
                                sql_products.close();
                        } catch (Exception ex) {
                            out.println("<option value=''>Error loading products: " + ex.getMessage() + "</option>");
                            ex.printStackTrace();
                        } finally {
                            if (conn_products != null) {
                                try { conn_products.close(); } catch (SQLException e) { e.printStackTrace(); }
                            }
                        }
                    %>
                  </select>
                  <input type="hidden" name="unit_price_at_order_hidden[]" class="unit-price-hidden" value="0">
                </td>
                <td>
                  <div class="quantity-control">
                    <button type="button" class="quantity-btn decrease-btn" onclick="decreaseQuantity(this)">-</button>
                    <input type="number" name="quantity[]" class="quantity-input" value="1" min="1" required oninput="updateRowTotal(this)" onchange="updateRowTotal(this)">
                    <button type="button" class="quantity-btn increase-btn" onclick="increaseQuantity(this)">+</button>
                  </div>
                </td>
                <td class="unit-price">Rs.0.00</td> 
                <td class="row-total">Rs.0.00</td>
                <td>
                  <button type="button" class="remove-row" onclick="removeProductRow(this)">&#10060;</button>
                </td>
              </tr>
            </tbody>
          </table>
          
          <button type="button" class="add-row-btn" onclick="addProductRow()">+ Add Another Product</button>
          
          <div class="summary-box">
            <div class="summary-row">
              <span>Subtotal:</span>
              <span id="subtotal">Rs.0.00</span>
            </div>
            <div class="summary-row">
              <span>Tax:</span>
              <span id="tax">Rs.0.00</span>
            </div>
            <div class="summary-row">
              <span>Shipping:</span>
              <span id="shipping">Rs.0.00</span>
            </div>
            <div class="summary-row">
              <span>Total:</span>
              <span id="total">Rs.0.00</span>
            </div>
          </div>
          
          <div class="action-buttons">
            <button type="button" class="action-btn btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/Admin/purchases.jsp'">Cancel</button>
            <button type="button" class="action-btn btn-primary" id="createPoButton">Create Purchase Order</button>
          </div>
        </form>
      </div>
      
      <div class="footer">
        Swift &copy; <%= java.time.Year.now().getValue() %>.
      </div>
    </div>
  </div>
  
  <script>
    function updateProductInfo(selectElement) { 
      const row = selectElement.closest('tr');
      const selectedOption = selectElement.options[selectElement.selectedIndex];
      const hiddenUnitPriceInput = row.querySelector('.unit-price-hidden');
      
      if (!selectedOption || !selectedOption.value) { 
        row.querySelector('.unit-price').textContent = 'Rs.0.00';
        if(hiddenUnitPriceInput) hiddenUnitPriceInput.value = '0';
        row.querySelector('.quantity-input').value = 1; 
        updateRowTotal(row.querySelector('.quantity-input')); 
        return;
      }
      const price = parseFloat(selectedOption.getAttribute('data-price')) || 0; 
      
      const unitPriceCell = row.querySelector('.unit-price');
      unitPriceCell.textContent = 'Rs.' + price.toFixed(2);
      if(hiddenUnitPriceInput) hiddenUnitPriceInput.value = price.toFixed(2);
      
      updateRowTotal(selectElement); 
    }

    function updateRowTotal(elementInRow) {
      const row = elementInRow.closest('tr');
      const productSelect = row.querySelector('.product-select');
      const quantityInput = row.querySelector('.quantity-input'); 
      const hiddenUnitPriceInput = row.querySelector('.unit-price-hidden');

      if (!productSelect || !productSelect.value) {
        row.querySelector('.unit-price').textContent = 'Rs.0.00';
        if(hiddenUnitPriceInput) hiddenUnitPriceInput.value = '0';
        row.querySelector('.row-total').textContent = 'Rs.0.00';
        updateOrderSummary();
        return;
      }

      const unitPrice = parseFloat(hiddenUnitPriceInput.value) || 0; 
      
      let quantity = parseInt(quantityInput.value);

      if (isNaN(quantity) || quantity < 1) {
        quantity = 1;
        quantityInput.value = 1; 
      }
      
      const rowTotal = unitPrice * quantity;
      row.querySelector('.row-total').textContent = 'Rs.' + rowTotal.toFixed(2);
      
      updateOrderSummary();
    }
    
    function increaseQuantity(button) {
      const input = button.previousElementSibling;
      const productSelect = input.closest('tr').querySelector('.product-select');
      if (!productSelect || !productSelect.value) return; 

      input.value = parseInt(input.value) + 1;
      updateRowTotal(input);
    }
    
    function decreaseQuantity(button) {
      const input = button.nextElementSibling;
      const productSelect = input.closest('tr').querySelector('.product-select');
      if (!productSelect || !productSelect.value) return;

      const currentValue = parseInt(input.value);
      if (currentValue > 1) {
        input.value = currentValue - 1;
        updateRowTotal(input);
      }
    }
    
    function addProductRow() {
        const productRowsTbody = document.getElementById('product-rows');
        const firstRow = productRowsTbody.querySelector('.product-row');
        if (!firstRow) {
            console.error("Could not find the first product row to clone.");
            return;
        }
        const newRow = firstRow.cloneNode(true);
        
        newRow.querySelector('.product-select').selectedIndex = 0;
        newRow.querySelector('.quantity-input').value = 1;
        newRow.querySelector('.unit-price').textContent = 'Rs.0.00';
        newRow.querySelector('.row-total').textContent = 'Rs.0.00';
        const hiddenUnitPriceInNewRow = newRow.querySelector('.unit-price-hidden');
        if(hiddenUnitPriceInNewRow) hiddenUnitPriceInNewRow.value = '0';
        
        // Re-attach event listeners for new row elements
        newRow.querySelector('.quantity-input').oninput = function() { updateRowTotal(this); };
        newRow.querySelector('.quantity-input').onchange = function() { updateRowTotal(this); };
        newRow.querySelector('.product-select').onchange = function() { updateProductInfo(this); };
        newRow.querySelector('.decrease-btn').onclick = function() { decreaseQuantity(this); };
        newRow.querySelector('.increase-btn').onclick = function() { increaseQuantity(this); };
        newRow.querySelector('.remove-row').onclick = function() { removeProductRow(this); };

        productRowsTbody.appendChild(newRow);
        updateOrderSummary(); 
    }
    
    function removeProductRow(button) {
      const row = button.closest('tr');
      const productRowsTbody = document.getElementById('product-rows');
      
      if (productRowsTbody.children.length > 1) {
        row.remove();
        updateOrderSummary();
      } else {
        // If it's the last row, clear its values instead of removing it
        const productSelect = row.querySelector('.product-select');
        productSelect.selectedIndex = 0; // Reset to "-- Select Product --"
        updateProductInfo(productSelect); // This will reset price, quantity, and totals
        alert("You must have at least one product in the order. The current item has been cleared.");
      }
    }

    function updateOrderSummary() {
        let subtotal = 0;
        let hasValidItem = false; // Flag to check if at least one valid item exists
        document.querySelectorAll('#product-rows .product-row').forEach(function(row) {
            const productSelect = row.querySelector('.product-select');
            if (productSelect && productSelect.value) { // Check if a product is selected
                const quantityInput = row.querySelector('.quantity-input');
                 // Ensure quantity is a positive number
                if (quantityInput && quantityInput.value && parseInt(quantityInput.value) > 0) {
                    const rowTotalText = row.querySelector('.row-total').textContent;
                    subtotal += parseFloat(rowTotalText.replace('Rs.', '')) || 0;
                    hasValidItem = true; // A valid item is found
                }
            }
        });
        document.getElementById('subtotal').textContent = 'Rs.' + subtotal.toFixed(2);

        const taxPercentageInput = document.getElementById('tax_percentage');
        const shippingCostInput = document.getElementById('shipping_cost');

        // Ensure inputs exist before trying to get their values
        const taxPercentage = parseFloat(taxPercentageInput ? taxPercentageInput.value : 0) || 0;
        const shippingCost = parseFloat(shippingCostInput ? shippingCostInput.value : 0) || 0;
        
        const taxAmount = (subtotal * taxPercentage) / 100;
        document.getElementById('tax').textContent = 'Rs.' + taxAmount.toFixed(2) + ' (' + taxPercentage.toFixed(2) + '%)';
        
        document.getElementById('shipping').textContent = 'Rs.' + shippingCost.toFixed(2);
        
        const total = subtotal + taxAmount + shippingCost;
        document.getElementById('total').textContent = 'Rs.' + total.toFixed(2);

        // Enable/disable Create PO button based on whether there's a valid item
        const createPoButton = document.getElementById('createPoButton');
        if (createPoButton) {
            createPoButton.disabled = !hasValidItem;
        }
    }

    document.addEventListener('DOMContentLoaded', function() {
        const taxInput = document.getElementById('tax_percentage');
        const shippingInput = document.getElementById('shipping_cost');
        if(taxInput) taxInput.addEventListener('input', updateOrderSummary);
        if(shippingInput) shippingInput.addEventListener('input', updateOrderSummary);

        // Initialize first row and attach event listeners
        document.querySelectorAll('.product-row').forEach(row => {
            const productSelect = row.querySelector('.product-select');
            const quantityInput = row.querySelector('.quantity-input');

            if (productSelect) {
                productSelect.addEventListener('change', function() { updateProductInfo(this); });
                // If a product is already selected (e.g. due to form repopulation after error), update its info
                if (productSelect.value) { 
                    updateProductInfo(productSelect);
                } else { // Ensure totals are calculated even if no product is initially selected
                    updateRowTotal(quantityInput || productSelect); // Pass an element from the row
                }
            }
            if (quantityInput) {
                quantityInput.addEventListener('input', function() { updateRowTotal(this); });
                quantityInput.addEventListener('change', function() { updateRowTotal(this); });
            }
            // Attach listeners for quantity and remove buttons for the initial row
            const decreaseBtn = row.querySelector('.decrease-btn');
            const increaseBtn = row.querySelector('.increase-btn');
            const removeBtn = row.querySelector('.remove-row');
            if(decreaseBtn) decreaseBtn.onclick = function() { decreaseQuantity(this); };
            if(increaseBtn) increaseBtn.onclick = function() { increaseQuantity(this); };
            if(removeBtn) removeBtn.onclick = function() { removeProductRow(this); };
        });
        
        updateOrderSummary(); // Initial calculation
        
        // Date validations
        var today = new Date().toISOString().split('T')[0];
        document.getElementById("order_date").setAttribute('min', today);
        document.getElementById("expected_date").setAttribute('min', today);

        document.getElementById("order_date").addEventListener("change", function() {
            var orderDate = this.value;
            document.getElementById("expected_date").setAttribute('min', orderDate);
            // If expected date is currently before new order date, update expected date
            if (document.getElementById("expected_date").value < orderDate) {
                document.getElementById("expected_date").value = orderDate;
            }
        });

        // Form submission validation
        const createPoBtn = document.getElementById('createPoButton');
        const poForm = document.getElementById('purchaseOrderForm');

        if (createPoBtn && poForm) {
            createPoBtn.addEventListener('click', function(event) {
                event.preventDefault(); // Prevent default form submission

                // Check if at least one valid product item exists
                let hasAtLeastOneValidItem = false;
                document.querySelectorAll('#product-rows .product-row').forEach(function(row) {
                    const productSelect = row.querySelector('.product-select');
                    const quantityInput = row.querySelector('.quantity-input');
                    if (productSelect && productSelect.value && quantityInput && quantityInput.value && parseInt(quantityInput.value) > 0) {
                        hasAtLeastOneValidItem = true;
                    }
                });

                if (!hasAtLeastOneValidItem) {
                    alert('Please add at least one product with a valid quantity to the purchase order.');
                    return;
                }

                // Check other required fields
                const supplierSelect = document.getElementById('supplier_id');
                if (!supplierSelect || !supplierSelect.value) {
                    alert('Please select a supplier.');
                    return;
                }
                
                const orderDate = document.getElementById('order_date').value;
                const expectedDate = document.getElementById('expected_date').value;
                const paymentTerms = document.getElementById('payment_terms').value;
                const shippingMethod = document.getElementById('shipping_method').value;
                const taxPercentage = document.getElementById('tax_percentage').value;
                const shippingCost = document.getElementById('shipping_cost').value;

                if (!orderDate || !expectedDate || !paymentTerms || !shippingMethod || taxPercentage === '' || shippingCost === '') {
                    alert('Please fill in all required order details (dates, payment terms, shipping, tax, shipping cost).');
                    return;
                }

                // Confirmation before submission
                if (confirm("Are you sure you want to create this purchase order?")) {
                    poForm.submit(); // Proceed with form submission
                }
            });
        }
    });
  </script>
</body>
</html>