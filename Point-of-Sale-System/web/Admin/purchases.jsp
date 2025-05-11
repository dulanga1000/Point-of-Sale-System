<%-- 
    Document   : purchases
    Created on : May 11, 2025, 1:55:25 PM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Create Purchase Order - Swift POS</title>
  <link rel="Stylesheet" href="styles.css">
  <style>
    /* Purchase Order Form Styles */
    .po-form-container {
      display: grid;
      grid-template-columns: 2fr 1fr;
      gap: 20px;
    }
    
    .po-left-panel, .po-right-panel {
      background-color: white;
      border-radius: 8px;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
      overflow: hidden;
    }
    
    .po-panel-header {
      padding: 15px 20px;
      background-color: var(--primary);
      color: white;
      font-weight: 600;
    }
    
    .po-panel-content {
      padding: 20px;
    }
    
    .po-form-group {
      margin-bottom: 20px;
    }
    
    .po-form-grid {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 15px;
    }
    
    .po-form-group label {
      display: block;
      margin-bottom: 8px;
      font-weight: 500;
      color: var(--dark);
      font-size: 14px;
    }
    
    .po-form-group input,
    .po-form-group select,
    .po-form-group textarea {
      width: 100%;
      padding: 10px;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      background-color: #f8fafc;
      font-size: 14px;
    }
    
    .po-form-group textarea {
      min-height: 100px;
      resize: vertical;
    }
    
    .po-products-table {
      width: 100%;
      margin-top: 15px;
    }
    
    .po-products-table th {
      background-color: #f1f5f9;
      padding: 10px;
      font-size: 14px;
      font-weight: 500;
    }
    
    .po-products-table td {
      padding: 10px;
      border-bottom: 1px solid #f1f5f9;
    }
    
    .po-products-table tr:last-child td {
      border-bottom: none;
    }
    
    .po-product-row {
      display: flex;
      align-items: center;
      gap: 10px;
    }
    
    .po-product-image {
      width: 40px;
      height: 40px;
      border-radius: 4px;
      object-fit: cover;
      background-color: #f1f5f9;
    }
    
    .po-action-btn {
      background: none;
      border: none;
      cursor: pointer;
      font-size: 16px;
      padding: 0;
      width: 28px;
      height: 28px;
      border-radius: 4px;
      display: flex;
      align-items: center;
      justify-content: center;
      transition: background-color 0.2s;
    }
    
    .po-action-btn:hover {
      background-color: #f1f5f9;
    }
    
    .po-add-product-btn {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      background-color: #f1f5f9;
      border: 1px dashed #cbd5e1;
      color: var(--secondary);
      padding: 12px;
      width: 100%;
      border-radius: 6px;
      cursor: pointer;
      margin-top: 15px;
      font-size: 14px;
      transition: all 0.2s;
    }
    
    .po-add-product-btn:hover {
      background-color: #e2e8f0;
      color: var(--dark);
    }
    
    .po-summary-item {
      display: flex;
      justify-content: space-between;
      padding: 12px 0;
      border-bottom: 1px solid #f1f5f9;
    }
    
    .po-summary-item:last-child {
      border-bottom: none;
    }
    
    .po-summary-label {
      font-size: 14px;
      color: var(--secondary);
    }
    
    .po-summary-value {
      font-weight: 500;
    }
    
    .po-total {
      font-size: 18px;
      font-weight: 600;
      color: var(--primary);
    }
    
    .po-actions {
      display: flex;
      gap: 10px;
      margin-top: 20px;
    }
    
    .po-primary-btn, .po-secondary-btn {
      padding: 10px 20px;
      border-radius: 6px;
      font-weight: 500;
      cursor: pointer;
      border: none;
      font-size: 14px;
    }
    
    .po-primary-btn {
      background-color: var(--primary);
      color: white;
      flex: 1;
    }
    
    .po-secondary-btn {
      background-color: #f1f5f9;
      color: var(--dark);
    }
    
    .po-supplier-info {
      padding: 15px;
      background-color: #f8fafc;
      border-radius: 6px;
      margin-bottom: 20px;
    }
    
    .po-supplier-header {
      display: flex;
      align-items: center;
      gap: 10px;
      margin-bottom: 10px;
    }
    
    .po-supplier-logo {
      width: 40px;
      height: 40px;
      border-radius: 50%;
      background-color: #e0f2fe;
      display: flex;
      align-items: center;
      justify-content: center;
      font-size: 16px;
      font-weight: 600;
      color: var(--primary);
    }
    
    .po-supplier-name {
      font-weight: 600;
      font-size: 16px;
    }
    
    .po-supplier-detail {
      display: flex;
      flex-direction: column;
      gap: 5px;
      font-size: 14px;
      color: var(--secondary);
    }
    
    .po-supplier-detail span {
      display: flex;
      align-items: center;
      gap: 8px;
    }
    
    .po-note {
      font-size: 13px;
      color: var(--secondary);
      margin-top: 10px;
      font-style: italic;
    }
    
    /* Input quantity spinner */
    .po-quantity-input {
      display: flex;
      align-items: center;
      max-width: 120px;
    }
    
    .po-quantity-btn {
      width: 28px;
      height: 28px;
      display: flex;
      align-items: center;
      justify-content: center;
      background-color: #f1f5f9;
      border: 1px solid #e2e8f0;
      cursor: pointer;
      font-size: 16px;
      user-select: none;
    }
    
    .po-quantity-btn:first-child {
      border-radius: 6px 0 0 6px;
    }
    
    .po-quantity-btn:last-child {
      border-radius: 0 6px 6px 0;
    }
    
    .po-quantity-input input {
      width: 60px;
      text-align: center;
      border: 1px solid #e2e8f0;
      border-left: none;
      border-right: none;
      padding: 5px 0;
    }
    
    .po-product-selector {
      position: relative;
    }
    
    .po-product-dropdown {
      position: absolute;
      top: calc(100% + 5px);
      left: 0;
      width: 100%;
      background-color: white;
      border-radius: 6px;
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
      max-height: 250px;
      overflow-y: auto;
      z-index: 10;
    }
    
    .po-product-option {
      display: flex;
      align-items: center;
      gap: 10px;
      padding: 10px 15px;
      cursor: pointer;
      border-bottom: 1px solid #f1f5f9;
    }
    
    .po-product-option:last-child {
      border-bottom: none;
    }
    
    .po-product-option:hover {
      background-color: #f8fafc;
    }
    
    .po-status {
      display: inline-block;
      padding: 4px 8px;
      border-radius: 4px;
      font-size: 12px;
      font-weight: 500;
      margin-top: 5px;
    }
    
    .po-status.in-stock {
      background-color: #d1fae5;
      color: var(--success);
    }
    
    .po-status.low-stock {
      background-color: #fef3c7;
      color: var(--warning);
    }
    
    .po-status.out-of-stock {
      background-color: #fee2e2;
      color: var(--danger);
    }
    
    /* Responsive adjustments */
    @media (max-width: 1024px) {
      .po-form-container {
        grid-template-columns: 1fr;
      }
    }
    
    @media (max-width: 768px) {
      .po-form-grid {
        grid-template-columns: 1fr;
      }
      
      .po-actions {
        flex-direction: column;
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
          <img src="../Images/logo.png" alt="Admin Profile">
          <div>
            <h4>Admin User</h4>
          </div>
        </div>
      </div>
      
      <!-- Form Container -->
      <div class="po-form-container">
        <!-- Left Panel - Order Details -->
        <div class="po-left-panel">
          <div class="po-panel-header">
            Order Details
          </div>
          <div class="po-panel-content">
            <div class="po-supplier-info">
              <div class="po-supplier-header">
                <div class="po-supplier-logo">GC</div>
                <div class="po-supplier-name">Global Coffee Co.</div>
              </div>
              <div class="po-supplier-detail">
                <span>
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M22 16.92v3a2 2 0 01-2.18 2 19.79 19.79 0 01-8.63-3.07 19.5 19.5 0 01-6-6 19.79 19.79 0 01-3.07-8.67A2 2 0 014.11 2h3a2 2 0 012 1.72 12.84 12.84 0 00.7 2.81 2 2 0 01-.45 2.11L8.09 9.91a16 16 0 006 6l1.27-1.27a2 2 0 012.11-.45 12.84 12.84 0 002.81.7A2 2 0 0122 16.92z"></path>
                  </svg>
                  +94 75 123 4567
                </span>
                <span>
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M4 4h16c1.1 0 2 .9 2 2v12c0 1.1-.9 2-2 2H4c-1.1 0-2-.9-2-2V6c0-1.1.9-2 2-2z"></path>
                    <polyline points="22,6 12,13 2,6"></polyline>
                  </svg>
                  john.smith@globalcoffee.com
                </span>
                <span>
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M21 10c0 7-9 13-9 13s-9-6-9-13a9 9 0 0118 0z"></path>
                    <circle cx="12" cy="10" r="3"></circle>
                  </svg>
                  123 Coffee Lane, Colombo 04
                </span>
              </div>
            </div>
            
            <div class="po-form-grid">
              <div class="po-form-group">
                <label for="poNumber">PO Number</label>
                <input type="text" id="poNumber" value="PO-4593" readonly>
              </div>
              <div class="po-form-group">
                <label for="orderDate">Order Date</label>
                <input type="date" id="orderDate" value="2025-05-11">
              </div>
              <div class="po-form-group">
                <label for="expectedDate">Expected Delivery Date</label>
                <input type="date" id="expectedDate" value="2025-05-18">
              </div>
              <div class="po-form-group">
                <label for="paymentTerms">Payment Terms</label>
                <select id="paymentTerms">
                  <option value="net30">Net 30</option>
                  <option value="net15">Net 15</option>
                  <option value="cod">Cash on Delivery</option>
                  <option value="advance">Advance Payment</option>
                </select>
              </div>
            </div>
            
            <div class="po-form-group">
              <label for="shippingAddress">Shipping Address</label>
              <textarea id="shippingAddress">Swift Cafe
456 Main Street, Colombo 07
Sri Lanka</textarea>
            </div>
            
            <!-- Products Table -->
            <div class="po-form-group">
              <label>Products</label>
              <table class="po-products-table">
                <thead>
                  <tr>
                    <th style="width: 45%">Product</th>
                    <th style="width: 15%">Unit Price</th>
                    <th style="width: 20%">Quantity</th>
                    <th style="width: 15%">Total</th>
                    <th style="width: 5%"></th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>
                      <div class="po-product-row">
                        <div class="po-product-image"></div>
                        <div>
                          <div>Premium Coffee Beans</div>
                          <div class="po-status low-stock">Low Stock: 15 kg</div>
                        </div>
                      </div>
                    </td>
                    <td>Rs. 3,200</td>
                    <td>
                      <div class="po-quantity-input">
                        <div class="po-quantity-btn" onclick="updateQuantity(this, -1)">-</div>
                        <input type="number" value="10" min="1" onchange="updateRowTotal(this)">
                        <div class="po-quantity-btn" onclick="updateQuantity(this, 1)">+</div>
                      </div>
                    </td>
                    <td>Rs. 32,000</td>
                    <td>
                      <button class="po-action-btn" onclick="removeRow(this)">❌</button>
                    </td>
                  </tr>
                  <tr>
                    <td>
                      <div class="po-product-row">
                        <div class="po-product-image"></div>
                        <div>
                          <div>Organic Decaf Beans</div>
                          <div class="po-status out-of-stock">Out of Stock</div>
                        </div>
                      </div>
                    </td>
                    <td>Rs. 3,800</td>
                    <td>
                      <div class="po-quantity-input">
                        <div class="po-quantity-btn" onclick="updateQuantity(this, -1)">-</div>
                        <input type="number" value="5" min="1" onchange="updateRowTotal(this)">
                        <div class="po-quantity-btn" onclick="updateQuantity(this, 1)">+</div>
                      </div>
                    </td>
                    <td>Rs. 19,000</td>
                    <td>
                      <button class="po-action-btn" onclick="removeRow(this)">❌</button>
                    </td>
                  </tr>
                  <tr>
                    <td>
                      <div class="po-product-row">
                        <div class="po-product-image"></div>
                        <div>
                          <div>Flavored Syrup - Vanilla</div>
                          <div class="po-status in-stock">In Stock: 42 bottles</div>
                        </div>
                      </div>
                    </td>
                    <td>Rs. 850</td>
                    <td>
                      <div class="po-quantity-input">
                        <div class="po-quantity-btn" onclick="updateQuantity(this, -1)">-</div>
                        <input type="number" value="12" min="1" onchange="updateRowTotal(this)">
                        <div class="po-quantity-btn" onclick="updateQuantity(this, 1)">+</div>
                      </div>
                    </td>
                    <td>Rs. 10,200</td>
                    <td>
                      <button class="po-action-btn" onclick="removeRow(this)">❌</button>
                    </td>
                  </tr>
                </tbody>
              </table>
              
              <button class="po-add-product-btn" onclick="showAddProductDialog()">
                <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                  <line x1="12" y1="5" x2="12" y2="19"></line>
                  <line x1="5" y1="12" x2="19" y2="12"></line>
                </svg>
                Add Product
              </button>
            </div>
            
            <div class="po-form-group">
              <label for="notes">Notes / Instructions</label>
              <textarea id="notes" placeholder="Any special instructions for the supplier..."></textarea>
            </div>
          </div>
        </div>
        
        <!-- Right Panel - Order Summary -->
        <div class="po-right-panel">
          <div class="po-panel-header">
            Order Summary
          </div>
          <div class="po-panel-content">
            <div class="po-summary-item">
              <div class="po-summary-label">Subtotal</div>
              <div class="po-summary-value">Rs. 61,200</div>
            </div>
            <div class="po-summary-item">
              <div class="po-summary-label">Discount</div>
              <div class="po-summary-value">Rs. 0</div>
            </div>
            <div class="po-summary-item">
              <div class="po-summary-label">Tax (15%)</div>
              <div class="po-summary-value">Rs. 9,180</div>
            </div>
            <div class="po-summary-item">
              <div class="po-summary-label">Shipping</div>
              <div class="po-summary-value">Rs. 1,500</div>
            </div>
            <div class="po-summary-item">
              <div class="po-summary-label po-total">Total</div>
              <div class="po-summary-value po-total">Rs. 71,880</div>
            </div>
            
            <div class="po-actions">
              <button class="po-primary-btn" onclick="submitPurchaseOrder()">Submit Order</button>
              <button class="po-secondary-btn" onclick="saveDraft()">Save Draft</button>
            </div>
            
            <p class="po-note">Note: This purchase order will be sent to the supplier once submitted.</p>
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
    
    // Function to update quantity
    function updateQuantity(btn, change) {
      const input = btn.parentNode.querySelector('input');
      let value = parseInt(input.value) + change;
      if (value < 1) value = 1;
      input.value = value;
      updateRowTotal(input);
    }
    
    // Function to update row total
    function updateRowTotal(input) {
      const row = input.closest('tr');
      const unitPrice = parseInt(row.cells[1].textContent.replace(/[^\d]/g, ''));
      const quantity = parseInt(input.value);
      const total = unitPrice * quantity;
      row.cells[3].textContent = 'Rs. ' + total.toLocaleString();
      updateOrderSummary();
    }
    
    // Function to remove a row
    function removeRow(btn) {
      const row = btn.closest('tr');
      row.remove();
      updateOrderSummary();
    }
    
    // Function to update order summary
    function updateOrderSummary() {
      let subtotal = 0;
      document.querySelectorAll('.po-products-table tbody tr').forEach(row => {
        const totalText = row.cells[3].textContent;
        const total = parseInt(totalText.replace(/[^\d]/g, ''));
        subtotal += total;
      });
      
      const tax = Math.round(subtotal * 0.15);
      const shipping = 1500;
      const total = subtotal + tax + shipping;
      
      document.querySelector('.po-summary-item:nth-child(1) .po-summary-value').textContent = 'Rs. ' + subtotal.toLocaleString();
      document.querySelector('.po-summary-item:nth-child(3) .po-summary-value').textContent = 'Rs. ' + tax.toLocaleString();
      document.querySelector('.po-summary-item:nth-child(5) .po-summary-value').textContent = 'Rs. ' + total.toLocaleString();
    }
    
    // Function to show add product dialog
    function showAddProductDialog() {
      alert('This would open a product selection dialog in the full application.');
    }
    
    // Function to submit purchase order
    function submitPurchaseOrder() {
      alert('Purchase Order submitted successfully! The order has been sent to Global Coffee Co.');
      // In a real application, this would submit the form to the server
    }
    
    // Function to save draft
    function saveDraft() {
      alert('Purchase Order saved as draft.');
      // In a real application, this would save the current state
    }
  </script>
</body>
</html>
