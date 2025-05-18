<%--
    Document   : Cashi_report
    Created on : May 18, 2025, (Current Time)
    Author     : NGC (or your name)
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%-- Duplicate import, but keeping as per original --%>
<%@page import="java.sql.*"%> 

<!DOCTYPE html>
<html lang="en">
<head>
    <script type="text/javascript" src="https://www.gstatic.com/charts/loader.js"></script>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cashier Report</title> <%-- Changed title --%>
    <script src="script.js"></script> <%-- Ensure script.js is accessible --%>
  
   
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
    <link rel="Stylesheet" href="styles.css">
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

            <ul class="menu">
                <li class="menu-item active">
                    <i class="fas fa-shopping-cart"></i>
                    <span>Sales</span>
                </li>
                <li class="menu-item">
                    <i class="fas fa-box"></i>
                    <span>Products</span>
                </li>
                <li class="menu-item">
                    <i class="fas fa-chart-bar"></i>
                    <span>Reports</span>
                </li>
                <li class="menu-item">
                    <i class="fas fa-warehouse"></i>
                    <span>Inventory</span>
                </li>
                <li class="menu-item">
                    <i class="fas fa-receipt"></i>
                    <span>Transactions</span>
                </li>
                <li class="menu-item">
                    <i class="fas fa-cog"></i>
                    <span>Settings</span>
                </li>
                <li class="menu-item">
                    <a href="${pageContext.request.contextPath}/logoutAction" style="text-decoration: none; color: inherit;">
                        <i class="fas fa-sign-out-alt"></i>
                        <span>Logout</span>
                    </a>
                </li>
            </ul>
        </div>
 <div class="main-content">
      <div class="header">
        <h1 class="page-title">Cashier Reports</h1>
        <div class="user-profile">
          <img src="../Images/logo.png" alt="Admin Profile">
          <div>
            <h4>Admin User</h4>
          </div>
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
        String URL = "jdbc:mysql://localhost:3306/Swift_Database";
        String USER = "root";
        String PASSWORD = "";

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