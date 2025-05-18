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
        } catch (SQLException e) { 
            System.err.println("SQL Error adding product: " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) { 
             System.err.println("Error adding product: " + e.getMessage());
            e.printStackTrace();
        }
        return false;
    }

    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
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

    public List<String> getAllCategories() {
        List<String> categories = new ArrayList<>();
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

    public List<Product> searchProducts(String query) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE LOWER(name) LIKE LOWER(?) OR LOWER(sku) LIKE LOWER(?) ORDER BY name ASC";
        String searchTerm = "%" + query.trim() + "%"; 

        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, searchTerm); 
            stmt.setString(2, searchTerm); 
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

    public List<Product> getProductsByCategory(String category) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE category = ? ORDER BY name ASC";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, category); 
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

    public List<Product> getProductsByPage(int itemsPerPage, int offset) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products ORDER BY name ASC LIMIT ? OFFSET ?"; 
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, itemsPerPage); 
            stmt.setInt(2, offset);       
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

    public int getTotalProductCount() {
        String sql = "SELECT COUNT(*) FROM products";
        int count = 0;
        try (PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                count = rs.getInt(1); 
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

    public int getLowStockCount(int threshold) {
        String sql = "SELECT COUNT(*) FROM products WHERE stock <= ?"; 
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
            System.err.println("SQL Error getting product by ID: " + id + " - " + e.getMessage());
            e.printStackTrace();
        } catch (Exception e) {
            System.err.println("Error getting product by ID: " + id + " - " + e.getMessage());
            e.printStackTrace();
        }
        return null;
    }

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

    // ***** NEW METHOD *****
    /**
     * Decreases the stock of a product by the given quantity.
     * Ensures that the stock does not go below zero as a result of this operation.
     * @param productId The ID of the product to update.
     * @param quantityDecreased The quantity to decrease the stock by.
     * @return true if the stock was updated successfully, false otherwise.
     */
    public boolean decreaseStock(int productId, int quantityDecreased) {
        // This query tries to decrement stock only if current stock is sufficient
        String sql = "UPDATE products SET stock = stock - ? WHERE id = ? AND stock >= ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, quantityDecreased);
            stmt.setInt(2, productId);
            stmt.setInt(3, quantityDecreased); // Condition: current stock must be >= quantityDecreased
            
            int rowsAffected = stmt.executeUpdate();
            if (rowsAffected > 0) {
                System.out.println("Stock updated for product ID " + productId + ". Decreased by " + quantityDecreased);
                return true;
            } else {
                // This can happen if product ID is not found, or if stock < quantityDecreased
                Product currentProduct = getProductById(productId);
                int currentStock = (currentProduct != null) ? currentProduct.getStock() : -1;
                System.err.println("Stock update failed for product ID " + productId + 
                                   ". Product not found, or insufficient stock (requested: " + quantityDecreased + 
                                   ", available: " + currentStock + ").");
                return false;
            }
        } catch (SQLException e) {
            System.err.println("SQL Error decreasing stock for product ID " + productId + ": " + e.getMessage());
            e.printStackTrace(); // Log the stack trace for debugging
        }
        return false;
    }

    // ***** NEW METHOD *****
    /**
     * Gets a product ID by its name.
     * Note: Using names as identifiers is less reliable than IDs or SKUs due to potential duplicates.
     * @param productName The name of the product.
     * @return The product ID, or -1 if not found or an error occurs.
     */
    public int getProductIdByName(String productName) {
        String sql = "SELECT id FROM products WHERE name = ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, productName);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt("id");
                }
            }
        } catch (SQLException e) {
            System.err.println("SQL Error getting product ID by name '" + productName + "': " + e.getMessage());
            e.printStackTrace(); // Log the stack trace
        }
        return -1; // Return -1 to indicate "not found" or an error
    }
}