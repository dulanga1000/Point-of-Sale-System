/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util; // Make sure this is in the 'util' package

import java.sql.*;
import java.util.logging.Level;
import java.util.logging.Logger;

public class DBConnection {
    private static final Logger LOGGER = Logger.getLogger(DBConnection.class.getName());
    // Ensure this URL matches your database name. Your previous SQL used 'swift_database'.
    private static final String URL = "jdbc:mysql://localhost:3306/swift_database?useSSL=false&serverTimezone=UTC";
    // IMPORTANT: Replace with your actual database credentials
    private static final String USER = "root"; // Your DB Username
    private static final String PASSWORD = "";   // Your DB Password

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            LOGGER.info("MySQL JDBC Driver loaded successfully");
            // verifyDatabaseStructure(); // Consider if this is needed at class load time for a web app
        } catch (ClassNotFoundException e) {
            LOGGER.log(Level.SEVERE, "MySQL JDBC Driver not found!", e);
            throw new RuntimeException("MySQL JDBC Driver not found!", e);
        }
    }

    // Method to verify structure (can be called selectively if needed)
    public static void verifyDatabaseStructure() {
        Connection conn = null;
        try {
            conn = getConnection(); // Uses the public getConnection
            DatabaseMetaData metaData = conn.getMetaData();
            LOGGER.info("Database Product Name: " + metaData.getDatabaseProductName());
            LOGGER.info("Database Product Version: " + metaData.getDatabaseProductVersion());

            ResultSet tables = metaData.getTables(null, null, "products", null); // Check 'products'
            if (!tables.next()) {
                LOGGER.severe("CRITICAL ERROR: 'products' table does not exist in the database!");
            } else {
                LOGGER.info("'products' table found in database");
            }
            if (tables != null) tables.close();

        } catch (SQLException e) {
            LOGGER.log(Level.SEVERE, "Error verifying database structure", e);
        } finally {
            closeConnection(conn);
        }
    }

    public static Connection getConnection() throws SQLException {
        try {
            Connection conn = DriverManager.getConnection(URL, USER, PASSWORD);
            // LOGGER.info("Database connection established successfully"); // Can be verbose for web apps
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
                // LOGGER.info("Database connection closed successfully");
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing database connection", e);
            }
        }
    }

    public static void closeStatement(Statement stmt) {
        if (stmt != null) {
            try {
                stmt.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing statement", e);
            }
        }
    }

    public static void closeResultSet(ResultSet rs) {
        if (rs != null) {
            try {
                rs.close();
            } catch (SQLException e) {
                LOGGER.log(Level.WARNING, "Error closing result set", e);
            }
        }
    }
}