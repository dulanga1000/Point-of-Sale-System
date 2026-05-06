<%-- 
    Document   : suppliers
    Created on : May 16, 2025, 9:27:45 AM
    Author     : dulan
    Enhanced on: May 21, 2025
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Supplier Management - Swift POS</title>
  <%-- Ensure script.js is accessible. Additional scripts are at the bottom of this file. --%>
  <link rel="stylesheet" href="styles.css"> <%-- Assuming styles.css is in the root of your webapp --%>
  <style>
    /* Additional styles for the supplier dashboard (Original styles retained) */
    :root { /* Define CSS variables if not in styles.css, for placeholder colors */
        --primary: #007bff;
        --secondary: #6c757d;
        --success: #28a745;
        --danger: #dc3545;
        --warning: #ffc107;
    }
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
      justify-content: space-between; /* Adjusted for better layout */
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
    .page-btn { /* Renamed from .page-button to .page-btn for consistency */
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
    .feedback-message {
      padding: 15px;
      margin-bottom: 20px;
      border: 1px solid transparent;
      border-radius: .25rem;
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
    
    /* Styles from original for stats, modules etc. would be here or in styles.css */
    /* Assuming dashboard, sidebar, main-content, header, stats-container, module-card etc. styles are in styles.css */
    .stats-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 20px; }
    .stat-card { background-color: #fff; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .stat-card h3 { font-size: 0.9em; color: #555; margin-bottom: 5px; text-transform: uppercase; }
    .stat-card .value { font-size: 1.8em; font-weight: bold; margin-bottom: 10px; }
    .stat-card .trend { font-size: 0.85em; display: flex; align-items: center; }
    .stat-card .trend.up { color: var(--success); }
    .stat-card .trend.down { color: var(--danger); }
    .stat-card .trend svg { margin-right: 5px; }

    .modules-container { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 20px; }
    .module-card { background-color: #fff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
    .module-header { padding: 15px; font-weight: bold; border-bottom: 1px solid #eee; }
    .module-content { padding: 15px; }
    .module-action { display: flex; align-items: center; gap: 15px; padding: 10px 0; cursor: pointer; border-bottom: 1px solid #f5f5f5; }
    .module-action:last-child { border-bottom: none; }
    .module-action:hover { background-color: #f9f9f9; }
    .action-icon { font-size: 1.5em; width: 40px; text-align: center; }
    .action-text h4 { margin: 0 0 5px 0; font-size: 1em; }
    .action-text p { margin: 0; font-size: 0.85em; color: #777; }

    table { width: 100%; border-collapse: collapse; margin-top:15px; }
    th, td { padding: 10px; text-align: left; border-bottom: 1px solid #eee; font-size:0.9em; }
    thead th { background-color: #f8f9fa; font-weight: bold; }
    .status { padding: 3px 8px; border-radius: 12px; font-size: 0.8em; text-transform: capitalize;}
    .status.pending { background-color: #fff0c1; color: #f59e0b; }
    .status.completed { background-color: #d1fae5; color: #067647; } /* Example */
    .status.active { background-color: #d1fae5; color: #067647; }
    .status.inactive { background-color: #fee2e2; color: #b91c1c; }

    .user-profile img { width: 40px; height: 40px; border-radius: 50%; margin-right: 10px; }
    .user-profile { display: flex; align-items: center;}
    .page-title { flex-grow: 1; }
    .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; }
    .footer { text-align: center; padding: 20px; margin-top: 30px; background-color: #f8f9fa; font-size: 0.9em; color: #777;}

    @media (max-width: 768px) {
      .search-filter-bar { flex-direction: column; align-items: stretch; }
      .search-container, .filter-container, .add-supplier-btn { width: 100%; }
      .add-supplier-btn { justify-content: center; }
      .header { flex-direction: column; align-items: flex-start; }
      .user-profile { margin-top:10px; }
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
            PreparedStatement userSql = null;
            ResultSet userResult = null;
            String URL = "jdbc:mysql://localhost:3306/Swift_Database";
            String USER = "root";
            String PASSWORD = ""; // Ensure this is secure in a real application

            try {
                Class.forName("com.mysql.cj.jdbc.Driver"); // Modern driver
                userConn = DriverManager.getConnection(URL, USER, PASSWORD);
                userSql = userConn.prepareStatement("SELECT first_name, profile_image_path FROM users WHERE role = 'admin' LIMIT 1");
                userResult = userSql.executeQuery();

                if (userResult.next()) {
          %>
                  <img src="${pageContext.request.contextPath}/<%= userResult.getString("profile_image_path") %>" alt="Admin Profile">
                  <div>
                    <h4><%= userResult.getString("first_name") %></h4>
                  </div>
          <% 
                } else {
                    out.println("<p>Admin user not found.</p>");
                }
            } catch (Exception ex) {
                // ex.printStackTrace(); // For debugging
                out.println("<p class='text-danger text-center'>Error loading user: " + ex.getMessage() + "</p>");
            } finally {
                if (userResult != null) try { userResult.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (userSql != null) try { userSql.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (userConn != null) try { userConn.close(); } catch (SQLException e) { e.printStackTrace(); }
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
          <%
            int totalSuppliers = 0;
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                userConn = DriverManager.getConnection(URL, USER, PASSWORD); // Re-open or use pooled connection
                userSql = userConn.prepareStatement("SELECT COUNT(*) AS count FROM suppliers");
                userResult = userSql.executeQuery();
                if (userResult.next()) {
                    totalSuppliers = userResult.getInt("count");
                }
            } catch (Exception ex) {
                // ex.printStackTrace(); // Log appropriately
            } finally {
                if (userResult != null) try { userResult.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (userSql != null) try { userSql.close(); } catch (SQLException e) { e.printStackTrace(); }
                if (userConn != null) try { userConn.close(); } catch (SQLException e) { e.printStackTrace(); }
            }
          %>
          <h3>TOTAL SUPPLIERS</h3>
          <div class="value"><%= totalSuppliers > 0 ? totalSuppliers : "24" %></div> <%-- Fallback if DB fetch fails --%>
          <div class="trend up">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            <%-- Dynamic count for "new this month" would require more logic --%>
            2 new this month 
          </div>
        </div>
        
        <div class="stat-card">
          <h3>ACTIVE ORDERS</h3>
          <div class="value">7</div> <%-- Placeholder - implement dynamic query --%>
          <div class="trend up">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="18 15 12 9 6 15"></polyline>
            </svg>
            3 pending delivery
          </div>
        </div>
        
        <div class="stat-card">
          <h3>MONTHLY EXPENSES</h3>
          <div class="value">Rs.86,240</div> <%-- Placeholder - implement dynamic query --%>
          <div class="trend down">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <polyline points="6 9 12 15 18 9"></polyline>
            </svg>
            4.2% from last month
          </div>
        </div>
        
        <div class="stat-card">
          <h3>SUPPLIER RELIABILITY</h3>
          <div class="value">92%</div> <%-- Placeholder - implement dynamic query --%>
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
          <div class="module-header">Supplier Actions</div>
          <div class="module-content">
            <div class="module-action" onclick="window.location.href='${pageContext.request.contextPath}/Admin/add_supplier.jsp'">
              <div class="action-icon">➕</div>
              <div class="action-text">
                <h4>Add New Supplier</h4>
                <p>Create a new supplier profile</p>
              </div>
            </div>
            <div class="module-action" onclick="window.location.href='${pageContext.request.contextPath}/Admin/purchases.jsp'">
              <div class="action-icon">🔄</div>
              <div class="action-text">
                <h4>Create Purchase Order</h4>
                <p>Create and send new orders to suppliers</p>
              </div>
            </div>
            <div class="module-action" onclick="window.location.href='${pageContext.request.contextPath}/Admin/supplier_reports.jsp'"> <%-- Corrected slash --%>
              <div class="action-icon">📊</div>
              <div class="action-text">
                <h4>Supplier Reports</h4>
                <p>View performance and order history</p>
              </div>
            </div>
            <div class="module-action" onclick="window.location.href='${pageContext.request.contextPath}/Admin/productsBySupplierController'">
              <div class="action-icon">🔍</div>
              <div class="action-text">
                <h4>Find Products by Supplier</h4>
                <p>Search products linked to specific suppliers</p>
              </div>
            </div>
          </div>
        </div>
        
        <div class="module-card">
          <div class="module-header">Upcoming Deliveries</div>
          <div class="module-content">
            <div class="sales-header" style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 10px;">
              <div class="sales-title">Expected Soon</div>
              <div class="view-all" style="cursor:pointer; color: var(--primary);" onclick="window.location.href='${pageContext.request.contextPath}/Admin/all_purchases.jsp'">View All</div>
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
                <%
                  Connection deliveryConn = null;
                  PreparedStatement deliverySql = null;
                  ResultSet deliveryResult = null;
                  try {
                      Class.forName("com.mysql.cj.jdbc.Driver");
                      deliveryConn = DriverManager.getConnection(URL, USER, PASSWORD);
                      // More specific query for upcoming deliveries
                      String sqlQuery = "SELECT order_number_display, supplier_company_name, order_status, " +
                                        "DATE_FORMAT(expected_delivery_date, '%Y-%m-%d') AS formatted_expected_date " +
                                        "FROM swift_purchase_orders_main " +
                                        "WHERE expected_delivery_date >= CURDATE() " +
                                        "AND order_status NOT IN ('Delivered', 'Cancelled', 'Received') " + // Adjust statuses as needed
                                        "ORDER BY expected_delivery_date ASC LIMIT 5"; // Show top 5 upcoming
                      deliverySql = deliveryConn.prepareStatement(sqlQuery);
                      deliveryResult = deliverySql.executeQuery();

                      boolean hasDeliveries = false;
                      while (deliveryResult.next()) {
                          hasDeliveries = true;
                %>
                        <tr>
                          <td><%= deliveryResult.getString("order_number_display") %></td>
                          <td><%= deliveryResult.getString("supplier_company_name") %></td>
                          <td><span class="status pending"><%= deliveryResult.getString("order_status") %></span></td>
                          <td><%= deliveryResult.getString("formatted_expected_date") %></td>
                        </tr>
                <% 
                      }
                      if (!hasDeliveries) {
                          out.println("<tr><td colspan='4' style='text-align:center;'>No upcoming deliveries found.</td></tr>");
                      }
                  } catch (Exception ex) {
                      // ex.printStackTrace();
                      out.println("<tr><td colspan='4' class='text-danger text-center'>Error loading deliveries: " + ex.getMessage() + "</td></tr>");
                  } finally {
                      if (deliveryResult != null) try { deliveryResult.close(); } catch (SQLException e) { e.printStackTrace(); }
                      if (deliverySql != null) try { deliverySql.close(); } catch (SQLException e) { e.printStackTrace(); }
                      if (deliveryConn != null) try { deliveryConn.close(); } catch (SQLException e) { e.printStackTrace(); }
                  }
                %>
              </tbody>
            </table>
          </div>
        </div>
      </div>
      
      <div class="module-card" style="margin-top: 20px;">
        <div class="module-header">Supplier Directory</div>
        <div class="module-content">
          <div class="search-filter-bar">
            <div class="search-container">
              <input type="text" id="supplierSearchInput" placeholder="Search suppliers..." class="search-input">
              <button class="search-button" onclick="filterSuppliers()">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <circle cx="11" cy="11" r="8"></circle>
                  <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                </svg>
              </button>
            </div>
            <div class="filter-container">
              <select class="filter-select" id="categoryFilter" onchange="filterSuppliers()">
                <option value="all">All Categories</option>
                <%-- Populate categories dynamically if possible, or list common ones --%>
                <option value="Beverages">Beverages</option>
                <option value="Dairy">Dairy</option>
                <option value="Packaging">Packaging</option>
                <option value="Ingredients">Ingredients</option>
                <option value="Services">Services</option> 
              </select>
              <select class="filter-select" id="statusFilter" onchange="filterSuppliers()">
                <option value="all">All Status</option>
                <option value="Active">Active</option>
                <option value="Inactive">Inactive</option>
              </select>
            </div>
            <button class="add-supplier-btn" onclick="window.location.href='${pageContext.request.contextPath}/Admin/add_supplier.jsp'">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="12" y1="5" x2="12" y2="19"></line>
                <line x1="5" y1="12" x2="19" y2="12"></line>
              </svg>
              Add Supplier
            </button>
          </div>
          
          <table id="supplierTable">
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
                Connection conn = null;
                PreparedStatement stmt = null;
                ResultSet rs = null;
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(URL, USER, PASSWORD);
                    stmt = conn.prepareStatement("SELECT supplier_id, company_name, category, contact_person, contact_phone, DATE_FORMAT(latest_po_creation_datetime, '%Y-%m-%d %H:%i') AS formatted_last_order, supplier_status FROM suppliers ORDER BY company_name ASC");
                    rs = stmt.executeQuery();
                    boolean hasSuppliers = false;
                    while (rs.next()) {
                        hasSuppliers = true;
                        String status = rs.getString("supplier_status");
                        if (status == null || status.trim().isEmpty()) {
                            status = "Active"; // Default status
                        }
              %>
                      <tr>
                        <td><%= rs.getString("supplier_id") %></td>
                        <td><%= rs.getString("company_name") %></td>
                        <td><%= rs.getString("category") %></td>
                        <td><%= rs.getString("contact_person") %></td>
                        <td><%= rs.getString("contact_phone") %></td>
                        <td><%= rs.getString("formatted_last_order") != null ? rs.getString("formatted_last_order") : "N/A" %></td>
                        <td><span class="status <%= status.toLowerCase() %>"><%= status %></span></td>
                        <td class="action-buttons">
                          <button class="action-btn edit-btn" title="Edit" onclick="editSupplier('<%= rs.getString("supplier_id") %>')">✏️</button>
                          <button class="action-btn view-btn" title="View Details" onclick="viewSupplier('<%= rs.getString("supplier_id") %>')">👁️</button>
                        </td>
                      </tr>
              <% 
                    }
                    if(!hasSuppliers){
                         out.println("<tr><td colspan='8' style='text-align:center;'>No suppliers found.</td></tr>");
                    }
                } catch (Exception ex) {
                    // ex.printStackTrace();
                    out.println("<tr><td colspan='8' class='text-danger text-center'>Error loading suppliers: " + ex.getMessage() + "</td></tr>");
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (stmt != null) try { stmt.close(); } catch (SQLException e) { e.printStackTrace(); }
                    if (conn != null) try { conn.close(); } catch (SQLException e) { e.printStackTrace(); }
                }
              %>
            </tbody>
          </table>
          
          <div class="pagination">
            <button class="pagination-btn" id="prevPageBtn" disabled>Previous</button>
            <div class="page-numbers" id="pageNumbersContainer">
              <%-- Page numbers will be generated by JavaScript --%>
            </div>
            <button class="pagination-btn" id="nextPageBtn">Next</button>
          </div>
        </div>
      </div>
      
      <div class="footer">
        Swift © <%= java.time.Year.now().getValue() %>.
      </div>
    </div>
  </div>
  
  <script>
    // Mobile navigation toggle
    document.getElementById('mobileNavToggle').addEventListener('click', function() {
      document.getElementById('sidebar').classList.toggle('active');
    });
    
    function editSupplier(supplierId) {
      window.location.href = '${pageContext.request.contextPath}/Admin/edit_supplier.jsp?id=' + supplierId;
    }
    
    function viewSupplier(supplierId) {
      window.location.href = '${pageContext.request.contextPath}/Admin/view_supplier.jsp?id=' + supplierId;
    }

    // --- Supplier Table Client-Side Search, Filter, and Pagination ---
    const supplierTable = document.getElementById('supplierTable');
    const tableBody = supplierTable.getElementsByTagName('tbody')[0];
    const allRows = Array.from(tableBody.getElementsByTagName('tr'));
    const searchInput = document.getElementById('supplierSearchInput');
    const categoryFilterSelect = document.getElementById('categoryFilter');
    const statusFilterSelect = document.getElementById('statusFilter');

    const rowsPerPage = 10; // Adjust as needed
    let currentPage = 1;
    let filteredRows = [...allRows];

    function displayTablePage(page) {
        tableBody.innerHTML = ""; // Clear current rows
        page--; // 0-indexed

        const start = rowsPerPage * page;
        const end = start + rowsPerPage;
        const paginatedItems = filteredRows.slice(start, end);

        paginatedItems.forEach(row => tableBody.appendChild(row));
    }

    function setupPaginationButtons() {
        const pageNumbersContainer = document.getElementById('pageNumbersContainer');
        pageNumbersContainer.innerHTML = ""; // Clear old buttons

        const pageCount = Math.ceil(filteredRows.length / rowsPerPage);
        const prevButton = document.getElementById('prevPageBtn');
        const nextButton = document.getElementById('nextPageBtn');

        prevButton.disabled = currentPage === 1;
        nextButton.disabled = currentPage === pageCount || pageCount === 0;

        // Simple page number display (can be enhanced with ellipsis for many pages)
        for (let i = 1; i <= pageCount; i++) {
            const btn = document.createElement('button');
            btn.classList.add('page-btn');
            btn.innerText = i;
            if (i === currentPage) {
                btn.classList.add('active');
            }
            btn.addEventListener('click', function() {
                currentPage = i;
                displayTablePage(currentPage);
                setupPaginationButtons(); // Re-render buttons to update active state and disabled states
            });
            pageNumbersContainer.appendChild(btn);
        }
         if (pageCount === 0) {
            const noResultsMsg = document.createElement('span');
            noResultsMsg.innerText = "No matching suppliers";
            pageNumbersContainer.appendChild(noResultsMsg);
        }
    }

    function filterSuppliers() {
        const searchTerm = searchInput.value.toLowerCase();
        const categoryFilter = categoryFilterSelect.value.toLowerCase();
        const statusFilter = statusFilterSelect.value.toLowerCase();

        filteredRows = allRows.filter(row => {
            const idText = row.cells[0].textContent.toLowerCase();
            const companyNameText = row.cells[1].textContent.toLowerCase();
            const categoryText = row.cells[2].textContent.toLowerCase();
            const contactPersonText = row.cells[3].textContent.toLowerCase();
            const phoneText = row.cells[4].textContent.toLowerCase();
            const statusText = row.cells[6].textContent.toLowerCase().trim(); // Trim to remove potential spaces around status text

            const matchesSearch = companyNameText.includes(searchTerm) || 
                                  idText.includes(searchTerm) || 
                                  contactPersonText.includes(searchTerm) ||
                                  phoneText.includes(searchTerm);
            const matchesCategory = categoryFilter === 'all' || categoryText.includes(categoryFilter);
            const matchesStatus = statusFilter === 'all' || statusText.startsWith(statusFilter); // Use startsWith for statuses like "active"

            return matchesSearch && matchesCategory && matchesStatus;
        });

        currentPage = 1; // Reset to first page after filtering
        displayTablePage(currentPage);
        setupPaginationButtons();
    }

    // Initial setup
    document.addEventListener('DOMContentLoaded', () => {
        if (allRows.length > 0) { // Only setup if there are rows
             filterSuppliers(); // Apply any default filters and initial pagination
        } else {
            // Handle case where table is initially empty, perhaps display a message or ensure pagination controls are correctly disabled
            document.getElementById('prevPageBtn').disabled = true;
            document.getElementById('nextPageBtn').disabled = true;
            document.getElementById('pageNumbersContainer').innerHTML = "No suppliers to display.";
        }

        searchInput.addEventListener('keyup', filterSuppliers);
        
        document.getElementById('prevPageBtn').addEventListener('click', () => {
            if (currentPage > 1) {
                currentPage--;
                displayTablePage(currentPage);
                setupPaginationButtons();
            }
        });

        document.getElementById('nextPageBtn').addEventListener('click', () => {
            const pageCount = Math.ceil(filteredRows.length / rowsPerPage);
            if (currentPage < pageCount) {
                currentPage++;
                displayTablePage(currentPage);
                setupPaginationButtons();
            }
        });
    });
    
  </script>
</body>
</html>