<%--
    Document   : Cashi_report
    Created on : May 18, 2025 (Adjusted for current context)
    Author     : NGC (Modified by AI)
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.YearMonth" %>
<%@ page import="java.time.ZoneId" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%!
    // Helper function to safely close resources
    private void closeQuietly(AutoCloseable resource) {
        if (resource != null) {
            try {
                resource.close();
            } catch (Exception e) {
                // Log or ignore
            }
        }
    }

    // Helper to format date for SQL
    private String formatDateForSQL(LocalDate date) {
        return date.format(DateTimeFormatter.ISO_LOCAL_DATE);
    }
%>

<%
    // --- Database Connection Details ---
    String DB_URL = "jdbc:mysql://localhost:3306/swift_database?useSSL=false&allowPublicKeyRetrieval=true";
    String DB_USER = "root";
    String DB_PASSWORD = ""; // Replace with your actual password if set
    String JDBC_DRIVER = "com.mysql.cj.jdbc.Driver";

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // --- Filter Handling ---
    String reportTypeFilter = request.getParameter("reportType") != null ? request.getParameter("reportType") : "monthly";
    String dateRangeFilter = request.getParameter("dateRange") != null ? request.getParameter("dateRange") : "this-month";
    String startDateFilter = request.getParameter("startDate");
    String endDateFilter = request.getParameter("endDate");
    String cashierIdFilter = request.getParameter("cashierId") != null ? request.getParameter("cashierId") : "all";

    LocalDate today = LocalDate.now(ZoneId.of("Asia/Colombo")); // Assuming Sri Lanka timezone for date context

    if (startDateFilter == null || endDateFilter == null || startDateFilter.isEmpty() || endDateFilter.isEmpty() || !dateRangeFilter.equals("custom")) {
        switch (dateRangeFilter) {
            case "this-month":
                startDateFilter = formatDateForSQL(today.withDayOfMonth(1));
                endDateFilter = formatDateForSQL(today.withDayOfMonth(today.lengthOfMonth()));
                break;
            case "last-month":
                LocalDate lastMonth = today.minusMonths(1);
                startDateFilter = formatDateForSQL(lastMonth.withDayOfMonth(1));
                endDateFilter = formatDateForSQL(lastMonth.withDayOfMonth(lastMonth.lengthOfMonth()));
                break;
            case "last-3-months":
                startDateFilter = formatDateForSQL(today.minusMonths(2).withDayOfMonth(1)); // Start of 3 months ago
                endDateFilter = formatDateForSQL(today.withDayOfMonth(today.lengthOfMonth())); // End of current month
                break;
            default: // Default to this month
                startDateFilter = formatDateForSQL(today.withDayOfMonth(1));
                endDateFilter = formatDateForSQL(today.withDayOfMonth(today.lengthOfMonth()));
                break;
        }
    }
    
    // For SQL BETWEEN, end date should be end of day
    String sqlStartDate = startDateFilter + " 00:00:00";
    String sqlEndDate = endDateFilter + " 23:59:59";

    DecimalFormat df = new DecimalFormat("#,##0.00");
    DecimalFormat countDf = new DecimalFormat("#,##0");

    // --- Data for Summary Cards ---
    double totalSales = 0;
    long totalOrders = 0;
    double avgOrderValue = 0;
    String bestSellingDay = "N/A";
    double bestSellingDaySales = 0;

    // --- Data for Charts ---
    List<Map<String, Object>> categoryData = new ArrayList<>();
    List<Map<String, Object>> topProductsData = new ArrayList<>();

    // --- Data for Sales Details Table ---
    List<Map<String, Object>> salesDetails = new ArrayList<>();

    // --- Data for Cashier Dropdown ---
    Map<String, String> cashiers = new LinkedHashMap<>();
    cashiers.put("all", "All Cashiers");

    try {
        Class.forName(JDBC_DRIVER);
        conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

        // Populate Cashier Dropdown
        pstmt = conn.prepareStatement("SELECT id, first_name, last_name FROM users WHERE role = 'Cashier' ORDER BY first_name, last_name");
        rs = pstmt.executeQuery();
        while (rs.next()) {
            cashiers.put(rs.getString("id"), rs.getString("first_name") + " " + rs.getString("last_name"));
        }
        closeQuietly(rs);
        closeQuietly(pstmt);


        // Build WHERE clause parts
        StringBuilder whereClause = new StringBuilder(" WHERE transaction_time BETWEEN ? AND ? ");
        List<Object> params = new ArrayList<>();
        params.add(sqlStartDate);
        params.add(sqlEndDate);

        if (!"all".equals(cashierIdFilter)) {
            whereClause.append(" AND cashier_id = ? ");
            params.add(Integer.parseInt(cashierIdFilter));
        }
        
        // --- Fetch Summary Card Data ---
        String summarySql = "SELECT SUM(total_amount) as total_sales, COUNT(sale_id) as total_orders FROM pos_sales" + whereClause.toString();
        pstmt = conn.prepareStatement(summarySql);
        for(int i=0; i<params.size(); i++) pstmt.setObject(i+1, params.get(i));
        rs = pstmt.executeQuery();
        if (rs.next()) {
            totalSales = rs.getDouble("total_sales");
            totalOrders = rs.getLong("total_orders");
        }
        if (totalOrders > 0) {
            avgOrderValue = totalSales / totalOrders;
        }
        closeQuietly(rs);
        closeQuietly(pstmt);

        // Best Selling Day
        String dayOfWeekSql = "SELECT DAYNAME(transaction_time) as day_name, SUM(total_amount) as daily_sales " +
                              "FROM pos_sales " + whereClause.toString() +
                              "GROUP BY day_name ORDER BY daily_sales DESC LIMIT 1";
        pstmt = conn.prepareStatement(dayOfWeekSql);
        for(int i=0; i<params.size(); i++) pstmt.setObject(i+1, params.get(i));
        rs = pstmt.executeQuery();
        if (rs.next()) {
            bestSellingDay = rs.getString("day_name");
            bestSellingDaySales = rs.getDouble("daily_sales");
        }
        closeQuietly(rs);
        closeQuietly(pstmt);


        // --- Fetch Product Categories Distribution Data (Affected by product table, not directly by sales filters unless joining) ---
        // This query is for overall product categories, not tied to sales period for simplicity here.
        // If it needs to be tied to sales, it would require joining products -> pos_sale_items -> pos_sales and applying filters.
        pstmt = conn.prepareStatement("SELECT p.category, COUNT(psi.sale_item_id) as count " +
                                      "FROM products p " +
                                      "JOIN pos_sale_items psi ON p.id = psi.product_id " +
                                      "JOIN pos_sales ps ON psi.sale_id = ps.sale_id " + whereClause.toString() +
                                      "GROUP BY p.category HAVING COUNT(psi.sale_item_id) > 0 ORDER BY count DESC");
        for(int i=0; i<params.size(); i++) pstmt.setObject(i+1, params.get(i));
        rs = pstmt.executeQuery();
        while (rs.next()) {
            Map<String, Object> row = new HashMap<>();
            row.put("category", rs.getString("category"));
            row.put("count", rs.getInt("count"));
            categoryData.add(row);
        }
        closeQuietly(rs);
        closeQuietly(pstmt);

        // --- Fetch Top Selling Products Data ---
        String topProductsSql = "SELECT p.name as product_name, SUM(psi.quantity_sold) as total_quantity_sold " +
                                "FROM pos_sale_items psi " +
                                "JOIN products p ON psi.product_id = p.id " +
                                "JOIN pos_sales ps ON psi.sale_id = ps.sale_id " + whereClause.toString() +
                                "GROUP BY p.id, p.name ORDER BY total_quantity_sold DESC LIMIT 6";
        pstmt = conn.prepareStatement(topProductsSql);
        for(int i=0; i<params.size(); i++) pstmt.setObject(i+1, params.get(i));
        rs = pstmt.executeQuery();
        long totalQuantityAllProducts = 0; // For percentage calculation if needed
        List<Map<String, Object>> tempTopProducts = new ArrayList<>();
        while(rs.next()){
            Map<String, Object> product = new HashMap<>();
            product.put("name", rs.getString("product_name"));
            product.put("quantity", rs.getInt("total_quantity_sold"));
            tempTopProducts.add(product);
            totalQuantityAllProducts += rs.getInt("total_quantity_sold");
        }
        // Calculate percentage (optional, keeping it simple with just quantity for now)
        for(Map<String, Object> product : tempTopProducts) {
            // double percentage = (totalQuantityAllProducts > 0) ? ((Integer)product.get("quantity") * 100.0 / totalQuantityAllProducts) : 0;
            // product.put("percentage", df.format(percentage) + "%");
             topProductsData.add(product);
        }
        closeQuietly(rs);
        closeQuietly(pstmt);


        // --- Fetch Sales Details Data ---
        // Using pos_sales for more detailed cashier-specific report
        String salesDetailsSql = "SELECT ps.transaction_time, ps.receipt_number, ps.cashier_name_snapshot, " +
                                 "(SELECT SUM(psi.quantity_sold) FROM pos_sale_items psi WHERE psi.sale_id = ps.sale_id) as items_count, " +
                                 "ps.payment_method, ps.total_amount " +
                                 "FROM pos_sales ps " + whereClause.toString() +
                                 "ORDER BY ps.transaction_time DESC";
        pstmt = conn.prepareStatement(salesDetailsSql);
        for(int i=0; i<params.size(); i++) pstmt.setObject(i+1, params.get(i));
        rs = pstmt.executeQuery();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        while (rs.next()) {
            Map<String, Object> row = new HashMap<>();
            Timestamp tt = rs.getTimestamp("transaction_time");
            row.put("date", sdf.format(tt));
            row.put("order_id", rs.getString("receipt_number"));
            row.put("cashier_name", rs.getString("cashier_name_snapshot"));
            row.put("items", rs.getInt("items_count"));
            row.put("payment_method", rs.getString("payment_method"));
            row.put("total", rs.getDouble("total_amount"));
            salesDetails.add(row);
        }
        closeQuietly(rs);
        closeQuietly(pstmt);

    } catch (SQLException se) {
        // Handle errors for JDBC
        out.println("<p style='color:red;'>Database Error: " + se.getMessage() + "</p>");
        se.printStackTrace();
    } catch (Exception e) {
        // Handle errors for Class.forName
        out.println("<p style='color:red;'>Error: " + e.getMessage() + "</p>");
        e.printStackTrace();
    } finally {
        // finally block used to close resources
        closeQuietly(rs);
        closeQuietly(pstmt);
        closeQuietly(conn);
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cashier Sales Report</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <%-- Ensure styles.css is in the correct path relative to this JSP or use context path --%>
    <link rel="stylesheet" href="styles.css">
    <style>
            .report-filters {
      display: flex;
      gap: 15px;
      flex-wrap: wrap;
      margin-bottom: 20px;
      padding: 20px;
      background-color: white;
      border-radius: 8px;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
    }
    
    .filter-item {
      display: flex;
      flex-direction: column;
      min-width: 200px;
    }
    
    .filter-item label {
      font-size: 14px;
      margin-bottom: 5px;
      color: var(--secondary);
    }
    
    .filter-item select,
    .filter-item input {
      padding: 8px;
      border: 1px solid #e2e8f0;
      border-radius: 4px;
    }
    
    .filter-buttons {
      display: flex;
      align-items: flex-end;
      gap: 10px;
    }
    
    .btn {
      padding: 8px 16px;
      border: none;
      border-radius: 4px;
      cursor: pointer;
      font-weight: 500;
    }
    
    .btn-primary {
      background-color: var(--primary);
      color: white;
    }
    
    .btn-outline {
      background-color: transparent;
      border: 1px solid var(--primary);
      color: var(--primary);
    }
    
    .report-summary {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 15px;
      margin-bottom: 20px;
    }
    
    .summary-card {
      background-color: white;
      border-radius: 8px;
      padding: 15px;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
    }
    
    .summary-title {
      font-size: 14px;
      color: var(--secondary);
      margin-bottom: 5px;
    }
    
    .summary-value {
      font-size: 24px;
      font-weight: 600;
    }
    
    .summary-change {
      font-size: 12px;
      margin-top: 5px;
    }
    
    .chart-container {
      display: grid;
      grid-template-columns: 2fr 1fr;
      gap: 20px;
      margin-bottom: 20px;
    }
    
    @media (max-width: 992px) {
      .chart-container {
        grid-template-columns: 1fr;
      }
    }
    
    .chart-card {
      background-color: white;
      border-radius: 8px;
      padding: 20px;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
    }
    
    .chart-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 15px;
    }
    
    .chart-title {
      font-size: 16px;
      font-weight: 600;
    }
    
    .chart-filters {
      display: flex;
      gap: 10px;
    }
    
    .chart-filter {
      background-color: #f1f5f9;
      border: none;
      padding: 5px 10px;
      border-radius: 4px;
      font-size: 12px;
      cursor: pointer;
    }
    
    .chart-filter.active {
      background-color: var(--primary);
      color: white;
    }
    
    .chart {
      height: 300px;
      width: 100%;
      position: relative;
      margin-top: 10px;
    }
    
    .chart-placeholder {
      width: 100%;
      height: 100%;
      background-color: #f8fafc;
      border-radius: 4px;
      display: flex;
      align-items: center;
      justify-content: center;
      color: var(--secondary);
    }
    
    .top-products {
      height: 100%;
      overflow-y: auto;
    }
    
    .product-item {
      display: flex;
      align-items: center;
      padding: 10px 0;
      border-bottom: 1px solid #f1f5f9;
    }
    
    .product-info {
      flex: 1;
    }
    
    .product-name {
      font-weight: 500;
      margin-bottom: 4px;
    }
    
    .product-sales {
      font-size: 12px;
      color: var(--secondary);
    }
    
    .product-percentage {
      font-weight: 600;
      color: var(--primary);
    }
    
    .report-actions {
      display: flex;
      justify-content: flex-end;
      gap: 10px;
      margin-bottom: 20px;
    }
    
    .report-option {
      display: flex;
      align-items: center;
      padding: 5px 10px;
      background-color: white;
      border-radius: 4px;
      border: 1px solid #e2e8f0;
      font-size: 14px;
      cursor: pointer;
    }
    
    .report-option i {
      margin-right: 5px;
      font-size: 16px;
    }
    
     /* card-chart */
        /* Chart container styles */
