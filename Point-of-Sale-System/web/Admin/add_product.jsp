<%-- 
    Document   : add_product
    Created on : May 5, 2025, 8:34:17 PM
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
    <title>Add Product</title>
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
    <div class="pos-container">
        <div class="top-bar">
            <a href="products.jsp" class="back-button">
                <svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                    <path d="M19 12H5M12 19l-7-7 7-7"/>
                </svg>
                Back to Products
            </a>
            <div class="form-title">Add New Product</div>
        </div>
        
        <form action="addProduct" method="POST" enctype="multipart/form-data">
            <div class="input-group">
                <label for="product_name">Product Name</label>
                <input type="text" id="product_name" name="product_name" placeholder="Enter product name" required>
            </div>

            <div class="input-group">
                <label for="product_category">Category</label>
                <select id="product_category" name="product_category" required>
                    <option value="">Select Category</option>
                    <option value="Coffee">Coffee</option>
                    <option value="Tea">Tea</option>
                    <option value="Pastries">Pastries</option>
                    <option value="Sandwiches">Sandwiches</option>
                    <option value="Accessories">Accessories</option>
                    <option value="Dairy">Dairy</option>
                    <option value="Syrups">Syrups</option>
                    <option value="Supplies">Supplies</option>
                </select>
            </div>

            <div class="input-group">
                <label for="product_price">Price ($)</label>
                <input type="number" id="product_price" name="product_price" placeholder="0.00" step="0.01" min="0" required>
            </div>

            <div class="input-group">
                <label for="product_sku">SKU</label>
                <input type="text" id="product_sku" name="product_sku" placeholder="Enter product SKU"
                       pattern="[A-Z0-9!@#$%^&*()_+\-=\[\]{};':&quot;\\|,.<>\/?]*"
                       title="Only capital letters, numbers, and symbols are allowed"
                       oninput="this.value = this.value.toUpperCase();"
                       required>
            </div>

            <div class="input-group">
                <label for="product_stock">Stock</label>
                <input type="number" id="product_stock" name="product_stock" placeholder="0" step="1" min="0" required>
            </div>

            <div class="input-group">
                <label for="product_supplier">Supplier</label>
                <select id="product_supplier" name="product_supplier" required>
                    <option value="">Select Category</option>
                    <option value="Coffee">Coffee</option>
                    <option value="Tea">Tea</option>
                    <option value="Pastries">Pastries</option>
                    <option value="Sandwiches">Sandwiches</option>
                    <option value="Accessories">Accessories</option>
                    <option value="Dairy">Dairy</option>
                    <option value="Syrups">Syrups</option>
                    <option value="Supplies">Supplies</option>
                </select>
            </div>

            <div class="input-group">
                <label for="product_image">Product Image</label>
                <input type="file" id="product_image" name="product_image" accept="image/*" required>
            </div>
            
            <div class="input-group">
                <label for="product_status">Status</label>
                <select id="product_status" name="product_status" required>
                    <option value="">Select Category</option>
                    <option value="Active">Active</option>
                    <option value="Low Stock">Low Stock</option>
                    <option value="Deactivate">Deactivate</option>
                </select>
            </div>

            <div class="btn-container">
                <button type="submit" class="btn btn-primary">Add Product</button>
            </div>
        </form>
    </div>
</body>
</html>