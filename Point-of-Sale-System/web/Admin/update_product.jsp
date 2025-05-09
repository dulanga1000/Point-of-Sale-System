<%-- 
    Document   : update_product
    Created on : May 6, 2025, 10:15:20 AM
    Author     : User
--%>

<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Update Product</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/Admin/styles.css">
</head>
<body>
    <%
        String productId = request.getParameter("id");
        if (productId == null || productId.isEmpty()) {
            response.sendRedirect("products.jsp");
            return;
        }
        
        // Variables to store product details
        String productName = "";
        String productCategory = "";
        double productPrice = 0.0;
        String productSku = "";
        int productStock = 0;
        String productSupplier = "";
        String productImagePath = "";
        String productStatus = "";
        
        // Database connection details
        String dbUrl = "jdbc:mysql://localhost:3306/Swift_Database";
        String dbUser = "root";
        String dbPassword = ""; // Update with your actual password if needed
        
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        
        try {
            // Load the JDBC driver
            Class.forName("com.mysql.cj.jdbc.Driver");
            
            // Establish connection
            conn = DriverManager.getConnection(dbUrl, dbUser, dbPassword);
            
            // Prepare and execute query
            String query = "SELECT * FROM products WHERE id = ?";
            pstmt = conn.prepareStatement(query);
            pstmt.setInt(1, Integer.parseInt(productId));
            rs = pstmt.executeQuery();
            
            if (rs.next()) {
                productName = rs.getString("name");
                productCategory = rs.getString("category");
                productPrice = rs.getDouble("price");
                productSku = rs.getString("sku");
                productStock = rs.getInt("stock");
                productSupplier = rs.getString("supplier");
                productImagePath = rs.getString("image_path");
                productStatus = rs.getString("status");
            } else {
                // Product not found, redirect back to products page
                response.sendRedirect("products.jsp?error=product_not_found");
                return;
            }
        } catch (Exception e) {
            e.printStackTrace();
            // Handle error, maybe redirect with error message
            response.sendRedirect("products.jsp?error=db_error");
            return;
        } finally {
            // Close database resources
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
                if (conn != null) conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    %>

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
                <h1 class="page-title">Update Product</h1>
                <div class="user-profile">
                    <img src="${pageContext.request.contextPath}/Images/logo.png" alt="Admin Profile">
                    <div>
                        <h4>Admin User</h4>
                    </div>
                </div>
            </div>

            <div class="product-form-container">
                <% if (request.getParameter("success") != null) { %>
                    <div class="product-success-message">
                        Product updated successfully!
                        <button type="button" class="close-btn" onclick="this.parentElement.style.display='none'"></button>
                    </div>
                <% } %>
                
                <% 
                    String error = request.getParameter("error");
                    if (error != null) {
                        String errorMessage = "";
                        switch(error) {
                            case "upload_dir_failed":
                                errorMessage = "Failed to create upload directory. Please try again.";
                                break;
                            case "file_save_failed":
                                errorMessage = "Failed to save the image file. Please try again.";
                                break;
                            case "file_save_error":
                                errorMessage = "Error occurred while saving the image. Please try again.";
                                break;
                            case "dir_not_writable":
                                errorMessage = "Upload directory is not writable. Please contact administrator.";
                                break;
                            default:
                                errorMessage = "An error occurred. Please try again.";
                        }
                %>
                    <div class="error-message">
                        <%= errorMessage %>
                        <button type="button" class="close-btn" onclick="this.parentElement.style.display='none'"></button>
                    </div>
                <% } %>

                <form action="${pageContext.request.contextPath}/updateProduct" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="product_id" value="<%= productId %>">
                    <input type="hidden" name="current_image_path" value="<%= productImagePath %>">
                    
                    <div class="product-form-group">
                        <label for="product_name">Product Name</label>
                        <input type="text" id="product_name" name="product_name" value="<%= productName %>" required>
                    </div>

                    <div class="product-form-group">
                        <label for="product_category">Category</label>
                        <select id="product_category" name="product_category" required>
                            <option value="">Select Category</option>
                            <option value="Food" <%= productCategory.equals("Food") ? "selected" : "" %>>Food</option>
                            <option value="Beverages" <%= productCategory.equals("Beverages") ? "selected" : "" %>>Beverages</option>
                            <option value="Electronics" <%= productCategory.equals("Electronics") ? "selected" : "" %>>Electronics</option>
                            <option value="Clothing" <%= productCategory.equals("Clothing") ? "selected" : "" %>>Clothing</option>
                            <option value="Home Goods" <%= productCategory.equals("Home Goods") ? "selected" : "" %>>Home Goods</option>
                            <option value="Books" <%= productCategory.equals("Books") ? "selected" : "" %>>Books</option>
                            <option value="Stationery" <%= productCategory.equals("Stationery") ? "selected" : "" %>>Stationery</option>
                            <option value="Accessories" <%= productCategory.equals("Accessories") ? "selected" : "" %>>Accessories</option>
                        </select>
                    </div>

                    <div class="product-form-group">
                        <label for="product_price">Price (Rs.)</label>
                        <input type="number" id="product_price" name="product_price" value="<%= productPrice %>" step="0.01" min="0" required>
                    </div>

                    <div class="product-form-group">
                        <label for="product_sku">SKU</label>
                        <input type="text" id="product_sku" name="product_sku" value="<%= productSku %>" 
                               pattern="[A-Z0-9!@#$%^&*()_+\-=\[\]{};':&quot;\\|,.<>\/?]*"
                               title="Only capital letters, numbers, and symbols are allowed"
                               oninput="this.value = this.value.toUpperCase();"
                               required>
                        <small class="product-form-text">Only capital letters, numbers, and symbols are allowed</small>
                    </div>

                    <div class="product-form-group">
                        <label for="product_stock">Stock</label>
                        <input type="number" id="product_stock" name="product_stock" value="<%= productStock %>" min="0" required>
                    </div>

                    <div class="product-form-group">
                        <label for="product_supplier">Supplier</label>
                        <select id="product_supplier" name="product_supplier" required>
                            <option value="">Select Supplier</option>
                            <option value="Global Coffee Co." <%= productSupplier.equals("Global Coffee Co.") ? "selected" : "" %>>Global Coffee Co.</option>
                            <option value="Dairy Farms Inc." <%= productSupplier.equals("Dairy Farms Inc.") ? "selected" : "" %>>Dairy Farms Inc.</option>
                            <option value="Sweet Supplies Ltd." <%= productSupplier.equals("Sweet Supplies Ltd.") ? "selected" : "" %>>Sweet Supplies Ltd.</option>
                            <option value="Package Solutions" <%= productSupplier.equals("Package Solutions") ? "selected" : "" %>>Package Solutions</option>
                            <option value="Flavor Masters" <%= productSupplier.equals("Flavor Masters") ? "selected" : "" %>>Flavor Masters</option>
                            <option value="Tea Suppliers" <%= productSupplier.equals("Tea Suppliers") ? "selected" : "" %>>Tea Suppliers</option>
                            <option value="Pastry Partners" <%= productSupplier.equals("Pastry Partners") ? "selected" : "" %>>Pastry Partners</option>
                            <option value="Sandwich Supplies" <%= productSupplier.equals("Sandwich Supplies") ? "selected" : "" %>>Sandwich Supplies</option>
                            <option value="Accessory World" <%= productSupplier.equals("Accessory World") ? "selected" : "" %>>Accessory World</option>
                        </select>
                    </div>

                    <div class="product-form-group">
                        <label for="product_status">Status</label>
                        <select id="product_status" name="product_status" required>
                            <option value="Active" <%= productStatus.equals("Active") ? "selected" : "" %>>Active</option>
                            <option value="Inactive" <%= productStatus.equals("Inactive") ? "selected" : "" %>>Inactive</option>
                            <option value="Out of Stock" <%= productStatus.equals("Out of Stock") ? "selected" : "" %>>Out of Stock</option>
                        </select>
                    </div>

                    <div class="product-form-group">
                        <label for="productImage">Product Image</label>
                        <input type="file" id="productImage" name="productImage" accept="image/*" onchange="previewImage(this)">
                        <small class="product-form-text">Max file size: 5MB. Supported formats: JPG, PNG, GIF</small>
                        <div class="product-image-preview" id="imagePreview">
                            <img src="${pageContext.request.contextPath}/<%= productImagePath %>" alt="Product Image Preview" id="preview">
                        </div>
                    </div>

                    <div class="product-form-actions">
                        <button type="submit" class="product-btn-primary">Update Product</button>
                        <button type="button" class="product-btn-secondary" onclick="window.location.href='${pageContext.request.contextPath}/Admin/products.jsp'">Cancel</button>
                    </div>
                </form>
            </div>

            <div class="footer">
                Swift © 2025.
            </div>
        </div>
    </div>

    <script>
        function previewImage(input) {
            const preview = document.getElementById('preview');
            const file = input.files[0];
            
            if (file) {
                // Check file size (5MB limit)
                if (file.size > 5 * 1024 * 1024) {
                    alert('File size must be less than 5MB');
                    input.value = '';
                    return;
                }

                // Check file type
                if (!file.type.startsWith('image/')) {
                    alert('Please select an image file');
                    input.value = '';
                    return;
                }

                const reader = new FileReader();
                reader.onload = function(e) {
                    preview.src = e.target.result;
                }
                reader.readAsDataURL(file);
            } else {
                preview.src = '${pageContext.request.contextPath}/<%= productImagePath %>';
            }
        }

        // Mobile navigation toggle
        const mobileNavToggle = document.getElementById('mobileNavToggle');
        const sidebar = document.getElementById('sidebar');

        if (mobileNavToggle && sidebar) {
            mobileNavToggle.addEventListener('click', () => {
                sidebar.classList.toggle('active');
            });
        }
    </script>
</body>
</html>