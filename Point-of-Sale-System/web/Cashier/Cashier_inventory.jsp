<%-- 
    Document   : Cashier_inventory
    Created on : May 18, 2025, 10:25:26 PM
    Author     : NGC
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.NumberFormat" %>
<%@ page import="java.util.Locale" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Inventory Reports - Swift POS</title>
  <script src="script.js"></script>
  <link rel="Stylesheet" href="styles.css">
 
  <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
  <style>
    /* Report-specific styles */
    .report-container {
      background-color: white;
      border-radius: 8px;
      padding: 20px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
      margin-bottom: 20px;
    }
    
    .report-options {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 15px;
      margin-bottom: 20px;
    }
    
    .option-group {
      display: flex;
      flex-direction: column;
    }
    
    .option-group label {
      font-weight: 500;
      margin-bottom: 8px;
      color: var(--secondary);
    }
    
    .option-group select,
    .option-group input {
      padding: 10px;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      font-size: 14px;
    }
    
    .preview-container {
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      padding: 20px;
      margin-top: 20px;
      min-height: 400px;
      background-color: #f8fafc;
    }
    
    .report-preview-header {
      text-align: center;
      margin-bottom: 20px;
      padding-bottom: 15px;
      border-bottom: 1px solid #e2e8f0;
    }
    
    .report-title {
      font-size: 18px;
      font-weight: 600;
      margin-bottom: 5px;
    }
    
    .report-subtitle {
      font-size: 14px;
      color: var(--secondary);
    }
    
    .report-actions {
      display: flex;
      justify-content: space-between;
      margin-top: 20px;
      flex-wrap: wrap;
      gap: 10px;
    }
    
    .report-button {
      padding: 10px 15px;
      border-radius: 6px;
      font-weight: 500;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      min-width: 120px;
      justify-content: center;
    }
    
    .generate-btn {
      background-color: var(--primary);
      color: white;
      border: none;
    }
    
    .secondary-btn {
      background-color: white;
      color: var(--dark);
      border: 1px solid #e2e8f0;
    }
    
    .report-tabs {
      display: flex;
      border-bottom: 1px solid #e2e8f0;
      margin-bottom: 20px;
    }
    
    .report-tab {
      padding: 10px 15px;
      cursor: pointer;
      font-weight: 500;
    }
    
    .report-tab.active {
      border-bottom: 2px solid var(--primary);
      color: var(--primary);
    }
    
    .preview-placeholder {
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      height: 300px;
      color: var(--secondary);
    }
    
    .placeholder-icon {
      font-size: 36px;
      margin-bottom: 15px;
      opacity: 0.5;
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
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
      text-align: center;
    }
    
    .summary-title {
      font-size: 14px;
      color: var(--secondary);
      margin-bottom: 8px;
    }
    
    .summary-value {
      font-size: 24px;
      font-weight: 600;
    }
    
    /* Visualization Styles */
    .visualization-container {
      background-color: white;
      border-radius: 8px;
      padding: 20px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
      margin-bottom: 20px;
    }
    
    .charts-row {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 20px;
      margin-bottom: 20px;
    }
    
    .chart-container {
      min-height: 300px;
      background-color: #f8fafc;
      border-radius: 8px;
      padding: 15px;
      border: 1px solid #e2e8f0;
    }
    
    .chart-selector {
      display: flex;
      margin-bottom: 15px;
      border-bottom: 1px solid #e2e8f0;
      padding-bottom: 10px;
    }
    
    .chart-type {
      padding: 8px 15px;
      cursor: pointer;
      font-weight: 500;
      font-size: 14px;
    }
    
    .chart-type.active {
      border-bottom: 2px solid var(--primary);
      color: var(--primary);
    }
    
    @media (max-width: 992px) {
      .charts-row {
        grid-template-columns: 1fr;
      }
    }
    
    @media (max-width: 768px) {
      .report-actions {
        flex-direction: column;
      }
      
      .report-button {
        width: 100%;
      }
    }
    
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
        .menu {
        list-style: none;
      }

      .menu-item {
        display: flex;
        align-items: center;
        padding: 12px 20px;
        cursor: pointer;
        transition: all 0.3s ease;
      }

      .menu-item:hover {
        background-color: rgba(255, 255, 255, 0.1);
      }

      .menu-item.active {
        background-color: var(--primary);
      }

      .menu-item i {
        margin-right: 15px;
        width: 20px;
        text-align: center;
      }

      .menu-item span {
        font-weight: 500;
      }

    </style>
