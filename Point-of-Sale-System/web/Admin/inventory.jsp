<%--
    Document   : inventory
    Created on : May 17, 2025, 10:15:23 AM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="org.json.JSONArray" %>
<%@ page import="org.json.JSONObject" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Inventory Dashboard - Swift POS</title>
  <script src="script.js"></script> <%-- Ensure script.js is present or remove if not used --%>
  <link rel="Stylesheet" href="styles.css"> <%-- Ensure styles.css is present --%>
  <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
  <style>
    /* Additional styles for the inventory dashboard */
    .inventory-filters {
      display: flex;
      gap: 15px;
      margin-bottom: 20px;
      flex-wrap: wrap;
    }
    
    .filter-item {
      background-color: white;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      padding: 10px 15px;
      display: flex;
      align-items: center;
      cursor: pointer;
    }
    
    .filter-icon {
      margin-right: 8px;
      color: var(--primary);
    }
    
    .inventory-search {
      flex: 1;
      display: flex;
      min-width: 250px;
    }
    
    .inventory-search input {
      flex: 1;
      border: 1px solid #e2e8f0;
      border-right: none;
      border-radius: 6px 0 0 6px;
      padding: 10px 15px;
    }
    
    .inventory-search button {
      background-color: var(--primary);
      color: white;
      border: none;
      border-radius: 0 6px 6px 0;
      padding: 0 15px;
      cursor: pointer;
    }
    
    .status-badge {
      display: inline-block;
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 12px;
      font-weight: 500;
    }
    
    .status-badge.in-stock {
      background-color: #d1fae5; /* Green for in-stock / positive changes */
      color: #065f46; 
    }
    
    .status-badge.low-stock {
      background-color: #fef3c7;
      color: #92400e; 
    }
    
    .status-badge.out-of-stock {
      background-color: #fee2e2; /* Red for out-of-stock / negative changes */
      color: #991b1b; 
    }
    
    .inventory-metrics {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 15px;
      margin-bottom: 20px;
    }
    
    .metric-card {
      background-color: white;
      border-radius: 8px;
      padding: 15px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    }
    
    .metric-title {
      font-size: 14px;
      color: var(--secondary);
      margin-bottom: 8px;
    }
    
    .metric-value {
      font-size: 24px;
      font-weight: 600;
    }
    
    .metric-change {
      font-size: 12px;
      margin-top: 5px;
      display: flex;
      align-items: center;
    }
    
    .metric-change.positive {
      color: var(--success);
    }
    
    .metric-change.negative {
      color: var(--danger);
    }
    
    .inventory-actions {
      display: flex;
      gap: 10px;
      margin-bottom: 20px;
      flex-wrap: wrap;
    }
    
    .action-button {
      background-color: var(--primary);
      color: white;
      border: none;
      border-radius: 6px;
      padding: 10px 15px;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      font-weight: 500;
    }
    
    .action-button.secondary {
      background-color: white;
      color: var(--dark);
      border: 1px solid #e2e8f0;
    }
    
    .category-filter {
      display: flex;
      overflow-x: auto;
      gap: 10px;
      padding-bottom: 10px;
      margin-bottom: 20px;
    }
    
    .category-item {
      background-color: #f1f5f9;
      border-radius: 20px;
      padding: 8px 16px;
      font-size: 14px;
      white-space: nowrap;
      cursor: pointer;
    }
    
    .category-item.active {
      background-color: var(--primary);
      color: white;
    }
    
    .inventory-movements {
      margin-top: 20px;
    }
    
    .chart-wrapper {
      background-color: white;
      border-radius: 8px;
      padding: 20px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
      margin-bottom: 20px;
      height: 350px; 
      display: flex;
      align-items: center;
      justify-content: center;
    }
        
    .movement-type {
      display: inline-flex;
      align-items: center;
      font-size: 13px;
      margin-right: 10px;
    }
    
    .dot {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      margin-right: 6px;
    }
    
    .dot.inward {
      background-color: var(--success);
    }
    
    .dot.outward {
      background-color: var(--danger);
    }
    
    .progress-bar {
      height: 6px;
      background-color: #e2e8f0;
      border-radius: 3px;
      overflow: hidden;
      margin-top: 8px;
    }
    
    .progress-fill {
      height: 100%;
      border-radius: 3px;
    }
    
    .action-menu {
      position: relative;
      display: inline-block;
    }
    
    .action-menu-btn {
      background: none;
      border: none;
      cursor: pointer;
      width: 30px;
      height: 30px;
      border-radius: 4px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    
    .action-menu-btn:hover {
      background-color: #f1f5f9;
    }
        
    .low-stock-list {
      list-style: none;
      padding: 0;
      margin: 0;
    }
    
    .stock-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 12px 0;
      border-bottom: 1px solid #e2e8f0;
    }
    
    .stock-item:last-child {
      border-bottom: none;
    }
    
    .stock-info {
      display: flex;
      flex-direction: column;
    }
    
    .stock-name {
      font-weight: 500;
      margin-bottom: 3px;
    }
    
    .stock-supplier {
      font-size: 12px;
      color: var(--secondary);
    }
    
    .stock-quantity {
      font-weight: 500;
      color: var(--danger); 
    }

    .text-danger { 
        color: #dc3545 !important;
    }
    .text-center { 
        text-align: center !important;
    }

    table {
        width: 100%;
        border-collapse: collapse;
        margin-top: 10px;
    }
    th, td {
        text-align: left;
        padding: 10px;
        border-bottom: 1px solid #e2e8f0;
        font-size: 14px;
    }
    th {
        background-color: #f8fafc;
        font-weight: 600;
        color: var(--secondary);
    }
    td .status-badge { 
        font-size: 12px;
        padding: 3px 7px;
    }
    .action-btn { 
        background-color: transparent;
        border: 1px solid #e2e8f0;
        border-radius: 4px;
        padding: 5px 8px;
        cursor: pointer;
        font-size: 12px;
    }
    .action-btn:hover {
        background-color: #f1f5f9;
    }

    @media (max-width: 768px) {
      .inventory-filters {
        flex-direction: column;
      }
      .inventory-search {
        width: 100%;
      }
      .action-button {
        width: 100%;
        justify-content: center;
      }
      .chart-wrapper {
        height: 300px; 
      }
      th, td {
          font-size: 13px; 
          padding: 8px;
      }
    }
  </style>

  <%
    // Database connection details
    String DB_URL = "jdbc:mysql://localhost:3306/Swift_Database"; 
    String DB_USER = "root"; 
    String DB_PASSWORD = ""; 

    Connection conn = null; // General connection variable, can be reused if careful with scope
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    // --- Data for Pie Chart (Monetary Value by Category) ---
    JSONArray categoryMonetaryValueData = new JSONArray();
    String pieChartError = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver"); // Load driver once
        conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        String pieQuery = "SELECT category, SUM(stock * price) AS total_monetary_value FROM products GROUP BY category HAVING SUM(stock * price) > 0";
        pstmt = conn.prepareStatement(pieQuery);
        rs = pstmt.executeQuery();
        while (rs.next()) {
            JSONObject catData = new JSONObject();
            catData.put("category", rs.getString("category"));
            catData.put("value", rs.getDouble("total_monetary_value"));
            categoryMonetaryValueData.put(catData);
        }
    } catch (Exception e) {
        pieChartError = "Error loading pie chart data: " + e.getMessage();
        // e.printStackTrace(); 
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ex) { /* log */ }
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) { /* log */ }
        if (conn != null) try { conn.close(); } catch (SQLException ex) { /* log */ }
    }

    if (pieChartError != null && categoryMonetaryValueData.length() == 0) {
        categoryMonetaryValueData.put(new JSONObject().put("category", "Chart Error").put("value", 1));
    } else if (categoryMonetaryValueData.length() == 0) {
        categoryMonetaryValueData.put(new JSONObject().put("category", "No Monetary Data").put("value", 1));
    }

    // --- Data for Total Monetary Inventory Value Metric Card ---
    double totalInventoryMonetaryValue = 0;
    String totalValueError = null;
    try {
        conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        String totalValueQuery = "SELECT SUM(stock * price) AS grand_total_value FROM products";
        pstmt = conn.prepareStatement(totalValueQuery);
        rs = pstmt.executeQuery();
        if (rs.next()) {
            totalInventoryMonetaryValue = rs.getDouble("grand_total_value");
        }
    } catch (Exception e) {
        totalValueError = "Error fetching total inventory value: " + e.getMessage();
        // e.printStackTrace();
    } finally {
        if (rs != null) try { rs.close(); } catch (SQLException ex) { /* log */ }
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) { /* log */ }
        if (conn != null) try { conn.close(); } catch (SQLException ex) { /* log */ }
    }

    Locale sriLankaLocale = new Locale("en", "LK"); 
    NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(sriLankaLocale);
    currencyFormatter.setCurrency(Currency.getInstance("LKR")); 
    String formattedTotalInventoryValue = currencyFormatter.format(totalInventoryMonetaryValue);
    
    // --- Data for other Metric Cards ---
    int totalItemsCount = 0; 
    int lowStockItemsCount = 0; 
    try {
        conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        pstmt = conn.prepareStatement("SELECT COUNT(DISTINCT id) AS total_unique_items FROM products");
        rs = pstmt.executeQuery();
        if (rs.next()) totalItemsCount = rs.getInt("total_unique_items");
        rs.close(); pstmt.close(); // Close previous statement and resultset

        pstmt = conn.prepareStatement("SELECT COUNT(*) AS low_stock_count FROM products WHERE stock <= reorder_level AND stock > 0 AND reorder_level > 0");
        rs = pstmt.executeQuery();
        if (rs.next()) lowStockItemsCount = rs.getInt("low_stock_count");
        
    } catch (Exception e) { 
      // e.printStackTrace(); 
    } 
    finally {
        if (rs != null) try { rs.close(); } catch (SQLException ex) { /* log */ }
        if (pstmt != null) try { pstmt.close(); } catch (SQLException ex) { /* log */ }
        if (conn != null) try { conn.close(); } catch (SQLException ex) { /* log */ }
    }
