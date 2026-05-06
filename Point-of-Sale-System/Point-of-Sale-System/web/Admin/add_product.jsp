<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.sql.*" %>
<%@ page import="jakarta.servlet.http.*, jakarta.servlet.*" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Add New Product</title>
    <link rel="stylesheet" href="${pageContext.request.contextPath}/Admin/styles.css">
</head>
<body>
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
                <h1 class="page-title">Add New Product</h1>
                <div class="user-profile">
                    <%
    Connection userConn = null;
    String URL = "jdbc:mysql://localhost:3306/Swift_Database";
    String USER = "root";
    String PASSWORD = "";

    try {
        Class.forName("com.mysql.jdbc.Driver"); // Load the driver explicitly
        userConn = DriverManager.getConnection(URL, USER, PASSWORD);
        PreparedStatement sql = userConn.prepareStatement("SELECT * FROM users WHERE role = 'admin' LIMIT 1");
        ResultSet result = sql.executeQuery();

        if (result.next()) { %>
            <img src="${pageContext.request.contextPath}/<%= result.getString("profile_image_path") %>" alt="Admin Profile">
            <div>
                <h4><%= result.getString("first_name") %></h4>
            </div>
        <% }
        result.close();
        sql.close();
    } catch (Exception ex) {
        out.println("<p class='text-danger text-center'>Error: " + ex.getMessage() + "</p>");
    } finally {
        if (userConn != null) {
            try {
                userConn.close();
            } catch (SQLException e) {
                // Log the error but continue
                e.printStackTrace();
            }
        }
    }
%>
                </div>
            </div>

            <div class="product-form-container">
                <% if (request.getParameter("success") != null) { %>
                    <div class="product-success-message">
                        Product added successfully!
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
                            case "sku_exists":
                                errorMessage = "A product with this SKU already exists. Please use a different SKU.";
                                break;
                            case "invalid_sku":
                                errorMessage = "Invalid SKU format. Please use only capital letters, numbers, and symbols.";
                                break;
                            case "missing_fields":
                                errorMessage = "Please fill in all required fields.";
                                break;
                            case "db_error":
                                errorMessage = "Database error occurred. Please try again.";
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

                <form action="${pageContext.request.contextPath}/AddProductServlet" method="POST" enctype="multipart/form-data">
                    <div class="product-form-group">
                        <label for="product_name">Product Name</label>
                        <input type="text" id="product_name" name="product_name" required>
                    </div>

                    <div class="product-form-group">
                        <label for="product_category">Category</label>
                        <select id="product_category" name="product_category" required>
                            <option value="">Select Category</option>
                            <option value="Food">Food</option>
                            <option value="Beverages">ingredients</option>
                            <option value="Electronics">dairy</option>
                            <option value="Clothing">packaging</option>
                            <option value="Home Goods">equipment</option>
                            <option value="Home Goods">beverages</option>
                        </select>
                    </div>

                    <div class="product-form-group">
                        <label for="product_price">Price (Rs.)</label>
                        <input type="number" id="product_price" name="product_price" step="0.01" min="0" required>
                    </div>

                    <div class="product-form-group">
                        <label for="product_sku">SKU</label>
                        <input type="text" id="product_sku" name="product_sku" 
                               pattern="[A-Z0-9!@#$%^&*()_+\-=\[\]{};':&quot;\\|,.<>\/?]*"
                               title="Only capital letters, numbers, and symbols are allowed"
                               oninput="this.value = this.value.toUpperCase();"
                               required>
                        <small class="product-form-text">Only capital letters, numbers, and symbols are allowed</small>
                    </div>

                    <div class="product-form-group">
                        <label for="product_stock">Stock</label>
                        <input type="number" id="product_stock" name="product_stock" min="0" required>
                    </div>

                    <div class="product-form-group">
                        <label for="product_supplier">Supplier</label>
                        <select id="product_supplier" name="product_supplier" required>
                            <option value="">Select Supplier</option>
                            <option value="Global Coffee Co.">Global Coffee Co.</option>
                            <option value="Dairy Farms Inc.">Dairy Farms Inc.</option>
                            <option value="Sweet Supplies Ltd.">Sweet Supplies Ltd.</option>
                            <option value="Package Solutions">Package Solutions</option>
                            <option value="Flavor Masters">Flavor Masters</option>
                            <option value="Tea Suppliers">Tea Suppliers</option>
                            <option value="Pastry Partners">Pastry Partners</option>
                            <option value="Sandwich Supplies">Sandwich Supplies</option>
                            <option value="Accessory World">Accessory World</option>
                        </select>
                    </div>

                    <div class="product-form-group">
                        <label for="product_status">Status</label>
                        <select id="product_status" name="product_status" required>
                            <option value="Active">Active</option>
                            <option value="Inactive">Inactive</option>
                            <option value="Out of Stock">Out of Stock</option>
                        </select>
                    </div>

                    <div class="product-form-group">
                        <label for="productImage">Product Image</label>
                        <input type="file" id="productImage" name="productImage" accept="image/*" onchange="previewImage(this)">
                        <small class="product-form-text">Max file size: 5MB. Supported formats: JPG, PNG, GIF</small>
                        <div class="product-image-preview" id="imagePreview">
                            <img src="${pageContext.request.contextPath}/Images/default.jpg" alt="Product Image Preview" id="preview">
                        </div>
                    </div>

                    <div class="product-form-actions">
                        <button type="submit" class="product-btn-primary">Add Product</button>
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
                preview.src = '${pageContext.request.contextPath}/Images/default.jpg';
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