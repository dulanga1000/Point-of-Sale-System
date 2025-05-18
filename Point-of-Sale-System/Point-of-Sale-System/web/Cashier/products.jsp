<!DOCTYPE html>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.User" %> <%-- Adjust to your User class package --%>

<%
    // Attempt to retrieve the logged-in user's details from the session
    // Ensure your LoginServlet stores the User object with the name "loggedInUserProfile"
    // Note: Your LoginServlet.java (from uploaded files) uses "loggedInUser". Adjust if needed.
    User currentUser = (User) session.getAttribute("loggedInUserProfile");

    // Default values in case user is not found or details are missing
    String displayName = "John Doe";
    String displayRole = "User"; // Or "Cashier" if this section is specific to cashiers
    String userProfileImagePath = request.getContextPath() + "/Images/default_avatar.png"; // Default user avatar

    if (currentUser != null) {
        // Construct the full name
        String firstName = currentUser.getFirstName() != null ? currentUser.getFirstName() : "";
        String lastName = currentUser.getLastName() != null ? currentUser.getLastName() : "";
        if (!firstName.isEmpty() || !lastName.isEmpty()) {
            displayName = (firstName + " " + lastName).trim();
        }

        // Get the role
        if (currentUser.getRole() != null && !currentUser.getRole().isEmpty()) {
            displayRole = currentUser.getRole();
        }

        // Construct the web-accessible image path from the database path
        if (currentUser.getProfileImagePath() != null && !currentUser.getProfileImagePath().isEmpty()) {
            String dbProfilePath = currentUser.getProfileImagePath();
            // Convert backslashes to forward slashes and prepend context path
            userProfileImagePath = request.getContextPath() + "/" + dbProfilePath.replace("\\", "/");
        }
    }
%>

<%
// Database configuration - using your swift_database
String dbDriver = "com.mysql.cj.jdbc.Driver"; //
String dbURL = "jdbc:mysql://localhost:3306/swift_database"; //
String dbUsername = "root"; //
String dbPassword = ""; //

List<Map<String, String>> products = new ArrayList<>();

