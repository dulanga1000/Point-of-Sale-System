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
<%@ page import="java.text.SimpleDateFormat" %>

<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Stock Adjustment - Swift POS</title>
  <link rel="Stylesheet" href="styles.css"> <%-- Ensure styles.css is available and correctly pathed --%>
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
    
    /* Simplified quantity display without buttons */
    .current-stock-display {
      margin-top: 10px;
      padding: 8px 12px;
      background-color: #f1f5f9;
      border-radius: 4px;
      font-size: 14px;
      color: var(--dark);
      display: inline-block;
    }
    
    /* Add styles for adjustment type buttons */
    .adjustment-type-selector {
      display: flex;
      margin-bottom: 15px;
    }
    
    .adjustment-type-btn {
      flex: 1;
      padding: 10px;
      text-align: center;
      border: 1px solid #e2e8f0;
      background-color: #f8fafc;
      cursor: pointer;
      font-weight: 500;
      transition: all 0.2s ease;
    }
    
    .adjustment-type-btn:first-child {
      border-top-left-radius: 6px;
      border-bottom-left-radius: 6px;
    }
    
    .adjustment-type-btn:last-child {
      border-top-right-radius: 6px;
      border-bottom-right-radius: 6px;
    }
    
    .adjustment-type-btn.active {
      background-color: var(--primary);
      color: white;
      border-color: var(--primary);
    }
  </style>
