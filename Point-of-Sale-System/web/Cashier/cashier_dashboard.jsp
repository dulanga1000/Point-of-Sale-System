<%-- 
    Document   : cashier_dashboard
    Created on : May 4, 2025, 4:20:32 AM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Cashier Dashboard</title>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/5.15.4/css/all.min.css">
  <script src="cscript.js"></script>
  <link rel="Stylesheet" href="styles.css">
  </head>
<body>
  <div class="mobile-top-bar">
    <div class="mobile-logo">
      <img src="../Images/logo.png" alt="POS Logo" class="logo-img">
      <h2>Swift</h2>
    </div>
    <button class="mobile-nav-toggle" id="mobileNavToggle">
      <i class="fas fa-bars"></i>
    </button>
  </div>

  <div class="dashboard">
    <div class="sidebar" id="sidebar">
      <div class="logo">
        <img src="../Images/logo.png" alt="POS Logo" class="logo-img">
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
          <i class="fas fa-sign-out-alt"></i>
          <span>Logout</span>
        </li>
      </ul>
    </div>

    <div class="main-content">
      <div class="header">
        <h1 class="page-title">Cashier Dashboard</h1>
        <div class="user-profile">
          <div class="user-image">
            <img src="../Images/logo.png" alt="User avatar">
          </div>
          <div class="user-info">
            <h4>John Doe</h4>
            <p>Cashier</p>
          </div>
        </div>
      </div>

      <div class="quick-actions">
        <div class="action-card">
          <div class="action-icon">
            <i class="fas fa-plus-circle" style="color: var(--success);"></i>
          </div>
          <h3 class="action-title">New Sale</h3>
          <p class="action-description">Start a new transaction</p>
        </div>
        <div class="action-card">
          <div class="action-icon">
            <i class="fas fa-history" style="color: var(--primary);"></i>
          </div>
          <h3 class="action-title">Recent Sales</h3>
          <p class="action-description">View recent transactions</p>
        </div>
        <div class="action-card">
          <div class="action-icon">
            <i class="fas fa-search" style="color: var(--secondary);"></i>
          </div>
          <h3 class="action-title">Stock Check</h3>
          <p class="action-description">View available products</p>
        </div>
      </div>

      <div class="modules-container">
        <div class="module-card">
          <div class="module-header">
            <span>Products</span>
            <button class="mobile-nav-toggle" style="display: none;">
              <i class="fas fa-arrow-left"></i>
            </button>
          </div>
          <div class="module-content">
            <div class="product-search">
              <div class="search-bar">
                <input type="text" class="search-input" placeholder="Search products by name or code...">
                <button class="search-btn">
                  <i class="fas fa-search"></i>
                </button>
              </div>
              <div class="category-filters">
                <div class="category-filter active">All</div>
                <div class="category-filter">Food</div>
                <div class="category-filter">Beverages</div>
                <div class="category-filter">Electronics</div>
                <div class="category-filter">Clothing</div>
                <div class="category-filter">Home Goods</div>
              </div>
            </div>
            <div class="product-grid">
              <div class="product-card">
                <div class="product-icon">
                  <i class="fas fa-tshirt"></i>
                </div>
                <h4 class="product-name">T-Shirt</h4>
                <p class="product-price">$19.99</p>
                <div class="stock-info">
                  <i class="fas fa-check-circle"></i>
                  <span>In Stock (45)</span>
                </div>
              </div>
              <div class="product-card">
                <div class="product-icon">
                  <i class="fas fa-mobile-alt"></i>
                </div>
                <h4 class="product-name">Smartphone Cover</h4>
                <p class="product-price">$12.99</p>
                <div class="stock-info">
                  <i class="fas fa-check-circle"></i>
                  <span>In Stock (32)</span>
                </div>
              </div>
              <div class="product-card">
                <div class="product-icon">
                  <i class="fas fa-headphones"></i>
                </div>
                <h4 class="product-name">Headphones</h4>
                <p class="product-price">$49.99</p>
                <div class="stock-info">
                  <i class="fas fa-check-circle"></i>
                  <span>In Stock (18)</span>
                </div>
              </div>
              <div class="product-card">
                <div class="product-icon">
                  <i class="fas fa-coffee"></i>
                </div>
                <h4 class="product-name">Coffee Mug</h4>
                <p class="product-price">$9.99</p>
                <div class="stock-info low">
                  <i class="fas fa-exclamation-circle"></i>
                  <span>Low Stock (5)</span>
                </div>
              </div>
              <div class="product-card">
                <div class="product-icon">
                  <i class="fas fa-book"></i>
                </div>
                <h4 class="product-name">Notebook</h4>
                <p class="product-price">$4.99</p>
                <div class="stock-info">
                  <i class="fas fa-check-circle"></i>
                  <span>In Stock (56)</span>
                </div>
              </div>
              <div class="product-card">
                <div class="product-icon">
                  <i class="fas fa-pen"></i>
                </div>
                <h4 class="product-name">Pen Set</h4>
                <p class="product-price">$7.99</p>
                <div class="stock-info">
                  <i class="fas fa-check-circle"></i>
                  <span>In Stock (42)</span>
                </div>
              </div>
              <div class="product-card">
                <div class="product-icon">
                  <i class="fas fa-glasses"></i>
                </div>
                <h4 class="product-name">Sunglasses</h4>
                <p class="product-price">$24.99</p>
                <div class="stock-info">
                  <i class="fas fa-check-circle"></i>
                  <span>In Stock (15)</span>
                </div>
              </div>
              <div class="product-card">
                <div class="product-icon">
                  <i class="fas fa-utensils"></i>
                </div>
                <h4 class="product-name">Cutlery Set</h4>
                <p class="product-price">$29.99</p>
                <div class="stock-info low">
                  <i class="fas fa-exclamation-circle"></i>
                  <span>Low Stock (3)</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        <div class="module-card">
          <div class="module-header">
            <span>Current Cart</span>
            <button class="clear-cart-btn">Clear Cart</button>
          </div>
          <div class="module-content cart-module">
            <div class="cart-items">
              <p style="text-align: center; padding: 20px;">Cart is empty</p>
            </div>
            <div class="cart-summary">
              <div class="summary-row">
                <span>Subtotal</span>
                <span id="cartSubtotal">$0.00</span>
              </div>
              <div class="summary-row input-row">
                <label for="cartDiscount">Discount (%)</label>
                <div class="input-with-symbol">
                  <input type="number" id="cartDiscount" value="" min="0" max="100" step="0.1" placeholder="0.0">
                  <span>%</span>
                </div>
              </div>
              <div class="summary-row">
                <span>Discount</span>
                <span id="cartDiscountAmount">$0.00 (0%)</span>
              </div>
              <div class="summary-row input-row">
                <label for="cartTaxRate">Tax (%)</label>
                <div class="input-with-symbol">
                  <input type="number" id="cartTaxRate" value="" min="0" step="0.1" placeholder="0">
                  <span>%</span>
                </div>
              </div>
              <div class="summary-row">
                <span>Tax</span>
                <span id="cartTaxAmount">$0.00</span>
              </div>
              <div class="summary-row total">
                <span>Total</span>
                <span id="cartTotal">$0.00</span>
              </div>
              <button class="checkout-btn" id="checkoutBtn">
                Proceed to Checkout
              </button>
            </div>
          </div>
        </div>
      </div>

      <div class="footer">
        Swift © 2025.
      </div>
    </div>
  </div>

