<%--
    Document   : products_by_supplier
    Created on : May 17, 2025, 10:15:30 AM
    Author     : admin
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.util.*" %>
<%@ page import="model.SupplierModel" %>  <%-- ENSURE 'model' is your correct package --%>
<%@ page import="model.ProductModel" %>   <%-- ENSURE 'model' is your correct package --%>
<%@ page import="java.text.DecimalFormat" %>
<%@ page import="java.math.BigDecimal" %>

<%
    List<SupplierModel> suppliers = (List<SupplierModel>) request.getAttribute("suppliersList");
    if (suppliers == null) suppliers = new ArrayList<>();

    List<ProductModel> products = (List<ProductModel>) request.getAttribute("filteredProductsList");
    if (products == null) products = new ArrayList<>();

    String selectedSupplierIdParam = (String) request.getAttribute("selectedSupplierId");
    if (selectedSupplierIdParam == null) selectedSupplierIdParam = "";

    String selectedSupplierName = (String) request.getAttribute("selectedSupplierName");
    if (selectedSupplierName == null) selectedSupplierName = "";
    
    int productsCount = request.getAttribute("productsCount") != null ? (Integer)request.getAttribute("productsCount") : 0;

    String selectedCategory = (String) request.getAttribute("selectedCategory");
    if (selectedCategory == null) selectedCategory = "";

    String enteredMinStock = (String) request.getAttribute("enteredMinStock");
    if (enteredMinStock == null) enteredMinStock = "";
    
    String enteredMinPrice = (String) request.getAttribute("enteredMinPrice");
    if (enteredMinPrice == null) enteredMinPrice = "";

    String enteredMaxPrice = (String) request.getAttribute("enteredMaxPrice");
    if (enteredMaxPrice == null) enteredMaxPrice = "";
    
    boolean formWasSubmittedOrFiltersApplied = Boolean.TRUE.equals(request.getAttribute("formWasSubmitted"));

    DecimalFormat df = new DecimalFormat("Rs#,##0.00");
    
    List<String> filterCategories = Arrays.asList("Coffee", "Dairy", "Food", "Sweeteners", "Packaging", "Bakery", "Equipment");
