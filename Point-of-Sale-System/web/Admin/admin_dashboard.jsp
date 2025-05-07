<%-- 
    Document   : admin_dashboard
    Created on : May 4, 2025, 4:19:20 AM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Admin Dashboard</title>
  <script src="script.js"></script>
  <link rel="Stylesheet" href="styles.css">
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
        <h1 class="page-title"> Admin Dashboard</h1>
        <div class="user-profile">
          <img src="../Images/logo.png" alt="Admin Profile">
          <div>
            <h4>Admin User</h4>
          </div>
        </div>
      </div>
      
      <!-- Stats Cards -->
      <div class="stats-container">
        <div class="stat-card">
          <h3>DAILY SALES</h3>
          <div class="value">Rs.2,459</div>
          <div class="trend up">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            12.5% from yesterday
          </div>
        </div>
        
        <div class="stat-card">
          <h3>MONTHLY SALES</h3>
          <div class="value">Rs.42,085</div>
          <div class="trend up">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            8.2% from last month
          </div>
        </div>
        
        <div class="stat-card">
          <h3>TOTAL PRODUCTS</h3>
          <div class="value">285</div>
          <div class="trend up">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            5 new products added
          </div>
        </div>
        
        <div class="stat-card">
          <h3>LOW STOCK ITEMS</h3>
          <div class="value">12</div>
          <div class="trend down">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="6 9 12 15 18 9"></polyline>
            </svg>
            3 more than yesterday
          </div>
        </div>
      </div>
      
      <!-- Modules -->
      <div class="modules-container">
        <div class="module-card">
          <div class="module-header">
            Admin Quick Actions
          </div>
          <div class="module-content">
            <div class="module-action">
              <div class="action-icon">👤</div>
              <div class="action-text">
                <h4>User Management</h4>
                <p>Create, edit, delete cashier accounts</p>
              </div>
            </div>
            
            <div class="module-action">
              <div class="action-icon">📦</div>
              <div class="action-text">
                <h4>Product Management</h4>
                <p>Add, update, delete products</p>
              </div>
            </div>
            
            <div class="module-action">
              <div class="action-icon">🏭</div>
              <div class="action-text">
                <h4>Supplier Management</h4>
                <p>Manage suppliers and product links</p>
              </div>
            </div>
            
            <div class="module-action">
              <div class="action-icon">📊</div>
              <div class="action-text">
                <h4>Sales Reports</h4>
                <p>View daily, weekly, monthly reports</p>
              </div>
            </div>
          </div>
        </div>
        
        <div class="module-card">
          <div class="module-header">
            Low Stock Alert
          </div>
          <div class="module-content">
            <ul class="low-stock-list">
              <li class="stock-item">
                <div class="stock-info">
                  <span class="stock-name">Premium Coffee Beans</span>
                  <span class="stock-supplier">Global Coffee Co.</span>
                </div>
                <div class="stock-quantity">
                  5 units
                </div>
              </li>
              
              <li class="stock-item">
                <div class="stock-info">
                  <span class="stock-name">Organic Milk 1L</span>
                  <span class="stock-supplier">Dairy Farms Inc.</span>
                </div>
                <div class="stock-quantity">
                  8 units
                </div>
              </li>
              
              <li class="stock-item">
                <div class="stock-info">
                  <span class="stock-name">Chocolate Syrup</span>
                  <span class="stock-supplier">Sweet Supplies Ltd.</span>
                </div>
                <div class="stock-quantity">
                  3 units
                </div>
              </li>
              
              <li class="stock-item">
                <div class="stock-info">
                  <span class="stock-name">Paper Cups 12oz</span>
                  <span class="stock-supplier">Package Solutions</span>
                </div>
                <div class="stock-quantity">
                  15 units
                </div>
              </li>
              
              <li class="stock-item">
                <div class="stock-info">
                  <span class="stock-name">Vanilla Flavoring</span>
                  <span class="stock-supplier">Flavor Masters</span>
                </div>
                <div class="stock-quantity">
                  2 units
                </div>
              </li>
            </ul>
          </div>
        </div>
        
        <div class="module-card">
          <div class="module-header">
            Cashier Performance
          </div>
          <div class="module-content">
            <div class="sales-header">
              <div class="sales-title">Recent Sales by Cashier</div>
              <div class="view-all">View All</div>
            </div>
            
            <table>
              <thead>
                <tr>
                  <th>Cashier</th>
                  <th>Sales Today</th>
                  <th>Transactions</th>
                  <th>Status</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td>John Doe</td>
                  <td>Rs.854.20</td>
                  <td>24</td>
                  <td><span class="status completed">Active</span></td>
                </tr>
                <tr>
                  <td>Emma Wilson</td>
                  <td>Rs.762.50</td>
                  <td>18</td>
                  <td><span class="status completed">Active</span></td>
                </tr>
                <tr>
                  <td>Michael Brown</td>
                  <td>Rs.645.75</td>
                  <td>15</td>
                  <td><span class="status completed">Active</span></td>
                </tr>
                <tr>
                  <td>Sarah Johnson</td>
                  <td>Rs.196.80</td>
                  <td>5</td>
                  <td><span class="status pending">Break</span></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </div>
      
      <!-- Recent Sales Table -->
      <div class="module-card" style="margin-top: 20px;">
        <div class="module-header">
          Recent Transactions
        </div>
        <div class="module-content">
          <table>
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Cashier</th>
                <th>Products</th>
                <th>Amount</th>
                <th>Payment</th>
                <th>Date</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>#ORD-7894</td>
                <td>John Doe</td>
                <td>5 items</td>
                <td>Rs.124.00</td>
                <td>Cash</td>
                <td>April 28, 2025 09:45</td>
                <td><span class="status completed">Completed</span></td>
              </tr>
              <tr>
                <td>#ORD-7893</td>
                <td>Emma Wilson</td>
                <td>3 items</td>
                <td>Rs.86.50</td>
                <td>Card</td>
                <td>April 28, 2025 09:32</td>
                <td><span class="status completed">Completed</span></td>
              </tr>
              <tr>
                <td>#ORD-7892</td>
                <td>Michael Brown</td>
                <td>2 items</td>
                <td>Rs.45.20</td>
                <td>QR Code</td>
                <td>April 28, 2025 09:27</td>
                <td><span class="status completed">Completed</span></td>
              </tr>
              <tr>
                <td>#ORD-7891</td>
                <td>Sarah Johnson</td>
                <td>7 items</td>
                <td>Rs.196.80</td>
                <td>Card</td>
                <td>April 28, 2025 09:15</td>
                <td><span class="status completed">Completed</span></td>
              </tr>
              <tr>
                <td>#ORD-7890</td>
                <td>John Doe</td>
                <td>1 item</td>
                <td>Rs.12.99</td>
                <td>Cash</td>
                <td>April 28, 2025 09:02</td>
                <td><span class="status completed">Completed</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      
      <div class="footer">
        Swift © 2025.
      </div>
    </div>
  </div>
</body>
</html>
