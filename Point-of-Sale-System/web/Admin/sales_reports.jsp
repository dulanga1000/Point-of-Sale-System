<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.time.DayOfWeek" %>
<%@ page import="java.time.temporal.TemporalAdjusters" %>

<%!
// Helper function to close SQL resources
private void closeDbResources(ResultSet rs, Statement stmt, Connection conn) {
    try { if (rs != null) rs.close(); } catch (SQLException e) { e.printStackTrace(); }
    try { if (stmt != null) stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
    try { if (conn != null) conn.close(); } catch (SQLException e) { e.printStackTrace(); }
}

// Helper to format date for SQL
private String formatDateForSQL(LocalDate date) {
    return date.format(DateTimeFormatter.ISO_LOCAL_DATE);
}
%>

<%
// Database connection details
// For MariaDB, consider using driver: org.mariadb.jdbc.Driver
// String DRIVER = "org.mariadb.jdbc.Driver";
String DRIVER = "com.mysql.jdbc.Driver"; // Current driver
String URL = "jdbc:mysql://localhost:3306/swift_database"; // Database: swift_database
String USER = "root";
String PASSWORD = "";

// Initialize filter variables
String reportTypeFilter = request.getParameter("report-type") != null ? request.getParameter("report-type") : "monthly";
String dateRangeFilter = request.getParameter("date-range") != null ? request.getParameter("date-range") : "this-month";
String startDateStr = request.getParameter("start-date");
String endDateStr = request.getParameter("end-date");
String cashierFilter = request.getParameter("cashier") != null ? request.getParameter("cashier") : "all";

LocalDate today = LocalDate.now();
LocalDate startDate, endDate;

// Set default date range if not provided or custom
if (startDateStr == null || startDateStr.isEmpty() || endDateStr == null || endDateStr.isEmpty()) {
    startDate = today.with(TemporalAdjusters.firstDayOfMonth());
    endDate = today.with(TemporalAdjusters.lastDayOfMonth());
    if ("last-month".equals(dateRangeFilter)) {
        startDate = today.minusMonths(1).with(TemporalAdjusters.firstDayOfMonth());
        endDate = today.minusMonths(1).with(TemporalAdjusters.lastDayOfMonth());
    } else if ("last-3-months".equals(dateRangeFilter)) {
        startDate = today.minusMonths(2).with(TemporalAdjusters.firstDayOfMonth());
        endDate = today.with(TemporalAdjusters.lastDayOfMonth());
    }
    startDateStr = formatDateForSQL(startDate);
    endDateStr = formatDateForSQL(endDate);
} else {
    try {
        startDate = LocalDate.parse(startDateStr);
        endDate = LocalDate.parse(endDateStr);
    } catch (Exception e) {
        startDate = today.with(TemporalAdjusters.firstDayOfMonth());
        endDate = today.with(TemporalAdjusters.lastDayOfMonth());
        startDateStr = formatDateForSQL(startDate);
        endDateStr = formatDateForSQL(endDate);
        e.printStackTrace(); // Log parsing error
    }
}

// For SQL, ensure end date includes the whole day for datetime fields
String sqlStartDate = startDateStr + " 00:00:00";
String sqlEndDate = endDateStr + " 23:59:59";

DecimalFormat df = new DecimalFormat("#,##0.00");

// Initialize summary variables
double totalSales = 0;
long totalOrders = 0;
double avgOrderValue = 0;
String bestSellingDay = "N/A";
double bestDaySales = 0;

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

List<String> cashierNames = new ArrayList<>();
try {
    Class.forName(DRIVER);
    conn = DriverManager.getConnection(URL, USER, PASSWORD);

    // Populate Cashier Filter from pos_sales table
    String cashierSql = "SELECT DISTINCT cashier_name_snapshot FROM pos_sales WHERE cashier_name_snapshot IS NOT NULL AND cashier_name_snapshot != '' ORDER BY cashier_name_snapshot"; // Using cashier_name_snapshot from pos_sales
    pstmt = conn.prepareStatement(cashierSql);
    rs = pstmt.executeQuery();
    while (rs.next()) {
        cashierNames.add(rs.getString("cashier_name_snapshot")); // Column: cashier_name_snapshot
    }
    closeDbResources(rs, pstmt, null); // Close only rs and pstmt here

    // Build base WHERE clause for sales queries on pos_sales table
    StringBuilder whereClause = new StringBuilder(" WHERE ps.transaction_time BETWEEN ? AND ? "); // Column: transaction_time
    List<Object> params = new ArrayList<>();
    params.add(sqlStartDate);
    params.add(sqlEndDate);

    if (!"all".equals(cashierFilter) && !cashierFilter.isEmpty()) {
        whereClause.append(" AND ps.cashier_name_snapshot = ? "); // Column: cashier_name_snapshot
        params.add(cashierFilter);
    }

    // --- Calculate Report Summary from pos_sales table ---
    // TOTAL SALES
    String totalSalesSql = "SELECT SUM(ps.total_amount) FROM pos_sales ps" + whereClause.toString(); // Column: total_amount
    pstmt = conn.prepareStatement(totalSalesSql);
    for(int i=0; i<params.size(); i++) pstmt.setObject(i+1, params.get(i));
    rs = pstmt.executeQuery();
    if (rs.next()) totalSales = rs.getDouble(1);
    closeDbResources(rs, pstmt, null);

    // TOTAL ORDERS
    String totalOrdersSql = "SELECT COUNT(ps.sale_id) FROM pos_sales ps" + whereClause.toString(); // Column: sale_id
    pstmt = conn.prepareStatement(totalOrdersSql);
    for(int i=0; i<params.size(); i++) pstmt.setObject(i+1, params.get(i));
    rs = pstmt.executeQuery();
    if (rs.next()) totalOrders = rs.getLong(1);
    closeDbResources(rs, pstmt, null);

    // AVERAGE ORDER VALUE
    if (totalOrders > 0) {
        avgOrderValue = totalSales / totalOrders;
    }
    
    // BEST SELLING DAY
    String bestDaySql = "SELECT DAYNAME(ps.transaction_time) as day_name, SUM(ps.total_amount) as daily_sales " +
                        "FROM pos_sales ps" + whereClause.toString() +
                        "GROUP BY day_name ORDER BY daily_sales DESC LIMIT 1"; // Columns: transaction_time, total_amount
    pstmt = conn.prepareStatement(bestDaySql);
    for(int i=0; i<params.size(); i++) pstmt.setObject(i+1, params.get(i));
    rs = pstmt.executeQuery();
    if (rs.next()) {
        bestSellingDay = rs.getString("day_name");
        bestDaySales = rs.getDouble("daily_sales");
    }
    // Note: No closeDbResources here, let the outer finally block handle conn

} catch (Exception e) {
    out.println("<p class='text-danger text-center'>Error initializing report data: " + e.getMessage() + "</p>"); // Uncommented for user feedback
    e.printStackTrace(); 
} finally {
    closeDbResources(rs, pstmt, conn); // Close all resources from this block
}

// Data for Top Selling Products from pos_sale_items and pos_sales tables
List<Map<String, Object>> topProductsList = new ArrayList<>();
double overallTotalSalesForPercentage = totalSales; 

Connection topProdConn = null;
PreparedStatement topProdPstmt = null;
ResultSet topProdRs = null;
try {
    Class.forName(DRIVER);
    topProdConn = DriverManager.getConnection(URL, USER, PASSWORD);
    StringBuilder topProductsSqlBuilder = new StringBuilder(
        "SELECT psi.product_name_snapshot, SUM(psi.quantity_sold) as total_quantity, SUM(psi.item_total_price) as product_total_sales " + // Columns: product_name_snapshot, quantity_sold, item_total_price
        "FROM pos_sale_items psi " + // Table: pos_sale_items
        "JOIN pos_sales ps ON psi.sale_id = ps.sale_id" // Join pos_sale_items with pos_sales
    );

    List<Object> topProductParams = new ArrayList<>();
    topProductsSqlBuilder.append(" WHERE ps.transaction_time BETWEEN ? AND ? "); // Filter by transaction_time from pos_sales
    topProductParams.add(sqlStartDate);
    topProductParams.add(sqlEndDate);

    if (!"all".equals(cashierFilter) && !cashierFilter.isEmpty()) {
        topProductsSqlBuilder.append(" AND ps.cashier_name_snapshot = ? "); // Filter by cashier_name_snapshot from pos_sales
        topProductParams.add(cashierFilter);
    }

    topProductsSqlBuilder.append("GROUP BY psi.product_id, psi.product_name_snapshot ORDER BY product_total_sales DESC LIMIT 5"); // Group by product_id, product_name_snapshot

    topProdPstmt = topProdConn.prepareStatement(topProductsSqlBuilder.toString());
    for(int i=0; i<topProductParams.size(); i++) topProdPstmt.setObject(i+1, topProductParams.get(i));
    topProdRs = topProdPstmt.executeQuery();

    while (topProdRs.next()) {
        Map<String, Object> product = new HashMap<>();
        product.put("name", topProdRs.getString("product_name_snapshot")); // Column: product_name_snapshot
        product.put("quantity", topProdRs.getInt("total_quantity")); // Alias for SUM(psi.quantity_sold)
        double productSales = topProdRs.getDouble("product_total_sales"); // Alias for SUM(psi.item_total_price)
        product.put("sales", productSales);
        double percentage = (overallTotalSalesForPercentage > 0) ? (productSales / overallTotalSalesForPercentage) * 100 : 0;
        product.put("percentage", df.format(percentage));
        topProductsList.add(product);
    }
} catch (Exception e) {
    out.println("<p class='text-danger text-center'>Error fetching top products: " + e.getMessage() + "</p>"); // Uncommented
    e.printStackTrace();
} finally {
    closeDbResources(topProdRs, topProdPstmt, topProdConn);
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Sales Reports</title>
    <%-- Make sure these paths are correct --%>
    <link rel="stylesheet" href="styles.css"> 
    <style>
    /* --- Your existing CSS --- */
    /* Ensure :root variables are defined in styles.css or here */
    :root {
        --primary: #007bff; 
        --secondary: #6c757d;
    }
    /* Report Filters */
    .report-filters { display: flex; gap: 15px; flex-wrap: wrap; margin-bottom: 20px; padding: 20px; background-color: white; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
    .filter-item { display: flex; flex-direction: column; min-width: 180px; }
    .filter-item label { font-size: 14px; margin-bottom: 5px; color: var(--secondary); }
    .filter-item select, .filter-item input[type="date"] { padding: 8px; border: 1px solid #e2e8f0; border-radius: 4px; box-sizing: border-box; }
    .filter-buttons { display: flex; align-items: flex-end; gap: 10px; margin-top: auto; }
    .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; font-weight: 500; font-size: 14px; }
    .btn-primary { background-color: var(--primary); color: white; }
    .btn-outline { background-color: transparent; border: 1px solid var(--primary); color: var(--primary); }
    /* Report Summary */
    .report-summary { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-bottom: 20px; }
    .summary-card { background-color: white; border-radius: 8px; padding: 15px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); }
    .summary-title { font-size: 14px; color: var(--secondary); margin-bottom: 5px; }
    .summary-value { font-size: 24px; font-weight: 600; }
    .summary-change { font-size: 12px; margin-top: 5px; display: flex; align-items: center; }
    .summary-change.trend.up { color: green; }
    .summary-change.trend.down { color: red; }
    .summary-change svg { margin-right: 4px; }
    /* Chart Container */
    .chart-container { display: grid; grid-template-columns: 2fr 1fr; gap: 20px; margin-bottom: 20px; }
    @media (max-width: 992px) { .chart-container { grid-template-columns: 1fr; } }
    .chart-card { background-color: white; border-radius: 8px; padding: 20px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); height: 100%; display: flex; flex-direction: column; }
    .chart-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 15px; }
    .chart-title { font-size: 16px; font-weight: 600; }
    .chart { height: 300px; width: 100%; position: relative; margin-top: 10px; flex-grow: 1; min-height: 300px; }
    /* Top Products List */
    .top-products { height: 100%; overflow-y: auto; max-height: 300px; } /* Consistent with chart height */
    .product-item { display: flex; align-items: center; padding: 10px 0; border-bottom: 1px solid #f1f5f9; }
    .product-item:last-child { border-bottom: none; }
    .product-info { flex: 1; }
    .product-name { font-weight: 500; margin-bottom: 4px; }
    .product-sales { font-size: 12px; color: var(--secondary); }
    .product-percentage { font-weight: 600; color: var(--primary); margin-left: 10px; }
    /* Report Actions */
    .report-actions { display: flex; justify-content: flex-end; gap: 10px; margin-bottom: 20px; }
    .report-option { display: flex; align-items: center; padding: 5px 10px; background-color: white; border-radius: 4px; border: 1px solid #e2e8f0; font-size: 14px; cursor: pointer; }
    .report-option i { margin-right: 5px; font-size: 16px; }
    /* Module Card for Table */
    .module-card { background-color: white; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); margin-bottom: 20px; }
    .module-header { padding: 15px; font-size: 16px; font-weight: 600; border-bottom: 1px solid #e2e8f0; }
    .module-content { padding: 15px; overflow-x: auto; }
    .module-content table { width: 100%; border-collapse: collapse; }
    .module-content th, .module-content td { padding: 10px; text-align: left; border-bottom: 1px solid #f1f5f9; font-size: 14px; }
    .module-content th { background-color: #f8fafc; font-weight: 600; }
    .module-content tr:last-child td { border-bottom: none; }
    .text-danger { color: red; }
    .text-center { text-align: center; }
    /* Pagination */
    .pagination-container { display: flex; justify-content: center; margin-top: 20px; }
    .pagination-buttons { display: flex; gap: 5px; }
    .pagination-buttons .btn { padding: 5px 10px; }
    .pagination-buttons .btn.active { background-color: var(--primary); color: white; border-color: var(--primary); }

    /* Mobile nav, logo, etc. from your original styles.css or structure */
    .mobile-top-bar { display: none; /* Shown on mobile */ }
    .sidebar { /* Your sidebar styles */ }
    .main-content { /* Your main content styles */ }
    .header { /* Your header styles */ }
    .page-title { /* Your page title styles */ }
    .user-profile { /* Your user profile styles */ }
    .footer { text-align: center; padding: 15px; font-size: 14px; color: var(--secondary); border-top: 1px solid #e2e8f0; margin-top: 20px; }

    @media (max-width: 768px) { /* Example breakpoint */
        .mobile-top-bar { display: flex; justify-content: space-between; align-items: center; padding: 10px; background-color: #fff; box-shadow: 0 2px 4px rgba(0,0,0,0.1); position: fixed; top: 0; left: 0; right: 0; z-index: 1000; }
        .mobile-logo img { height: 30px; }
        .mobile-logo h2 { font-size: 1.2em; margin-left: 5px; }
        .sidebar { position: fixed; /* More styles for mobile sidebar */ transform: translateX(-100%); transition: transform 0.3s ease-in-out; z-index: 999;}
        .sidebar.active { transform: translateX(0); }
        .main-content { margin-top: 60px; /* Adjust if mobile-top-bar is fixed */ }
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
                <h1 class="page-title">Sales Reports</h1>
                <div class="user-profile">
                <%
                    Connection userConn = null;
                    PreparedStatement userPstmt = null;
                    ResultSet userRs = null;
                    try {
                        Class.forName(DRIVER);
                        userConn = DriverManager.getConnection(URL, USER, PASSWORD);
                        // Assuming 'Admin' role exists and has profile info in 'users' table
                        userPstmt = userConn.prepareStatement("SELECT first_name, profile_image_path FROM users WHERE role = 'Admin' LIMIT 1"); // Columns: first_name, profile_image_path
                        userRs = userPstmt.executeQuery();

                        if (userRs.next()) {
                %>
                            <img src="${pageContext.request.contextPath}/<%= userRs.getString("profile_image_path") %>" alt="Admin Profile">
                            <div>
                                <h4><%= userRs.getString("first_name") %></h4>
                            </div>
                <%
                        } else {
                            out.println("Admin user not found.");
                        }
                    } catch (Exception ex) {
                        out.println("<p class='text-danger text-center'>Error loading user: " + ex.getMessage() + "</p>");
                        ex.printStackTrace();
                    } finally {
                        closeDbResources(userRs, userPstmt, userConn);
                    }
                %>
                </div>
            </div>
            
            <form method="GET" action="sales_reports.jsp"> 
                <div class="report-filters">
                    <div class="filter-item">
                        <label for="report-type">Report Type</label>
                        <select id="report-type" name="report-type">
                            <option value="daily" <%= "daily".equals(reportTypeFilter) ? "selected" : "" %>>Daily Sales</option>
                            <option value="weekly" <%= "weekly".equals(reportTypeFilter) ? "selected" : "" %>>Weekly Sales</option>
                            <option value="monthly" <%= "monthly".equals(reportTypeFilter) ? "selected" : "" %>>Monthly Sales</option>
                            <option value="yearly" <%= "yearly".equals(reportTypeFilter) ? "selected" : "" %>>Yearly Sales</option>
                        </select>
                    </div>
                    
                    <div class="filter-item">
                        <label for="date-range">Date Range</label>
                        <select id="date-range" name="date-range">
                            <option value="this-month" <%= "this-month".equals(dateRangeFilter) ? "selected" : "" %>>This Month</option>
                            <option value="last-month" <%= "last-month".equals(dateRangeFilter) ? "selected" : "" %>>Last Month</option>
                            <option value="last-3-months" <%= "last-3-months".equals(dateRangeFilter) ? "selected" : "" %>>Last 3 Months</option>
                            <option value="custom" <%= "custom".equals(dateRangeFilter) ? "selected" : "" %>>Custom Range</option>
                        </select>
                    </div>
                    
                    <div class="filter-item">
                        <label for="start-date">Start Date</label>
                        <input type="date" id="start-date" name="start-date" value="<%= startDateStr %>">
                    </div>
                    
                    <div class="filter-item">
                        <label for="end-date">End Date</label>
                        <input type="date" id="end-date" name="end-date" value="<%= endDateStr %>">
                    </div>
                    
                    <div class="filter-item">
                        <label for="cashier">Cashier</label>
                        <select id="cashier" name="cashier">
                            <option value="all">All Cashiers</option>
                            <% for(String name : cashierNames) { %>
                                <option value="<%= name %>" <%= name.equals(cashierFilter) ? "selected" : "" %>><%= name %></option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="filter-buttons">
                        <button type="submit" class="btn btn-primary">Generate Report</button>
                        <button type="button" class="btn btn-outline" onclick="window.location.href='sales_reports.jsp'">Reset Filters</button>
                    </div>
                </div>
            </form>
\
            
            <div class="report-summary">
                <div class="summary-card">
                    <div class="summary-title">TOTAL SALES</div>
                    <div class="summary-value">Rs.<%= df.format(totalSales) %></div>
                    <div class="summary-change trend up"> 
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="18 15 12 9 6 15"></polyline></svg>
                        N/A% from last period
                    </div>
                </div>
                
                <div class="summary-card">
                    <div class="summary-title">TOTAL ORDERS</div>
                    <div class="summary-value"><%= totalOrders %></div>
                    <div class="summary-change trend up">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="18 15 12 9 6 15"></polyline></svg>
                        N/A% from last period
                    </div>
                </div>
                
                <div class="summary-card">
                    <div class="summary-title">AVERAGE ORDER VALUE</div>
                    <div class="summary-value">Rs.<%= df.format(avgOrderValue) %></div>
                    <div class="summary-change trend down">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                        N/A% from last period
                    </div>
                </div>
                
                <div class="summary-card">
                    <div class="summary-title">BEST SELLING DAY</div>
                    <div class="summary-value"><%= bestSellingDay %></div>
                    <div class="summary-change">Rs.<%= df.format(bestDaySales) %> in sales</div>
                </div>
            </div>
            
            <div class="chart-container">
                <div class="chart-card">
                    <div class="chart-header">
                        <div class="chart-title">Product Categories Sales Distribution</div>
                    </div>
                    <div id="categoryPieChart" class="chart"></div>
                </div>
                
                <div class="chart-card">
                    <div class="chart-header">
                        <div class="chart-title">Top Selling Products</div>
                    </div>
                    <div class="top-products">
                        <% if (topProductsList.isEmpty()) { %>
                            <p style="text-align:center; padding-top:20px;">No top products found for this period.</p>
                        <% } else {
                            for (Map<String, Object> product : topProductsList) { %>
                            <div class="product-item">
                                <div class="product-info">
                                    <div class="product-name"><%= product.get("name") %></div>
                                    <div class="product-sales"><%= product.get("quantity") %> units sold (Rs.<%= df.format(product.get("sales")) %>)</div>
                                </div>
                                <div class="product-percentage"><%= product.get("percentage") %>%</div>
                            </div>
                        <%  }
                            } %>
                    </div>
                </div>
            </div>
            
            <div class="module-card">
                <div class="module-header">Sales Details</div>
                <div class="module-content">
                    <table>
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Receipt No.</th>
                                <th>Cashier</th>
                                <th>Items Sold</th>
                                <th>Payment Method</th>
                                <th>Total (Rs.)</th>
                            </tr>
                        </thead>
                        <tbody>
                        <%
                            Connection detailConn = null;
                            PreparedStatement detailPstmt = null;
                            ResultSet detailRs = null;
                            try {
                                Class.forName(DRIVER);
                                detailConn = DriverManager.getConnection(URL, USER, PASSWORD);
                                StringBuilder detailSql = new StringBuilder(
                                    "SELECT ps.transaction_time, ps.receipt_number, ps.cashier_name_snapshot, " + // Columns from pos_sales
                                    "ps.payment_method, ps.total_amount, " + // Columns from pos_sales
                                    "(SELECT SUM(psi.quantity_sold) FROM pos_sale_items psi WHERE psi.sale_id = ps.sale_id) as items_sold " + // Subquery on pos_sale_items
                                    "FROM pos_sales ps " // Table: pos_sales
                                );
                                detailSql.append(" WHERE ps.transaction_time BETWEEN ? AND ? "); // Filter on transaction_time
                                List<Object> detailParams = new ArrayList<>();
                                detailParams.add(sqlStartDate);
                                detailParams.add(sqlEndDate);

                                if (!"all".equals(cashierFilter) && !cashierFilter.isEmpty()) {
                                    detailSql.append(" AND ps.cashier_name_snapshot = ? "); // Filter on cashier_name_snapshot
                                    detailParams.add(cashierFilter);
                                }
                                detailSql.append(" ORDER BY ps.transaction_time DESC");

                                detailPstmt = detailConn.prepareStatement(detailSql.toString());
                                for(int i=0; i<detailParams.size(); i++) detailPstmt.setObject(i+1, detailParams.get(i));
                                detailRs = detailPstmt.executeQuery();

                                if (!detailRs.isBeforeFirst()) { 
                                    out.println("<tr><td colspan='6' class='text-center'>No sales data found for the selected filters.</td></tr>");
                                } else {
                                    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm");
                                    while (detailRs.next()) {
                        %>
                                        <tr>
                                            <td><%= sdf.format(detailRs.getTimestamp("transaction_time")) %></td>
                                            <td><%= detailRs.getString("receipt_number") %></td>
                                            <td><%= detailRs.getString("cashier_name_snapshot") %></td>
                                            <td><%= detailRs.getInt("items_sold") %></td>
                                            <td><%= detailRs.getString("payment_method") %></td>
                                            <td><%= df.format(detailRs.getDouble("total_amount")) %></td>
                                        </tr>
                        <%
                                    }
                                }
                            } catch (Exception ex) {
                                out.println("<tr><td colspan='6' class='text-danger text-center'>Error loading sales details: " + ex.getMessage() + "</td></tr>");
                                ex.printStackTrace();
                            } finally {
                                closeDbResources(detailRs, detailPstmt, detailConn);
                            }
                        %>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <%-- Basic static pagination, actual functionality would require more logic --%>
            <div class="pagination-container">
                <div class="pagination-buttons">
                    <button class="btn btn-outline">&lt;</button>
                    <button class="btn active">1</button>
                    <button class="btn btn-outline">2</button>
                    <button class="btn btn-outline">3</button>
                    <button class="btn btn-outline">&gt;</button>
                </div>
            </div>
            
            <div class="footer">
                Swift © 2025.
            </div>
        </div>
    </div>
    
    <script>
    // Mobile menu toggle
    document.getElementById('mobileNavToggle').addEventListener('click', function() {
        document.getElementById('sidebar').classList.toggle('active');
    });
    
    // Date range dependent fields
    const dateRangeSelect = document.getElementById('date-range');
    const startDateInput = document.getElementById('start-date');
    const endDateInput = document.getElementById('end-date');
    
    dateRangeSelect.addEventListener('change', function() {
        const today = new Date();
        let start = new Date(today); 
        let end = new Date(today);   
        
        switch(this.value) {
            case 'this-month':
                start = new Date(today.getFullYear(), today.getMonth(), 1);
                end = new Date(today.getFullYear(), today.getMonth() + 1, 0);
                break;
            case 'last-month':
                start = new Date(today.getFullYear(), today.getMonth() - 1, 1);
                end = new Date(today.getFullYear(), today.getMonth(), 0);
                break;
            case 'last-3-months':
                start = new Date(today.getFullYear(), today.getMonth() - 2, 1); 
                end = new Date(today.getFullYear(), today.getMonth() + 1, 0); 
                break;
            case 'custom':
                // Enable date inputs if they were disabled, or simply allow manual input
                startDateInput.disabled = false;
                endDateInput.disabled = false;
                return; // Do not overwrite custom dates
        }
        startDateInput.value = formatDate(start);
        endDateInput.value = formatDate(end);
        // Optionally disable date inputs if a predefined range is selected
        // startDateInput.disabled = (this.value !== 'custom');
        // endDateInput.disabled = (this.value !== 'custom');
    });
    
    function formatDate(date) {
        const year = date.getFullYear();
        const month = String(date.getMonth() + 1).padStart(2, '0');
        const day = String(date.getDate()).padStart(2, '0');
        return `${year}-${month}-${day}`;
    }

    // Initialize date fields based on current selection (if not custom)
    // This ensures that if the page reloads with a non-custom range, the dates are set correctly
    // However, your JSP logic already sets startDateStr and endDateStr, so this might be redundant 
    // unless you want the JS to override JSP-set dates for non-custom on load.
    // if (dateRangeSelect.value !== 'custom') {
    //    dateRangeSelect.dispatchEvent(new Event('change'));
    // }


    // Load the Visualization API and the corechart package
    google.charts.load('current', {'packages':['corechart']});
    google.charts.setOnLoadCallback(drawCategoryChart);
    
    function drawCategoryChart() {
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Category');
        data.addColumn('number', 'Sales');
        
        <%
        Connection chartConn = null;
        PreparedStatement chartPstmt = null;
        ResultSet chartRs = null;
        try {
            Class.forName(DRIVER);
            chartConn = DriverManager.getConnection(URL, USER, PASSWORD);
            StringBuilder chartSql = new StringBuilder(
                "SELECT p.category, SUM(psi.item_total_price) as category_sales " + // Columns: p.category, psi.item_total_price
                "FROM pos_sale_items psi " + // Table: pos_sale_items
                "JOIN products p ON psi.product_id = p.id " + // Join with products table on product_id
                "JOIN pos_sales ps ON psi.sale_id = ps.sale_id" // Join with pos_sales table on sale_id
            );
            chartSql.append(" WHERE ps.transaction_time BETWEEN ? AND ? "); // Filter on transaction_time
            List<Object> chartParams = new ArrayList<>();
            chartParams.add(sqlStartDate); // from JSP scriptlet
            chartParams.add(sqlEndDate);   // from JSP scriptlet

            if (!"all".equals(cashierFilter) && !cashierFilter.isEmpty()) { // cashierFilter from JSP scriptlet
                chartSql.append(" AND ps.cashier_name_snapshot = ? "); // Filter on cashier_name_snapshot
                chartParams.add(cashierFilter);
            }
            chartSql.append(" GROUP BY p.category HAVING SUM(psi.item_total_price) > 0 ORDER BY category_sales DESC"); // Group by product category

            chartPstmt = chartConn.prepareStatement(chartSql.toString());
            for(int i=0; i<chartParams.size(); i++) chartPstmt.setObject(i+1, chartParams.get(i));
            chartRs = chartPstmt.executeQuery();
            
            boolean hasChartData = false;
            while(chartRs.next()) {
                hasChartData = true;
                String category = chartRs.getString("category"); // Column: category from products table
                category = category != null ? category.replace("'", "\\'") : "Unknown"; // Basic sanitization for JS string
        %>
                data.addRow(['<%= category %>', <%= chartRs.getDouble("category_sales") %>]);
        <%
            }
            if (!hasChartData) {
                %> data.addRow(['No Data Available', 0]); <% // Use 0 for no data, not 1
            }
        } catch(Exception e) {
            System.err.println("Error fetching chart data: " + e.getMessage());
            e.printStackTrace();
            // Fallback data if database fails
            %>
            data.addRow(['Error Loading Data', 0]);
            <%
        } finally {
            // Resources should be closed by the helper method.
            // Ensure proper resource management for chartConn, chartPstmt, chartRs if not using the helper method directly in this scope
            try { if (chartRs != null) chartRs.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (chartPstmt != null) chartPstmt.close(); } catch (SQLException e) { e.printStackTrace(); }
            try { if (chartConn != null) chartConn.close(); } catch (SQLException e) { e.printStackTrace(); }
        }
        %>
        
        var options = {
            pieHole: 0.4,
            pieSliceText: 'percentage',
            chartArea: { width: '90%', height: '80%', left: "5%", top: "5%", right:"5%", bottom:"10%"},
            legend: { position: 'right', alignment: 'center', textStyle: { fontSize: 12 } },
            titleTextStyle: { fontSize: 16, bold: true },
            colors: ['#4285F4', '#EA4335', '#FBBC05', '#34A853', '#673AB7', '#FF9800', '#795548'],
            tooltip: { showColorCode: true, textStyle: { fontSize: 12 }, trigger: 'focus' },
            fontSize: 12,
            sliceVisibilityThreshold: .01 
        };
        
        try {
            var chart = new google.visualization.PieChart(document.getElementById('categoryPieChart'));
            chart.draw(data, options);
            
            window.addEventListener('resize', function() { chart.draw(data, options); });
        } catch (e) {
            console.error("Error drawing chart: ", e);
            document.getElementById('categoryPieChart').innerHTML = 
                '<div style="color:red;padding:20px;text-align:center;">Chart failed to load. Check console for errors.</div>';
        }
    }
    </script>
</body>
</html>