<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.Year" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.text.SimpleDateFormat" %>

<%
    // Database connection details
    String DB_URL = "jdbc:mysql://localhost:3306/Swift_Database";
    String DB_USER = "root";
    String DB_PASSWORD = "";

    // Initialize variables for stats (already present in your file)
    double dailySales = 0.0;
    double monthlySales = 0.0;
    int totalProducts = 0;
    int lowStockItemsCount = 0;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    Locale sriLankaLocale = new Locale("en", "LK");
    NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(sriLankaLocale);
    currencyFormatter.setCurrency(java.util.Currency.getInstance("LKR"));

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

        // --- Daily Sales ---
        String dailySalesQuery = "SELECT SUM(total_amount) AS daily_total FROM pos_sales WHERE DATE(transaction_time) = CURDATE()";
        pstmt = conn.prepareStatement(dailySalesQuery);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            dailySales = rs.getDouble("daily_total");
        }
        rs.close();
        pstmt.close();

        // --- Monthly Sales ---
        String monthlySalesQuery = "SELECT SUM(total_amount) AS monthly_total FROM pos_sales WHERE MONTH(transaction_time) = MONTH(CURDATE()) AND YEAR(transaction_time) = YEAR(CURDATE())";
        pstmt = conn.prepareStatement(monthlySalesQuery);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            monthlySales = rs.getDouble("monthly_total");
        }
        rs.close();
        pstmt.close();

        // --- Total Products ---
        String totalProductsQuery = "SELECT COUNT(id) AS product_count FROM products";
        pstmt = conn.prepareStatement(totalProductsQuery);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            totalProducts = rs.getInt("product_count");
        }
        rs.close();
        pstmt.close();

        // --- Low Stock Items (Count for Stat Card) ---
        String lowStockQuery = "SELECT COUNT(id) AS low_stock_count FROM products WHERE stock <= reorder_level AND reorder_level > 0 AND stock > 0"; //
        pstmt = conn.prepareStatement(lowStockQuery);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            lowStockItemsCount = rs.getInt("low_stock_count");
        }
        rs.close();
        pstmt.close();

    } catch (Exception e) {
        e.printStackTrace(); 
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ex) { /* log */ }
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) { /* log */ }
        if (conn != null) try { conn.close(); } catch (SQLException ex) { /* log */ }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard</title>
    <%-- <script src="script.js"></script> --%>
    <link rel="Stylesheet" href="styles.css">
