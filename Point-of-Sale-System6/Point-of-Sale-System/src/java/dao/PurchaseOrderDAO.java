/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.*;
import java.util.List;
/**
 *
 * @author TUF
 */
public class PurchaseOrderDAO {

    public static boolean createPurchaseOrder(
            int supplierId,
            String paymentTerms,
            String shippingMethod,
            String notes,
            double taxRate,
            double shipping,
            double subtotal,
            double total,
            List<Integer> productIds,
            List<Integer> quantities
    ) {
        Connection conn = null;
        PreparedStatement psOrder = null;
        PreparedStatement psItem = null;
        ResultSet rs = null;

        try {
            // DB connection
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/swift_database", "root", "your_password");
            conn.setAutoCommit(false); // Start transaction

            // 1. Insert into purchase_orders
            String orderSQL = "INSERT INTO purchase_orders (order_date, expected_date, supplier_id, payment_terms, shipping_method, notes, tax_rate, shipping, subtotal, total) VALUES (NOW(), NULL, ?, ?, ?, ?, ?, ?, ?, ?)";
            psOrder = conn.prepareStatement(orderSQL, Statement.RETURN_GENERATED_KEYS);
            psOrder.setInt(1, supplierId);
            psOrder.setString(2, paymentTerms);
            psOrder.setString(3, shippingMethod);
            psOrder.setString(4, notes);
            psOrder.setDouble(5, taxRate);
            psOrder.setDouble(6, shipping);
            psOrder.setDouble(7, subtotal);
            psOrder.setDouble(8, total);
            psOrder.executeUpdate();

            rs = psOrder.getGeneratedKeys();
            int orderId = 0;
            if (rs.next()) {
                orderId = rs.getInt(1);
            } else {
                conn.rollback();
                return false;
            }

            // 2. Insert into purchase_order_items
            String itemSQL = "INSERT INTO purchase_order_items (order_id, product_id, quantity, unit_price, total_price) VALUES (?, ?, ?, ?, ?)";
            psItem = conn.prepareStatement(itemSQL);

            for (int i = 0; i < productIds.size(); i++) {
                int productId = productIds.get(i);
                int quantity = quantities.get(i);

                // Fetch unit price
                String priceQuery = "SELECT unit_price FROM products WHERE product_id = ?";
                PreparedStatement psPrice = conn.prepareStatement(priceQuery);
                psPrice.setInt(1, productId);
                ResultSet priceRs = psPrice.executeQuery();
                if (priceRs.next()) {
                    double unitPrice = priceRs.getDouble("unit_price");
                    double totalPrice = unitPrice * quantity;

                    psItem.setInt(1, orderId);
                    psItem.setInt(2, productId);
                    psItem.setInt(3, quantity);
                    psItem.setDouble(4, unitPrice);
                    psItem.setDouble(5, totalPrice);
                    psItem.addBatch();
                }
                priceRs.close();
                psPrice.close();
            }

            psItem.executeBatch();
            conn.commit();
            return true;

        } catch (Exception e) {
            e.printStackTrace();
            try {
                if (conn != null) conn.rollback();
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            return false;

        } finally {
            try { if (rs != null) rs.close(); } catch (Exception ignored) {}
            try { if (psItem != null) psItem.close(); } catch (Exception ignored) {}
            try { if (psOrder != null) psOrder.close(); } catch (Exception ignored) {}
            try { if (conn != null) conn.close(); } catch (Exception ignored) {}
        }
    }
}