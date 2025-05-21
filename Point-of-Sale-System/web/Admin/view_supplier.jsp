<%@page contentType="text/html" pageEncoding="UTF-8"%>
<%@page import="java.sql.*, java.util.*, java.math.BigDecimal, util.DBConnection, model.Supplier, java.text.SimpleDateFormat, java.util.stream.Collectors" %>

<%!
    // Helper method to safely close resources
    private void closeQuietly(AutoCloseable resource) {
        if (resource != null) {
            try {
                resource.close();
            } catch (Exception e) {
                // Log or ignore for brevity in JSP
            }
        }
    }

    // Helper to format BigDecimal for display
    private String formatCurrency(BigDecimal value) {
        if (value == null) return "N/A";
        return String.format("Rs. %,.2f", value);
    }

    // Helper to format int for display
     private String formatInt(int value, String ifZero) {
        return value == 0 && "0".equals(ifZero) ? "0" : (value == 0 ? ifZero : String.valueOf(value));
    }
     private String formatInt(int value) {
        return String.valueOf(value);
    }

    // Helper for null-safe string display
    private String displayString(String s) {
        return (s == null || s.trim().isEmpty()) ? "N/A" : s;
    }

    // Helper for date display (expects java.util.Date or its subclass java.sql.Date)
    private String formatDate(java.util.Date date) { // Explicitly java.util.Date
        if (date == null) return "N/A";
        return new SimpleDateFormat("MMMM dd, yyyy").format(date); // Corrected format
    }

     private String formatTimestamp(java.sql.Timestamp timestamp) { // java.sql.Timestamp is specific
        if (timestamp == null) return "N/A";
        // SimpleDateFormat formats java.util.Date. Timestamp.getTime() gives long.
        return new SimpleDateFormat("MMMM dd, yyyy, hh:mm a").format(new java.util.Date(timestamp.getTime())); // Explicitly new java.util.Date, corrected format
    }
%>

