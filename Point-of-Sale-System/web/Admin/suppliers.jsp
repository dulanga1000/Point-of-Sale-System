<%-- 
    Document   : suppliers
    Created on : May 16, 2025, 9:27:45 AM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%-- Removed duplicate imports --%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Supplier Management - Swift POS</title>
  <script src="script.js"></script> <%-- Ensure script.js is accessible --%>
  <link rel="Stylesheet" href="Admin/styles.css"> <%-- Ensure styles.css is accessible --%>
    <style>
    /* Additional styles for the supplier dashboard */
    .search-filter-bar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
      flex-wrap: wrap;
      gap: 10px;
    }
    
    .search-container {
      display: flex;
      align-items: center;
      background-color: #f8fafc;
      border-radius: 6px;
      overflow: hidden;
      border: 1px solid #e2e8f0;
    }
    
    .search-input {
      padding: 10px 15px;
      border: none;
      background-color: transparent;
      flex: 1;
      min-width: 200px;
    }
    
    .search-button {
      background-color: var(--primary);
      border: none;
      color: white;
      padding: 10px 15px;
      cursor: pointer;
    }
    
    .filter-container {
      display: flex;
      gap: 10px;
    }
    
    .filter-select {
      padding: 10px;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      background-color: #f8fafc;
      min-width: 150px;
    }
    
    .add-supplier-btn {
      display: flex;
      align-items: center;
      gap: 8px;
      background-color: var(--primary);
      color: white;
      border: none;
      padding: 10px 15px;
      border-radius: 6px;
      cursor: pointer;
      font-weight: 500;
    }
    
    .action-buttons {
      display: flex;
      gap: 8px;
    }
    
    .action-btn {
      background: none;
      border: none;
      font-size: 16px;
      cursor: pointer;
      padding: 2px 5px;
      border-radius: 4px;
      transition: background-color 0.2s;
    }
    
    .action-btn:hover {
      background-color: #f1f5f9;
    }
    
    .pagination {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: 20px;
    }
    
    .pagination-btn {
      background-color: #f1f5f9;
      border: 1px solid #e2e8f0;
      padding: 8px 16px;
      border-radius: 6px;
      cursor: pointer;
    }
    
    .pagination-btn:disabled {
      opacity: 0.5;
      cursor: not-allowed;
    }
    
    .page-numbers {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    .page-btn {
      width: 32px;
      height: 32px;
      display: flex;
      align-items: center;
      justify-content: center;
      background-color: #f1f5f9;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      cursor: pointer;
    }
    
    .page-btn.active {
      background-color: var(--primary);
      color: white;
      border-color: var(--primary);
    }
    
    .page-ellipsis {
      line-height: 1;
    }
    
    /* Supply Chain Health Styles */
    .supply-chain-metrics {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 15px;
      margin-bottom: 30px;
    }
    
    .metric-card {
      background-color: #f8fafc;
      border-radius: 8px;
      padding: 15px;
      position: relative;
      border-left: 4px solid transparent;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    }
    
    .metric-title {
      font-size: 14px;
      color: var(--secondary);
      margin-bottom: 8px;
    }
    
    .metric-value {
      font-size: 22px;
      font-weight: 600;
    }
    
    .metric-indicator {
      width: 8px;
      height: 8px;
      border-radius: 50%;
      position: absolute;
      top: 15px;
      right: 15px;
    }
    
    .metric-indicator.good {
      background-color: var(--success);
    }
    
    .metric-indicator.average {
      background-color: var(--warning);
    }
    
    .metric-indicator.poor {
      background-color: var(--danger);
    }
    
    .top-suppliers h3 {
      margin-bottom: 15px;
      font-size: 16px;
      font-weight: 600;
    }
    
    .supplier-rating-list {
      display: flex;
      flex-direction: column;
      gap: 12px;
    }
    
    .supplier-rating-item {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 12px 15px;
      background-color: #f8fafc;
      border-radius: 8px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    }
    
    .supplier-name {
      font-weight: 500;
      margin-bottom: 4px;
      display: block;
    }
    
    .supplier-rating {
      display: flex;
      align-items: center;
      color: #f59e0b;
    }
    
    .supplier-metrics {
      display: flex;
      gap: 15px;
      font-size: 13px;
      color: var(--secondary);
    }
    
    .star.filled {
      color: #f59e0b;
    }
    
    .star.half {
      position: relative;
      color: #e2e8f0;
    }
    
    .star.half:before {
      content: '★';
      position: absolute;
      color: #f59e0b;
      width: 50%;
      overflow: hidden;
    }
    
    .star:not(.filled):not(.half) {
      color: #e2e8f0;
    }
    
    /* Responsive adjustments */
    @media (max-width: 768px) {
      .search-filter-bar {
        flex-direction: column;
        align-items: stretch;
      }
      
      .search-container {
        width: 100%;
      }
      
      .filter-container {
        width: 100%;
      }
      
      .add-supplier-btn {
        width: 100%;
        justify-content: center;
      }
      
      .supplier-rating-item {
        flex-direction: column;
        align-items: flex-start;
        gap: 8px;
      }
      
      .supplier-metrics {
        width: 100%;
        justify-content: space-between;
      }
    }

    /* Styles for feedback messages */
    .feedback-message {
      padding: 15px;
      margin-bottom: 20px;
      border: 1px solid transparent;
      border-radius: .25rem; /* Bootstrap-like border radius */
      font-size: 1rem;
      text-align: center;
    }
    .feedback-message.success {
      color: #155724;
      background-color: #d4edda;
      border-color: #c3e6cb;
    }
    .feedback-message.error {
      color: #721c24;
      background-color: #f8d7da;
      border-color: #f5c6cb;
    }

  </style>
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
        <h1 class="page-title">Supplier Management</h1>
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
      
      <%
          String feedbackMessage = (String) request.getAttribute("feedbackMessage");
          String errorMessage = (String) request.getAttribute("errorMessage");

          if (feedbackMessage != null) {
      %>
          <div class="feedback-message success" role="alert">
              <%= feedbackMessage %>
          </div>
      <%
          }
          if (errorMessage != null) {
      %>
          <div class="feedback-message error" role="alert">
              <%= errorMessage %>
          </div>
      <%
          }
      %>
      <div class="stats-container">
        <div class="stat-card">
          <h3>TOTAL SUPPLIERS</h3>
          <div class="value">24</div>
          <div class="trend up">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            2 new this month
          </div>
        </div>
        
        <div class="stat-card">
          <h3>ACTIVE ORDERS</h3>
          <div class="value">7</div>
          <div class="trend up">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            3 pending delivery
          </div>
        </div>
        
        <div class="stat-card">
          <h3>MONTHLY EXPENSES</h3>
          <div class="value">Rs.86,240</div>
          <div class="trend down">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="6 9 12 15 18 9"></polyline>
            </svg>
            4.2% from last month
          </div>
        </div>
        
        <div class="stat-card">
          <h3>SUPPLIER RELIABILITY</h3>
          <div class="value">92%</div>
          <div class="trend up">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            3.5% improvement
          </div>
        </div>
      </div>
      
      <div class="modules-container">
        <div class="module-card">
          <div class="module-header">
            Supplier Actions
          </div>
          <div class="module-content">
            <div class="module-action" data-page="add_supplier.jsp"> <%-- Consider path: ${pageContext.request.contextPath}/Admin/add_supplier.jsp if add_supplier.jsp is in Admin folder --%>
              <div class="action-icon">➕</div>
              <div class="action-text">
                <h4>Add New Supplier</h4>
                <p>Create a new supplier profile</p>
              </div>
            </div>
            
            <div class="module-action" data-page="purchases.jsp">
              <div class="action-icon">🔄</div>
              <div class="action-text">
                <h4>Create Purchase Order</h4>
                <p>Create and send new orders to suppliers</p>
              </div>
            </div>
            
            <div class="module-action" data-page="supplier_reports.jsp">
              <div class="action-icon">📊</div>
              <div class="action-text">
                <h4>Supplier Reports</h4>
                <p>View performance and order history</p>
              </div>
            </div>
            
            <div class="module-action" data-page="productsBySupplierController">
              <div class="action-icon">🔍</div>
              <div class="action-text">
                <h4>Find Products by Supplier</h4>
                <p>Search products linked to specific suppliers</p>
              </div>
            </div>
          </div>
        </div>
        
        <div class="module-card">
          <div class="module-header">
            Upcoming Deliveries
          </div>
          <div class="module-content">
            <div class="sales-header">
              <div class="sales-title">Expected Within 7 Days</div>
              <div class="view-all">View All</div>
            </div>
            
            <table>
              <thead>
                <tr>
                  <th>Order ID</th>
                  <th>Supplier</th>
                  <th>Status</th>
                  <th>Expected Date</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>#PO-4592</td>
                  <td>Global Coffee Co.</td>
                  <td><span class="status pending">In Transit</span></td>
                  <td>May 13, 2025</td>
                </tr>
                <tr>
                  <td>#PO-4587</td>
                  <td>Dairy Farms Inc.</td>
                  <td><span class="status pending">Processing</span></td>
                  <td>May 14, 2025</td>
                </tr>
                <tr>
                  <td>#PO-4581</td>
                  <td>Sweet Supplies Ltd.</td>
                  <td><span class="status pending">Confirmed</span></td>
                  <td>May 15, 2025</td>
                </tr>
                <tr>
                  <td>#PO-4576</td>
                  <td>Package Solutions</td>
                  <td><span class="status completed">Shipped</span></td>
                  <td>May 12, 2025</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
      
      <div class="module-card" style="margin-top: 20px;">
        <div class="module-header">
          Supplier Directory
        </div>
        <div class="module-content">
          <div class="search-filter-bar">
            <div class="search-container">
              <input type="text" placeholder="Search suppliers..." class="search-input">
              <button class="search-button">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <circle cx="11" cy="11" r="8"></circle>
                  <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                </svg>
              </button>
            </div>
            <div class="filter-container">
              <select class="filter-select">
                <option value="all">All Categories</option>
                <option value="beverages">Beverages</option>
                <option value="dairy">Dairy</option>
                <option value="packaging">Packaging</option>
                <option value="ingredients">Ingredients</option>
              </select>
              <select class="filter-select">
                <option value="all">All Status</option>
                <option value="active">Active</option>
                <option value="inactive">Inactive</option>
              </select>
            </div>
            <button class="add-supplier-btn" data-page="add_supplier.jsp"> <%-- Consider path: ${pageContext.request.contextPath}/Admin/add_supplier.jsp --%>
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="12" y1="5" x2="12" y2="19"></line>
                <line x1="5" y1="12" x2="19" y2="12"></line>
              </svg>
              Add Supplier
            </button>
          </div>
          
          <table>
            <thead>
              <tr>
                <th>Supplier ID</th>
                <th>Company Name</th>
                <th>Category</th>
                <th>Contact Person</th>
                <th>Phone</th>
                <th>Last Order</th>
                <th>Status</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
                <%
    // Re-use DB connection details from above if possible, or redefine
    // String URL = "jdbc:mysql://localhost:3306/Swift_Database"; // Already defined
    // String USER = "root"; // Already defined
    // String PASSWORD = ""; // Already defined
    Connection conn = null;
    try {
        // Class.forName("com.mysql.jdbc.Driver"); // Already loaded for user profile
        conn = DriverManager.getConnection(URL, USER, PASSWORD);
        PreparedStatement sql = conn.prepareStatement("SELECT * FROM suppliers"); // Ensure table and column names are correct
        ResultSet result = sql.executeQuery();

        while (result.next()) { %>
              <tr>
                <td><%= result.getString("supplier_id") %></td>
                <td><%= result.getString("company_name") %></td>
                <td><%= result.getString("category") %></td>
                <td><%= result.getString("contact_person") %></td>
                <td><%= result.getString("contact_phone") %></td>
                <td><%= result.getString("lead_time") %> days</td> <%-- Assuming lead_time is what's meant by Last Order here or needs adjustment --%>
                <td><span class="status completed"><%= result.getString("supplier_status") != null ? result.getString("supplier_status") : "Active" %></span></td> <%-- Added null check for status --%>
                <td class="action-buttons">
                  <button class="action-btn edit-btn" title="Edit">✏️</button>
                  <button class="action-btn view-btn" title="View Details">👁️</button>
                  <button class="action-btn order-btn" title="Place Order">🛒</button>
                </td>
              </tr>
              <% }
        result.close();
        sql.close();
    } catch (Exception ex) {
        out.println("<tr><td colspan='8' class='text-danger text-center'>Error loading suppliers: " + ex.getMessage() + "</td></tr>");
        ex.printStackTrace(); // For server logs
    } finally {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
%>
              
            </tbody>
          </table>
          
          <div class="pagination">
            <button class="pagination-btn" disabled>Previous</button>
            <div class="page-numbers">
              <button class="page-btn active">1</button>
              <button class="page-btn">2</button>
              <button class="page-btn">3</button>
              <span class="page-ellipsis">...</span>
              <button class="page-btn">8</button>
            </div>
            <button class="pagination-btn">Next</button>
          </div>
        </div>
      </div>
      
      <div class="module-card" style="margin-top: 20px;">
        <div class="module-header">
          Supply Chain Health
        </div>
        <div class="module-content">
          <div class="supply-chain-metrics">
            <div class="metric-card">
              <div class="metric-title">Average Delivery Time</div>
              <div class="metric-value">4.2 Days</div>
              <div class="metric-indicator good"></div>
            </div>
            <div class="metric-card">
              <div class="metric-title">Order Fulfillment Rate</div>
              <div class="metric-value">94%</div>
              <div class="metric-indicator good"></div>
            </div>
            <div class="metric-card">
              <div class="metric-title">Quality Compliance</div>
              <div class="metric-value">97%</div>
              <div class="metric-indicator good"></div>
            </div>
            <div class="metric-card">
              <div class="metric-title">Price Stability</div>
              <div class="metric-value">87%</div>
              <div class="metric-indicator average"></div>
            </div>
          </div>
          
          <div class="top-suppliers">
            <h3>Top Performing Suppliers</h3>
            <div class="supplier-rating-list">
              <div class="supplier-rating-item">
                <div class="supplier-info">
                  <span class="supplier-name">Global Coffee Co.</span>
                  <div class="supplier-rating">
                    <span class="star filled">★</span>
                    <span class="star filled">★</span>
                    <span class="star filled">★</span>
                    <span class="star filled">★</span>
                    <span class="star filled">★</span>
                  </div>
                </div>
                <div class="supplier-metrics">
                  <span>On-time: 98%</span>
                  <span>Quality: 99%</span>
                </div>
              </div>
              
              <div class="supplier-rating-item">
                <div class="supplier-info">
                  <span class="supplier-name">Dairy Farms Inc.</span>
                  <div class="supplier-rating">
                    <span class="star filled">★</span>
                    <span class="star filled">★</span>
                    <span class="star filled">★</span>
                    <span class="star filled">★</span>
                    <span class="star half">★</span>
                  </div>
                </div>
                <div class="supplier-metrics">
                  <span>On-time: 95%</span>
                  <span>Quality: 97%</span>
                </div>
              </div>
              
              <div class="supplier-rating-item">
                <div class="supplier-info">
                  <span class="supplier-name">Package Solutions</span>
                  <div class="supplier-rating">
                    <span class="star filled">★</span>
                    <span class="star filled">★</span>
                    <span class="star filled">★</span>
                    <span class="star filled">★</span>
                    <span class="star">★</span>
                  </div>
                </div>
                <div class="supplier-metrics">
                  <span>On-time: 92%</span>
                  <span>Quality: 95%</span>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <div class="footer">
        Swift © 2025.
      </div>
    </div>
  </div>
  
  <script>
    // Mobile navigation toggle
    document.getElementById('mobileNavToggle').addEventListener('click', function() {
      document.getElementById('sidebar').classList.toggle('active');
    });
    
    // Navigation via JavaScript for module actions
    document.querySelectorAll('.module-action').forEach(action => {
      action.addEventListener('click', function() {
        const targetPage = this.getAttribute('data-page');
        if (targetPage) {
          // If add_supplier.jsp is in /Admin folder, adjust path:
          // if (targetPage === 'add_supplier.jsp') {
          //   window.location.href = '${pageContext.request.contextPath}/Admin/add_supplier.jsp';
          // } else {
          //   window.location.href = targetPage;
          // }
          // For now, assuming targetPage is correct as is or relative to current page/context root
          window.location.href = targetPage; 
        }
      });
    });
    
    // Interactivity for Add Supplier buttons
    // Ensure this navigates to the correct Add Supplier form page
    document.querySelectorAll('.add-supplier-btn').forEach(button => {
      button.addEventListener('click', function() {
          // If your add_supplier.jsp is in the /Admin folder, use:
          // window.location.href = '${pageContext.request.contextPath}/Admin/add_supplier.jsp';
          // If it's at the root or same directory as suppliers.jsp:
          window.location.href = 'add_supplier.jsp'; 
      });
    });
    
    // Action buttons in table (Edit, View, Order) - currently not functional, for demonstration
    document.querySelectorAll('.action-btn.edit-btn, .action-btn.view-btn, .action-btn.order-btn').forEach(button => {
        button.addEventListener('click', function(event) {
            // Prevent default if these were links or form submit buttons
            // event.preventDefault(); 
            // Example: Get supplier ID from the row
            // const supplierId = event.target.closest('tr').cells[0].textContent;
            // console.log("Action on supplier ID: ", supplierId, "Action: ", this.title);
            // Implement actual edit/view/order logic here or navigate
            alert('Action: ' + this.title + ' (functionality to be implemented)');
        });
    });
    
    document.querySelectorAll('.page-btn:not(.active)').forEach(button => {
      button.addEventListener('click', function() {
        const currentActive = document.querySelector('.page-btn.active');
        if(currentActive) currentActive.classList.remove('active');
        this.classList.add('active');
        // Add logic to fetch and display data for the new page
      });
    });
  </script>
</body>
</html>