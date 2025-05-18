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
 * @author User / dulan
 */
public class ProductDAO {
    private Connection conn;

    public ProductDAO(Connection conn) {
        this.conn = conn;
    }

    // --- Helper Method to Map ResultSet to Product ---
    private Product mapRowToProduct(ResultSet rs) throws SQLException {
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
            System.err.println("SQL Error adding product: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) { // Catch other potential exceptions
             System.err.println("Error adding product: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // Original getAllProducts method (fetches all products, no filters)
    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        // Added ORDER BY for consistent display
        String sql = "SELECT * FROM products ORDER BY name ASC";
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                products.add(mapRowToProduct(rs));
            }
        } catch (SQLException e) {
            System.err.println("SQL Error getting all products: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
             System.err.println("Error getting all products: " + e.getMessage());
            e.printStackTrace();
        }
        return products;
    }

    // *** NEW: Method to get all unique categories ***
    public List<String> getAllCategories() {
        List<String> categories = new ArrayList<>();
        // Select distinct, non-null, non-empty categories and order them
        String sql = "SELECT DISTINCT category FROM products WHERE category IS NOT NULL AND category != '' ORDER BY category ASC";
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                categories.add(rs.getString("category"));
            }
        } catch (SQLException e) {
            System.err.println("SQL Error getting categories: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
             System.err.println("Error getting categories: " + e.getMessage());
            e.printStackTrace();
        }
        return categories;
    }

    // *** NEW: Method to search products by name or SKU (fetches all matches) ***
    public List<Product> searchProducts(String query) {
        List<Product> products = new ArrayList<>();
        // Use LIKE for partial matching, trim query, add wildcards
        String sql = "SELECT * FROM products WHERE LOWER(name) LIKE LOWER(?) OR LOWER(sku) LIKE LOWER(?) ORDER BY name ASC";
        String searchTerm = "%" + query.trim() + "%"; // Add wildcards for LIKE

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, searchTerm); // Set parameter for name search
            stmt.setString(2, searchTerm); // Set parameter for sku search
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    products.add(mapRowToProduct(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("SQL Error searching products: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error searching products: " + e.getMessage());
            e.printStackTrace();
        }
        return products;
    }

    // *** NEW: Method to get products by category (fetches all matches) ***
    public List<Product> getProductsByCategory(String category) {
        List<Product> products = new ArrayList<>();
        // Exact match for category, order by name
        String sql = "SELECT * FROM products WHERE category = ? ORDER BY name ASC";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, category); // Set category parameter
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    products.add(mapRowToProduct(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("SQL Error getting products by category: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error getting products by category: " + e.getMessage());
            e.printStackTrace();
        }
        return products;
    }


    // --- Methods below might be useful for admin/other parts, keep them ---

    // getProductsByPage (for potential future pagination)
    public List<Product> getProductsByPage(int itemsPerPage, int offset) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products ORDER BY name ASC LIMIT ? OFFSET ?"; // Added ORDER BY
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, itemsPerPage); // Set the limit
            stmt.setInt(2, offset);       // Set the offset
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    products.add(mapRowToProduct(rs));
                }
            }
        } catch (SQLException e) {
            System.err.println("SQL Error getting products by page: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
             System.err.println("Error getting products by page: " + e.getMessage());
            e.printStackTrace();
        }
        return products;
    }

    // getTotalProductCount (for potential future pagination)
    public int getTotalProductCount() {
        String sql = "SELECT COUNT(*) FROM products";
        int count = 0;
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt(1); // Get the count from the first column
            }
        } catch (SQLException e) {
            System.err.println("SQL Error getting total product count: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error getting total product count: " + e.getMessage());
            e.printStackTrace();
        }
        return count;
    }

    // getLowStockCount
    public int getLowStockCount(int threshold) {
        String sql = "SELECT COUNT(*) FROM products WHERE stock <= ?"; // Changed to <= threshold
        int count = 0;
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, threshold);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    count = rs.getInt(1);
                }
            }
        } catch (SQLException e) {
            System.err.println("SQL Error getting low stock count: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error getting low stock count: " + e.getMessage());
            e.printStackTrace();
        }
        return count;
    }

    // getUniqueCategoryCount
     public int getUniqueCategoryCount() {
         String sql = "SELECT COUNT(DISTINCT category) FROM products WHERE category IS NOT NULL AND category != ''";
         int count = 0;
         try (PreparedStatement stmt = conn.prepareStatement(sql);
              ResultSet rs = stmt.executeQuery()) {
             if (rs.next()) {
                 count = rs.getInt(1);
             }
         } catch (SQLException e) {
             System.err.println("SQL Error getting unique category count: " + e.getMessage());
             e.printStackTrace();
         } catch (Exception e) {
             System.err.println("Error getting unique category count: " + e.getMessage());
             e.printStackTrace();
         }
         return count;
     }


    // getProductById method... (keep as is)
    public Product getProductById(int id) {
        String sql = "SELECT * FROM products WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRowToProduct(rs);
                }
            }
        } catch (SQLException e) {
            System.err.println("SQL Error getting product by ID: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error getting product by ID: " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

    // deleteProduct method... (keep as is)
    public boolean deleteProduct(int id) {
        String sql = "DELETE FROM products WHERE id = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            System.err.println("SQL Error deleting product: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error deleting product: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    // updateProduct method... (keep as is)
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
             System.err.println("SQL Error updating product: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
             System.err.println("Error updating product: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }
}