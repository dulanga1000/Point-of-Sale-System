<%-- 
    Document   : sales_report
    Created on : May 17, 2025, 10:15:22 AM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@page import="java.sql.*"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Sales Reports</title>
  <script src="script.js"></script>
  <link rel="Stylesheet" href="styles.css">
  <style>
    /* Additional styles specific to sales reports */
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

  </style>
</head>
<body>
  <!-- Mobile Top Bar (visible on mobile only) -->
  <div class="mobile-top-bar">
    <div class="mobile-logo">
      <img src="${pageContext.request.contextPath}/Images/logo.png" alt="POS Logo">
      <h2>Swift</h2>
    </div>
    <button class="mobile-nav-toggle" id="mobileNavToggle">☰</button>
  </div>
  
  <div class="dashboard">
    <!-- Sidebar -->
    <div class="sidebar" id="sidebar">
      <div class="logo">
        <img src="${pageContext.request.contextPath}/Images/logo.png" alt="POS Logo">
        <h2>Swift</h2>
      </div>
      <jsp:include page="menu.jsp" />
    </div>
    
    <!-- Main Content -->
    <div class="main-content">
      <div class="header">
        <h1 class="page-title">Sales Reports</h1>
        <div class="user-profile">
          <%
    Connection userConn = null;
    String URL = "jdbc:mysql://localhost:3306/Swift_Database";
    String USER = "root";
    String PASSWORD = "";

    try {
        Class.forName("com.mysql.jdbc.Driver"); // Load the driver explicitly
        userConn = DriverManager.getConnection(URL, USER, PASSWORD);
        PreparedStatement sql = userConn.prepareStatement("SELECT * FROM users WHERE role = 'admin' LIMIT 1");
        ResultSet result = sql.executeQuery();

        if (result.next()) { %>
            <img src="${pageContext.request.contextPath}/<%= result.getString("profile_image_path") %>" alt="Admin Profile">
            <div>
                <h4><%= result.getString("first_name") %></h4>
            </div>
        <% }
        result.close();
        sql.close();
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
      
      <!-- Report Filters -->
      <div class="report-filters">
        <div class="filter-item">
          <label for="report-type">Report Type</label>
          <select id="report-type">
            <option value="daily">Daily Sales</option>
            <option value="weekly">Weekly Sales</option>
            <option value="monthly" selected>Monthly Sales</option>
            <option value="yearly">Yearly Sales</option>
          </select>
        </div>
        
        <div class="filter-item">
          <label for="date-range">Date Range</label>
          <select id="date-range">
            <option value="this-month">This Month</option>
            <option value="last-month">Last Month</option>
            <option value="last-3-months">Last 3 Months</option>
            <option value="custom">Custom Range</option>
          </select>
        </div>
        
        <div class="filter-item">
          <label for="start-date">Start Date</label>
          <input type="date" id="start-date" value="2025-04-01">
        </div>
        
        <div class="filter-item">
          <label for="end-date">End Date</label>
          <input type="date" id="end-date" value="2025-04-30">
        </div>
        
        <div class="filter-item">
          <label for="cashier">Cashier</label>
          <select id="cashier">
            <option value="all">All Cashiers</option>
            <option value="1">John Doe</option>
            <option value="2">Emma Wilson</option>
            <option value="3">Michael Brown</option>
            <option value="4">Sarah Johnson</option>
          </select>
        </div>
        
        <div class="filter-buttons">
          <button class="btn btn-primary">Generate Report</button>
          <button class="btn btn-outline">Reset Filters</button>
        </div>
      </div>
      
      <!-- Report Actions -->
      <div class="report-actions">
        <div class="report-option">
          <i>📊</i> View as Chart
        </div>
        <div class="report-option">
          <i>📋</i> View as Table
        </div>
        <div class="report-option">
          <i>📄</i> Export PDF
        </div>
        <div class="report-option">
          <i>📊</i> Export Excel
        </div>
      </div>
      
      <!-- Report Summary -->
      <div class="report-summary">
        <div class="summary-card">
          <div class="summary-title">TOTAL SALES</div>
          <div class="summary-value">Rs.42,085</div>
          <div class="summary-change trend up">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            8.2% from last month
          </div>
        </div>
        
        <div class="summary-card">
          <div class="summary-title">TOTAL ORDERS</div>
          <div class="summary-value">386</div>
          <div class="summary-change trend up">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            12.4% from last month
          </div>
        </div>
        
        <div class="summary-card">
          <div class="summary-title">AVERAGE ORDER VALUE</div>
          <div class="summary-value">Rs.109</div>
          <div class="summary-change trend down">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="6 9 12 15 18 9"></polyline>
            </svg>
            3.8% from last month
          </div>
        </div>
        
        <div class="summary-card">
          <div class="summary-title">BEST SELLING DAY</div>
          <div class="summary-value">Saturday</div>
          <div class="summary-change">Rs.7,654 in sales</div>
        </div>
      </div>
      
      <!-- Charts -->
      <div class="chart-container">
<div class="chart-card">
    <div class="chart-header">
        <div class="chart-title">Product Categories Distribution</div>
    </div>
    <div id="categoryPieChart" class="chart"></div>
    
     <%-- Database connection test (hidden by default) --%>
    <div style="display:none;">
        <%
        String dbStatus = "";
        try {
            Class.forName("com.mysql.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/swift_database", 
                "root", 
                "");
            
            if(conn != null && !conn.isClosed()) {
                dbStatus = "Database connection successful";
                
                Statement testStmt = conn.createStatement();
                ResultSet testRs = testStmt.executeQuery("SELECT COUNT(*) FROM products");
                if(testRs.next()) {
                    dbStatus += " | Found " + testRs.getInt(1) + " products";
                }
                testRs.close();
                testStmt.close();
            }
            conn.close();
        } catch(Exception e) {
            dbStatus = "DB Connection Failed: " + e.getMessage();
            e.printStackTrace();
        }
        %>
        <%= dbStatus %>
    </div>
</div>

        
        <div class="chart-card">
          <div class="chart-header">
            <div class="chart-title">Top Selling Products</div>
          </div>
          <div class="top-products">
            <div class="product-item">
              <div class="product-info">
                <div class="product-name">Premium Coffee Beans</div>
                <div class="product-sales">124 units sold</div>
              </div>
              <div class="product-percentage">24%</div>
            </div>
            
            <div class="product-item">
              <div class="product-info">
                <div class="product-name">Organic Milk 1L</div>
                <div class="product-sales">98 units sold</div>
              </div>
              <div class="product-percentage">19%</div>
            </div>
            
            <div class="product-item">
              <div class="product-info">
                <div class="product-name">Chocolate Syrup</div>
                <div class="product-sales">87 units sold</div>
              </div>
              <div class="product-percentage">16%</div>
            </div>
            
            <div class="product-item">
              <div class="product-info">
                <div class="product-name">Vanilla Coffee</div>
                <div class="product-sales">65 units sold</div>
              </div>
              <div class="product-percentage">12%</div>
            </div>
            
            <div class="product-item">
              <div class="product-info">
                <div class="product-name">Caramel Latte</div>
                <div class="product-sales">52 units sold</div>
              </div>
              <div class="product-percentage">10%</div>
            </div>
            
            <div class="product-item">
              <div class="product-info">
                <div class="product-name">Espresso Shot</div>
                <div class="product-sales">43 units sold</div>
              </div>
              <div class="product-percentage">8%</div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Detailed Sales Table -->
      <div class="module-card">
        <div class="module-header">
          Sales Details
        </div>
        <div class="module-content">
          <table>
            <thead>
                    <tr>
                <th>Date</th>
                <th>Order ID</th>
                <th>Cashier</th>
                <th>Items</th>
                <th>Payment Method</th>
                <th>Total (Rs.)</th>
                  </tr>
            </thead>
             <tbody>
    <%

        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            PreparedStatement sql = conn.prepareStatement("SELECT * FROM orders");
            ResultSet result = sql.executeQuery();

            if (result.isBeforeFirst()) {  // Check if there are any results
                while (result.next()) { %>
                    <tr>
                        <td><%= result.getString("order_date") %></td>
                        <td>#ORD-<%= result.getString("order_id") %></td>
                        <td><%= result.getString("cashier_name") %></td>
                        <td><%= result.getString("items") %></td>
                        <td><%= result.getString("payment_method") %></td>
                        <td><%= String.format("%.2f", result.getDouble("total")) %></td>
                    </tr>
                <% }
            } else { %>
                <tr><td colspan="6" style="text-align:center;">No orders found</td></tr>
            <% }
            conn.close();
        } catch (Exception ex) {
            out.println("<p class='text-danger text-center'>Error: " + ex.getMessage() + "</p>");
        }
    %>
