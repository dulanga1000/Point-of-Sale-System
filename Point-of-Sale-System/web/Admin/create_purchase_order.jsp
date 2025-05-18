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
  <script src="${pageContext.request.contextPath}/Admin/script.js"></script>
  <link rel="stylesheet" href="${pageContext.request.contextPath}/Admin/styles.css">
  <style>
    /* Purchase Order specific styles (Copied from your original JSP) */
    :root {
      --primary: #4f46e5;     /* Indigo 600 */
      --primary-light: #6366f1; /* Indigo 500 */
      --secondary: #475569;   /* Slate 600 */
      --dark: #1e293b;         /* Slate 800 */
      --light: #f8fafc;       /* Slate 50 */
      --danger: #ef4444;       /* Red 500 */
      --success: #10b981;       /* Emerald 500 */
      --warning: #f59e0b;       /* Amber 500 */
    }
    
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
      width: 60px;
      padding: 8px 10px;
      border: 1px solid #e2e8f0;
      border-radius: 4px;
      text-align: center;
      background-color: #f8fafc;
    }
    
    .quantity-control {
      display: flex;
      align-items: center;
      justify-content: space-between;
      max-width: 130px;
    }
    
    .quantity-btn {
      width: 30px;
      height: 30px;
      display: flex;
      align-items: center;
      justify-content: center;
      background-color: var(--primary-light);
      color: white;
      border: none;
      border-radius: 4px;
      font-size: 16px;
      cursor: pointer;
      transition: background-color 0.2s;
    }
    
    .quantity-btn:hover {
      background-color: var(--primary);
    }
    
    .unit-price {
      font-weight: 500;
      color: var(--dark);
    }
    
    .row-total {
      font-weight: 500;
      color: var(--primary);
    }
    
    .add-row-btn {
      display: block;
      width: 100%;
      background-color: #e0e7ff;
      border: 1px dashed #a5b4fc;
      color: var(--primary);
      padding: 10px;
      margin-top: 10px;
      border-radius: 6px;
      cursor: pointer;
      font-size: 14px;
      text-align: center;
      transition: background-color 0.2s;
    }
    
    .add-row-btn:hover {
      background-color: #c7d2fe;
    }
    
    .summary-box {
      background-color: #f1f5f9;
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
      color: var(--dark);
    }
    
    .summary-row:last-child {
      border-bottom: none;
      padding-top: 15px;
      font-weight: 600;
      font-size: 18px;
      color: var(--primary);
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
      transition: background-color 0.2s;
    }
    
    .btn-secondary {
      background-color: #e2e8f0;
      color: var(--dark);
    }
    
    .btn-secondary:hover {
      background-color: #cbd5e1;
    }
    
    .btn-primary {
      background-color: var(--primary);
      color: white;
    }
    
    .btn-primary:hover {
      background-color: #4338ca;
    }
    
    .remove-row {
      background: none;
      border: none;
      color: var(--danger);
      cursor: pointer;
      font-size: 18px;
      transition: transform 0.2s;
    }
    
    .remove-row:hover {
      transform: scale(1.1);
    }

    /* Message Styles */
    .message-container {
        padding: 10px 15px; /* Increased padding */
        margin-bottom: 20px; /* Increased margin */
        border-radius: 6px; /* Slightly more rounded */
        font-size: 14px;
        text-align: center;
        border-width: 1px;
        border-style: solid;
    }
    .message-success {
        background-color: #d1fae5; /* Lighter green */
        color: #065f46;    /* Darker green text */
        border-color: #34d399; /* Green border */
    }
    .message-error {
        background-color: #fee2e2; /* Lighter red */
        color: #991b1b;    /* Darker red text */
        border-color: #f87171; /* Red border */
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
  <div class="mobile-top-bar">
    <div class="mobile-logo">
      <img src="${pageContext.request.contextPath}/Images/logo.png" alt="POS Logo">
      <h2>Swift</h2>
    </div>
    <button class="mobile-nav-toggle" id="mobileNavToggle">&#9776;</button>
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
        <h1 class="page-title">Create Purchase Order</h1>
        <div class="user-profile">
          <img src="${pageContext.request.contextPath}/Images/logo.png" alt="Admin Profile">
          <div>
            <%
                model.User loggedInUser = (model.User) session.getAttribute("loggedInUser");
                String userDisplayName = "Admin User"; // Default
                if (loggedInUser != null) {
                    userDisplayName = loggedInUser.getFirstName() + " " + loggedInUser.getLastName();
                }
            %>
            <h4><%= userDisplayName %></h4>
          </div>
        </div>
      </div>

      <%
            String message = (String) session.getAttribute("poMessage");
            String messageType = (String) session.getAttribute("poMessageType");
            if (message != null) {
        %>
            <div class="message-container <%= "success".equals(messageType) ? "message-success" : "message-error" %>">
                <%= message %>
            </div>
        <%
                session.removeAttribute("poMessage");
                session.removeAttribute("poMessageType");
            }
        %>
      
      <div class="po-form-container">
        <%-- *** MODIFIED: Form action points to the new servlet *** --%>
        <form method="post" action="${pageContext.request.contextPath}/Admin/createPurchaseOrderAction" id="purchaseOrderForm">
          <div class="form-row">
            <div class="form-group">
              <label for="order_id">Purchase Order #</label>
              <input type="text" id="order_id" name="order_id" value="PO-<%= new java.util.Random().nextInt(900000) + 100000 %>" readonly>
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
          
          <div class="form-row">
            <div class="form-group">
              <label for="supplier_id">Select Supplier</label>
              <select id="supplier_id" name="supplier_id" required>
                <option value="">-- Select Supplier --</option>
                <%
                    // Database connection details (should ideally be in a utility class)
                    String URL_JSP = "jdbc:mysql://localhost:3306/Swift_Database";
                    String USER_JSP = "root";
                    String PASSWORD_JSP = ""; // Your DB password

                    Connection conn_jsp_supplier = null;
                    try {
                        Class.forName("com.mysql.cj.jdbc.Driver");
                        conn_jsp_supplier = DriverManager.getConnection(URL_JSP, USER_JSP, PASSWORD_JSP);
                        // Fetch only active suppliers
                        PreparedStatement ps_supplier = conn_jsp_supplier.prepareStatement(
                            "SELECT supplier_id, company_name FROM suppliers WHERE supplier_status = 'Active' ORDER BY company_name"
                        );
                        ResultSet rs_supplier = ps_supplier.executeQuery();

                        while (rs_supplier.next()) { %>
                          <option value="<%= rs_supplier.getInt("supplier_id") %>"><%= rs_supplier.getString("company_name") %></option>
                        <% }
                        rs_supplier.close();
                        ps_supplier.close();
                    } catch (Exception ex) {
                        out.println("<option value=''>Error loading suppliers: " + ex.getMessage() + "</option>");
                        ex.printStackTrace(); // Log error
                    } finally {
                        if (conn_jsp_supplier != null) {
                            try { conn_jsp_supplier.close(); } catch (SQLException e) { e.printStackTrace(); }
                        }
                    }
                %>
              </select>
            </div>
            <div class="form-group">
              <label for="payment_terms">Payment Terms</label>
              <select id="payment_terms" name="payment_terms" required>
                <option value="Net 30">Net 30 Days</option>
                <option value="Net 15">Net 15 Days</option>
                <option value="Net 7">Net 7 Days</option>
                <option value="Due on Receipt">Due on Receipt</option>
                <option value="Cash on Delivery">Cash on Delivery</option>
                <option value="Advance Payment">Advance Payment</option>
              </select>
            </div>
            <div class="form-group">
              <label for="shipping_method">Shipping Method</label>
              <select id="shipping_method" name="shipping_method" required>
                <option value="Standard Delivery">Standard Delivery</option>
                <option value="Express Delivery">Express Delivery</option>
                <option value="Pickup">Pickup from Supplier</option>
                <option value="Courier Service">Courier Service</option>
              </select>
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group">
              <label for="tax_percentage">Tax Percentage (%)</label>
              <input type="number" id="tax_percentage" name="tax_percentage" min="0" max="100" step="0.01" value="15.00" required oninput="updateOrderSummary()">
            </div>
            <div class="form-group">
              <label for="shipping_cost">Shipping Cost (Rs.)</label>
              <input type="number" id="shipping_cost" name="shipping_cost" min="0" step="0.01" value="0.00" required oninput="updateOrderSummary()">
            </div>
          </div>
          
          <div class="form-row">
            <div class="form-group full-width">
              <label for="notes">Order Notes</label>
              <textarea id="notes" name="notes" placeholder="Enter any special instructions or notes for this order..."></textarea>
            </div>
          </div>
          
          <h3 style="margin-top: 30px; margin-bottom: 15px; font-size: 16px; color: var(--primary);">Order Items</h3>
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
              <tr class="product-row">
                <td>
                  <%-- Ensure name is product_id[] for array submission --%>
                  <select name="product_id[]" class="product-select" required onchange="updateProductPrice(this)">
                    <option value="">-- Select Product --</option>
                    <%
                        Connection conn_products_jsp = null;
                        try {
                            Class.forName("com.mysql.cj.jdbc.Driver");
                            conn_products_jsp = DriverManager.getConnection(URL_JSP, USER_JSP, PASSWORD_JSP);
                            PreparedStatement ps_products = conn_products_jsp.prepareStatement(
                                "SELECT id, name, price FROM products WHERE status = 'Active' ORDER BY name"
                            );
                            ResultSet rs_products = ps_products.executeQuery();

                            while (rs_products.next()) { 
                                double price = rs_products.getDouble("price");
                            %>
                              <option value="<%= rs_products.getInt("id") %>" data-price="<%= price %>">
                                <%= rs_products.getString("name") %> - Rs.<%= String.format("%.2f", price) %>
                              </option>
                            <% }
                            rs_products.close();
                            ps_products.close();
                        } catch (Exception ex) {
                            out.println("<option value=''>Error loading products: " + ex.getMessage() + "</option>");
                            ex.printStackTrace();
                        } finally {
                            if (conn_products_jsp != null) {
                                try { conn_products_jsp.close(); } catch (SQLException e) { e.printStackTrace(); }
                            }
                        }
                    %>
                  </select>
                </td>
                <td>
                  <div class="quantity-control">
                    <button type="button" class="quantity-btn decrease-btn" onclick="decreaseQuantity(this)">-</button>
                    <%-- Ensure name is quantity[] for array submission --%>
                    <input type="number" name="quantity[]" class="quantity-input" value="1" min="1" required onchange="updateRowTotal(this)">
                    <button type="button" class="quantity-btn increase-btn" onclick="increaseQuantity(this)">+</button>
                  </div>
                </td>
                <td class="unit-price">Rs.0.00</td>
                <td class="row-total">Rs.0.00</td>
                <td>
                  <button type="button" class="remove-row" onclick="removeProductRow(this)">&#10060;</button>
                </td>
              </tr>
            </tbody>
          </table>
          
          <button type="button" class="add-row-btn" onclick="addProductRow()">+ Add Another Product</button>
          
          <div class="summary-box">
            <div class="summary-row">
              <span>Subtotal:</span>
              <span id="subtotal">Rs.0.00</span>
            </div>
            <div class="summary-row">
              <span>Tax:</span>
              <span id="tax">Rs.0.00</span>
            </div>
            <div class="summary-row">
              <span>Shipping:</span>
              <span id="shipping">Rs.0.00</span>
            </div>
            <div class="summary-row">
              <span>Total:</span>
              <span id="total">Rs.0.00</span>
            </div>
          </div>
          
          <div class="action-buttons">
            <button type="button" class="action-btn btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/Admin/purchases.jsp'">Cancel</button>
            <button type="submit" class="action-btn btn-primary">Create Purchase Order</button>
          </div>
        </form>
      </div>
      
      <div class="footer">
        Swift &copy; <%= java.time.Year.now().getValue() %>.
      </div>
    </div>
  </div>
  
  <script>
    // JavaScript functions (updateProductPrice, updateRowTotal, increaseQuantity, decreaseQuantity, addProductRow, removeProductRow, updateOrderSummary)
    // remain the same as in your provided JSP.
    // Ensure they are correctly implemented and working for client-side calculations.

    function updateProductPrice(selectElement) {
        const row = selectElement.closest('tr');
        const selectedOption = selectElement.options[selectElement.selectedIndex];
        const price = parseFloat(selectedOption.getAttribute('data-price')) || 0;
        
        const unitPriceCell = row.querySelector('.unit-price');
        unitPriceCell.textContent = 'Rs.' + price.toFixed(2);
        
        updateRowTotal(selectElement); 
    }

    function updateRowTotal(elementInRow) {
        const row = elementInRow.closest('tr');
        const unitPriceText = row.querySelector('.unit-price').textContent;
        const unitPrice = parseFloat(unitPriceText.replace('Rs.', '')) || 0;
        const quantityInput = row.querySelector('.quantity-input');
        let quantity = parseInt(quantityInput.value);

        if(isNaN(quantity) || quantity < 1) { 
             quantity = 1; 
             quantityInput.value = 1; // Correct the input field as well
        }
        
        const rowTotal = unitPrice * quantity;
        row.querySelector('.row-total').textContent = 'Rs.' + rowTotal.toFixed(2);
        
        updateOrderSummary();
    }
    
    function increaseQuantity(button) {
      const input = button.previousElementSibling;
      input.value = parseInt(input.value) + 1;
      updateRowTotal(input);
    }
    
    function decreaseQuantity(button) {
      const input = button.nextElementSibling;
      const currentValue = parseInt(input.value);
      if (currentValue > 1) {
        input.value = currentValue - 1;
        updateRowTotal(input);
      }
    }
    
    function addProductRow() {
        const productRowsTbody = document.getElementById('product-rows');
        const firstRow = productRowsTbody.querySelector('.product-row');
        if (!firstRow) {
            console.error("Could not find the first product row to clone.");
            return;
        }
        const newRow = firstRow.cloneNode(true);
        
        // Reset values in the new row
        newRow.querySelector('.product-select').selectedIndex = 0;
        const newQtyInput = newRow.querySelector('.quantity-input');
        newQtyInput.value = 1;
        newRow.querySelector('.unit-price').textContent = 'Rs.0.00';
        newRow.querySelector('.row-total').textContent = 'Rs.0.00';
        
        // Re-attach event listeners for new row elements if they were dynamically added or need specific handling
        // For onchange, cloning usually preserves them, but for dynamically added buttons, you might need to.
        // Example: newRow.querySelector('.product-select').addEventListener('change', function() { updateProductPrice(this); });
        // newQtyInput.addEventListener('change', function() { updateRowTotal(this); });
        // newRow.querySelector('.decrease-btn').addEventListener('click', function() { decreaseQuantity(this); });
        // newRow.querySelector('.increase-btn').addEventListener('click', function() { increaseQuantity(this); });
        // newRow.querySelector('.remove-row').addEventListener('click', function() { removeProductRow(this); });


        productRowsTbody.appendChild(newRow);
        updateOrderSummary(); 
    }
    
    function removeProductRow(button) {
      const row = button.closest('tr');
      const productRowsTbody = document.getElementById('product-rows');
      
      if (productRowsTbody.children.length > 1) {
        row.remove();
        updateOrderSummary();
      } else {
        alert("You must have at least one product in the order.");
      }
    }

    function updateOrderSummary() {
        let subtotal = 0;
        document.querySelectorAll('#product-rows .product-row').forEach(function(row) {
            const rowTotalText = row.querySelector('.row-total').textContent;
            subtotal += parseFloat(rowTotalText.replace('Rs.', '')) || 0;
        });
        document.getElementById('subtotal').textContent = 'Rs.' + subtotal.toFixed(2);

        const taxPercentage = parseFloat(document.getElementById('tax_percentage').value) || 0;
        const shippingCost = parseFloat(document.getElementById('shipping_cost').value) || 0;
        
        const taxAmount = (subtotal * taxPercentage) / 100;
        document.getElementById('tax').textContent = 'Rs.' + taxAmount.toFixed(2); // Removed percentage display here, it's in label
        
        document.getElementById('shipping').textContent = 'Rs.' + shippingCost.toFixed(2);
        
        const total = subtotal + taxAmount + shippingCost;
        document.getElementById('total').textContent = 'Rs.' + total.toFixed(2);
    }

    document.addEventListener('DOMContentLoaded', function() {
        const taxInput = document.getElementById('tax_percentage');
        const shippingInput = document.getElementById('shipping_cost');
        if(taxInput) taxInput.addEventListener('input', updateOrderSummary);
        if(shippingInput) shippingInput.addEventListener('input', updateOrderSummary);

        const firstProductSelect = document.querySelector('#product-rows .product-select');
        if (firstProductSelect && firstProductSelect.options.length > 1) { // Ensure product options are loaded
             if(firstProductSelect.value) { // If a product is already selected (e.g. due to browser cache)
                updateProductPrice(firstProductSelect);
             } else { // If "-- Select Product --" is selected, ensure totals are zeroed or based on defaults
                updateOrderSummary();
             }
        } else {
            updateOrderSummary(); 
        }
        
        // Initial attachment for the first row's quantity input
        const firstQuantityInput = document.querySelector('#product-rows .quantity-input');
        if (firstQuantityInput) {
            firstQuantityInput.addEventListener('change', function() { updateRowTotal(this); });
        }
    });
  </script>
</body>
</html>