.chart-card {
    background-color: white;
    border-radius: 8px;
    padding: 20px;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
    height: 100%;
    display: flex;
    flex-direction: column;
}

.chart-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 15px;
}

.chart-title {
    font-size: 16px;
    font-weight: 600;
    color: #333;
}

.chart {
    width: 100%;
    height: 300px;
    min-height: 300px;
    flex-grow: 1;
}

/* Responsive adjustments */
@media (max-width: 768px) {
    .chart {
        height: 250px;
    }
}

/*
         * Styles for the "Sales Details" table module to match image_9545ee.png
         */

        /* Card container for the Sales Details table */
        .module-card { /* Ensure this general style applies or is overridden if needed for other cards */
            background-color: #fff;
            border-radius: 8px;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.07); /* Subtle shadow as in image */
            margin-bottom: 25px;
            padding: 20px; /* Padding inside the card, around the content */
        }

        /* Header of the Sales Details card (blue bar) */
        .module-card .module-header {
            background-color: #0d6efd; /* Bright blue from image - similar to Bootstrap primary */
            color: white;
            padding: 0.9rem 1.25rem;   /* Padding for the header text */
            font-size: 1.1em;
            font-weight: 600;
            /* The following lines make the header span the card's width, accounting for the card's padding */
            margin-left: -20px;   /* Negative margin equal to card's left padding */
            margin-right: -20px;  /* Negative margin equal to card's right padding */
            margin-top: -20px;    /* Negative margin equal to card's top padding */
            margin-bottom: 20px;  /* Space between this header and the table content */
            border-top-left-radius: 8px;  /* Match card's border radius */
            border-top-right-radius: 8px; /* Match card's border radius */
        }

        /* Styling for the table within the module content */
        .module-card .module-content table {
            width: 100%;
            border-collapse: collapse; /* Remove double borders */
            font-size: 0.9em;
        }

        /* Table Header (thead) styling */
        .module-card .module-content thead tr {
            background-color: #f8f9fa; /* Very light grey background for table header */
        }

        .module-card .module-content th {
            color: #495057; /* Darker grey text for table header cells */
            font-weight: 600; /* Bold header text */
            padding: 0.75rem 1rem; /* Padding for header cells */
            text-align: left;
            border-bottom: 2px solid #dee2e6; /* Slightly thicker border below header */
        }

        /* Table Body (tbody) cell styling */
        .module-card .module-content td {
            padding: 0.75rem 1rem; /* Padding for data cells */
            text-align: left;
            color: #495057; /* Text color for data cells */
            border-bottom: 1px solid #e9ecef; /* Light grey border for separating rows */
        }

        /* Remove bottom border from the last row in the table body */
        .module-card .module-content tbody tr:last-child td {
            border-bottom: none;
        }

        /* Optional: Add a subtle hover effect for table rows in the body */
        .module-card .module-content tbody tr:hover {
            background-color: #f1f3f5; /* Slightly darker hover */
        }
        
        
        /*
         * Styles for the Main Header to match Screenshot 2025-05-18 221315.png
         */

        .header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 1rem 1.5rem;       /* Vertical and horizontal padding */
            background-color: #f8f9fa;  /* Very light grey background, almost white like the image */
            /* border-bottom: 1px solid #e9ecef; */ /* Optional: subtle bottom border if needed */
            margin-bottom: 25px;        /* Space below the header */
            /* border-radius: 8px; */  /* Optional: if you want rounded corners matching other cards. Image is not clear on this. */
        }

        .header .page-title {
            margin: 0;
            font-size: 1.6em;         /* Prominent title size */
            color: #212529;           /* Dark, standard text color */
            font-weight: 600;         /* Semi-bold */
        }

        .header .user-profile {
            display: flex;
            align-items: center;
        }

        .header .user-profile img { /* Styling for the Swift bird logo */
            width: 28px;              /* Adjust size as needed */
            height: auto;             /* Maintain aspect ratio */
            margin-right: 10px;       /* Space between logo and text */
            /* No border-radius if it's an icon/logo like the bird */
        }

        .header .user-profile div { /* Container for name and role */
            line-height: 1.3;         /* Adjust line height for tighter spacing */
            text-align: right;        /* Align text to the right if logo is on left of this block */
        }

        .header .user-profile h4 { /* For "John Doe" */
            margin: 0;
            font-size: 0.95em;        /* Standard name size */
            color: #212529;           /* Dark text color */
            font-weight: 600;         /* Semi-bold */
        }

        .header .user-profile span { /* For "Cashier" */
            margin: 0;
            font-size: 0.8em;         /* Smaller text for role */
            color: #6c757d;           /* Grey color for role */
            display: block;           /* Ensure it's on its own line if needed */
        }
    </style>
