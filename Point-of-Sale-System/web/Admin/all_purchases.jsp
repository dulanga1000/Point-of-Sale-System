<%-- 
    Document   : all_purchases
    Created on : May 21, 2025
    Author     : Your Name/AI
    Updated for swift_database (28).sql schema
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
  <title>All Purchase Orders - Swift POS</title>
  <link rel="stylesheet" href="styles.css">
  <style>
    /* Reusing and adapting styles from suppliers.jsp for consistency */
    :root { 
        --primary: #007bff;
        --secondary: #6c757d;
        --success: #28a745;
        --danger: #dc3545;
        --warning: #ffc107;
        --info: #17a2b8;
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
    .search-button, .create-po-btn {
      background-color: var(--primary);
      border: none;
      color: white;
      padding: 10px 15px;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      border-radius: 6px;
      font-weight: 500;
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
    
    .user-profile img { width: 40px; height: 40px; border-radius: 50%; margin-right: 10px; }
    .user-profile { display: flex; align-items: center;}
    .page-title { flex-grow: 1; }
    .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 20px; padding-bottom:15px; border-bottom: 1px solid #eee; }
    .footer { text-align: center; padding: 20px; margin-top: 30px; background-color: #f8f9fa; font-size: 0.9em; color: #777;}
    .module-card { background-color: #fff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); margin-top: 20px;}
    .module-header { padding: 15px; font-weight: bold; border-bottom: 1px solid #eee; }
    .module-content { padding: 15px; }

    table { width: 100%; border-collapse: collapse; margin-top:15px; }
    th, td { padding: 12px 15px; text-align: left; border-bottom: 1px solid #eee; font-size:0.9em; }
    thead th { background-color: #f8f9fa; font-weight: bold; }
    .status { padding: 4px 10px; border-radius: 15px; font-size: 0.85em; text-transform: capitalize; color: white; display: inline-block; min-width: 80px; text-align:center; }
    .status.pending { background-color: var(--warning); color: #333; }
    .status.approved { background-color: #0062cc; } /* A slightly different blue */
    .status.ordered { background-color: var(--info); }
    .status.shipped { background-color: #6f42c1; } /* A purple shade */
    .status.received { background-color: var(--success); } /* Alias for delivered */
    .status.delivered { background-color: var(--success); }
    .status.cancelled { background-color: var(--danger); }
    .status.partially-received { background-color: #fd7e14; } /* Orange for partially received */
    .status.draft { background-color: var(--secondary); }
    .total-amount { text-align: right; }


    @media (max-width: 768px) {
      .search-filter-bar { flex-direction: column; align-items: stretch; }
      .search-container, .filter-container, .create-po-btn { width: 100%; }
      .create-po-btn { justify-content: center; }
      .header { flex-direction: column; align-items: flex-start; }
      .user-profile { margin-top:10px; }
      th, td { padding: 8px; font-size: 0.85em; } 
      .action-buttons { flex-wrap: wrap; } 
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
        <h1 class="page-title">All Purchase Orders</h1>
        <div class="user-profile">
          <%
            Connection userConn = null;
            PreparedStatement userSql = null;
            ResultSet userResult = null;
            String URL = "jdbc:mysql://localhost:3306/swift_database"; // Database name from SQL dump
            String USER = "root"; 
            String PASSWORD = ""; 

            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                userConn = DriverManager.getConnection(URL, USER, PASSWORD);
                userSql = userConn.prepareStatement("SELECT first_name, profile_image_path FROM users WHERE role = 'admin' LIMIT 1"); // users table from SQL dump
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
                out.println("<p class='text-danger text-center'>Error loading user: " + ex.getMessage() + "</p>");
            } finally {
                if (userResult != null) try { userResult.close(); } catch (SQLException e) { /* Log */ }
                if (userSql != null) try { userSql.close(); } catch (SQLException e) { /* Log */ }
                if (userConn != null) try { userConn.close(); } catch (SQLException e) { /* Log */ }
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
      
      <div class="module-card">
        <div class="module-content">
          <div class="search-filter-bar">
            <div class="search-container">
              <input type="text" id="purchaseOrderSearchInput" placeholder="Search by Order # or Supplier..." class="search-input">
              <button class="search-button" onclick="filterPurchaseOrders()">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <circle cx="11" cy="11" r="8"></circle>
                  <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                </svg>
              </button>
            </div>
            <div class="filter-container">
              <select class="filter-select" id="statusFilter" onchange="filterPurchaseOrders()">
                <option value="all">All Statuses</option>
                <option value="Pending">Pending</option>
                <option value="Approved">Approved</option>
                <option value="Ordered">Ordered</option>
                <option value="Partially Received">Partially Received</option>
                <option value="Received">Received</option>
                <option value="Shipped">Shipped</option> {/* Added Shipped based on common practice */}
                <option value="Cancelled">Cancelled</option>
                <option value="Draft">Draft</option>
              </select>
            </div>
            <button class="create-po-btn" onclick="window.location.href='${pageContext.request.contextPath}/Admin/purchases.jsp'">
              <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                <line x1="12" y1="5" x2="12" y2="19"></line>
                <line x1="5" y1="12" x2="19" y2="12"></line>
              </svg>
              Create PO
            </button>
          </div>
          
          <table id="purchaseOrdersTable">
            <thead>
              <tr>
                <th>Order #</th>
                <th>Supplier</th>
                <th>Order Date</th>
                <th>Expected Delivery</th>
                <th>Status</th>
                <th class="total-amount">Total (Rs.)</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <%
                Connection conn = null;
                PreparedStatement stmt = null;
                ResultSet rs = null;
                NumberFormat currencyFormatter = NumberFormat.getCurrencyInstance(new Locale("en", "LK")); 

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    conn = DriverManager.getConnection(URL, USER, PASSWORD);
                    // Updated SQL query based on swift_database (28).sql schema
                    String sql = "SELECT po_main_id, order_number_display, supplier_company_name, " +
                                 "DATE_FORMAT(order_date_form, '%Y-%m-%d') AS formatted_order_date, " +
                                 "DATE_FORMAT(expected_delivery_date, '%Y-%m-%d') AS formatted_expected_date, " +
                                 "order_status, grand_total " +
                                 "FROM swift_purchase_orders_main ORDER BY order_date_form DESC, po_main_id DESC"; //
                    stmt = conn.prepareStatement(sql);
                    rs = stmt.executeQuery();
                    boolean hasOrders = false;
                    while (rs.next()) {
                        hasOrders = true;
                        String status = rs.getString("order_status"); // From swift_purchase_orders_main
                        if (status == null || status.trim().isEmpty()) {
                            status = "N/A"; 
                        }
                        // grand_total from swift_purchase_orders_main
                        double grandTotal = rs.getDouble("grand_total"); 
              %>
                      <tr>
                        <td><%= rs.getString("order_number_display") %></td> <%-- order_number_display from swift_purchase_orders_main --%>
                        <td><%= rs.getString("supplier_company_name") %></td> <%-- supplier_company_name from swift_purchase_orders_main --%>
                        <td><%= rs.getString("formatted_order_date") %></td> <%-- underlying order_date_form from swift_purchase_orders_main --%>
                        <td><%= rs.getString("formatted_expected_date") !=null ? rs.getString("formatted_expected_date") : "N/A" %></td> <%-- underlying expected_delivery_date from swift_purchase_orders_main --%>
                        <td><span class="status <%= status.toLowerCase().replaceAll("\\s+", "-") %>"><%= status %></span></td>
                        <td class="total-amount"><%= currencyFormatter.format(grandTotal).replace("LKR", "Rs. ") %></td>
                        <td class="action-buttons">
                          <button class="action-btn view-btn" title="View Order" onclick="viewPurchaseOrder('<%= rs.getString("po_main_id") %>')">👁️</button> <%-- po_main_id from swift_purchase_orders_main --%>
                          <button class="action-btn edit-btn" title="Edit Order" onclick="editPurchaseOrder('<%= rs.getString("po_main_id") %>')">✏️</button> <%-- po_main_id from swift_purchase_orders_main --%>
                        </td>
                      </tr>
              <% 
                    }
                    if(!hasOrders){
                         out.println("<tr><td colspan='7' style='text-align:center;'>No purchase orders found.</td></tr>");
                    }
                } catch (Exception ex) {
                    out.println("<tr><td colspan='7' class='text-danger text-center'>Error loading purchase orders: " + ex.getMessage() + "</td></tr>");
                    ex.printStackTrace(); 
                } finally {
                    if (rs != null) try { rs.close(); } catch (SQLException e) { /* Log */ }
                    if (stmt != null) try { stmt.close(); } catch (SQLException e) { /* Log */ }
                    if (conn != null) try { conn.close(); } catch (SQLException e) { /* Log */ }
                }
              %>
            </tbody>
          </table>
          
          <div class="pagination">
            <button class="pagination-btn" id="prevPageBtn" disabled>Previous</button>
            <div class="page-numbers" id="pageNumbersContainer">
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
    document.getElementById('mobileNavToggle').addEventListener('click', function() {
      document.getElementById('sidebar').classList.toggle('active');
    });
    
    function viewPurchaseOrder(orderId) { // orderId is po_main_id
      window.location.href = '${pageContext.request.contextPath}/Admin/view_purchase_order.jsp?id=' + orderId;
    }
    
    function editPurchaseOrder(orderId) { // orderId is po_main_id
      window.location.href = '${pageContext.request.contextPath}/Admin/edit_purchase_order.jsp?id=' + orderId;
    }

    const poTable = document.getElementById('purchaseOrdersTable');
    const poTableBody = poTable.getElementsByTagName('tbody')[0];
    const poAllRows = Array.from(poTableBody.getElementsByTagName('tr'));
    const poSearchInput = document.getElementById('purchaseOrderSearchInput');
    const poStatusFilterSelect = document.getElementById('statusFilter');

    const poRowsPerPage = 10; 
    let poCurrentPage = 1;
    let poFilteredRows = [...poAllRows];

    function displayPOTablePage(page) {
        poTableBody.innerHTML = ""; 
        page--; 

        const start = poRowsPerPage * page;
        const end = start + poRowsPerPage;
        const paginatedItems = poFilteredRows.slice(start, end);

        paginatedItems.forEach(row => poTableBody.appendChild(row));
    }

    function setupPOPaginationButtons() {
        const pageNumbersContainer = document.getElementById('pageNumbersContainer');
        pageNumbersContainer.innerHTML = ""; 

        const pageCount = Math.ceil(poFilteredRows.length / poRowsPerPage);
        const prevButton = document.getElementById('prevPageBtn');
        const nextButton = document.getElementById('nextPageBtn');

        prevButton.disabled = poCurrentPage === 1;
        nextButton.disabled = poCurrentPage === pageCount || pageCount === 0;
        
        let maxVisibleButtons = 5;
        let startPage = Math.max(1, poCurrentPage - Math.floor(maxVisibleButtons / 2));
        let endPage = Math.min(pageCount, startPage + maxVisibleButtons - 1);

        if (endPage - startPage + 1 < maxVisibleButtons && startPage > 1) {
            startPage = Math.max(1, endPage - maxVisibleButtons + 1);
        }

        if (startPage > 1) {
            const firstBtn = document.createElement('button');
            firstBtn.classList.add('page-btn');
            firstBtn.innerText = '1';
            firstBtn.addEventListener('click', function() { poCurrentPage = 1; displayPOTablePage(poCurrentPage); setupPOPaginationButtons(); });
            pageNumbersContainer.appendChild(firstBtn);
            if (startPage > 2) {
                 const ellipsis = document.createElement('span');
                 ellipsis.innerText = '...';
                 ellipsis.classList.add('page-ellipsis');
                 pageNumbersContainer.appendChild(ellipsis);
            }
        }

        for (let i = startPage; i <= endPage; i++) {
            const btn = document.createElement('button');
            btn.classList.add('page-btn');
            btn.innerText = i;
            if (i === poCurrentPage) {
                btn.classList.add('active');
            }
            btn.addEventListener('click', function() {
                poCurrentPage = i;
                displayPOTablePage(poCurrentPage);
                setupPOPaginationButtons(); 
            });
            pageNumbersContainer.appendChild(btn);
        }

        if (endPage < pageCount) {
            if (endPage < pageCount - 1) {
                 const ellipsis = document.createElement('span');
                 ellipsis.innerText = '...';
                 ellipsis.classList.add('page-ellipsis');
                 pageNumbersContainer.appendChild(ellipsis);
            }
            const lastBtn = document.createElement('button');
            lastBtn.classList.add('page-btn');
            lastBtn.innerText = pageCount;
            lastBtn.addEventListener('click', function() { poCurrentPage = pageCount; displayPOTablePage(poCurrentPage); setupPOPaginationButtons(); });
            pageNumbersContainer.appendChild(lastBtn);
        }

         if (pageCount === 0) {
            const noResultsMsg = document.createElement('span');
            noResultsMsg.innerText = "No matching orders";
            pageNumbersContainer.appendChild(noResultsMsg);
        }
    }

    function filterPurchaseOrders() {
        const searchTerm = poSearchInput.value.toLowerCase();
        const statusFilter = poStatusFilterSelect.value.toLowerCase();

        poFilteredRows = poAllRows.filter(row => {
            if (row.getElementsByTagName('td').length === 0) return false; 

            const orderNumberText = row.cells[0].textContent.toLowerCase();
            const supplierNameText = row.cells[1].textContent.toLowerCase();
            const statusElement = row.cells[4].querySelector('.status');
            const statusText = statusElement ? statusElement.textContent.toLowerCase() : "";

            const matchesSearch = orderNumberText.includes(searchTerm) || 
                                  supplierNameText.includes(searchTerm);
            const matchesStatus = statusFilter === 'all' || statusText === statusFilter;
            
            return matchesSearch && matchesStatus;
        });

        poCurrentPage = 1; 
        displayPOTablePage(poCurrentPage);
        setupPOPaginationButtons();
    }

    document.addEventListener('DOMContentLoaded', () => {
        if (poAllRows.length > 0 && poAllRows[0].getElementsByTagName('td').length > 1) { 
             filterPurchaseOrders(); 
        } else {
            document.getElementById('prevPageBtn').disabled = true;
            document.getElementById('nextPageBtn').disabled = true;
             if (poAllRows.length === 1 && poAllRows[0].getElementsByTagName('td')[0].colSpan > 1) {
                document.getElementById('pageNumbersContainer').innerHTML = poAllRows[0].getElementsByTagName('td')[0].textContent;
            } else {
                document.getElementById('pageNumbersContainer').innerHTML = "No purchase orders to display.";
            }
        }

        poSearchInput.addEventListener('keyup', filterPurchaseOrders);
        
        document.getElementById('prevPageBtn').addEventListener('click', () => {
            if (poCurrentPage > 1) {
                poCurrentPage--;
                displayPOTablePage(poCurrentPage);
                setupPOPaginationButtons();
            }
        });

        document.getElementById('nextPageBtn').addEventListener('click', () => {
            const pageCount = Math.ceil(poFilteredRows.length / poRowsPerPage);
            if (poCurrentPage < pageCount) {
                poCurrentPage++;
                displayPOTablePage(poCurrentPage);
                setupPOPaginationButtons();
            }
        });
    });
    
  </script>
</body>
</html>