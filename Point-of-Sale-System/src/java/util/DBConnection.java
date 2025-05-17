/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

/**
 *
 * @author dulan
 */

import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBConnection {
    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());
    private static final String URL = "jdbc:mysql://localhost:3306/Swift_Database";
    private static final String USER = "root";
    private static final String PASSWORD = "";

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            LOGGER.info("MySQL JDBC Driver loaded successfully");
            verifyDatabaseStructure();
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "MySQL JDBC Driver not found!", e);
            throw new RuntimeException("MySQL JDBC Driver not found!", e);
        }
    }

    private static void verifyDatabaseStructure() {
        Connection conn = null;
        try {
            conn = getConnection();
            DatabaseMetaData metaData = conn.getMetaData();
            
            // Log database info
            LOGGER.info("Database Product Name: " + metaData.getDatabaseProductName());
            LOGGER.info("Database Product Version: " + metaData.getDatabaseProductVersion());
            
            // Check if suppliers table exists
            ResultSet tables = metaData.getTables(null, null, "suppliers", null);
            if (!tables.next()) {
                LOGGER.severe("CRITICAL ERROR: 'suppliers' table does not exist in the database!");
            } else {
                LOGGER.info("'suppliers' table found in database");
                
                // Check table structure
                ResultSet columns = metaData.getColumns(null, null, "suppliers", null);
                LOGGER.info("Suppliers table structure:");
                while (columns.next()) {
                    String columnName = columns.getString("COLUMN_NAME");
                    String columnType = columns.getString("TYPE_NAME");
                    LOGGER.info(String.format("Column: %s, Type: %s", columnName, columnType));
                }
            }
            
            // Test query
            Statement stmt = conn.createStatement();
            ResultSet rs = stmt.executeQuery("SELECT COUNT(*) as count FROM suppliers");
            if (rs.next()) {
                int count = rs.getInt("count");
                LOGGER.info("Number of records in suppliers table: " + count);
            }
            
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error verifying database structure", e);
        } finally {
            closeConnection(conn);
        }
    }

    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            LOGGER.info("Database connection established successfully");
            return conn;
        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Failed to establish database connection", e);
            throw e;
        }
    }

    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
                LOGGER.info("Database connection closed successfully");
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing database connection", e);
                e.printStackTrace();
            }
        }
    }
}
