<%-- 
    Document   : products_by_supplier
    Created on : May 11, 2025, 4:52:45 PM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Find Products by Supplier - Swift POS</title>
  <script src="script.js"></script>
  <link rel="Stylesheet" href="styles.css">
  <style>
    /* Specific styles for Find Products by Supplier page */
    .supplier-selection {
      margin-bottom: 25px;
    }
    
    .supplier-select {
      width: 100%;
      padding: 12px;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      background-color: #f8fafc;
      font-size: 16px;
    }
    
    .product-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
      gap: 20px;
      margin-top: 25px;
    }
    
    .product-card {
      background-color: #fff;
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
      transition: transform 0.2s, box-shadow 0.2s;
    }
    
    .product-card:hover {
      transform: translateY(-4px);
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }
    
    .product-image {
      height: 180px;
      width: 100%;
      background-color: #f1f5f9;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
    }
    
    .product-image img {
      max-width: 100%;
      max-height: 100%;
      object-fit: contain;
    }
    
    .product-details {
      padding: 15px;
    }
    
    .product-name {
      font-weight: 600;
      font-size: 16px;
      margin-bottom: 6px;
    }
    
    .product-category {
      color: var(--secondary);
      font-size: 13px;
      margin-bottom: 8px;
    }
    
    .product-meta {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: 10px;
    }
    
    .product-price {
      font-weight: 600;
      font-size: 18px;
      color: var(--primary);
    }
    
    .product-stock {
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 12px;
      font-weight: 500;
    }
    
    .in-stock {
      background-color: #d1fae5;
      color: var(--success);
    }
    
    .low-stock {
      background-color: #fef3c7;
      color: var(--warning);
    }
    
    .out-of-stock {
      background-color: #fee2e2;
      color: var(--danger);
    }
    
    .filter-bar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
      flex-wrap: wrap;
      gap: 10px;
    }
    
    .filter-group {
      display: flex;
      gap: 10px;
      align-items: center;
    }
    
    .filter-label {
      font-weight: 500;
      font-size: 14px;
      color: var(--secondary);
    }
    
    .filter-select {
      padding: 8px 12px;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      background-color: #f8fafc;
    }
    
    .search-box {
      display: flex;
      align-items: center;
      background-color: #f8fafc;
      border-radius: 6px;
      overflow: hidden;
      border: 1px solid #e2e8f0;
      width: 100%;
      max-width: 300px;
    }
    
    .search-input {
      padding: 10px 15px;
      border: none;
      background-color: transparent;
      flex: 1;
    }
    
    .search-button {
      background-color: var(--primary);
      border: none;
      color: white;
      padding: 10px 15px;
      cursor: pointer;
    }
    
    .no-products {
      text-align: center;
      padding: 40px 20px;
      background-color: #f8fafc;
      border-radius: 8px;
      color: var(--secondary);
    }
    
    .product-action-buttons {
      display: flex;
      gap: 8px;
      margin-top: 15px;
    }
    
    .product-action-btn {
      flex: 1;
      background-color: #f1f5f9;
      border: none;
      padding: 8px;
      border-radius: 4px;
      font-size: 13px;
      cursor: pointer;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 5px;
      transition: background-color 0.2s;
    }
    
    .product-action-btn:hover {
      background-color: #e2e8f0;
    }
    
    .product-action-btn.primary {
      background-color: var(--primary);
      color: white;
    }
    
    .product-action-btn.primary:hover {
      background-color: var(--primary-dark);
    }
    
    .supplier-info {
      display: flex;
      align-items: center;
      gap: 15px;
      margin-bottom: 20px;
      background-color: #f8fafc;
      padding: 15px;
      border-radius: 8px;
      border-left: 4px solid var(--primary);
    }
    
    .supplier-icon {
      width: 50px;
      height: 50px;
      border-radius: 50%;
      background-color: #e0f2fe;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 24px;
    }
    
    .supplier-details h3 {
      font-weight: 600;
      margin-bottom: 5px;
    }
    
    .supplier-details p {
      color: var(--secondary);
      font-size: 14px;
    }
    
    .supplier-contact {
      margin-left: auto;
      display: flex;
      flex-direction: column;
      gap: 5px;
    }
    
    .supplier-contact-item {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 14px;
    }
    
    .supplier-actions {
      display: flex;
      gap: 10px;
      margin-top: 10px;
    }
    
    .supplier-btn {
      background-color: transparent;
      border: 1px solid #e2e8f0;
      padding: 8px 12px;
      border-radius: 4px;
      font-size: 13px;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 5px;
    }
    
    .supplier-btn:hover {
      background-color: #f1f5f9;
    }
    
    .supplier-btn.primary {
      background-color: var(--primary);
      color: white;
      border-color: var(--primary);
    }
    
    .supplier-btn.primary:hover {
      background-color: var(--primary-dark);
    }
    
    /* Responsive styling */
    @media (max-width: 768px) {
      .product-grid {
        grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      }
      
      .filter-bar {
        flex-direction: column;
        align-items: flex-start;
      }
      
      .search-box {
        max-width: 100%;
      }
      
      .supplier-info {
        flex-direction: column;
        align-items: flex-start;
        gap: 10px;
      }
      
      .supplier-contact {
        margin-left: 0;
        margin-top: 10px;
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
        <h1 class="page-title">Find Products by Supplier</h1>
        <div class="user-profile">
          <img src="../Images/logo.png" alt="Admin Profile">
          <div>
            <h4>Admin User</h4>
          </div>
        </div>
      </div>
      
      <!-- Supplier Selection -->
      <div class="module-card">
        <div class="module-header">
          Select a Supplier
        </div>
        <div class="module-content">
          <div class="supplier-selection">
            <select id="supplierSelect" class="supplier-select" onchange="loadSupplierProducts()">
              <option value="">-- Select a Supplier --</option>
              <option value="SUP001">Global Coffee Co.</option>
              <option value="SUP002">Dairy Farms Inc.</option>
              <option value="SUP003">Sweet Supplies Ltd.</option>
              <option value="SUP004">Package Solutions</option>
              <option value="SUP005">Flavor Masters</option>
              <option value="SUP006">Ceylon Teas</option>
            </select>
          </div>
        </div>
      </div>
      
      <!-- Supplier Info (Appears when a supplier is selected) -->
      <div id="supplierInfo" class="supplier-info" style="display: none;">
        <div class="supplier-icon">
          🏭
        </div>
        <div class="supplier-details">
          <h3 id="supplierName">Global Coffee Co.</h3>
          <p id="supplierCategory">Category: Beverages</p>
        </div>
        <div class="supplier-contact">
          <div class="supplier-contact-item">
            <span>📞</span>
            <span id="supplierPhone">+94 75 123 4567</span>
          </div>
          <div class="supplier-contact-item">
            <span>✉️</span>
            <span id="supplierEmail">contact@globalcoffee.com</span>
          </div>
        </div>
        <div class="supplier-actions">
          <button class="supplier-btn" onclick="window.location.href='supplier_details.jsp'">
            <span>👁️</span> View Details
          </button>
          <button class="supplier-btn primary" onclick="window.location.href='purchases.jsp'">
            <span>🛒</span> Place Order
          </button>
        </div>
      </div>
      
      <!-- Products by Supplier (appears when a supplier is selected) -->
      <div id="productsContainer" class="module-card" style="display: none; margin-top: 20px;">
        <div class="module-header">
          Products by <span id="selectedSupplierName">Global Coffee Co.</span>
        </div>
        <div class="module-content">
          <!-- Filter and Search Bar -->
          <div class="filter-bar">
            <div class="filter-group">
              <span class="filter-label">Sort By:</span>
              <select class="filter-select" id="sortFilter">
                <option value="name">Name (A-Z)</option>
                <option value="name-desc">Name (Z-A)</option>
                <option value="price-asc">Price (Low to High)</option>
                <option value="price-desc">Price (High to Low)</option>
                <option value="stock">Stock (High to Low)</option>
              </select>
            </div>
            <div class="filter-group">
              <span class="filter-label">Category:</span>
              <select class="filter-select" id="categoryFilter">
                <option value="all">All Categories</option>
                <option value="coffee">Coffee</option>
                <option value="tea">Tea</option>
                <option value="dairy">Dairy</option>
                <option value="sweeteners">Sweeteners</option>
                <option value="packaging">Packaging</option>
              </select>
            </div>
            <div class="search-box">
              <input type="text" placeholder="Search products..." class="search-input" id="productSearch">
              <button class="search-button" onclick="searchProducts()">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <circle cx="11" cy="11" r="8"></circle>
                  <line x1="21" y1="21" x2="16.65" y2="16.65"></line>
                </svg>
              </button>
            </div>
          </div>
          
          <!-- Product Grid -->
          <div class="product-grid" id="productGrid">
            <!-- Product cards will be populated here -->
          </div>
          
          <!-- No Products Message (shown when no products match filter) -->
          <div class="no-products" id="noProducts" style="display: none;">
            <h3>No products found</h3>
            <p>Try adjusting your search or filter criteria</p>
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
    
    // Sample product data
    const products = {
      "SUP001": [
        { id: 1, name: "Premium Coffee Beans", category: "coffee", price: 1200, stock: 5, image: "coffee_beans.jpg" },
        { id: 2, name: "Arabica Coffee Grounds", category: "coffee", price: 950, stock: 12, image: "coffee_grounds.jpg" },
        { id: 3, name: "Espresso Coffee Beans", category: "coffee", price: 1350, stock: 8, image: "espresso_beans.jpg" },
        { id: 4, name: "Decaf Coffee Grounds", category: "coffee", price: 1100, stock: 15, image: "decaf_coffee.jpg" },
        { id: 5, name: "Flavored Coffee Grounds", category: "coffee", price: 1050, stock: 20, image: "flavored_coffee.jpg" }
      ],
      "SUP002": [
        { id: 6, name: "Organic Milk 1L", category: "dairy", price: 220, stock: 8, image: "organic_milk.jpg" },
        { id: 7, name: "Low Fat Milk 1L", category: "dairy", price: 200, stock: 15, image: "low_fat_milk.jpg" },
        { id: 8, name: "Heavy Cream 500ml", category: "dairy", price: 380, stock: 10, image: "heavy_cream.jpg" },
        { id: 9, name: "Almond Milk 1L", category: "dairy", price: 450, stock: 18, image: "almond_milk.jpg" }
      ],
      "SUP003": [
        { id: 10, name: "Chocolate Syrup", category: "sweeteners", price: 450, stock: 3, image: "chocolate_syrup.jpg" },
        { id: 11, name: "Vanilla Syrup", category: "sweeteners", price: 420, stock: 7, image: "vanilla_syrup.jpg" },
        { id: 12, name: "Caramel Syrup", category: "sweeteners", price: 420, stock: 9, image: "caramel_syrup.jpg" },
        { id: 13, name: "White Sugar 1kg", category: "sweeteners", price: 350, stock: 25, image: "white_sugar.jpg" },
        { id: 14, name: "Brown Sugar 1kg", category: "sweeteners", price: 380, stock: 20, image: "brown_sugar.jpg" }
      ],
      "SUP004": [
        { id: 15, name: "Paper Cups 12oz", category: "packaging", price: 1200, stock: 15, image: "paper_cups.jpg" },
        { id: 16, name: "Paper Cups 8oz", category: "packaging", price: 950, stock: 22, image: "small_cups.jpg" },
        { id: 17, name: "Cup Lids 12oz", category: "packaging", price: 750, stock: 30, image: "cup_lids.jpg" },
        { id: 18, name: "Cup Sleeves", category: "packaging", price: 500, stock: 40, image: "cup_sleeves.jpg" },
        { id: 19, name: "Paper Straws", category: "packaging", price: 300, stock: 50, image: "paper_straws.jpg" }
      ],
      "SUP005": [
        { id: 20, name: "Vanilla Flavoring", category: "sweeteners", price: 580, stock: 2, image: "vanilla_flavor.jpg" },
        { id: 21, name: "Hazelnut Flavoring", category: "sweeteners", price: 600, stock: 6, image: "hazelnut_flavor.jpg" },
        { id: 22, name: "Mocha Flavoring", category: "sweeteners", price: 620, stock: 4, image: "mocha_flavor.jpg" }
      ],
      "SUP006": [
        { id: 23, name: "Ceylon Black Tea", category: "tea", price: 850, stock: 18, image: "black_tea.jpg" },
        { id: 24, name: "Green Tea", category: "tea", price: 950, stock: 14, image: "green_tea.jpg" },
        { id: 25, name: "Earl Grey Tea", category: "tea", price: 900, stock: 12, image: "earl_grey.jpg" },
        { id: 26, name: "Chamomile Tea", category: "tea", price: 800, stock: 10, image: "chamomile_tea.jpg" }
      ]
    };
    
    // Supplier information
    const suppliers = {
      "SUP001": {
        name: "Global Coffee Co.",
        category: "Beverages",
        phone: "+94 75 123 4567",
        email: "contact@globalcoffee.com"
      },
      "SUP002": {
        name: "Dairy Farms Inc.",
        category: "Dairy",
        phone: "+94 77 234 5678",
        email: "info@dairyfarms.com"
      },
      "SUP003": {
        name: "Sweet Supplies Ltd.",
        category: "Ingredients",
        phone: "+94 76 345 6789",
        email: "sales@sweetsupplies.com"
      },
      "SUP004": {
        name: "Package Solutions",
        category: "Packaging",
        phone: "+94 71 456 7890",
        email: "support@packagesolutions.com"
      },
      "SUP005": {
        name: "Flavor Masters",
        category: "Ingredients",
        phone: "+94 78 567 8901",
        email: "info@flavormasters.com"
      },
      "SUP006": {
        name: "Ceylon Teas",
        category: "Beverages",
        phone: "+94 70 678 9012",
        email: "orders@ceylonteas.com"
      }
    };
    
    // Function to load supplier info and products
    function loadSupplierProducts() {
      const supplierId = document.getElementById('supplierSelect').value;
      
      if (!supplierId) {
        document.getElementById('supplierInfo').style.display = 'none';
        document.getElementById('productsContainer').style.display = 'none';
        return;
      }
      
      // Display supplier info
      const supplier = suppliers[supplierId];
      document.getElementById('supplierName').textContent = supplier.name;
      document.getElementById('supplierCategory').textContent = `Category: ${supplier.category}`;
      document.getElementById('supplierPhone').textContent = supplier.phone;
      document.getElementById('supplierEmail').textContent = supplier.email;
      document.getElementById('supplierInfo').style.display = 'flex';
      
      // Display products container
      document.getElementById('selectedSupplierName').textContent = supplier.name;
      document.getElementById('productsContainer').style.display = 'block';
      
      // Load products
      displayProducts(supplierId);
    }
    
    // Function to display products
    function displayProducts(supplierId, searchTerm = '', category = 'all', sortBy = 'name') {
      const productGrid = document.getElementById('productGrid');
      productGrid.innerHTML = '';
      
      let filteredProducts = [...products[supplierId]];
      
      // Apply category filter
      if (category !== 'all') {
        filteredProducts = filteredProducts.filter(product => product.category === category);
      }
      
      // Apply search filter
      if (searchTerm) {
        filteredProducts = filteredProducts.filter(product => 
          product.name.toLowerCase().includes(searchTerm.toLowerCase())
        );
      }
      
      // Apply sorting
      switch(sortBy) {
        case 'name':
          filteredProducts.sort((a, b) => a.name.localeCompare(b.name));
          break;
        case 'name-desc':
          filteredProducts.sort((a, b) => b.name.localeCompare(a.name));
          break;
        case 'price-asc':
          filteredProducts.sort((a, b) => a.price - b.price);
          break;
        case 'price-desc':
          filteredProducts.sort((a, b) => b.price - a.price);
          break;
        case 'stock':
          filteredProducts.sort((a, b) => b.stock - a.stock);
          break;
      }
      
      // Show no products message if no products found
      if (filteredProducts.length === 0) {
        document.getElementById('noProducts').style.display = 'block';
        return;
      } else {
        document.getElementById('noProducts').style.display = 'none';
      }
      
      // Display products
      filteredProducts.forEach(product => {
        let stockClass = 'in-stock';
        let stockText = 'In Stock';
        
        if (product.stock <= 5) {
          stockClass = 'low-stock';
          stockText = 'Low Stock';
        } else if (product.stock === 0) {
          stockClass = 'out-of-stock';
          stockText = 'Out of Stock';
        }
        
        const productCard = document.createElement('div');
        productCard.className = 'product-card';
        productCard.innerHTML = `
          <div class="product-image">
            <img src="${pageContext.request.contextPath}/Images/${product.image}" alt="${product.name}" onerror="this.src='${pageContext.request.contextPath}/Images/no_image.png'">
          </div>
          <div class="product-details">
            <h3 class="product-name">${product.name}</h3>
            <div class="product-category">${product.category.charAt(0).toUpperCase() + product.category.slice(1)}</div>
            <div class="product-meta">
              <span class="product-price">Rs.${product.price.toFixed(2)}</span>
              <span class="product-stock ${stockClass}">${stockText} (${product.stock})</span>
            </div>
            <div class="product-action-buttons">
              <button class="product-action-btn" onclick="viewProductDetails(${product.id})">
                <span>👁️</span> View
              </button>
              <button class="product-action-btn primary" onclick="orderProduct(${product.id})">
                <span>🛒</span> Order
              </button>
            </div>
          </div>
        `;
        
        productGrid.appendChild(productCard);
      });
    }
    
    // Search products function
    function searchProducts() {
      const supplierId = document.getElementById('supplierSelect').value;
      const searchTerm = document.getElementById('productSearch').value;
      const category = document.getElementById('categoryFilter').value;
      const sortBy = document.getElementById('sortFilter').value;
      
      displayProducts(supplierId, searchTerm, category, sortBy);
    }
    
    // Event listeners for filters
    document.getElementById('categoryFilter').addEventListener('change', searchProducts);
    document.getElementById('sortFilter').addEventListener('change', searchProducts);
    document.getElementById('productSearch').addEventListener('input', searchProducts);
    
    // Functions for product actions
    function viewProductDetails(productId) {
      // Redirect to product details page
      alert(`View product details for ID: ${productId}`);
      // In a real app: window.location.href = `product_details.jsp?id=${productId}`;
    }
    
    function orderProduct(productId) {
      // Redirect to order page
      alert(`Order product ID: ${productId}`);
      // In a real app: window.location.href = `create_order.jsp?product=${productId}`;
    }
  </script>
</body>
</html>