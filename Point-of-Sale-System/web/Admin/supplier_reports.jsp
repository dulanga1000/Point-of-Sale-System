<%-- 
    Document   : sales_report
    Created on : May 17, 2025, 10:15:22 AM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
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
            <div class="chart-title">Sales Trend</div>
            <div class="chart-filters">
              <button class="chart-filter">Day</button>
              <button class="chart-filter active">Week</button>
              <button class="chart-filter">Month</button>
            </div>
          </div>
          <div class="chart">
            <div class="chart-placeholder">
              <img src="${pageContext.request.contextPath}/Images/sales-chart.png" alt="Sales Chart" style="width: 100%; height: 100%; object-fit: cover;">
            </div>
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
                <th>Total</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>Apr 30, 2025</td>
                <td>#ORD-7894</td>
                <td>John Doe</td>
                <td>5 items</td>
                <td>Cash</td>
                <td>Rs.124.00</td>
              </tr>
              <tr>
                <td>Apr 30, 2025</td>
                <td>#ORD-7893</td>
                <td>Emma Wilson</td>
                <td>3 items</td>
                <td>Card</td>
                <td>Rs.86.50</td>
              </tr>
              <tr>
                <td>Apr 29, 2025</td>
                <td>#ORD-7892</td>
                <td>Michael Brown</td>
                <td>2 items</td>
                <td>QR Code</td>
                <td>Rs.45.20</td>
              </tr>
              <tr>
                <td>Apr 29, 2025</td>
                <td>#ORD-7891</td>
                <td>Sarah Johnson</td>
                <td>7 items</td>
                <td>Card</td>
                <td>Rs.196.80</td>
              </tr>
              <tr>
                <td>Apr 28, 2025</td>
                <td>#ORD-7890</td>
                <td>John Doe</td>
                <td>1 item</td>
                <td>Cash</td>
                <td>Rs.12.99</td>
              </tr>
              <tr>
                <td>Apr 28, 2025</td>
                <td>#ORD-7889</td>
                <td>Emma Wilson</td>
                <td>4 items</td>
                <td>Card</td>
                <td>Rs.98.75</td>
              </tr>
              <tr>
                <td>Apr 28, 2025</td>
                <td>#ORD-7888</td>
                <td>Michael Brown</td>
                <td>6 items</td>
                <td>QR Code</td>
                <td>Rs.156.30</td>
              </tr>
              <tr>
                <td>Apr 27, 2025</td>
                <td>#ORD-7887</td>
                <td>Sarah Johnson</td>
                <td>3 items</td>
                <td>Cash</td>
                <td>Rs.68.45</td>
              </tr>
              <tr>
                <td>Apr 27, 2025</td>
                <td>#ORD-7886</td>
                <td>John Doe</td>
                <td>2 items</td>
                <td>Card</td>
                <td>Rs.35.20</td>
              </tr>
              <tr>
                <td>Apr 27, 2025</td>
                <td>#ORD-7885</td>
                <td>Emma Wilson</td>
                <td>5 items</td>
                <td>QR Code</td>
                <td>Rs.112.60</td>
              </tr>
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
  </script>
</body>
</html>