<%--
    Document   : purchases
    Created on : May 16, 2025, 9:26:53 AM
    Author     : dulan
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Product" %>
<%@ page import="dao.ProductDAO" %>
<%@ page import="util.DBConnection" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>

<%
    // --- Pagination Parameters ---
    int itemsPerPage = 7; // Show 7 products per page
    
    // Get the requested page from URL parameter, default to 1 if not present
    int currentPage = 1;
    String pageParam = request.getParameter("page");
    if (pageParam != null && !pageParam.isEmpty()) {
        try {
            currentPage = Integer.parseInt(pageParam);
            if (currentPage < 1) currentPage = 1; // Ensure page is at least 1
        } catch (NumberFormatException e) {
            // If page parameter is not a valid number, default to page 1
            currentPage = 1;
        }
    }
    
    // Calculate the SQL OFFSET (starting index for records)
    int offset = (currentPage - 1) * itemsPerPage;
    
    // --- Database Interaction Scriptlet ---
    Connection conn = null;
    List<Product> productList = null;
    String errorMessageJsp = null; // Renamed to avoid conflict with errorParam
    int totalProducts = 0;
    int totalPages = 0;
    int lowStockCount = 0;
    int uniqueCategoryCount = 0;

    try {
        // Get database connection
        conn = DBConnection.getConnection();

        if (conn != null) {
            // If connection is successful, create DAO and fetch paginated products
            ProductDAO productDAO = new ProductDAO(conn);
            
            // Get paginated list of products
            productList = productDAO.getProductsByPage(itemsPerPage, offset);
            
            // Get total count for pagination calculations
            totalProducts = productDAO.getTotalProductCount();
            
            // Calculate total pages
            totalPages = (int) Math.ceil((double) totalProducts / itemsPerPage);
            
            // If current page is beyond total pages, redirect to last page
            if (totalPages > 0 && currentPage > totalPages) {
                response.sendRedirect(request.getContextPath() + "/Admin/products.jsp?page=" + totalPages);
                return;
            }
            
            // Get statistics for dashboard
            lowStockCount = productDAO.getLowStockCount(10); // Threshold of 10 for low stock
            uniqueCategoryCount = productDAO.getUniqueCategoryCount();
        } else {
            // If connection failed, set an error message
            errorMessageJsp = "Error: Database connection failed.";
        }
    } catch (Exception e) {
        // Catch any exceptions during the process (DB errors, etc.)
        e.printStackTrace(); // Log the error on the server console
        errorMessageJsp = "Error retrieving products: " + e.getMessage();
    } finally {
        // Always close the database connection
        DBConnection.closeConnection(conn);
    }

    // Optional: Format price for display
    DecimalFormat df = new DecimalFormat("#.00");

    // --- Calculate display range values ---
    int displayedItemsStart = Math.min(totalProducts, offset + 1);
    int displayedItemsEnd = Math.min(totalProducts, offset + itemsPerPage);
    
    // Handle case where total products is 0
    if (totalProducts == 0) {
        displayedItemsStart = 0;
        displayedItemsEnd = 0;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Products Management</title>
    <%-- Ensure these file paths are correct relative to your JSP --%>
    <script src="${pageContext.request.contextPath}/Admin/script.js"></script> <%-- Adjusted path to Admin folder if script.js is there --%>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/Admin/styles.css"> <%-- Adjusted path --%>
    <style>
        /* Additional CSS for Products page (Copied from your original JSP) */

        /* Action Bar Styles */
        .action-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            flex-wrap: wrap;
            gap: 15px;
        }

        .search-container {
            display: flex;
            align-items: center;
            background-color: white;
            border-radius: 6px;
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
            min-width: 250px;
        }

        .search-input {
            border: none;
            padding: 10px 15px;
            flex: 1;
            outline: none;
            font-size: 14px;
        }

        .search-button {
            background-color: transparent;
            border: none;
            padding: 10px 15px;
            cursor: pointer;
            color: var(--secondary);
        }

        .filter-container {
            display: flex;
            gap: 10px;
            flex-wrap: wrap;
        }

        .filter-select {
            padding: 10px 15px;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            background-color: white;
            font-size: 14px;
            color: var(--dark);
            outline: none;
            cursor: pointer;
        }

        .primary-button {
            display: flex;
            align-items: center;
            gap: 8px;
            background-color: var(--primary);
            color: white;
            border: none;
            border-radius: 6px;
            padding: 10px 20px;
            cursor: pointer;
            font-weight: 500;
            transition: background-color 0.2s;
            text-decoration: none; 
        }

        .primary-button:hover {
            background-color: var(--primary-dark);
        }
         .primary-button a {
            text-decoration: none; 
            color: inherit;
         }


        /* Products Table Styles */
        .products-table {
            width: 100%;
            border-collapse: collapse; 
            margin-top: 15px; 
        }
        /* Table Headers */
        .products-table thead th {
            padding: 12px 15px;
            text-align: left;
            font-size: 13px;
            font-weight: 600;
            color: var(--secondary);
            border-bottom: 1px solid #e2e8f0;
        }
        /* Table Data Cells */
        .products-table tbody td {
            padding: 12px 15px;
            font-size: 14px;
            color: var(--dark);
            border-bottom: 1px solid #e2e8f0;
        }

        .products-table tbody tr:last-child td {
            border-bottom: none; /* No border on the last row */
        }

        .products-table tbody tr:hover {
            background-color: #f9fafb; /* Hover effect */
        }


        .module-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
        }

        .header-title {
            font-weight: 600;
            font-size: 16px;
        }

        .header-actions {
            display: flex;
            gap: 10px;
        }

        .icon-button {
            display: flex;
            align-items: center;
            gap: 8px;
            background-color: transparent;
            border: 1px solid #e2e8f0;
            border-radius: 6px;
            padding: 8px 12px;
            font-size: 14px;
            cursor: pointer;
            transition: background-color 0.2s;
            color: var(--secondary);
        }

        .icon-button:hover {
            background-color: #f1f5f9;
        }

        .select-all-checkbox,
        .row-checkbox {
            width: 16px;
            height: 16px;
            cursor: pointer;
        }

        .product-info {
            display: flex;
            align-items: center;
            gap: 10px;
        }

        .product-thumbnail {
            width: 40px;
            height: 40px;
            border-radius: 4px;
            object-fit: cover;
        }

        .product-details {
            display: flex;
            flex-direction: column;
        }

        .product-name {
            font-weight: 500;
            margin-bottom: 2px;
        }

        .product-id {
            font-size: 12px;
            color: var(--secondary);
        }

        .stock-level {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
            width: fit-content;
        }

        .stock-level.high { /* Green */
            background-color: #d1fae5;
            color: #047857; /* Deeper green */
        }

        .stock-level.medium { /* Blue */
            background-color: #e0f2fe;
            color: #0284c7; /* Deeper blue */
        }

        .stock-level.low { /* Red */
            background-color: #fee2e2;
            color: #dc2626; /* Deeper red */
        }

        .row-actions {
            display: flex;
            gap: 6px;
        }

        .action-button {
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: transparent;
            border: none;
            width: 28px;
            height: 28px;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.2s;
        }

        .action-button.edit {
            color: var(--primary);
        }

        .action-button.delete {
            color: var(--danger);
        }

        .action-button:hover {
            background-color: #f1f5f9;
        }

        /* Status Styles */
        .status {
            padding: 4px 8px;
            border-radius: 4px;
            font-size: 12px;
            font-weight: 500;
            display: inline-block; 
        }

        .status.completed { /* Use for 'Active' */
            background-color: #d1fae5;
            color: #047857; 
        }

        .status.pending { /* Use for 'Inactive' or other non-active states */
            background-color: #fef3c7;
            color: #d97706; 
        }

        .status.warning { 
            background-color: #fef3c7;
            color: #d97706;
        }

         .trend.neutral {
            color: var(--secondary);
         }

        /* Pagination Styles */
        .pagination {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 20px;
            flex-wrap: wrap;
            gap: 15px;
        }

        .pagination-info {
            font-size: 14px;
            color: var(--secondary);
        }

        .pagination-controls {
            display: flex;
            gap: 5px;
        }

        .pagination-button {
            padding: 6px 12px;
            border: 1px solid #e2e8f0;
            background-color: white;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: all 0.2s;
        }

        .pagination-button.active {
            background-color: var(--primary);
            color: white;
            border-color: var(--primary);
        }

        .pagination-button:hover:not(.active):not([disabled]) {
            background-color: #f1f5f9;
        }

        .pagination-button[disabled] {
            opacity: 0.5;
            cursor: not-allowed;
        }

        /* Responsive Adjustments */
        @media (max-width: 768px) {
            .action-bar {
                flex-direction: column;
                align-items: stretch;
            }

            .search-container {
                width: 100%;
            }

            .filter-container {
                width: 100%;
                justify-content: space-between;
            }

            .filter-select {
                flex: 1;
                min-width: 120px;
            }

            .primary-button {
                width: 100%;
                justify-content: center;
            }

            .pagination {
                flex-direction: column;
                align-items: center;
            }

            .module-content {
                overflow-x: auto; 
            }

            .products-table {
                min-width: 700px; 
            }
        }

        @media (max-width: 480px) {
            .header-actions {
                margin-top: 10px;
                justify-content: flex-start; 
            }

            .module-header {
                flex-direction: column;
                align-items: flex-start;
                gap: 10px;
            }

            .filter-container {
                flex-direction: column;
            }

            .filter-select {
                width: 100%;
            }
        }

        /* Style for no image placeholder */
        .no-image {
            font-size: 12px;
            color: var(--secondary);
            text-align: center;
        }
        /* Error message styling (can be reused for success messages with different colors) */
        .feedback-message { /* Generic class for feedback */
            padding: 10px;
            margin-bottom: 15px;
            border-radius: 4px;
            text-align: center;
        }
        .error-message-jsp { /* Specific for JSP scriptlet variable */
            color: red;
            background-color: #ffebeb;
            border: 1px solid red;
        }
        .success-message-url { /* For URL param success */
            color: green;
            background-color: #e6ffe6;
            border: 1px solid green;
        }
        .error-message-url { /* For URL param error */
             color: red;
             background-color: #ffebeb;
             border: 1px solid red;
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
            <%-- Include the menu here --%>
            <jsp:include page="menu.jsp" />
        </div>

        <div class="main-content">
            <div class="header">
                <h1 class="page-title">Products Management</h1>
                <div class="user-profile">
            <%
                Connection userConn = null;
                String URL = "jdbc:mysql://localhost:3306/Swift_Database"; // Ensure this matches DBConnection
                String USER = "root"; // Ensure this matches DBConnection
                String PASSWORD = "";   // Ensure this matches DBConnection

                try {
                    Class.forName("com.mysql.cj.jdbc.Driver"); // Updated driver
                    userConn = DriverManager.getConnection(URL, USER, PASSWORD);
                    PreparedStatement sql = userConn.prepareStatement("SELECT * FROM users WHERE role = 'admin' LIMIT 1");
                    ResultSet result = sql.executeQuery();

                    if (result.next()) { %>
                        <img src="${pageContext.request.contextPath}/<%= result.getString("profile_image_path") != null ? result.getString("profile_image_path") : "Images/placeholder-user.png" %>" alt="Admin Profile">
                        <div>
                            <h4><%= result.getString("first_name") %></h4>
                        </div>
                    <% }
                    result.close();
                    sql.close();
                } catch (Exception ex) {
                    out.println("<p class='text-danger text-center'>Error loading user: " + ex.getMessage() + "</p>");
                    ex.printStackTrace();
                } finally {
                    if (userConn != null) {
                        try {
                            userConn.close();
                        } catch (SQLException e) {
                            e.printStackTrace();
                        }
                    }
                }
            %>
                </div>
            </div>

            <%
                String successParam = request.getParameter("success");
                String errorParam = request.getParameter("error");
                String errorDetails = request.getParameter("details");

                if (successParam != null) {
                    if ("delete".equals(successParam)) {
                        out.println("<p class='feedback-message success-message-url'>Product deleted successfully!</p>");
                    } else if ("update".equals(successParam)) { // Example for update
                        out.println("<p class='feedback-message success-message-url'>Product updated successfully!</p>");
                    }
                    // Add other success messages if needed
                }

                if (errorParam != null) {
                    String displayErrorMessage = "An error occurred while processing your request.";
                    if ("invalid_id".equals(errorParam)) {
                        displayErrorMessage = "Error: The product ID provided was invalid.";
                    } else if ("missing_id".equals(errorParam)) {
                        displayErrorMessage = "Error: No product ID was provided for the operation.";
                    } else if ("db_delete_failed".equals(errorParam)) {
                        displayErrorMessage = "Error: Failed to delete the product from the database. The product might not exist, or it could be referenced by other data (e.g., in existing orders). Check server logs for more details.";
                    } else if ("db_connection_failed".equals(errorParam)) {
                        displayErrorMessage = "Error: Could not connect to the database. Please check server logs.";
                    } else if ("sql_exception".equals(errorParam)) {
                        displayErrorMessage = "Database Error: An SQL exception occurred. Please check server logs for specific details.";
                        if (errorDetails != null && !errorDetails.isEmpty()) {
                            displayErrorMessage += " Details: " + errorDetails.replace("<", "&lt;").replace(">", "&gt;");
                        }
                    } else if ("unexpected".equals(errorParam)) {
                        displayErrorMessage = "An unexpected error occurred. Please try again or check server logs.";
                    } else if ("db_update".equals(errorParam)){
                         displayErrorMessage = "Error: Failed to update product in the database.";
                    }
                     // Add other specific error messages based on parameters your servlets might send
                    out.println("<p class='feedback-message error-message-url'>" + displayErrorMessage + "</p>");
                }
            %>
            <div class="action-bar">
                <div class="search-container">
                    <input type="text" placeholder="Search products..." class="search-input" id="searchInput">
                    <button class="search-button" id="searchButton">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <circle cx="11" cy="11" r="8"></circle>
                            <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                        </svg>
                    </button>
                </div>

                <div class="filter-container">
                    <select class="filter-select" id="categoryFilter">
                        <option value="">All Categories</option>
                        <option value="coffee">Coffee</option>
                        <option value="tea">Tea</option>
                        <option value="pastries">Pastries</option>
                        <option value="sandwiches">Sandwiches</option>
                        <option value="accessories">Accessories</option>
                        <option value="Dairy">Dairy</option>
                        <option value="Syrups">Syrups</option>
                        <option value="Supplies">Supplies</option>
                    </select>

                    <select class="filter-select" id="supplierFilter">
                        <option value="">All Suppliers</option>
                        <option value="global-coffee">Global Coffee Co.</option>
                        <option value="dairy-farms">Dairy Farms Inc.</option>
                        <option value="sweet-supplies">Sweet Supplies Ltd.</option>
                        <option value="package-solutions">Package Solutions</option>
                        <option value="flavor-masters">Flavor Masters</option>
                    </select>

                    <select class="filter-select" id="stockFilter">
                        <option value="">Stock Status</option>
                        <option value="in-stock">In Stock</option>
                        <option value="low-stock">Low Stock</option>
                        <option value="out-of-stock">Out of Stock</option>
                    </select>
                </div>

                <button class="primary-button">
                    <a href="<%= request.getContextPath() %>/Admin/add_product.jsp">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <line x1="12" y1="5" x2="12" y2="19"></line>
                            <line x1="5" y1="12" x2="19" y2="12"></line>
                        </svg>
                        Add New Product
                    </a>
                </button>
            </div>

            <div class="stats-container">
                <div class="stat-card">
                    <h3>TOTAL PRODUCTS</h3>
                    <div class="value"><%= totalProducts %></div>
                    <div class="trend up">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="18 15 12 9 6 15"></polyline></svg>
                        5 new products added
                    </div>
                </div>
                <div class="stat-card">
                    <h3>LOW STOCK ITEMS</h3>
                    <div class="value"><%= lowStockCount %></div>
                    <div class="trend down">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="6 9 12 15 18 9"></polyline></svg>
                        3 more than yesterday
                    </div>
                </div>
                <div class="stat-card">
                    <h3>TOP SELLING</h3>
                    <div class="value">Cappuccino</div>
                    <div class="trend up">
                         <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="18 15 12 9 6 15"></polyline></svg>
                        18.3% increase in sales
                    </div>
                </div>
                <div class="stat-card">
                    <h3>PRODUCT CATEGORIES</h3>
                    <div class="value"><%= uniqueCategoryCount %></div>
                    <div class="trend neutral">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><line x1="5" y1="12" x2="19" y2="12"></line></svg>
                        No change
                    </div>
                </div>
            </div>

            <div class="module-card" style="margin-top: 20px;">
                <div class="module-header">
                    <div class="header-title">Products List</div>
                    <div class="header-actions">
                        <button class="icon-button">
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <path d="M21 15v4a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2v-4"></path>
                                <polyline points="7 10 12 15 17 10"></polyline>
                                <line x1="12" y1="15" x2="12" y2="3"></line>
                            </svg>
                            Export
                        </button>
                        <button class="icon-button" onclick="window.location.reload();"> 
                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                <polyline points="1 4 1 10 7 10"></polyline>
                                <polyline points="23 20 23 14 17 14"></polyline>
                                <path d="M20.49 9A9 9 0 0 0 5.64 5.64L1 10m22 4l-4.64 4.36A9 9 0 0 1 3.51 15"></path>
                            </svg>
                            Refresh
                        </button>
                    </div>
                </div>
                <div class="module-content">
                    <%-- Display error message from JSP scriptlet if connection or retrieval failed --%>
                    <% if (errorMessageJsp != null) { %>
                        <p class="feedback-message error-message-jsp"><%= errorMessageJsp %></p>
                    <% } %>
                    <table class="products-table">
                        <thead>
                            <tr>
                                <th><input type="checkbox" class="select-all-checkbox"></th>
                                <th>Product</th>
                                <th>SKU</th>
                                <th>Category</th>
                                <th>Price</th>
                                <th>Stock</th>
                                <th>Supplier</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <%
                                if (productList != null && !productList.isEmpty()) {
                                    for (Product product : productList) {
                            %>
                            <tr>
                                <td><input type="checkbox" class="row-checkbox" value="<%= product.getId() %>"></td>
                                <td>
                                    <div class="product-info">
                                        <%
                                            String productImageUrl = request.getContextPath() + "/Images/default.jpg"; 
                                            if (product.getImagePath() != null && !product.getImagePath().isEmpty() && !product.getImagePath().endsWith("default.jpg")) {
                                                productImageUrl = request.getContextPath() + "/" + product.getImagePath();
                                            }
                                        %>
                                        <img src="<%= productImageUrl %>" alt="<%= product.getName() %> Image" class="product-thumbnail">
                                        <div class="product-details">
                                            <span class="product-name"><%= product.getName() %></span>
                                            <span class="product-id">#PROD-<%= product.getId() %></span>
                                        </div>
                                    </div>
                                </td>
                                <td><%= product.getSku() != null ? product.getSku() : "N/A" %></td>
                                <td><%= product.getCategory() != null ? product.getCategory() : "N/A" %></td>
                                <td>Rs.<%= df.format(product.getPrice()) %></td>
                                <td>
                                    <%
                                        String stockClass = "low"; 
                                        if (product.getStock() >= 50) { 
                                            stockClass = "high";
                                        } else if (product.getStock() >= 10) { 
                                            stockClass = "medium";
                                        } 
                                    %>
                                    <div class="stock-level <%= stockClass %>"><%= product.getStock() %> units</div>
                                </td>
                                <td><%= product.getSupplier() != null ? product.getSupplier() : "N/A" %></td>
                                <td>
                                    <%
                                        String statusText = product.getStatus() != null ? product.getStatus() : "N/A";
                                        String statusClass = "pending"; 
                                        if ("Active".equalsIgnoreCase(statusText)) {
                                            statusClass = "completed"; 
                                        } else if ("Inactive".equalsIgnoreCase(statusText)) { 
                                            statusClass = "pending"; 
                                        }
                                    %>
                                    <span class="status <%= statusClass %>"><%= statusText %></span>
                                </td>
                                <td>
                                    <div class="row-actions">
                                        <button class="action-button edit" onclick="window.location.href='<%= request.getContextPath() %>/Admin/update_product.jsp?id=<%= product.getId() %>&oldImagePath=<%= product.getImagePath() != null ? product.getImagePath() : "" %>' ">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                                                <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                                            </svg>
                                        </button>
                                        <button class="action-button delete" onclick="confirmDelete(<%= product.getId() %>)">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                <polyline points="3 6 5 6 21 6"></polyline>
                                                <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                                            </svg>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                            <%
                                    }
                                } else if (errorMessageJsp == null) { // Only show "No products found" if there was no DB error earlier
                            %>
                            <tr>
                                <td colspan="9" style="text-align: center; padding: 20px;">No products found.</td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>

                    <form id="deleteForm" action="<%= request.getContextPath() %>/deleteProduct" method="POST" style="display: none;">
                        <input type="hidden" name="productId" id="productIdToDelete">
                    </form>
                </div>
            </div>

            <div class="pagination">
                <div class="pagination-info">Showing <%= displayedItemsStart %> to <%= displayedItemsEnd %> of <%= totalProducts %> entries</div>
                <div class="pagination-controls">
                    <a href="<%= currentPage > 1 ? request.getContextPath() + "/Admin/products.jsp?page=" + (currentPage - 1) : "#" %>"
                       style="text-decoration: none; color: inherit;"
                       class="pagination-button <%= currentPage == 1 ? "disabled" : "" %>"
                       <%= currentPage == 1 ? "onclick='return false;'" : "" %>>
                        Previous
                    </a>
                    
                    <% 
                        int maxVisiblePages = 3; 
                        int startPage = Math.max(1, currentPage - 1); // Ensure startPage is at least 1
                        int endPage = Math.min(totalPages, currentPage + 1);

                        if (currentPage <=2) { // If current page is 1 or 2, start from 1
                           startPage = 1;
                           endPage = Math.min(totalPages, maxVisiblePages);
                        } else if (currentPage >= totalPages -1 && totalPages > maxVisiblePages) { // If current page is last or second last
                           startPage = Math.max(1, totalPages - maxVisiblePages + 1);
                           endPage = totalPages;
                        } else { // For pages in the middle
                            startPage = currentPage -1;
                            endPage = currentPage +1;
                        }


                        if (startPage > 1) { %>
                            <a href="<%= request.getContextPath() %>/Admin/products.jsp?page=1" style="text-decoration: none; color: inherit;" class="pagination-button <%= currentPage == 1 ? "active" : "" %>">1</a>
                            <% if (startPage > 2) { %><span class="pagination-ellipsis">...</span><% } %>
                    <%  }
                        for (int i = startPage; i <= endPage; i++) {
                    %>
                        <a href="<%= request.getContextPath() %>/Admin/products.jsp?page=<%= i %>"
                           style="text-decoration: none; color: inherit;"
                           class="pagination-button <%= currentPage == i ? "active" : "" %>"><%= i %></a>
                    <%  } 
                        if (endPage < totalPages) {
                            if (endPage < totalPages -1) { %><span class="pagination-ellipsis">...</span><% } %>
                            <a href="<%= request.getContextPath() %>/Admin/products.jsp?page=<%= totalPages %>" style="text-decoration: none; color: inherit;" class="pagination-button <%= currentPage == totalPages ? "active" : "" %>"><%= totalPages %></a>
                    <%  } %>
                    
                    <a href="<%= currentPage < totalPages ? request.getContextPath() + "/Admin/products.jsp?page=" + (currentPage + 1) : "#" %>" 
                       style="text-decoration: none; color: inherit;"
                       class="pagination-button <%= currentPage >= totalPages ? "disabled" : "" %>"
                       <%= currentPage >= totalPages ? "onclick='return false;'" : "" %>>
                        Next
                    </a>
                </div>
            </div>

            <div class="footer">
                Swift © 2025.
            </div>
        </div>
    </div>

    <script>
        const mobileNavToggle = document.getElementById('mobileNavToggle');
        const sidebar = document.getElementById('sidebar');

        if(mobileNavToggle && sidebar) {
            mobileNavToggle.addEventListener('click', () => {
                sidebar.classList.toggle('active');
            });
        }

        function confirmDelete(productId) {
            if (confirm("Are you sure you want to delete this product? This action cannot be undone.")) {
                document.getElementById('productIdToDelete').value = productId;
                document.getElementById('deleteForm').submit();
            }
        }

        document.getElementById('searchButton').addEventListener('click', function() {
            const searchQuery = document.getElementById('searchInput').value.trim();
            // This is a basic search implementation. For full filter integration,
            // you'd need to gather all filter values and construct the URL.
            // For now, search will reset other filters unless they are also included in the URL construction.
            if (searchQuery) {
                window.location.href = '${pageContext.request.contextPath}/Admin/products.jsp?search=' + encodeURIComponent(searchQuery) + '&page=1';
            } else {
                 window.location.href = '${pageContext.request.contextPath}/Admin/products.jsp?page=1'; // Go to page 1 if search is empty
            }
        });
        
        document.getElementById('searchInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                document.getElementById('searchButton').click();
            }
        });
        
        // Basic filter change handling (can be expanded)
        const filterSelects = ['categoryFilter', 'supplierFilter', 'stockFilter'];
        filterSelects.forEach(filterId => {
            const selectElement = document.getElementById(filterId);
            if (selectElement) {
                selectElement.addEventListener('change', function() {
                    // This is a simplified version. For a real implementation,
                    // you would collect ALL current filter values and the search query
                    // to build a complete query string for the server.
                    // For now, applying one filter might reset others unless explicitly handled.
                    let params = new URLSearchParams(window.location.search);
                    params.set(filterId, this.value);
                    params.set('page', '1'); // Reset to page 1 on filter change
                    // To clear a filter if "All X" is selected
                    if (!this.value) {
                        params.delete(filterId);
                    }
                    window.location.href = '${pageContext.request.contextPath}/Admin/products.jsp?' + params.toString();
                });
            }
        });

         // Preserve filter values on page load
        window.addEventListener('load', () => {
            const urlParams = new URLSearchParams(window.location.search);
            filterSelects.forEach(filterId => {
                const selectElement = document.getElementById(filterId);
                if (selectElement && urlParams.has(filterId)) {
                    selectElement.value = urlParams.get(filterId);
                }
            });
            const searchInput = document.getElementById('searchInput');
            if (searchInput && urlParams.has('search')) {
                searchInput.value = urlParams.get('search');
            }
        });

    </script>
</body>
</html>