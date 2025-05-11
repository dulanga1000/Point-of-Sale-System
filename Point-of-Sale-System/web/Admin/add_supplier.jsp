<%-- 
    Document   : add_supplier
    Created on : May 11, 2025, 1:28:12 PM
    Author     : dulan
--%>

<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Add Supplier - Swift POS</title>
  <style>
    * {
      margin: 0;
      padding: 0;
      box-sizing: border-box;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }

    :root {
      --primary: #2563eb;
      --primary-dark: #1d4ed8;
      --secondary: #64748b;
      --light: #f1f5f9;
      --dark: #1e293b;
      --success: #10b981;
      --warning: #f59e0b;
      --danger: #ef4444;
    }

    body {
      background-color: #f8fafc;
      color: var(--dark);
      padding: 20px;
    }

    .module-card {
      background-color: white;
      border-radius: 8px;
      box-shadow: 0 2px 5px rgba(0, 0, 0, 0.05);
      overflow: hidden;
      max-width: 900px;
      margin: 20px auto;
    }

    .module-header {
      padding: 15px 20px;
      background-color: var(--primary);
      color: white;
      font-weight: 600;
      font-size: 18px;
    }

    .module-content {
      padding: 20px;
    }

    .form-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 20px;
      margin-bottom: 20px;
    }

    .form-group {
      margin-bottom: 15px;
    }

    .form-group.full-width {
      grid-column: span 2;
    }

    .form-group label {
      display: block;
      margin-bottom: 8px;
      font-weight: 500;
      color: var(--dark);
    }

    .form-control {
      width: 100%;
      padding: 10px 12px;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      font-size: 14px;
      transition: border-color 0.2s;
    }

    .form-control:focus {
      outline: none;
      border-color: var(--primary);
      box-shadow: 0 0 0 2px rgba(37, 99, 235, 0.1);
    }

    textarea.form-control {
      min-height: 100px;
      resize: vertical;
    }

    .form-actions {
      display: flex;
      justify-content: flex-end;
      gap: 15px;
      margin-top: 20px;
      border-top: 1px solid #f1f5f9;
      padding-top: 20px;
    }

    .btn {
      padding: 10px 20px;
      border-radius: 6px;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;
      font-size: 14px;
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
      background-color: #e2e8f0;
      color: var(--dark);
    }

    .btn-secondary:hover {
      background-color: #cbd5e1;
    }

    .form-help {
      font-size: 12px;
      color: var(--secondary);
      margin-top: 4px;
    }

    .form-section {
      margin-bottom: 25px;
    }

    .form-section-title {
      font-weight: 600;
      font-size: 16px;
      margin-bottom: 15px;
      padding-bottom: 8px;
      border-bottom: 1px solid #f1f5f9;
    }

    .tag-container {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
      margin-top: 10px;
    }

    .tag {
      background-color: #f1f5f9;
      border-radius: 20px;
      padding: 5px 12px;
      font-size: 12px;
      display: flex;
      align-items: center;
      gap: 5px;
    }

    .tag-remove {
      cursor: pointer;
      font-weight: bold;
    }

    /* Responsive adjustments */
    @media (max-width: 768px) {
      .form-grid {
        grid-template-columns: 1fr;
      }
      
      .form-group.full-width {
        grid-column: span 1;
      }
      
      .form-actions {
        flex-direction: column;
      }
      
      .btn {
        width: 100%;
      }
    }

    .form-note {
      background-color: #f8fafc;
      border-left: 4px solid var(--primary);
      padding: 12px 15px;
      margin-bottom: 20px;
      border-radius: 0 6px 6px 0;
      font-size: 14px;
    }

    .credit-terms {
      display: none;
    }

    .credit-terms.active {
      display: block;
      animation: fadeIn 0.3s;
    }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(-10px); }
      to { opacity: 1; transform: translateY(0); }
    }
  </style>