<div class="modal" id="paymentModal">
  <div class="modal-content">
    <div class="modal-header">
      <h3>Checkout - Payment</h3>
      <button class="close-modal" id="closeModal">
        <i class="fas fa-times"></i>
      </button>
    </div>
    <div class="modal-body">
      <h4 id="paymentModalTotal">Total Amount: $0.00</h4>
      <div class="payment-options">
        <div class="payment-option active" data-method="cash">
          <i class="fas fa-money-bill-wave"></i>
          <span>Cash</span>
        </div>
        <div class="payment-option" data-method="card">
          <i class="fas fa-credit-card"></i>
          <span>Card</span>
        </div>
        <div class="payment-option" data-method="digital">
          <i class="fas fa-mobile-alt"></i>
          <span>Digital Payment</span>
        </div>
      </div>

      <div class="payment-form cash-form active">
        <div class="form-group">
          <label for="cashAmount">Cash Received</label>
          <div class="input-with-icon">
            <span class="currency-symbol">$</span>
            <input type="number" id="cashAmount" placeholder="Enter amount" min="0" step="0.01">
          </div>
        </div>
        <div class="form-group">
          <label>Change Due</label>
          <div class="change-amount" id="changeAmountDisplay">$0.00</div>
        </div>
      </div>

      <div class="payment-form card-form">
        <div class="form-group">
          <label for="cardNumber">Card Number</label>
          <input type="text" id="cardNumber" placeholder="XXXX XXXX XXXX XXXX">
        </div>
        <div class="form-row">
          <div class="form-group half">
            <label for="expiryDate">Expiry Date</label>
            <input type="text" id="expiryDate" placeholder="MM/YY">
          </div>
          <div class="form-group half">
            <label for="cvvCode">CVV</label>
            <input type="text" id="cvvCode" placeholder="XXX">
          </div>
        </div>
        <div class="form-group">
          <label for="cardHolderName">Cardholder Name</label>
          <input type="text" id="cardHolderName" placeholder="Enter name as on card">
        </div>
      </div>

      <div class="payment-form digital-form">
        <div class="qr-code-container">
          <img src="https://api.qrserver.com/v1/create-qr-code/?size=150x150&data=Example" alt="QR Code" class="qr-code">
        </div>
        <p class="qr-instruction">Scan QR code with your payment app</p>
        <div class="digital-options">
          <div class="digital-option">
            <i class="fab fa-apple-pay"></i>
          </div>
          <div class="digital-option">
            <i class="fab fa-google-pay"></i>
          </div>
          <div class="digital-option">
            <i class="fas fa-qrcode"></i>
          </div>
        </div>
      </div>
    </div>
    <div class="modal-footer">
      <button class="cancel-btn">Cancel</button>
      <button class="confirm-btn">Complete Payment</button>
    </div>
  </div>
