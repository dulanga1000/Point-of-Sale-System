<%-- 
    Document   : supplier_details
    Created on : May 11, 2025, 5:10:13 PM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Supplier Details - Swift POS</title>
  <script src="script.js"></script>
  <link rel="Stylesheet" href="styles.css">
  <style>
    /* Specific styles for Supplier Details page */
    .supplier-header {
      display: flex;
      align-items: flex-start;
      gap: 30px;
      margin-bottom: 30px;
    }
    
    .supplier-logo {
      width: 120px;
      height: 120px;
      border-radius: 12px;
      background-color: #e0f2fe;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 48px;
    }
    
    .supplier-logo img {
      max-width: 100%;
      max-height: 100%;
      object-fit: contain;
    }
    
    .supplier-info-main {
      flex: 1;
    }
    
    .supplier-name {
      font-size: 26px;
      font-weight: 600;
      margin-bottom: 5px;
    }
    
    .supplier-category {
      color: var(--secondary);
      margin-bottom: 15px;
      font-size: 16px;
    }
    
    .supplier-meta {
      display: flex;
      gap: 25px;
      margin-top: 15px;
    }
    
    .supplier-meta-item {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    .supplier-meta-item span {
      color: var(--secondary);
      font-size: 14px;
    }
    
    .supplier-meta-item strong {
      color: var(--dark);
      font-weight: 600;
    }
    
    .action-buttons {
      display: flex;
      gap: 10px;
      margin-top: 20px;
    }
    
    .btn {
      padding: 10px 16px;
      border-radius: 6px;
      font-size: 14px;
      font-weight: 500;
      cursor: pointer;
      display: flex;
      align-items: center;
      gap: 8px;
      border: none;
    }
    
    .btn-primary {
      background-color: var(--primary);
      color: white;
    }
    
    .btn-primary:hover {
      background-color: var(--primary-dark);
    }
    
    .btn-secondary {
      background-color: #f1f5f9;
      color: var(--dark);
    }
    
    .btn-secondary:hover {
      background-color: #e2e8f0;
    }
    
    .contact-section {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
      gap: 20px;
      margin-bottom: 30px;
    }
    
    .contact-card {
      background-color: white;
      border-radius: 8px;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
      padding: 20px;
    }
    
    .contact-card h3 {
      font-size: 16px;
      margin-bottom: 15px;
      display: flex;
      align-items: center;
      gap: 10px;
    }
    
    .contact-item {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 12px;
    }
    
    .contact-item:last-child {
      margin-bottom: 0;
    }
    
    .contact-item span {
      color: var(--secondary);
    }
    
    .contact-icon {
      width: 30px;
      height: 30px;
      background-color: #e0f2fe;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      color: var(--primary);
    }
    
    .stats-row {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 15px;
      margin-bottom: 30px;
    }
    
    .stats-card {
      background-color: white;
      border-radius: 8px;
      padding: 20px;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
      text-align: center;
    }
    
    .stats-value {
      font-size: 28px;
      font-weight: 700;
      margin-bottom: 5px;
      color: var(--primary);
    }
    
    .stats-label {
      color: var(--secondary);
      font-size: 14px;
    }
    
    .address-map {
      width: 100%;
      height: 200px;
      background-color: #f1f5f9;
      border-radius: 8px;
      margin-top: 15px;
      display: flex;
      align-items: center;
      justify-content: center;
    }
    
    .products-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
      gap: 20px;
      margin-top: 20px;
    }
    
    .product-card {
      background-color: white;
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
      height: 150px;
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
    
    .table-container {
      margin-top: 20px;
      overflow-x: auto;
    }
    
    .table-tabs {
      display: flex;
      margin-bottom: 20px;
      border-bottom: 1px solid #e2e8f0;
    }
    
    .table-tab {
      padding: 12px 20px;
      cursor: pointer;
      font-weight: 500;
      position: relative;
    }
    
    .table-tab.active {
      color: var(--primary);
    }
    
    .table-tab.active::after {
      content: '';
      position: absolute;
      bottom: -1px;
      left: 0;
      width: 100%;
      height: 2px;
      background-color: var(--primary);
    }
    
    /* Responsive styling */
    @media (max-width: 768px) {
      .supplier-header {
        flex-direction: column;
        align-items: center;
        text-align: center;
        gap: 15px;
      }
      
      .supplier-meta {
        flex-direction: column;
        gap: 10px;
        align-items: center;
      }
      
      .action-buttons {
        justify-content: center;
      }
      
      .stats-row {
        grid-template-columns: 1fr 1fr;
      }
      
      .contact-section {
        grid-template-columns: 1fr;
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
        <h1 class="page-title">Supplier Details</h1>
        <div class="user-profile">
          <img src="../Images/logo.png" alt="Admin Profile">
          <div>
            <h4>Admin User</h4>
          </div>
        </div>
      </div>
      
      <!-- Supplier Header -->
      <div class="supplier-header">
        <div class="supplier-logo">
          🏭
        </div>
        <div class="supplier-info-main">
          <h1 class="supplier-name" id="supplierName">Global Coffee Co.</h1>
          <div class="supplier-category" id="supplierCategory">Category: Beverages</div>
          
          <div class="supplier-meta">
            <div class="supplier-meta-item">
              <span>Registration No:</span>
              <strong id="registrationNo">SUP001-2024</strong>
            </div>
            <div class="supplier-meta-item">
              <span>Partnership Since:</span>
              <strong id="partnershipDate">January 12, 2024</strong>
            </div>
            <div class="supplier-meta-item">
              <span>Payment Terms:</span>
              <strong id="paymentTerms">30 days</strong>
            </div>
            <div class="supplier-meta-item">
              <span>Status:</span>
              <strong id="supplierStatus" style="color: var(--success);">Active</strong>
            </div>
          </div>
          
          <div class="action-buttons">
            <button class="btn btn-primary" onclick="window.location.href='purchases.jsp'">
              <span>🛒</span> Place Order
            </button>
            <button class="btn btn-secondary" onclick="window.location.href='edit_supplier.jsp'">
              <span>✏️</span> Edit Details
            </button>
            <button class="btn btn-secondary" id="toggleHistory">
              <span>📋</span> Order History
            </button>
          </div>
        </div>
      </div>
      
      <!-- Supplier Statistics -->
      <div class="stats-row">
        <div class="stats-card">
          <div class="stats-value" id="totalOrdersValue">43</div>
          <div class="stats-label">Total Orders</div>
        </div>
        <div class="stats-card">
          <div class="stats-value" id="totalProductsValue">5</div>
          <div class="stats-label">Products Supplied</div>
        </div>
        <div class="stats-card">
          <div class="stats-value" id="monthlyOrdersValue">12</div>
          <div class="stats-label">Orders This Month</div>
        </div>
        <div class="stats-card">
          <div class="stats-value" id="totalSpendValue">Rs.542,850</div>
          <div class="stats-label">Total Spend</div>
        </div>
      </div>
      
      <!-- Contact Information -->
      <h2 style="margin-bottom: 15px;">Contact Information</h2>
      <div class="contact-section">
        <div class="contact-card">
          <h3><span>👤</span> Primary Contact</h3>
          <div class="contact-item">
            <div class="contact-icon">👤</div>
            <div>
              <strong id="contactName">John Smith</strong>
              <div><span>Sales Manager</span></div>
            </div>
          </div>
          <div class="contact-item">
            <div class="contact-icon">📞</div>
            <div>
              <strong id="contactPhone">+94 75 123 4567</strong>
              <div><span>Mobile</span></div>
            </div>
          </div>
          <div class="contact-item">
            <div class="contact-icon">✉️</div>
            <div>
              <strong id="contactEmail">john@globalcoffee.com</strong>
              <div><span>Email</span></div>
            </div>
          </div>
        </div>
        
        <div class="contact-card">
          <h3><span>🏢</span> Company Information</h3>
          <div class="contact-item">
            <div class="contact-icon">📞</div>
            <div>
              <strong id="companyPhone">+94 11 234 5678</strong>
              <div><span>Office</span></div>
            </div>
          </div>
          <div class="contact-item">
            <div class="contact-icon">✉️</div>
            <div>
              <strong id="companyEmail">contact@globalcoffee.com</strong>
              <div><span>Email</span></div>
            </div>
          </div>
          <div class="contact-item">
            <div class="contact-icon">🌐</div>
            <div>
              <strong id="companyWebsite">www.globalcoffee.com</strong>
              <div><span>Website</span></div>
            </div>
          </div>
        </div>
        
        <div class="contact-card">
          <h3><span>📍</span> Address</h3>
          <div class="contact-item">
            <div class="contact-icon">📍</div>
            <div>
              <strong id="companyAddress">123 Coffee Lane, Colombo 05, Sri Lanka</strong>
              <div><span>Head Office</span></div>
            </div>
          </div>
          <div class="address-map">
            <span>Map Placeholder</span>
          </div>
        </div>
      </div>
      
      <!-- Products Supplied -->
      <div class="module-card">
        <div class="module-header">
          Products Supplied
        </div>
        <div class="module-content">
          <div class="products-grid" id="productsGrid">
            <!-- Product cards will be populated here -->
          </div>
        </div>
      </div>
      
      <!-- Order History (Hidden by default) -->
      <div class="module-card" id="orderHistoryCard" style="display: none; margin-top: 20px;">
        <div class="module-header">
          Order History
        </div>
        <div class="module-content">
          <div class="table-tabs">
            <div class="table-tab active" data-tab="recent">Recent Orders</div>
            <div class="table-tab" data-tab="pending">Pending Orders</div>
            <div class="table-tab" data-tab="all">All Orders</div>
          </div>
          <div class="table-container">
            <table>
              <thead>
                <tr>
                  <th>Order ID</th>
                  <th>Date</th>
                  <th>Products</th>
                  <th>Amount</th>
                  <th>Status</th>
                  <th>Actions</th>
                </tr>
              </thead>
              <tbody id="orderHistoryTable">
                <!-- Order history will be populated here -->
              </tbody>
            </table>
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
    
    // Toggle order history visibility
    document.getElementById('toggleHistory').addEventListener('click', function() {
      const orderHistoryCard = document.getElementById('orderHistoryCard');
      orderHistoryCard.style.display = orderHistoryCard.style.display === 'none' ? 'block' : 'none';
      
      // Update button text based on visibility
      this.innerHTML = orderHistoryCard.style.display === 'none' 
        ? '<span>📋</span> Order History' 
        : '<span>📋</span> Hide History';
    });
    
    // Sample data for the supplier
    const supplierData = {
      "SUP001": {
        name: "Global Coffee Co.",
        category: "Beverages",
        registrationNo: "SUP001-2024",
        partnershipDate: "January 12, 2024",
        paymentTerms: "30 days",
        status: "Active",
        statistics: {
          totalOrders: 43,
          totalProducts: 5,
          monthlyOrders: 12,
          totalSpend: "Rs.542,850"
        },
        contacts: {
          primary: {
            name: "John Smith",
            position: "Sales Manager",
            phone: "+94 75 123 4567",
            email: "john@globalcoffee.com"
          },
          company: {
            phone: "+94 11 234 5678",
            email: "contact@globalcoffee.com",
            website: "www.globalcoffee.com",
            address: "123 Coffee Lane, Colombo 05, Sri Lanka"
          }
        },
        products: [
          { id: 1, name: "Premium Coffee Beans", category: "coffee", price: 1200, stock: 5, image: "coffee_beans.jpg" },
          { id: 2, name: "Arabica Coffee Grounds", category: "coffee", price: 950, stock: 12, image: "coffee_grounds.jpg" },
          { id: 3, name: "Espresso Coffee Beans", category: "coffee", price: 1350, stock: 8, image: "espresso_beans.jpg" },
          { id: 4, name: "Decaf Coffee Grounds", category: "coffee", price: 1100, stock: 15, image: "decaf_coffee.jpg" },
          { id: 5, name: "Flavored Coffee Grounds", category: "coffee", price: 1050, stock: 20, image: "flavored_coffee.jpg" }
        ],
        orders: [
          { id: "PO-2025-001", date: "May 01, 2025", products: 3, amount: "Rs.15,600", status: "Delivered" },
          { id: "PO-2025-002", date: "April 25, 2025", products: 2, amount: "Rs.8,750", status: "Delivered" },
          { id: "PO-2025-003", date: "April 18, 2025", products: 4, amount: "Rs.22,400", status: "Delivered" },
          { id: "PO-2025-004", date: "April 10, 2025", products: 1, amount: "Rs.5,950", status: "Delivered" },
          { id: "PO-2025-005", date: "May 10, 2025", products: 3, amount: "Rs.14,850", status: "Pending" },
          { id: "PO-2025-006", date: "May 09, 2025", products: 2, amount: "Rs.10,200", status: "Processing" }
        ]
      }
    };
    
    // Function to load supplier details
    function loadSupplierDetails() {
      // For demonstration, we'll use SUP001 as the selected supplier
      const supplierId = "SUP001";
      const supplier = supplierData[supplierId];
      
      // Update supplier information
      document.getElementById('supplierName').textContent = supplier.name;
      document.getElementById('supplierCategory').textContent = `Category: ${supplier.category}`;
      document.getElementById('registrationNo').textContent = supplier.registrationNo;
      document.getElementById('partnershipDate').textContent = supplier.partnershipDate;
      document.getElementById('paymentTerms').textContent = supplier.paymentTerms;
      document.getElementById('supplierStatus').textContent = supplier.status;
      
      // Update statistics
      document.getElementById('totalOrdersValue').textContent = supplier.statistics.totalOrders;
      document.getElementById('totalProductsValue').textContent = supplier.statistics.totalProducts;
      document.getElementById('monthlyOrdersValue').textContent = supplier.statistics.monthlyOrders;
      document.getElementById('totalSpendValue').textContent = supplier.statistics.totalSpend;
      
      // Update contact information
      document.getElementById('contactName').textContent = supplier.contacts.primary.name;
      document.getElementById('contactPhone').textContent = supplier.contacts.primary.phone;
      document.getElementById('contactEmail').textContent = supplier.contacts.primary.email;
      document.getElementById('companyPhone').textContent = supplier.contacts.company.phone;
      document.getElementById('companyEmail').textContent = supplier.contacts.company.email;
      document.getElementById('companyWebsite').textContent = supplier.contacts.company.website;
      document.getElementById('companyAddress').textContent = supplier.contacts.company.address;
      
      // Load products
      loadProducts(supplier.products);
      
      // Load order history
      loadOrderHistory(supplier.orders);
    }
    
    // Function to load products
    function loadProducts(products) {
      const productsGrid = document.getElementById('productsGrid');
      productsGrid.innerHTML = '';
      
      products.forEach(product => {
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
          </div>
        `;
        
        productsGrid.appendChild(productCard);
      });
    }
    
    // Function to load order history
    function loadOrderHistory(orders) {
      const orderHistoryTable = document.getElementById('orderHistoryTable');
      orderHistoryTable.innerHTML = '';
      
      // For now, we'll show only recent orders
      const recentOrders = orders.filter(order => {
        // In a real app, you would filter by date
        return true;
      });
      
      recentOrders.forEach(order => {
        let statusClass = '';
        
        switch(order.status) {
          case 'Delivered':
            statusClass = 'completed';
            break;
          case 'Pending':
            statusClass = 'pending';
            break;
          case 'Processing':
            statusClass = 'pending';
            break;
          default:
            statusClass = '';
        }
        
        const row = document.createElement('tr');
        row.innerHTML = `
          <td>${order.id}</td>
          <td>${order.date}</td>
          <td>${order.products} items</td>
          <td>${order.amount}</td>
          <td><span class="status ${statusClass}">${order.status}</span></td>
          <td>
            <button class="btn btn-secondary" style="padding: 6px 10px; font-size: 12px;" onclick="viewOrderDetails('${order.id}')">
              <span>👁️</span> View
            </button>
          </td>
        `;
        
        orderHistoryTable.appendChild(row);
      });
    }
    
    // Function to view order details
    function viewOrderDetails(orderId) {
      alert(`View order details for ${orderId}`);
      // In a real app: window.location.href = `order_details.jsp?id=${orderId}`;
    }
    
    // Tab switching for order history
    document.querySelectorAll('.table-tab').forEach(tab => {
      tab.addEventListener('click', function() {
        // Remove active class from all tabs
        document.querySelectorAll('.table-tab').forEach(t => {
          t.classList.remove('active');
        });
        
        // Add active class to clicked tab
        this.classList.add('active');
        
        // In a real app, you would filter the order history based on the selected tab
        // For now, we'll just show the same data
        const tabType = this.getAttribute('data-tab');
        switch(tabType) {
          case 'recent':
            // Show recent orders
            break;
          case 'pending':
            // Show pending orders
            break;
          case 'all':
            // Show all orders
            break;
        }
      });
    });
    
    // Load supplier details when the page loads
    document.addEventListener('DOMContentLoaded', function() {
      loadSupplierDetails();
    });
  </script>
</body>
</html>