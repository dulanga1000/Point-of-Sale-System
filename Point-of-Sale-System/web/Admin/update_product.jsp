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
    <style>
        :root {
            --primary-color: #4361ee;
            --primary-hover: #3a56d4;
            --text-color: #333;
            --secondary-text: #666;
            --border-color: #e0e0e0;
            --background: #f8f9fa;
            --card-bg: #ffffff;
            --success: #2ecc71;
            --danger: #e74c3c;
        }

        * {
            box-sizing: border-box;
            margin: 0;
            padding: 0;
        }

        body {
            font-family: 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, 'Open Sans', sans-serif;
            background-color: var(--background);
            color: var(--text-color);
            line-height: 1.6;
            display: flex;
            justify-content: center;
            align-items: center;
            min-height: 100vh;
            margin: 0;
            padding: 20px;
            flex-direction: column;
        }

        .header {
            font-size: 28px;
            font-weight: 600;
            margin-bottom: 20px;
            color: var(--text-color);
            text-align: center;
        }

        .pos-container {
            background-color: var(--card-bg);
            padding: 40px;
            border-radius: 12px;
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.08);
            width: 100%;
            max-width: 650px;
            transition: all 0.3s ease;
        }

        .top-bar {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 30px;
        }

        .back-button {
            display: flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
            color: var(--secondary-text);
            font-weight: 500;
            font-size: 16px;
            transition: all 0.2s ease;
            padding: 8px 12px;
            border-radius: 6px;
        }

        .back-button:hover {
            background-color: rgba(0, 0, 0, 0.05);
            color: var(--primary-color);
        }

        .back-button svg {
            width: 20px;
            height: 20px;
        }

        .form-title {
            font-size: 24px;
            font-weight: 600;
        }

        .input-group {
            margin-bottom: 24px;
        }

        label {
            display: block;
            font-size: 16px;
            font-weight: 500;
            color: var(--secondary-text);
            margin-bottom: 8px;
        }

        input, textarea, select {
            width: 100%;
            padding: 14px 16px;
            font-size: 16px;
            border: 1px solid var(--border-color);
            border-radius: 8px;
            background-color: var(--card-bg);
            color: var(--text-color);
            transition: all 0.2s ease;
        }

        input[type="file"] {
            padding: 10px;
            background-color: var(--background);
            cursor: pointer;
        }

        select {
            cursor: pointer;
            appearance: none;
            background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' width='24' height='24' viewBox='0 0 24 24' fill='none' stroke='%23666' stroke-width='2' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpolyline points='6 9 12 15 18 9'%3E%3C/polyline%3E%3C/svg%3E");
            background-repeat: no-repeat;
            background-position: right 16px center;
            background-size: 16px;
            padding-right: 40px;
        }

        input:focus, textarea:focus, select:focus {
            outline: none;
            border-color: var(--primary-color);
            box-shadow: 0 0 0 3px rgba(67, 97, 238, 0.15);
        }

        .btn-container {
            display: flex;
            gap: 10px;
            margin-top: 10px;
        }

        .btn {
            font-size: 16px;
            font-weight: 600;
            padding: 14px 20px;
            border: none;
            border-radius: 8px;
            cursor: pointer;
            transition: all 0.2s ease;
            flex: 1;
            text-align: center;
        }

        .btn-primary {
            background-color: var(--primary-color);
            color: white;
        }

        .btn-primary:hover {
            background-color: var(--primary-hover);
            box-shadow: 0 4px 12px rgba(67, 97, 238, 0.2);
        }

        .success-message {
            background-color: var(--success);
            color: white;
            padding: 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: none;
        }

        .error-message {
            background-color: var(--danger);
            color: white;
            padding: 16px;
            border-radius: 8px;
            margin-bottom: 20px;
            display: none;
        }

        @media (max-width: 768px) {
            .pos-container {
                padding: 30px 20px;
            }
            
            .header {
                font-size: 24px;
            }
            
            .form-title {
                font-size: 20px;
            }
        }
    </style>
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

    <div class="pos-container">
        <div class="top-bar">
            <a href="products.jsp" class="back-button">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M19 12H5M12 19l-7-7 7-7"/>
                </svg>
                Back to Products
            </a>
            <div class="form-title">Update Product</div>
        </div>
        
        <% if (request.getParameter("success") != null) { %>
            <div class="success-message" style="display: block;">
                Product updated successfully!
            </div>
        <% } %>
        
        <% if (request.getParameter("error") != null) { %>
            <div class="error-message" style="display: block;">
                Error: <%= request.getParameter("error").equals("db_error") ? "Database error occurred" : 
                          request.getParameter("error").equals("file_upload") ? "File upload error" : 
                          "An unexpected error occurred" %>
            </div>
        <% } %>
        
        <form action="/Point-of-Sale-System/updateProduct" method="POST" enctype="multipart/form-data">
            <input type="hidden" name="product_id" value="<%= productId %>">
            
            <div class="input-group">
                <label for="product_name">Product Name</label>
                <input type="text" id="product_name" name="product_name" value="<%= productName %>" placeholder="Enter product name" required>
            </div>

            <div class="input-group">
                <label for="product_category">Category</label>
                <select id="product_category" name="product_category" required>
                    <option value="">Select Category</option>
                    <option value="Coffee" <%= productCategory.equals("Coffee") ? "selected" : "" %>>Coffee</option>
                    <option value="Tea" <%= productCategory.equals("Tea") ? "selected" : "" %>>Tea</option>
                    <option value="Pastries" <%= productCategory.equals("Pastries") ? "selected" : "" %>>Pastries</option>
                    <option value="Sandwiches" <%= productCategory.equals("Sandwiches") ? "selected" : "" %>>Sandwiches</option>
                    <option value="Accessories" <%= productCategory.equals("Accessories") ? "selected" : "" %>>Accessories</option>
                    <option value="Dairy" <%= productCategory.equals("Dairy") ? "selected" : "" %>>Dairy</option>
                    <option value="Syrups" <%= productCategory.equals("Syrups") ? "selected" : "" %>>Syrups</option>
                    <option value="Supplies" <%= productCategory.equals("Supplies") ? "selected" : "" %>>Supplies</option>
                </select>
            </div>

            <div class="input-group">
                <label for="product_price">Price ($)</label>
                <input type="number" id="product_price" name="product_price" value="<%= productPrice %>" placeholder="0.00" step="0.01" min="0" required>
            </div>

            <div class="input-group">
                <label for="product_sku">SKU</label>
                <input type="text" id="product_sku" name="product_sku" value="<%= productSku %>" placeholder="Enter product SKU"
                       pattern="[A-Z0-9!@#$%^&*()_+\-=\[\]{};':&quot;\\|,.<>\/?]*"
                       title="Only capital letters, numbers, and symbols are allowed"
                       oninput="this.value = this.value.toUpperCase();"
                       required>
            </div>

            <div class="input-group">
                <label for="product_stock">Stock</label>
                <input type="number" id="product_stock" name="product_stock" value="<%= productStock %>" placeholder="0" step="1" min="0" required>
            </div>

            <div class="input-group">
                <label for="product_supplier">Supplier</label>
                <select id="product_supplier" name="product_supplier" required>
                    <option value="">Select Supplier</option>
                    <option value="Coffee" <%= productSupplier.equals("Coffee") ? "selected" : "" %>>Coffee</option>
                    <option value="Tea" <%= productSupplier.equals("Tea") ? "selected" : "" %>>Tea</option>
                    <option value="Pastries" <%= productSupplier.equals("Pastries") ? "selected" : "" %>>Pastries</option>
                    <option value="Sandwiches" <%= productSupplier.equals("Sandwiches") ? "selected" : "" %>>Sandwiches</option>
                    <option value="Accessories" <%= productSupplier.equals("Accessories") ? "selected" : "" %>>Accessories</option>
                    <option value="Dairy" <%= productSupplier.equals("Dairy") ? "selected" : "" %>>Dairy</option>
                    <option value="Syrups" <%= productSupplier.equals("Syrups") ? "selected" : "" %>>Syrups</option>
                    <option value="Supplies" <%= productSupplier.equals("Supplies") ? "selected" : "" %>>Supplies</option>
                </select>
            </div>

            <div class="input-group">
                <label for="product_image">Product Image (leave empty to keep current image)</label>
                <input type="file" id="product_image" name="product_image" accept="image/*">
                <input type="hidden" name="current_image_path" value="<%= productImagePath %>">
                <% if (productImagePath != null && !productImagePath.isEmpty()) { %>
                    <p style="margin-top: 8px; font-size: 14px;">Current image: <%= productImagePath %></p>
                <% } %>
            </div>
            
            <div class="input-group">
                <label for="product_status">Status</label>
                <select id="product_status" name="product_status" required>
                    <option value="">Select Status</option>
                    <option value="Active" <%= productStatus.equals("Active") ? "selected" : "" %>>Active</option>
                    <option value="Low Stock" <%= productStatus.equals("Low Stock") ? "selected" : "" %>>Low Stock</option>
                    <option value="Deactivate" <%= productStatus.equals("Deactivate") ? "selected" : "" %>>Deactivate</option>
                </select>
            </div>

            <div class="btn-container">
                <button type="submit" class="btn btn-primary">Update Product</button>
            </div>
        </form>
    </div>
    
    <script>
        // Fade out success/error messages after 5 seconds
        window.addEventListener('load', function() {
            setTimeout(function() {
                const successMessage = document.querySelector('.success-message');
                const errorMessage = document.querySelector('.error-message');
                
                if (successMessage && successMessage.style.display === 'block') {
                    successMessage.style.opacity = '0';
                    successMessage.style.transition = 'opacity 0.5s ease';
                    setTimeout(function() {
                        successMessage.style.display = 'none';
                    }, 500);
                }
                
                if (errorMessage && errorMessage.style.display === 'block') {
                    errorMessage.style.opacity = '0';
                    errorMessage.style.transition = 'opacity 0.5s ease';
                    setTimeout(function() {
                        errorMessage.style.display = 'none';
                    }, 500);
                }
            }, 5000);
        });
    </script>
</body>
</html>