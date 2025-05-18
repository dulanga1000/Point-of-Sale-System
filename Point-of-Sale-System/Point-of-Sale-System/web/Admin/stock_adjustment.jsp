<%--
    Document   : stock_adjustment
    Created on : May 17, 2025, 11:30:15 AM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Stock Adjustment - Swift POS</title>
  <link rel="Stylesheet" href="styles.css">
  <style>
    /* Additional styles for the stock adjustment page */
    .stock-adjustment-container {
      max-width: 900px;
      margin: 0 auto;
      background-color: white;
      border-radius: 8px;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
      padding: 20px;
    }
    
    .form-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 20px;
      margin-bottom: 20px;
    }
    
    .form-grid-full {
      grid-column: span 2;
    }
    
    .form-group {
      margin-bottom: 15px;
    }
    
    .form-group label {
      display: block;
      margin-bottom: 8px;
      font-weight: 500;
      color: var(--dark);
    }
    
    .form-control {
      width: 100%;
      padding: 10px;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      font-size: 14px;
    }
    
    .form-select {
      width: 100%;
      padding: 10px;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      font-size: 14px;
      background-color: white;
    }
    
    .btn-primary {
      background-color: var(--primary);
      color: white;
      border: none;
      padding: 12px 24px;
      border-radius: 6px;
      cursor: pointer;
      font-weight: 500;
    }
    
    .btn-secondary {
      background-color: white;
      color: var(--dark);
      border: 1px solid #e2e8f0;
      padding: 12px 24px;
      border-radius: 6px;
      cursor: pointer;
      font-weight: 500;
    }
    
    .btn-success {
      background-color: var(--success);
      color: white;
      border: none;
      padding: 12px 24px;
      border-radius: 6px;
      cursor: pointer;
      font-weight: 500;
    }
    
    .selected-product {
      background-color: #f8fafc;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      padding: 15px;
      margin-bottom: 20px;
    }
    
    .selected-product-name {
      font-weight: 600;
      font-size: 16px;
      margin-bottom: 5px;
    }
    
    .selected-product-details {
      display: flex;
      color: var(--secondary);
      font-size: 14px;
      margin-bottom: 10px;
    }
    
    .selected-product-detail {
      margin-right: 20px;
    }
    
    .adjustment-type {
      display: flex;
      gap: 10px;
      margin-bottom: 15px;
    }
    
    .type-btn {
      flex: 1;
      padding: 10px;
      text-align: center;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      cursor: pointer;
      background-color: white;
    }
    
    .type-btn.active {
      background-color: var(--primary);
      color: white;
      border-color: var(--primary);
    }
    
    .type-btn.increase.active {
      background-color: var(--success);
      border-color: var(--success);
    }
    
    .type-btn.decrease.active {
      background-color: var(--danger);
      border-color: var(--danger);
    }
    
    .adjustment-history {
      margin-top: 30px;
    }
    
    .adjustment-history h3 {
      font-size: 18px;
      margin-bottom: 15px;
      color: var(--dark);
      font-weight: 600;
    }
    
    /* Message styles */
    .message {
      padding: 15px;
      margin-bottom: 20px;
      border-radius: 6px;
      font-size: 14px;
    }
    
    .message-success {
      background-color: #d1fae5;
      color: #065f46;
      border: 1px solid #34d399;
    }
    
    .message-error {
      background-color: #fee2e2;
      color: #991b1b;
      border: 1px solid #f87171;
    }
    
    /* Responsive adjustments */
    @media (max-width: 768px) {
      .form-grid {
        grid-template-columns: 1fr;
      }
      
      .form-grid-full {
        grid-column: span 1;
      }
      
      .stock-adjustment-container {
        padding: 15px;
        margin: 0 10px;
      }
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
        <h1 class="page-title">Stock Adjustment</h1>
        <div class="user-profile">
          <img src="../Images/logo.png" alt="Admin Profile">
          <div>
            <h4>Admin User</h4>
          </div>
        </div>
      </div>
      
      <!-- Notification Messages -->
      <% 
        String message = request.getParameter("message");
        String messageType = request.getParameter("type");
        
        if (message != null && !message.isEmpty()) {
      %>
        <div class="message <%= messageType != null && messageType.equals("error") ? "message-error" : "message-success" %>">
          <%= message %>
        </div>
      <% } %>
      
      <div class="stock-adjustment-container">
        <form action="processStockAdjustment.jsp" method="post" id="adjustmentForm">
          <div class="form-group">
            <label for="productSelect">Select Product:</label>
            <select id="productSelect" name="productId" class="form-select" required>
              <option value="">-- Select a product --</option>
              <% 
              Connection conn = null;
              try {
                  Class.forName("com.mysql.cj.jdbc.Driver");
                  String URL = "jdbc:mysql://localhost:3306/Swift_Database";
                  String USER = "root";
                  String PASSWORD = "";
                  conn = DriverManager.getConnection(URL, USER, PASSWORD);
                  
                  String productQuery = "SELECT id, name, sku, stock_quantity, category_id, " +
                                      "(SELECT name FROM categories WHERE id = products.category_id) as category_name " +
                                      "FROM products ORDER BY name ASC";
                                      
                  PreparedStatement ps = conn.prepareStatement(productQuery);
                  ResultSet rs = ps.executeQuery();
                  
                  while (rs.next()) {
              %>
              <option value="<%= rs.getInt("id") %>" 
                      data-sku="<%= rs.getString("sku") %>" 
                      data-stock="<%= rs.getInt("stock_quantity") %>" 
                      data-category="<%= rs.getString("category_name") %>">
                <%= rs.getString("name") %> - <%= rs.getString("sku") %>
              </option>
              <% 
                  }
              } catch (Exception e) {
                  out.println("<option value=''>Error loading products: " + e.getMessage() + "</option>");
              } finally {
                  if (conn != null) {
                      try {
                          conn.close();
                      } catch (SQLException e) {
                          // Log the error
                      }
                  }
              }
              %>
            </select>
          </div>
          
          <div id="selectedProductContainer" style="display: none;" class="selected-product">
            <div class="selected-product-name" id="selectedProductName">Product Name</div>
            <div class="selected-product-details">
              <div class="selected-product-detail">SKU: <span id="selectedProductSKU">SKU123</span></div>
              <div class="selected-product-detail">Current Stock: <span id="selectedProductStock">100</span></div>
              <div class="selected-product-detail">Category: <span id="selectedProductCategory">Category</span></div>
            </div>
          </div>
          
          <div class="form-grid">
            <div class="form-group">
              <label>Adjustment Type:</label>
              <div class="adjustment-type">
                <div class="type-btn increase" data-type="increase" onclick="selectAdjustmentType('increase')">
                  Stock In (+)
                </div>
                <div class="type-btn decrease" data-type="decrease" onclick="selectAdjustmentType('decrease')">
                  Stock Out (-)
                </div>
              </div>
              <input type="hidden" name="adjustmentType" id="adjustmentType" value="increase">
            </div>
            
            <div class="form-group">
              <label for="quantity">Quantity:</label>
              <input type="number" id="quantity" name="quantity" class="form-control" min="1" value="1" required>
            </div>
            
            <div class="form-group">
              <label for="reason">Reason:</label>
              <select name="reason" id="reason" class="form-select" required>
                <option value="">Select reason</option>
                <option value="Purchase">New Purchase</option>
                <option value="Return">Customer Return</option>
                <option value="Damage">Damaged/Expired</option>
                <option value="Count">Stock Count Adjustment</option>
                <option value="Transfer">Transfer</option>
                <option value="Sale">Sale</option>
                <option value="Other">Other</option>
              </select>
            </div>
            
            <div class="form-group">
              <label for="reference">Reference Number:</label>
              <input type="text" id="reference" name="reference" class="form-control" value="" readonly>
            </div>
            
            <div class="form-group form-grid-full">
              <label for="notes">Notes:</label>
              <textarea id="notes" name="notes" class="form-control" rows="3" placeholder="Additional information"></textarea>
            </div>
          </div>
          
          <div style="text-align: right;">
            <button type="button" class="btn-secondary" onclick="window.location.href='inventory.jsp'">Cancel</button>
            <button type="submit" class="btn-success" id="submitBtn" disabled>Save Adjustment</button>
          </div>
        </form>
      </div>
      
      <div class="module-card adjustment-history">
        <div class="module-header">
          Recent Stock Adjustments
        </div>
        <div class="module-content">
          <table>
            <thead>
              <tr>
                <th>Date</th>
                <th>Product</th>
                <th>Type</th>
                <th>Quantity</th>
                <th>Reason</th>
                <th>Reference</th>
                <th>User</th>
              </tr>
            </thead>
            <tbody>
              <% 
              String URL = "jdbc:mysql://localhost:3306/Swift_Database";
              String USER = "root";
              String PASSWORD = ""; // Ensure this is secure in production
              conn = null;
              
              try {
                  Class.forName("com.mysql.cj.jdbc.Driver");
                  conn = DriverManager.getConnection(URL, USER, PASSWORD);
                  
                  // Sample query - modify according to your database schema
                  String query = "SELECT sa.id, sa.date, p.name as product_name, sa.adjustment_type, " +
                                "sa.quantity, sa.reason, sa.reference, u.username " +
                                "FROM stock_adjustments sa " +
                                "JOIN products p ON sa.product_id = p.id " +
                                "JOIN users u ON sa.user_id = u.id " +
                                "ORDER BY sa.date DESC LIMIT 10";
                                
                  PreparedStatement ps = conn.prepareStatement(query);
                  ResultSet rs = ps.executeQuery();
                  
                  boolean hasAdjustments = false;
                  while (rs.next()) {
                      hasAdjustments = true;
                      String adjustmentType = rs.getString("adjustment_type");
                      String typeClass = adjustmentType.equalsIgnoreCase("increase") ? "completed" : "pending";
              %>
              <tr>
                <td><%= rs.getString("date") %></td>
                <td><%= rs.getString("product_name") %></td>
                <td><span class="status <%= typeClass %>"><%= adjustmentType.equals("increase") ? "Stock In" : "Stock Out" %></span></td>
                <td><%= rs.getInt("quantity") %></td>
                <td><%= rs.getString("reason") %></td>
                <td><%= rs.getString("reference") != null ? rs.getString("reference") : "-" %></td>
                <td><%= rs.getString("username") %></td>
              </tr>
              <% 
                  }
                  
                  if (!hasAdjustments) {
              %>
              <tr>
                <td colspan="7" style="text-align: center;">No recent stock adjustments found.</td>
              </tr>
              <% 
                  }
              } catch (Exception e) {
                  out.println("<tr><td colspan='7' style='text-align: center; color: red;'>Error fetching adjustment history: " + e.getMessage() + "</td></tr>");
              } finally {
                  if (conn != null) {
                      try {
                          conn.close();
                      } catch (SQLException e) {
                          // Log the error
                      }
                  }
              }
              %>
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
    const mobileNavToggle = document.getElementById('mobileNavToggle');
    const sidebar = document.getElementById('sidebar');

    if (mobileNavToggle && sidebar) {
        mobileNavToggle.addEventListener('click', () => {
            sidebar.classList.toggle('active');
        });
    }
    
    // Product selection functionality
    const productSelect = document.getElementById('productSelect');
    const selectedProductContainer = document.getElementById('selectedProductContainer');
    const submitBtn = document.getElementById('submitBtn');
    
    // Generate reference number
    function generateReferenceNumber() {
        const prefix = document.getElementById('adjustmentType').value === 'increase' ? 'IN' : 'OUT';
        const date = new Date();
        const timestamp = date.getFullYear().toString().substr(-2) + 
                         padNumber(date.getMonth() + 1) + 
                         padNumber(date.getDate()) + 
                         padNumber(date.getHours()) + 
                         padNumber(date.getMinutes());
        const random = Math.floor(Math.random() * 1000).toString().padStart(3, '0');
        return `${prefix}-${timestamp}-${random}`;
    }
    
    function padNumber(num) {
        return num.toString().padStart(2, '0');
    }
    
    // Update reference number when adjustment type changes
    function updateReferenceNumber() {
        document.getElementById('reference').value = generateReferenceNumber();
    }
    
    // Initialize reference number
    updateReferenceNumber();
    
    // Product selection
    productSelect.addEventListener('change', function() {
        if (this.value) {
            const selectedOption = this.options[this.selectedIndex];
            const sku = selectedOption.getAttribute('data-sku');
            const stock = selectedOption.getAttribute('data-stock');
            const category = selectedOption.getAttribute('data-category');
            
            // Display selected product info
            document.getElementById('selectedProductName').textContent = selectedOption.text;
            document.getElementById('selectedProductSKU').textContent = sku;
            document.getElementById('selectedProductStock').textContent = stock;
            document.getElementById('selectedProductCategory').textContent = category;
            
            // Show product container
            selectedProductContainer.style.display = 'block';
            
            // Enable submit button
            submitBtn.disabled = false;
        } else {
            // Hide product container if no product selected
            selectedProductContainer.style.display = 'none';
            
            // Disable submit button
            submitBtn.disabled = true;
        }
    });
    
    // Adjustment type selection
    function selectAdjustmentType(type) {
        document.querySelectorAll('.type-btn').forEach(btn => {
            btn.classList.remove('active');
        });
        
        document.querySelector(`.type-btn[data-type="${type}"]`).classList.add('active');
        document.getElementById('adjustmentType').value = type;
        
        // Update reference number when type changes
        updateReferenceNumber();
    }
    
    // Initialize with "increase" as default
    selectAdjustmentType('increase');
    
    // Form validation
    document.getElementById('adjustmentForm').addEventListener('submit', function(e) {
        const productId = document.getElementById('productSelect').value;
        const quantity = document.getElementById('quantity').value;
        const reason = document.getElementById('reason').value;
        
        if (!productId) {
            e.preventDefault();
            alert('Please select a product');
            return;
        }
        
        if (!quantity || quantity < 1) {
            e.preventDefault();
            alert('Please enter a valid quantity');
            return;
        }
        
        if (!reason) {
            e.preventDefault();
            alert('Please select a reason for this adjustment');
            return;
        }
    });
  </script>
</body>
</html>