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
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
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
    String URL = "jdbc:mysql://localhost:3306/Swift_Database";
    String USER = "root";
    String PASSWORD = ""; // Ensure this is secure or configured properly
    Connection conn = null;
    JSONArray categoryValueData = new JSONArray();

    try {
        // It's good practice to load the driver explicitly
        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(URL, USER, PASSWORD);

        // Query to get total value (stock * price) per category
        // Assuming 'products' table has 'category', 'stock', and 'price' columns
        String query = "SELECT category, SUM(stock * price) AS total_value FROM products GROUP BY category";
        PreparedStatement ps = conn.prepareStatement(query);
        ResultSet rs = ps.executeQuery();

        while (rs.next()) {
            JSONObject categoryData = new JSONObject();
            categoryData.put("category", rs.getString("category"));
            categoryData.put("value", rs.getDouble("total_value"));
            categoryValueData.put(categoryData);
        }
    } catch (Exception e) {
        // Log the error or display a user-friendly message
        // For production, use a logging framework
        // out.println("<p>Error fetching chart data: " + e.getMessage() + "</p>");
        // For now, we'll add some dummy data if there's an error to show chart structure
        JSONObject dummy1 = new JSONObject();
        dummy1.put("category", "Error Category 1");
        dummy1.put("value", 100);
        categoryValueData.put(dummy1);
        JSONObject dummy2 = new JSONObject();
        dummy2.put("category", "Error Category 2");
        dummy2.put("value", 200);
        categoryValueData.put(dummy2);
    } finally {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                // Log error
            }
        }
    }
