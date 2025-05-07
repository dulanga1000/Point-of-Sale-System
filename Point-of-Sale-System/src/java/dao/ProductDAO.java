/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException; // Import SQLException
import java.util.ArrayList;
import java.util.List;
import model.Product;

/**
 *
 * @author User
 */

public class ProductDAO {
    private Connection conn;

    public ProductDAO(Connection conn) {
        this.conn = conn;
    }

    // Original addProduct method... (keep as is)
    public boolean addProduct(Product product) {
        String sql = "INSERT INTO products (name, category, price, sku, stock, supplier, image_path, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, product.getName());
            stmt.setString(2, product.getCategory());
            stmt.setDouble(3, product.getPrice());
            stmt.setString(4, product.getSku());
            stmt.setInt(5, product.getStock());
            stmt.setString(6, product.getSupplier());
            stmt.setString(7, product.getImagePath());
            stmt.setString(8, product.getStatus());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) { // Use SQLException
            e.printStackTrace();
        } catch (Exception e) { // Catch other potential exceptions
            e.printStackTrace();
        }
        return false;
    }

    // Original getAllProducts method... (keep as is, might be useful elsewhere but not for the paginated list display)
    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products";
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                products.add(new Product(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("category"),
                    rs.getDouble("price"),
                    rs.getString("sku"),
                    rs.getInt("stock"),
                    rs.getString("supplier"),
                    rs.getString("image_path"),
                    rs.getString("status")
                ));
            }
        } catch (SQLException e) {
             e.printStackTrace();
         } catch (Exception e) {
            e.printStackTrace();
        }
        return products;
    }

    // --- NEW METHOD FOR PAGINATION ---
    public List<Product> getProductsByPage(int itemsPerPage, int offset) {
        List<Product> products = new ArrayList<>();
        // SQL query to select a limited number of rows starting from an offset
        // LIMIT specifies the maximum number of rows to return
        // OFFSET specifies the number of rows to skip before starting to return rows
        String sql = "SELECT * FROM products LIMIT ? OFFSET ?"; // Standard MySQL/PostgreSQL syntax
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, itemsPerPage); // Set the limit
            stmt.setInt(2, offset);      // Set the offset
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    products.add(new Product(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("category"),
                        rs.getDouble("price"),
                        rs.getString("sku"),
                        rs.getInt("stock"),
                        rs.getString("supplier"),
                        rs.getString("image_path"),
                        rs.getString("status")
                    ));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (Exception e) {
             e.printStackTrace();
        }
        return products;
    }

    // --- NEW METHOD TO GET TOTAL PRODUCT COUNT ---
    public int getTotalProductCount() {
        String sql = "SELECT COUNT(*) FROM products";
        int count = 0;
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt(1); // Get the count from the first column
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (Exception e) {
             e.printStackTrace();
        }
        return count;
    }

    // --- NEW METHOD TO GET LOW STOCK COUNT (for stats) ---
    public int getLowStockCount(int threshold) {
        String sql = "SELECT COUNT(*) FROM products WHERE stock < ?";
        int count = 0;
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
             stmt.setInt(1, threshold);
             try (ResultSet rs = stmt.executeQuery()) {
                 if (rs.next()) {
                     count = rs.getInt(1);
                 }
             }
         } catch (SQLException e) {
             e.printStackTrace();
         } catch (Exception e) {
             e.printStackTrace();
         }
        return count;
    }

    // --- NEW METHOD TO GET UNIQUE CATEGORY COUNT (for stats) ---
     public int getUniqueCategoryCount() {
         String sql = "SELECT COUNT(DISTINCT category) FROM products WHERE category IS NOT NULL AND category != ''";
         int count = 0;
         try (PreparedStatement stmt = conn.prepareStatement(sql);
              ResultSet rs = stmt.executeQuery()) {
             if (rs.next()) {
                 count = rs.getInt(1);
             }
         } catch (SQLException e) {
             e.printStackTrace();
         } catch (Exception e) {
             e.printStackTrace();
         }
         return count;
     }


    // Original getProductById method... (keep as is)
    public Product getProductById(int id) {
        String sql = "SELECT * FROM products WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return new Product(
                        rs.getInt("id"),
                        rs.getString("name"),
                        rs.getString("category"),
                        rs.getDouble("price"),
                        rs.getString("sku"),
                        rs.getInt("stock"),
                        rs.getString("supplier"),
                        rs.getString("image_path"),
                        rs.getString("status")
                    );
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // Original deleteProduct method... (keep as is)
    public boolean deleteProduct(int id) {
        String sql = "DELETE FROM products WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }

    // Original updateProduct method... (keep as is)
    public boolean updateProduct(Product product) {
        String sql = "UPDATE products SET name=?, category=?, price=?, sku=?, stock=?, supplier=?, image_path=?, status=? WHERE id=?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, product.getName());
            stmt.setString(2, product.getCategory());
            stmt.setDouble(3, product.getPrice());
            stmt.setString(4, product.getSku());
            stmt.setInt(5, product.getStock());
            stmt.setString(6, product.getSupplier());
            stmt.setString(7, product.getImagePath());
            stmt.setString(8, product.getStatus());
            stmt.setInt(9, product.getId());
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        }
        return false;
    }
}