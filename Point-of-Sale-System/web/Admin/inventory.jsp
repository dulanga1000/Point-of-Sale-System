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

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Inventory Dashboard - Swift POS</title>
  <script src="script.js"></script>
  <link rel="Stylesheet" href="styles.css">
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
      background-color: #d1fae5;
      color: var(--success);
    }
    
    .status-badge.low-stock {
      background-color: #fef3c7;
      color: var(--warning);
    }
    
    .status-badge.out-of-stock {
      background-color: #fee2e2;
      color: var(--danger);
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
      /*Adjust height as needed for the chart */
      height: 350px; 
      display: flex;
      align-items: center;
      justify-content: center;
    }
    
    /* Removed chart-placeholder as we will draw the actual chart */
    
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
    
    /* Low Stock List Styles */
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
    
    /* Responsive adjustments */
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
        height: 300px; /* Adjust for smaller screens */
      }
    }
  </style>

  <%
    // Database connection details
    String DB_URL = "jdbc:mysql://localhost:3306/Swift_Database"; 
    String DB_USER = "root"; 
    String DB_PASSWORD = ""; 

    // --- Data for Pie Chart (Monetary Value by Category) ---
    JSONArray categoryMonetaryValueData = new JSONArray(); // Renamed for clarity
    String pieChartError = null;
    Connection connPie = null;
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        connPie = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        // QUERY MODIFIED: Get total monetary value (stock * price) per category
        String pieQuery = "SELECT category, SUM(stock * price) AS total_monetary_value FROM products GROUP BY category HAVING SUM(stock * price) > 0";
        PreparedStatement psPie = connPie.prepareStatement(pieQuery);
        ResultSet rsPie = psPie.executeQuery();
        while (rsPie.next()) {
            JSONObject catData = new JSONObject();
            catData.put("category", rsPie.getString("category"));
            catData.put("value", rsPie.getDouble("total_monetary_value")); // Storing the monetary value
            categoryMonetaryValueData.put(catData);
        }
    } catch (Exception e) {
        pieChartError = "Error loading pie chart data: " + e.getMessage();
        // e.printStackTrace(); // For server-side logging
    } finally {
        if (connPie != null) try { connPie.close(); } catch (SQLException ex) { /* log ex */ }
    }

    if (pieChartError != null && categoryMonetaryValueData.length() == 0) {
        JSONObject errorData = new JSONObject().put("category", "Chart Error").put("value", 1);
        categoryMonetaryValueData.put(errorData);
    } else if (categoryMonetaryValueData.length() == 0) {
        JSONObject noData = new JSONObject().put("category", "No Monetary Data").put("value", 1);
        categoryMonetaryValueData.put(noData);
    }

    // --- Data for Total Monetary Inventory Value Metric Card ---
    double totalInventoryMonetaryValue = 0;
    String totalValueError = null;
    Connection connTotalValue = null;
    try {
        connTotalValue = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        String totalValueQuery = "SELECT SUM(stock * price) AS grand_total_value FROM products";
        PreparedStatement psTotal = connTotalValue.prepareStatement(totalValueQuery);
        ResultSet rsTotal = psTotal.executeQuery();
        if (rsTotal.next()) {
            totalInventoryMonetaryValue = rsTotal.getDouble("grand_total_value");
        }
    } catch (Exception e) {
        totalValueError = "Error fetching total inventory value: " + e.getMessage();
        // e.printStackTrace();
    } finally {
        if (connTotalValue != null) try { connTotalValue.close(); } catch (SQLException ex) { /* log ex */ }
    }

    Locale sriLankaLocale = new Locale("en ", "LK"); 
    NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(sriLankaLocale);
    String formattedTotalInventoryValue = currencyFormatter.format(totalInventoryMonetaryValue);
    
    // --- Data for other Metric Cards ---
    int totalItemsCount = 0; 
    int lowStockItemsCount = 0; 
    Connection connMetrics = null;
    try {
        connMetrics = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        PreparedStatement psTotalItems = connMetrics.prepareStatement("SELECT COUNT(DISTINCT id) AS total_unique_items FROM products");
        ResultSet rsTotalItems = psTotalItems.executeQuery();
        if (rsTotalItems.next()) totalItemsCount = rsTotalItems.getInt("total_unique_items");
        rsTotalItems.close(); psTotalItems.close();

        PreparedStatement psLowStock = connMetrics.prepareStatement("SELECT COUNT(*) AS low_stock_count FROM products WHERE stock <= 10 AND stock > 0"); // Threshold 10
        ResultSet rsLowStock = psLowStock.executeQuery();
        if (rsLowStock.next()) lowStockItemsCount = rsLowStock.getInt("low_stock_count");
        rsLowStock.close(); psLowStock.close();
    } catch (Exception e) { /* e.printStackTrace(); */ } 
    finally {
        if (connMetrics != null) try { connMetrics.close(); } catch (SQLException ex) { /* log ex */ }
    }