<%
    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    Supplier supplierToView = null;
    List<Map<String, String>> productsBySupplier = new ArrayList<>();
    List<Map<String, String>> purchaseOrdersBySupplier = new ArrayList<>();

    String feedbackMessage = "";
    String feedbackClass = "";

    String supplierIdParam = request.getParameter("id");
    int supplierId = -1;

    if (supplierIdParam == null || supplierIdParam.trim().isEmpty()) {
        feedbackMessage = "Error: Supplier ID is missing.";
        feedbackClass = "error";
    } else {
        try {
            supplierId = Integer.parseInt(supplierIdParam);
            conn = DBConnection.getConnection();
            if (conn == null) {
                throw new SQLException("Failed to establish database connection.");
            }

            // Fetch Supplier Details
            String sqlSelectSupplier = "SELECT * FROM suppliers WHERE supplier_id = ?";
            pstmt = conn.prepareStatement(sqlSelectSupplier);
            pstmt.setInt(1, supplierId);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                supplierToView = new Supplier();
                supplierToView.setSupplierId(rs.getInt("supplier_id"));
                supplierToView.setCompanyName(rs.getString("company_name"));
                supplierToView.setCategory(rs.getString("category"));
                supplierToView.setBusinessRegNo(rs.getString("business_reg_no"));
                supplierToView.setTaxId(rs.getString("tax_id"));
                supplierToView.setCompanyAddress(rs.getString("company_address"));
                // supplier_status will be fetched separately for supplierCurrentStatusDisplay
                supplierToView.setContactPerson(rs.getString("contact_person"));
                supplierToView.setContactPosition(rs.getString("contact_position"));
                supplierToView.setContactPhone(rs.getString("contact_phone"));
                supplierToView.setContactEmail(rs.getString("contact_email"));
                supplierToView.setPaymentMethod(rs.getString("payment_method"));
                supplierToView.setPaymentTerms(rs.getString("payment_terms"));
                supplierToView.setCreditLimit(rs.getBigDecimal("credit_limit"));
                supplierToView.setDeliveryTerms(rs.getString("delivery_terms"));
                supplierToView.setLeadTime(rs.getInt("lead_time"));
                supplierToView.setProductCategories(rs.getString("product_categories"));
                supplierToView.setAdditionalNotes(rs.getString("additional_notes"));

                // Fetch Products by this Supplier
                closeQuietly(rs);
                closeQuietly(pstmt);
                String sqlSelectProducts = "SELECT id, name, category, price, sku, stock, image_path FROM products WHERE supplier = ? AND status = 'Active' ORDER BY name ASC LIMIT 10";
                pstmt = conn.prepareStatement(sqlSelectProducts);
                pstmt.setString(1, supplierToView.getCompanyName());
                rs = pstmt.executeQuery();
                while(rs.next()){
                    Map<String, String> product = new HashMap<>();
                    product.put("id", String.valueOf(rs.getInt("id")));
                    product.put("name", rs.getString("name"));
                    product.put("category", rs.getString("category"));
                    product.put("price", formatCurrency(rs.getBigDecimal("price")));
                    product.put("sku", rs.getString("sku"));
                    product.put("stock", String.valueOf(rs.getInt("stock")));
                    product.put("image_path", rs.getString("image_path"));
                    productsBySupplier.add(product);
                }
                closeQuietly(rs);
                closeQuietly(pstmt);

                // Fetch Purchase Orders for this Supplier
                String sqlSelectPOs = "SELECT po_main_id, order_number_display, order_date_form, grand_total, order_status FROM swift_purchase_orders_main WHERE supplier_id = ? ORDER BY order_date_form DESC LIMIT 10";
                pstmt = conn.prepareStatement(sqlSelectPOs);
                pstmt.setInt(1, supplierId);
                rs = pstmt.executeQuery();
                while(rs.next()){
                    Map<String, String> po = new HashMap<>();
                    po.put("id", String.valueOf(rs.getInt("po_main_id")));
                    po.put("order_number_display", rs.getString("order_number_display"));
                    po.put("order_date", formatDate(rs.getDate("order_date_form"))); // rs.getDate() returns java.sql.Date
                    po.put("grand_total", formatCurrency(rs.getBigDecimal("grand_total")));
                    po.put("status", rs.getString("order_status"));
                    purchaseOrdersBySupplier.add(po);
                }

            } else {
                feedbackMessage = "Supplier with ID " + supplierId + " not found.";
                feedbackClass = "error";
            }
        } catch (NumberFormatException e) {
            feedbackMessage = "Error: Invalid Supplier ID format in URL.";
            feedbackClass = "error";
        } catch (SQLException e) {
            feedbackMessage = "Database error: " + e.getMessage();
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
    }

    String supplierCurrentStatusDisplay = "N/A";
    String supplierCurrentStatusCss = "status-inactive";
    if (supplierToView != null && supplierToView.getSupplierId() > 0) {
        Connection tempConn = null; PreparedStatement tempPstmt = null; ResultSet tempRs = null;
        try {
            tempConn = DBConnection.getConnection();
            tempPstmt = tempConn.prepareStatement("SELECT supplier_status FROM suppliers WHERE supplier_id = ?");
            tempPstmt.setInt(1, supplierToView.getSupplierId());
            tempRs = tempPstmt.executeQuery();
            if (tempRs.next()) {
                supplierCurrentStatusDisplay = tempRs.getString("supplier_status");
                if ("Active".equalsIgnoreCase(supplierCurrentStatusDisplay)) {
                    supplierCurrentStatusCss = "status-active";
                }
            }
        } catch (SQLException e) { /* ignore, use default */ }
        finally { closeQuietly(tempRs); closeQuietly(tempPstmt); closeQuietly(tempConn); }
    }

    String supplierDisplayId = (supplierToView != null && supplierToView.getSupplierId() > 0) ? "SUP-" + String.format("%04d", supplierToView.getSupplierId()) : "N/A";
    String lastUpdatedDate = "N/A"; 

    String statusParam = request.getParameter("status");
    String messageParam = request.getParameter("message");
    if (statusParam != null && messageParam != null && feedbackMessage.isEmpty()) {
        feedbackMessage = messageParam;
        if (statusParam.startsWith("success")) feedbackClass = "success";
        else if (statusParam.startsWith("error")) feedbackClass = "error";
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Supplier Details - Swift POS</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0-beta3/css/all.min.css">
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        :root { --primary: #2563eb; --primary-dark: #1d4ed8; --secondary: #64748b; --light: #f1f5f9; --dark: #1e293b; --success: #10b981; --warning: #f59e0b; --danger: #ef4444; }
        body { background-color: #f8fafc; color: var(--dark); padding: 20px; }
        .module-card { background-color: white; border-radius: 8px; box-shadow: 0 2px 5px rgba(0,0,0,0.05); overflow: hidden; max-width: 900px; margin: 20px auto; }
        .module-header { padding: 15px 20px; background-color: var(--primary); color: white; font-weight: 600; font-size: 18px; display: flex; justify-content: space-between; align-items: center; }
        .module-header-actions { display: flex; gap: 10px; }
        .btn { padding: 8px 15px; border-radius: 6px; font-weight: 500; cursor: pointer; transition: all 0.2s; font-size: 14px; border: none; text-decoration: none; display: inline-flex; align-items: center; }
        .btn i { margin-right: 5px; }
        .btn-primary { background-color: var(--primary); color: white; }
        .btn-primary:hover { background-color: var(--primary-dark); }
        .btn-secondary { background-color: #e2e8f0; color: var(--dark); }
        .btn-secondary:hover { background-color: #cbd5e1; }
        .btn-danger { background-color: var(--danger); color: white; }
        .btn-danger:hover { background-color: #dc2626; }
        .btn-light { background-color: var(--light); color: var(--dark); border: 1px solid #e2e8f0; }
        .btn-light:hover { background-color: #e2e8f0; }
        .module-content { padding: 20px; }
        .form-section { margin-bottom: 25px; }
        .form-section-title { font-weight: 600; font-size: 16px; margin-bottom: 15px; padding-bottom: 8px; border-bottom: 1px solid #f1f5f9; color: var(--primary); }
        .details-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px 20px; }
        .detail-item { margin-bottom: 10px; }
        .detail-item strong { display: block; color: var(--secondary); font-size: 0.9em; margin-bottom: 3px; }
        .detail-item span, .detail-item .value { font-size: 1em; color: var(--dark); word-wrap: break-word; }
        .status-badge { display: inline-block; padding: 4px 10px; border-radius: 20px; font-size: 12px; font-weight: 500; margin-left: 10px; }
        .status-active { background-color: #dcfce7; color: #166534; }
        .status-inactive { background-color: #fee2e2; color: #991b1b; }
        .form-note { background-color: #eff6ff; border-left: 4px solid var(--primary); padding: 12px 15px; margin-bottom: 20px; border-radius: 0 6px 6px 0; font-size: 14px; color: #1e40af; }
        .form-feedback { padding: 12px 15px; margin-bottom: 20px; border-radius: 6px; font-size: 14px; border-left-width: 4px; border-left-style: solid; font-weight: 500; }
        .form-feedback.success { background-color: #f0fdf4; border-color: var(--success); color: #15803d; }
        .form-feedback.error { background-color: #fef2f2; border-color: var(--danger); color: #b91c1c; }
        .product-categories-view .tag { background-color: #e0e7ff; color: #3730a3; border-radius: 15px; padding: 5px 12px; font-size: 13px; font-weight: 500; display: inline-block; margin-right: 8px; margin-bottom: 8px;}
        .data-table { width: 100%; border-collapse: collapse; margin-top: 15px; font-size: 0.9em;}
        .data-table th, .data-table td { border: 1px solid #e2e8f0; padding: 8px 10px; text-align: left; }
        .data-table th { background-color: #f8fafc; font-weight: 600; }
        .data-table tr:nth-child(even) { background-color: #fdfdff; }
        .data-table img { max-width: 40px; max-height: 40px; vertical-align: middle; margin-right: 5px; border-radius: 4px; }
        .no-data { text-align: center; padding: 15px; color: var(--secondary); }
        .modal-overlay { position: fixed; top: 0; left: 0; width: 100%; height: 100%; background-color: rgba(0,0,0,0.5); display: flex; justify-content: center; align-items: center; z-index: 1000; visibility: hidden; opacity: 0; transition: all 0.3s; }
        .modal-overlay.active { visibility: visible; opacity: 1; }
        .modal-content { background-color: white; border-radius: 8px; width: 400px; max-width: 90%; overflow: hidden; transform: translateY(-20px); transition: transform 0.3s; }
        .modal-overlay.active .modal-content { transform: translateY(0); }
        .modal-header { padding: 15px 20px; background-color: var(--danger); color: white; font-weight: 600; font-size: 16px;}
        .modal-body { padding: 20px; font-size:14px; line-height:1.5; }
        .modal-footer { padding: 15px 20px; display: flex; justify-content: flex-end; gap: 10px; border-top: 1px solid #f1f5f9; }
    </style>
</head>
<body>
    <div class="module-card">
        <div class="module-header">
             <% if (supplierToView != null && supplierToView.getSupplierId() > 0) { %>
                <span>View Supplier: <%= displayString(supplierToView.getCompanyName()) %></span>
                <span class="status-badge <%= supplierCurrentStatusCss %>"><%= displayString(supplierCurrentStatusDisplay) %></span>
            <% } else { %>
                <span>View Supplier</span>
            <% } %>
            <div class="module-header-actions">
                <a href="${pageContext.request.contextPath}/Admin/suppliers.jsp" class="btn btn-light"><i class="fas fa-list"></i> Back to List</a>
                <% if (supplierToView != null && supplierToView.getSupplierId() > 0) { %>
                    <a href="${pageContext.request.contextPath}/Admin/edit_supplier.jsp?id=<%= supplierToView.getSupplierId() %>" class="btn btn-primary"><i class="fas fa-edit"></i> Edit</a>
                    <button type="button" class="btn btn-danger" onclick="showDeleteModal()"><i class="fas fa-trash-alt"></i> Delete</button>
                <% } %>
            </div>
        </div>

        <div class="module-content">
            <% if (!feedbackMessage.isEmpty()) { %>
                <div class="form-feedback <%= feedbackClass %>">
                    <%= feedbackMessage %>
                </div>
            <% } %>

            <% if (supplierToView != null && supplierToView.getSupplierId() > 0) { %>
                <div class="form-note">
                    <strong>Supplier ID:</strong> <%= supplierDisplayId %>
                    | <strong>Status:</strong> <span class="status-badge <%= supplierCurrentStatusCss %>" style="margin-left:0;"><%= displayString(supplierCurrentStatusDisplay) %></span>
                </div>

                <div class="form-section">
                    <h3 class="form-section-title">Company Information</h3>
                    <div class="details-grid">
                        <div class="detail-item"><strong>Company Name:</strong> <span class="value"><%= displayString(supplierToView.getCompanyName()) %></span></div>
                        <div class="detail-item"><strong>Main Category:</strong> <span class="value"><%= displayString(supplierToView.getCategory()) %></span></div>
                        <div class="detail-item"><strong>Business Reg No:</strong> <span class="value"><%= displayString(supplierToView.getBusinessRegNo()) %></span></div>
                        <div class="detail-item"><strong>Tax ID:</strong> <span class="value"><%= displayString(supplierToView.getTaxId()) %></span></div>
                        <div class="detail-item" style="grid-column: span 2;"><strong>Company Address:</strong> <span class="value"><%= displayString(supplierToView.getCompanyAddress()) %></span></div>
                    </div>
                </div>
                
                <div class="form-section">
                    <h3 class="form-section-title">Primary Contact</h3>
                    <div class="details-grid">
                        <div class="detail-item"><strong>Contact Person:</strong> <span class="value"><%= displayString(supplierToView.getContactPerson()) %></span></div>
                        <div class="detail-item"><strong>Position:</strong> <span class="value"><%= displayString(supplierToView.getContactPosition()) %></span></div>
                        <div class="detail-item"><strong>Phone Number:</strong> <span class="value"><%= displayString(supplierToView.getContactPhone()) %></span></div>
                        <div class="detail-item"><strong>Email:</strong> <span class="value"><%= displayString(supplierToView.getContactEmail()) %></span></div>
                    </div>
                </div>

                <div class="form-section">
                    <h3 class="form-section-title">Payment & Terms</h3>
                    <div class="details-grid">
                        <div class="detail-item"><strong>Preferred Payment Method:</strong> <span class="value"><%= displayString(supplierToView.getPaymentMethod()) %></span></div>
                        <div class="detail-item"><strong>Payment Terms:</strong> <span class="value"><%= displayString(supplierToView.getPaymentTerms()) %></span></div>
                        <div class="detail-item"><strong>Credit Limit:</strong> <span class="value"><%= formatCurrency(supplierToView.getCreditLimit()) %></span></div>
                        <div class="detail-item"><strong>Delivery Terms:</strong> <span class="value"><%= displayString(supplierToView.getDeliveryTerms()) %></span></div>
                        <div class="detail-item"><strong>Average Lead Time:</strong> <span class="value"><%= formatInt(supplierToView.getLeadTime(), "N/A") %> Days</span></div>
                    </div>
                </div>

                <div class="form-section">
                    <h3 class="form-section-title">Products & Services (Supplied Categories)</h3>
                    <div class="product-categories-view">
                        <%
                            String cats = supplierToView.getProductCategories();
                            if (cats != null && !cats.trim().isEmpty()) {
                                String[] categoryArray = cats.split(",");
                                for (String cat : categoryArray) {
                                    if (!cat.trim().isEmpty()) {
                        %>
                                    <span class="tag"><%= cat.trim() %></span>
                        <%
                                    }
                                }
                            } else {
                        %>
                            <span class="value">N/A</span>
                        <%
                            }
                        %>
                    </div>
                </div>
                
                <div class="form-section">
                    <h3 class="form-section-title">Additional Notes</h3>
                    <p class="value"><%= displayString(supplierToView.getAdditionalNotes()).replace("\n", "<br>") %></p>
                </div>

                <div class="form-section">
                    <h3 class="form-section-title">Products from this Supplier (Max 10)</h3>
                    <% if (!productsBySupplier.isEmpty()) { %>
                        <table class="data-table">
                            <thead><tr><th>Image</th><th>SKU</th><th>Name</th><th>Category</th><th>Price</th><th>Stock</th></tr></thead>
                            <tbody>
                            <% for(Map<String, String> product : productsBySupplier) { %>
                                <tr>
                                    <td>
                                        <% String imgPath = product.get("image_path"); %>
                                        <% if (imgPath != null && !imgPath.isEmpty() && !imgPath.endsWith("default.jpg") && !imgPath.endsWith("placeholder-user.png")) { %>
                                            <img src="${pageContext.request.contextPath}/<%= imgPath.replace("\\\\", "/") %>" alt="<%= product.get("name") %>" >
                                        <% } else { %>
                                            <i class="fas fa-image fa-lg" style="color: #ccc; font-size:1.5em;"></i>
                                        <% } %>
                                    </td>
                                    <td><%= product.get("sku") %></td>
                                    <td><%= product.get("name") %></td>
                                    <td><%= product.get("category") %></td>
                                    <td><%= product.get("price") %></td>
                                    <td><%= product.get("stock") %></td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    <% } else { %>
                        <p class="no-data">No active products found for this supplier in the system.</p>
                    <% } %>
                </div>

                <div class="form-section">
                    <h3 class="form-section-title">Recent Purchase Orders (Max 10)</h3>
                     <% if (!purchaseOrdersBySupplier.isEmpty()) { %>
                        <table class="data-table">
                            <thead><tr><th>PO Number</th><th>Order Date</th><th>Total Amount</th><th>Status</th></tr></thead>
                            <tbody>
                            <% for(Map<String, String> po : purchaseOrdersBySupplier) { %>
                                <tr>
                                    <td><%= po.get("order_number_display") %></td>
                                    <td><%= po.get("order_date") %></td>
                                    <td><%= po.get("grand_total") %></td>
                                    <td><%= po.get("status") %></td>
                                </tr>
                            <% } %>
                            </tbody>
                        </table>
                    <% } else { %>
                        <p class="no-data">No purchase orders found for this supplier.</p>
                    <% } %>
                </div>

            <% } else if (feedbackMessage.isEmpty() && (supplierIdParam == null || supplierIdParam.trim().isEmpty())) { %>
                 <p class="form-feedback error">Please provide a supplier ID to view details (e.g., view_supplier.jsp?id=1).</p>
            <% } %>
        </div>
    </div>
    
    <div class="modal-overlay" id="deleteModal">
        <div class="modal-content">
            <div class="modal-header">Confirm Deletion</div>
            <div class="modal-body">
                <p>Are you sure you want to delete this supplier: <strong><%= (supplierToView != null && supplierToView.getCompanyName() != null) ? supplierToView.getCompanyName() : "N/A" %></strong> (ID: <%= supplierDisplayId %>)?</p>
                <p style="margin-top: 10px;">This action cannot be undone.</p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" onclick="closeDeleteModal()">Cancel</button>
                <button type="button" class="btn btn-danger" onclick="confirmDeleteSupplier()">Delete Supplier</button>
            </div>
        </div>
    </div>

    <form id="deleteSupplierForm" action="${pageContext.request.contextPath}/Admin/edit_supplier.jsp" method="POST" style="display:none;">
        <input type="hidden" name="supplierId" value="<%= (supplierToView != null && supplierToView.getSupplierId() > 0) ? supplierToView.getSupplierId() : "" %>">
        <input type="hidden" name="formAction" value="delete">
    </form>

    <script>
        function showDeleteModal() {
            const modal = document.getElementById('deleteModal');
            if(modal) modal.classList.add('active');
        }
        function closeDeleteModal() {
            const modal = document.getElementById('deleteModal');
            if(modal) modal.classList.remove('active');
        }
        function confirmDeleteSupplier() {
            const deleteForm = document.getElementById('deleteSupplierForm');
            if(deleteForm) {
                deleteForm.submit();
            }
        }
    </script>
</body>
</html>