</head>
<body>
    <div class="mobile-top-bar">
        <div class="mobile-logo">
            <img src="<%= request.getContextPath() %>/Images/logo.png" alt="POS Logo" class="logo-img">
            <h2>Swift</h2>
        </div>
        <button class="mobile-nav-toggle" id="mobileNavToggle">
            <i class="fas fa-bars"></i>
        </button>
    </div>

    <div class="dashboard">
        <div class="sidebar" id="sidebar">
            <div class="logo">
                <img src="<%= request.getContextPath() %>/Images/logo.png" alt="POS Logo" class="logo-img">
                <h2>Swift</h2>
            </div>
            <jsp:include page="menu.jsp" />
        </div>

        <div class="main-content">
            <div class="header">
                <h1 class="page-title">Cashier Sales Reports</h1>
                <div class="user-profile">
                    <%
                        Connection userConnHeader = null;
                        PreparedStatement userPstmtHeader = null;
                        ResultSet userRsHeader = null;
                        try {
                            Class.forName(JDBC_DRIVER);
                            userConnHeader = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                            // Fetching a generic Admin/Cashier for display, assuming no specific session user here
                            userPstmtHeader = userConnHeader.prepareStatement("SELECT first_name, last_name, role, profile_image_path FROM users WHERE role IN ('Admin', 'Cashier') ORDER BY id DESC LIMIT 1");
                            userRsHeader = userPstmtHeader.executeQuery();
                            if (userRsHeader.next()) {
                                String profileImagePath = userRsHeader.getString("profile_image_path");
                                String defaultImagePath = request.getContextPath() + "/Images/default-avatar.png"; // Provide a default avatar
                                String imageToDisplay = (profileImagePath != null && !profileImagePath.trim().isEmpty()) ? 
                                                        request.getContextPath() + "/" + profileImagePath.replace("\\", "/") : defaultImagePath;
                    %>
                        <img src="<%= imageToDisplay %>" alt="User" class="profile-avatar">
                        <div class="user-info">
                            <h4><%= userRsHeader.getString("first_name") %> <%= userRsHeader.getString("last_name") %></h4>
                            <span><%= userRsHeader.getString("role") %></span>
                        </div>
                    <%
                            } else {
                    %>
                        <img src="<%= request.getContextPath() %>/Images/default-avatar.png" alt="User" class="profile-avatar">
                        <div class="user-info">
                             <h4>Guest User</h4>
                             <span>Cashier</span>
                        </div>
                    <%
                            }
                        } catch (Exception ex) {
                            out.println("<p style='color: red; font-size:0.8em;'>Profile Error</p>");
                            // ex.printStackTrace(new java.io.PrintWriter(out)); // For debugging
                        } finally {
                            closeQuietly(userRsHeader);
                            closeQuietly(userPstmtHeader);
                            closeQuietly(userConnHeader);
                        }
                    %>
                </div>
            </div>
            
            <form method="GET" action="Cashi_report.jsp">
                <div class="report-filters">
                    <div class="filter-item">
                        <label for="report-type">Report Type</label>
                        <select id="report-type" name="reportType" disabled> <%-- Disabled as not fully implemented for different data views yet --%>
                            <option value="daily" <%= "daily".equals(reportTypeFilter) ? "selected" : "" %>>Daily Sales</option>
                            <option value="weekly" <%= "weekly".equals(reportTypeFilter) ? "selected" : "" %>>Weekly Sales</option>
                            <option value="monthly" <%= "monthly".equals(reportTypeFilter) ? "selected" : "" %>>Monthly Sales</option>
                            <option value="yearly" <%= "yearly".equals(reportTypeFilter) ? "selected" : "" %>>Yearly Sales</option>
                        </select>
                    </div>
                    
                    <div class="filter-item">
                        <label for="date-range">Date Range</label>
                        <select id="date-range" name="dateRange">
                            <option value="this-month" <%= "this-month".equals(dateRangeFilter) ? "selected" : "" %>>This Month</option>
                            <option value="last-month" <%= "last-month".equals(dateRangeFilter) ? "selected" : "" %>>Last Month</option>
                            <option value="last-3-months" <%= "last-3-months".equals(dateRangeFilter) ? "selected" : "" %>>Last 3 Months</option>
                            <option value="custom" <%= "custom".equals(dateRangeFilter) ? "selected" : "" %>>Custom Range</option>
                        </select>
                    </div>
                    
                    <div class="filter-item">
                        <label for="start-date">Start Date</label>
                        <input type="date" id="start-date" name="startDate" value="<%= startDateFilter != null ? startDateFilter : "" %>">
                    </div>
                    
                    <div class="filter-item">
                        <label for="end-date">End Date</label>
                        <input type="date" id="end-date" name="endDate" value="<%= endDateFilter != null ? endDateFilter : "" %>">
                    </div>
                    
                    <div class="filter-item">
                        <label for="cashierId">Cashier</label>
                        <select id="cashierId" name="cashierId">
                            <% for (Map.Entry<String, String> entry : cashiers.entrySet()) { %>
                                <option value="<%= entry.getKey() %>" <%= entry.getKey().equals(cashierIdFilter) ? "selected" : "" %>>
                                    <%= entry.getValue() %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                    
                    <div class="filter-buttons">
                        <button type="submit" class="btn btn-primary">Generate Report</button>
                        <button type="button" class="btn btn-outline" onclick="window.location.href='Cashi_report.jsp'">Reset Filters</button>
                    </div>
                </div>
            </form>
            
        

            <div class="report-summary">
                <div class="summary-card">
                    <div class="summary-title">TOTAL SALES</div>
                    <div class="summary-value">Rs.<%= df.format(totalSales) %></div>
                    <%-- <div class="summary-change trend up"> <svg>...</svg> 8.2% from last month </div> --%>
                </div>
                <div class="summary-card">
                    <div class="summary-title">TOTAL ORDERS</div>
                    <div class="summary-value"><%= countDf.format(totalOrders) %></div>
                    <%-- <div class="summary-change trend up"> <svg>...</svg> 12.4% from last month </div> --%>
                </div>
                <div class="summary-card">
                    <div class="summary-title">AVERAGE ORDER VALUE</div>
                    <div class="summary-value">Rs.<%= df.format(avgOrderValue) %></div>
                     <%-- <div class="summary-change trend down"> <svg>...</svg> 3.8% from last month </div> --%>
                </div>
                <div class="summary-card">
                    <div class="summary-title">BEST SELLING DAY (Period)</div>
                    <div class="summary-value"><%= bestSellingDay != null ? bestSellingDay : "N/A" %></div>
                    <div class="summary-change"><%= bestSellingDay != null ? ("Rs." + df.format(bestSellingDaySales) + " in sales") : "" %></div>
                </div>
            </div>

            <div class="chart-container">
                <div class="chart-card">
                    <div class="chart-header">
                        <div class="chart-title">Product Categories Distribution (Sales Based)</div>
                    </div>
                    <div id="categoryPieChart" class="chart">
                        <% if (categoryData.isEmpty()) { %>
                            <p style="text-align:center; padding-top:50px; color:#6c757d;">No category data available for the selected period.</p>
                        <% } %>
                    </div>
                </div>
                
                <div class="chart-card">
                    <div class="chart-header">
                        <div class="chart-title">Top Selling Products (by Quantity)</div>
                    </div>
                    <div class="top-products">
                        <% if (topProductsData.isEmpty()) { %>
                            <p style="text-align:center; padding-top:50px; color:#6c757d;">No top products found for the selected period.</p>
                        <% } else {
                            for (Map<String, Object> product : topProductsData) { %>
                                <div class="product-item">
                                    <div class="product-info">
                                        <div class="product-name"><%= product.get("name") %></div>
                                        <div class="product-sales"><%= product.get("quantity") %> units sold</div>
                                    </div>
                                    <%-- <div class="product-percentage"><%= product.get("percentage") != null ? product.get("percentage") : "" %></div> --%>
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
                                <th>Date & Time</th>
                                <th>Receipt No.</th>
                                <th>Cashier</th>
                                <th>Items Sold</th>
                                <th>Payment Method</th>
                                <th>Total (Rs.)</th>
                            </tr>
                        </thead>
                        <tbody>
                        <% if (salesDetails.isEmpty()) { %>
                            <tr><td colspan="6" style="text-align:center;">No sales data found for the selected filters.</td></tr>
                        <% } else {
                                for (Map<String, Object> sale : salesDetails) { %>
                                <tr>
                                    <td><%= sale.get("date") %></td>
                                    <td><%= sale.get("order_id") %></td>
                                    <td><%= sale.get("cashier_name") %></td>
                                    <td><%= sale.get("items") %></td>
                                    <td><%= sale.get("payment_method") %></td>
                                    <td><%= df.format(sale.get("total")) %></td>
                                </tr>
                        <%    }
                           } %>
                        </tbody>
                    </table>
                </div>
            </div>
            
            <div style="display: flex; justify-content: center; margin-top: 20px;">
                <div style="display: flex; gap: 5px;">
                    <button class="btn btn-outline" style="padding: 5px 10px;">&lt;</button>
                    <button class="btn" style="padding: 5px 12px; background-color: var(--primary); color: white;">1</button>
                    <button class="btn btn-outline" style="padding: 5px 12px;">2</button>
                    <button class="btn btn-outline" style="padding: 5px 10px;">&gt;</button>
                </div>
            </div>
            
            <div class="footer">
                Swift POS © <%= YearMonth.now().getYear() %>.
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
        
        function formatDateForInput(date) {
            const year = date.getFullYear();
            const month = String(date.getMonth() + 1).padStart(2, '0');
            const day = String(date.getDate()).padStart(2, '0');
            return `${year}-${month}-${day}`;
        }

        dateRangeSelect.addEventListener('change', function() {
            const today = new Date();
            let start = new Date();
            let end = new Date();
            
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
                    start = new Date(today.getFullYear(), today.getMonth() - 2, 1); // Start of 3 months period
                    end = new Date(today.getFullYear(), today.getMonth() + 1, 0); // End of current month
                    break;
                case 'custom':
                    // Keep current values or allow user to pick
                    startDateInput.readOnly = false;
                    endDateInput.readOnly = false;
                    return;
            }
            startDateInput.value = formatDateForInput(start);
            endDateInput.value = formatDateForInput(end);
            startDateInput.readOnly = (this.value !== 'custom');
            endDateInput.readOnly = (this.value !== 'custom');
        });
        // Trigger change on load to set initial dates if not custom
        if (dateRangeSelect.value !== 'custom') {
             dateRangeSelect.dispatchEvent(new Event('change'));
        } else {
             startDateInput.readOnly = false;
             endDateInput.readOnly = false;
        }


        // Google Charts
        google.charts.load('current', {'packages':['corechart']});
        google.charts.setOnLoadCallback(drawCategoryChart);

        function drawCategoryChart() {
            <% if (!categoryData.isEmpty()) { %>
            var data = new google.visualization.DataTable();
            data.addColumn('string', 'Category');
            data.addColumn('number', 'Count');
            
            <% for (Map<String, Object> cat : categoryData) {
                String categoryName = (String) cat.get("category");
                // Basic escaping for JavaScript string literals
                categoryName = categoryName != null ? categoryName.replace("'", "\\'").replace("\n", "\\n").replace("\r", "\\r") : "Unknown";
            %>
                data.addRow(['<%= categoryName %>', <%= cat.get("count") %>]);
            <% } %>
            
            var options = {
                // title: 'Product Categories Distribution', // Title is now in HTML
                pieHole: 0.4,
                pieSliceText: 'percentage', // show percentage on slice
                tooltip: { text: 'value' }, // show count in tooltip
                chartArea: { width: '90%', height: '80%', left: "5%", top: "10%", right:"5%", bottom:"10%"},
                legend: { position: 'right', alignment: 'center', textStyle: { fontSize: 12 } },
                titleTextStyle: { fontSize: 16, bold: true }, // if you want to set title via options
                colors: ['#4285F4', '#EA4335', '#FBBC05', '#34A853', '#673AB7', '#FF9800', '#795548'],
                fontSize: 12,
                height: '100%', // Make chart responsive within its container
                width: '100%'
            };
            
            var chartElement = document.getElementById('categoryPieChart');
            if (chartElement) {
                 var chart = new google.visualization.PieChart(chartElement);
                 chart.draw(data, options);
                 
                 window.addEventListener('resize', function() { // Redraw on resize
                    chart.draw(data, options);
                 });
            } else {
                console.error("Chart element 'categoryPieChart' not found.");
            }
            <% } else { %>
                // Handled by JSP printing "No data" message above
                var chartElement = document.getElementById('categoryPieChart');
                if(chartElement && chartElement.innerHTML.trim() === ""){ // if JSP didn't already put a message
                    chartElement.innerHTML = '<p style="text-align:center; padding-top:50px; color:#6c757d;">No category data to display.</p>';
                }
            <% } %>
        }
    </script>
</body>
</html>