</head>
<body>
  <%
    // Database connection details
    String DB_URL = "jdbc:mysql://localhost:3306/Swift_Database"; 
    String DB_USER = "root"; 
    String DB_PASSWORD = ""; 
  %>

  <div class="mobile-top-bar">
    <div class="mobile-logo">
      <img src="${pageContext.request.contextPath}/Images/logo.png" alt="POS Logo">
      <h2>Swift</h2>
    </div>
    <button class="mobile-nav-toggle" id="mobileNavToggle" aria-label="Toggle Navigation">☰</button>
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
          <img src="${pageContext.request.contextPath}/Images/logo.png" alt="Admin Profile"> <%-- Consider dynamic path or fallback --%>
          <div>
            <h4>Admin User</h4> <%-- TODO: Make dynamic from session --%>
          </div>
        </div>
      </div>
      
      <% 
        String message = request.getParameter("message");
        String messageType = request.getParameter("type");
        
        if (message != null && !message.isEmpty()) {
      %>
        <div class="message <%= "error".equals(messageType) ? "message-error" : "message-success" %>">
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
                Connection connProducts = null;
                PreparedStatement psProducts = null;
                ResultSet rsProducts = null;
                try {
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    connProducts = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                    
                    // MODIFIED Query for products table
                    String productQuery = "SELECT id, name, sku, stock, category FROM products ORDER BY name ASC";
                    psProducts = connProducts.prepareStatement(productQuery);
                    rsProducts = psProducts.executeQuery();
                    
                    while (rsProducts.next()) {
              %>
              <option value="<%= rsProducts.getInt("id") %>" 
                      data-sku="<%= rsProducts.getString("sku") != null ? rsProducts.getString("sku") : "N/A" %>" 
                      data-stock="<%= rsProducts.getInt("stock") %>" 
                      data-category="<%= rsProducts.getString("category") != null ? rsProducts.getString("category") : "N/A" %>">
                <%= rsProducts.getString("name") %> <%= rsProducts.getString("sku") != null ? "("+rsProducts.getString("sku")+")" : "" %>
              </option>
              <% 
                    }
                } catch (Exception e) {
                    out.println("<option value=''>Error: " + e.getMessage() + "</option>");
                    // For debugging: e.printStackTrace(new java.io.PrintWriter(out));
                } finally {
                    if (rsProducts != null) try { rsProducts.close(); } catch (SQLException e) {}
                    if (psProducts != null) try { psProducts.close(); } catch (SQLException e) {}
                    if (connProducts != null) try { connProducts.close(); } catch (SQLException e) {}
                }
              %>
            </select>
          </div>
          
          <div id="selectedProductContainer" style="display: none;" class="selected-product">
            <div class="selected-product-name" id="selectedProductName">Product Name</div>
            <div class="selected-product-details">
              <div class="selected-product-detail">SKU: <span id="selectedProductSKU"></span></div>
              <div class="selected-product-detail">Current Stock: <span id="selectedProductStock"></span></div>
              <div class="selected-product-detail">Category: <span id="selectedProductCategory"></span></div>
            </div>
          </div>
          
          <div class="form-grid">
            <!-- Add adjustment type selector -->
            <div class="form-group">
              <label>Adjustment Type:</label>
              <div class="adjustment-type-selector">
                <div class="adjustment-type-btn active" id="increaseBtn" onclick="setAdjustmentType('increase')">Increase Stock</div>
                <div class="adjustment-type-btn" id="decreaseBtn" onclick="setAdjustmentType('decrease')">Decrease Stock</div>
              </div>
              <!-- Hidden input for adjustment type -->
              <input type="hidden" name="adjustmentType" id="adjustmentTypeInput" value="increase">
              
              <!-- Hidden input for auto-generated reference number -->
              <input type="hidden" name="reference" id="reference">
            </div>

            <div class="form-group">
              <label for="quantity">Quantity:</label>
              <input type="number" id="quantity" name="quantity" class="form-control" min="1" value="1" required>
              <div class="current-stock-display" id="quantityStockDisplay">New Stock: <span id="currentStockValue">0</span></div>
            </div>
            
            <div class="form-group">
              <label for="reason">Reason:</label>
              <select name="reason" id="reason" class="form-select" required>
                <option value="">-- Select reason --</option>
                <option value="Purchase Receipt">Purchase Receipt</option> <option value="Customer Return">Customer Return</option>
                <option value="Damaged Goods">Damaged Goods</option>
                <option value="Expired Goods">Expired Goods</option>
                <option value="Stock Count Correction">Stock Count Correction</option>
                <option value="Internal Transfer">Internal Transfer</option>
                <option value="Initial Stock Setup">Initial Stock Setup</option>
                <option value="Return to Supplier">Return to Supplier</option>
                <option value="Other Adjustment">Other Adjustment</option>
              </select>
            </div>
            
            <div class="form-group form-grid-full">
              <label for="notes">Notes (Optional):</label>
              <textarea id="notes" name="notes" class="form-control" rows="3" placeholder="Additional information for this adjustment"></textarea>
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
                <th>Qty Change</th>
                <th>Notes/Reason</th>
                <th>Reference</th>
                <th>User</th>
              </tr>
            </thead>
            <tbody>
            <% 
              Connection connHistory = null;
              PreparedStatement psHistory = null;
              ResultSet rsHistory = null;
              SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");

              try {
                  Class.forName("com.mysql.cj.jdbc.Driver");
                  connHistory = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
                  
                  // MODIFIED query for inventory_movements
                  String historyQuery = "SELECT im.movement_date, p.name as product_name, p.sku as product_sku, " +
                                        "im.movement_type, im.quantity_change, im.notes, im.reference_id, u.username " +
                                        "FROM inventory_movements im " +
                                        "JOIN products p ON im.product_id = p.id " +
                                        "LEFT JOIN users u ON im.user_id = u.id " + // LEFT JOIN in case user is null
                                        // Filter for types that are typically manual adjustments or relevant here
                                        "WHERE im.movement_type LIKE '%adjustment%' OR im.movement_type IN ('damaged_goods', 'expired_goods', 'initial_stock_setup', 'others', 'return_from_customer', 'return_to_supplier') " + 
                                        "ORDER BY im.movement_date DESC LIMIT 10";
                  psHistory = connHistory.prepareStatement(historyQuery);
                  rsHistory = psHistory.executeQuery();
                  
                  boolean hasAdjustments = false;
                  while (rsHistory.next()) {
                      hasAdjustments = true;
                      String movementTypeDb = rsHistory.getString("movement_type");
                      double qtyChange = rsHistory.getDouble("quantity_change");
                      String displayType;
                      String typeClass = "status other"; // Default

                      // Interpret movement_type for display
                      if ("stock_adjustment_add".equalsIgnoreCase(movementTypeDb) || qtyChange > 0) {
                          displayType = "Stock Adj. (Add)";
                          typeClass = "status completed"; // Green for increase
                      } else if ("stock_adjustment_subtract".equalsIgnoreCase(movementTypeDb) || qtyChange < 0) {
                          displayType = "Stock Adj. (Subtract)";
                          typeClass = "status pending"; // Red for decrease
                      } else if ("damaged_goods".equalsIgnoreCase(movementTypeDb)) {
                          displayType = "Damaged";
                           typeClass = "status pending";
                      } else if ("expired_goods".equalsIgnoreCase(movementTypeDb)) {
                          displayType = "Expired";
                           typeClass = "status pending";
                      } else if ("initial_stock_setup".equalsIgnoreCase(movementTypeDb)) {
                          displayType = "Initial Setup";
                          typeClass = "status completed";
                      } else if ("return_from_customer".equalsIgnoreCase(movementTypeDb)) {
                          displayType = "Cust. Return";
                           typeClass = "status completed";
                      } else if ("return_to_supplier".equalsIgnoreCase(movementTypeDb)) {
                          displayType = "Supp. Return";
                           typeClass = "status pending";
                      } else {
                          displayType = movementTypeDb.replace("_", " ").toUpperCase(); // Generic display
                      }

            %>
              <tr>
                <td><%= sdf.format(rsHistory.getTimestamp("movement_date")) %></td>
                <td><%= rsHistory.getString("product_name") %> (<%= rsHistory.getString("product_sku") != null ? rsHistory.getString("product_sku") : "N/A" %>)</td>
                <td><span class="<%= typeClass %>"><%= displayType %></span></td>
                <td><%= String.format("%.2f", qtyChange) %></td>
                <td><%= rsHistory.getString("notes") != null ? rsHistory.getString("notes") : "-" %></td>
                <td><%= rsHistory.getString("reference_id") != null ? rsHistory.getString("reference_id") : "-" %></td>
                <td><%= rsHistory.getString("username") != null ? rsHistory.getString("username") : "N/A" %></td>
              </tr>
            <% 
                  }
                  if (!hasAdjustments) {
            %>
              <tr><td colspan="7" style="text-align: center;">No recent stock adjustments found.</td></tr>
            <% 
                  }
              } catch (Exception e) {
                  out.println("<tr><td colspan='7' style='text-align:center; color:red;'>Error: " + e.getMessage() + "</td></tr>");
                  // For debugging: e.printStackTrace(new java.io.PrintWriter(out));
              } finally {
                  if (rsHistory != null) try { rsHistory.close(); } catch (SQLException e) {}
                  if (psHistory != null) try { psHistory.close(); } catch (SQLException e) {}
                  if (connHistory != null) try { connHistory.close(); } catch (SQLException e) {}
              }
            %>
            </tbody>
          </table>
        </div>
      </div>
      
      <div class="footer">
        Swift © <%= java.time.Year.now().getValue() %>.
      </div>
    </div>
  </div>

  <script>
    // Mobile navigation toggle (if not in separate script.js)
    const mobileNavToggle = document.getElementById('mobileNavToggle');
    const sidebar = document.getElementById('sidebar');
    if (mobileNavToggle && sidebar) {
        mobileNavToggle.addEventListener('click', () => sidebar.classList.toggle('active'));
    }
    document.addEventListener('click', function(event) {
        if (sidebar && sidebar.classList.contains('active') && !sidebar.contains(event.target) && !mobileNavToggle.contains(event.target)) {
            sidebar.classList.remove('active');
        }
    });

    // Stock Adjustment Page Specific JavaScript
    const productSelect = document.getElementById('productSelect');
    const selectedProductContainer = document.getElementById('selectedProductContainer');
    const submitBtn = document.getElementById('submitBtn');
    const adjustmentTypeInput = document.getElementById('adjustmentTypeInput'); // Hidden input for adjustment type
    const quantityInput = document.getElementById('quantity');
    const currentStockValue = document.getElementById('currentStockValue');
    const quantityStockDisplay = document.getElementById('quantityStockDisplay');
    const increaseBtn = document.getElementById('increaseBtn');
    const decreaseBtn = document.getElementById('decreaseBtn');
    const referenceInput = document.getElementById('reference');

    // Current adjustment type (default: increase)
    let currentAdjustmentType = 'increase';

    /**
     * Sets the adjustment type and updates UI accordingly.
     * @param {string} type - The adjustment type ('increase' or 'decrease').
     */
    function setAdjustmentType(type) {
        currentAdjustmentType = type;
        adjustmentTypeInput.value = type;

        // Update button styling
        if (type === 'increase') {
            increaseBtn.classList.add('active');
            decreaseBtn.classList.remove('active');
        } else {
            decreaseBtn.classList.add('active');
            increaseBtn.classList.remove('active');
        }

        // Update reference number
        generateReference();

        // Update projected stock display
        updateProjectedStock();
    }

    /**
     * Generates a completely random reference number.
     * Format: ADJ-RANDOMXXXX (where XXXX is a 4-digit random number)
     */
    function generateReference() {
        // Generate a random 8-digit number
        const random = Math.floor(10000000 + Math.random() * 90000000);
        referenceInput.value = "ADJ-" + random;
    }

    /**
     * Event listener for the product selection dropdown.
     * When a product is selected, it displays the product's details (name, SKU, stock, category)
     * in a dedicated container and enables the 'Save Adjustment' button.
     * If no product is selected, it hides the details container and disables the button.
     */
    productSelect.addEventListener('change', function() {
        if (this.value) { // A product is selected
            const selectedOption = this.options[this.selectedIndex];
            const stockValue = selectedOption.getAttribute('data-stock');

            document.getElementById('selectedProductName').textContent = selectedOption.text.split('(')[0].trim(); // Get name part before SKU
            document.getElementById('selectedProductSKU').textContent = selectedOption.getAttribute('data-sku');
            document.getElementById('selectedProductStock').textContent = stockValue;
            document.getElementById('selectedProductCategory').textContent = selectedOption.getAttribute('data-category');

            // Update the current stock display near quantity
            currentStockValue.textContent = stockValue;

            selectedProductContainer.style.display = 'block'; // Show product details
            quantityStockDisplay.style.display = 'inline-block'; // Show stock display
            submitBtn.disabled = false; // Enable submit button
            updateProjectedStock(); // Update the projected stock immediately
        } else { // "-- Select a product --" is chosen
            selectedProductContainer.style.display = 'none'; // Hide product details
            quantityStockDisplay.style.display = 'none'; // Hide stock display
            submitBtn.disabled = true; // Disable submit button
        }
    });

    // Initialize the page state when loaded
    generateReference();          // Generate initial reference number
    quantityStockDisplay.style.display = 'none'; // Hide stock display initially

    // Add event listener for quantity changes
    quantityInput.addEventListener('input', updateProjectedStock);
    quantityInput.addEventListener('change', updateProjectedStock);

    /**
     * Updates the displayed stock level based on the current adjustment
     * Shows the projected stock after the adjustment is applied
     */
    function updateProjectedStock() {
        if (!productSelect.value) return; // No product selected

        const originalStock = parseInt(document.getElementById('selectedProductStock').textContent) || 0;
        const adjustmentQty = parseInt(quantityInput.value) || 0;

        let projectedStock, displayPrefix;

        if (currentAdjustmentType === 'increase') {
            projectedStock = originalStock + adjustmentQty;
            displayPrefix = "+";
        } else {
            projectedStock = originalStock - adjustmentQty;
            displayPrefix = "-";

            // Check if the adjustment would result in negative stock
            if (projectedStock < 0) {
                currentStockValue.textContent = `Warning: Would result in negative stock (${projectedStock})`;
                currentStockValue.style.color = 'red';
                return;
            }
        }

        // Reset color if it was previously red
        currentStockValue.style.color = '';

        currentStockValue.textContent = originalStock + " → " + projectedStock + " (" + displayPrefix + adjustmentQty + ")";
    }

    /**
     * Event listener for the form submission.
     * Performs client-side validation before allowing the form to be submitted.
     */
    document.getElementById('adjustmentForm').addEventListener('submit', function(e) {
        const productId = productSelect.value;
        const quantity = parseInt(quantityInput.value) || 0;
        const reason = document.getElementById('reason').value;
        const originalStock = parseInt(document.getElementById('selectedProductStock').textContent) || 0;

        if (!productId) {
            e.preventDefault(); // Prevent form submission
            alert('Please select a product.');
            productSelect.focus();
            return;
        }

        // Modified validation to allow quantity of 0 for decrease adjustments
        if ((currentAdjustmentType === 'increase' && quantity < 1) || 
            (currentAdjustmentType === 'decrease' && quantity < 0)) {
            e.preventDefault(); // Prevent form submission
            alert('Please enter a valid quantity.');
            quantityInput.focus();
            return;
        }

        if (!reason) {
            e.preventDefault(); // Prevent form submission
            alert('Please select a reason for this adjustment.');
            document.getElementById('reason').focus();
            return;
        }

        // Check if there's enough stock for decrease adjustments
        if (currentAdjustmentType === 'decrease') {
            if (quantity > originalStock) {
                e.preventDefault(); // Prevent form submission
                alert('Cannot decrease more than the current stock level (' + originalStock + ').');
                quantityInput.focus();
                return;
            }
        }
        
        // Generate a new reference number before submitting
        generateReference();
    });
  </script>
</body>
</html>