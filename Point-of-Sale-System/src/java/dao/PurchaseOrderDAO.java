/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.logging.Level;
import java.util.logging.Logger;

public class PurchaseOrderDAO {
    private static final Logger LOGGER = Logger.getLogger(PurchaseOrderDAO.class.getName());

    /**
     * Saves the main purchase order details to the database.
     * @return The auto-generated po_id if successful, otherwise -1.
     */
    public int savePurchaseOrder(Connection conn, String orderReferenceNo, int supplierId, 
                                 String orderDateStr, String expectedDateStr, String paymentTerms, 
                                 String shippingMethod, double taxPercentage, double shippingCost, 
                                 double subtotal, double taxAmount, double grandTotal, String notes) throws SQLException {
        String sql = "INSERT INTO purchase_orders (order_reference_no, supplier_id, order_date, expected_delivery_date, " +
                     "payment_terms, shipping_method, tax_percentage, shipping_cost, subtotal_amount, tax_amount, " +
                     "total_amount, notes, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        PreparedStatement pstmt = null;
        ResultSet generatedKeys = null;
        int poId = -1;

        try {
            pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            pstmt.setString(1, orderReferenceNo);
            pstmt.setInt(2, supplierId);

            // Convert date strings to java.sql.Date
            SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
            try {
                if (orderDateStr != null && !orderDateStr.isEmpty()) {
                    pstmt.setDate(3, new java.sql.Date(sdf.parse(orderDateStr).getTime()));
                } else {
                    pstmt.setNull(3, Types.DATE);
                }
                if (expectedDateStr != null && !expectedDateStr.isEmpty()) {
                     pstmt.setDate(4, new java.sql.Date(sdf.parse(expectedDateStr).getTime()));
                } else {
                    pstmt.setNull(4, Types.DATE);
                }
            } catch (ParseException e) {
                LOGGER.log(Level.SEVERE, "Error parsing date strings for PO: " + orderReferenceNo, e);
                throw new SQLException("Invalid date format provided.", e);
            }
            
            pstmt.setString(5, paymentTerms);
            pstmt.setString(6, shippingMethod);
            pstmt.setDouble(7, taxPercentage);
            pstmt.setDouble(8, shippingCost);
            pstmt.setDouble(9, subtotal);
            pstmt.setDouble(10, taxAmount);
            pstmt.setDouble(11, grandTotal);
            pstmt.setString(12, notes);
            pstmt.setString(13, "Pending"); // Default status

            int affectedRows = pstmt.executeUpdate();

            if (affectedRows > 0) {
                generatedKeys = pstmt.getGeneratedKeys();
                if (generatedKeys.next()) {
                    poId = generatedKeys.getInt(1);
                    LOGGER.info("Purchase order saved successfully with PO ID: " + poId);
                } else {
                    LOGGER.severe("Failed to retrieve generated PO ID for: " + orderReferenceNo);
                    throw new SQLException("Creating purchase order failed, no ID obtained.");
                }
            } else {
                 LOGGER.severe("Creating purchase order failed, no rows affected for: " + orderReferenceNo);
                throw new SQLException("Creating purchase order failed, no rows affected.");
            }
        } finally {
            if (generatedKeys != null) try { generatedKeys.close(); } catch (SQLException e) { LOGGER.log(Level.WARNING, "Error closing generatedKeys ResultSet", e); }
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { LOGGER.log(Level.WARNING, "Error closing PreparedStatement for savePurchaseOrder", e); }
            // Connection is managed by the calling servlet/JSP
        }
        return poId;
    }

    /**
     * Saves an individual item for a purchase order.
     * @return true if successful, false otherwise.
     */
    public boolean savePurchaseOrderItem(Connection conn, int poId, int productId, String productName, 
                                         int quantity, double unitPrice, double itemTotalPrice) throws SQLException {
        String sql = "INSERT INTO purchase_order_items (po_id, product_id, product_name, quantity_ordered, unit_price, item_total_price) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        PreparedStatement pstmt = null;
        try {
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, poId);
            pstmt.setInt(2, productId);
            pstmt.setString(3, productName); // Storing name for easier PO display
            pstmt.setInt(4, quantity);
            pstmt.setDouble(5, unitPrice);
            pstmt.setDouble(6, itemTotalPrice);

            int affectedRows = pstmt.executeUpdate();
            if (affectedRows > 0) {
                LOGGER.finer("PO Item saved: PO ID " + poId + ", Product ID " + productId);
                return true;
            } else {
                LOGGER.warning("Failed to save PO Item: PO ID " + poId + ", Product ID " + productId);
                return false;
            }
        } finally {
            if (pstmt != null) try { pstmt.close(); } catch (SQLException e) { LOGGER.log(Level.WARNING, "Error closing PreparedStatement for savePurchaseOrderItem", e); }
            // Connection is managed by the calling servlet/JSP
        }
    }
}