</head>
<body>
   <div class="mobile-top-bar">
        <div class="mobile-logo">
            <img src="<%= request.getContextPath() %>/Images/logo.png" alt="POS Logo" class="logo-img"> <%-- Use context path --%>
            <h2>Swift</h2>
        </div>
        <button class="mobile-nav-toggle" id="mobileNavToggle">
            <i class="fas fa-bars"></i>
        </button>
    </div>

    <div class="dashboard">
        <div class="sidebar" id="sidebar">
            <div class="logo">
                <img src="<%= request.getContextPath() %>/Images/logo.png" alt="POS Logo" class="logo-img"> <%-- Use context path --%>
                <h2>Swift</h2>
            </div>
                <jsp:include page="menu.jsp" />
            
        </div>
 <div class="main-content">
      <div class="header">
        <h1 class="page-title">Cashier_inventory</h1>
        <div class="user-profile">
          <img src="../Images/logo.png" alt="Admin Profile">
          <div>
            <h4>Admin User</h4>
          </div>
        </div>
      </div>
  
          <%
        // Database connection details
        String DB_URL = "jdbc:mysql://localhost:3306/Swift_Database"; 
        String DB_USER = "root"; 
        String DB_PASSWORD = ""; 
        
        // Initialize variables for report data
        int totalProducts = 0;
        double totalInventoryValue = 0;
        int lowStockItems = 0;
        int outOfStockItems = 0;
        
        // Initialize variables for chart data
        Map<String, Integer> categoryProductCounts = new HashMap<>();
        Map<String, Double> categoryValues = new HashMap<>();
        
        Connection conn = null;
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
            
            // Get total products count
            PreparedStatement psTotalProducts = conn.prepareStatement("SELECT COUNT(*) AS total FROM products");
            ResultSet rsTotalProducts = psTotalProducts.executeQuery();
            if (rsTotalProducts.next()) {
                totalProducts = rsTotalProducts.getInt("total");
            }
            
            // Get total inventory value
            PreparedStatement psTotalValue = conn.prepareStatement("SELECT SUM(stock * price) AS total_value FROM products");
            ResultSet rsTotalValue = psTotalValue.executeQuery();
            if (rsTotalValue.next()) {
                totalInventoryValue = rsTotalValue.getDouble("total_value");
            }
            
            // Get low stock items count
            PreparedStatement psLowStock = conn.prepareStatement("SELECT COUNT(*) AS low_stock FROM products WHERE stock <= 10 AND stock > 0");
            ResultSet rsLowStock = psLowStock.executeQuery();
            if (rsLowStock.next()) {
                lowStockItems = rsLowStock.getInt("low_stock");
            }
            
            // Get out of stock items count
            PreparedStatement psOutOfStock = conn.prepareStatement("SELECT COUNT(*) AS out_of_stock FROM products WHERE stock = 0");
            ResultSet rsOutOfStock = psOutOfStock.executeQuery();
            if (rsOutOfStock.next()) {
                outOfStockItems = rsOutOfStock.getInt("out_of_stock");
            }
            
            // Get product counts by category (for charts)
            PreparedStatement psCategoryCount = conn.prepareStatement("SELECT category, COUNT(*) as count FROM products GROUP BY category");
            ResultSet rsCategoryCount = psCategoryCount.executeQuery();
            while(rsCategoryCount.next()) {
                categoryProductCounts.put(rsCategoryCount.getString("category"), rsCategoryCount.getInt("count"));
            }
            
            // Get inventory value by category (for charts)
            PreparedStatement psCategoryValue = conn.prepareStatement("SELECT category, SUM(stock * price) as value FROM products GROUP BY category");
            ResultSet rsCategoryValue = psCategoryValue.executeQuery();
            while(rsCategoryValue.next()) {
                categoryValues.put(rsCategoryValue.getString("category"), rsCategoryValue.getDouble("value"));
            }
            
        } catch (Exception e) {
            // Handle exception
            out.println("<div class='alert alert-danger'>Error connecting to database: " + e.getMessage() + "</div>");
        } finally {
            if (conn != null) {
                try { conn.close(); } catch (SQLException e) { /* ignore */ }
            }
        }
        
        Locale sriLankaLocale = new Locale("en", "LK");
        NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(sriLankaLocale);
        String formattedTotalValue = currencyFormatter.format(totalInventoryValue);
      %>
      
      <div class="report-summary">
        <div class="summary-card">
          <div class="summary-title">TOTAL PRODUCTS</div>
          <div class="summary-value"><%= totalProducts %></div>
        </div>
        <div class="summary-card">
          <div class="summary-title">INVENTORY VALUE</div>
          <div class="summary-value"><%= formattedTotalValue %></div>
        </div>
        <div class="summary-card">
          <div class="summary-title">LOW STOCK ITEMS</div>
          <div class="summary-value"><%= lowStockItems %></div>
        </div>
        <div class="summary-card">
          <div class="summary-title">OUT OF STOCK</div>
          <div class="summary-value"><%= outOfStockItems %></div>
        </div>
      </div>
      
      <!-- Visualization Section -->
      <div class="visualization-container">
        <h2 style="margin-bottom: 15px;">Inventory Visualization</h2>
        
        <div class="charts-row">
          <div class="chart-wrapper">
            <div class="chart-selector">
              <div class="chart-type active" data-chart="category-distribution">Category Distribution</div>
              <div class="chart-type" data-chart="stock-status">Stock Status</div>
            </div>
            <div class="chart-container" id="chart1"></div>
          </div>
          
          <div class="chart-wrapper">
            <div class="chart-selector">
              <div class="chart-type active" data-chart="inventory-value">Inventory Value</div>
              <div class="chart-type" data-chart="stock-trend">Stock Trend</div>
            </div>
            <div class="chart-container" id="chart2"></div>
          </div>
        </div>
        
        <div class="chart-wrapper">
          <div class="chart-selector">
            <div class="chart-type active" data-chart="category-value-comparison">Category Value Comparison</div>
          </div>
          <div class="chart-container" id="chart3" style="height: 350px;"></div>
        </div>
      </div>
      
      <div class="report-container">
        <div class="report-tabs">
          <div class="report-tab active">Stock Status</div>
          <div class="report-tab">Valuation</div>
          <div class="report-tab">Movement History</div>
          <div class="report-tab">Category Analysis</div>
        </div>
        
        <div class="report-options">
          <div class="option-group">
            <label for="report-type">Report Type</label>
            <select id="report-type">
              <option value="stock_level">Stock Level Report</option>
              <option value="low_stock">Low Stock Report</option>
              <option value="out_of_stock">Out of Stock Report</option>
              <option value="valuation">Inventory Valuation</option>
              <option value="movement">Stock Movement History</option>
            </select>
          </div>
          
          <div class="option-group">
            <label for="category-filter">Category</label>
            <select id="category-filter">
              <option value="all">All Categories</option>
              <option value="beverages">Beverages</option>
              <option value="bakery">Bakery</option>
              <option value="dairy">Dairy</option>
              <option value="snacks">Snacks</option>
              <option value="packaging">Packaging</option>
              <option value="equipment">Equipment</option>
              <option value="others">Others</option>
            </select>
          </div>
          
          <div class="option-group">
            <label for="date-from">Date From</label>
            <input type="date" id="date-from">
          </div>
          
          <div class="option-group">
            <label for="date-to">Date To</label>
            <input type="date" id="date-to">
          </div>
        </div>
        
        <div class="report-actions">
          <div>
            <button class="report-button generate-btn" onclick="generateReport()">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path><polyline points="7 10 12 15 17 10"></polyline><line x1="12" y1="15" x2="12" y2="3"></line></svg>
              Generate Report
            </button>
          </div>
          <div style="display: flex; gap: 10px;">
            <button class="report-button secondary-btn" onclick="exportPDF()">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline><line x1="16" y1="13" x2="8" y2="13"></line><line x1="16" y1="17" x2="8" y2="17"></line><polyline points="10 9 9 9 8 9"></polyline></svg>
              Export PDF
            </button>
            <button class="report-button secondary-btn" onclick="exportExcel()">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="3" y="3" width="18" height="18" rx="2" ry="2"></rect><line x1="3" y1="9" x2="21" y2="9"></line><line x1="3" y1="15" x2="21" y2="15"></line><line x1="9" y1="3" x2="9" y2="21"></line><line x1="15" y1="3" x2="15" y2="21"></line></svg> 
              Export Excel
            </button>
          </div>
        </div>
        
        <div class="preview-container">
          <div class="report-preview-header">
            <div class="report-title">Stock Level Report</div>
            <div class="report-subtitle">Generated on <%= new java.text.SimpleDateFormat("MMMM d, yyyy").format(new java.util.Date()) %></div>
          </div>
          
          <div id="report-preview-content">
            <!-- Report preview will be loaded here after generating -->
            <div class="preview-placeholder">
              <div class="placeholder-icon">📊</div>
              <p>Select options and click "Generate Report" to preview</p>
            </div>
          </div>
        </div>
      </div>
      
      <div class="footer">Swift POS © <%= java.time.Year.now().getValue() %>.</div>
    </div>
  </div>
  
  <script>
    // Mobile navigation toggle
    const mobileNavToggle = document.getElementById('mobileNavToggle');
    const sidebar = document.getElementById('sidebar');
    
    if (mobileNavToggle && sidebar) {
      mobileNavToggle.addEventListener('click', () => {
        sidebar.classList.toggle('active');
      });
    }
    
    // Close sidebar when clicking outside
    document.addEventListener('click', function(event) {
      if (sidebar && sidebar.classList.contains('active') && 
          !sidebar.contains(event.target) && 
          !mobileNavToggle.contains(event.target)) {
        sidebar.classList.remove('active');
      }
    });
    
    // Google Charts implementation
    google.charts.load('current', {'packages':['corechart', 'bar']});
    google.charts.setOnLoadCallback(drawCharts);
    
    function drawCharts() {
      drawCategoryDistribution();
      drawInventoryValue();
      drawCategoryValueComparison();
      
      // Add chart switching functionality
      const chartTypes = document.querySelectorAll('.chart-type');
      chartTypes.forEach(type => {
        type.addEventListener('click', function() {
          const chartWrapper = this.closest('.chart-wrapper');
          const chartTypes = chartWrapper.querySelectorAll('.chart-type');
          chartTypes.forEach(t => t.classList.remove('active'));
          this.classList.add('active');
          
          const chartId = chartWrapper.querySelector('.chart-container').id;
          const chartType = this.getAttribute('data-chart');
          
          switch(chartType) {
            case 'category-distribution':
              drawCategoryDistribution();
              break;
            case 'stock-status':
              drawStockStatus();
              break;
            case 'inventory-value':
              drawInventoryValue();
              break;
            case 'stock-trend':
              drawStockTrend();
              break;
            case 'category-value-comparison':
              drawCategoryValueComparison();
              break;
          }
        });
      });
    }
    
    function drawCategoryDistribution() {
      // Data would typically come from the database via JSP variables
      // For this example, we'll use the data that was fetched in the JSP section
      var data = google.visualization.arrayToDataTable([
        ['Category', 'Products'],
        // In a real implementation, this would use the categoryProductCounts data from JSP
        ['Beverages', 12],
        ['Bakery', 8],
        ['Dairy', 5],
        ['Packaging', 10],
        ['Equipment', 6],
        ['Others', 3]
      ]);
      
      var options = {
        title: 'Product Distribution by Category',
        pieHole: 0.4,
        colors: ['#4285F4', '#DB4437', '#F4B400', '#0F9D58', '#AB47BC', '#00ACC1'],
        chartArea: {width: '100%', height: '80%'},
        legend: {position: 'bottom'}
      };
      
      var chart = new google.visualization.PieChart(document.getElementById('chart1'));
      chart.draw(data, options);
    }
    
    function drawStockStatus() {
      // Simulated data for stock status chart
      var data = google.visualization.arrayToDataTable([
        ['Status', 'Items', { role: 'style' }],
        ['In Stock', <%= totalProducts - lowStockItems - outOfStockItems %>, '#4CAF50'],
        ['Low Stock', <%= lowStockItems %>, '#FFC107'],
        ['Out of Stock', <%= outOfStockItems %>, '#F44336']
      ]);
      
      var options = {
        title: 'Stock Status Overview',
        legend: { position: 'none' },
        chartArea: {width: '90%', height: '70%'},
        hAxis: {
          title: 'Number of Items',
          minValue: 0
        },
        vAxis: {
          title: 'Status'
        }
      };
      
      var chart = new google.visualization.BarChart(document.getElementById('chart1'));
      chart.draw(data, options);
    }
    
    function drawInventoryValue() {
      // Data would come from the categoryValues map in JSP
      var data = google.visualization.arrayToDataTable([
        ['Category', 'Inventory Value'],
        ['Beverages', 135620],
        ['Bakery', 42300],
        ['Dairy', 22780],
        ['Packaging', 76190],
        ['Equipment', 54320],
        ['Others', 15690]
      ]);
      
      var options = {
        title: 'Inventory Value by Category',
        pieHole: 0,
        is3D: true,
        colors: ['#4285F4', '#DB4437', '#F4B400', '#0F9D58', '#AB47BC', '#00ACC1'],
        chartArea: {width: '100%', height: '80%'},
        legend: {position: 'bottom'}
      };
      
      var chart = new google.visualization.PieChart(document.getElementById('chart2'));
      chart.draw(data, options);
    }
    
    function drawStockTrend() {
      // Simulated stock trend data (would be from historical data in a real implementation)
      var data = google.visualization.arrayToDataTable([
        ['Date', 'Stock Level'],
        ['Apr 18', 210],
        ['Apr 25', 245],
        ['May 2', 236],
        ['May 9', 258],
        ['May 16', 264],
        ['May 18', <%= totalProducts %>]
      ]);
      
      var options = {
        title: 'Inventory Stock Level Trend',
        curveType: 'function',
        legend: { position: 'bottom' },
        chartArea: {width: '90%', height: '70%'},
        colors: ['#4285F4'],
        hAxis: {
          title: 'Date'
        },
        vAxis: {
          title: 'Total Products'
        }
      };
      
      var chart = new google.visualization.LineChart(document.getElementById('chart2'));
      chart.draw(data, options);
    }
    
    function drawCategoryValueComparison() {
      // Comparing product counts vs inventory value by category
      var data = google.visualization.arrayToDataTable([
        ['Category', 'Product Count', 'Inventory Value (in thousands)'],
        ['Beverages', 12, 135.62],
        ['Bakery', 8, 42.30],
        ['Dairy', 5, 22.78],
        ['Packaging', 10, 76.19],
        ['Equipment', 6, 54.32],
        ['Others', 3, 15.69]
      ]);
      
      var options = {
        title: 'Category Comparison: Product Count vs. Inventory Value',
        chartArea: {width: '80%', height: '70%'},
        hAxis: {
          title: 'Category'
        },
        vAxis: {
          title: 'Count / Value'
        },
        seriesType: 'bars',
        series: {1: {type: 'line'}}
      };
      
      var chart = new google.visualization.ComboChart(document.getElementById('chart3'));
      chart.draw(data, options);
    }
    
    // Tab switching functionality
    const reportTabs = document.querySelectorAll('.report-tab');
    reportTabs.forEach(tab => {
      tab.addEventListener('click', () => {
        reportTabs.forEach(t => t.classList.remove('active'));
        tab.classList.add('active');
        
        // Update report type based on selected tab
        const reportTypeSelect = document.getElementById('report-type');
        switch(tab.textContent) {
          case 'Stock Status':
            reportTypeSelect.value = 'stock_level';
            break;
          case 'Valuation':
            reportTypeSelect.value = 'valuation';
            break;
          case 'Movement History':
            reportTypeSelect.value = 'movement';
            break;
          case 'Category Analysis':
            reportTypeSelect.value = 'category_analysis';
            break;
        }
      });
    });
    
    // Set current date as default for Date To field
    document.addEventListener('DOMContentLoaded', function() {
      const today = new Date();
      const dateToInput = document.getElementById('date-to');
      dateToInput.valueAsDate = today;
      
      // Set date from to 30 days ago
      const thirtyDaysAgo = new Date();
      thirtyDaysAgo.setDate(today.getDate() - 30);
      const dateFromInput = document.getElementById('date-from');
      dateFromInput.valueAsDate = thirtyDaysAgo;
      
      // Make sure Google Charts are drawn when all content is loaded
      if (google.visualization) {
        drawCharts();
      }
      
      // Responsive chart redraw on window resize
      window.addEventListener('resize', function() {
        if (google.visualization) {
          const activeCharts = document.querySelectorAll('.chart-type.active');
          activeCharts.forEach(chart => {
            const chartType = chart.getAttribute('data-chart');
            switch(chartType) {
              case 'category-distribution':
                drawCategoryDistribution();
                break;
              case 'stock-status':
                drawStockStatus();
                break;
              case 'inventory-value':
                drawInventoryValue();
                break;
              case 'stock-trend':
                drawStockTrend();
                break;
              case 'category-value-comparison':
                drawCategoryValueComparison();
                break;
            }
          });
        }
      });
    });
    
    // Generate report function
    function generateReport() {
      const reportType = document.getElementById('report-type').value;
      const category = document.getElementById('category-filter').value;
      const dateFrom = document.getElementById('date-from').value;
      const dateTo = document.getElementById('date-to').value;
      
      // Update report title
      updateReportTitle(reportType);
      
      // Show loading state
      const previewContent = document.getElementById('report-preview-content');
      previewContent.innerHTML = '<div style="text-align:center; padding:40px;"><p>Loading report data...</p></div>';
      
      // Simulate loading data with setTimeout
      setTimeout(() => {
        // In a real app, you would fetch data from server based on selected options
        previewContent.innerHTML = generateReportHTML(reportType, category, dateFrom, dateTo);
      }, 800);
    }
    
    function updateReportTitle(reportType) {
      const reportTitle = document.querySelector('.report-title');
      switch(reportType) {
        case 'stock_level':
          reportTitle.textContent = 'Stock Level Report';
          break;
        case 'low_stock':
          reportTitle.textContent = 'Low Stock Report';
          break;
        case 'out_of_stock':
          reportTitle.textContent = 'Out of Stock Report';
          break;
        case 'valuation':
          reportTitle.textContent = 'Inventory Valuation Report';
          break;
        case 'movement':
          reportTitle.textContent = 'Stock Movement History Report';
          break;
        default:
          reportTitle.textContent = 'Inventory Report';
      }
    }
    
    // The most critical issue is in the report generation function:
function generateReportHTML(reportType, category, dateFrom, dateTo) {
  // This is a simplified demo - in a real app, you would generate this from actual database data
  let html = '<table><thead><tr>';
  
  switch(reportType) {
    case 'stock_level':
      html += '<th>Product</th><th>SKU</th><th>Category</th><th>Current Stock</th><th>Reorder Level</th><th>Status</th>';
      html += '</tr></thead><tbody>';
      html += '<tr><td>Espresso Coffee Blend</td><td>COF-001</td><td>Beverages</td><td>42</td><td>10</td><td><span class="status-badge in-stock">In Stock</span></td></tr>';
      // More rows added...
      break;
      
    // Other case statements...
      
    default:
      html += '<th>No report data available</th>';
      html += '</tr></thead><tbody>';
      html += '<tr><td>Please select a valid report type</td></tr>';
  }
  
  html += '</tbody></table>';
  return html;  // This returns without completing HTML for most report types!
}
  </script>
</body>
</html>