<%-- 
    Document   : supplier_reports
    Created on : May 11, 2025, 4:47:38 PM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Supplier Reports - Swift POS</title>
  <script src="script.js"></script>
  <link rel="Stylesheet" href="styles.css">
  <style>
    /* Additional styles for the supplier reports */
    .report-filters {
      display: flex;
      gap: 15px;
      margin-bottom: 20px;
      flex-wrap: wrap;
    }
    
    .filter-group {
      display: flex;
      flex-direction: column;
      min-width: 180px;
    }
    
    .filter-group label {
      font-size: 13px;
      color: var(--secondary);
      margin-bottom: 5px;
    }
    
    .filter-input {
      padding: 10px;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      background-color: #f8fafc;
    }
    
    .report-actions {
      display: flex;
      gap: 10px;
      margin-bottom: 20px;
    }
    
    .report-btn {
      padding: 10px 20px;
      border-radius: 6px;
      font-weight: 500;
      cursor: pointer;
      border: none;
    }
    
    .primary-btn {
      background-color: var(--primary);
      color: white;
    }
    
    .secondary-btn {
      background-color: #f1f5f9;
      color: var(--dark);
      border: 1px solid #e2e8f0;
    }
    
    .report-summary {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 20px;
      margin-bottom: 20px;
    }
    
    .summary-card {
      background-color: white;
      padding: 15px;
      border-radius: 8px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
    }
    
    .summary-title {
      font-size: 13px;
      color: var(--secondary);
      margin-bottom: 8px;
    }
    
    .summary-value {
      font-size: 20px;
      font-weight: 600;
    }
    
    .performance-trend {
      margin-top: 5px;
      font-size: 12px;
      display: flex;
      align-items: center;
      gap: 3px;
    }
    
    .trend-up {
      color: var(--success);
    }
    
    .trend-down {
      color: var(--danger);
    }
    
    .report-tab-container {
      margin-bottom: 20px;
    }
    
    .report-tabs {
      display: flex;
      border-bottom: 1px solid #e2e8f0;
      margin-bottom: 15px;
    }
    
    .report-tab {
      padding: 10px 20px;
      cursor: pointer;
      border-bottom: 2px solid transparent;
      font-weight: 500;
      transition: all 0.2s;
    }
    
    .report-tab.active {
      border-bottom-color: var(--primary);
      color: var(--primary);
    }
    
    .report-tab:hover:not(.active) {
      background-color: #f8fafc;
      border-bottom-color: #e2e8f0;
    }
    
    .report-content {
      background-color: white;
      border-radius: 8px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.05);
      padding: 20px;
      margin-bottom: 20px;
    }
    
    .chart-container {
      width: 100%;
      height: 300px;
      margin: 20px 0;
      background-color: #f8fafc;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-style: italic;
      color: var(--secondary);
    }
    
    .report-table {
      width: 100%;
      border-collapse: collapse;
      margin-top: 15px;
    }
    
    .report-table th,
    .report-table td {
      padding: 12px 15px;
      text-align: left;
      border-bottom: 1px solid #f1f5f9;
    }
    
    .report-table th {
      background-color: #f8fafc;
      font-weight: 500;
      color: var(--secondary);
    }
    
    .report-footer {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding-top: 15px;
      border-top: 1px solid #f1f5f9;
      margin-top: 20px;
    }
    
    .report-info {
      font-size: 13px;
      color: var(--secondary);
    }
    
    .report-actions-footer {
      display: flex;
      gap: 10px;
    }
    
    .quality-indicator {
      width: 10px;
      height: 10px;
      border-radius: 50%;
      display: inline-block;
      margin-right: 5px;
    }
    
    .quality-excellent {
      background-color: var(--success);
    }
    
    .quality-good {
      background-color: #22c55e;
    }
    
    .quality-average {
      background-color: var(--warning);
    }
    
    .quality-poor {
      background-color: var(--danger);
    }
    
    @media (max-width: 768px) {
      .report-filters,
      .report-actions {
        flex-direction: column;
      }
      
      .filter-group,
      .report-btn {
        width: 100%;
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
        <h1 class="page-title">Supplier Reports</h1>
        <div class="user-profile">
          <img src="../Images/logo.png" alt="Admin Profile">
          <div>
            <h4>Admin User</h4>
          </div>
        </div>
      </div>
      
      <!-- Report Filters -->
      <div class="module-card">
        <div class="module-header">
          Report Parameters
        </div>
        <div class="module-content">
          <div class="report-filters">
            <div class="filter-group">
              <label>Supplier</label>
              <select class="filter-input">
                <option value="all">All Suppliers</option>
                <option value="global">Global Coffee Co.</option>
                <option value="dairy">Dairy Farms Inc.</option>
                <option value="sweet">Sweet Supplies Ltd.</option>
                <option value="package">Package Solutions</option>
                <option value="flavor">Flavor Masters</option>
                <option value="ceylon">Ceylon Teas</option>
              </select>
            </div>
            
            <div class="filter-group">
              <label>Date Range</label>
              <select class="filter-input">
                <option value="last30">Last 30 Days</option>
                <option value="last90">Last 90 Days</option>
                <option value="last6m">Last 6 Months</option>
                <option value="lastyear">Last Year</option>
                <option value="custom">Custom Range</option>
              </select>
            </div>
            
            <div class="filter-group">
              <label>Report Type</label>
              <select class="filter-input">
                <option value="performance">Performance Analysis</option>
                <option value="orders">Order History</option>
                <option value="quality">Quality Assessment</option>
                <option value="financial">Financial Summary</option>
              </select>
            </div>
            
            <div class="filter-group">
              <label>Category</label>
              <select class="filter-input">
                <option value="all">All Categories</option>
                <option value="beverages">Beverages</option>
                <option value="dairy">Dairy</option>
                <option value="packaging">Packaging</option>
                <option value="ingredients">Ingredients</option>
              </select>
            </div>
          </div>
          
          <div class="report-actions">
            <button class="report-btn primary-btn">Generate Report</button>
            <button class="report-btn secondary-btn">Reset Filters</button>
            <button class="report-btn secondary-btn">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                <polyline points="7 10 12 15 17 10"></polyline>
                <line x1="12" y1="15" x2="12" y2="3"></line>
              </svg>
              Export Report
            </button>
          </div>
        </div>
      </div>
      
      <!-- Report Summary -->
      <div class="report-summary">
        <div class="summary-card">
          <div class="summary-title">TOTAL ORDERS</div>
          <div class="summary-value">127</div>
          <div class="performance-trend trend-up">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            12% vs. previous period
          </div>
        </div>
        
        <div class="summary-card">
          <div class="summary-title">TOTAL SPENDING</div>
          <div class="summary-value">Rs.286,450</div>
          <div class="performance-trend trend-up">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            8.5% vs. previous period
          </div>
        </div>
        
        <div class="summary-card">
          <div class="summary-title">AVG. DELIVERY TIME</div>
          <div class="summary-value">4.2 Days</div>
          <div class="performance-trend trend-down">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="6 9 12 15 18 9"></polyline>
            </svg>
            0.3 days improvement
          </div>
        </div>
        
        <div class="summary-card">
          <div class="summary-title">QUALITY SCORE</div>
          <div class="summary-value">94%</div>
          <div class="performance-trend trend-up">
            <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            2.1% improvement
          </div>
        </div>
      </div>
      
      <!-- Report Tabs -->
      <div class="report-tab-container">
        <div class="report-tabs">
          <div class="report-tab active">Performance Analysis</div>
          <div class="report-tab">Order History</div>
          <div class="report-tab">Quality Assessment</div>
          <div class="report-tab">Financial Summary</div>
        </div>
      </div>
      
      <!-- Report Content -->
      <div class="report-content">
        <h3>Supplier Performance Analysis</h3>
        <p>Showing data for all suppliers from Apr 11, 2025 - May 11, 2025</p>
        
        <div class="chart-container">
          [Performance Chart Visualization]
        </div>
        
        <table class="report-table">
          <thead>
            <tr>
              <th>Supplier</th>
              <th>Category</th>
              <th>Orders</th>
              <th>On-Time %</th>
              <th>Avg. Delivery (Days)</th>
              <th>Quality</th>
              <th>Overall Rating</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>Global Coffee Co.</td>
              <td>Beverages</td>
              <td>32</td>
              <td>98%</td>
              <td>3.2</td>
              <td><span class="quality-indicator quality-excellent"></span> Excellent</td>
              <td>5.0</td>
            </tr>
            <tr>
              <td>Dairy Farms Inc.</td>
              <td>Dairy</td>
              <td>45</td>
              <td>95%</td>
              <td>2.8</td>
              <td><span class="quality-indicator quality-excellent"></span> Excellent</td>
              <td>4.8</td>
            </tr>
            <tr>
              <td>Sweet Supplies Ltd.</td>
              <td>Ingredients</td>
              <td>18</td>
              <td>89%</td>
              <td>4.5</td>
              <td><span class="quality-indicator quality-good"></span> Good</td>
              <td>4.2</td>
            </tr>
            <tr>
              <td>Package Solutions</td>
              <td>Packaging</td>
              <td>23</td>
              <td>92%</td>
              <td>3.7</td>
              <td><span class="quality-indicator quality-good"></span> Good</td>
              <td>4.3</td>
            </tr>
            <tr>
              <td>Flavor Masters</td>
              <td>Ingredients</td>
              <td>9</td>
              <td>88%</td>
              <td>5.1</td>
              <td><span class="quality-indicator quality-average"></span> Average</td>
              <td>3.8</td>
            </tr>
            <tr>
              <td>Ceylon Teas</td>
              <td>Beverages</td>
              <td>0</td>
              <td>-</td>
              <td>-</td>
              <td>-</td>
              <td>-</td>
            </tr>
          </tbody>
        </table>
        
        <div class="report-footer">
          <div class="report-info">
            Report generated on May 11, 2025 at 2:30 PM
          </div>
          <div class="report-actions-footer">
            <button class="report-btn secondary-btn">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                <polyline points="7 10 12 15 17 10"></polyline>
                <line x1="12" y1="15" x2="12" y2="3"></line>
              </svg>
              Export as PDF
            </button>
            <button class="report-btn secondary-btn">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                <polyline points="7 10 12 15 17 10"></polyline>
                <line x1="12" y1="15" x2="12" y2="3"></line>
              </svg>
              Export as Excel
            </button>
          </div>
        </div>
      </div>
      
      <!-- Performance Metrics -->
      <div class="module-card">
        <div class="module-header">
          Key Performance Indicators
        </div>
        <div class="module-content">
          <div class="chart-container">
            [KPI Comparison Chart]
          </div>
          
          <div class="report-tab-container">
            <div class="report-tabs">
              <div class="report-tab active">On-Time Delivery</div>
              <div class="report-tab">Quality Consistency</div>
              <div class="report-tab">Price Stability</div>
              <div class="report-tab">Response Time</div>
            </div>
          </div>
          
          <table class="report-table">
            <thead>
              <tr>
                <th>Month</th>
                <th>Global Coffee</th>
                <th>Dairy Farms</th>
                <th>Sweet Supplies</th>
                <th>Package Solutions</th>
                <th>Flavor Masters</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>January 2025</td>
                <td>97%</td>
                <td>94%</td>
                <td>87%</td>
                <td>90%</td>
                <td>85%</td>
              </tr>
              <tr>
                <td>February 2025</td>
                <td>96%</td>
                <td>93%</td>
                <td>88%</td>
                <td>91%</td>
                <td>86%</td>
              </tr>
              <tr>
                <td>March 2025</td>
                <td>98%</td>
                <td>94%</td>
                <td>90%</td>
                <td>92%</td>
                <td>87%</td>
              </tr>
              <tr>
                <td>April 2025</td>
                <td>98%</td>
                <td>95%</td>
                <td>89%</td>
                <td>92%</td>
                <td>88%</td>
              </tr>
              <tr>
                <td>May 2025 (MTD)</td>
                <td>99%</td>
                <td>96%</td>
                <td>91%</td>
                <td>93%</td>
                <td>89%</td>
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
    // Mobile navigation toggle
    document.getElementById('mobileNavToggle').addEventListener('click', function() {
      document.getElementById('sidebar').classList.toggle('active');
    });
    
    // Tab switching functionality
    document.querySelectorAll('.report-tab').forEach(tab => {
      tab.addEventListener('click', function() {
        document.querySelector('.report-tab.active').classList.remove('active');
        this.classList.add('active');
        // In a real implementation, this would load the appropriate report content
      });
    });
    
    // Export button functionality (placeholder)
    document.querySelectorAll('.report-btn').forEach(button => {
      if (button.textContent.includes('Export')) {
        button.addEventListener('click', function() {
          alert('Export functionality would be implemented here');
        });
      }
    });
  </script>
</body>
</html>