</tbody>
          </table>
        </div>
      </div>
      
      <!-- Pagination -->
      <div style="display: flex; justify-content: center; margin-top: 20px;">
        <div style="display: flex; gap: 5px;">
          <button class="btn btn-outline" style="padding: 5px 10px;">&lt;</button>
          <button class="btn" style="padding: 5px 12px; background-color: var(--primary); color: white;">1</button>
          <button class="btn btn-outline" style="padding: 5px 12px;">2</button>
          <button class="btn btn-outline" style="padding: 5px 12px;">3</button>
          <button class="btn btn-outline" style="padding: 5px 12px;">4</button>
          <button class="btn btn-outline" style="padding: 5px 12px;">5</button>
          <button class="btn btn-outline" style="padding: 5px 10px;">&gt;</button>
        </div>
      </div>
      
      <div class="footer">
        Swift © 2025.
      </div>
    </div>
  </div>
            <servlet>
    <servlet-name>SalesReportServlet</servlet-name>
    <servlet-class>com.example.servlet.SalesReportServlet</servlet-class>
</servlet>

<servlet-mapping>
    <servlet-name>SalesReportServlet</servlet-name>
    <url-pattern>/sappier_reports</url-pattern>
</servlet-mapping>

            
  
  <script>
    // Mobile menu toggle
    document.getElementById('mobileNavToggle').addEventListener('click', function() {
      document.getElementById('sidebar').classList.toggle('active');
    });
    
    // Date range dependent fields
    const dateRange = document.getElementById('date-range');
    const startDate = document.getElementById('start-date');
    const endDate = document.getElementById('end-date');
    
    dateRange.addEventListener('change', function() {
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
          start = new Date(today.getFullYear(), today.getMonth() - 3, 1);
          end = new Date(today.getFullYear(), today.getMonth(), 0);
          break;
        case 'custom':
          // Keep current values
          return;
      }
      
      startDate.value = formatDate(start);
      endDate.value = formatDate(end);
    });
    
    function formatDate(date) {
      const year = date.getFullYear();
      const month = String(date.getMonth() + 1).padStart(2, '0');
      const day = String(date.getDate()).padStart(2, '0');
      return `${year}-${month}-${day}`;
    }
    
    // Chart filter selection
    const chartFilters = document.querySelectorAll('.chart-filter');
    chartFilters.forEach(filter => {
      filter.addEventListener('click', function() {
        chartFilters.forEach(f => f.classList.remove('active'));
        this.classList.add('active');
      });
    });
    
    // card-chart
    
    // Load the Visualization API and the corechart package
    google.charts.load('current', {'packages':['corechart']});
    
    // Set a callback to run when the Google Visualization API is loaded
    google.charts.setOnLoadCallback(drawCategoryChart);
    
    function drawCategoryChart() {
        // Create a data table
        var data = new google.visualization.DataTable();
        data.addColumn('string', 'Category');
        data.addColumn('number', 'Count');
        
        // Get data from JSP
        <%
        try {
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/swift_database", 
                "root", 
                "");
            
            String sql = "SELECT category, COUNT(*) as count FROM products GROUP BY category";
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery(sql);
            
            while(rs.next()) {
                String category = rs.getString("category");
                // Properly escape JavaScript strings
                category = category.replace("'", "\\'").replace("\n", "\\n").replace("\r", "\\r");
        %>
                data.addRow(['<%= category %>', <%= rs.getInt("count") %>]);
        <%
            }
            conn.close();
        } catch(Exception e) {
            System.err.println("Error: " + e.getMessage());
            // Fallback data if database fails
            %>
            data.addRow(['Food', 5]);
            data.addRow(['Beverages', 2]);
            data.addRow(['Other', 1]);
            <%
        }
        %>
        
        // Set chart options
        var options = {
            title: 'Product Categories Distribution',
            pieHole: 0.4,
            pieSliceText: 'value',
            chartArea: {
                width: '90%', 
                height: '80%',
                left: "5%",
                top: "15%",
                right: "5%",
                bottom: "15%"
            },
            legend: {
                position: 'right',
                alignment: 'center',
                textStyle: {
                    fontSize: 12
                }
            },
            titleTextStyle: {
                fontSize: 16,
                bold: true
            },
            colors: ['#4285F4', '#EA4335', '#FBBC05', '#34A853', '#673AB7'],
            tooltip: {
                showColorCode: true,
                textStyle: {
                    fontSize: 12
                }
            },
            fontSize: 12
        };
        
        // Instantiate and draw the chart
        try {
            var chart = new google.visualization.PieChart(
                document.getElementById('categoryPieChart'));
            chart.draw(data, options);
            
            // Handle window resize
            window.addEventListener('resize', function() {
                chart.draw(data, options);
            });
        } catch (e) {
            console.error("Error drawing chart: ", e);
            document.getElementById('categoryPieChart').innerHTML = 
                '<div style="color:red;padding:20px;text-align:center;">' +
                'Chart failed to load. Check console for errors.</div>';
        }
    }

  </script>
</body>
</html>