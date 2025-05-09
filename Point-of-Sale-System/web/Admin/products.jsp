<%--
    Document   : products
    Created on : May 5, 2025, 8:04:51 PM
    Author     : dulan
--%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="model.Product" %>
<%@ page import="dao.ProductDAO" %>
<%@ page import="util.DBConnection" %>
<%@ page import="java.sql.Connection" %>
<%@ page import="java.text.DecimalFormat" %>

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
    String errorMessage = null;
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
            errorMessage = "Error: Database connection failed.";
        }
    } catch (Exception e) {
        // Catch any exceptions during the process (DB errors, etc.)
        e.printStackTrace(); // Log the error on the server console
        errorMessage = "Error retrieving products: " + e.getMessage();
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
    <script src="${pageContext.request.contextPath}/script.js"></script>
    <link rel="Stylesheet" href="styles.css">
    <style>
        /* Additional CSS for Products page */

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
             text-decoration: none; /* Style the link inside the button */
        }

        .primary-button:hover {
            background-color: var(--primary-dark);
        }
         .primary-button a {
             text-decoration: none; /* Style the link inside the button */
             color: inherit;
         }


        /* Products Table Styles */
        .products-table {
            width: 100%;
            border-collapse: collapse; /* Added for cleaner table borders */
             margin-top: 15px; /* Added some space below header */
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
            display: inline-block; /* Ensure it doesn't take full width */
        }

        .status.completed { /* Use for 'Active' */
            background-color: #d1fae5;
            color: #047857; /* Deeper green */
        }

        .status.pending { /* Use for 'Inactive' or other non-active states */
            background-color: #fef3c7;
            color: #d97706; /* Deeper yellow/orange */
        }

        .status.warning { /* Use for 'Low Stock' explicitly if needed, but stock level handles visually */
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

            /* Responsive Table - Horizontal Scroll */
            .module-content {
                overflow-x: auto; /* Enable horizontal scrolling */
            }

            .products-table {
                min-width: 700px; /* Ensure table has a minimum width to enable scrolling */
            }
        }

        @media (max-width: 480px) {
            .header-actions {
                margin-top: 10px;
                justify-content: flex-start; /* Align actions left on small screens */
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
         /* Error message styling */
         .error-message {
             color: red;
             padding: 10px;
             border: 1px solid red;
             background-color: #ffebeb;
             margin-bottom: 15px;
             border-radius: 4px;
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
            <%-- Assuming menu.jsp contains the sidebar menu structure --%>
            <jsp:include page="menu.jsp" />
        </div>

        <div class="main-content">
            <div class="header">
                <h1 class="page-title">Products Management</h1>
                <div class="user-profile">
                    <img src="${pageContext.request.contextPath}/Images/logo.png" alt="Admin Profile"> <%-- Use context path for images --%>
                    <div>
                        <h4>Admin User</h4>
                    </div>
                </div>
            </div>

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
                        <%-- Add dynamic supplier options here if available --%>
                    </select>

                    <select class="filter-select" id="supplierFilter">
                        <option value="">All Suppliers</option>
                        <option value="global-coffee">Global Coffee Co.</option>
                        <option value="dairy-farms">Dairy Farms Inc.</option>
                        <option value="sweet-supplies">Sweet Supplies Ltd.</option>
                        <option value="package-solutions">Package Solutions</option>
                        <option value="flavor-masters">Flavor Masters</option>
                        <%-- Add dynamic supplier options here if available --%>
                    </select>

                    <select class="filter-select" id="stockFilter">
                        <option value="">Stock Status</option>
                        <option value="in-stock">In Stock</option>
                        <option value="low-stock">Low Stock</option>
                        <option value="out-of-stock">Out of Stock</option>
                    </select>
                </div>

                <%-- Link the button to the add product page --%>
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
                    <%-- Display actual total product count --%>
                    <div class="value"><%= totalProducts %></div>
                    <div class="trend up">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="18 15 12 9 6 15"></polyline>
                        </svg>
                        <%-- Placeholder: Dynamically show new products added today/this week --%>
                        5 new products added
                    </div>
                </div>

                <div class="stat-card">
                    <h3>LOW STOCK ITEMS</h3>
                    <%-- Display actual low stock item count --%>
                    <div class="value"><%= lowStockCount %></div>
                    <div class="trend down">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="6 9 12 15 18 9"></polyline>
                        </svg>
                        <%-- Placeholder: Dynamically show change in low stock items --%>
                        3 more than yesterday
                    </div>
                </div>

                <div class="stat-card">
                    <h3>TOP SELLING</h3>
                    <%-- Placeholder: Dynamically display top selling product --%>
                    <div class="value">Cappuccino</div>
                    <div class="trend up">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <polyline points="18 15 12 9 6 15"></polyline>
                        </svg>
                        18.3% increase in sales
                    </div>
                </div>

                <div class="stat-card">
                    <h3>PRODUCT CATEGORIES</h3>
                    <%-- Display actual unique category count --%>
                    <div class="value"><%= uniqueCategoryCount %></div>
                    <div class="trend neutral">
                        <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <line x1="5" y1="12" x2="19" y2="12"></line>
                        </svg>
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
                        <button class="icon-button" onclick="window.location.reload();"> <%-- Add refresh functionality --%>
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
                     <%-- Display error message if connection or retrieval failed --%>
                     <% if (errorMessage != null) { %>
                         <p class="error-message"><%= errorMessage %></p>
                     <% } %>
                    <table class="products-table">
                        <thead>
                            <tr>
                                <th>
                                    <input type="checkbox" class="select-all-checkbox">
                                </th>
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
                                // Check if productList is not null AND not empty before looping
                                if (productList != null && !productList.isEmpty()) {
                                    for (Product product : productList) {
                            %>
                            <tr>
                                <td>
                                    <input type="checkbox" class="row-checkbox" value="<%= product.getId() %>"> <%-- Use product ID as value --%>
                                </td>
                                <td>
                                    <div class="product-info">
                                        <%
                                            // Construct image URL using context path and stored path
                                            String productImageUrl = request.getContextPath() + "/Images/default.jpg"; // Default image if needed
                                            if (product.getImagePath() != null && !product.getImagePath().isEmpty()) {
                                                // Assuming imagePath in DB is like "Images/your_image.jpg"
                                                // Construct the full URL accessible from the browser
                                                productImageUrl = request.getContextPath() + "/" + product.getImagePath();
                                            }
                                        %>
                                        <img src="<%= productImageUrl %>" alt="<%= product.getName() %> Image" class="product-thumbnail">
                                        <div class="product-details">
                                            <span class="product-name"><%= product.getName() %></span>
                                            <span class="product-id">#PROD-<%= product.getId() %></span> <%-- Use product ID --%>
                                        </div>
                                    </div>
                                </td>
                                <td><%= product.getSku() != null ? product.getSku() : "N/A" %></td> <%-- Display SKU --%>
                                <td><%= product.getCategory() != null ? product.getCategory() : "N/A" %></td> <%-- Display Category --%>
                                <td>Rs.<%= df.format(product.getPrice()) %></td> <%-- Display formatted Price --%>
                                <td>
                                    <%
                                        String stockClass = "low"; // Default to low
                                        if (product.getStock() >= 50) { // Example thresholds: >= 50 is high
                                            stockClass = "high";
                                        } else if (product.getStock() >= 10) { // >= 10 and < 50 is medium
                                            stockClass = "medium";
                                        } // < 10 remains low
                                    %>
                                    <div class="stock-level <%= stockClass %>"><%= product.getStock() %> units</div> <%-- Display Stock --%>
                                </td>
                                <td><%= product.getSupplier() != null ? product.getSupplier() : "N/A" %></td> <%-- Display Supplier --%>
                                <td>
                                    <%
                                        String statusText = product.getStatus() != null ? product.getStatus() : "N/A";
                                        String statusClass = "pending"; // Default style
                                        if ("Active".equalsIgnoreCase(statusText)) {
                                            statusClass = "completed"; // Green style for Active
                                        } else if ("Inactive".equalsIgnoreCase(statusText)) { // Example for Inactive
                                            statusClass = "pending"; // Yellow style for Inactive
                                        }
                                        // Note: Low stock is handled visually by the Stock column
                                    %>
                                    <span class="status <%= statusClass %>"><%= statusText %></span> <%-- Display Status --%>
                                </td>
                                <td>
                                    <div class="row-actions">
                                        <%-- Edit Button (Link to edit page with product ID) --%>
                                        <button class="action-button edit" onclick="window.location.href='<%= request.getContextPath() %>/Admin/update_product.jsp?id=<%= product.getId() %>&oldImagePath=<%= product.getImagePath() %>'">
                                            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                                                <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                                                <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                                            </svg>
                                        </button>
                                        <%-- Delete Button (Trigger delete action via form) --%>
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
                                } else if (errorMessage == null) { // Only show "No products found" if there was no DB error
                            %>
                            <tr>
                                <td colspan="9" style="text-align: center; padding: 20px;">No products found.</td>
                            </tr>
                            <%
                                }
                            %>
                        </tbody>
                    </table>

                    <%-- Basic Delete Form (Hidden) --%>
                    <%-- This form will be dynamically populated and submitted by the confirmDelete JS function --%>
                    <form id="deleteForm" action="<%= request.getContextPath() %>/deleteProduct" method="POST" style="display: none;">
                        <input type="hidden" name="productId" id="productIdToDelete">
                    </form>

                </div>
            </div>

            <%-- Enhanced Pagination with Dynamic Page Links --%>
            <div class="pagination">
                <%-- Displaying info based on actual paginated data --%>
                <div class="pagination-info">Showing <%= displayedItemsStart %> to <%= displayedItemsEnd %> of <%= totalProducts %> entries</div>
                <div class="pagination-controls">
                    <%-- Previous button - disabled on first page --%>
                    <a href="<%= currentPage > 1 ? request.getContextPath() + "/Admin/products.jsp?page=" + (currentPage - 1) : "#" %>"
                       style="text-decoration: none; color: inherit;"
                       class="pagination-button <%= currentPage == 1 ? "disabled" : "" %>"
                       <%= currentPage == 1 ? "onclick='return false;'" : "" %>>
                       Previous
                    </a>
                    
                    <%-- First page is always shown --%>
                    <a href="<%= request.getContextPath() %>/Admin/products.jsp?page=1"
                       style="text-decoration: none; color: inherit;"
                       class="pagination-button <%= currentPage == 1 ? "active" : "" %>">1</a>
                    
                    <%-- If there are many pages, add ellipsis and control which page numbers to show --%>
                    <% 
                        // Maximum number of page links to show (excluding first, last, ellipses)
                        int maxVisiblePages = 3; 
                        
                        // Determine the range of pages to display
                        int startPage = Math.max(2, currentPage - 1);
                        int endPage = Math.min(totalPages - 1, currentPage + 1);
                        
                        // Adjust to ensure we show up to maxVisiblePages
                        if (endPage - startPage + 1 < maxVisiblePages) {
                            // If we're showing fewer than maxVisiblePages, try to show more
                            if (startPage == 2) {
                                // We're near the beginning, so extend to the right
                                endPage = Math.min(totalPages - 1, startPage + maxVisiblePages - 1);
                            } else if (endPage == totalPages - 1) {
                                // We're near the end, so extend to the left
                                startPage = Math.max(2, endPage - maxVisiblePages + 1);
                            }
                        }
                        
                        // Show ellipsis before startPage if needed
                        if (startPage > 2) {
                    %>
                        <span class="pagination-ellipsis">...</span>
                    <% } 
                       
                       // Display the calculated range of page numbers
                       for (int i = startPage; i <= endPage; i++) {
                    %>
                        <a href="<%= request.getContextPath() %>/Admin/products.jsp?page=<%= i %>"
                           style="text-decoration: none; color: inherit;"
                           class="pagination-button <%= currentPage == i ? "active" : "" %>"><%= i %></a>
                    <% } 
                       
                       // Show ellipsis after endPage if needed
                       if (endPage < totalPages - 1 && totalPages > 2) {
                    %>
                        <span class="pagination-ellipsis">...</span>
                    <% } 
                       
                       // Always show last page if there's more than one page
                       if (totalPages > 1) {
                    %>
                        <a href="<%= request.getContextPath() %>/Admin/products.jsp?page=<%= totalPages %>"
                           style="text-decoration: none; color: inherit;"
                           class="pagination-button <%= currentPage == totalPages ? "active" : "" %>"><%= totalPages %></a>
                    <% } %>
                    
                    <%-- Next button - disabled on last page --%>
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
        // JavaScript for mobile sidebar toggle (from your initial HTML)
        const mobileNavToggle = document.getElementById('mobileNavToggle');
        const sidebar = document.getElementById('sidebar');

        if(mobileNavToggle && sidebar) {
            mobileNavToggle.addEventListener('click', () => {
                sidebar.classList.toggle('active');
            });
        }

        // JavaScript for delete confirmation
        function confirmDelete(productId) {
            if (confirm("Are you sure you want to delete this product? This action cannot be undone.")) {
                // Populate the hidden form and submit it
                document.getElementById('productIdToDelete').value = productId;
                document.getElementById('deleteForm').submit();
            }
        }

        // Add search functionality
        document.getElementById('searchButton').addEventListener('click', function() {
            const searchQuery = document.getElementById('searchInput').value.trim();
            if (searchQuery) {
                // You can enhance this to maintain other parameters like current filters
                window.location.href = '${pageContext.request.contextPath}/Admin/products.jsp?search=' + encodeURIComponent(searchQuery) + '&page=1';
            }
        });
        
        // Add event listener for Enter key in search input
        document.getElementById('searchInput').addEventListener('keypress', function(e) {
            if (e.key === 'Enter') {
                document.getElementById('searchButton').click();
            }
        });
        
        // Add filter change event handlers (basic implementation)
        const filters = ['categoryFilter', 'supplierFilter', 'stockFilter'];
        filters.forEach(filterId => {
            document.getElementById(filterId).addEventListener('change', function() {
                // This is a simplified version. For a real implementation,
                // you would collect all filter values and build a query string
                const filterValue = this.value;
                if (filterValue) {
                    // Again, you can enhance this to maintain other parameters
                    window.location.href = '${pageContext.request.contextPath}/Admin/products.jsp?filter=' + 
                                         encodeURIComponent(filterId) + 
                                         '&value=' + encodeURIComponent(filterValue) + 
                                         '&page=1';
                }
            });
        });
    </script>
</body>
</html>