try {
    // Load JDBC driver
    Class.forName(dbDriver);
    
    // Create database connection
    try (Connection conn = DriverManager.getConnection(dbURL, dbUsername, dbPassword)) {
        // SQL query to fetch products - matching your table structure
        String query = "SELECT id, name, category, price, sku, stock, image_path, status FROM products WHERE status = 'Active'"; //
        
        try (Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(query)) {
            
            // Process results
            while (rs.next()) {
                Map<String, String> product = new HashMap<>();
                product.put("id", rs.getString("id"));
                product.put("name", rs.getString("name"));
                product.put("category", rs.getString("category"));
                product.put("price", String.format("Rs.%.2f", rs.getDouble("price")));
                product.put("stock", rs.getString("stock"));
                product.put("sku", rs.getString("sku"));
                product.put("image_path", rs.getString("image_path")); //
                
                // Determine stock status based on quantity
                int stock = rs.getInt("stock");
                String stockStatus;
                if (stock <= 0) {
                    stockStatus = "out-stock";
                } else if (stock < 10) {
                    stockStatus = "low-stock";
                } else {
                    stockStatus = "in-stock";
                }
                product.put("stock_status", stockStatus);
                
                // Determine icon class based on category
                String iconClass = "fas fa-box"; // default
                String category = rs.getString("category").toLowerCase();
                if (category.contains("food")) {
                    iconClass = "fas fa-utensils";
                } else if (category.contains("beverage")) {
                    iconClass = "fas fa-coffee";
                } else if (category.contains("electronic")) {
                    iconClass = "fas fa-mobile-alt";
                } else if (category.contains("cloth")) {
                    iconClass = "fas fa-tshirt";
                } else if (category.contains("stationery")) {
                    iconClass = "fas fa-pen";
                } else if (category.contains("home")) {
                    iconClass = "fas fa-home";
                }
                product.put("icon_class", iconClass);
                
                products.add(product);
            }
        }
    }
} catch (ClassNotFoundException e) {
    out.println("<div class='error'>JDBC Driver not found: " + e.getMessage() + "</div>");
    e.printStackTrace();
} catch (SQLException e) {
    out.println("<div class='error'>Database error: " + e.getMessage() + "</div>");
    e.printStackTrace();
} catch (Exception e) {
    out.println("<div class='error'>Unexpected error: " + e.getMessage() + "</div>");
    e.printStackTrace();
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Products - Cashier Dashboard</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
  <%-- <script src="product_cashi.js"> </script> --%> <%-- Ensure this JS file exists and is correctly linked if used --%>
  <style>
    :root {
      --primary: #3498db;
      --primary-dark: #2980b9;
      --secondary: #2ecc71;
      --secondary-dark: #27ae60;
      --success: #2ecc71;
      --danger: #e74c3c;
      --warning: #f39c12;
      --light: #f8f9fa;
      --dark: #343a40;
      --gray: #6c757d;
      --gray-light: #e9ecef;
      --border-radius: 8px;
      --shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
      --sidebar-width: 250px;
      --header-height: 70px;
      --footer-height: 50px;
    }
    
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }
    
    body {
      background-color: #f0f2f5;
      color: var(--dark);
      font-size: 14px;
      line-height: 1.5;
    }
    
    button {
      cursor: pointer;
      border: none;
      border-radius: var(--border-radius);
      transition: all 0.3s ease;
    }
    
    button:hover {
      opacity: 0.9;
    }
    
    input {
      padding: 10px 12px;
      border: 1px solid var(--gray-light);
      border-radius: var(--border-radius);
      font-size: 14px;
    }
    
    input:focus {
      outline: none;
      border-color: var(--primary);
      box-shadow: 0 0 0 2px rgba(52, 152, 219, 0.2);
    }
    
    /* Layout */
    .dashboard {
      display: flex;
      min-height: 100vh;
    }
    
    /* Sidebar */
    .sidebar {
      width: var(--sidebar-width);
      background-color: var(--dark);
      color: white;
      padding: 20px 0;
      position: fixed;
      height: 100vh;
      overflow-y: auto;
      transition: all 0.3s ease;
      z-index: 100;
    }
    
    .logo {
      display: flex;
      align-items: center;
      padding: 0 20px;
      margin-bottom: 30px;
    }
    
    .logo-img {
      width: 28px;
      height: 28px;
      margin-right: 10px;
      object-fit: contain;
      filter: invert(1) brightness(2);
    }
    
    .logo h2 {
      font-size: 20px;
      font-weight: 600;
      color: white;
    }
    
    .menu {
      list-style: none;
    }
    
    .menu-item {
      display: flex;
      align-items: center;
      padding: 12px 20px;
      cursor: pointer;
      transition: all 0.3s ease;
    }
    
    .menu-item:hover {
      background-color: rgba(255, 255, 255, 0.1);
    }
    
    .menu-item.active {
      background-color: var(--primary);
    }
    
    .menu-item i {
      margin-right: 15px;
      width: 20px;
      text-align: center;
    }
    
    .menu-item span {
      font-weight: 500;
    }
    
    /* Main Content */
    .main-content {
      flex: 1;
      margin-left: var(--sidebar-width);
      padding: 20px;
      display: flex;
      flex-direction: column;
      min-height: 100vh;
    }
    
    .header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
    }
    
    .page-title {
      font-size: 24px;
      font-weight: 600;
      color: var(--dark);
    }
    
    .user-profile {
      display: flex;
      align-items: center;
    }
    
    .user-image {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      overflow: hidden;
      margin-right: 15px;
    }
    
    .user-image img {
      width: 100%;
      height: 100%;
      object-fit: cover;
    }
    
    .user-info h4 {
      font-size: 16px;
      margin-bottom: 2px;
    }
    
    .user-info p {
      font-size: 12px;
      color: var(--gray);
    }
    
    /* Products View Module */
    .products-module {
      background: white;
      border-radius: var(--border-radius);
      box-shadow: var(--shadow);
      margin-bottom: 20px;
      overflow: hidden;
    }
    
    .module-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      padding: 15px 20px;
      background-color: var(--primary);
      color: white;
    }
    
    .module-header h2 {
      font-size: 18px;
      font-weight: 600;
    }
    
    .module-actions {
      display: flex;
      gap: 10px;
    }
    
    .search-container {
      display: flex;
      padding: 15px 20px;
      border-bottom: 1px solid var(--gray-light);
      background-color: var(--light);
    }
    
    .search-input {
      flex: 1;
      padding: 10px 15px;
      border: 1px solid var(--gray-light);
      border-radius: var(--border-radius);
      font-size: 14px;
    }
    
    .search-btn {
      padding: 0 20px;
      background-color: var(--primary);
      color: white;
      border-radius: var(--border-radius);
      margin-left: 10px;
    }
    
    .filter-container {
      padding: 10px 20px;
      border-bottom: 1px solid var(--gray-light);
      display: flex;
      flex-wrap: wrap;
      gap: 10px;
      background-color: #fafafa;
    }
    
    .filter-category {
      padding: 8px 15px;
      background-color: var(--gray-light);
      border-radius: 20px;
      font-size: 13px;
      cursor: pointer;
      transition: all 0.2s ease;
    }
    
    .filter-category.active {
      background-color: var(--primary);
      color: white;
    }
    
    .products-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
      gap: 20px;
      padding: 20px;
      max-height: calc(100vh - 260px); /* Adjust as needed */
      overflow-y: auto;
    }
    
    .product-card {
      border: 1px solid var(--gray-light);
      border-radius: var(--border-radius);
      overflow: hidden;
      transition: all 0.3s ease;
    }
    
    .product-card:hover {
      transform: translateY(-5px);
      box-shadow: var(--shadow);
    }
    
    .product-image {
      height: 140px;
      background-color: #f9f9f9;
      display: flex;
      align-items: center;
      justify-content: center;
      overflow: hidden;
    }
    
    .product-image i {
      font-size: 48px;
      color: var(--primary);
    }
    
    .product-image img {
      width: 100%;
      height: 100%;
      object-fit: contain; /* Changed to contain to see full image */
    }
    
    .product-details {
      padding: 15px;
    }
    
    .product-name {
      font-size: 16px;
      font-weight: 600;
      margin-bottom: 5px;
      color: var(--dark);
    }
    
    .product-category {
      color: var(--gray);
      font-size: 12px;
      margin-bottom: 10px;
    }
    
    .product-price {
      font-size: 18px;
      font-weight: 700;
      color: var(--primary-dark);
      margin-bottom: 10px;
    }
    
    .product-stock {
      display: flex;
      align-items: center;
      font-size: 13px;
      font-weight: 500;
    }
    
    .stock-status {
      display: flex;
      align-items: center;
      font-weight: 600;
    }
    
    .stock-status i {
      margin-right: 5px;
    }
    
    .stock-status.in-stock {
      color: var(--success);
    }
    
    .stock-status.low-stock {
      color: var(--warning);
    }
    
    .stock-status.out-stock {
      color: var(--danger);
    }
    
    .product-code {
      margin-top: 10px;
      font-size: 12px;
      color: var(--gray);
    }
    
    .pagination {
      display: flex;
      justify-content: center;
      padding: 20px;
      border-top: 1px solid var(--gray-light);
    }
    
    .pagination-item {
      width: 35px;
      height: 35px;
      display: flex;
      align-items: center;
      justify-content: center;
      margin: 0 5px;
      border-radius: 5px;
      cursor: pointer;
      transition: all 0.2s ease;
    }
    
    .pagination-item:hover {
      background-color: var(--gray-light);
    }
    
    .pagination-item.active {
      background-color: var(--primary);
      color: white;
    }
    
    .footer {
      margin-top: auto; /* Pushes footer to bottom if content is short */
      text-align: center;
      padding: 15px 0;
      border-top: 1px solid var(--gray-light);
      color: var(--gray);
    }
    
    /* Mobile Responsive */
    .mobile-top-bar {
      display: none; /* Hidden by default */
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      background-color: var(--dark);
      padding: 15px;
      z-index: 99; /* Ensure it's above other content but below sidebar if active */
      justify-content: space-between;
      align-items: center;
    }
    
    .mobile-logo {
      display: flex;
      align-items: center;
      color: white;
    }
    
    .mobile-logo img {
      width: 20px;
      height: 20px;
      margin-right: 10px;
    }
    
    .mobile-nav-toggle {
      background: transparent;
      color: white;
      font-size: 18px;
    }
    
    @media screen and (max-width: 992px) {
      .products-grid {
        grid-template-columns: repeat(auto-fill, minmax(160px, 1fr));
      }
    }
    
    @media screen and (max-width: 768px) {
      .mobile-top-bar {
        display: flex;
      }
      
      .main-content {
        margin-left: 0;
        padding-top: 70px; /* Adjust if mobile top bar height changes */
      }
      
      .sidebar {
        transform: translateX(-100%);
        box-shadow: 5px 0 15px rgba(0,0,0,0.1); /* Shadow when sidebar is open on mobile */
      }
      
      .sidebar.active {
        transform: translateX(0);
      }
      
      .header {
        flex-direction: column;
        align-items: flex-start;
      }
      
      .user-profile {
        margin-top: 10px;
      }
      
      .products-grid {
        grid-template-columns: repeat(auto-fill, minmax(130px, 1fr));
      }
    }
  </style>
