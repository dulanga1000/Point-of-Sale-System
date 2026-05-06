/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

import model.Supplier;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Types;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

public class SupplierDAO {

    private static final Logger LOGGER = Logger.getLogger(SupplierDAO.class.getName());
    
    private static final String INSERT_SUPPLIER_SQL = "INSERT INTO suppliers " +
        "(company_name, category, business_reg_no, tax_id, company_address, " +
        "contact_person, contact_position, contact_phone, contact_email, " +
        "payment_method, payment_terms, credit_limit, delivery_terms, lead_time, " +
        "product_categories, additional_notes, supplier_status) " +
        "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Active')";

    private static final String SELECT_ALL_SUPPLIERS_SQL = "SELECT * FROM suppliers ORDER BY company_name ASC";
    private static final String SELECT_SUPPLIER_BY_ID_SQL = "SELECT * FROM suppliers WHERE supplier_id = ?";
    private static final String SELECT_SUPPLIER_EMAIL_BY_ID_SQL = "SELECT contact_email FROM suppliers WHERE supplier_id = ?";


    // Helper method to map ResultSet to Supplier object
    private Supplier mapRowToSupplier(ResultSet resultSet) throws SQLException {
        Supplier supplier = new Supplier();
        supplier.setSupplierId(resultSet.getInt("supplier_id"));
        supplier.setCompanyName(resultSet.getString("company_name"));
        supplier.setCategory(resultSet.getString("category"));
        supplier.setBusinessRegNo(resultSet.getString("business_reg_no"));
        supplier.setTaxId(resultSet.getString("tax_id"));
        supplier.setCompanyAddress(resultSet.getString("company_address"));
        // supplier.setSupplierStatus(resultSet.getString("supplier_status")); // Uncomment if you add this field to your Supplier model
        supplier.setContactPerson(resultSet.getString("contact_person"));
        supplier.setContactPosition(resultSet.getString("contact_position"));
        supplier.setContactPhone(resultSet.getString("contact_phone"));
        supplier.setContactEmail(resultSet.getString("contact_email"));
        supplier.setPaymentMethod(resultSet.getString("payment_method"));
        supplier.setPaymentTerms(resultSet.getString("payment_terms"));
        
        BigDecimal creditLimit = resultSet.getBigDecimal("credit_limit");
        if (resultSet.wasNull()) {
            supplier.setCreditLimit(null);
        } else {
            supplier.setCreditLimit(creditLimit);
        }
        
        supplier.setDeliveryTerms(resultSet.getString("delivery_terms"));
        supplier.setLeadTime(resultSet.getInt("lead_time")); // Assuming lead_time is NOT NULL or handle appropriately
        supplier.setProductCategories(resultSet.getString("product_categories"));
        supplier.setAdditionalNotes(resultSet.getString("additional_notes"));
        
        // Assuming your Supplier model has createdAt and if the column exists in DB
        // If your Supplier model doesn't have createdAt, you can comment this out.
        // supplier.setCreatedAt(resultSet.getTimestamp("created_at")); 
        return supplier;
    }

