<%--
    Document   : create_purchase_order
    Created on : May 16, 2025, 9:30:15 AM
    Author     : dulan
    Modified to include DB insertion logic directly in JSP.
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.math.BigDecimal" %>

<%!
    // Database connection details (Consider moving to a configuration or context parameters for better practice)
    // Make sure these are correct for your environment
    String DB_URL = "jdbc:mysql://localhost:3306/Swift_Database"; // Ensure 'Swift_Database' is correct
    String DB_USER = "root";
    String DB_PASSWORD = ""; // Your ACTUAL DB password
%>

<%
    Connection conn = null;
    PreparedStatement pstmtMain = null;
    PreparedStatement pstmtItem = null;
    ResultSet generatedKeys = null;

    // --- FORM SUBMISSION PROCESSING ---
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        boolean success = false;
        String poMessage = "An error occurred while processing the purchase order."; // Default error
        String poMessageType = "error";

        // IMPORTANT: You need a model.User object in the session.
        // Ensure 'model.User' is the correct class and it's properly stored in session.
        // This assumes your login process sets this attribute.
        model.User loggedInUserSubmit = (model.User) session.getAttribute("loggedInUser");
        int currentUserIdSubmit = -1; // Default to an invalid ID
        String currentUserFullNameSubmit = "System/Unknown";

        if (loggedInUserSubmit == null) {
            poMessage = "ERROR: You must be logged in to create a purchase order. No user found in session.";
            poMessageType = "error";
            // No DB operations, just set message and redirect
            session.setAttribute("poMessage", poMessage);
            session.setAttribute("poMessageType", poMessageType);
            response.sendRedirect(request.getRequestURI()); // Redirect to clear POST
            return; // Stop further processing
        } else {
            try {
                 // CRITICAL: Ensure these methods exist on your model.User class and return correct types.
                 // getId() should return an int that is a valid ID in your 'users' table.
                 currentUserIdSubmit = loggedInUserSubmit.getId();
                 currentUserFullNameSubmit = loggedInUserSubmit.getFirstName() + " " + loggedInUserSubmit.getLastName();
                 if (currentUserFullNameSubmit == null || currentUserFullNameSubmit.trim().isEmpty()){
                     currentUserFullNameSubmit = "User " + currentUserIdSubmit; // Fallback if name is empty
                 }
            } catch (Exception e) {
                // This catch block means there's a problem with your model.User class or session attribute
                poMessage = "ERROR: Could not retrieve essential user details (ID/Name) from session. Please contact support. Details: " + e.getMessage();
                poMessageType = "error";
                e.printStackTrace(); // Log the actual error to server console
                // currentUserIdSubmit remains -1, which will likely cause an FK violation if 'users' table doesn't have ID -1
                // Forcing a redirect here as well because without a valid user ID, insert will fail.
                session.setAttribute("poMessage", poMessage);
                session.setAttribute("poMessageType", poMessageType);
                response.sendRedirect(request.getRequestURI());
                return; // Stop further processing
            }
        }


        // --- DEBUG: Print received parameters (Remove or comment out in production) ---
        System.out.println("--- JSP Purchase Order: POST Data Received ---");
        Enumeration<String> paramNamesDebug = request.getParameterNames();
        while(paramNamesDebug.hasMoreElements()){
            String paramName = paramNamesDebug.nextElement();
            System.out.print("Param: " + paramName + " = ");
            String[] paramValues = request.getParameterValues(paramName);
            for(int i=0; i < paramValues.length; i++){
                System.out.print(paramValues[i] + (i < paramValues.length -1 ? ", " : ""));
            }
            System.out.println();
        }
        System.out.println("Attempting to use User ID: " + currentUserIdSubmit + " (" + currentUserFullNameSubmit + ")");
        // --- END DEBUG ---


        try {
            Class.forName("com.mysql.cj.jdbc.Driver"); // Ensure MySQL driver is in your classpath
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            conn.setAutoCommit(false); // Start transaction

            // 1. Retrieve and Prepare Main Order Data
            String orderNumberDisplay = request.getParameter("order_id");
            String supplierIdStr = request.getParameter("supplier_id");
            String orderDateStr = request.getParameter("order_date");
            String expectedDateStr = request.getParameter("expected_date");
            String paymentTerms = request.getParameter("payment_terms");
            String shippingMethod = request.getParameter("shipping_method");
            String notes = request.getParameter("notes");
            String subtotalStr = request.getParameter("subtotal_hidden");
            String taxPercentageStr = request.getParameter("tax_percentage");
            String taxAmountStr = request.getParameter("tax_amount_hidden");
            String shippingCostStr = request.getParameter("shipping_cost");
            String grandTotalStr = request.getParameter("grand_total_hidden");
            String orderStatus = "Pending"; // Default status

            // Validate and parse required fields
            if (orderNumberDisplay == null || supplierIdStr == null || orderDateStr == null || expectedDateStr == null ||
                subtotalStr == null || taxPercentageStr == null || taxAmountStr == null || shippingCostStr == null || grandTotalStr == null) {
                throw new NullPointerException("One or more required form fields for main order are missing.");
            }
            if (supplierIdStr.isEmpty() || orderDateStr.isEmpty() || expectedDateStr.isEmpty()){
                 throw new IllegalArgumentException("Supplier, Order Date, or Expected Date cannot be empty.");
            }


            int supplierId = Integer.parseInt(supplierIdStr);
            java.sql.Date orderDateForm = java.sql.Date.valueOf(LocalDate.parse(orderDateStr));
            java.sql.Date expectedDeliveryDate = java.sql.Date.valueOf(LocalDate.parse(expectedDateStr));

            BigDecimal subtotal = new BigDecimal(subtotalStr);
            BigDecimal taxPercentage = new BigDecimal(taxPercentageStr);
            BigDecimal taxAmount = new BigDecimal(taxAmountStr);
            BigDecimal shippingFee = new BigDecimal(shippingCostStr);
            BigDecimal grandTotal = new BigDecimal(grandTotalStr);


            // Insert into swift_purchase_orders_main
            // Make sure column names match your swift_purchase_orders_main table exactly
            String sqlMain = "INSERT INTO swift_purchase_orders_main " +
                             "(order_number_display, supplier_id, order_date_form, expected_delivery_date, payment_terms, shipping_method, notes, subtotal, tax_percentage, tax_amount, shipping_fee, grand_total, order_status, created_by_user_id, created_by_user_full_name) " +
                             "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
            pstmtMain = conn.prepareStatement(sqlMain, Statement.RETURN_GENERATED_KEYS);
            pstmtMain.setString(1, orderNumberDisplay);
            pstmtMain.setInt(2, supplierId);
            pstmtMain.setDate(3, orderDateForm);
            pstmtMain.setDate(4, expectedDeliveryDate);
            pstmtMain.setString(5, paymentTerms);
            pstmtMain.setString(6, shippingMethod);
            pstmtMain.setString(7, notes);
            pstmtMain.setBigDecimal(8, subtotal);
            pstmtMain.setBigDecimal(9, taxPercentage);
            pstmtMain.setBigDecimal(10, taxAmount);
            pstmtMain.setBigDecimal(11, shippingFee);
            pstmtMain.setBigDecimal(12, grandTotal);
            pstmtMain.setString(13, orderStatus);
            pstmtMain.setInt(14, currentUserIdSubmit); // FK constraint here, users.id must have this value
            pstmtMain.setString(15, currentUserFullNameSubmit);

            System.out.println("Executing Main Order Insert for PO: " + orderNumberDisplay + " by User ID: " + currentUserIdSubmit);
            int rowsAffectedMain = pstmtMain.executeUpdate();
            int poMainId = -1;

            if (rowsAffectedMain > 0) {
                generatedKeys = pstmtMain.getGeneratedKeys();
                if (generatedKeys.next()) {
                    poMainId = generatedKeys.getInt(1);
                    System.out.println("Main Order Inserted. Generated po_main_id: " + poMainId);
                }
            }

            if (poMainId == -1) {
                conn.rollback(); // Rollback if main insert failed or no ID obtained
                throw new SQLException("Failed to create main purchase order record, or no generated ID obtained.");
            }

            // 2. Retrieve and Prepare Order Item Data
            // Note: HTML name is "product_id", "quantity" etc. (singular) for each row.
            // getParameterValues will collect all inputs with the same name.
            String[] productIdsStrArr = request.getParameterValues("product_id");
            String[] quantitiesStrArr = request.getParameterValues("quantity");
            String[] unitPricesStrArr = request.getParameterValues("unit_price_item");
            String[] itemTotalsStrArr = request.getParameterValues("row_total_item");

            if (productIdsStrArr != null && productIdsStrArr.length > 0) {
                System.out.println("Processing " + productIdsStrArr.length + " order items.");
                // Make sure column names match your swift_purchase_order_items table exactly
                String sqlItem = "INSERT INTO swift_purchase_order_items " +
                                 "(po_main_id, product_id, quantity_ordered, unit_price_at_order, row_total_at_order) " +
                                 "VALUES (?, ?, ?, ?, ?)";
                pstmtItem = conn.prepareStatement(sqlItem);

                for (int i = 0; i < productIdsStrArr.length; i++) {
                    // Basic validation for item data
                    if (productIdsStrArr[i] == null || productIdsStrArr[i].isEmpty() ||
                        quantitiesStrArr[i] == null || quantitiesStrArr[i].isEmpty() ||
                        unitPricesStrArr[i] == null || unitPricesStrArr[i].isEmpty() ||
                        itemTotalsStrArr[i] == null || itemTotalsStrArr[i].isEmpty()) {
                        System.out.println("Skipping empty or incomplete item at index " + i);
                        continue; // Skip incomplete item rows
                    }

                    int productId = Integer.parseInt(productIdsStrArr[i]);
                    int quantityOrdered = Integer.parseInt(quantitiesStrArr[i]);
                    BigDecimal unitPriceAtOrder = new BigDecimal(unitPricesStrArr[i]);
                    BigDecimal rowTotalAtOrder = new BigDecimal(itemTotalsStrArr[i]);

                    pstmtItem.setInt(1, poMainId);
                    pstmtItem.setInt(2, productId); // FK constraint here, products.id must have this value
                    pstmtItem.setInt(3, quantityOrdered);
                    pstmtItem.setBigDecimal(4, unitPriceAtOrder);
                    pstmtItem.setBigDecimal(5, rowTotalAtOrder);
                    pstmtItem.addBatch();
                    System.out.println("Adding to batch: Item Product ID " + productId + ", Qty " + quantityOrdered);
                }
                int[] itemRowsAffected = pstmtItem.executeBatch();
                System.out.println("Item batch executed. Rows affected per statement: " + Arrays.toString(itemRowsAffected));
                // Check itemRowsAffected if needed, e.g., ensure all are >= 0 or Statement.SUCCESS_NO_INFO
            } else {
                System.out.println("No product items submitted or productIdsStrArr is null/empty.");
                // Decide if an order with no items is valid. If not, throw an exception or rollback.
                // For now, allows order with no items if swift_purchase_order_items can be empty.
            }

            conn.commit(); // Commit transaction
            success = true;
            poMessage = "Purchase Order (" + orderNumberDisplay + ") created successfully with ID " + poMainId + "!";
            poMessageType = "success";
            System.out.println("Transaction committed successfully for PO: " + orderNumberDisplay);

        } catch (NumberFormatException nfe) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            poMessage = "ERROR: Invalid number format in one of the fields. " + nfe.getMessage();
            poMessageType = "error";
            System.err.println("NumberFormatException: " + nfe.getMessage());
            nfe.printStackTrace();
        } catch (NullPointerException npe) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            poMessage = "ERROR: A required field was missing or null. " + npe.getMessage();
            poMessageType = "error";
            System.err.println("NullPointerException: " + npe.getMessage());
            npe.printStackTrace();
        } catch (IllegalArgumentException iae) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            poMessage = "ERROR: Invalid data provided for a field. " + iae.getMessage();
            poMessageType = "error";
            System.err.println("IllegalArgumentException: " + iae.getMessage());
            iae.printStackTrace();
        }
        catch (SQLException sqle) {
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); } // Log rollback error
            poMessage = "DATABASE ERROR: " + sqle.getMessage() + " (SQLState: " + sqle.getSQLState() + ", ErrorCode: " + sqle.getErrorCode() + ")";
            poMessageType = "error";
            System.err.println("SQLException occurred:");
            sqle.printStackTrace(); // For server logs
        } catch (Exception e) { // Catch-all for other unexpected errors
            if (conn != null) try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            poMessage = "UNEXPECTED ERROR: " + e.getMessage();
            poMessageType = "error";
            System.err.println("General Exception occurred:");
            e.printStackTrace(); // For server logs
        } finally {
            // Close resources
            if (generatedKeys != null) try { generatedKeys.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (pstmtItem != null) try { pstmtItem.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (pstmtMain != null) try { pstmtMain.close(); } catch (SQLException e) { e.printStackTrace(); }
            if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }

            // Set messages for display and redirect
            session.setAttribute("poMessage", poMessage);
            session.setAttribute("poMessageType", poMessageType);
            response.sendRedirect(request.getRequestURI()); // Redirect to prevent re-submission
            return; // Crucial to stop further output/processing of JSP in this request
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Create Purchase Order - Swift POS</title>
  <%-- Make sure these paths are correct relative to your webapp structure --%>
  <script src="${pageContext.request.contextPath}/Admin/script.js"></script>
  <link rel="Stylesheet" href="${pageContext.request.contextPath}/Admin/styles.css">
  <style>
    /* Your existing CSS styles remain here */
    :root {
      --primary: #4f46e5;    /* Indigo 600 */
      --primary-light: #6366f1; /* Indigo 500 */
      --secondary: #475569;    /* Slate 600 */
      --dark: #1e293b;        /* Slate 800 */
      --light: #f8fafc;      /* Slate 50 */
      --danger: #ef4444;      /* Red 500 */
      --success: #10b981;      /* Emerald 500 */
      --warning: #f59e0b;      /* Amber 500 */
    }
    .po-form-container { background-color: white; border-radius: 8px; box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05); padding: 20px; margin-bottom: 20px; }
    .form-row { display: flex; flex-wrap: wrap; margin: 0 -10px; margin-bottom: 15px; }
    .form-group { flex: 1; min-width: 200px; padding: 0 10px; margin-bottom: 15px; }
    .form-group label { display: block; margin-bottom: 8px; font-weight: 500; font-size: 14px; color: var(--dark); }
    .form-group input, .form-group select, .form-group textarea { box-sizing: border-box; width: 100%; padding: 10px 12px; border: 1px solid #e2e8f0; border-radius: 6px; font-size: 14px; background-color: #f8fafc; }
    .form-group textarea { min-height: 100px; resize: vertical; }
    .form-group.full-width { width: 100%; flex-basis: 100%; }
    .products-table { margin-top: 20px; width: 100%; border-collapse: collapse; }
    .products-table th { background-color: #f1f5f9; padding: 12px 15px; text-align: left; font-weight: 500; font-size: 14px; color: var(--dark); }
    .products-table td { padding: 12px 15px; border-bottom: 1px solid #f1f5f9; }
    .products-table tr:last-child td { border-bottom: none; }
    .product-select { width: 100%; padding: 8px 10px; border: 1px solid #e2e8f0; border-radius: 4px; background-color: #f8fafc; }
    .quantity-input { width: 60px; padding: 8px 10px; border: 1px solid #e2e8f0; border-radius: 4px; text-align: center; background-color: #f8fafc; }
    .quantity-control { display: flex; align-items: center; justify-content: space-between; max-width: 130px; }
    .quantity-btn { width: 30px; height: 30px; display: flex; align-items: center; justify-content: center; background-color: var(--primary-light); color: white; border: none; border-radius: 4px; font-size: 16px; cursor: pointer; transition: background-color 0.2s; }
    .quantity-btn:hover { background-color: var(--primary); }
    .unit-price { font-weight: 500; color: var(--dark); }
    .row-total { font-weight: 500; color: var(--primary); }
    .add-row-btn { display: block; width: 100%; background-color: #e0e7ff; border: 1px dashed #a5b4fc; color: var(--primary); padding: 10px; margin-top: 10px; border-radius: 6px; cursor: pointer; font-size: 14px; text-align: center; transition: background-color 0.2s; }
    .add-row-btn:hover { background-color: #c7d2fe; }
    .summary-box { background-color: #f1f5f9; border-radius: 8px; padding: 20px; margin-top: 20px; border: 1px solid #e2e8f0; }
    .summary-row { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #e2e8f0; color: var(--dark); }
    .summary-row:last-child { border-bottom: none; padding-top: 15px; font-weight: 600; font-size: 18px; color: var(--primary); }
    .action-buttons { display: flex; justify-content: flex-end; margin-top: 30px; gap: 15px; }
    .action-btn { padding: 12px 24px; border-radius: 6px; font-weight: 500; cursor: pointer; border: none; font-size: 14px; transition: background-color 0.2s; }
    .btn-secondary { background-color: #e2e8f0; color: var(--dark); }
    .btn-secondary:hover { background-color: #cbd5e1; }
    .btn-primary { background-color: var(--primary); color: white; }
    .btn-primary:hover { background-color: #4338ca; }
    .remove-row { background: none; border: none; color: var(--danger); cursor: pointer; font-size: 18px; transition: transform 0.2s; }
    .remove-row:hover { transform: scale(1.1); }
    .message-container { padding: 10px; margin-bottom: 15px; border-radius: 5px; font-size: 14px; text-align: center; word-wrap: break-word; } /* Added word-wrap */
    .message-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
    .message-error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
    @media (max-width: 768px) {
      .form-group { flex: 0 0 100%; }
      .action-buttons { flex-direction: column; }
      .action-btn { width: 100%; }
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
      <%-- Make sure menu.jsp path is correct --%>
      <jsp:include page="menu.jsp" />
    </div>

    <div class="main-content">
      <div class="header">
        <h1 class="page-title">Create Purchase Order</h1>
        <div class="user-profile">
          <img src="${pageContext.request.contextPath}/Images/logo.png" alt="Admin Profile">
          <div>
            <%
                // This is for display only; submission logic uses loggedInUserSubmit
                model.User loggedInUserDisplay = (model.User) session.getAttribute("loggedInUser");
                String userDisplayName = "Admin User (Not Logged In)"; // Default if not logged in
                if (loggedInUserDisplay != null) {
                    try {
                        // Assuming getFirstName and getLastName exist
                        userDisplayName = loggedInUserDisplay.getFirstName() + " " + loggedInUserDisplay.getLastName();
                        if (userDisplayName == null || userDisplayName.trim().isEmpty()){
                             userDisplayName = "User ID: " + loggedInUserDisplay.getId(); // Fallback
                        }
                    } catch (Exception e) {
                        userDisplayName = "Registered User (Error getting name)";
                        // Log this minor display error if needed: e.printStackTrace();
                    }
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
            <div class="message-container <%= "success".equals(messageType) ? "message-success" : "message-error" %>">
                <%= message %>
            </div>
        <%
                session.removeAttribute("poMessage");
                session.removeAttribute("poMessageType");
            }
        %>

      <div class="po-form-container">
        <%-- Form submits to the current page (itself) --%>
        <form method="post" action="<%= request.getRequestURI() %>" id="purchaseOrderForm">
          <div class="form-row">
            <div class="form-group">
              <label for="order_id">Purchase Order #</label>
              <input type="text" id="order_id" name="order_id" value="PO-<%= new java.util.Random().nextInt(900000) + 100000 %>" readonly required>
            </div>
            <div class="form-group">
              <label for="order_date">Order Date</label>
              <input type="date" id="order_date" name="order_date" value="<%= LocalDate.now().format(DateTimeFormatter.ISO_DATE) %>" required>
            </div>
            <div class="form-group">
              <label for="expected_date">Expected Delivery Date</label>
              <input type="date" id="expected_date" name="expected_date" value="<%= LocalDate.now().plusDays(7).format(DateTimeFormatter.ISO_DATE) %>" required>
            </div>
          </div>

          <div class="form-row">
            <div class="form-group">
              <label for="supplier_id">Select Supplier</label>
              <select id="supplier_id" name="supplier_id" required>
                <option value="">-- Select Supplier --</option>
                <%
                    Connection conn_jsp_supplier = null;
                    PreparedStatement ps_supplier = null;
                    ResultSet rs_supplier = null;
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn_jsp_supplier = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                        // Ensure 'suppliers' table and columns 'supplier_id', 'company_name', 'supplier_status' exist
                        ps_supplier = conn_jsp_supplier.prepareStatement("SELECT supplier_id, company_name FROM suppliers WHERE supplier_status = 'Active' ORDER BY company_name");
                        rs_supplier = ps_supplier.executeQuery();
                        while (rs_supplier.next()) { %>
                          <option value="<%= rs_supplier.getString("supplier_id") %>"><%= rs_supplier.getString("company_name") %></option>
                        <% }
                    } catch (Exception ex) {
                        out.println("<option value=''>Error loading suppliers: " + ex.getMessage() + "</option>");
                        ex.printStackTrace(); // For server log
                    } finally {
                        if (rs_supplier != null) try { rs_supplier.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (ps_supplier != null) try { ps_supplier.close(); } catch (SQLException e) { e.printStackTrace(); }
                        if (conn_jsp_supplier != null) try { conn_jsp_supplier.close(); } catch (SQLException e) { e.printStackTrace(); }
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
              <%-- A template row for products. JavaScript will clone this. --%>
              <tr class="product-row">
                <td>
                  <%-- name="product_id" will be collected as an array by getParameterValues --%>
                  <select name="product_id" class="product-select" required onchange="updateProductPrice(this)">
                    <option value="">-- Select Product --</option>
                    <%
                        Connection conn_products = null;
                        PreparedStatement ps_products = null;
                        ResultSet rs_products = null;
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            conn_products = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                            // Ensure 'products' table and columns 'id', 'name', 'price', 'status' exist
                            ps_products = conn_products.prepareStatement("SELECT id, name, price FROM products WHERE status = 'Active' ORDER BY name");
                            rs_products = ps_products.executeQuery();
                            while (rs_products.next()) {
                                double price = rs_products.getDouble("price");
                            %>
                              <option value="<%= rs_products.getString("id") %>" data-price="<%= price %>">
                                <%= rs_products.getString("name") %> - Rs.<%= String.format("%.2f", price) %>
                              </option>
                            <% }
                        } catch (Exception ex) {
                            out.println("<option value=''>Error loading products: " + ex.getMessage() + "</option>");
                            ex.printStackTrace(); // For server log
                        } finally {
                            if (rs_products != null) try { rs_products.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (ps_products != null) try { ps_products.close(); } catch (SQLException e) { e.printStackTrace(); }
                            if (conn_products != null) try { conn_products.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    %>
                  </select>
                  <%-- Hidden fields for each item's price and total, submitted with the form --%>
                  <input type="hidden" name="unit_price_item" class="unit-price-hidden" value="0.00">
                  <input type="hidden" name="row_total_item" class="row-total-hidden" value="0.00">
                </td>
                <td>
                  <div class="quantity-control">
                    <button type="button" class="quantity-btn decrease-btn" onclick="decreaseQuantity(this)">-</button>
                    <%-- name="quantity" will be collected as an array --%>
                    <input type="number" name="quantity" class="quantity-input" value="1" min="1" required onchange="updateRowTotal(this)" oninput="updateRowTotal(this)">
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
              <span>Tax (<span id="tax_percentage_display">15.00</span>%):</span>
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

          <input type="hidden" name="subtotal_hidden" id="subtotal_hidden" value="0.00">
          <input type="hidden" name="tax_amount_hidden" id="tax_amount_hidden" value="0.00">
          <input type="hidden" name="grand_total_hidden" id="grand_total_hidden" value="0.00">

          <div class="action-buttons">
            <button type="button" class="action-btn btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/Admin/purchases.jsp'">Cancel</button>
            <button type="submit" class="action-btn btn-primary">Create Purchase Order</button>
          </div>
        </form>
      </div>

      <div class="footer">
        Swift &copy; <%= java.time.Year.now().getValue() %>.
      </div>
    </div>
  </div>

  <script>
    function updateProductPrice(selectElement) {
        const row = selectElement.closest('tr');
        const selectedOption = selectElement.options[selectElement.selectedIndex];
        const price = parseFloat(selectedOption.getAttribute('data-price')) || 0;

        row.querySelector('.unit-price').textContent = 'Rs.' + price.toFixed(2);
        row.querySelector('.unit-price-hidden').value = price.toFixed(2); // Update hidden field

        updateRowTotal(selectElement); // Pass the select element itself
    }

    function updateRowTotal(elementInRow) {
        const row = elementInRow.closest('tr');
        const unitPriceText = row.querySelector('.unit-price').textContent;
        const unitPrice = parseFloat(unitPriceText.replace('Rs.', '').replace(/,/g, '')) || 0; // handle potential commas
        const quantityInput = row.querySelector('.quantity-input');
        let quantity = parseInt(quantityInput.value);

        if (isNaN(quantity) || quantity < 1) {
            quantity = 1;
            if (quantityInput.value !== "" && !isNaN(parseInt(quantityInput.value)) && parseInt(quantityInput.value) < 1) {
                 quantityInput.value = 1; // Correct invalid input if not empty and less than 1
            } else if (isNaN(quantity)) {
                 quantityInput.value = 1; // Default to 1 if NaN
            }
            // If input is empty, let validation handle it, but use 1 for calculation
        }

        const rowTotal = unitPrice * quantity;
        row.querySelector('.row-total').textContent = 'Rs.' + rowTotal.toFixed(2);
        row.querySelector('.row-total-hidden').value = rowTotal.toFixed(2); // Update hidden field
        // Ensure unit price hidden field is also current if it was reset somehow
        row.querySelector('.unit-price-hidden').value = unitPrice.toFixed(2);

        updateOrderSummary();
    }

    function increaseQuantity(button) {
      const input = button.parentElement.querySelector('.quantity-input'); // More robust selector
      let currentValue = parseInt(input.value) || 0;
      input.value = currentValue + 1;
      updateRowTotal(input);
    }

    function decreaseQuantity(button) {
      const input = button.parentElement.querySelector('.quantity-input'); // More robust selector
      const currentValue = parseInt(input.value);
      if (currentValue > 1) {
        input.value = currentValue - 1;
        updateRowTotal(input);
      }
    }

    function addProductRow() {
        const productRowsTbody = document.getElementById('product-rows');
        const firstRow = productRowsTbody.querySelector('.product-row'); // Get the first row as template
        if (!firstRow) {
            console.error("Could not find the template product row to clone.");
            // Potentially create a row from scratch if none exists, or show an error.
            // For now, we rely on at least one row being present initially from JSP.
            return;
        }
        const newRow = firstRow.cloneNode(true); // Clone the full structure

        // Reset values in the new row
        newRow.querySelector('.product-select').selectedIndex = 0; // Reset dropdown
        newRow.querySelector('.quantity-input').value = 1;       // Reset quantity
        newRow.querySelector('.unit-price').textContent = 'Rs.0.00';// Reset display price
        newRow.querySelector('.row-total').textContent = 'Rs.0.00'; // Reset display total
        newRow.querySelector('.unit-price-hidden').value = '0.00';  // Reset hidden unit price
        newRow.querySelector('.row-total-hidden').value = '0.00';   // Reset hidden row total

        // Add new row to the table body
        productRowsTbody.appendChild(newRow);
        // Ensure new quantity input also triggers updates
        const newQuantityInput = newRow.querySelector('.quantity-input');
        newQuantityInput.addEventListener('change', function() { updateRowTotal(this); });
        newQuantityInput.addEventListener('input', function() { updateRowTotal(this); });

        updateOrderSummary(); // Recalculate summary
    }

    function removeProductRow(button) {
      const row = button.closest('tr');
      const productRowsTbody = document.getElementById('product-rows');

      if (productRowsTbody.children.length > 1) {
        row.remove();
        updateOrderSummary();
      } else {
        alert("You must have at least one product in the order.");
      }
    }

    function updateOrderSummary() {
        let subtotal = 0;
        document.querySelectorAll('#product-rows .product-row').forEach(function(row) {
            const rowTotalText = row.querySelector('.row-total-hidden').value; // Use hidden value for accuracy
            subtotal += parseFloat(rowTotalText) || 0;
        });
        document.getElementById('subtotal').textContent = 'Rs.' + subtotal.toFixed(2);
        document.getElementById('subtotal_hidden').value = subtotal.toFixed(2);

        const taxPercentageInput = document.getElementById('tax_percentage');
        const taxPercentage = parseFloat(taxPercentageInput.value) || 0;
        document.getElementById('tax_percentage_display').textContent = taxPercentage.toFixed(2);


        const shippingCostInput = document.getElementById('shipping_cost');
        const shippingCost = parseFloat(shippingCostInput.value) || 0;

        const taxAmount = (subtotal * taxPercentage) / 100;
        document.getElementById('tax').textContent = 'Rs.' + taxAmount.toFixed(2);
        document.getElementById('tax_amount_hidden').value = taxAmount.toFixed(2);

        document.getElementById('shipping').textContent = 'Rs.' + shippingCost.toFixed(2);
        // shipping_cost value is directly from an input field, which is fine for submission.

        const total = subtotal + taxAmount + shippingCost;
        document.getElementById('total').textContent = 'Rs.' + total.toFixed(2);
        document.getElementById('grand_total_hidden').value = total.toFixed(2);
    }

    // Initial setup and event listeners
    document.addEventListener('DOMContentLoaded', function() {
        // Add event listeners for dynamic updates
        const taxInput = document.getElementById('tax_percentage');
        const shippingInput = document.getElementById('shipping_cost');
        if(taxInput) taxInput.addEventListener('input', updateOrderSummary);
        if(shippingInput) shippingInput.addEventListener('input', updateOrderSummary);

        // Initialize the first row's calculations if it has a selected product
        document.querySelectorAll('#product-rows .product-row').forEach(row => {
            const productSelect = row.querySelector('.product-select');
            const quantityInput = row.querySelector('.quantity-input');

            if (productSelect) {
                 if(productSelect.value) { // If a product is selected
                    updateProductPrice(productSelect);
                 } else { // No product selected, just ensure row total is calculated if quantity changes
                    updateRowTotal(quantityInput || productSelect); // Default to 0.00 prices
                 }
            }
            if (quantityInput) {
                quantityInput.addEventListener('change', function() { updateRowTotal(this); });
                quantityInput.addEventListener('input', function() { updateRowTotal(this); });
            }
        });
        updateOrderSummary(); // Initial full summary calculation
    });

    // For mobile navigation (if not handled by global script.js)
    const mobileNavToggle = document.getElementById('mobileNavToggle');
    const sidebar = document.getElementById('sidebar');
    if (mobileNavToggle && sidebar) {
        mobileNavToggle.addEventListener('click', function() {
            sidebar.classList.toggle('active');
        });
    }
  </script>
</body>
</html>