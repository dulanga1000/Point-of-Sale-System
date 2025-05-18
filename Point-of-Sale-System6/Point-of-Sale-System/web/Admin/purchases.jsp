<%-- 
    Document   : purchases
    Created on : May 16, 2025, 11:17:12 PM
    Author     : dulan
--%>

<%-- 
    Document   : create_purchase_order
    Created on : May 16, 2025, 9:30:15 AM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.time.LocalDate" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Create Purchase Order - Swift POS</title>
  <script src="script.js"></script>
  <link rel="Stylesheet" href="styles.css">
  <style>
    /* Purchase Order specific styles */
    .po-form-container {
      background-color: white;
      border-radius: 8px;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
      padding: 20px;
      margin-bottom: 20px;
    }
    
    .form-row {
      display: flex;
      flex-wrap: wrap;
      margin: 0 -10px;
      margin-bottom: 15px;
    }
    
    .form-group {
      flex: 1;
      min-width: 200px;
      padding: 0 10px;
      margin-bottom: 15px;
    }
    
    .form-group label {
      display: block;
      margin-bottom: 8px;
      font-weight: 500;
      font-size: 14px;
      color: var(--dark);
    }
    
    .form-group input,
    .form-group select,
    .form-group textarea {
      width: 100%;
      padding: 10px 12px;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      font-size: 14px;
      background-color: #f8fafc;
    }
    
    .form-group textarea {
      min-height: 100px;
      resize: vertical;
    }
    
    .form-group.full-width {
      width: 100%;
      flex-basis: 100%;
    }
    
    .products-table {
      margin-top: 20px;
      width: 100%;
      border-collapse: collapse;
    }
    
    .products-table th {
      background-color: #f1f5f9;
      padding: 12px 15px;
      text-align: left;
      font-weight: 500;
      font-size: 14px;
      color: var(--dark);
    }
    
    .products-table td {
      padding: 12px 15px;
      border-bottom: 1px solid #f1f5f9;
    }
    
    .products-table tr:last-child td {
      border-bottom: none;
    }
    
    .product-select {
      width: 100%;
      padding: 8px 10px;
      border: 1px solid #e2e8f0;
      border-radius: 4px;
      background-color: #f8fafc;
    }
    
    .quantity-input {
      width: 80px;
      padding: 8px 10px;
      border: 1px solid #e2e8f0;
      border-radius: 4px;
      text-align: center;
      background-color: #f8fafc;
    }
    
    .unit-price {
      font-weight: 500;
    }
    
    .row-total {
      font-weight: 500;
    }
    
    .add-row-btn {
      display: block;
      width: 100%;
      background-color: #f1f5f9;
      border: 1px dashed #cbd5e1;
      color: var(--secondary);
      padding: 10px;
      margin-top: 10px;
      border-radius: 6px;
      cursor: pointer;
      font-size: 14px;
      text-align: center;
    }
    
    .summary-box {
      background-color: #f8fafc;
      border-radius: 8px;
      padding: 20px;
      margin-top: 20px;
      border: 1px solid #e2e8f0;
    }
    
    .summary-row {
      display: flex;
      justify-content: space-between;
      padding: 8px 0;
      border-bottom: 1px solid #e2e8f0;
    }
    
    .summary-row:last-child {
      border-bottom: none;
      padding-top: 15px;
      font-weight: 600;
      font-size: 18px;
    }
    
    .action-buttons {
      display: flex;
      justify-content: flex-end;
      margin-top: 30px;
      gap: 15px;
    }
    
    .action-btn {
      padding: 12px 24px;
      border-radius: 6px;
      font-weight: 500;
      cursor: pointer;
      border: none;
      font-size: 14px;
    }
    
    .btn-secondary {
      background-color: #f1f5f9;
      color: var(--dark);
    }
    
    .btn-primary {
      background-color: var(--primary);
      color: white;
    }
    
    /* Responsive adjustments */
    @media (max-width: 768px) {
      .form-group {
        flex: 0 0 100%;
      }
      
      .action-buttons {
        flex-direction: column;
      }
      
      .action-btn {
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
        <h1 class="page-title">Create Purchase Order</h1>
        <div class="user-profile">
          <img src="${pageContext.request.contextPath}/Images/logo.png" alt="Admin Profile">
          <div>
            <h4>Admin User</h4>
          </div>
        </div>
      </div>
      
      <!-- Form Container -->
      <div class="po-form-container">
        <form action="/Point-of-Sale-System/Admin/PurchaseOrderServlet" method="post"onsubmit="updateSummary()">
          <!-- Order Information -->
          <div class="form-row">
            <div class="form-group">
              <label for="order_id">Purchase Order #</label>
              <input type="text" id="order_id" name="order_id" value="PO-<%= new java.util.Random().nextInt(90000) + 10000 %>" readonly>
            </div>
            <div class="form-group">
              <label for="order_date">Order Date</label>
              <input type="date" id="order_date" name="order_date" value="<%= LocalDate.now() %>" required>
            </div>
            <div class="form-group">
              <label for="expected_date">Expected Delivery Date</label>
              <input type="date" id="expected_date" name="expected_date" value="<%= LocalDate.now().plusDays(7) %>" required>
            </div>
          </div>
          
          <!-- Supplier Selection -->
          <div class="form-row">
            <div class="form-group">
              <label for="supplier_id">Select Supplier</label>
              <select id="supplier_id" name="supplier_id" required>
                <option value="">-- Select Supplier --</option>
                <%
                    String URL = "jdbc:mysql://localhost:3306/Swift_Database";
                    String USER = "root";
                    String PASSWORD = "";

                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
                        PreparedStatement sql = conn.prepareStatement("SELECT supplier_id, company_name FROM suppliers WHERE supplier_status = 'Active' ORDER BY company_name");
                        ResultSet result = sql.executeQuery();

                        while (result.next()) { %>
                            <option value="<%= result.getString("supplier_id") %>"><%= result.getString("company_name") %></option>
                        <% }
                        conn.close();
                    } catch (Exception ex) {
                        out.println("<option value=''>Error loading suppliers: " + ex.getMessage() + "</option>");
                    }
                %>
              </select>
            </div>
            <div class="form-group">
              <label for="payment_terms">Payment Terms</label>
              <select id="payment_terms" name="payment_terms" required>
                <option value="Net 30">Net 30</option>
                <option value="Net 15">Net 15</option>
                <option value="Net 7">Net 7</option>
                <option value="Due on Receipt">Due on Receipt</option>
                <option value="Cash on Delivery">Cash on Delivery</option>
              </select>
            </div>
            <div class="form-group">
              <label for="shipping_method">Shipping Method</label>
              <select id="shipping_method" name="shipping_method" required>
                <option value="Standard">Standard Delivery</option>
                <option value="Express">Express Delivery</option>
                <option value="Pickup">Pickup from Supplier</option>
              </select>
            </div>
          </div>
          
          <!-- Notes -->
          <div class="form-row">
            <div class="form-group full-width">
              <label for="notes">Order Notes</label>
              <textarea id="notes" name="notes" placeholder="Enter any special instructions or notes for this order..."></textarea>
            </div>
          </div>
          
          <!-- Products Table -->
<h3 style="margin-top: 30px; margin-bottom: 15px; font-size: 16px;">Order Items</h3>
<table class="products-table">
  <thead>
    <tr>
      <th style="width: 40%;">Product</th>
      <th style="width: 15%;">Quantity</th>
      <th style="width: 20%;">Unit Price</th>
      <th style="width: 20%;">Total</th>
      <th style="width: 5%;"></th>
    </tr>
  </thead>
  <tbody id="product-rows">
    <tr>
      <td>
        <select name="product_id[]" class="product-select" required>
          <option value="">-- Select Product --</option>
          <%
              try {
                  Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
                  PreparedStatement sql = conn.prepareStatement("SELECT id, name, price FROM products ORDER BY name");
                  ResultSet result = sql.executeQuery();

                  while (result.next()) {
          %>
              <option value="<%= result.getString("id") %>" data-price="<%= result.getDouble("price") %>">
               <%= result.getString("name") %> - Rs.<%= result.getDouble("price") %>
              </option>

          <%
                  }
                  conn.close();
              } catch (Exception ex) {
                  out.println("<option value=''>Error loading products: " + ex.getMessage() + "</option>");
              }
          %>
        </select>
      </td>
      <td>
        <input type="number" name="quantity[]" class="quantity-input" value="1" min="1" required>
      </td>
      <td class="unit-price">Rs.0.00</td>
      <td class="row-total">Rs.0.00</td>
      <td>
        <button type="button" class="remove-row-btn" onclick="removeProductRow(this)" style="background: none; border: none; color: var(--danger); cursor: pointer;">❌</button>
      </td>
    </tr>
  </tbody>
</table>

          
          <button type="button" class="add-row-btn" onclick="addProductRow()" >+ Add Another Product</button>
          
          <!-- Order Summary -->
          
            <div class="summary-row">
                 <label for="tax_rate" style="flex: 1;">Tax (%):</label>
                  <input type="number" id="tax_rate" name="tax_rate" value="15" min="0" max="100" step="0.01" style="width: 80px; text-align: right;" oninput="updateSummary()">
            </div>
            <div class="summary-row">
                 <span>Tax Amount:</span>
                 <span id="tax">Rs.0.00</span>
            </div>

          

             <div class="summary-row">
                  <span>Shipping:</span>
                  <span id="shipping">Rs.500.00</span>
             </div>
            <input type="hidden" id="shipping_input" name="shipping_amount" value="500.00">




          
            <div class="summary-box">
              <div class="summary-row">
               <span>Subtotal:</span>
               <span id="subtotal">Rs.0.00</span>
              </div>
              <div class="summary-row">
               <span>Total:</span>
               <span id="total">Rs.0.00</span>
             </div>
            </div>

               
               
           
    

          
          <!-- Action Buttons -->
          <div class="action-buttons">
  
            <!-- ✅ Hidden inputs for backend -->
             <input type="hidden" id="shipping_input" name="shipping_amount" value="500.00">
             <input type="hidden" id="subtotal_input" name="subtotal" value="0.00">
             <input type="hidden" id="total_input" name="total" value="0.00">

           <!-- Buttons -->
             <button type="button" class="action-btn btn-secondary" onclick="window.location.href='suppliers.jsp'">Cancel</button>
             <button type="submit" class="action-btn btn-primary">Create Purchase Order</button>
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
    
    // You requested without JavaScript, but minimal JS is included for mobile responsiveness
    // The supplier dropdown functionality works without JS
  </script>
  <script>
  function updateRow(row) {
    const productSelect = row.querySelector('.product-select');
    const quantityInput = row.querySelector('.quantity-input');
    const unitPriceTd = row.querySelector('.unit-price');
    const rowTotalTd = row.querySelector('.row-total');

    const selectedOption = productSelect.options[productSelect.selectedIndex];
    if (!selectedOption || !selectedOption.text.includes("Rs.")) return;

    const priceText = selectedOption.text.split("Rs.")[1];
    const unitPrice = parseFloat(priceText.replace(",", "").trim()) || 0;
    const quantity = parseInt(quantityInput.value) || 0;

    const rowTotal = unitPrice * quantity;
    unitPriceTd.textContent = "Rs." + unitPrice.toFixed(2);
    rowTotalTd.textContent = "Rs." + rowTotal.toFixed(2);

    updateSummary();
  }

  function updateSummary() {
  let subtotal = 0;

  // Sum all product row totals
  document.querySelectorAll('#product-rows tr').forEach(row => {
    const rowTotalText = row.querySelector('.row-total')?.textContent?.replace("Rs.", "").trim() || "0";
    subtotal += parseFloat(rowTotalText) || 0;
  });

  const taxRate = parseFloat(document.getElementById('tax_rate')?.value || 0);
  const shipping = parseFloat(document.getElementById('shipping_input')?.value || 0);
  const taxAmount = subtotal * (taxRate / 100);
  const total = subtotal + taxAmount + shipping;

  // Update UI display
  document.getElementById('subtotal').textContent = "Rs." + subtotal.toFixed(2);
  document.getElementById('tax').textContent = "Rs." + taxAmount.toFixed(2);
  document.getElementById('shipping').textContent = "Rs." + shipping.toFixed(2);
  document.getElementById('total').textContent = "Rs." + total.toFixed(2);

  // Update hidden input fields for backend
  document.getElementById('subtotal_input').value = subtotal.toFixed(2);
  document.getElementById('total_input').value = total.toFixed(2);
}






  document.querySelectorAll('.product-select, .quantity-input').forEach(el => {
    el.addEventListener('change', function () {
      const row = el.closest('tr');
      updateRow(row);
    });
  });

  document.getElementById('tax_rate').addEventListener('input', updateSummary);
  document.getElementById('shipping_input').addEventListener('input', updateSummary);
  // Recalculate initially
  updateSummary();
  
  function prepareOrderData() {
  const rows = document.querySelectorAll('#product-rows tr');
  const productIds = [];
  const quantities = [];

  rows.forEach(row => {
    const productSelect = row.querySelector('.product-select');
    const quantityInput = row.querySelector('.quantity-input');

    const productId = productSelect.value;
    const quantity = parseInt(quantityInput.value);

    if (productId && quantity > 0) {
      productIds.push(productId);
      quantities.push(quantity);
    }
  });
  
  

  document.getElementById('product_ids').value = productIds.join(',');
  document.getElementById('quantities').value = quantities.join(',');
  return true;
}


</script>







</body>
</html>   