<%-- 
    Document   : inventory
    Created on : May 16, 2025, 11:54:49 PM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Inventory Dashboard</title>
  <script src="script.js"></script>
  <link rel="Stylesheet" href="styles.css">
    
  <style>
    /* Additional inventory dashboard specific styles */
    .chart-container {
      display: flex;
      justify-content: center;
      align-items: flex-end;
      height: 180px;
      margin: 0 auto;
      padding: 10px;
      margin-bottom: 20px;
    }
    
    .chart-bar {
      width: 80px;
      margin: 0 10px;
      position: relative;
      display: flex;
      justify-content: center;
      border-radius: 4px 4px 0 0;
    }
    
    .chart-label {
      position: absolute;
      bottom: -25px;
      font-size: 12px;
      font-weight: 500;
    }
    
    .chart-legend {
      display: flex;
      flex-direction: column;
      gap: 10px;
      margin-top: 30px;
    }
    
    .legend-item {
      display: flex;
      align-items: center;
      font-size: 12px;
    }
    
    .legend-color {
      width: 12px;
      height: 12px;
      margin-right: 8px;
      border-radius: 2px;
    }
    
    .inventory-status {
      display: flex;
      justify-content: center;
    }
    
    .status.warning {
      background-color: #fef3c7;
      color: var(--warning);
    }
    
    .status.normal {
      background-color: #e0f2fe;
      color: var(--primary);
    }
    
    .action-link {
      color: var(--primary);
      font-size: 12px;
      cursor: pointer;
      text-decoration: underline;
    }
    
    @media (max-width: 768px) {
      .inventory-status {
        flex-direction: column;
      }
      
      .chart-container {
        height: 150px;
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
        <h1 class="page-title">Inventory Dashboard</h1>
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
          <h3>TOTAL INVENTORY VALUE</h3>
          <div class="value">Rs.152,785</div>
          <div class="trend up">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            5.2% from last month
          </div>
        </div>
        
        <div class="stat-card">
          <h3>TOTAL STOCK ITEMS</h3>
          <div class="value">285</div>
          <div class="trend up">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            12 new items
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
        
        <div class="stat-card">
          <h3>OUT OF STOCK ITEMS</h3>
          <div class="value">4</div>
          <div class="trend down">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="6 9 12 15 18 9"></polyline>
            </svg>
            2 more than yesterday
          </div>
        </div>
      </div>
      
      <!-- Modules -->
      <div class="modules-container">
        <div class="module-card">
          <div class="module-header">
            Inventory Quick Actions
          </div>
          <div class="module-content">
            <div class="module-action" data-page="stock_count.jsp">
              <div class="action-icon">📋</div>
              <div class="action-text">
                <h4>Stock Count</h4>
                <p>Perform inventory count and reconciliation</p>
              </div>
            </div>
            
            <div class="module-action" data-page="stock_count.jsp">
              <div class="action-icon">🔄</div>
              <div class="action-text">
                <h4>Restock Items</h4>
                <p>Create purchase orders for low stock items</p>
              </div>
            </div>
            
            <div class="module-action" data-page="stock_count.jsp">
              <div class="action-icon">📥</div>
              <div class="action-text">
                <h4>Receive Inventory</h4>
                <p>Record new inventory arrivals</p>
              </div>
            </div>
            
            <div class="module-action" data-page="stock_count.jsp">
              <div class="action-icon">🏷️</div>
              <div class="action-text">
                <h4>Print Labels</h4>
                <p>Generate barcode labels for products</p>
              </div>
            </div>
          </div>
        </div>
        
        <div class="module-card">
          <div class="module-header">
            Stock Alerts
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
            Inventory Status
          </div>
          <div class="module-content">
            <div class="inventory-status">
              <div class="status-chart">
                <div class="chart-container">
                  <div class="chart-bar" style="height: 70%; background-color: var(--success);">
                    <span class="chart-label">Optimal</span>
                  </div>
                  <div class="chart-bar" style="height: 20%; background-color: var(--warning);">
                    <span class="chart-label">Low</span>
                  </div>
                  <div class="chart-bar" style="height: 10%; background-color: var(--danger);">
                    <span class="chart-label">Out</span>
                  </div>
                </div>
                <div class="chart-legend">
                  <div class="legend-item">
                    <span class="legend-color" style="background-color: var(--success);"></span>
                    <span>Optimal (195 items)</span>
                  </div>
                  <div class="legend-item">
                    <span class="legend-color" style="background-color: var(--warning);"></span>
                    <span>Low Stock (12 items)</span>
                  </div>
                  <div class="legend-item">
                    <span class="legend-color" style="background-color: var(--danger);"></span>
                    <span>Out of Stock (4 items)</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
      </div>
      
      <!-- Inventory List -->
      <div class="module-card" style="margin-top: 20px;">
        <div class="module-header">
          Recent Inventory Activities
        </div>
        <div class="module-content">
          <table>
            <thead>
              <tr>
                <th>Date</th>
                <th>Activity</th>
                <th>Product</th>
                <th>Quantity</th>
                <th>User</th>
                <th>Status</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>May 16, 2025 09:45</td>
                <td>Stock Received</td>
                <td>Premium Coffee Beans</td>
                <td>+20 units</td>
                <td>Admin User</td>
                <td><span class="status completed">Completed</span></td>
              </tr>
              <tr>
                <td>May 16, 2025 09:32</td>
                <td>Stock Adjustment</td>
                <td>Organic Milk 1L</td>
                <td>-2 units</td>
                <td>John Doe</td>
                <td><span class="status completed">Completed</span></td>
              </tr>
              <tr>
                <td>May 15, 2025 16:27</td>
                <td>Stock Count</td>
                <td>Paper Cups 12oz</td>
                <td>-5 units</td>
                <td>Emma Wilson</td>
                <td><span class="status completed">Completed</span></td>
              </tr>
              <tr>
                <td>May 15, 2025 15:15</td>
                <td>Purchase Order</td>
                <td>Vanilla Flavoring</td>
                <td>+10 units</td>
                <td>Admin User</td>
                <td><span class="status pending">Pending</span></td>
              </tr>
              <tr>
                <td>May 15, 2025 10:02</td>
                <td>Stock Received</td>
                <td>Chocolate Syrup</td>
                <td>+15 units</td>
                <td>Michael Brown</td>
                <td><span class="status completed">Completed</span></td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      
      <!-- Expiring Products -->
      <div class="module-card" style="margin-top: 20px;">
        <div class="module-header">
          Expiring Products
        </div>
        <div class="module-content">
          <table>
            <thead>
              <tr>
                <th>Product</th>
                <th>Quantity</th>
                <th>Expiry Date</th>
                <th>Days Left</th>
                <th>Status</th>
                <th>Action</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>Organic Milk 1L</td>
                <td>8 units</td>
                <td>May 22, 2025</td>
                <td>6 days</td>
                <td><span class="status warning">Expiring Soon</span></td>
                <td><span class="action-link">Mark Priority</span></td>
              </tr>
              <tr>
                <td>Fresh Cream 500ml</td>
                <td>4 units</td>
                <td>May 25, 2025</td>
                <td>9 days</td>
                <td><span class="status warning">Expiring Soon</span></td>
                <td><span class="action-link">Mark Priority</span></td>
              </tr>
              <tr>
                <td>Yogurt Plain 500g</td>
                <td>6 units</td>
                <td>June 1, 2025</td>
                <td>16 days</td>
                <td><span class="status normal">Normal</span></td>
                <td><span class="action-link">Monitor</span></td>
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
    <script>
            document.querySelectorAll('.module-action').forEach(action => {
      action.addEventListener('click', function() {
        const targetPage = this.getAttribute('data-page');
        if (targetPage) {
          window.location.href = targetPage;
        }
      });
    });
    </script>

</body>
</html>