/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.ProductModel;
import model.SupplierModel;
import util.DBConnection; // Your database connection class

import java.sql.*;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;
import java.math.BigDecimal;

public class CompanyDAO {
    private static final Logger LOGGER = Logger.getLogger(CompanyDAO.class.getName());

    public List<SupplierModel> getAllSuppliers() {
        List<SupplierModel> suppliers = new ArrayList<>();
        // Fetches only active suppliers to populate the dropdown
        String sql = "SELECT supplier_id, company_name FROM suppliers WHERE supplier_status = 'Active' ORDER BY company_name ASC";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                SupplierModel supplier = new SupplierModel();
                supplier.setSupplierId(rs.getInt("supplier_id"));
                supplier.setCompanyName(rs.getString("company_name"));
                suppliers.add(supplier);
            }
            LOGGER.info("Successfully retrieved " + suppliers.size() + " active suppliers.");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching all suppliers: " + e.getMessage(), e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return suppliers;
    }

    public SupplierModel getSupplierById(int supplierId) {
        SupplierModel supplier = null;
        String sql = "SELECT supplier_id, company_name FROM suppliers WHERE supplier_id = ?";
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, supplierId);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                supplier = new SupplierModel();
                supplier.setSupplierId(rs.getInt("supplier_id"));
                supplier.setCompanyName(rs.getString("company_name"));
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching supplier by ID: " + supplierId, e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return supplier;
    }

    public List<ProductModel> getProductsByCriteria(String supplierNameFilter, String categoryFilter, Integer minStockFilter, BigDecimal minPriceFilter, BigDecimal maxPriceFilter) {
        List<ProductModel> products = new ArrayList<>();
        StringBuilder sqlBuilder = new StringBuilder("SELECT id, name, category, price, sku, stock, supplier, image_path, status FROM products WHERE status = 'Active'"); // Also filter by active products
        List<Object> params = new ArrayList<>();

        // IMPORTANT: This filter relies on supplierNameFilter (which is a company_name from 'suppliers' table)
        // to EXACTLY MATCH the string stored in the 'products.supplier' column.
        // If they don't match (e.g. 'Cylon' vs 'Dairy Farms Inc.'), no products will be found for that supplier.
        if (supplierNameFilter != null && !supplierNameFilter.isEmpty()) {
            sqlBuilder.append(" AND supplier = ?");
            params.add(supplierNameFilter);
        }

        if (categoryFilter != null && !categoryFilter.isEmpty()) {
            sqlBuilder.append(" AND category = ?");
            params.add(categoryFilter);
        }

        if (minStockFilter != null) {
            sqlBuilder.append(" AND stock >= ?");
            params.add(minStockFilter);
        }

        if (minPriceFilter != null) {
            sqlBuilder.append(" AND price >= ?");
            params.add(minPriceFilter);
        }

        if (maxPriceFilter != null) {
            sqlBuilder.append(" AND price <= ?");
            params.add(maxPriceFilter);
        }

        sqlBuilder.append(" ORDER BY name ASC");

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            pstmt = conn.prepareStatement(sqlBuilder.toString());

            for (int i = 0; i < params.size(); i++) {
                pstmt.setObject(i + 1, params.get(i));
            }

            LOGGER.info("Executing product query: " + pstmt.toString());
            rs = pstmt.executeQuery();

            while (rs.next()) {
                ProductModel product = new ProductModel();
                product.setId(rs.getInt("id"));
                product.setName(rs.getString("name"));
                product.setCategory(rs.getString("category"));
                product.setPrice(rs.getBigDecimal("price")); // Use getBigDecimal
                product.setSku(rs.getString("sku"));
                product.setStock(rs.getInt("stock"));
                product.setSupplierName(rs.getString("supplier")); // Name from products table
                product.setImagePath(rs.getString("image_path"));
                product.setStatus(rs.getString("status"));
                products.add(product);
            }
            LOGGER.info("Successfully retrieved " + products.size() + " products matching criteria.");
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error fetching products by criteria: " + e.getMessage(), e);
        } finally {
            closeResources(conn, pstmt, rs);
        }
        return products;
    }

    private void closeResources(Connection conn, Statement stmt, ResultSet rs) {
        try {
            if (rs != null) rs.close();
            if (stmt != null) stmt.close();
        } catch (SQLException e) {
            LOGGER.log(Level.WARNING, "Error closing statement or result set: " + e.getMessage(), e);
        }
        if (conn != null) {
            DBConnection.closeConnection(conn); // Call your utility method
        }
    }
}