</head>
<body>
    <div class="mobile-top-bar">
        <div class="mobile-logo" style="display:flex; align-items:center;">
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
                <h1 class="page-title"> Admin Dashboard</h1>
                <div class="user-profile">
                    <%
                        String adminProfileImg = "Images/default-profile.png"; 
                        String adminFirstName = "Admin";
                        Connection headerConn = null;
                        PreparedStatement headerPstmt = null;
                        ResultSet headerRs = null;
                        try {
                            headerConn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                            headerPstmt = headerConn.prepareStatement("SELECT first_name, profile_image_path FROM users WHERE role = 'Admin' LIMIT 1"); //
                            headerRs = headerPstmt.executeQuery();
                            if (headerRs.next()) {
                                adminFirstName = headerRs.getString("first_name") != null ? headerRs.getString("first_name") : "Admin"; //
                                String fetchedPath = headerRs.getString("profile_image_path"); //
                                if (fetchedPath != null && !fetchedPath.trim().isEmpty() && 
                                    !fetchedPath.toLowerCase().endsWith("uploads\\profile_images\\") && 
                                    !fetchedPath.toLowerCase().endsWith("uploads/profile_images/")) {
                                    adminProfileImg = fetchedPath.replace("\\", "/");
                                }
                            }
                        } catch (Exception ex) {
                            ex.printStackTrace(); 
                        } finally {
                            if (headerRs != null) try { headerRs.close(); } catch (SQLException e) { /* log */ }
                            if (headerPstmt != null) try { headerPstmt.close(); } catch (SQLException e) { /* log */ }
                            if (headerConn != null) try { headerConn.close(); } catch (SQLException e) { /* log */ }
                        }
                    %>
                    <img src="${pageContext.request.contextPath}/<%= adminProfileImg %>" alt="Admin Profile" onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/Images/default-profile.png';">
                    <div><h4><%= adminFirstName %></h4></div>
                </div>
            </div>
            
            <div class="stats-container">
                <div class="stat-card">
                    <h3>DAILY SALES</h3>
                    <div class="value"><%= currencyFormatter.format(dailySales) %></div>
                    <div class="trend up">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="18 15 12 9 6 15"></polyline></svg>
                        12.5% from yesterday 
                    </div>
                </div>
                <div class="stat-card">
                    <h3>MONTHLY SALES</h3>
                    <div class="value"><%= currencyFormatter.format(monthlySales) %></div>
                    <div class="trend up">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="18 15 12 9 6 15"></polyline></svg>
                        8.2% from last month
                    </div>
                </div>
                <div class="stat-card">
                    <h3>TOTAL PRODUCTS</h3>
                    <div class="value"><%= totalProducts %></div>
                    <div class="trend up">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="18 15 12 9 6 15"></polyline></svg>
                        5 new products added
                    </div>
                </div>
                <div class="stat-card">
                    <h3>LOW STOCK ITEMS</h3>
                    <div class="value"><%= lowStockItemsCount %></div>
                    <div class="trend down">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                        3 more than yesterday
                    </div>
                </div>
            </div>
            
            <div class="modules-container">
                <div class="module-card">
                    <div class="module-header">Admin Quick Actions</div>
                    <div class="module-content">
                        <div class="module-action">
                            <div class="action-icon">👤</div>
                            <a href="user_management.jsp" style="text-decoration: none; color: inherit; display: contents;">
                                <div class="action-text"><h4>User Management</h4><p>Create, edit, delete user accounts</p></div>
                            </a>
                        </div>
                        <div class="module-action">
                            <div class="action-icon">📦</div>
                             <a href="products.jsp" style="text-decoration: none; color: inherit; display: contents;">
                                <div class="action-text"><h4>Product Management</h4><p>Add, update, delete products</p></div>
                            </a>
                        </div>
                        <div class="module-action">
                            <div class="action-icon">🏭</div>
                            <a href="suppliers.jsp" style="text-decoration: none; color: inherit; display: contents;">
                                <div class="action-text"><h4>Supplier Management</h4><p>Manage suppliers and product links</p></div>
                            </a>
                        </div>
                        <div class="module-action">
                            <div class="action-icon">📊</div>
                             <a href="sales_reports.jsp" style="text-decoration: none; color: inherit; display: contents;">
                                <div class="action-text"><h4>Sales Reports</h4><p>View daily, weekly, monthly reports</p></div>
                            </a>
                        </div>
                    </div>
                </div>
                
                                        <div class="module-card">
                            <div class="module-header">Low Stock Alert</div>
                            <div class="module-content">
                                <ul class="low-stock-list">
                                    <%
                                        Connection lowStockConn = null;
                                        PreparedStatement lowStockPstmt = null;
                                        ResultSet lowStockRs = null;
                                        boolean foundLowStockItems = false;
                                        try {
                                            lowStockConn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                                            
                                            // REVISED SQL Query:
                                            // Uses reorder_level if set (>0), otherwise falls back to stock <= 10.
                                            // Ensures stock is also > 0 to avoid listing out-of-stock items as merely "low".
                                            String lowStockSql = "SELECT name, supplier, stock FROM products " +
                                                                 "WHERE stock > 0 AND ( " +
                                                                 "    (reorder_level > 0 AND stock <= reorder_level) OR " +
                                                                 "    (reorder_level = 0 AND stock <= 10) " + // Fallback threshold if reorder_level is 0
                                                                 ") ORDER BY stock ASC LIMIT 5";
                                            
                                            lowStockPstmt = lowStockConn.prepareStatement(lowStockSql);
                                            lowStockRs = lowStockPstmt.executeQuery();
                                            while (lowStockRs.next()) {
                                                foundLowStockItems = true;
                                    %>
                                                <li class="stock-item">
                                                    <div class="stock-info">
                                                        <span class="stock-name"><%= lowStockRs.getString("name") %></span>
                                                        <span class="stock-supplier"><%= lowStockRs.getString("supplier") != null ? lowStockRs.getString("supplier") : "N/A" %></span>
                                                    </div>
                                                    <div class="stock-quantity">
                                                        <%= lowStockRs.getInt("stock") %> units
                                                    </div>
                                                </li>
                                    <%
                                            }
                                            if (!foundLowStockItems) {
                                                out.println("<li class='text-center' style='padding:10px;'>No items currently low on stock.</li>");
                                            }
                                        } catch (Exception e) {
                                            out.println("<li class='text-danger text-center' style='padding:10px;'>Error fetching low stock items: " + e.getMessage() + "</li>");
                                            e.printStackTrace(); 
                                        } finally {
                                            if (lowStockRs != null) try { lowStockRs.close(); } catch (SQLException ex) { /* log error */ }
                                            if (lowStockPstmt != null) try { lowStockPstmt.close(); } catch (SQLException ex) { /* log error */ }
                                            if (lowStockConn != null) try { lowStockConn.close(); } catch (SQLException ex) { /* log error */ }
                                        }
                                    %>
                                </ul>
                            </div>
                        </div>
                <div class="module-card">
                    <div class="module-header">Cashier Performance (Today)</div>
                    <div class="module-content">
                        <div class="sales-header">
                            <div class="sales-title">Sales by Cashier</div>
                            <div class="view-all" onclick="window.location.href='cashier_reports.jsp';">View All</div>
                        </div>
                        <table>
                            <thead>
                                <tr>
                                    <th>Cashier</th>
                                    <th>Sales Today</th>
                                    <th>Sales(Qty)</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <%
                                    Connection cashierPerfConn = null;
                                    PreparedStatement cashierPerfPstmt = null;
                                    ResultSet cashierPerfRs = null;
                                    boolean foundCashierPerf = false;
                                    try {
                                        cashierPerfConn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                                        // This query attempts to use cashier_name_snapshot and find a matching user for status.
                                        // Ideally, pos_sales.cashier_id should be a reliable FK to users.id.
                                        String cashierSql = "SELECT " +
                                                            "    ps.cashier_name_snapshot, " + //
                                                            "    SUM(ps.total_amount) AS sales_today, " + //
                                                            "    COUNT(ps.sale_id) AS transactions_today, " + //
                                                            "    (SELECT u.status FROM users u WHERE u.username = ps.cashier_name_snapshot OR CONCAT(u.first_name, ' ', u.last_name) = ps.cashier_name_snapshot LIMIT 1) AS user_actual_status " + //
                                                            "FROM " +
                                                            "    pos_sales ps " +
                                                            "WHERE " +
                                                            "    DATE(ps.transaction_time) = CURDATE() " + //
                                                            "GROUP BY " +
                                                            "    ps.cashier_name_snapshot " +
                                                            "ORDER BY " +
                                                            "    sales_today DESC " +
                                                            "LIMIT 4";
                                        cashierPerfPstmt = cashierPerfConn.prepareStatement(cashierSql);
                                        cashierPerfRs = cashierPerfPstmt.executeQuery();
                                        while (cashierPerfRs.next()) {
                                            foundCashierPerf = true;
                                            String cashierNameSnapshot = cashierPerfRs.getString("cashier_name_snapshot"); //
                                            String userStatus = cashierPerfRs.getString("user_actual_status"); //
                                            if (userStatus == null) {
                                                userStatus = "N/A"; // Default if no matching user status found
                                            }
                                %>
                                            <tr>
                                                <td><%= cashierNameSnapshot != null ? cashierNameSnapshot : "N/A" %></td>
                                                <td><%= currencyFormatter.format(cashierPerfRs.getDouble("sales_today")) %></td>
                                                <td><%= cashierPerfRs.getInt("transactions_today") %></td>
                                                <td><span class="status <%= userStatus.equalsIgnoreCase("Active") ? "completed" : "pending" %>"><%= userStatus %></span></td>
                                            </tr>
                                <%
                                        }
                                        if (!foundCashierPerf) {
                                             out.println("<tr><td colspan='4' class='text-center'>No cashier sales data for today.</td></tr>");
                                        }
                                    } catch (Exception e) {
                                        out.println("<tr><td colspan='4' class='text-danger text-center'>Error fetching cashier performance: " + e.getMessage() + "</td></tr>");
                                        e.printStackTrace(); // For debugging
                                    } finally {
                                        if (cashierPerfRs != null) try { cashierPerfRs.close(); } catch (SQLException ex) { /* log error */ }
                                        if (cashierPerfPstmt != null) try { cashierPerfPstmt.close(); } catch (SQLException ex) { /* log error */ }
                                        if (cashierPerfConn != null) try { cashierPerfConn.close(); } catch (SQLException ex) { /* log error */ }
                                    }
                                %>
                            </tbody>
                        </table>
                    </div>
                </div>
                </div>
            
            <div class="module-card" style="margin-top: 20px;">
                <div class="module-header">Recent Transactions</div>
                <div class="module-content">
                    <table>
                        <thead>
                            <tr>
                                <th>Order ID</th>
                                <th>Cashier</th>
                                <th>Items</th>
                                <th>Amount</th>
                                <th>Payment</th>
                                <th>Date & Time</th>
                                <th>Status</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                Connection recentSalesConn = null;
                                PreparedStatement recentSalesPstmt = null;
                                ResultSet recentSalesRs = null;
                                boolean foundRecentSales = false;
                                SimpleDateFormat sdf = new SimpleDateFormat("MMM dd, yyyy HH:mm");
                                try {
                                    recentSalesConn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                                    String recentSalesSql = "SELECT ps.receipt_number, ps.cashier_name_snapshot, ps.total_amount, " + //
                                                            "ps.payment_method, ps.transaction_time, " + //
                                                            "(SELECT SUM(psi.quantity_sold) FROM pos_sale_items psi WHERE psi.sale_id = ps.sale_id) AS total_items " + //
                                                            "FROM pos_sales ps " + //
                                                            "ORDER BY ps.transaction_time DESC LIMIT 5"; //
                                    recentSalesPstmt = recentSalesConn.prepareStatement(recentSalesSql);
                                    recentSalesRs = recentSalesPstmt.executeQuery();
                                    while (recentSalesRs.next()) {
                                        foundRecentSales = true;
                            %>
                                        <tr>
                                            <td><%= recentSalesRs.getString("receipt_number") %></td>
                                            <td><%= recentSalesRs.getString("cashier_name_snapshot") != null ? recentSalesRs.getString("cashier_name_snapshot") : "N/A" %></td>
                                            <td><%= recentSalesRs.getInt("total_items") %> items</td>
                                            <td><%= currencyFormatter.format(recentSalesRs.getDouble("total_amount")) %></td>
                                            <td><%= recentSalesRs.getString("payment_method") %></td>
                                            <td><%= sdf.format(recentSalesRs.getTimestamp("transaction_time")) %></td>
                                            <td><span class="status completed">Completed</span></td>
                                        </tr>
                            <%
                                    }
                                    if (!foundRecentSales) {
                                        out.println("<tr><td colspan='7' class='text-center'>No recent transactions found.</td></tr>");
                                    }
                                } catch (Exception e) {
                                    out.println("<tr><td colspan='7' class='text-danger text-center'>Error fetching recent transactions: " + e.getMessage() + "</td></tr>");
                                    e.printStackTrace();
                                } finally {
                                    if (recentSalesRs != null) try { recentSalesRs.close(); } catch (SQLException ex) { /* log */ }
                                    if (recentSalesPstmt != null) try { recentSalesPstmt.close(); } catch (SQLException ex) { /* log */ }
                                    if (recentSalesConn != null) try { recentSalesConn.close(); } catch (SQLException ex) { /* log */ }
                                }
                            %>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div class="footer">
                Swift POS © <%= Year.now().getValue() %>.
            </div>
        </div>
    </div>
    <script>
        const mobileNavToggle = document.getElementById('mobileNavToggle');
        const sidebar = document.getElementById('sidebar');
        if (mobileNavToggle && sidebar) {
            mobileNavToggle.addEventListener('click', () => {
                sidebar.classList.toggle('active');
            });
        }
        document.addEventListener('click', function(event) {
            if (sidebar && sidebar.classList.contains('active') && 
                !sidebar.contains(event.target) && 
                !mobileNavToggle.contains(event.target)) {
                sidebar.classList.remove('active');
            }
        });
    </script>
</body>
</html>