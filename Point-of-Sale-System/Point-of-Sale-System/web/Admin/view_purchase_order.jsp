<%--
    Document   : view_purchase_order
    Created on : May 21, 2025
    Author     : AI / Your Name
    Based on   : swift_database (28).sql
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*, java.util.*, java.text.NumberFormat, java.util.Locale" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Purchase Order - Swift POS</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        :root {
            --primary: #007bff; --secondary: #6c757d; --success: #28a745;
            --danger: #dc3545; --warning: #ffc107; --info: #17a2b8;
            --light: #f8f9fa; --dark: #343a40;
        }
        body { font-family: Arial, sans-serif; margin: 0; background-color: #f4f6f9; color: #333; }
        .dashboard { display: flex; }
        .sidebar { width: 250px; /* Adjust as needed */ }
        .main-content { flex-grow: 1; padding: 20px; }
        .header { display: flex; justify-content: space-between; align-items: center; padding-bottom: 15px; border-bottom: 1px solid #eee; margin-bottom: 20px; }
        .page-title { font-size: 1.8em; color: var(--dark); }
        .user-profile img { width: 40px; height: 40px; border-radius: 50%; margin-right: 10px; }
        .user-profile { display: flex; align-items: center; }

        .po-details-card { background-color: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-bottom: 20px; }
        .po-header { padding: 20px; border-bottom: 1px solid #eee; background-color: var(--primary); color: white; border-top-left-radius: 8px; border-top-right-radius: 8px; }
        .po-header h2 { margin: 0; font-size: 1.5em; }
        .po-header .status { float: right; background-color: black; padding: 5px 15px; border-radius: 15px; font-size: 0.9em; text-transform: uppercase; }
        .po-header .status.approved { background-color: var(--success); }
        .po-header .status.received { background-color: var(--info); }
        .po-header .status.cancelled { background-color: var(--danger); }
        
        .po-section { padding: 20px; border-bottom: 1px solid #eee; }
        .po-section:last-child { border-bottom: none; }
        .po-section h3 { font-size: 1.2em; color: var(--primary); margin-top: 0; margin-bottom: 15px; border-bottom: 1px solid #eee; padding-bottom: 8px;}
        .info-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px; }
        .info-item { margin-bottom: 10px; }
        .info-item strong { display: inline-block; width: 150px; color: #555; }
        
        .items-table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .items-table th, .items-table td { padding: 10px; text-align: left; border-bottom: 1px solid #eee; }
        .items-table thead th { background-color: var(--light); font-weight: bold; }
        .items-table td.number, .items-table th.number { text-align: right; }
        
        .totals-section { padding: 20px; background-color: var(--light); border-bottom-left-radius: 8px; border-bottom-right-radius: 8px; }
        .totals-grid { display: grid; grid-template-columns: 1fr auto; gap: 5px 20px; max-width: 400px; margin-left: auto; }
        .totals-grid strong { font-weight: bold; text-align: right; }
        .totals-grid .grand-total strong, .totals-grid .grand-total span { font-size: 1.2em; color: var(--primary); }

        .action-buttons-bar { padding: 20px; text-align: right; background-color: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.1); margin-top:20px;}
        .action-btn {
            padding: 10px 20px; margin-left: 10px; border: none; border-radius: 5px;
            cursor: pointer; font-weight: bold; text-decoration: none; display: inline-block;
        }
        .edit-btn { background-color: var(--info); color: white; }
        .print-btn { background-color: var(--secondary); color: white; }
        .back-btn { background-color: #ccc; color: #333; }
        .footer { text-align: center; padding: 20px; margin-top: 30px; font-size: 0.9em; color: #777;}
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
                <h1 class="page-title">Purchase Order Details</h1>
                <div class="user-profile">
                    <%-- User Profile Display (same as other pages) --%>
                    <%
                        Connection _userConn = null; PreparedStatement _userSql = null; ResultSet _userResult = null;
                        String _URL = "jdbc:mysql://localhost:3306/swift_database";
                        String _USER = "root"; String _PASSWORD = "";
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            _userConn = DriverManager.getConnection(_URL, _USER, _PASSWORD);
                            _userSql = _userConn.prepareStatement("SELECT first_name, profile_image_path FROM users WHERE role = 'admin' LIMIT 1");
                            _userResult = _userSql.executeQuery();
                            if (_userResult.next()) {
                    %>
                            <img src="${pageContext.request.contextPath}/<%= _userResult.getString("profile_image_path") %>" alt="Admin Profile">
                            <div><h4><%= _userResult.getString("first_name") %></h4></div>
                    <%      }
                        } catch (Exception ex) { out.println("<p class='text-danger'>Error: " + ex.getMessage() + "</p>"); } 
                        finally {
                            if (_userResult != null) try { _userResult.close(); } catch (SQLException e) {}
                            if (_userSql != null) try { _userSql.close(); } catch (SQLException e) {}
                            if (_userConn != null) try { _userConn.close(); } catch (SQLException e) {}
                        }
                    %>
                </div>
            </div>

            <%
                String poMainIdStr = request.getParameter("id");
                if (poMainIdStr == null || poMainIdStr.trim().isEmpty()) {
                    out.println("<p class='feedback-message error'>No Purchase Order ID provided.</p>");
                    return;
                }

                Connection conn = null;
                PreparedStatement pstmtPoMain = null;
                ResultSet rsPoMain = null;
                PreparedStatement pstmtPoItems = null;
                ResultSet rsPoItems = null;
                NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(new Locale("si", "LK"));

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(_URL, _USER, _PASSWORD);

                    String sqlPoMain = "SELECT pom.*, u.first_name as creator_first_name, u.last_name as creator_last_name " +
                                       "FROM swift_purchase_orders_main pom " +
                                       "LEFT JOIN users u ON pom.created_by_user_id = u.id " +
                                       "WHERE pom.po_main_id = ?";
                    pstmtPoMain = conn.prepareStatement(sqlPoMain);
                    pstmtPoMain.setInt(1, Integer.parseInt(poMainIdStr));
                    rsPoMain = pstmtPoMain.executeQuery();

                    if (rsPoMain.next()) {
                        String orderNumberDisplay = rsPoMain.getString("order_number_display");
                        String supplierCompanyName = rsPoMain.getString("supplier_company_name");
                        String orderDateForm = rsPoMain.getString("order_date_form");
                        String expectedDeliveryDate = rsPoMain.getString("expected_delivery_date");
                        String paymentTerms = rsPoMain.getString("payment_terms");
                        String shippingMethod = rsPoMain.getString("shipping_method");
                        String notes = rsPoMain.getString("notes");
                        double subtotal = rsPoMain.getDouble("subtotal");
                        double taxPercentage = rsPoMain.getDouble("tax_percentage");
                        double taxAmount = rsPoMain.getDouble("tax_amount");
                        double shippingFee = rsPoMain.getDouble("shipping_fee");
                        double grandTotal = rsPoMain.getDouble("grand_total");
                        String orderStatus = rsPoMain.getString("order_status");
                        String createdByUserFullName = rsPoMain.getString("created_by_user_full_name"); // Directly from PO table
                        if (createdByUserFullName == null || createdByUserFullName.trim().isEmpty()){
                             createdByUserFullName = rsPoMain.getString("creator_first_name") + " " + rsPoMain.getString("creator_last_name");
                        }
                        String orderCreationDatetime = rsPoMain.getTimestamp("order_creation_datetime").toString();

            %>
            <div class="po-details-card">
                <div class="po-header">
                    <h2>Order #<%= orderNumberDisplay %></h2>
                    <span class="status <%= orderStatus != null ? orderStatus.toLowerCase().replaceAll("\\s+", "-") : "" %>"><%= orderStatus %></span>
                </div>

                <div class="po-section">
                    <h3>General Information</h3>
                    <div class="info-grid">
                        <div class="info-item"><strong>Supplier:</strong> <span><%= supplierCompanyName %></span></div>
                        <div class="info-item"><strong>Order Date:</strong> <span><%= orderDateForm %></span></div>
                        <div class="info-item"><strong>Expected Delivery:</strong> <span><%= expectedDeliveryDate %></span></div>
                        <div class="info-item"><strong>Payment Terms:</strong> <span><%= paymentTerms != null ? paymentTerms : "N/A" %></span></div>
                        <div class="info-item"><strong>Shipping Method:</strong> <span><%= shippingMethod != null ? shippingMethod : "N/A" %></span></div>
                        <div class="info-item"><strong>Created By:</strong> <span><%= createdByUserFullName %></span></div>
                        <div class="info-item"><strong>Creation Date:</strong> <span><%= orderCreationDatetime %></span></div>
                    </div>
                     <% if (notes != null && !notes.trim().isEmpty()) { %>
                        <div class="info-item" style="grid-column: 1 / -1;"><strong>Notes:</strong> <pre><%= notes %></pre></div>
                     <% } %>
                </div>

                <div class="po-section">
                    <h3>Order Items</h3>
                    <table class="items-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Product Name</th>
                                <th>SKU</th>
                                <th class="number">Quantity</th>
                                <th class="number">Unit Price</th>
                                <th class="number">Row Total</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            String sqlPoItems = "SELECT poi.*, p.name AS product_name, p.sku AS product_sku " +
                                                "FROM swift_purchase_order_items poi " +
                                                "JOIN products p ON poi.product_id = p.id " +
                                                "WHERE poi.po_main_id = ?";
                            pstmtPoItems = conn.prepareStatement(sqlPoItems);
                            pstmtPoItems.setInt(1, Integer.parseInt(poMainIdStr));
                            rsPoItems = pstmtPoItems.executeQuery();
                            int itemCount = 0;
                            while(rsPoItems.next()) {
                                itemCount++;
                        %>
                            <tr>
                                <td><%= itemCount %></td>
                                <td><%= rsPoItems.getString("product_name") %></td>
                                <td><%= rsPoItems.getString("product_sku") %></td>
                                <td class="number"><%= rsPoItems.getInt("quantity_ordered") %></td>
                                <td class="number"><%= currencyFormatter.format(rsPoItems.getDouble("unit_price_at_order")).replace("LKR", "Rs. ") %></td>
                                <td class="number"><%= currencyFormatter.format(rsPoItems.getDouble("row_total_at_order")).replace("LKR", "Rs. ") %></td>
                            </tr>
                        <%
                            }
                            if (itemCount == 0) {
                                out.println("<tr><td colspan='6' style='text-align:center;'>No items found for this order.</td></tr>");
                            }
                        %>
                        </tbody>
                    </table>
                </div>
                
                <div class="totals-section">
                     <h3>Order Summary</h3>
                    <div class="totals-grid">
                        <strong>Subtotal:</strong> <span><%= currencyFormatter.format(subtotal).replace("LKR", "Rs. ") %></span>
                        <strong>Tax (<%= String.format("%.2f", taxPercentage) %>%):</strong> <span><%= currencyFormatter.format(taxAmount).replace("LKR", "Rs. ") %></span>
                        <strong>Shipping Fee:</strong> <span><%= currencyFormatter.format(shippingFee).replace("LKR", "Rs. ") %></span>
                        <strong class="grand-total">Grand Total:</strong> <span class="grand-total"><%= currencyFormatter.format(grandTotal).replace("LKR", "Rs. ") %></span>
                    </div>
                </div>
            </div>

            <div class="action-buttons-bar">
                <a href="${pageContext.request.contextPath}/Admin/all_purchases.jsp" class="action-btn back-btn">Back to List</a>
                <button onclick="window.print()" class="action-btn print-btn">Print Order</button>
                <%-- Only allow editing if status is appropriate (e.g., not 'Received' or 'Cancelled') --%>
                <% if (!"Received".equalsIgnoreCase(orderStatus) && !"Cancelled".equalsIgnoreCase(orderStatus)) { %>
                <a href="${pageContext.request.contextPath}/Admin/edit_purchase_order.jsp?id=<%= poMainIdStr %>" class="action-btn edit-btn">Edit Order</a>
                <% } %>
            </div>

            <%
                    } else {
                        out.println("<p class='feedback-message error'>Purchase Order not found.</p>");
                    }
                } catch (NumberFormatException nfe){
                    out.println("<p class='feedback-message error'>Invalid Purchase Order ID format.</p>");
                } catch (Exception e) {
                    out.println("<p class='feedback-message error'>Error loading purchase order details: " + e.getMessage() + "</p>");
                    e.printStackTrace();
                } finally {
                    if (rsPoItems != null) try { rsPoItems.close(); } catch (SQLException e) {}
                    if (pstmtPoItems != null) try { pstmtPoItems.close(); } catch (SQLException e) {}
                    if (rsPoMain != null) try { rsPoMain.close(); } catch (SQLException e) {}
                    if (pstmtPoMain != null) try { pstmtPoMain.close(); } catch (SQLException e) {}
                    if (conn != null) try { conn.close(); } catch (SQLException e) {}
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
    </script>
</body>
</html>