%>

  <script type="text/javascript">
    google.charts.load('current', {'packages':['corechart', 'table']}); // Added 'table' for potential future use like formatted tables
    google.charts.setOnLoadCallback(drawInventoryValuePieChart);

    function drawInventoryValuePieChart() {
      var data = new google.visualization.DataTable();
      data.addColumn('string', 'Category');
      // MODIFIED: Label for data column to reflect monetary value
      data.addColumn('number', 'Monetary Value (Rs.)'); 

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
            if ("<%= pieChartError != null %>" === "true") { // Check if pieChartError was set from JSP
                 message = "Error loading chart data. Please check logs.";
            }
        }
        pieChartDiv.innerHTML = '<p style="text-align:center; color:grey; padding-top:20px;">' + message + '</p>';
        return;
      }

      for (var i = 0; i < chartDataFromJSP.length; i++) {
        data.addRow([chartDataFromJSP[i].category, chartDataFromJSP[i].value]);
      }

      // Format the 'Monetary Value (Rs.)' column as LKR currency for tooltips.
      // Note: The symbol 'Rs' might not be standard for all locales with LKR.
      // 'LKR' is the ISO code. For explicit "Rs." prefix, you might need custom tooltips.
      // This formatter will attempt to use the locale's default for LKR.
      var formatter = new google.visualization.NumberFormat({
        prefix: 'Rs. ', // Explicitly adding Rs. prefix
        decimalSymbol: '.',
        groupingSymbol: ',',
        fractionDigits: 2 // Show two decimal places for currency
      });
      formatter.format(data, 1); // Apply formatter to the second column (index 1)

      var options = {
        // MODIFIED: Chart Title
        title: 'Inventory Value by Category (Rs.)', 
        pieHole: 0.4, 
        legend: { position: 'bottom' },
        height: '100%', 
        width: '100%',
        pieSliceText: 'percentage', // Shows percentage on slices
        tooltip: { text: 'value', trigger: 'focus' } // Tooltip will show the formatted Rs. value
        // For more complex tooltips showing category, formatted value, and percentage:
        // tooltip: {isHtml: true} and generate HTML content for tooltips, or use a DataView with custom columns.
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
            Connection userConn = null;
            String URL = "jdbc:mysql://localhost:3306/Swift_Database";
            String USER = "root";
            String PASSWORD = "";

            try {
                // Updated to use newer driver name
                Class.forName("com.mysql.cj.jdbc.Driver");
                userConn = DriverManager.getConnection(URL, USER, PASSWORD);

                PreparedStatement sql = userConn.prepareStatement("SELECT * FROM users WHERE role = 'admin' LIMIT 1");
                ResultSet result = sql.executeQuery();

                if (result.next()) {
                    String profileImagePath = result.getString("profile_image_path");
                    String firstName = result.getString("first_name") != null ? result.getString("first_name") : "Admin";

                    // Handle null or empty profile image path
                    if (profileImagePath == null || profileImagePath.trim().isEmpty()) {
                        profileImagePath = "/Images/default-profile.png"; // Default image path
                    }
          %>
                    <img src="${pageContext.request.contextPath}/<%= result.getString("profile_image_path") %>"
                         alt="Admin Profile"
                         onerror="this.src='<img src="${pageContext.request.contextPath}<%= result.getString("profile_image_path") %>" alt="Admin Profile">
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
                result.close();
                sql.close();
            } catch (ClassNotFoundException e) {
                out.println("<p class='text-danger text-center'>Database driver not found: " + e.getMessage() + "</p>");
            } catch (SQLException e) {
                out.println("<p class='text-danger text-center'>Database error: " + e.getMessage() + "</p>");
            } catch (Exception ex) {
                out.println("<p class='text-danger text-center'>Error: " + ex.getMessage() + "</p>");
            } finally {
                if (userConn != null) {
                    try {
                        userConn.close();
                    } catch (SQLException e) {
                        // Log the error but continue
                        e.printStackTrace();
                    }
                }
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
          <div class="metric-value">4.7x</div> 
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
          <input type="text" placeholder="Search by name, SKU, or category...">
          <button aria-label="Search"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg></button>
        </div>
        <div class="filter-item"><div class="filter-icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon></svg></div>Filters</div>
        <div class="filter-item"><div class="filter-icon"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="8" y1="6" x2="21" y2="6"></line><line x1="8" y1="12" x2="21" y2="12"></line><line x1="8" y1="18" x2="21" y2="18"></line><line x1="3" y1="6" x2="3.01" y2="6"></line><line x1="3" y1="12" x2="3.01" y2="12"></line><line x1="3" y1="18" x2="3.01" y2="18"></line></svg></div>Sort By</div>
      </div>
      
      <div class="category-filter">
        <div class="category-item active">All Items</div><div class="category-item">Beverages</div><div class="category-item">Bakery</div><div class="category-item">Dairy</div><div class="category-item">Snacks</div><div class="category-item">Packaging</div><div class="category-item">Equipment</div><div class="category-item">Others</div>
      </div>
      
      <div class="modules-container">
        <div class="module-card">
          <div class="module-header">Low Stock Alert</div>
          <div class="module-content"><ul class="low-stock-list">
            <%
              Connection connLowStock = null;
              try {
                  connLowStock = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                  PreparedStatement psLow = connLowStock.prepareStatement("SELECT name, supplier, stock FROM products WHERE stock <= 10 AND stock > 0 ORDER BY stock ASC LIMIT 5");
                  ResultSet rsLow = psLow.executeQuery(); boolean foundLowStock = false;
                  while (rsLow.next()) { foundLowStock = true; %>
              <li class="stock-item"><div class="stock-info"><span class="stock-name"><%= rsLow.getString("name") %></span><span class="stock-supplier"><%= rsLow.getString("supplier") != null ? rsLow.getString("supplier") : "N/A" %></span></div><div class="stock-quantity"><%= rsLow.getInt("stock") %> Items left</div></li>
            <% } if (!foundLowStock) out.println("<li class='stock-item' style='justify-content:center;'><p>No items currently low on stock.</p></li>");
                  rsLow.close(); psLow.close();
              } catch (Exception ex) { out.println("<li class='stock-item'><p class='text-danger'>Error: " + ex.getMessage() + "</p></li>"); } 
              finally { if (connLowStock != null) try { connLowStock.close(); } catch (SQLException e) { /* log e */ } }
            %>
            </ul></div>
        </div>
        <div class="module-card">
          <div class="module-header">Inventory Value by Category (Rs.)</div>
          <div class="module-content"><div class="chart-wrapper"><div id="piechart_div" style="width: 100%; height: 100%;"></div></div></div>
        </div>
      </div>
      
      <div class="module-card" style="margin-top: 20px;">
        <div class="module-header">Inventory Activities (Recent)</div>
        <div class="module-content"><table><thead><tr><th>Product</th><th>Type</th><th>Quantity</th><th>Date</th><th>User</th><th>Reference</th><th>Actions</th></tr></thead><tbody>
            <%  
              Connection connActivities = null;
              try {
                  connActivities = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                  PreparedStatement psAct = connActivities.prepareStatement("SELECT name, stock FROM products ORDER BY RAND() LIMIT 3"); ResultSet rsAct = psAct.executeQuery();
                  boolean hasActivities = false; String[] types = {"Stock In", "Sale", "Adjustment"}; String[] refs = {"#PO-4576", "#INV-1023", "#ADJ-003"}; int actCount = 0;
                  while (rsAct.next() && actCount < 3) { hasActivities = true; %>
              <tr><td><%= rsAct.getString("name") %></td><td><span class="status completed"><%= types[actCount % types.length] %></span></td><td><%= (rsAct.getInt("stock") / (actCount + 2)) + (actCount % 2 == 0 ? 5 : -2) %></td><td>May <%= 16 - actCount % 3 %>, 2025</td><td>Admin User</td><td><%= refs[actCount % refs.length] %></td><td><button class="action-menu-btn" title="View Details">📝</button></td></tr>
            <% actCount++; } if (!hasActivities) out.println("<tr><td colspan='7' class='text-center'>No recent activities.</td></tr>");
                  rsAct.close(); psAct.close();
              } catch (Exception ex) { out.println("<tr><td colspan='7' class='text-danger text-center'>Error: " + ex.getMessage() + "</td></tr>"); } 
              finally { if (connActivities != null) try { connActivities.close(); } catch (SQLException e) { /* log e */ } }
            %>
            </tbody></table></div>
      </div>
      
      <div class="module-card" style="margin-top: 20px;">
        <div class="module-header">Stock Levels - Top Products</div>
        <div class="module-content"><table><thead><tr><th>Product</th><th>SKU</th><th>Category</th><th>Current Stock</th><th>Reorder Level</th><th>Status</th><th>Actions</th></tr></thead><tbody>
            <%  
              Connection connStockLvl = null;
              try {
                  connStockLvl = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                  PreparedStatement psSLvl = connStockLvl.prepareStatement("SELECT name, sku, category, stock, COALESCE(reorder_level, 10) as reorder_level FROM products ORDER BY stock DESC LIMIT 10");
                  ResultSet rsSLvl = psSLvl.executeQuery(); boolean hasStockLevels = false;
                  while (rsSLvl.next()) { hasStockLevels = true; int stock = rsSLvl.getInt("stock"); int reorderLvl = rsSLvl.getInt("reorder_level");
                      String statusClass = (stock <= 0) ? "out-of-stock" : (stock <= reorderLvl) ? "low-stock" : "in-stock";
                      String statusText = (stock <= 0) ? "Out of Stock" : (stock <= reorderLvl) ? "Low Stock" : "In Stock"; %>
              <tr><td><%= rsSLvl.getString("name") %></td><td><%= rsSLvl.getString("sku") != null ? rsSLvl.getString("sku") : "N/A" %></td><td><%= rsSLvl.getString("category") != null ? rsSLvl.getString("category") : "N/A" %></td><td><%= stock %></td><td><%= reorderLvl %></td><td><span class="status-badge <%= statusClass %>"><%= statusText %></span></td><td><button class="action-btn" title="Adjust Stock">📝</button></td></tr>
            <% } if (!hasStockLevels) out.println("<tr><td colspan='7' class='text-center'>No stock data.</td></tr>");
                  rsSLvl.close(); psSLvl.close();
              } catch (Exception ex) { out.println("<tr><td colspan='7' class='text-danger text-center'>Error: " + ex.getMessage() + "</td></tr>"); } 
              finally { if (connStockLvl != null) try { connStockLvl.close(); } catch (SQLException e) { /* log e */ } }
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
    categoryItems.forEach(item => { item.addEventListener('click', () => { categoryItems.forEach(i => i.classList.remove('active')); item.classList.add('active'); console.log('Category filter:', item.textContent); }); });
  </script>
</body>
</html>