</head>
<body>
  <div class="module-card">
    <div class="module-header">
      Add New Supplier
    </div>
    <div class="module-content">
      <div class="form-note">
        Complete all required fields (*) to register a new supplier in the system.
      </div>
      
      <form id="addSupplierForm">
        <!-- Company Information -->
        <div class="form-section">
          <h3 class="form-section-title">Company Information</h3>
          <div class="form-grid">
            <div class="form-group">
              <label for="companyName">Company Name *</label>
              <input type="text" id="companyName" class="form-control" required>
            </div>
            
            <div class="form-group">
              <label for="supplierCategory">Category *</label>
              <select id="supplierCategory" class="form-control" required>
                <option value="">Select Category</option>
                <option value="beverages">Beverages</option>
                <option value="dairy">Dairy</option>
                <option value="packaging">Packaging</option>
                <option value="ingredients">Ingredients</option>
                <option value="equipment">Equipment</option>
                <option value="other">Other</option>
              </select>
            </div>
            
            <div class="form-group">
              <label for="businessRegNo">Business Registration No. *</label>
              <input type="text" id="businessRegNo" class="form-control" required>
            </div>
            
            <div class="form-group">
              <label for="taxId">Tax ID</label>
              <input type="text" id="taxId" class="form-control">
            </div>
            
            <div class="form-group full-width">
              <label for="companyAddress">Company Address *</label>
              <textarea id="companyAddress" class="form-control" required></textarea>
            </div>
          </div>
        </div>
        
        <!-- Contact Information -->
        <div class="form-section">
          <h3 class="form-section-title">Primary Contact</h3>
          <div class="form-grid">
            <div class="form-group">
              <label for="contactPerson">Contact Person *</label>
              <input type="text" id="contactPerson" class="form-control" required>
            </div>
            
            <div class="form-group">
              <label for="contactPosition">Position</label>
              <input type="text" id="contactPosition" class="form-control">
            </div>
            
            <div class="form-group">
              <label for="contactPhone">Phone Number *</label>
              <input type="tel" id="contactPhone" class="form-control" required>
              <div class="form-help">Format: +94 7X XXX XXXX</div>
            </div>
            
            <div class="form-group">
              <label for="contactEmail">Email *</label>
              <input type="email" id="contactEmail" class="form-control" required>
            </div>
          </div>
        </div>
        
        <!-- Payment & Terms -->
        <div class="form-section">
          <h3 class="form-section-title">Payment & Terms</h3>
          <div class="form-grid">
            <div class="form-group">
              <label for="paymentMethod">Preferred Payment Method *</label>
              <select id="paymentMethod" class="form-control" required>
                <option value="">Select Payment Method</option>
                <option value="bank_transfer">Bank Transfer</option>
                <option value="cash">Cash</option>
                <option value="cheque">Cheque</option>
                <option value="credit_card">Credit Card</option>
              </select>
            </div>
            
            <div class="form-group">
              <label for="paymentTerms">Payment Terms *</label>
              <select id="paymentTerms" class="form-control" required onchange="toggleCreditTerms()">
                <option value="">Select Payment Terms</option>
                <option value="immediate">Immediate Payment</option>
                <option value="cod">Cash on Delivery</option>
                <option value="7days">Net 7</option>
                <option value="15days">Net 15</option>
                <option value="30days">Net 30</option>
                <option value="credit">Credit Line</option>
              </select>
            </div>
            
            <div id="creditTerms" class="form-group full-width credit-terms">
              <label for="creditLimit">Credit Limit (Rs.)</label>
              <input type="number" id="creditLimit" class="form-control" min="0" step="1000">
              <div class="form-help">Maximum credit amount allowed for this supplier</div>
            </div>
            
            <div class="form-group">
              <label for="deliveryTerms">Delivery Terms *</label>
              <select id="deliveryTerms" class="form-control" required>
                <option value="">Select Delivery Terms</option>
                <option value="supplier_delivery">Supplier Delivery</option>
                <option value="pickup">Store Pickup</option>
                <option value="third_party">Third Party Logistics</option>
              </select>
            </div>
            
            <div class="form-group">
              <label for="leadTime">Average Lead Time (Days) *</label>
              <input type="number" id="leadTime" class="form-control" min="1" required>
              <div class="form-help">Average time from order to delivery</div>
            </div>
          </div>
        </div>
        
        <!-- Products & Services -->
        <div class="form-section">
          <h3 class="form-section-title">Products & Services</h3>
          <div class="form-grid">
            <div class="form-group full-width">
              <label for="productCategories">Product Categories *</label>
              <input type="text" id="productCategories" class="form-control" placeholder="Type a category and press Enter">
              <div class="form-help">Enter product categories this supplier provides (e.g., Coffee Beans, Milk, Cups)</div>
              <div class="tag-container" id="categoryTags">
                <!-- Tags will be added here -->
              </div>
            </div>
            
            <div class="form-group full-width">
              <label for="additionalNotes">Additional Notes</label>
              <textarea id="additionalNotes" class="form-control" placeholder="Any additional information about this supplier..."></textarea>
            </div>
          </div>
        </div>
        
        <div class="form-actions">
          <button type="button" class="btn btn-secondary" onclick="window.history.back()">Cancel</button>
          <button type="submit" class="btn btn-primary">Save Supplier</button>
        </div>
      </form>
    </div>
  </div>

  <script>
    // Toggle credit terms section
    function toggleCreditTerms() {
      const paymentTerms = document.getElementById('paymentTerms').value;
      const creditTerms = document.getElementById('creditTerms');
      
      if (paymentTerms === 'credit') {
        creditTerms.classList.add('active');
        document.getElementById('creditLimit').setAttribute('required', 'required');
      } else {
        creditTerms.classList.remove('active');
        document.getElementById('creditLimit').removeAttribute('required');
      }
    }
    
    // Handle product categories tags
    document.getElementById('productCategories').addEventListener('keydown', function(e) {
      if (e.key === 'Enter') {
        e.preventDefault();
        const value = this.value.trim();
        if (value) {
          addCategoryTag(value);
          this.value = '';
        }
      }
    });
    
    function addCategoryTag(text) {
      const tagsContainer = document.getElementById('categoryTags');
      const tag = document.createElement('div');
      tag.className = 'tag';
      tag.innerHTML = `${text} <span class="tag-remove" onclick="removeTag(this)">✕</span>`;
      tagsContainer.appendChild(tag);
    }
    
    function removeTag(element) {
      element.parentElement.remove();
    }
    
    // Form submission handling
    document.getElementById('addSupplierForm').addEventListener('submit', function(e) {
      e.preventDefault();
      // Normally would validate and submit to server
      alert('Supplier information would be saved to the database.');
    });
    
    // Add some sample tags for demonstration
    window.onload = function() {
      const sampleCategories = ['Coffee Beans', 'Sugar', 'Flavoring Syrups'];
      sampleCategories.forEach(category => addCategoryTag(category));
    };
  </script>
</body>
</html>