%>

  <script type="text/javascript">
    google.charts.load('current', {'packages':['corechart']});
    google.charts.setOnLoadCallback(drawInventoryValuePieChart);

    function drawInventoryValuePieChart() {
      var data = new google.visualization.DataTable();
      data.addColumn('string', 'Category');
      data.addColumn('number', 'Monetary Value (LKR)'); 

      var chartDataFromJSP = <%= categoryMonetaryValueData.toString() %>;
      var pieChartDiv = document.getElementById('piechart_div');

      if (!pieChartDiv) {
          console.error("Element with ID 'piechart_div' not found.");
          return;
      }
      
      if (chartDataFromJSP.length === 0 || 
          (chartDataFromJSP.length === 1 && (chartDataFromJSP[0].category === "Chart Error" || chartDataFromJSP[0].category === "No Monetary Data"))) {
        var message = "No inventory monetary data for categories.";
        if (chartDataFromJSP.length === 1) {
            message = chartDataFromJSP[0].category + ".";
            if ("<%= pieChartError != null %>" === "true") { 
                message = "Error loading chart data. Please check logs.";
            }
        }
        pieChartDiv.innerHTML = '<p style="text-align:center; color:grey; padding-top:20px;">' + message + '</p>';
        return;
      }

      for (var i = 0; i < chartDataFromJSP.length; i++) {
        data.addRow([chartDataFromJSP[i].category, chartDataFromJSP[i].value]);
      }

      var formatter = new google.visualization.NumberFormat({
        prefix: 'LKR ', 
        decimalSymbol: '.',
        groupingSymbol: ',',
        fractionDigits: 2 
      });
      formatter.format(data, 1); 

      var options = {
        title: 'Inventory Value by Category (LKR)', 
        pieHole: 0.4, 
        legend: { position: 'bottom' },
        height: '100%', 
        width: '100%',
        pieSliceText: 'percentage', 
        tooltip: { text: 'value', trigger: 'focus' } 
      };

      var chart = new google.visualization.PieChart(pieChartDiv);
      chart.draw(data, options);

      window.addEventListener('resize', function() {
        chart.draw(data, options);
      });
    }
  </script>
