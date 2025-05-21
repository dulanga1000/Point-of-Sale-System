<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Add Supplier - Swift POS</title>
  <style>
    /* --- Keep all your existing CSS here --- */
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
      padding: 8px; /* Add some padding */
      border: 1px solid #e2e8f0; /* Add border */
      border-radius: 6px; /* Match input border radius */
      min-height: 40px; /* Ensure it has some height even when empty */
    }

    .tag {
      background-color: #e0e7ff; /* Lighter primary color */
      color: #3730a3; /* Darker primary color text */
      border-radius: 15px; /* More rounded */
      padding: 5px 12px;
      font-size: 13px; /* Slightly larger */
      font-weight: 500;
      display: flex;
      align-items: center;
      gap: 6px;
      cursor: default;
    }

    .tag span:first-child {
        margin-right: 5px;
    }

    .tag-remove {
      cursor: pointer;
      font-weight: bold;
      color: #64748b; /* Secondary color */
      padding: 0 3px;
      border-radius: 50%; /* Make it round */
      line-height: 1; /* Adjust line height */
      transition: background-color 0.2s, color 0.2s;
    }
    .tag-remove:hover {
        color: white;
        background-color: var(--danger);
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
      background-color: #eff6ff;
      border-left: 4px solid var(--primary);
      padding: 12px 15px;
      margin-bottom: 20px;
      border-radius: 0 6px 6px 0;
      font-size: 14px;
      color: #1e40af;
    }

    /* Feedback message styling */
    .form-feedback {
        padding: 12px 15px;
        margin-bottom: 20px;
        border-radius: 6px;
        font-size: 14px;
        border-left-width: 4px;
        border-left-style: solid;
        font-weight: 500; /* Make text slightly bolder */
    }
    .form-feedback.success {
        background-color: #f0fdf4;
        border-color: var(--success);
        color: #15803d;
    }
    .form-feedback.error {
        background-color: #fef2f2;
        border-color: var(--danger);
        color: #b91c1c;
    }


    .credit-terms {
      display: none;
    }

    .credit-terms.active {
      display: block;
      animation: fadeIn 0.3s ease-out; /* Added ease-out */
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
      <%-- Display Feedback Messages --%>
      <%
          String status = request.getParameter("status");
          String messageCode = request.getParameter("message");
          String feedbackMessage = "";
          String feedbackClass = "";

          if ("success".equals(status)) {
              feedbackMessage = "Supplier added successfully!";
              feedbackClass = "success";
          } else if ("error".equals(status)) {
              feedbackClass = "error";
              // Define user-friendly messages based on codes from servlet
              if ("MissingRequiredFields".equals(messageCode)) {
                  feedbackMessage = "Error: Please fill in all required fields (*).";
              } else if ("InvalidLeadTime".equals(messageCode)) {
                  feedbackMessage = "Error: Please enter a valid, positive number for Average Lead Time.";
              } else if ("InvalidCreditLimit".equals(messageCode)) {
                  feedbackMessage = "Error: Please enter a valid, non-negative number for Credit Limit.";
              } else if ("MissingCreditLimit".equals(messageCode)) {
                  feedbackMessage = "Error: Credit Limit is required and must be provided when Payment Term is 'Credit Line'.";
              } else if ("DatabaseError".equals(messageCode)) {
                   feedbackMessage = "Error: Could not save supplier to the database. Please check server logs or contact support.";
              } else if ("InvalidCategoryInput".equals(messageCode)){
                  feedbackMessage = "Error: Please add at least one valid product category.";
              }
               else {
                   feedbackMessage = "An unexpected error occurred while saving the supplier."; // Generic fallback
              }
          }

          if (!feedbackMessage.isEmpty()) {
      %>
          <div class="form-feedback <%= feedbackClass %>">
              <%= feedbackMessage %>
          </div>
      <%
          }
      %>

      <div class="form-note">
        Complete all required fields (*) to register a new supplier in the system.
        <%-- Uncomment to debug context path if needed
        <p style="background-color: yellow; padding: 1px;">DEBUG: Context Path=[${pageContext.request.contextPath}]</p>
        --%>
      </div>

      <%-- *** CORE FIX: Use context path for form action *** --%>
      <form id="addSupplierForm" action="${pageContext.request.contextPath}/addSupplier" method="POST">
        <div class="form-section">
          <h3 class="form-section-title">Company Information</h3>
          <div class="form-grid">
            <div class="form-group">
              <label for="companyName">Company Name *</label>
              <input type="text" id="companyName" name="companyName" class="form-control" required>
            </div>

            <div class="form-group">
              <label for="supplierCategory">Category *</label>
              <select id="supplierCategory" name="supplierCategory" class="form-control" required>
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
              <input type="text" id="businessRegNo" name="businessRegNo" class="form-control" required>
            </div>

            <div class="form-group">
              <label for="taxId">Tax ID</label>
              <input type="text" id="taxId" name="taxId" class="form-control">
            </div>

            <div class="form-group full-width">
              <label for="companyAddress">Company Address *</label>
              <textarea id="companyAddress" name="companyAddress" class="form-control" required></textarea>
            </div>
          </div>
        </div>

        <div class="form-section">
          <h3 class="form-section-title">Primary Contact</h3>
          <div class="form-grid">
            <div class="form-group">
              <label for="contactPerson">Contact Person *</label>
              <input type="text" id="contactPerson" name="contactPerson" class="form-control" required>
            </div>

            <div class="form-group">
              <label for="contactPosition">Position</label>
              <input type="text" id="contactPosition" name="contactPosition" class="form-control">
            </div>

            <div class="form-group">
              <label for="contactPhone">Phone Number *</label>
              <%-- Added pattern for basic validation (adjust if needed) --%>
              <input type="tel" id="contactPhone" name="contactPhone" class="form-control" required pattern="\+94\s?[7][0-9]{1}\s?[0-9]{3}\s?[0-9]{4}" title="Format: +94 7X XXX XXXX">
              <div class="form-help">Format: +94 7X XXX XXXX</div>
            </div>

            <div class="form-group">
              <label for="contactEmail">Email *</label>
              <input type="email" id="contactEmail" name="contactEmail" class="form-control" required>
            </div>
          </div>
        </div>

        <div class="form-section">
          <h3 class="form-section-title">Payment & Terms</h3>
          <div class="form-grid">
            <div class="form-group">
              <label for="paymentMethod">Preferred Payment Method *</label>
              <select id="paymentMethod" name="paymentMethod" class="form-control" required>
                <option value="">Select Payment Method</option>
                <option value="bank_transfer">Bank Transfer</option>
                <option value="cash">Cash</option>
                <option value="cheque">Cheque</option>
                <option value="credit_card">Credit Card</option>
              </select>
            </div>

            <div class="form-group">
              <label for="paymentTerms">Payment Terms *</label>
              <select id="paymentTerms" name="paymentTerms" class="form-control" required onchange="toggleCreditTerms()">
                <option value="">Select Payment Terms</option>
                <option value="immediate">Immediate Payment</option>
                <option value="cod">Cash on Delivery</option>
                <option value="7days">Net 7</option>
                <option value="15days">Net 15</option>
                <option value="30days">Net 30</option>
                <option value="credit">Credit Line</option>
              </select>
            </div>

            <%-- Credit Terms section depends on paymentTerms selection --%>
            <div id="creditTerms" class="form-group full-width credit-terms">
              <label for="creditLimit">Credit Limit (Rs.)</label>
              <%-- step=0.01 allows for cents if needed, min=0 prevents negative --%>
              <input type="number" id="creditLimit" name="creditLimit" class="form-control" min="0" step="0.01">
              <div class="form-help">Maximum credit amount allowed (Required if 'Credit Line' is selected)</div>
            </div>

            <div class="form-group">
              <label for="deliveryTerms">Delivery Terms *</label>
              <select id="deliveryTerms" name="deliveryTerms" class="form-control" required>
                <option value="">Select Delivery Terms</option>
                <option value="supplier_delivery">Supplier Delivery</option>
                <option value="pickup">Store Pickup</option>
                <option value="third_party">Third Party Logistics</option>
              </select>
            </div>

            <div class="form-group">
              <label for="leadTime">Average Lead Time (Days) *</label>
              <%-- min=1 ensures positive lead time --%>
              <input type="number" id="leadTime" name="leadTime" class="form-control" min="1" required>
              <div class="form-help">Average time from order to delivery (must be 1 or more)</div>
            </div>
          </div>
        </div>

        <div class="form-section">
          <h3 class="form-section-title">Products & Services</h3>
          <div class="form-grid">
            <div class="form-group full-width">
              <label for="productCategoriesInput">Product Categories *</label>
               <%-- Changed ID slightly to avoid conflict with name --%>
              <input type="text" id="productCategoriesInput" class="form-control" placeholder="Type a category and press Enter">
              <div class="form-help">Enter product categories (e.g., Coffee Beans, Milk), press Enter after each. At least one is required.</div>
              <div class="tag-container" id="categoryTags">
                </div>
              <%-- Hidden input to send the collected tag data --%>
              <input type="hidden" name="hiddenProductCategories" id="hiddenProductCategories">
               <%-- Validation message display area --%>
              <div class="form-help" id="categoryValidationMsg" style="color: var(--danger); display: none; margin-top: 8px;">At least one product category is required.</div>
            </div>

            <div class="form-group full-width">
              <label for="additionalNotes">Additional Notes</label>
              <textarea id="additionalNotes" name="additionalNotes" class="form-control" placeholder="Any special instructions, contact preferences, or other details about this supplier..."></textarea>
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
    // --- Elements ---
    const paymentTermsSelect = document.getElementById('paymentTerms');
    const creditTermsDiv = document.getElementById('creditTerms');
    const creditLimitInput = document.getElementById('creditLimit');
    const categoryInputField = document.getElementById('productCategoriesInput');
    const tagsContainerDiv = document.getElementById('categoryTags');
    const hiddenCategoriesField = document.getElementById('hiddenProductCategories');
    const categoryValidationMsgDiv = document.getElementById('categoryValidationMsg');
    const addSupplierForm = document.getElementById('addSupplierForm');

    // --- Functions ---

    // Toggle visibility and requirement of credit limit field
    function toggleCreditTerms() {
      const isCreditTerm = paymentTermsSelect.value === 'credit';
      if (isCreditTerm) {
        creditTermsDiv.classList.add('active');
        creditLimitInput.setAttribute('required', 'required');
      } else {
        creditTermsDiv.classList.remove('active');
        creditLimitInput.removeAttribute('required');
        // Optional: Clear the value when hiding to avoid submitting old value
        // creditLimitInput.value = '';
      }
    }

    // Adds a new tag element visually
    function addCategoryTag(text) {
       // Prevent adding empty or whitespace-only tags
      const trimmedText = text.trim();
      if (!trimmedText) return;

      // Prevent adding duplicate tags (case-insensitive check)
       const existingTags = Array.from(tagsContainerDiv.querySelectorAll('.tag span:first-child'))
                               .map(span => span.textContent.trim().toLowerCase());
       if (existingTags.includes(trimmedText.toLowerCase())) {
           // alert('Category "' + trimmedText + '" already added.'); // Optional feedback
           categoryInputField.value = ''; // Clear input even if duplicate
           return; // Stop processing if duplicate
       }


      const tag = document.createElement('div');
      tag.className = 'tag';

      // Create span for text content (safer than innerHTML)
      const textSpan = document.createElement('span');
      textSpan.textContent = trimmedText; // Use textContent for safety

      // Create remove button
      const removeSpan = document.createElement('span');
      removeSpan.className = 'tag-remove';
      removeSpan.innerHTML = '&#10005;'; // Use HTML entity for 'x'
      removeSpan.title = 'Remove category'; // Tooltip
      removeSpan.onclick = function() {
          removeTagElement(this.parentElement); // Pass the whole tag element to remove
      };

      tag.appendChild(textSpan);
      tag.appendChild(removeSpan);
      tagsContainerDiv.appendChild(tag);

      // Clear the input field and update hidden data
      categoryInputField.value = '';
      updateHiddenCategories();
      validateCategories(); // Re-validate after adding
    }

    // Removes a tag element visually and updates hidden data
    function removeTagElement(tagElement) {
      tagElement.remove();
      updateHiddenCategories();
      validateCategories(); // Re-validate after removing
    }

    // Updates the hidden input field with current tag values (comma-separated)
    function updateHiddenCategories() {
      const tags = tagsContainerDiv.querySelectorAll('.tag span:first-child');
      const categories = Array.from(tags).map(tag => tag.textContent.trim());
      hiddenCategoriesField.value = categories.join(',');
      // console.log("Hidden categories:", hiddenCategoriesField.value); // For debugging
    }

    // Validates if at least one category tag exists
    function validateCategories() {
        const hasTags = tagsContainerDiv.querySelectorAll('.tag').length > 0;
        if (!hasTags) {
            categoryValidationMsgDiv.style.display = 'block'; // Show error
            // Optionally add a visual cue to the container/input
            categoryInputField.style.borderColor = 'var(--danger)';
            return false; // Indicate validation failure
        } else {
            categoryValidationMsgDiv.style.display = 'none'; // Hide error
             categoryInputField.style.borderColor = '#e2e8f0'; // Reset border
            return true; // Indicate validation success
        }
    }

    // Client-side validation for the credit limit field when required
    function validateCreditLimit() {
        if (paymentTermsSelect.value === 'credit') {
            if (!creditLimitInput.value || parseFloat(creditLimitInput.value) < 0) {
                alert('Credit Limit is required and must be zero or positive when Payment Term is Credit Line.');
                creditLimitInput.focus();
                creditLimitInput.style.borderColor = 'var(--danger)'; // Highlight error
                return false; // Validation failed
            } else {
                 creditLimitInput.style.borderColor = '#e2e8f0'; // Reset border if valid
            }
        }
         return true; // Validation passed (or not applicable)
    }


    // --- Event Listeners ---

    // Add tag when Enter key is pressed in the category input field
    categoryInputField.addEventListener('keydown', function(e) {
      if (e.key === 'Enter') {
        e.preventDefault(); // Prevent form submission on Enter
        addCategoryTag(this.value);
      }
    });

     // Handle form submission: perform final validation
    addSupplierForm.addEventListener('submit', function(e) {
      // 1. Update hidden categories one last time
      updateHiddenCategories();

      // 2. Validate required fields (client-side checks complement server-side)
      let isFormValid = true;

      // Validate product categories
      if (!validateCategories()) {
          isFormValid = false;
      }

      // Validate credit limit if required
      if (!validateCreditLimit()){
           isFormValid = false;
      }

      // Prevent submission if client-side validation fails
      if (!isFormValid) {
          e.preventDefault();
          alert('Please correct the errors highlighted in the form before submitting.');
          console.log('Form submission stopped due to client-side validation errors.');
          return false;
      }

      // If all client-side checks pass, allow the form to submit naturally to the servlet
      console.log('Form submitting...');
    });

    // --- Initialization ---

    // Run on page load
    window.onload = function() {
      // Pre-populate with sample tags if desired (usually empty for 'add' form)
      // const sampleCategories = ['Coffee Beans', 'Sugar'];
      // sampleCategories.forEach(category => addCategoryTag(category));

      // Initial setup
      updateHiddenCategories(); // Ensure hidden field is set initially
      toggleCreditTerms(); // Set initial state of credit terms field
      validateCategories(); // Run initial category validation (might show error if empty)
    };

  </script>
</body>
</html>