%>

  <script type="text/javascript">
    google.charts.load('current', {'packages':['corechart']});
    google.charts.setOnLoadCallback(drawChart);

    function drawChart() {
      var data = new google.visualization.DataTable();
      data.addColumn('string', 'Category');
      data.addColumn('number', 'Inventory Value');

      // Get data from JSP (converted to JavaScript array)
      var chartDataFromJSP = <%= categoryValueData.toString() %>;
      
      if (chartDataFromJSP.length === 0) {
        // Handle case where there's no data
        document.getElementById('piechart_div').innerHTML = '<p style=\"text-align:center; color:grey;\">No inventory data available for categories.</p>';
        return;
      }


      for (var i = 0; i < chartDataFromJSP.length; i++) {
        data.addRow([chartDataFromJSP[i].category, chartDataFromJSP[i].value]);
      }

      var options = {
        title: 'Inventory Value by Category',
        //is3D: true, // Optional: for a 3D pie chart
        pieHole: 0.4, // Optional: for a donut chart
        legend: { position: 'bottom' },
         height: '100%', // Make chart responsive within its container
        width: '100%'   // Make chart responsive
      };

      var chart = new google.visualization.PieChart(document.getElementById('piechart_div'));
      chart.draw(data, options);

      // Add event listener for window resize to redraw the chart
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
        <h1 class="page-title">Inventory Dashboard</h1>
        <div class="user-profile">
          <img src="../Images/logo.png" alt="Admin Profile">
          <div>
            <h4>Admin User</h4>
          </div>
        </div>
      </div>
      
      <div class="inventory-metrics">
        <div class="metric-card">
          <div class="metric-title">TOTAL ITEMS</div>
          <div class="metric-value">458</div>
          <div class="metric-change positive">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            12 added this month
          </div>
        </div>
        
        <div class="metric-card">
          <div class="metric-title">LOW STOCK ITEMS</div>
          <div class="metric-value">28</div>
          <div class="metric-change negative">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="6 9 12 15 18 9"></polyline>
            </svg>
            5 more than last week
          </div>
        </div>
        
        <div class="metric-card">
          <div class="metric-title">INVENTORY VALUE</div>
          <div class="metric-value">Rs.1,248,350</div>
          <div class="metric-change positive">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            Rs.56,240 growth
          </div>
        </div>
        
        <div class="metric-card">
          <div class="metric-title">STOCK TURNOVER RATE</div>
          <div class="metric-value">4.7x</div>
          <div class="metric-change positive">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            0.3x increase
          </div>
        </div>
      </div>
      
      <div class="inventory-actions">
        <button class="action-button" onclick="window.location.href='add_product.jsp'">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
          Add New Item
        </button>
        
        <button class="action-button secondary" onclick="window.location.href='stock_adjustment.jsp'">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M17 3a2.828 2.828 0 1 1 4 4L7.5 20.5 2 22l1.5-5.5L17 3z"></path>
          </svg>
          Stock Adjustment
        </button>
        
        <button class="action-button secondary" onclick="window.location.href='inventory_reports.jsp'">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path>
            <polyline points="14 2 14 8 20 8"></polyline>
            <line x1="16" y1="13" x2="8" y2="13"></line>
            <line x1="16" y1="17" x2="8" y2="17"></line>
            <polyline points="10 9 9 9 8 9"></polyline>
          </svg>
          Generate Report
        </button>
        
        <button class="action-button secondary" onclick="window.location.href='purchases.jsp'">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <circle cx="9" cy="21" r="1"></circle>
            <circle cx="20" cy="21" r="1"></circle>
            <path d="M1 1h4l2.68 13.39a2 2 0 0 0 2 1.61h9.72a2 2 0 0 0 2-1.61L23 6H6"></path>
          </svg>
          Create Purchase Order
        </button>
      </div>
      
      <div class="inventory-filters">
        <div class="inventory-search">
          <input type="text" placeholder="Search by name, SKU, or category...">
          <button>
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="11" cy="11" r="8"></circle>
              <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
          </button>
        </div>
        
        <div class="filter-item">
          <div class="filter-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polygon points="22 3 2 3 10 12.46 10 19 14 21 14 12.46 22 3"></polygon>
            </svg>
          </div>
          Filters
        </div>
        
        <div class="filter-item">
          <div class="filter-icon">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <line x1="8" y1="6" x2="21" y2="6"></line>
              <line x1="8" y1="12" x2="21" y2="12"></line>
              <line x1="8" y1="18" x2="21" y2="18"></line>
              <line x1="3" y1="6" x2="3.01" y2="6"></line>
              <line x1="3" y1="12" x2="3.01" y2="12"></line>
              <line x1="3" y1="18" x2="3.01" y2="18"></line>
            </svg>
          </div>
          Sort By
        </div>
      </div>
      
      <div class="category-filter">
        <div class="category-item active">All Items</div>
        <div class="category-item">Beverages</div>
        <div class="category-item">Bakery</div>
        <div class="category-item">Dairy</div>
        <div class="category-item">Snacks</div>
        <div class="category-item">Packaging</div>
        <div class="category-item">Equipment</div>
        <div class="category-item">Others</div>
      </div>
      
      <div class="modules-container">
        <div class="module-card">
          <div class="module-header">
            Low Stock Alert
          </div>
          <div class="module-content">
            <ul class="low-stock-list">
            <%
              // Re-establish connection if closed or use a new one for this section
              Connection connLowStock = null;
              try {
                  connLowStock = DriverManager.getConnection(URL, USER, PASSWORD);
                  PreparedStatement sqlLowStock = connLowStock.prepareStatement("SELECT name, supplier, stock FROM products WHERE stock <= 9 "); // Assuming a reorder_level column or a fixed value
                  ResultSet resultLowStock = sqlLowStock.executeQuery();

                  while (resultLowStock.next()) { 
            %>
              <li class="stock-item">
                <div class="stock-info">
                  <span class="stock-name"><%= resultLowStock.getString("name") %></span>
                  <span class="stock-supplier"><%= resultLowStock.getString("supplier") %></span>
                </div>
                <div class="stock-quantity"><%= resultLowStock.getInt("stock") %> Items left</div>
              </li>
            <%  
                  }
              } catch (Exception ex) {
                  out.println("<li class='stock-item'><p class='text-danger'>Error: " + ex.getMessage() + "</p></li>");
              } finally {
                  if (connLowStock != null) connLowStock.close();
              }
            %>
            </ul>
          </div>
        </div>
        
        <div class="module-card">
          <div class="module-header">
            Inventory Value by Category
          </div>
          <div class="module-content">
            <div class="chart-wrapper">
                <div id="piechart_div" style="width: 100%; height: 100%;">
                    <p style="text-align:center; color:grey; margin-top:20px;">Loading chart...</p>
                </div>
            </div>
          </div>
        </div>
      </div>
      
      <div class="module-card" style="margin-top: 20px;">
        <div class="module-header">
          Inventory Activities
        </div>
        <div class="module-content">
          <table>
            <thead>
              <tr>
                <th>Product</th>
                <th>Type</th>
                <th>Quantity</th>
                <th>Date</th>
                <th>User</th>
                <th>Reference</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <% 
              // This is placeholder data for recent activities. 
              // You'll need a separate table/logic for inventory movements.
              // The current 'products' query is not suitable for "activities".
              // For demonstration, I'll loop a few times with dummy data.
              // Replace this with actual inventory activity data fetching.
              
              Connection connActivities = null;
              try {
                  connActivities = DriverManager.getConnection(URL, USER, PASSWORD);
                  // Example: SELECT product_name, activity_type, quantity, activity_date, user_name, reference_id FROM inventory_log ORDER BY activity_date DESC LIMIT 5
                  // For now, using products table as a placeholder as in original code
                  PreparedStatement sqlActivities = connActivities.prepareStatement("SELECT name, stock FROM products LIMIT 5"); // Placeholder
                  ResultSet resultActivities = sqlActivities.executeQuery();
                  
                  boolean hasActivities = false;
                  while (resultActivities.next()) {
                      hasActivities = true;
              %>
              <tr>
                <td><%= resultActivities.getString("name") %></td>
                <td><span class="status completed">Stock In</span></td> <td><%= resultActivities.getInt("stock") %> Items</td> <td>May 16, 2025</td> <td>Admin User</td> <td>#PO-4576</td> <td>
                  <div class="action-menu">
                    <button class="action-menu-btn">📝</button>
                  </div>
                </td>
              </tr>
              <%  
                  }
                  if (!hasActivities) {
                      out.println("<tr><td colspan='7' style='text-align:center;'>No recent inventory activities.</td></tr>");
                  }
              } catch (Exception ex) {
                  out.println("<tr><td colspan='7' class='text-danger text-center'>Error loading activities: " + ex.getMessage() + "</td></tr>");
              } finally {
                  if (connActivities != null) connActivities.close();
              }
              %>
            </tbody>
          </table>
        </div>
      </div>
      
      <div class="module-card" style="margin-top: 20px;">
        <div class="module-header">
          Stock Levels - Top Products
        </div>
        <div class="module-content">
          <table>
            <thead>
              <tr>
                <th>Product</th>
                <th>SKU</th>
                <th>Category</th>
                <th>Current Stock</th>
                <th>Reorder Level</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <% 
              Connection connStockLevels = null;
              try {
                  connStockLevels = DriverManager.getConnection(URL, USER, PASSWORD);
                  // Assuming 'sku', 'category' exist in your products table
                  PreparedStatement sqlStockLevels = connStockLevels.prepareStatement("SELECT name, sku, category, stock FROM products ORDER BY stock DESC LIMIT 10"); // Example: Top 10 products
                  ResultSet resultStockLevels = sqlStockLevels.executeQuery();
                  int reorderLevel = 10; // Fixed reorder level as in original

                  boolean hasStockLevels = false;
                  while (resultStockLevels.next()) {
                      hasStockLevels = true;
                      int stock = resultStockLevels.getInt("stock");
                      String statusClass = "";
                      String statusText = "";
                      if (stock <= 0) {
                          statusClass = "out-of-stock";
                          statusText = "Out of Stock";
                      } else if (stock <= reorderLevel) {
                          statusClass = "low-stock";
                          statusText = "Low Stock";
                      } else {
                          statusClass = "in-stock";
                          statusText = "In Stock";
                      }
              %>
              <tr>
                <td><%= resultStockLevels.getString("name") %></td>
                <td><%= resultStockLevels.getString("sku") != null ? resultStockLevels.getString("sku") : "N/A" %></td>
                <td><%= resultStockLevels.getString("category") != null ? resultStockLevels.getString("category") : "N/A" %></td>
                <td><%= stock %></td>
                <td><%= reorderLevel %></td>
                <td>
                  <span class="status-badge <%= statusClass %>"><%= statusText %></span>
                </td>
                <td>
                  <button class="action-btn" title="Adjust Stock">📝</button>
                </td>
              </tr>
              <%  
                  }
                   if (!hasStockLevels) {
                      out.println("<tr><td colspan='7' style='text-align:center;'>No product stock data available.</td></tr>");
                  }
              } catch (Exception ex) {
                  out.println("<tr><td colspan='7' class='text-danger text-center'>Error loading stock levels: " + ex.getMessage() + "</td></tr>");
              } finally {
                  if (connStockLevels != null) connStockLevels.close();
              }
              %>
            </tbody>
          </table>
        </div>
      </div>
      
      <div class="footer">
        Swift © 2025.
      </div>
    </div>
  </div>
   <script>
    // Basic mobile navigation toggle
    const mobileNavToggle = document.getElementById('mobileNavToggle');
    const sidebar = document.getElementById('sidebar');

    if (mobileNavToggle && sidebar) {
        mobileNavToggle.addEventListener('click', () => {
            sidebar.classList.toggle('active'); // You'll need to define an 'active' class for the sidebar if it's not already there
        });
    }
    </script>
</body>
</html>