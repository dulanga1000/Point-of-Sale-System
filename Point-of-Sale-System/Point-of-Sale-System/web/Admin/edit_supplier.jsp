<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, java.util.*, java.math.BigDecimal, util.DBConnection, model.Supplier, java.text.SimpleDateFormat, java.util.stream.Collectors" %>

<%!
    // Helper method to safely close resources
    private void closeQuietly(AutoCloseable resource) {
        if (resource != null) {
            try {
                resource.close();
            } catch (Exception e) {
                // Log or ignore
            }
        }
    }

    // Helper to check if a string is empty or null
    private boolean isEmpty(String s) {
        return s == null || s.trim().isEmpty();
    }
%>

<%
    // --- Initialize variables ---
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    String feedbackMessage = "";
    String feedbackClass = "";
    String pageAction = request.getParameter("action"); // For POST actions like update/delete

    Supplier supplierToEdit = new Supplier(); // Initialize with a default object
    String supplierDisplayId = "N/A";
    String supplierCurrentStatus = "Inactive";
    String supplierCurrentStatusCss = "status-inactive";
    String productCategoriesJS = "";
    String lastUpdatedDate = "N/A (DB schema needed)"; // Placeholder

    // --- Handle POST Request (Update/Delete) ---
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String formAction = request.getParameter("formAction"); // distinguish update from delete
        int sId = -1;
        try {
            sId = Integer.parseInt(request.getParameter("supplierId"));
        } catch (NumberFormatException e) {
            feedbackMessage = "Invalid Supplier ID.";
            feedbackClass = "error";
        }

        if (sId != -1) {
            try {
                conn = DBConnection.getConnection();
                if (conn == null) {
                    throw new SQLException("Failed to establish database connection.");
                }

                if ("update".equals(formAction)) {
                    // Retrieve all form parameters
                    String companyName = request.getParameter("companyName");
                    String category = request.getParameter("supplierCategory");
                    String businessRegNo = request.getParameter("businessRegNo");
                    String taxId = request.getParameter("taxId");
                    String companyAddress = request.getParameter("companyAddress");
                    String statusUpdate = request.getParameter("supplierStatus"); // Correct name from form
                    String contactPerson = request.getParameter("contactPerson");
                    String contactPosition = request.getParameter("contactPosition");
                    String contactPhone = request.getParameter("contactPhone");
                    String contactEmail = request.getParameter("contactEmail");
                    String paymentMethod = request.getParameter("paymentMethod");
                    String paymentTerms = request.getParameter("paymentTerms");
                    String creditLimitStr = request.getParameter("creditLimit");
                    String deliveryTerms = request.getParameter("deliveryTerms");
                    String leadTimeStr = request.getParameter("leadTime");
                    String hiddenProductCategories = request.getParameter("hiddenProductCategories");
                    String additionalNotes = request.getParameter("additionalNotes");

                    // Validation
                    if (isEmpty(companyName) || isEmpty(category) || isEmpty(businessRegNo) || isEmpty(statusUpdate) ||
                        isEmpty(contactPerson) || isEmpty(contactPhone) || isEmpty(contactEmail) ||
                        isEmpty(paymentMethod) || isEmpty(paymentTerms) || isEmpty(deliveryTerms) ||
                        isEmpty(leadTimeStr) || isEmpty(hiddenProductCategories)) {
                        feedbackMessage = "Error: Please fill in all required fields (*).";
                        feedbackClass = "error";
                    } else {
                        int leadTime = Integer.parseInt(leadTimeStr);
                        BigDecimal creditLimit = null;
                        if ("credit".equalsIgnoreCase(paymentTerms)) {
                            if (isEmpty(creditLimitStr)) {
                                feedbackMessage = "Error: Credit Limit is required for 'Credit Line'.";
                                feedbackClass = "error";
                            } else {
                                creditLimit = new BigDecimal(creditLimitStr);
                                if (creditLimit.compareTo(BigDecimal.ZERO) < 0) {
                                    feedbackMessage = "Error: Credit Limit cannot be negative.";
                                    feedbackClass = "error";
                                }
                            }
                        } else {
                             if (!isEmpty(creditLimitStr)) { creditLimit = new BigDecimal(creditLimitStr); }
                        }
                        
                        if (feedbackClass.isEmpty()) { // No validation errors so far
                            String sqlUpdate = "UPDATE suppliers SET company_name=?, category=?, business_reg_no=?, tax_id=?, " +
                                               "company_address=?, supplier_status=?, contact_person=?, contact_position=?, contact_phone=?, " +
                                               "contact_email=?, payment_method=?, payment_terms=?, credit_limit=?, delivery_terms=?, " +
                                               "lead_time=?, product_categories=?, additional_notes=? WHERE supplier_id=?";
                            pstmt = conn.prepareStatement(sqlUpdate);
                            pstmt.setString(1, companyName);
                            pstmt.setString(2, category);
                            pstmt.setString(3, businessRegNo);
                            pstmt.setString(4, taxId);
                            pstmt.setString(5, companyAddress);
                            pstmt.setString(6, statusUpdate); // supplier_status from DB
                            pstmt.setString(7, contactPerson);
                            pstmt.setString(8, contactPosition);
                            pstmt.setString(9, contactPhone);
                            pstmt.setString(10, contactEmail);
                            pstmt.setString(11, paymentMethod);
                            pstmt.setString(12, paymentTerms);
                            if (creditLimit != null) pstmt.setBigDecimal(13, creditLimit);
                            else pstmt.setNull(13, Types.DECIMAL);
                            pstmt.setString(14, deliveryTerms);
                            pstmt.setInt(15, leadTime);
                            pstmt.setString(16, hiddenProductCategories);
                            pstmt.setString(17, additionalNotes);
                            pstmt.setInt(18, sId);

                            int rowsAffected = pstmt.executeUpdate();
                            if (rowsAffected > 0) {
                                feedbackMessage = "Supplier updated successfully!";
                                feedbackClass = "success";
                            } else {
                                feedbackMessage = "Error: Could not update supplier. No rows affected or supplier not found.";
                                feedbackClass = "error";
                            }
                        }
                    }
                    // Redirect after POST to prevent re-submission
                    String redirectURL = request.getContextPath() + "/Admin/edit_supplier.jsp?id=" + sId +
                                         "&status=" + (feedbackClass.equals("success") ? "success_update" : "error_update") +
                                         "&message=" + java.net.URLEncoder.encode(feedbackMessage, "UTF-8");
                    response.sendRedirect(redirectURL);
                    return; // Stop further processing of JSP for this request

                } else if ("delete".equals(formAction)) {
                    String sqlDelete = "DELETE FROM suppliers WHERE supplier_id = ?";
                    pstmt = conn.prepareStatement(sqlDelete);
                    pstmt.setInt(1, sId);
                    int rowsAffected = pstmt.executeUpdate();
                    if (rowsAffected > 0) {
                        response.sendRedirect(request.getContextPath() + "/Admin/suppliers.jsp?status=success_delete&message=" + java.net.URLEncoder.encode("Supplier deleted successfully!", "UTF-8"));
                    } else {
                        response.sendRedirect(request.getContextPath() + "/Admin/suppliers.jsp?status=error_delete&message=" + java.net.URLEncoder.encode("Error deleting supplier. Supplier not found or DB error.", "UTF-8"));
                    }
                    return; // Stop further processing
                }
            } catch (SQLException e) {
                feedbackMessage = "Database error: " + e.getMessage();
                feedbackClass = "error";
                e.printStackTrace(); // Log to server console
                 String redirectURL = request.getContextPath() + "/Admin/edit_supplier.jsp?id=" + sId +
                                         "&status=error_update&message=" + java.net.URLEncoder.encode(feedbackMessage, "UTF-8");
                response.sendRedirect(redirectURL);
                return;
            } catch (Exception e) {
                feedbackMessage = "An unexpected error occurred: " + e.getMessage();
                feedbackClass = "error";
                e.printStackTrace();
                 String redirectURL = request.getContextPath() + "/Admin/edit_supplier.jsp?id=" + sId +
                                         "&status=error_update&message=" + java.net.URLEncoder.encode(feedbackMessage, "UTF-8");
                response.sendRedirect(redirectURL);
                return;
            } finally {
                closeQuietly(rs);
                closeQuietly(pstmt);
                closeQuietly(conn);
            }
        }
    }

    // --- Handle GET Request (Display Form) or Page Load after POST redirect ---
    String supplierIdParam = request.getParameter("id");
    if (supplierIdParam != null && !supplierIdParam.trim().isEmpty()) {
        try {
            int currentSupplierId = Integer.parseInt(supplierIdParam);
            conn = DBConnection.getConnection();
            if (conn == null) throw new SQLException("Failed to establish database connection.");

            String sqlSelect = "SELECT * FROM suppliers WHERE supplier_id = ?";
            pstmt = conn.prepareStatement(sqlSelect);
            pstmt.setInt(1, currentSupplierId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                supplierToEdit.setSupplierId(rs.getInt("supplier_id"));
                supplierToEdit.setCompanyName(rs.getString("company_name"));
                supplierToEdit.setCategory(rs.getString("category"));
                supplierToEdit.setBusinessRegNo(rs.getString("business_reg_no"));
                supplierToEdit.setTaxId(rs.getString("tax_id"));
                supplierToEdit.setCompanyAddress(rs.getString("company_address"));
                // supplierToEdit.setSupplierStatus(rs.getString("supplier_status")); // Assumes model has this method
                supplierCurrentStatus = rs.getString("supplier_status"); // Use directly for JSP
                supplierToEdit.setContactPerson(rs.getString("contact_person"));
                supplierToEdit.setContactPosition(rs.getString("contact_position"));
                supplierToEdit.setContactPhone(rs.getString("contact_phone"));
                supplierToEdit.setContactEmail(rs.getString("contact_email"));
                supplierToEdit.setPaymentMethod(rs.getString("payment_method"));
                supplierToEdit.setPaymentTerms(rs.getString("payment_terms"));
                supplierToEdit.setCreditLimit(rs.getBigDecimal("credit_limit"));
                supplierToEdit.setDeliveryTerms(rs.getString("delivery_terms"));
                supplierToEdit.setLeadTime(rs.getInt("lead_time"));
                supplierToEdit.setProductCategories(rs.getString("product_categories"));
                supplierToEdit.setAdditionalNotes(rs.getString("additional_notes"));
                // supplierToEdit.setCreatedAt(rs.getTimestamp("created_at")); // If 'created_at' exists in DB

                supplierDisplayId = "SUP-" + String.format("%04d", supplierToEdit.getSupplierId());
                if ("Active".equalsIgnoreCase(supplierCurrentStatus)) {
                    supplierCurrentStatusCss = "status-active";
                }

                if (supplierToEdit.getProductCategories() != null && !supplierToEdit.getProductCategories().trim().isEmpty()) {
                    productCategoriesJS = Arrays.stream(supplierToEdit.getProductCategories().split(","))
                                                .map(String::trim)
                                                .filter(s -> !s.isEmpty())
                                                .collect(Collectors.joining(","));
                }
                // Example: If suppliers table had 'updated_at'
                // Timestamp updatedAtTimestamp = rs.getTimestamp("updated_at");
                // if (updatedAtTimestamp != null) {
                //    lastUpdatedDate = new SimpleDateFormat("MMMM dd, yyyy").format(new Date(updatedAtTimestamp.getTime()));
                // }


            } else {
                feedbackMessage = "Supplier not found for ID: " + currentSupplierId;
                feedbackClass = "error";
            }
        } catch (NumberFormatException e) {
            feedbackMessage = "Invalid Supplier ID format in URL.";
            feedbackClass = "error";
        } catch (SQLException e) {
            feedbackMessage = "Database error fetching supplier: " + e.getMessage();
            feedbackClass = "error";
            e.printStackTrace();
        } catch (Exception e) {
            feedbackMessage = "An unexpected error occurred: " + e.getMessage();
            feedbackClass = "error";
            e.printStackTrace();
        } finally {
            closeQuietly(rs);
            closeQuietly(pstmt);
            closeQuietly(conn);
        }
    } else if (isEmpty(pageAction)) { // Only show if not a POST action already handled
        feedbackMessage = "No Supplier ID provided to edit.";
        feedbackClass = "error";
    }

    // Process feedback messages passed via URL parameters (e.g., after a redirect)
    String statusParam = request.getParameter("status");
    String messageParam = request.getParameter("message");

    if (statusParam != null && messageParam != null) {
        feedbackMessage = messageParam; // Already URL-decoded by getParameter
        if ("success_update".equals(statusParam)) {
            feedbackClass = "success";
        } else if ("error_update".equals(statusParam)) {
            feedbackClass = "error";
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Supplier - Swift POS</title>
    <style>
        /* ... (Your existing CSS, ensure it matches the one from your last 'edit_supplier.jsp' example) ... */
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        :root { --primary: #2563eb; --primary-dark: #1d4ed8; --secondary: #64748b; --light: #f1f5f9; --dark: #1e293b; --success: #10b981; --warning: #f59e0b; --danger: #ef4444; }
        body { background-color: #f8fafc; color: var(--dark); padding: 20px; }
        .module-card { background-color: white; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); overflow: hidden; max-width: 900px; margin: 20px auto; }
        .module-header { padding: 15px 20px; background-color: var(--primary); color: white; font-weight: 600; font-size: 18px; display: flex; justify-content: space-between; align-items: center; }
        .module-header-actions { display: flex; gap: 10px; }
        .btn-danger { background-color: var(--danger); color: white; }
        .btn-danger:hover { background-color: #dc2626; }
        .module-content { padding: 20px; }
        .form-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 20px; margin-bottom: 20px; }
        .form-group { margin-bottom: 15px; }
        .form-group.full-width { grid-column: span 2; }
        .form-group label { display: block; margin-bottom: 8px; font-weight: 500; color: var(--dark); }
        .form-control { width: 100%; padding: 10px 12px; border: 1px solid #e2e8f0; border-radius: 6px; font-size: 14px; transition: border-color 0.2s; }
        .form-control:focus { outline: none; border-color: var(--primary); box-shadow: 0 0 0 2px rgba(37,99,235,0.1); }
        textarea.form-control { min-height: 100px; resize: vertical; }
        .form-actions { display: flex; justify-content: flex-end; gap: 15px; margin-top: 20px; border-top: 1px solid #f1f5f9; padding-top: 20px; }
        .btn { padding: 10px 20px; border-radius: 6px; font-weight: 500; cursor: pointer; transition: all 0.2s; font-size: 14px; border: none; }
        .btn-primary { background-color: var(--primary); color: white; }
        .btn-primary:hover { background-color: var(--primary-dark); }
        .btn-secondary { background-color: #e2e8f0; color: var(--dark); }
        .btn-secondary:hover { background-color: #cbd5e1; }
        .form-help { font-size: 12px; color: var(--secondary); margin-top: 4px; }
        .form-section { margin-bottom: 25px; }
        .form-section-title { font-weight: 600; font-size: 16px; margin-bottom: 15px; padding-bottom: 8px; border-bottom: 1px solid #f1f5f9; }
        .tag-container { display: flex; flex-wrap: wrap; gap: 8px; margin-top: 10px; padding: 8px; border: 1px solid #e2e8f0; border-radius: 6px; min-height: 40px; }
        .tag { background-color: #e0e7ff; color: #3730a3; border-radius: 15px; padding: 5px 12px; font-size: 13px; font-weight: 500; display: flex; align-items: center; gap: 6px; cursor: default; }
        .tag span:first-child { margin-right: 5px; }
        .tag-remove { cursor: pointer; font-weight: bold; color: #64748b; padding: 0 3px; border-radius: 50%; line-height: 1; transition: background-color 0.2s, color 0.2s; }
        .tag-remove:hover { color: white; background-color: var(--danger); }
        @media (max-width: 768px) { .form-grid { grid-template-columns: 1fr; } .form-group.full-width { grid-column: span 1; } .form-actions { flex-direction: column; } .btn { width: 100%; } .module-header { flex-direction: column; align-items: flex-start; gap: 10px; } .module-header-actions { width: 100%; } }
        .form-note { background-color: #eff6ff; border-left: 4px solid var(--primary); padding: 12px 15px; margin-bottom: 20px; border-radius: 0 6px 6px 0; font-size: 14px; color: #1e40af; }
        .credit-terms { display: none; } .credit-terms.active { display: block; animation: fadeIn 0.3s ease-out; }
        @keyframes fadeIn { from { opacity: 0; transform: translateY(-10px); } to { opacity: 1; transform: translateY(0); } }
        .status-badge { display: inline-block; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 500; margin-left: 10px; }
        .status-active { background-color: #dcfce7; color: #166534; } .status-inactive { background-color: #fee2e2; color: #991b1b; }
        .form-group.inline-radio { display: flex; gap: 20px; align-items: center; }
        .form-group.inline-radio label:first-child { margin-bottom:0; }
        .radio-option { display: flex; align-items: center; gap: 8px; }
        .info-pill { display: inline-flex; align-items: center; gap: 5px; background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 50px; padding: 6px 12px; font-size: 13px; margin-top: 8px; color: var(--dark); }
        .info-icon { color: var(--secondary); font-size: 14px; }
        .modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 1000; visibility: hidden; opacity: 0; transition: all 0.3s; }
        .modal-overlay.active { visibility: visible; opacity: 1; }
        .modal-content { background-color: white; border-radius: 8px; width: 400px; max-width: 90%; overflow: hidden; transform: translateY(-20px); transition: transform 0.3s; }
        .modal-overlay.active .modal-content { transform: translateY(0); }
        .modal-header { padding: 15px 20px; background-color: var(--danger); color: white; font-weight: 600; font-size: 16px; }
        .modal-body { padding: 20px; font-size:14px; line-height:1.5; }
        .modal-footer { padding: 15px 20px; display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid #f1f5f9; }
        .history-container { background-color: #f8fafc; border: 1px solid #e2e8f0; border-radius: 6px; padding: 15px; margin-top: 10px; font-size: 14px; }
        .history-item { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px dashed #e2e8f0; }
        .history-item:last-child { border-bottom: none; } .history-date { color: var(--secondary); font-size: 12px; }
        .form-feedback { padding: 12px 15px; margin-bottom: 20px; border-radius: 6px; font-size: 14px; border-left-width: 4px; border-left-style: solid; font-weight: 500; }
        .form-feedback.success { background-color: #f0fdf4; border-color: var(--success); color: #15803d; }
        .form-feedback.error { background-color: #fef2f2; border-color: var(--danger); color: #b91c1c; }
    </style>
</head>
<body>
    <div class="modal-overlay" id="deleteModal">
        <div class="modal-content">
            <div class="modal-header">Confirm Deletion</div>
            <div class="modal-body">
                <p>Are you sure you want to delete this supplier: <strong><%= supplierToEdit.getCompanyName() != null ? supplierToEdit.getCompanyName() : "N/A" %></strong> (ID: <%= supplierDisplayId %>)?</p>
                <p style="margin-top: 10px;">This action cannot be undone. Associated order history will remain.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeDeleteModal()">Cancel</button>
                <button type="button" class="btn btn-danger" onclick="confirmDeleteSupplier()">Delete Supplier</button>
            </div>
        </div>
    </div>

    <div class="module-card">
        <div class="module-header">
            <div>
                Edit Supplier
                <span class="status-badge <%= supplierCurrentStatusCss %>"><%= supplierCurrentStatus %></span>
            </div>
            <div class="module-header-actions">
                <% if (supplierToEdit != null && supplierToEdit.getSupplierId() > 0) { %>
                <button type="button" class="btn btn-danger" onclick="showDeleteModal()">Delete</button>
                <% } %>
            </div>
        </div>
        <div class="module-content">
            <% if (!feedbackMessage.isEmpty()) { %>
            <div class="form-feedback <%= feedbackClass %>">
                <%= feedbackMessage %>
            </div>
            <% } %>

            <div class="form-note">
                <strong>Supplier ID:</strong> <%= supplierDisplayId %> | <strong>Last Updated:</strong> <%= lastUpdatedDate %>
            </div>

            <% if (supplierToEdit.getSupplierId() > 0 || "No Supplier ID provided to edit.".equals(feedbackMessage) || "Invalid Supplier ID format in URL.".equals(feedbackMessage) ) { // Show form if ID exists or if initial error is only about ID missing for fetch
                if(supplierToEdit.getSupplierId() <= 0 && !feedbackMessage.toLowerCase().contains("not found")) { // If supplier not found for a valid ID, don't show form unless it's the general ID missing error
                    // If here, means supplierIdParam was null or invalid, so supplierToEdit is empty.
                    // Feedback message for missing/invalid ID is already set or will be displayed from URL params.
                    // To avoid showing an empty form when a specific supplier ID was expected but not found,
                    // we might add an additional check or rely on the feedback message.
                }
            %>
            <form id="editSupplierForm" action="edit_supplier.jsp?id=<%= supplierToEdit.getSupplierId() %>" method="POST">
                <input type="hidden" name="supplierId" value="<%= supplierToEdit.getSupplierId() %>">
                <input type="hidden" name="formAction" id="formActionInput" value="update"> <%-- To distinguish update from delete --%>

                <div class="form-section">
                    <h3 class="form-section-title">Company Information</h3>
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="companyName">Company Name *</label>
                            <input type="text" id="companyName" name="companyName" class="form-control" required value="<%= supplierToEdit.getCompanyName() != null ? supplierToEdit.getCompanyName() : "" %>">
                        </div>
                        <div class="form-group">
                            <label for="supplierCategory">Main Category *</label>
                            <select id="supplierCategory" name="supplierCategory" class="form-control" required>
                                <option value="">Select Category</option>
                                <% String currentMainCategory = supplierToEdit.getCategory() != null ? supplierToEdit.getCategory() : ""; %>
                                <option value="beverages" <%= "beverages".equals(currentMainCategory) ? "selected" : "" %>>Beverages</option>
                                <option value="dairy" <%= "dairy".equals(currentMainCategory) ? "selected" : "" %>>Dairy</option>
                                <option value="packaging" <%= "packaging".equals(currentMainCategory) ? "selected" : "" %>>Packaging</option>
                                <option value="ingredients" <%= "ingredients".equals(currentMainCategory) ? "selected" : "" %>>Ingredients</option>
                                <option value="equipment" <%= "equipment".equals(currentMainCategory) ? "selected" : "" %>>Equipment</option>
                                <option value="other" <%= "other".equals(currentMainCategory) ? "selected" : "" %>>Other</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="businessRegNo">Business Registration No. *</label>
                            <input type="text" id="businessRegNo" name="businessRegNo" class="form-control" required value="<%= supplierToEdit.getBusinessRegNo() != null ? supplierToEdit.getBusinessRegNo() : "" %>">
                        </div>
                        <div class="form-group">
                            <label for="taxId">Tax ID</label>
                            <input type="text" id="taxId" name="taxId" class="form-control" value="<%= supplierToEdit.getTaxId() != null ? supplierToEdit.getTaxId() : "" %>">
                        </div>
                        <div class="form-group full-width">
                            <label for="companyAddress">Company Address *</label>
                            <textarea id="companyAddress" name="companyAddress" class="form-control" required><%= supplierToEdit.getCompanyAddress() != null ? supplierToEdit.getCompanyAddress() : "" %></textarea>
                        </div>
                    </div>
                </div>

                <div class="form-section">
                    <h3 class="form-section-title">Supplier Status</h3>
                    <div class="form-group inline-radio">
                        <label>Current Status:</label>
                        <div class="radio-option">
                            <input type="radio" id="statusActive" name="supplierStatus" value="Active" <%= "Active".equalsIgnoreCase(supplierCurrentStatus) ? "checked" : "" %>>
                            <label for="statusActive">Active</label>
                        </div>
                        <div class="radio-option">
                            <input type="radio" id="statusInactive" name="supplierStatus" value="Inactive" <%= "Inactive".equalsIgnoreCase(supplierCurrentStatus) ? "checked" : "" %>>
                            <label for="statusInactive">Inactive</label>
                        </div>
                    </div>
                     <div class="info-pill">
                        <span class="info-icon">ℹ</span> Supplier registered (<%-- Date N/A without created_at in DB --%>)
                    </div>
                </div>

                <div class="form-section">
                    <h3 class="form-section-title">Primary Contact</h3>
                    <div class="form-grid">
                        <div class="form-group">
                            <label for="contactPerson">Contact Person *</label>
                            <input type="text" id="contactPerson" name="contactPerson" class="form-control" required value="<%= supplierToEdit.getContactPerson() != null ? supplierToEdit.getContactPerson() : "" %>">
                        </div>
                        <div class="form-group">
                            <label for="contactPosition">Position</label>
                            <input type="text" id="contactPosition" name="contactPosition" class="form-control" value="<%= supplierToEdit.getContactPosition() != null ? supplierToEdit.getContactPosition() : "" %>">
                        </div>
                        <div class="form-group">
                            <label for="contactPhone">Phone Number *</label>
                            <input type="tel" id="contactPhone" name="contactPhone" class="form-control" title="Format: +94 7X XXX XXXX" value="<%= supplierToEdit.getContactPhone() != null ? supplierToEdit.getContactPhone() : "" %>">
                            <div class="form-help">Format: +94 7X XXX XXXX</div>
                        </div>
                        <div class="form-group">
                            <label for="contactEmail">Email *</label>
                            <input type="email" id="contactEmail" name="contactEmail" class="form-control" required value="<%= supplierToEdit.getContactEmail() != null ? supplierToEdit.getContactEmail() : "" %>">
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
                                <% String currentPaymentMethod = supplierToEdit.getPaymentMethod() != null ? supplierToEdit.getPaymentMethod() : ""; %>
                                <option value="bank_transfer" <%= "bank_transfer".equals(currentPaymentMethod) ? "selected" : "" %>>Bank Transfer</option>
                                <option value="cash" <%= "cash".equals(currentPaymentMethod) ? "selected" : "" %>>Cash</option>
                                <option value="cheque" <%= "cheque".equals(currentPaymentMethod) ? "selected" : "" %>>Cheque</option>
                                <option value="credit_card" <%= "credit_card".equals(currentPaymentMethod) ? "selected" : "" %>>Credit Card</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="paymentTerms">Payment Terms *</label>
                            <select id="paymentTerms" name="paymentTerms" class="form-control" required onchange="toggleCreditTerms()">
                                <option value="">Select Payment Terms</option>
                                <% String currentPaymentTerms = supplierToEdit.getPaymentTerms() != null ? supplierToEdit.getPaymentTerms() : ""; %>
                                <option value="immediate" <%= "immediate".equals(currentPaymentTerms) ? "selected" : "" %>>Immediate Payment</option>
                                <option value="cod" <%= "cod".equals(currentPaymentTerms) ? "selected" : "" %>>Cash on Delivery</option>
                                <option value="7days" <%= "7days".equals(currentPaymentTerms) ? "selected" : "" %>>Net 7</option>
                                <option value="15days" <%= "15days".equals(currentPaymentTerms) ? "selected" : "" %>>Net 15</option>
                                <option value="30days" <%= "30days".equals(currentPaymentTerms) ? "selected" : "" %>>Net 30</option>
                                <option value="credit" <%= "credit".equals(currentPaymentTerms) ? "selected" : "" %>>Credit Line</option>
                            </select>
                        </div>
                        <div id="creditTerms" class="form-group full-width credit-terms">
                            <label for="creditLimit">Credit Limit (Rs.)</label>
                            <input type="number" id="creditLimit" name="creditLimit" class="form-control" min="0" step="0.01" value="<%= (supplierToEdit.getCreditLimit() != null) ? supplierToEdit.getCreditLimit().toPlainString() : "" %>">
                            <div class="form-help">Maximum credit amount allowed (Required if 'Credit Line' is selected)</div>
                        </div>
                        <div class="form-group">
                            <label for="deliveryTerms">Delivery Terms *</label>
                            <select id="deliveryTerms" name="deliveryTerms" class="form-control" required>
                                 <option value="">Select Delivery Terms</option>
                                <% String currentDeliveryTerms = supplierToEdit.getDeliveryTerms() != null ? supplierToEdit.getDeliveryTerms() : ""; %>
                                <option value="supplier_delivery" <%= "supplier_delivery".equals(currentDeliveryTerms) ? "selected" : "" %>>Supplier Delivery</option>
                                <option value="pickup" <%= "pickup".equals(currentDeliveryTerms) ? "selected" : "" %>>Store Pickup</option>
                                <option value="third_party" <%= "third_party".equals(currentDeliveryTerms) ? "selected" : "" %>>Third Party Logistics</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <label for="leadTime">Average Lead Time (Days) *</label>
                            <input type="number" id="leadTime" name="leadTime" class="form-control" min="1" required value="<%= supplierToEdit.getLeadTime() > 0 ? supplierToEdit.getLeadTime() : "1" %>">
                            <div class="form-help">Average time from order to delivery (must be 1 or more)</div>
                        </div>
                    </div>
                </div>

                <div class="form-section">
                    <h3 class="form-section-title">Products & Services</h3>
                    <div class="form-grid">
                        <div class="form-group full-width">
                            <label for="productCategoriesInput">Product Categories Supplied *</label>
                            <input type="text" id="productCategoriesInput" class="form-control" placeholder="Type a category and press Enter">
                            <div class="form-help">Enter product categories this supplier provides (e.g., Coffee Beans, Milk). At least one is required.</div>
                            <div class="tag-container" id="categoryTags">
                                <%-- Tags populated by JavaScript --%>
                            </div>
                            <input type="hidden" name="hiddenProductCategories" id="hiddenProductCategories" value="<%= productCategoriesJS %>">
                            <div class="form-help" id="categoryValidationMsg" style="color: var(--danger); display: none; margin-top: 8px;">At least one product category is required.</div>
                        </div>
                        <div class="form-group full-width">
                            <label for="additionalNotes">Additional Notes</label>
                            <textarea id="additionalNotes" name="additionalNotes" class="form-control" placeholder="Any special instructions, contact preferences, or other details..."><%= supplierToEdit.getAdditionalNotes() != null ? supplierToEdit.getAdditionalNotes() : "" %></textarea>
                        </div>
                    </div>
                </div>

                <div class="form-section">
                    <h3 class="form-section-title">Recent Activity (Placeholder)</h3>
                    <div class="history-container">
                        <div class="history-item"><div>Last Order Placed</div><div class="history-date">May 8, 2025</div></div>
                        <div class="history-item"><div>Total Orders (Last 6 Months)</div><div>24</div></div>
                        <div class="history-item"><div>Average Order Value</div><div>Rs. 42,750.00</div></div>
                        <div class="history-item"><div>Payment Status</div><div style="color: var(--success);">Good Standing</div></div>
                    </div>
                </div>

                <div class="form-actions">
                    <button type="button" class="btn btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/Admin/suppliers.jsp';">Cancel</button>
                    <button type="submit" class="btn btn-primary" onclick="document.getElementById('formActionInput').value='update';">Update Supplier</button>
                </div>
            </form>
            <% } else if (supplierToEdit.getSupplierId() <= 0 && !feedbackMessage.isEmpty() && feedbackMessage.toLowerCase().contains("not found")) { %>
                <%-- Message already displayed via feedbackMessage scriptlet at the top if supplier not found after valid ID attempt --%>
            <% } %>
        </div>
    </div>

    <script>
        // --- Elements (ensure these are consistent with your actual form) ---
        const paymentTermsSelect = document.getElementById('paymentTerms');
        const creditTermsDiv = document.getElementById('creditTerms');
        const creditLimitInput = document.getElementById('creditLimit');
        const categoryInputField = document.getElementById('productCategoriesInput');
        const tagsContainerDiv = document.getElementById('categoryTags');
        const hiddenCategoriesField = document.getElementById('hiddenProductCategories');
        const categoryValidationMsgDiv = document.getElementById('categoryValidationMsg');
        const editSupplierForm = document.getElementById('editSupplierForm');

        function toggleCreditTerms() {
            if (!paymentTermsSelect || !creditTermsDiv || !creditLimitInput) return;
            const isCreditTerm = paymentTermsSelect.value === 'credit';
            creditTermsDiv.classList.toggle('active', isCreditTerm);
            if (isCreditTerm) {
                creditLimitInput.setAttribute('required', 'required');
            } else {
                creditLimitInput.removeAttribute('required');
            }
        }

        function addCategoryTag(text) {
            if (!categoryInputField || !tagsContainerDiv || !hiddenCategoriesField) return;
            const trimmedText = text.trim();
            if (!trimmedText) return;
            const existingTags = Array.from(tagsContainerDiv.querySelectorAll('.tag span:first-child'))
                                    .map(span => span.textContent.trim().toLowerCase());
            if (existingTags.includes(trimmedText.toLowerCase())) {
                categoryInputField.value = ''; return;
            }
            const tag = document.createElement('div');
            tag.className = 'tag';
            const textSpan = document.createElement('span');
            textSpan.textContent = trimmedText;
            const removeSpan = document.createElement('span');
            removeSpan.className = 'tag-remove';
            removeSpan.innerHTML = '&#10005;';
            removeSpan.title = 'Remove category';
            removeSpan.onclick = function() { removeTagElement(this.parentElement); };
            tag.appendChild(textSpan);
            tag.appendChild(removeSpan);
            tagsContainerDiv.appendChild(tag);
            categoryInputField.value = '';
            updateHiddenCategories();
            validateCategories();
        }

        function removeTagElement(tagElement) {
            tagElement.remove();
            updateHiddenCategories();
            validateCategories();
        }

        function updateHiddenCategories() {
            if (!tagsContainerDiv || !hiddenCategoriesField) return;
            const tags = tagsContainerDiv.querySelectorAll('.tag span:first-child');
            hiddenCategoriesField.value = Array.from(tags).map(tag => tag.textContent.trim()).join(',');
        }

        function validateCategories() {
            if (!tagsContainerDiv || !categoryValidationMsgDiv || !categoryInputField) return true; // Default to true if elements missing
            const hasTags = tagsContainerDiv.querySelectorAll('.tag').length > 0;
            categoryValidationMsgDiv.style.display = hasTags ? 'none' : 'block';
            categoryInputField.style.borderColor = hasTags ? '#e2e8f0' : 'var(--danger)';
            return hasTags;
        }

        function validateCreditLimit() {
            if (!paymentTermsSelect || !creditLimitInput) return true;
            if (paymentTermsSelect.value === 'credit') {
                if (!creditLimitInput.value || parseFloat(creditLimitInput.value) < 0) {
                    alert('Credit Limit is required and must be zero or positive when Payment Term is Credit Line.');
                    creditLimitInput.focus();
                    creditLimitInput.style.borderColor = 'var(--danger)';
                    return false;
                } else {
                    creditLimitInput.style.borderColor = '#e2e8f0';
                }
            }
            return true;
        }
        if (categoryInputField) {
            categoryInputField.addEventListener('keydown', function(e) {
                if (e.key === 'Enter') {
                    e.preventDefault();
                    addCategoryTag(this.value);
                }
            });
        }

        if (editSupplierForm) {
            editSupplierForm.addEventListener('submit', function(e) {
                // This client-side validation runs before form submission.
                // Server-side validation in JSP scriptlet will also run.
                updateHiddenCategories();
                let isFormValid = true;
                if (!validateCategories()) isFormValid = false;
                if (!validateCreditLimit()) isFormValid = false;
                
                if (!this.checkValidity()) { // HTML5 built-in validation
                    isFormValid = false;
                }

                if (!isFormValid) {
                    e.preventDefault(); // Stop form submission if client-side validation fails
                    alert('Please correct the errors highlighted or fill all required (*) fields before submitting.');
                }
                // If valid, form submits naturally to the JSP itself for POST processing.
            });
        }

        function showDeleteModal() {
            const modal = document.getElementById('deleteModal');
            if(modal) modal.classList.add('active');
        }
        function closeDeleteModal() {
            const modal = document.getElementById('deleteModal');
            if(modal) modal.classList.remove('active');
        }
        function confirmDeleteSupplier() {
            // Set action to delete and submit the form
            const formActionInput = document.getElementById('formActionInput');
            if(formActionInput) formActionInput.value = 'delete';
            if(editSupplierForm) editSupplierForm.submit();
        }

        window.onload = function() {
            if (hiddenCategoriesField) {
                const initialCategories = hiddenCategoriesField.value;
                if (initialCategories) {
                    initialCategories.split(',').map(cat => cat.trim()).filter(cat => cat)
                                     .forEach(category => addCategoryTag(category));
                }
            }
            updateHiddenCategories();
            toggleCreditTerms();
            validateCategories();
        };
    </script>
</body>
</html>