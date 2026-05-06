<%--
    Document   : supplier_reports.jsp
    Created on : May 21, 2025
    Author     : Gemini AI (based on user's swift_database and suppliers.jsp)
    Description: Page for displaying supplier-related reports.
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supplier Reports - Swift POS</title>
    <link rel="stylesheet" href="styles.css"> <%-- Assuming styles.css is in the root of your webapp --%>
    <style>
        /* Reusing styles from suppliers.jsp, adding report-specific if needed */
        :root { 
            --primary: #007bff;
            --secondary: #6c757d;
            --success: #28a745;
            --danger: #dc3545;
            --warning: #ffc107;
            --info: #17a2b8;
        }
        .search-filter-bar { /* For report filters */
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 10px;
            padding: 15px;
            background-color: #f9f9f9;
            border-radius: 6px;
        }
        .filter-group {
            display: flex;
            gap: 10px;
            align-items: center;
        }
        .filter-group label {
            font-weight: 500;
        }
        .filter-select, .filter-input {
            padding: 8px 12px;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            background-color: #fff;
        }
        .filter-button {
            background-color: var(--primary);
            color: white;
            border: none;
            padding: 10px 15px;
            border-radius: 6px;
            cursor: pointer;
            font-weight: 500;
        }
        .filter-button:hover {
            background-color: #0056b3;
        }

        .stats-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 20px; margin-bottom: 20px; }
        .stat-card { background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        .stat-card h3 { font-size: 0.9em; color: #555; margin-bottom: 5px; text-transform: uppercase; }
        .stat-card .value { font-size: 1.8em; font-weight: bold; margin-bottom: 10px; }
        .stat-card .description { font-size: 0.85em; color: #777; }

        .module-card { background-color: #fff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-bottom:20px; }
        .module-header { padding: 15px; font-weight: bold; border-bottom: 1px solid #eee; font-size: 1.1em; }
        .module-content { padding: 15px; }

        table { width: 100%; border-collapse: collapse; margin-top:15px; }
        th, td { padding: 10px 12px; text-align: left; border-bottom: 1px solid #eee; font-size:0.9em; }
        thead th { background-color: #f8f9fa; font-weight: bold; }
        .status { padding: 3px 8px; border-radius: 12px; font-size: 0.8em; text-transform: capitalize; color: white; }
        .status.pending { background-color: var(--warning); color: #333; }
        .status.approved { background-color: var(--info); }
        .status.received { background-color: var(--success); }
        .status.cancelled { background-color: var(--danger); }
        .status.draft { background-color: var(--secondary); }
        .status.ordered { background-color: #ff8c00; } /* DarkOrange */
        .status.partially.received { background-color: #dda0dd; } /* Plum */
        .status.closed { background-color: #808080; } /* Gray */


        .user-profile img { width: 40px; height: 40px; border-radius: 50%; margin-right: 10px; }
        .user-profile { display: flex; align-items: center;}
        .page-title { flex-grow: 1; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
        .footer { text-align: center; padding: 20px; margin-top: 30px; background-color: #f8f9fa; font-size: 0.9em; color: #777;}
        .no-data { text-align: center; padding: 20px; color: #777; }
        .text-danger { color: var(--danger); }
        .text-right { text-align: right; }

        @media (max-width: 768px) {
            .search-filter-bar { flex-direction: column; align-items: stretch; }
            .filter-group { flex-direction: column; align-items: stretch; width: 100%;}
            .filter-select, .filter-input, .filter-button { width: 100%; margin-top: 5px; }
            .header { flex-direction: column; align-items: flex-start; }
            .user-profile { margin-top:10px; }
        }
    </style>
</head>
<body>
    <%
        // Database Connection Variables
        String URL = "jdbc:mysql://localhost:3306/swift_database";
        String USER = "root";
        String PASSWORD = ""; // Ensure this is secure in a real application
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        DecimalFormat df = new DecimalFormat("#,##0.00");
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");

        // Initialize report parameters
        String selectedSupplierId = request.getParameter("selected_supplier_id");
        String selectedPoStatus = request.getParameter("selected_po_status");
        String orderDateFrom = request.getParameter("order_date_from");
        String orderDateTo = request.getParameter("order_date_to");

        if (selectedSupplierId == null) selectedSupplierId = "all";
        if (selectedPoStatus == null) selectedPoStatus = "all";
        if (orderDateFrom == null) orderDateFrom = "";
        if (orderDateTo == null) orderDateTo = "";
    %>
    <div class="mobile-top-bar">
        <div class="mobile-logo">
            <img src="${pageContext.request.contextPath}/Images/logo.png" alt="POS Logo">
            <h2>Swift</h2>
        </div>
        <button class="mobile-nav-toggle" id="mobileNavToggle">☰</button>
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
                <h1 class="page-title">Supplier Reports</h1>
                <div class="user-profile">
                <%
                    Connection userConnHeader = null;
                    PreparedStatement userSqlHeader = null;
                    ResultSet userResultHeader = null;
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        userConnHeader = DriverManager.getConnection(URL, USER, PASSWORD);
                        userSqlHeader = userConnHeader.prepareStatement("SELECT first_name, profile_image_path FROM users WHERE role = 'admin' LIMIT 1"); // Assuming admin is viewing reports
                        userResultHeader = userSqlHeader.executeQuery();
                        if (userResultHeader.next()) {
                %>
                            <img src="${pageContext.request.contextPath}/<%= userResultHeader.getString("profile_image_path") %>" alt="Admin Profile">
                            <div>
                                <h4><%= userResultHeader.getString("first_name") %></h4>
                            </div>
                <%      } else {
                            out.println("<p>Admin user not found.</p>");
                        }
                    } catch (Exception ex) {
                        out.println("<p class='text-danger text-center'>Error: " + ex.getMessage() + "</p>");
                    } finally {
                        if (userResultHeader != null) try { userResultHeader.close(); } catch (SQLException e) { /* ignored */ }
                        if (userSqlHeader != null) try { userSqlHeader.close(); } catch (SQLException e) { /* ignored */ }
                        if (userConnHeader != null) try { userConnHeader.close(); } catch (SQLException e) { /* ignored */ }
                    }
                %>
                </div>
            </div>

            <div class="stats-container">
                <%
                    int totalSuppliers = 0;
                    int totalPOs = 0;
                    double totalPOValue = 0.0;
                    int activePOs = 0;

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn = DriverManager.getConnection(URL, USER, PASSWORD);

                        // Total Suppliers
                        pstmt = conn.prepareStatement("SELECT COUNT(*) AS count FROM suppliers"); //
                        rs = pstmt.executeQuery();
                        if (rs.next()) totalSuppliers = rs.getInt("count");
                        rs.close();
                        pstmt.close();

                        // Total POs and Value
                        pstmt = conn.prepareStatement("SELECT COUNT(*) AS po_count, SUM(grand_total) AS total_value FROM swift_purchase_orders_main"); //
                        rs = pstmt.executeQuery();
                        if (rs.next()) {
                            totalPOs = rs.getInt("po_count");
                            totalPOValue = rs.getDouble("total_value");
                        }
                        rs.close();
                        pstmt.close();
                        
                        // Active POs (example: 'Pending' or 'Approved')
                        pstmt = conn.prepareStatement("SELECT COUNT(*) AS active_count FROM swift_purchase_orders_main WHERE order_status IN ('Pending', 'Approved', 'Ordered')"); //
                        rs = pstmt.executeQuery();
                        if (rs.next()) {
                            activePOs = rs.getInt("active_count");
                        }
                        rs.close();
                        pstmt.close();

                    } catch (Exception ex) {
                        out.println("<p class='text-danger'>Error fetching stats: " + ex.getMessage() + "</p>");
                    } finally {
                        if (rs != null) try { rs.close(); } catch (SQLException e) { /* ignored */ }
                        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { /* ignored */ }
                        if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignored */ }
                    }
                %>
                <div class="stat-card">
                    <h3>Total Suppliers</h3>
                    <div class="value"><%= totalSuppliers %></div>
                    <div class="description">Registered in the system.</div>
                </div>
                <div class="stat-card">
                    <h3>Total Purchase Orders</h3>
                    <div class="value"><%= totalPOs %></div>
                    <div class="description">Overall orders placed.</div>
                </div>
                <div class="stat-card">
                    <h3>Total PO Value</h3>
                    <div class="value">Rs.<%= df.format(totalPOValue) %></div>
                    <div class="description">Sum of all order amounts.</div>
                </div>
                 <div class="stat-card">
                    <h3>Active Purchase Orders</h3>
                    <div class="value"><%= activePOs %></div>
                    <div class="description">Pending, Approved, or Ordered.</div>
                </div>
            </div>

            <div class="module-card">
                <div class="module-header">Purchase Order Details</div>
                <div class="module-content">
                    <form method="get" action="supplier_reports.jsp" class="search-filter-bar">
                        <div class="filter-group">
                            <label for="selected_supplier_id">Supplier:</label>
                            <select name="selected_supplier_id" id="selected_supplier_id" class="filter-select">
                                <option value="all">All Suppliers</option>
                                <%
                                    try {
                                        Class.forName("com.mysql.cj.jdbc.Driver");
                                        conn = DriverManager.getConnection(URL, USER, PASSWORD);
                                        pstmt = conn.prepareStatement("SELECT supplier_id, company_name FROM suppliers ORDER BY company_name ASC"); //
                                        rs = pstmt.executeQuery();
                                        while (rs.next()) {
                                            String id = rs.getString("supplier_id");
                                            String name = rs.getString("company_name");
                                            out.println("<option value='" + id + "'" + (id.equals(selectedSupplierId) ? " selected" : "") + ">" + name + "</option>");
                                        }
                                    } catch (Exception e) {
                                        out.println("<option value=''>Error loading suppliers</option>");
                                    } finally {
                                        if (rs != null) try { rs.close(); } catch (SQLException e) { /* ignored */ }
                                        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { /* ignored */ }
                                        if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignored */ }
                                    }
                                %>
                            </select>
                        </div>
                        <div class="filter-group">
                            <label for="selected_po_status">Status:</label>
                            <select name="selected_po_status" id="selected_po_status" class="filter-select">
                                <option value="all">All Statuses</option>
                                <%  // Dynamically fetch distinct statuses from swift_purchase_orders_main or use a predefined list
                                    List<String> poStatuses = new ArrayList<>(Arrays.asList("Pending", "Approved", "Received", "Cancelled", "Ordered", "Partially Received", "Closed", "Draft")); // From DB schema comments for purchase_orders & swift_purchase_orders_main
                                    try {
                                        Class.forName("com.mysql.cj.jdbc.Driver");
                                        conn = DriverManager.getConnection(URL, USER, PASSWORD);
                                        pstmt = conn.prepareStatement("SELECT DISTINCT order_status FROM swift_purchase_orders_main WHERE order_status IS NOT NULL AND order_status != '' ORDER BY order_status"); //
                                        rs = pstmt.executeQuery();
                                        Set<String> distinctStatuses = new HashSet<>(poStatuses); // Start with common ones
                                        while(rs.next()){
                                            distinctStatuses.add(rs.getString("order_status"));
                                        }
                                        List<String> sortedStatuses = new ArrayList<>(distinctStatuses);
                                        Collections.sort(sortedStatuses);

                                        for (String status : sortedStatuses) {
                                            out.println("<option value='" + status + "'" + (status.equalsIgnoreCase(selectedPoStatus) ? " selected" : "") + ">" + status + "</option>");
                                        }
                                    } catch (Exception e) {
                                        // Fallback or error message
                                        for (String status : poStatuses) { // Fallback to predefined
                                             out.println("<option value='" + status + "'" + (status.equalsIgnoreCase(selectedPoStatus) ? " selected" : "") + ">" + status + "</option>");
                                        }
                                    } finally {
                                        if (rs != null) try { rs.close(); } catch (SQLException e) { /* ignored */ }
                                        if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { /* ignored */ }
                                        if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignored */ }
                                    }
                                %>
                            </select>
                        </div>
                        <div class="filter-group">
                            <label for="order_date_from">From:</label>
                            <input type="date" name="order_date_from" id="order_date_from" value="<%= orderDateFrom %>" class="filter-input">
                        </div>
                        <div class="filter-group">
                            <label for="order_date_to">To:</label>
                            <input type="date" name="order_date_to" id="order_date_to" value="<%= orderDateTo %>" class="filter-input">
                        </div>
                        <button type="submit" class="filter-button">Apply Filters</button>
                    </form>

                    <table>
                        <thead>
                            <tr>
                                <th>PO Number</th>
                                <th>Supplier</th>
                                <th>Order Date</th>
                                <th>Expected Delivery</th>
                                <th class="text-right">Total Amount (Rs.)</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                StringBuilder queryBuilder = new StringBuilder("SELECT spom.order_number_display, s.company_name, spom.order_date_form, spom.expected_delivery_date, spom.grand_total, spom.order_status FROM swift_purchase_orders_main spom JOIN suppliers s ON spom.supplier_id = s.supplier_id WHERE 1=1"); //
                                List<Object> queryParams = new ArrayList<>();

                                if (!"all".equals(selectedSupplierId)) {
                                    queryBuilder.append(" AND spom.supplier_id = ?");
                                    queryParams.add(Integer.parseInt(selectedSupplierId));
                                }
                                if (!"all".equals(selectedPoStatus)) {
                                    queryBuilder.append(" AND spom.order_status = ?");
                                    queryParams.add(selectedPoStatus);
                                }
                                if (!orderDateFrom.isEmpty()) {
                                    queryBuilder.append(" AND spom.order_date_form >= ?");
                                    queryParams.add(orderDateFrom);
                                }
                                if (!orderDateTo.isEmpty()) {
                                    queryBuilder.append(" AND spom.order_date_form <= ?");
                                    queryParams.add(orderDateTo);
                                }
                                queryBuilder.append(" ORDER BY spom.order_date_form DESC, spom.po_main_id DESC LIMIT 200"); // Limit results for performance

                                boolean poFound = false;
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    conn = DriverManager.getConnection(URL, USER, PASSWORD);
                                    pstmt = conn.prepareStatement(queryBuilder.toString());
                                    for (int i = 0; i < queryParams.size(); i++) {
                                        pstmt.setObject(i + 1, queryParams.get(i));
                                    }
                                    rs = pstmt.executeQuery();
                                    while (rs.next()) {
                                        poFound = true;
                                        String statusClass = rs.getString("order_status") != null ? rs.getString("order_status").toLowerCase().replace(" ", ".") : "pending";
                            %>
                                        <tr>
                                            <td><%= rs.getString("order_number_display") %></td>
                                            <td><%= rs.getString("company_name") %></td>
                                            <td><%= sdf.format(rs.getDate("order_date_form")) %></td>
                                            <td><%= sdf.format(rs.getDate("expected_delivery_date")) %></td>
                                            <td class="text-right"><%= df.format(rs.getDouble("grand_total")) %></td>
                                            <td><span class="status <%= statusClass %>"><%= rs.getString("order_status") %></span></td>
                                        </tr>
                            <%
                                    }
                                    if (!poFound) {
                                        out.println("<tr><td colspan='6' class='no-data'>No purchase orders found matching your criteria.</td></tr>");
                                    }
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='6' class='text-danger'>Error fetching purchase orders: " + e.getMessage() + "</td></tr>");
                                    e.printStackTrace();
                                } finally {
                                    if (rs != null) try { rs.close(); } catch (SQLException e) { /* ignored */ }
                                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { /* ignored */ }
                                    if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignored */ }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>

            <div class="module-card">
                <div class="module-header">Total Spending by Supplier</div>
                <div class="module-content">
                    <table>
                        <thead>
                            <tr>
                                <th>Rank</th>
                                <th>Supplier Name</th>
                                <th class="text-right">Number of POs</th>
                                <th class="text-right">Total Spent (Rs.)</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                boolean spendingDataFound = false;
                                int rank = 1;
                                try {
                                    Class.forName("com.mysql.cj.jdbc.Driver");
                                    conn = DriverManager.getConnection(URL, USER, PASSWORD);
                                    String spendingQuery = "SELECT s.company_name, COUNT(spom.po_main_id) AS num_pos, SUM(spom.grand_total) AS total_spent " + //
                                                           "FROM suppliers s JOIN swift_purchase_orders_main spom ON s.supplier_id = spom.supplier_id " + //
                                                           "GROUP BY s.supplier_id, s.company_name " + //
                                                           "ORDER BY total_spent DESC LIMIT 50"; // Limit results for performance
                                    pstmt = conn.prepareStatement(spendingQuery);
                                    rs = pstmt.executeQuery();
                                    while (rs.next()) {
                                        spendingDataFound = true;
                            %>
                                        <tr>
                                            <td><%= rank++ %></td>
                                            <td><%= rs.getString("company_name") %></td>
                                            <td class="text-right"><%= rs.getInt("num_pos") %></td>
                                            <td class="text-right"><%= df.format(rs.getDouble("total_spent")) %></td>
                                        </tr>
                            <%
                                    }
                                    if (!spendingDataFound) {
                                        out.println("<tr><td colspan='4' class='no-data'>No spending data available.</td></tr>");
                                    }
                                } catch (Exception e) {
                                     out.println("<tr><td colspan='4' class='text-danger'>Error fetching spending data: " + e.getMessage() + "</td></tr>");
                                     e.printStackTrace();
                                } finally {
                                    if (rs != null) try { rs.close(); } catch (SQLException e) { /* ignored */ }
                                    if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { /* ignored */ }
                                    if (conn != null) try { conn.close(); } catch (SQLException e) { /* ignored */ }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div class="footer">
                Swift © <%= java.time.Year.now().getValue() %>.
            </div>
        </div>
    </div>
    
    <script>
        // Mobile navigation toggle
        document.getElementById('mobileNavToggle').addEventListener('click', function() {
            document.getElementById('sidebar').classList.toggle('active');
        });

        // Simple clear filter for dates (optional enhancement)
        // function clearDateFilter(inputId) {
        //    document.getElementById(inputId).value = "";
        // }
    </script>
</body>
</html>