</head>
<body>
  <div class="mobile-top-bar">
    <div class="mobile-logo">
      <img src="<%= request.getContextPath() %>/Images/logo.png" alt="POS Logo" class="logo-img">
      <h2>Swift</h2>
    </div>
    <button class="mobile-nav-toggle" id="mobileNavToggle">
      <i class="fas fa-bars"></i>
    </button>
  </div>

  <div class="dashboard">
    <div class="sidebar" id="sidebar">
      <div class="logo">
        <img src="<%= request.getContextPath() %>/Images/logo.png" alt="POS Logo" class="logo-img">
        <h2>Swift</h2>
      </div>

      <ul class="menu">
              <li class="menu-item active">
                  <i class="fas fa-shopping-cart"></i>
                  <span>Sales</span>
              </li>
              <li class="menu-item">
                  <i class="fas fa-box"></i>
                  <span>Products</span>
              </li>
              <li class="menu-item">
                  <i class="fas fa-chart-bar"></i>
                  <span>Reports</span>
              </li>
              <li class="menu-item">
                  <i class="fas fa-warehouse"></i>
                  <span>Inventory</span>
              </li>
              <li class="menu-item">
                  <i class="fas fa-receipt"></i>
                  <span>Transactions</span>
              </li>
              <li class="menu-item">
                  <i class="fas fa-cog"></i>
                  <span>Settings</span>
              </li>
              <li class="menu-item">
                  <a href="${pageContext.request.contextPath}/logoutAction" style="text-decoration: none; color: inherit; display: flex; align-items: center;">
                      <i class="fas fa-sign-out-alt"></i>
                      <span>Logout</span>
                  </a>
              </li>
          </ul>
      </div>

    <div class="main-content">
      <div class="header">
        <h1 class="page-title">Products</h1>
        <div class="user-profile">
          <div class="user-image">
            <img src="<%= userProfileImagePath %>" alt="<%= displayName %> avatar" style="width:40px; height:40px; border-radius:50%; object-fit: cover;">
          </div>
          <div class="user-info">
            <h4><%= displayName %></h4>
            <p><%= displayRole %></p>
          </div>
        </div>
      </div>

      <div class="products-module">
        <div class="module-header">
          <h2>Product Catalog</h2>
          <div class="module-actions">
            <%-- Optional: Add action buttons here if needed for this view --%>
          </div>
        </div>

        <div class="search-container">
          <input type="text" class="search-input" placeholder="Search products by name, code or category...">
          <button class="search-btn">
            <i class="fas fa-search"></i> Search
          </button>
        </div>

        <div class="filter-container">
          <div class="filter-category active">All Products</div>
          <div class="filter-category">Food</div>
          <div class="filter-category">Beverages</div>
          <div class="filter-category">Electronics</div>
          <div class="filter-category">Clothing</div>
          <div class="filter-category">Stationery</div>
          <div class="filter-category">Home Goods</div>
        </div>

        <div class="products-grid">
          <% for (Map<String, String> product : products) { 
              String prodImgPath = product.get("image_path");
              String fullProdImgPath = "";
              if (prodImgPath != null && !prodImgPath.isEmpty()) {
                  fullProdImgPath = request.getContextPath() + "/" + prodImgPath.replace("\\", "/");
              }
          %>
            <div class="product-card">
              <div class="product-image">
                <% if (fullProdImgPath != null && !fullProdImgPath.isEmpty() && !fullProdImgPath.endsWith("/null")) { %>
                  <img src="<%= fullProdImgPath %>" alt="<%= product.get("name") %>">
                <% } else { %>
                  <i class="<%= product.get("icon_class") %>"></i>
                <% } %>
              </div>
              <div class="product-details">
                <h3 class="product-name"><%= product.get("name") %></h3>
                <div class="product-category"><%= product.get("category") %></div>
                <div class="product-price"><%= product.get("price") %></div>
                <div class="product-stock">
                  <div class="stock-status <%= product.get("stock_status") %>">
                    <i class="fas 
                      <%= product.get("stock_status").equals("in-stock") ? "fa-check-circle" : 
                         product.get("stock_status").equals("low-stock") ? "fa-exclamation-circle" : 
                         "fa-times-circle" %>">
                    </i>
                    <%= product.get("stock_status").equals("in-stock") ? "In Stock" : 
                       product.get("stock_status").equals("low-stock") ? "Low Stock" : 
                       "Out of Stock" %> 
                    (<%= product.get("stock") %>)
                  </div>
                </div>
                <div class="product-code">SKU: <%= product.get("sku") %></div>
              </div>
            </div>
          <% } %>
          
          <% if (products.isEmpty()) { %>
            <div style="grid-column: 1/-1; text-align: center; padding: 40px;">
              <i class="fas fa-box-open" style="font-size: 48px; color: var(--gray); margin-bottom: 15px;"></i>
              <h3 style="color: var(--dark);">No products found</h3>
              <p style="color: var(--gray);">There are currently no active products in the database that match your criteria.</p>
            </div>
          <% } %>
        </div>

        <div class="pagination">
          <div class="pagination-item active">1</div>
          <div class="pagination-item">2</div>
          <div class="pagination-item">3</div>
          <div class="pagination-item">4</div>
          <div class="pagination-item">
            <i class="fas fa-angle-right"></i>
          </div>
        </div>
      </div>

      <div class="footer">
        Swift POS © 2025. All rights reserved.
      </div>
    </div>
  </div>

  <script>
    // Mobile menu toggle
    document.getElementById('mobileNavToggle').addEventListener('click', function() {
      document.getElementById('sidebar').classList.toggle('active');
    });
    
    // Basic filter and search stubs (implement full logic if needed)
    document.querySelectorAll('.filter-category').forEach(item => {
      item.addEventListener('click', function() {
        document.querySelectorAll('.filter-category').forEach(el => el.classList.remove('active'));
        this.classList.add('active');
        console.log('Filter selected:', this.textContent);
        // Add actual filtering logic here
      });
    });
    
    document.querySelector('.search-btn').addEventListener('click', function() {
      const searchTerm = document.querySelector('.search-input').value.trim();
      if (searchTerm) console.log('Searching for:', searchTerm);
      // Add actual search logic here
    });
  </script>
</body>
</html>