</div>

<div class="modal" id="receiptModal">
  <div class="modal-content">
    <div class="modal-header">
      <h3>Receipt</h3>
      <button class="close-modal" id="closeReceiptModal">
        <i class="fas fa-times"></i>
      </button>
    </div>
    <div class="modal-body">
      <div class="receipt-container">
        <div class="receipt-header">
            <div class="store-logo" id="store-logo">
            <img src="../Images/logo.png" alt="POS Logo" class="logo-img">
          </div>
          <h2>Swift POS Store</h2> <p>123/2, High level Road, Homagama.</p>
          <p>Tel: (+94) 76-2375055</p>
        </div>
        <div class="receipt-details">
          <div class="receipt-row">
            <span>Receipt #:</span>
            <span id="receiptNumber">INV-YYYYMMDD-XXX</span>
          </div>
          <div class="receipt-row">
            <span>Date:</span>
            <span id="receiptDate">Month DD, YYYY HH:MM AM/PM</span>
          </div>
          <div class="receipt-row">
            <span>Cashier:</span>
            <span>John Doe</span> </div>
        </div>
        <div class="receipt-items">
          <div class="receipt-item-header">
            <span class="item-name">Item</span>
            <span class="item-qty">Qty</span>
            <span class="item-price">Price</span>
          </div>
          </div>
        <div class="receipt-summary">
          <div class="receipt-row">
            <span>Subtotal:</span>
            <span id="receiptSubtotal">$0.00</span>
          </div>
          <div class="receipt-row">
            <span>Discount:</span>
            <span id="receiptDiscount">$0.00</span>
          </div>
          <div class="receipt-row">
            <span>Tax:</span>
            <span id="receiptTax">$0.00</span>
          </div>
          <div class="receipt-row total">
            <span>Total:</span>
            <span id="receiptTotal">$0.00</span>
          </div>
          </div>
        <div class="receipt-footer">
          <p>Thank you for shopping with us!</p>
          <p>Return policy: Items can be returned within 30 days with receipt</p>
          <div class="barcode">
             <img src="https://barcode.tec-it.com/barcode.ashx?data=123456789012&code=Code128&translate-esc=on" alt="Barcode" style="height: 50px;">
          </div>
        </div>
      </div>
    </div>
    <div class="modal-footer">
      <button class="print-btn">
        <i class="fas fa-print"></i> Print Receipt
      </button>
      <button class="email-btn">
        <i class="fas fa-envelope"></i> Email Receipt
      </button>
    </div>
  </div>
</div>

<script src="cscript.js"></script>

</body>
</html>