    public boolean addSupplier(Supplier supplier) {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        boolean rowInserted = false;
        LOGGER.info("Attempting to add supplier: " + (supplier != null ? supplier.getCompanyName() : "NULL Supplier Object"));

        try {
            connection = DBConnection.getConnection();
            if (connection == null) {
                LOGGER.severe("Failed to obtain database connection in addSupplier.");
                return false;
            }
            preparedStatement = connection.prepareStatement(INSERT_SUPPLIER_SQL);

            preparedStatement.setString(1, supplier.getCompanyName());
            preparedStatement.setString(2, supplier.getCategory());
            preparedStatement.setString(3, supplier.getBusinessRegNo());
            
            if (supplier.getTaxId() != null && !supplier.getTaxId().trim().isEmpty()) {
                preparedStatement.setString(4, supplier.getTaxId());
            } else {
                preparedStatement.setNull(4, Types.VARCHAR);
            }
            
            preparedStatement.setString(5, supplier.getCompanyAddress());
            preparedStatement.setString(6, supplier.getContactPerson());

            if (supplier.getContactPosition() != null && !supplier.getContactPosition().trim().isEmpty()) {
                preparedStatement.setString(7, supplier.getContactPosition());
            } else {
                preparedStatement.setNull(7, Types.VARCHAR);
            }

            preparedStatement.setString(8, supplier.getContactPhone());
            preparedStatement.setString(9, supplier.getContactEmail());
            preparedStatement.setString(10, supplier.getPaymentMethod());
            preparedStatement.setString(11, supplier.getPaymentTerms());

            if (supplier.getCreditLimit() != null) {
                preparedStatement.setBigDecimal(12, supplier.getCreditLimit());
            } else {
                 preparedStatement.setNull(12, Types.DECIMAL);
            }

            preparedStatement.setString(13, supplier.getDeliveryTerms());
            preparedStatement.setInt(14, supplier.getLeadTime());
            preparedStatement.setString(15, supplier.getProductCategories() != null ? supplier.getProductCategories() : ""); 
            
            if (supplier.getAdditionalNotes() != null && !supplier.getAdditionalNotes().trim().isEmpty()) {
                preparedStatement.setString(16, supplier.getAdditionalNotes());
            } else {
                 preparedStatement.setNull(16, Types.VARCHAR);
            }
            // supplier_status is set to 'Active' by default in the SQL

            int affectedRows = preparedStatement.executeUpdate();
            rowInserted = (affectedRows > 0);
            if(rowInserted) {
                LOGGER.info("Supplier added successfully: " + supplier.getCompanyName());
            } else {
                LOGGER.warning("Failed to add supplier (no rows affected): " + supplier.getCompanyName());
            }

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "SQL Error adding supplier: " + (supplier != null ? supplier.getCompanyName() : "NULL Supplier Object"), e);
            rowInserted = false; 
        } finally {
            if (preparedStatement != null) {
                try { preparedStatement.close(); } catch (SQLException e) { LOGGER.log(Level.WARNING, "Error closing PreparedStatement.", e); }
            }
            DBConnection.closeConnection(connection);
        }
        return rowInserted;
    }

    public List<Supplier> getAllSuppliers() {
        List<Supplier> suppliers = new ArrayList<>();
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        LOGGER.info("Attempting to retrieve all suppliers.");

        try {
            connection = DBConnection.getConnection();
            if (connection == null) {
                LOGGER.severe("Failed to obtain database connection in getAllSuppliers.");
                return suppliers; // Return empty list
            }
            preparedStatement = connection.prepareStatement(SELECT_ALL_SUPPLIERS_SQL);
            resultSet = preparedStatement.executeQuery();
            LOGGER.info("SQL query executed: " + SELECT_ALL_SUPPLIERS_SQL);

            int count = 0;
            while (resultSet.next()) {
                Supplier supplier = mapRowToSupplier(resultSet); // Use helper method
                suppliers.add(supplier);
                count++;
            }
            LOGGER.info("Total suppliers loaded from database: " + count);
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "SQL Error retrieving all suppliers.", e);
        } finally {
            if (resultSet != null) { try { resultSet.close(); } catch (SQLException e) { LOGGER.log(Level.WARNING, "Error closing ResultSet.", e); }}
            if (preparedStatement != null) { try { preparedStatement.close(); } catch (SQLException e) { LOGGER.log(Level.WARNING, "Error closing PreparedStatement.", e); }}
            DBConnection.closeConnection(connection);
        }
        return suppliers;
    }
    
    public Supplier getSupplierById(int supplierId) {
        Supplier supplier = null;
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        LOGGER.info("Attempting to retrieve supplier by ID: " + supplierId);

        try {
            connection = DBConnection.getConnection();
            if (connection == null) {
                LOGGER.severe("Failed to obtain database connection in getSupplierById.");
                return null;
            }
            preparedStatement = connection.prepareStatement(SELECT_SUPPLIER_BY_ID_SQL);
            preparedStatement.setInt(1, supplierId);
            resultSet = preparedStatement.executeQuery();

            if (resultSet.next()) {
                supplier = mapRowToSupplier(resultSet); 
                LOGGER.info("Supplier found: " + (supplier != null ? supplier.getCompanyName() : "null object mapped"));
            } else {
                LOGGER.warning("No supplier found with ID: " + supplierId);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "SQL Error retrieving supplier by ID: " + supplierId, e);
        } finally {
            if (resultSet != null) { try { resultSet.close(); } catch (SQLException e) { LOGGER.log(Level.WARNING, "Error closing ResultSet.", e); }}
            if (preparedStatement != null) { try { preparedStatement.close(); } catch (SQLException e) { LOGGER.log(Level.WARNING, "Error closing PreparedStatement.", e); }}
            DBConnection.closeConnection(connection);
        }
        return supplier;
    }

    public String getSupplierEmailById(int supplierId) {
        Connection connection = null;
        PreparedStatement preparedStatement = null;
        ResultSet resultSet = null;
        String email = null;
        LOGGER.info("Attempting to retrieve email for supplier ID: " + supplierId);

        try {
            connection = DBConnection.getConnection();
            if (connection == null) {
                LOGGER.severe("Failed to obtain database connection in getSupplierEmailById.");
                return null;
            }
            preparedStatement = connection.prepareStatement(SELECT_SUPPLIER_EMAIL_BY_ID_SQL);
            preparedStatement.setInt(1, supplierId);
            resultSet = preparedStatement.executeQuery();

            if (resultSet.next()) {
                email = resultSet.getString("contact_email"); 
            }
            if (email != null) {
                LOGGER.info("Email found for supplier ID " + supplierId + ": " + email);
            } else {
                LOGGER.warning("No email found for supplier ID " + supplierId);
            }
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "SQL Error retrieving supplier email for ID: " + supplierId, e);
        } finally {
            if (resultSet != null) { try { resultSet.close(); } catch (SQLException e) { LOGGER.log(Level.WARNING, "Error closing ResultSet.", e); }}
            if (preparedStatement != null) { try { preparedStatement.close(); } catch (SQLException e) { LOGGER.log(Level.WARNING, "Error closing PreparedStatement.", e); }}
            DBConnection.closeConnection(connection);
        }
        return email;
    }
}