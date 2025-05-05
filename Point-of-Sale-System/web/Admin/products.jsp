<%-- 
    Document   : products
    Created on : May 5, 2025, 8:04:51 PM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Products Management</title>
  <script src="script.js"></script>
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
    }

    .primary-button:hover {
      background-color: var(--primary-dark);
    }

    /* Products Table Styles */
    .products-table {
      width: 100%;
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

    .stock-level.high {
      background-color: #d1fae5;
      color: var(--success);
    }

    .stock-level.medium {
      background-color: #e0f2fe;
      color: var(--primary);
    }

    .stock-level.low {
      background-color: #fee2e2;
      color: var(--danger);
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
    .status.warning {
      background-color: #fef3c7;
      color: var(--warning);
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
    }

    @media (max-width: 480px) {
      .header-actions {
        margin-top: 10px;
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
        <h1 class="page-title">Products Management</h1>
        <div class="user-profile">
          <img src="../Images/logo.png" alt="Admin Profile">
          <div>
            <h4>Admin User</h4>
          </div>
        </div>
      </div>
      
      <!-- Action Bar -->
      <div class="action-bar">
        <div class="search-container">
          <input type="text" placeholder="Search products..." class="search-input">
          <button class="search-button">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <circle cx="11" cy="11" r="8"></circle>
              <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
            </svg>
          </button>
        </div>
        
        <div class="filter-container">
          <select class="filter-select">
            <option value="">All Categories</option>
            <option value="coffee">Coffee</option>
            <option value="tea">Tea</option>
            <option value="pastries">Pastries</option>
            <option value="sandwiches">Sandwiches</option>
            <option value="accessories">Accessories</option>
          </select>
          
          <select class="filter-select">
            <option value="">All Suppliers</option>
            <option value="global-coffee">Global Coffee Co.</option>
            <option value="dairy-farms">Dairy Farms Inc.</option>
            <option value="sweet-supplies">Sweet Supplies Ltd.</option>
            <option value="package-solutions">Package Solutions</option>
            <option value="flavor-masters">Flavor Masters</option>
          </select>
          
          <select class="filter-select">
            <option value="">Stock Status</option>
            <option value="in-stock">In Stock</option>
            <option value="low-stock">Low Stock</option>
            <option value="out-of-stock">Out of Stock</option>
          </select>
        </div>
        
        <button class="primary-button"><a href="add_product.jsp" style="text-decoration: none; color: inherit;">
          <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
            <line x1="12" y1="5" x2="12" y2="19"></line>
            <line x1="5" y1="12" x2="19" y2="12"></line>
          </svg>
          Add New Product
          </a>
        </button>
      </div>
      
      <!-- Product Stats -->
      <div class="stats-container">
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
        
        <div class="stat-card">
          <h3>TOP SELLING</h3>
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
          <div class="value">8</div>
          <div class="trend neutral">
            <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
              <line x1="5" y1="12" x2="19" y2="12"></line>
            </svg>
            No change
          </div>
        </div>
      </div>
      
      <!-- Products Table -->
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
            <button class="icon-button">
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
              <tr>
                <td>
                  <input type="checkbox" class="row-checkbox">
                </td>
                <td>
                  <div class="product-info">
                    <img src="${pageContext.request.contextPath}/Images/products/coffee.jpg" alt="Espresso" class="product-thumbnail">
                    <div class="product-details">
                      <span class="product-name">Espresso</span>
                      <span class="product-id">#PROD-001</span>
                    </div>
                  </div>
                </td>
                <td>ESP-001</td>
                <td>Coffee</td>
                <td>$3.50</td>
                <td>
                  <div class="stock-level high">78 units</div>
                </td>
                <td>Global Coffee Co.</td>
                <td><span class="status completed">Active</span></td>
                <td>
                  <div class="row-actions">
                    <button class="action-button edit">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                      </svg>
                    </button>
                    <button class="action-button delete">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="3 6 5 6 21 6"></polyline>
                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                      </svg>
                    </button>
                  </div>
                </td>
              </tr>
              <tr>
                <td>
                  <input type="checkbox" class="row-checkbox">
                </td>
                <td>
                  <div class="product-info">
                    <img src="${pageContext.request.contextPath}/Images/products/cappuccino.jpg" alt="Cappuccino" class="product-thumbnail">
                    <div class="product-details">
                      <span class="product-name">Cappuccino</span>
                      <span class="product-id">#PROD-002</span>
                    </div>
                  </div>
                </td>
                <td>CAP-001</td>
                <td>Coffee</td>
                <td>$4.25</td>
                <td>
                  <div class="stock-level high">65 units</div>
                </td>
                <td>Global Coffee Co.</td>
                <td><span class="status completed">Active</span></td>
                <td>
                  <div class="row-actions">
                    <button class="action-button edit">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                      </svg>
                    </button>
                    <button class="action-button delete">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="3 6 5 6 21 6"></polyline>
                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                      </svg>
                    </button>
                  </div>
                </td>
              </tr>
              <tr>
                <td>
                  <input type="checkbox" class="row-checkbox">
                </td>
                <td>
                  <div class="product-info">
                    <img src="${pageContext.request.contextPath}/Images/products/latte.jpg" alt="Latte" class="product-thumbnail">
                    <div class="product-details">
                      <span class="product-name">Latte</span>
                      <span class="product-id">#PROD-003</span>
                    </div>
                  </div>
                </td>
                <td>LAT-001</td>
                <td>Coffee</td>
                <td>$4.50</td>
                <td>
                  <div class="stock-level medium">32 units</div>
                </td>
                <td>Global Coffee Co.</td>
                <td><span class="status completed">Active</span></td>
                <td>
                  <div class="row-actions">
                    <button class="action-button edit">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                      </svg>
                    </button>
                    <button class="action-button delete">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="3 6 5 6 21 6"></polyline>
                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                      </svg>
                    </button>
                  </div>
                </td>
              </tr>
              <tr>
                <td>
                  <input type="checkbox" class="row-checkbox">
                </td>
                <td>
                  <div class="product-info">
                    <img src="${pageContext.request.contextPath}/Images/products/milk.jpg" alt="Organic Milk 1L" class="product-thumbnail">
                    <div class="product-details">
                      <span class="product-name">Organic Milk 1L</span>
                      <span class="product-id">#PROD-004</span>
                    </div>
                  </div>
                </td>
                <td>MILK-001</td>
                <td>Dairy</td>
                <td>$3.99</td>
                <td>
                  <div class="stock-level low">8 units</div>
                </td>
                <td>Dairy Farms Inc.</td>
                <td><span class="status warning">Low Stock</span></td>
                <td>
                  <div class="row-actions">
                    <button class="action-button edit">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                      </svg>
                    </button>
                    <button class="action-button delete">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="3 6 5 6 21 6"></polyline>
                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                      </svg>
                    </button>
                  </div>
                </td>
              </tr>
              <tr>
                <td>
                  <input type="checkbox" class="row-checkbox">
                </td>
                <td>
                  <div class="product-info">
                    <img src="${pageContext.request.contextPath}/Images/products/chocolate.jpg" alt="Chocolate Syrup" class="product-thumbnail">
                    <div class="product-details">
                      <span class="product-name">Chocolate Syrup</span>
                      <span class="product-id">#PROD-005</span>
                    </div>
                  </div>
                </td>
                <td>CHOC-001</td>
                <td>Syrups</td>
                <td>$6.75</td>
                <td>
                  <div class="stock-level low">3 units</div>
                </td>
                <td>Sweet Supplies Ltd.</td>
                <td><span class="status warning">Low Stock</span></td>
                <td>
                  <div class="row-actions">
                    <button class="action-button edit">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                      </svg>
                    </button>
                    <button class="action-button delete">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="3 6 5 6 21 6"></polyline>
                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                      </svg>
                    </button>
                  </div>
                </td>
              </tr>
              <tr>
                <td>
                  <input type="checkbox" class="row-checkbox">
                </td>
                <td>
                  <div class="product-info">
                    <img src="${pageContext.request.contextPath}/Images/products/vanilla.jpg" alt="Vanilla Flavoring" class="product-thumbnail">
                    <div class="product-details">
                      <span class="product-name">Vanilla Flavoring</span>
                      <span class="product-id">#PROD-006</span>
                    </div>
                  </div>
                </td>
                <td>VAN-001</td>
                <td>Syrups</td>
                <td>$7.50</td>
                <td>
                  <div class="stock-level low">2 units</div>
                </td>
                <td>Flavor Masters</td>
                <td><span class="status warning">Low Stock</span></td>
                <td>
                  <div class="row-actions">
                    <button class="action-button edit">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                      </svg>
                    </button>
                    <button class="action-button delete">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="3 6 5 6 21 6"></polyline>
                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                      </svg>
                    </button>
                  </div>
                </td>
              </tr>
              <tr>
                <td>
                  <input type="checkbox" class="row-checkbox">
                </td>
                <td>
                  <div class="product-info">
                    <img src="${pageContext.request.contextPath}/Images/products/cups.jpg" alt="Paper Cups 12oz" class="product-thumbnail">
                    <div class="product-details">
                      <span class="product-name">Paper Cups 12oz</span>
                      <span class="product-id">#PROD-007</span>
                    </div>
                  </div>
                </td>
                <td>CUP-001</td>
                <td>Supplies</td>
                <td>$24.99</td>
                <td>
                  <div class="stock-level low">15 units</div>
                </td>
                <td>Package Solutions</td>
                <td><span class="status warning">Low Stock</span></td>
                <td>
                  <div class="row-actions">
                    <button class="action-button edit">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M11 4H4a2 2 0 0 0-2 2v14a2 2 0 0 0 2 2h14a2 2 0 0 0 2-2v-7"></path>
                        <path d="M18.5 2.5a2.121 2.121 0 0 1 3 3L12 15l-4 1 1-4 9.5-9.5z"></path>
                      </svg>
                    </button>
                    <button class="action-button delete">
                      <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <polyline points="3 6 5 6 21 6"></polyline>
                        <path d="M19 6v14a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2V6m3 0V4a2 2 0 0 1 2-2h4a2 2 0 0 1 2 2v2"></path>
                      </svg>
                    </button>
                  </div>
                </td>
              </tr>
            </tbody>
          </table>
          
          <!-- Pagination -->
          <div class="pagination">
            <div class="pagination-info">Showing 1 to 7 of 285 entries</div>
            <div class="pagination-controls">
              <button class="pagination-button" disabled>Previous</button>
              <button class="pagination-button active">1</button>
              <button class="pagination-button">2</button>
              <button class="pagination-button">3</button>
              <button class="pagination-button">...</button>
              <button class="pagination-button">41</button>
              <button class="pagination-button">Next</button>
            </div>
          </div>
        </div>
      </div>
      
      <div class="footer">
        Swift © 2025.
      </div>
    </div>
  </div>
</body>
</html>