%>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Products by Supplier - Swift POS</title>
  <link rel="Stylesheet" href="${pageContext.request.contextPath}/Admin/styles.css">
  <style>
    /* Your existing specific styles for this page */
    .supplier-filter-container { display: flex; flex-direction: column; gap: 20px; margin-bottom: 20px; }
    .supplier-selector { display: flex; align-items: center; gap: 15px; flex-wrap: wrap; }
    .supplier-dropdown { min-width: 250px; padding: 10px 15px; border: 1px solid #e2e8f0; border-radius: 6px; background-color: white; }
    .filter-row { display: flex; flex-wrap: wrap; gap: 15px; align-items: center; }
    .filter-item { display: flex; align-items: center; gap: 8px; background-color: #f8fafc; padding: 8px 12px; border-radius: 6px; border: 1px solid #e2e8f0; }
    .filter-label { font-size: 14px; color: var(--secondary); }
    .filter-input { padding: 6px 10px; border: 1px solid #e2e8f0; border-radius: 4px; width: 120px; }
    .reset-filters, .apply-filters-main, .apply-filters-secondary { background-color: #f1f5f9; border: 1px solid #e2e8f0; color: var(--secondary); padding: 8px 16px; border-radius: 6px; cursor: pointer; font-size: 14px; display: flex; align-items: center; gap: 5px; }
    .apply-filters-main, .apply-filters-secondary { background-color: var(--primary); border: none; color: white; }
    .product-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(280px, 1fr)); gap: 20px; }
    .product-card { background-color: white; border-radius: 8px; overflow: hidden; box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05); transition: transform 0.2s, box-shadow 0.2s; }
    .product-card:hover { transform: translateY(-3px); box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1); }
    .product-image { width: 100%; height: 180px; background-color: #f8fafc; display: flex; align-items: center; justify-content: center; overflow: hidden; }
    .product-image img { max-width: 100%; max-height: 100%; object-fit: contain; }
    .product-details { padding: 15px; }
    .product-name { font-weight: 600; margin-bottom: 5px; font-size: 16px; min-height: 40px; }
    .product-sku { color: var(--secondary); font-size: 12px; margin-bottom: 10px; }
    .product-price { font-weight: 600; font-size: 18px; margin-bottom: 10px; }
    .product-supplier { display: flex; align-items: center; gap: 5px; font-size: 13px; color: var(--secondary); margin-bottom: 8px; }
    .product-stock { display: flex; align-items: center; gap: 5px; font-size: 13px; }
    .stock-indicator { width: 8px; height: 8px; border-radius: 50%; }
    .in-stock { background-color: var(--success); }
    .low-stock { background-color: var(--warning); }
    .out-of-stock { background-color: var(--danger); }
    .product-actions { display: flex; gap: 8px; margin-top: 12px; }
    .view-product-btn, .order-product-btn { flex: 1; padding: 8px 0; text-align: center; border-radius: 4px; cursor: pointer; font-size: 13px; text-decoration: none; }
    .view-product-btn { background-color: var(--primary); color: white; border: none; }
    .order-product-btn { background-color: #f8fafc; border: 1px solid #e2e8f0; color: var(--dark); }
    .no-products { text-align: center; padding: 40px; background-color: #f8fafc; border-radius: 8px; color: var(--secondary); grid-column: 1 / -1; }
    .no-products-icon { font-size: 48px; margin-bottom: 15px; }
    .product-category-tag { display: inline-block; padding: 3px 8px; background-color: #f1f5f9; color: var(--secondary); border-radius: 20px; font-size: 12px; margin-bottom: 10px; }
    .results-summary { margin-bottom: 20px; color: var(--secondary); font-size: 14px; }
    .results-count { font-weight: 600; color: var(--dark); }
    .supplier-badge { display: inline-block; padding: 2px 8px; background-color: #e0f2fe; color: var(--primary); border-radius: 20px; font-size: 12px; margin-right: 5px; }
    @media (max-width: 768px) { .supplier-selector { flex-direction: column; align-items: stretch; } .supplier-dropdown { width: 100%; } .filter-row { flex-direction: column; align-items: stretch; } .filter-item { width: auto; } .filter-input { width: 100%; box-sizing: border-box; } .filter-item span + .filter-input { width: calc(50% - 10px) !important; } .filter-actions { display: flex; gap: 10px; width: 100%; } .reset-filters, .apply-filters-secondary { flex: 1; justify-content: center; } .product-grid { grid-template-columns: repeat(auto-fill, minmax(220px, 1fr)); } }
    @media (max-width: 480px) { .product-grid { grid-template-columns: 1fr; } }
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
        <h1 class="page-title">Find Products by Supplier</h1>
        <div class="user-profile">
          <img src="${pageContext.request.contextPath}/Images/logo.png" alt="Admin Profile">
          <div><h4>Admin User</h4></div>
        </div>
      </div>
      
      <div class="stats-container">
        <div class="stat-card"><h3>TOTAL PRODUCTS</h3><div class="value">187</div><div class="trend up"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"><polyline points="18 15 12 9 6 15"></polyline></svg> 12 new</div></div>
        <div class="stat-card"><h3>ACTIVE SUPPLIERS</h3><div class="value"><%= suppliers.size() %></div><div class="trend up"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"><polyline points="18 15 12 9 6 15"></polyline></svg> <%= suppliers.size() > 0 ? "Active" : "None" %></div></div>
        <div class="stat-card"><h3>PRODUCT CATEGORIES</h3><div class="value"><%= filterCategories.size() %></div><div class="trend flat"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"><line x1="5" y1="12" x2="19" y2="12"></line></svg> Listed</div></div>
        <div class="stat-card"><h3>LOW STOCK ITEMS</h3><div class="value">?</div><div class="trend down"><svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"></polyline></svg> Check</div></div>
      </div>
      
      <div class="module-card">
        <div class="module-header">Select Supplier & Filter Products</div>
        <div class="module-content">
          <%-- ****************************************************** --%>
          <%-- *** THIS IS THE LINE YOU NEED TO CHANGE IN THE JSP *** --%>
          <%-- ****************************************************** --%>
          <form method="POST" action="${pageContext.request.contextPath}/Admin/productsBySupplierController" id="filterForm">
            <div class="supplier-filter-container">
              <div class="supplier-selector">
                <select class="supplier-dropdown" id="supplierSelect" name="supplierSelect">
                  <option value="">-- All Suppliers --</option>
                  <% for (SupplierModel sup : suppliers) { %>
                    <option value="<%= sup.getSupplierId() %>" 
                            <%= String.valueOf(sup.getSupplierId()).equals(selectedSupplierIdParam) ? "selected" : "" %>>
                      <%= sup.getCompanyName() %>
                    </option>
                  <% } %>
                </select>
                <button type="submit" class="apply-filters-main">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"><circle cx="11" cy="11" r="8"></circle><line x1="21" y1="21" x2="16.65" y2="16.65"></line></svg>
                  Filter Products
                </button>
              </div>
              
              <div class="filter-row">
                <div class="filter-item">
                  <span class="filter-label">Category:</span>
                  <select class="filter-input" name="categoryFilter">
                    <option value="" <%= "".equals(selectedCategory) ? "selected" : "" %>>All Categories</option>
                    <% for (String cat : filterCategories) { %>
                         <option value="<%= cat %>" <%= cat.equals(selectedCategory) ? "selected" : "" %>><%= cat %></option>
                    <% } %>
                  </select>
                </div>
                <div class="filter-item">
                  <span class="filter-label">Min Stock:</span>
                  <input type="number" class="filter-input" name="minStock" placeholder="Min quantity" value="<%= enteredMinStock %>">
                </div>
                <div class="filter-item">
                  <span class="filter-label">Price Range:</span>
                  <input type="number" class="filter-input" name="minPrice" placeholder="Min" style="width: 70px;" value="<%= enteredMinPrice %>" step="0.01">
                  <span>-</span>
                  <input type="number" class="filter-input" name="maxPrice" placeholder="Max" style="width: 70px;" value="<%= enteredMaxPrice %>" step="0.01">
                </div>
                <div class="filter-actions">
                  <button type="button" class="reset-filters" id="resetFiltersBtn">
                    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"><path d="M3 12a9 9 0 1 0 18 0 9 9 0 0 0-18 0z"></path><path d="M9 15l6-6"></path><path d="M15 15l-6-6"></path></svg>
                    Reset
                  </button>
                  <button type="submit" class="apply-filters-secondary">
                     <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24"><line x1="4" y1="21" x2="4" y2="14"></line><line x1="4" y1="10" x2="4" y2="3"></line><line x1="12" y1="21" x2="12" y2="12"></line><line x1="12" y1="8" x2="12" y2="3"></line><line x1="20" y1="21" x2="20" y2="16"></line><line x1="20" y1="12" x2="20" y2="3"></line><line x1="1" y1="14" x2="7" y2="14"></line><line x1="9" y1="8" x2="15" y2="8"></line><line x1="17" y1="16" x2="23" y2="16"></line></svg>
                    Apply Filters
                  </button>
                </div>
              </div>
            </div>
          </form>
          
          <div class="results-summary" id="resultsSummary">
            <% if (formWasSubmittedOrFiltersApplied) { %>
                <% if (!selectedSupplierName.isEmpty()) { %>
                    Showing <span class="results-count"><%= productsCount %></span> products from <span class="supplier-badge"><%= selectedSupplierName %></span>.
                <% } else { %>
                     Showing <span class="results-count"><%= productsCount %></span> products matching criteria.
                <% } %>
            <% } else if (!products.isEmpty()) { %>
                Showing <span class="results-count"><%= productsCount %></span> total products. Apply filters to refine.
            <% } else { %>
                No products available at the moment.
            <% } %>
          </div>
          
          <div class="product-grid" id="productGrid">
            <% if (products.isEmpty()) { %>
              <div class="no-products" id="noProducts">
                <div class="no-products-icon">📦</div>
                <h3>No Products Found</h3>
                <% if (formWasSubmittedOrFiltersApplied) { %>
                    <p>Try adjusting your filters or selecting a different supplier.</p>
                <% } else { %>
                    <p>There are currently no products to display.</p>
                <% } %>
              </div>
            <% } else { %>
              <% for (ProductModel product : products) { %>
                <div class="product-card">
                  <div class="product-image">
                    <img src="${pageContext.request.contextPath}/<%= (product.getImagePath() != null && !product.getImagePath().isEmpty() ? product.getImagePath() : "Images/products/default.png") %>" alt="<%= product.getName() %>">
                  </div>
                  <div class="product-details">
                    <% if (product.getCategory() != null && !product.getCategory().isEmpty()) { %>
                        <span class="product-category-tag"><%= product.getCategory() %></span>
                    <% } %>
                    <h3 class="product-name"><%= product.getName() %></h3>
                    <div class="product-sku">SKU: <%= product.getSku() != null ? product.getSku() : "N/A" %></div>
                    <div class="product-price"><%= df.format(product.getPrice() != null ? product.getPrice() : BigDecimal.ZERO) %></div>
                    <div class="product-supplier">
                      <svg xmlns="http://www.w3.org/2000/svg" width="12" height="12" viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
                      <%= product.getSupplierName() != null ? product.getSupplierName() : "Unknown Supplier" %>
                    </div>
                    <div class="product-stock">
                      <% 
                        String stockClass = "out-of-stock"; String stockText = "Out of Stock";
                        if (product.getStock() > 10) { stockClass = "in-stock"; stockText = "In Stock (" + product.getStock() + " units)"; }
                        else if (product.getStock() > 0) { stockClass = "low-stock"; stockText = "Low Stock (" + product.getStock() + " units)"; }
                      %>
                      <div class="stock-indicator <%= stockClass %>"></div> <%= stockText %>
                    </div>
                    <div class="product-actions">
                      <button class="view-product-btn" onclick="alert('View details for: <%= product.getName().replace("'", "\\\\'") %>')">View Details</button>
                      <button class="order-product-btn" onclick="window.location.href='purchases.jsp?productId=<%= product.getId() %>'">Order</button>
                    </div>
                  </div>
                </div>
              <% } %>
            <% } %>
          </div>
        </div>
      </div>
      
      <div class="footer"> Swift © <%= new java.text.SimpleDateFormat("yyyy").format(new java.util.Date()) %>. </div>
    </div>
  </div>
  
  <script src="${pageContext.request.contextPath}/Admin/script.js"></script>
  <script>
    document.getElementById('mobileNavToggle').addEventListener('click', function() {
      document.getElementById('sidebar').classList.toggle('active');
    });
    
    document.getElementById('resetFiltersBtn').addEventListener('click', function() {
      const form = document.getElementById('filterForm');
      form.reset(); 
      // Redirect to the controller with the new Admin path to show all products
      window.location.href = "${pageContext.request.contextPath}/Admin/productsBySupplierController";
    });
  </script>
</body>
</html>