</head>
<body>
  <div class="mobile-top-bar">
    <div class="mobile-logo">
      <img src="${pageContext.request.contextPath}/Images/logo.png" alt="POS Logo">
      <h2>Swift</h2>
    </div>
    <button class="mobile-nav-toggle" id="mobileNavToggle" aria-label="Toggle navigation">☰</button>
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
        <h1 class="page-title">Inventory Dashboard</h1>
        <div class="user-profile">
          <%
            Connection userConnHeader = null; // Use a distinct variable name
            PreparedStatement userSqlHeader = null;
            ResultSet userResultHeader = null;
            try {
                userConnHeader = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                userSqlHeader = userConnHeader.prepareStatement("SELECT profile_image_path, first_name FROM users WHERE role = 'Admin' LIMIT 1");
                userResultHeader = userSqlHeader.executeQuery();

                if (userResultHeader.next()) {
                    String profileImagePath = userResultHeader.getString("profile_image_path");
                    String firstName = userResultHeader.getString("first_name") != null ? userResultHeader.getString("first_name") : "Admin";

                    if (profileImagePath == null || profileImagePath.trim().isEmpty() || profileImagePath.trim().equals("uploads\\profile_images\\")) {
                        profileImagePath = "Images/default-profile.png"; 
                    } else {
                        profileImagePath = profileImagePath.replace("\\", "/");
                    }
        %>
                    <img src="${pageContext.request.contextPath}/<%= profileImagePath %>"
                         alt="Admin Profile"
                         onerror="this.onerror=null; this.src='${pageContext.request.contextPath}/Images/default-profile.png';">
                    <div>
                        <h4><%= firstName %></h4>
                    </div>
        <%
                } else {
        %>
                    <img src="${pageContext.request.contextPath}/Images/default-profile.png" alt="Default Profile">
                    <div>
                        <h4>Admin</h4>
                    </div>
        <%
                }
            } catch (Exception ex) { // Catch generic Exception after specific ones if any
                out.println("<p class='text-danger text-center'>Error loading profile: " + ex.getMessage() + "</p>");
                 // ex.printStackTrace();
            } finally {
                if (userResultHeader != null) try { userResultHeader.close(); } catch (SQLException e) { /* log */ }
                if (userSqlHeader != null) try { userSqlHeader.close(); } catch (SQLException e) { /* log */ }
                if (userConnHeader != null) try { userConnHeader.close(); } catch (SQLException e) { /* log */ }
            }
          %>
        </div>
      </div>
      
      <div class="inventory-metrics">
        <div class="metric-card">
          <div class="metric-title">TOTAL ITEMS</div>
          <div class="metric-value"><%= totalItemsCount %></div> 
          <div class="metric-change positive">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="18 15 12 9 6 15"></polyline></svg>
            ...
          </div>
        </div>
        <div class="metric-card">
          <div class="metric-title">LOW STOCK ITEMS</div>
          <div class="metric-value"><%= lowStockItemsCount %></div> 
          <div class="metric-change negative">
             <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
            ...
          </div>
        </div>
        <div class="metric-card">
          <div class="metric-title">INVENTORY VALUE</div>
          <% if (totalValueError != null) { %>
            <div class="metric-value text-danger" style="font-size:16px;">Error</div>
            <p style="font-size:12px;"><%= totalValueError %></p>
          <% } else { %>
            <div class="metric-value"><%= formattedTotalInventoryValue %></div>
          <% } %>
          <div class="metric-change positive">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="18 15 12 9 6 15"></polyline></svg>
            ...
          </div>
        </div>
        <div class="metric-card">
          <div class="metric-title">STOCK TURNOVER RATE</div>
          <div class="metric-value">N/A</div> 
          <div class="metric-change positive">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="18 15 12 9 6 15"></polyline></svg>
            ...
          </div>
        </div>
      </div>
      
      <div class="inventory-actions">
        <button class="action-button" onclick="window.location.href='add_product.jsp'">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="12" y1="5" x2="12" y2="19"></line><line x1="5" y1="12" x2="19" y2="12"></line></svg>
          Add New Item
        </button>
        <button class="action-button secondary" onclick="window.location.href='stock_adjustment.jsp'">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path></svg>
          Stock Adjustment
        </button>
        <button class="action-button secondary" onclick="window.location.href='inventory_reports.jsp'">
           <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
          Generate Report
        </button>
         <button class="action-button secondary" onclick="window.location.href='purchases.jsp'">
           <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="9" cy="21" r="1"></circle><circle cx="20" cy="21" r="1"></circle><path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path></svg>
           Create Purchase Order
        </button>
      </div>
      
      <div class="inventory-filters">
        <div class="inventory-search">
          <input type="text" placeholder="Search by name, SKU, or category..." id="inventorySearchInput">
          <button aria-label="Search" id="inventorySearchButton"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg></button>
        </div>
        <div class="filter-item" id="filterButton"><div class="filter-icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg></div>Filters</div>
        <div class="filter-item" id="sortButton"><div class="filter-icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line><line x1="3" y1="6" x2="3.01" y2="6"></line><line x1="3" y1="12" x2="3.01" y2="12"></line><line x1="3" y1="18" x2="3.01" y2="18"></line></svg></div>Sort By</div>
      </div>
      
      <div class="category-filter">
        <div class="category-item active" data-category="All">All Items</div>
        <%
            Connection connCategoriesFilter = null; // Distinct variable
            PreparedStatement psCategoriesFilter = null;
            ResultSet rsCategoriesFilter = null;
            try {
                connCategoriesFilter = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                psCategoriesFilter = connCategoriesFilter.prepareStatement("SELECT DISTINCT category FROM products WHERE category IS NOT NULL AND category <> '' ORDER BY category");
                rsCategoriesFilter = psCategoriesFilter.executeQuery();
                while(rsCategoriesFilter.next()){
                    String categoryName = rsCategoriesFilter.getString("category");
        %>
                    <div class="category-item" data-category="<%= categoryName %>"><%= categoryName %></div>
        <%
                }
            } catch (Exception e) {
                // e.printStackTrace(); 
            } finally {
                if (rsCategoriesFilter != null) try { rsCategoriesFilter.close(); } catch (SQLException ex) {/* log */}
                if (psCategoriesFilter != null) try { psCategoriesFilter.close(); } catch (SQLException ex) {/* log */}
                if (connCategoriesFilter != null) try { connCategoriesFilter.close(); } catch (SQLException ex) {/* log */}
            }
        %>
      </div>
      
      <div class="modules-container">
        <div class="module-card">
          <div class="module-header">Low Stock Alert</div>
          <div class="module-content"><ul class="low-stock-list">
            <%
              Connection connLowStockList = null; 
              PreparedStatement psLowList = null;    
              ResultSet rsLowList = null;        
              try {
                  connLowStockList = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                  psLowList = connLowStockList.prepareStatement(
                      "SELECT name, supplier, stock FROM products " + // Removed reorder_level for now to simplify if it's causing issues
                      "WHERE stock <= 10 AND stock > 0 " + // Using fixed threshold 10 for low stock
                      "ORDER BY stock ASC LIMIT 5"
                  );
                  rsLowList = psLowList.executeQuery(); boolean foundLowStock = false;
                  while (rsLowList.next()) { foundLowStock = true; 
            %>
            <li class="stock-item">
                <div class="stock-info">
                    <span class="stock-name"><%= rsLowList.getString("name") %></span>
                    <span class="stock-supplier"><%= rsLowList.getString("supplier") != null ? rsLowList.getString("supplier") : "N/A" %></span>
                </div>
                <div class="stock-quantity"><%= rsLowList.getInt("stock") %> Items left</div>
            </li>
            <% 
                } 
                if (!foundLowStock) {
                    out.println("<li class='stock-item' style='justify-content:center;'><p>No items currently low on stock (threshold: 10).</p></li>");
                }
              } catch (Exception ex) { 
                  out.println("<li class='stock-item'><p class='text-danger'>Error fetching low stock: " + ex.getMessage() + "</p></li>"); 
                  // ex.printStackTrace();
              } finally { 
                  if (rsLowList != null) try { rsLowList.close(); } catch (SQLException e) { /* log */ }
                  if (psLowList != null) try { psLowList.close(); } catch (SQLException e) { /* log */ }
                  if (connLowStockList != null) try { connLowStockList.close(); } catch (SQLException e) { /* log */ } 
              }
            %>
            </ul></div>
        </div>
        <div class="module-card">
          <div class="module-header">Inventory Value by Category (LKR)</div>
          <div class="module-content"><div class="chart-wrapper"><div id="piechart_div" style="width: 100%; height: 100%;"></div></div></div>
        </div>
      </div>
      
      <div class="module-card" style="margin-top: 20px;">
          <div class="module-header">Inventory Activities (Recent)</div>
          <div class="module-content">
              <table>
                  <thead>
                      <tr>
                          <th>Product Name</th>
                          <th>Movement Type</th>
                          <th>Quantity Change</th>
                          <th>Date</th>
                          <th>User</th>
                          <th>Reference</th>
                      </tr>
                  </thead>
                  <tbody>
                      <%
                          Connection connActivities = null;
                          PreparedStatement psAct = null;
                          ResultSet rsAct = null;
                          try {
                              connActivities = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                              String queryActivities = "SELECT p.name AS product_name, im.movement_type, " +
                                                       "im.quantity_change, im.movement_date, u.first_name AS user_name, im.user_id AS actual_user_id, " +
                                                       "im.reference_type, im.reference_id " +
                                                       "FROM inventory_movements im " +
                                                       "JOIN products p ON im.product_id = p.id " +
                                                       "LEFT JOIN users u ON im.user_id = u.id " +
                                                       "ORDER BY im.movement_date DESC LIMIT 5";
                              psAct = connActivities.prepareStatement(queryActivities);
                              rsAct = psAct.executeQuery();
                              boolean hasActivities = false;
                              while (rsAct.next()) {
                                  hasActivities = true;
                                  String productName = rsAct.getString("product_name");
                                  String movementType = rsAct.getString("movement_type");
                                  BigDecimal quantityChange = rsAct.getBigDecimal("quantity_change");
                                  Timestamp movementDateTs = rsAct.getTimestamp("movement_date");
                                  String movementDateStr = (movementDateTs != null) ? new SimpleDateFormat("MMM dd, yyyy HH:mm").format(movementDateTs) : "N/A";
                                  String userName = rsAct.getString("user_name");
                                  int actualUserId = rsAct.getInt("actual_user_id");

                                  if (userName == null || userName.trim().isEmpty()) {
                                      if (actualUserId != 0 && rsAct.wasNull()) { 
                                          userName = "User ID: " + actualUserId;
                                      } else {
                                          userName = "N/A"; 
                                      }
                                  }
                                  String referenceType = rsAct.getString("reference_type");
                                  String referenceId = rsAct.getString("reference_id");
                                  String referenceDisplay = ((referenceType != null && !referenceType.isEmpty()) ? referenceType + ": " : "") + ((referenceId != null && !referenceId.isEmpty()) ? referenceId : "");
                                  if (referenceDisplay.trim().isEmpty() || referenceDisplay.trim().equals(":")) referenceDisplay = "N/A";
                      %>
                      <tr>
                          <td><%= productName %></td>
                          <td>
                              <%
                                  String typeClass = "";
                                  String typeText = movementType; 
                                  if (quantityChange.doubleValue() > 0) {
                                      typeClass = "status-badge in-stock"; 
                                  } else if (quantityChange.doubleValue() < 0) {
                                      typeClass = "status-badge out-of-stock"; 
                                  } else {
                                      typeClass = "status-badge"; 
                                  }
                                  switch (movementType) {
                                      case "purchase_receipt": typeText = "Purchase Receipt"; break;
                                      case "sale_dispatch": typeText = "Sale Dispatch"; break;
                                      case "stock_adjustment_add": typeText = "Adjustment (Add)"; break;
                                      case "stock_adjustment_subtract": typeText = "Adjustment (Subtract)"; break;
                                      case "return_from_customer": typeText = "Customer Return"; break;
                                      case "return_to_supplier": typeText = "Supplier Return"; break;
                                      case "initial_stock_setup": typeText = "Initial Stock"; break;
                                      case "damaged_goods": typeText = "Damaged"; break;
                                      case "expired_goods": typeText = "Expired"; break;
                                      case "internal_transfer_out": typeText = "Transfer Out"; break;
                                      case "internal_transfer_in": typeText = "Transfer In"; break;
                                      case "others": typeText = "Others"; break;
                                      default: 
                                        String temp = movementType.replace("_", " ");
                                        typeText = temp.substring(0, 1).toUpperCase() + temp.substring(1).toLowerCase();
                                        break;
                                  }
                              %>
                              <span class="<%= typeClass %>"><%= typeText %></span>
                          </td>
                          <td><%= quantityChange.signum() > 0 ? "+" : "" %><%= quantityChange.toString() %></td>
                          <td><%= movementDateStr %></td>
                          <td><%= userName %></td>
                          <td><%= referenceDisplay %></td>
                      </tr>
                      <%
                              }
                              if (!hasActivities) {
                                  out.println("<tr><td colspan='6' class='text-center'>No recent inventory activities found.</td></tr>");
                              }
                          } catch (Exception ex) {
                              out.println("<tr><td colspan='6' class='text-danger text-center'>Error loading activities: " + ex.getMessage() + "</td></tr>");
                              // ex.printStackTrace(); 
                          } finally {
                              if (rsAct != null) try { rsAct.close(); } catch (SQLException e) { /* log */ }
                              if (psAct != null) try { psAct.close(); } catch (SQLException e) { /* log */ }
                              if (connActivities != null) try { connActivities.close(); } catch (SQLException e) { /* log */ }
                          }
                      %>
                  </tbody>
              </table>
          </div>
      </div>
      
      <div class="module-card" style="margin-top: 20px;">
        <div class="module-header">Stock Levels - Top Products</div>
        <div class="module-content"><table><thead><tr><th>Product</th><th>SKU</th><th>Category</th><th>Current Stock</th><th>Reorder Level</th><th>Status</th></tr></thead><tbody>
            <%  
              Connection connStockLvl = null;
              PreparedStatement psSLvl = null;
              ResultSet rsSLvl = null;
              try {
                  connStockLvl = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                  psSLvl = connStockLvl.prepareStatement(
                      "SELECT name, sku, category, stock, COALESCE(reorder_level, 0) as reorder_level FROM products ORDER BY stock DESC LIMIT 10"
                  );
                  rsSLvl = psSLvl.executeQuery(); boolean hasStockLevels = false;
                  while (rsSLvl.next()) { hasStockLevels = true; 
                      String productNameSL = rsSLvl.getString("name"); // Explicitly get product name
                      int stock = rsSLvl.getInt("stock");
                      int reorderLvl = rsSLvl.getInt("reorder_level");
                      String statusClass = "";
                      String statusText = "";
                      if (stock <= 0) {
                          statusClass = "out-of-stock";
                          statusText = "Out of Stock";
                      } else if (reorderLvl > 0 && stock <= reorderLvl) { 
                          statusClass = "low-stock";
                          statusText = "Low Stock";
                      } else {
                          statusClass = "in-stock";
                          statusText = "In Stock";
                      }
            %>
            <tr>
                <td><%= productNameSL %></td>
                <td><%= rsSLvl.getString("sku") != null ? rsSLvl.getString("sku") : "N/A" %></td>
                <td><%= rsSLvl.getString("category") != null ? rsSLvl.getString("category") : "N/A" %></td>
                <td><%= stock %></td>
                <td><%= reorderLvl > 0 ? reorderLvl : "N/A" %></td>
                <td><span class="status-badge <%= statusClass %>"><%= statusText %></span></td>
          
            <% 
                } if (!hasStockLevels) {
                    out.println("<tr><td colspan='7' class='text-center'>No stock data.</td></tr>");
                }
              } catch (Exception ex) { 
                  out.println("<tr><td colspan='7' class='text-danger text-center'>Error fetching stock levels: " + ex.getMessage() + "</td></tr>"); 
                  // ex.printStackTrace();
              } finally { 
                  if (rsSLvl != null) try { rsSLvl.close(); } catch (SQLException e) { /* log */ }
                  if (psSLvl != null) try { psSLvl.close(); } catch (SQLException e) { /* log */ }
                  if (connStockLvl != null) try { connStockLvl.close(); } catch (SQLException e) { /* log */ }
              }
            %>
            </tbody></table></div>
      </div>
      
      <div class="footer">Swift POS © <%= java.time.Year.now().getValue() %>.</div>
    </div>
  </div>
  <script>
    const mobileNavToggle = document.getElementById('mobileNavToggle');
    const sidebar = document.getElementById('sidebar');
    if (mobileNavToggle && sidebar) { mobileNavToggle.addEventListener('click', () => sidebar.classList.toggle('active')); }
    document.addEventListener('click', function(event) { if (sidebar && sidebar.classList.contains('active') && !sidebar.contains(event.target) && !mobileNavToggle.contains(event.target)) { sidebar.classList.remove('active'); } });
    
    const categoryItems = document.querySelectorAll('.category-item');
    categoryItems.forEach(item => { 
        item.addEventListener('click', () => { 
            categoryItems.forEach(i => i.classList.remove('active')); 
            item.classList.add('active'); 
            console.log('Category filter:', item.dataset.category); 
        }); 
    });

    const searchInput = document.getElementById('inventorySearchInput');
    const searchButton = document.getElementById('inventorySearchButton');
    const filterButton = document.getElementById('filterButton');
    const sortButton = document.getElementById('sortButton');

    if(searchButton && searchInput) {
        searchButton.addEventListener('click', () => {
            console.log('Search for:', searchInput.value);
        });
    }
    if(filterButton) {
        filterButton.addEventListener('click', () => {
            console.log('Open filter options');
        });
    }
    if(sortButton) {
        sortButton.addEventListener('click', () => {
            console.log('Open sort options');
        });
    }
  </script>
</body>
</html>