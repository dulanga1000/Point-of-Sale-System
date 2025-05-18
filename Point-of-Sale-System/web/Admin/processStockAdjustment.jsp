<%@ page import="java.sql.*" %>
<%@ page import="java.time.LocalDateTime" %>
<%@ page import="java.time.format.DateTimeFormatter" %>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="java.util.Date" %>

<%
    // Database connection details (same as in your stock_adjustment.jsp)
    String DB_URL = "jdbc:mysql://localhost:3306/Swift_Database";
    String DB_USER = "root";
    String DB_PASSWORD = "";

    Connection conn = null;
    PreparedStatement psUpdateProduct = null;
    PreparedStatement psInsertMovement = null;
    PreparedStatement psInsertAdjustmentLog = null;
    PreparedStatement psGetProduct = null;
    ResultSet rsProduct = null;

    String redirectURL = "stock_adjustment.jsp";
    String message = "";
    String messageType = "error"; // Default to error

    // Get current user ID from session (assuming it's stored as "userId" an Integer)
    // Replace with your actual session attribute name and type handling
    Integer userId = null; // Placeholder
    if (session.getAttribute("userId") != null) {
        try {
            userId = Integer.parseInt(session.getAttribute("userId").toString());
        } catch (NumberFormatException e) {
            // Handle error if userId in session is not a valid integer
            System.err.println("Error parsing userId from session: " + e.getMessage());
            // You might want to deny the operation if userId is crucial and invalid
        }
    } else {
        // If no user is logged in, you might want to deny the operation or use a default/system user ID
        // For this example, we'll allow it to proceed with a null user_id if not found,
        // but in a real app, you'd typically enforce login.
         System.err.println("User ID not found in session. Stock adjustment will be logged with NULL user.");
        // If your DB schema for user_id in these tables doesn't allow NULL and it's required,
        // this will fail. Adjust accordingly.
    }


    // Retrieve form parameters
    String productIdStr = request.getParameter("productId");
    String adjustmentType = request.getParameter("adjustmentType"); // "increase" or "decrease"
    String quantityStr = request.getParameter("quantity");
    String reason = request.getParameter("reason");
    String reference = request.getParameter("reference"); // Generated reference number
    String notes = request.getParameter("notes");

    if (productIdStr == null || productIdStr.isEmpty() ||
        adjustmentType == null || adjustmentType.isEmpty() ||
        quantityStr == null || quantityStr.isEmpty() ||
        reason == null || reason.isEmpty() ||
        reference == null || reference.isEmpty()) {

        message = "Missing required fields. Please fill out the form completely.";
        response.sendRedirect(redirectURL + "?message=" + java.net.URLEncoder.encode(message, "UTF-8") + "&type=" + messageType);
        return;
    }

    int productId = 0;
    double quantity = 0;

    try {
        productId = Integer.parseInt(productIdStr);
        quantity = Double.parseDouble(quantityStr);

        if (quantity <= 0) {
            message = "Quantity must be a positive number.";
            response.sendRedirect(redirectURL + "?message=" + java.net.URLEncoder.encode(message, "UTF-8") + "&type=" + messageType);
            return;
        }

        Class.forName("com.mysql.cj.jdbc.Driver");
        conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);
        conn.setAutoCommit(false); // Start transaction

        // 1. Get current product details (stock, name, sku, category)
        String getProductSQL = "SELECT stock, name, sku, category FROM products WHERE id = ?";
        psGetProduct = conn.prepareStatement(getProductSQL);
        psGetProduct.setInt(1, productId);
        rsProduct = psGetProduct.executeQuery();

        double currentStock = 0;
        String productName = "N/A";
        String productSku = "N/A";
        String productCategory = "N/A";

        if (rsProduct.next()) {
            currentStock = rsProduct.getDouble("stock");
            productName = rsProduct.getString("name");
            productSku = rsProduct.getString("sku");
            productCategory = rsProduct.getString("category");
        } else {
            throw new SQLException("Product not found with ID: " + productId);
        }

        // 2. Calculate new stock and quantity change for inventory_movements
        double newStock;
        double quantityChangeForMovement; // Signed quantity for inventory_movements
        String movementTypeDb;

        if ("increase".equalsIgnoreCase(adjustmentType)) {
            newStock = currentStock + quantity;
            quantityChangeForMovement = quantity; // Positive
            movementTypeDb = "stock_adjustment_add";
        } else if ("decrease".equalsIgnoreCase(adjustmentType)) {
            if (quantity > currentStock) {
                conn.rollback(); // Rollback before redirecting
                message = "Cannot decrease stock by " + quantity + ". Current stock is only " + currentStock + ".";
                response.sendRedirect(redirectURL + "?message=" + java.net.URLEncoder.encode(message, "UTF-8") + "&type=" + messageType);
                return;
            }
            newStock = currentStock - quantity;
            quantityChangeForMovement = -quantity; // Negative
            movementTypeDb = "stock_adjustment_subtract";
        } else {
            throw new IllegalArgumentException("Invalid adjustment type: " + adjustmentType);
        }

        // 3. Update product stock in 'products' table
        String updateProductSQL = "UPDATE products SET stock = ? WHERE id = ?";
        psUpdateProduct = conn.prepareStatement(updateProductSQL);
        psUpdateProduct.setDouble(1, newStock);
        psUpdateProduct.setInt(2, productId);
        int productUpdatedRows = psUpdateProduct.executeUpdate();

        if (productUpdatedRows == 0) {
            throw new SQLException("Failed to update product stock. Product may not exist or no change needed.");
        }

        // 4. Insert into 'inventory_movements' table
        // The `movement_type` enum in your DB includes `stock_adjustment_add` and `stock_adjustment_subtract`
        String insertMovementSQL = "INSERT INTO inventory_movements (product_id, movement_type, quantity_change, balance_after_movement, movement_date, user_id, reference_type, reference_id, notes) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        psInsertMovement = conn.prepareStatement(insertMovementSQL, Statement.RETURN_GENERATED_KEYS);
        psInsertMovement.setInt(1, productId);
        psInsertMovement.setString(2, movementTypeDb);
        psInsertMovement.setDouble(3, quantityChangeForMovement);
        psInsertMovement.setDouble(4, newStock);
        psInsertMovement.setTimestamp(5, new Timestamp(new Date().getTime())); // Current timestamp
        if (userId != null) {
            psInsertMovement.setInt(6, userId);
        } else {
            psInsertMovement.setNull(6, Types.INTEGER);
        }
        psInsertMovement.setString(7, "Stock Adjustment Form"); // Or a more dynamic type if needed
        psInsertMovement.setString(8, reference);

        // Combine reason and notes for the inventory_movements notes field
        String movementNotes = reason;
        if (notes != null && !notes.trim().isEmpty()) {
            movementNotes += " | Additional Notes: " + notes;
        }
        psInsertMovement.setString(9, movementNotes);
        psInsertMovement.executeUpdate();
        
        long inventoryMovementId = 0;
        ResultSet generatedKeysMovement = psInsertMovement.getGeneratedKeys();
        if (generatedKeysMovement.next()) {
            inventoryMovementId = generatedKeysMovement.getLong(1);
        }


        // 5. Insert into 'stock_adjustment_log' table
        String insertLogSQL = "INSERT INTO stock_adjustment_log (product_id, product_name_at_adjustment, product_sku_at_adjustment, product_category_at_adjustment, user_id, adjustment_timestamp, adjustment_type, quantity_adjusted, old_stock_level, new_stock_level, reason, reference_number, notes, inventory_movement_id) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        psInsertAdjustmentLog = conn.prepareStatement(insertLogSQL);
        psInsertAdjustmentLog.setInt(1, productId);
        psInsertAdjustmentLog.setString(2, productName);
        psInsertAdjustmentLog.setString(3, productSku);
        psInsertAdjustmentLog.setString(4, productCategory);
        if (userId != null) {
            psInsertAdjustmentLog.setInt(5, userId);
        } else {
            psInsertAdjustmentLog.setNull(5, Types.INTEGER);
        }
        psInsertAdjustmentLog.setTimestamp(6, new Timestamp(new Date().getTime())); // Current timestamp
        psInsertAdjustmentLog.setString(7, adjustmentType); // 'increase' or 'decrease'
        psInsertAdjustmentLog.setDouble(8, quantity); // Always positive quantity, type indicates direction
        psInsertAdjustmentLog.setDouble(9, currentStock);
        psInsertAdjustmentLog.setDouble(10, newStock);
        psInsertAdjustmentLog.setString(11, reason);
        psInsertAdjustmentLog.setString(12, reference);
        psInsertAdjustmentLog.setString(13, notes);
        if (inventoryMovementId > 0) {
            psInsertAdjustmentLog.setLong(14, inventoryMovementId);
        } else {
            psInsertAdjustmentLog.setNull(14, Types.INTEGER);
        }

        psInsertAdjustmentLog.executeUpdate();

        conn.commit(); // Commit transaction
        message = "Stock adjustment successful for product: " + productName + " (SKU: " + productSku + ")";
        messageType = "success";

    } catch (NumberFormatException e) {
        message = "Invalid input. Product ID and Quantity must be numbers.";
        e.printStackTrace(); // For server logs
        if (conn != null) try { conn.rollback(); } catch (SQLException se) { se.printStackTrace(); }
    } catch (IllegalArgumentException e) {
        message = e.getMessage();
        e.printStackTrace();
        if (conn != null) try { conn.rollback(); } catch (SQLException se) { se.printStackTrace(); }
    } catch (SQLException e) {
        message = "Database error: " + e.getMessage();
        e.printStackTrace();
        if (conn != null) try { conn.rollback(); } catch (SQLException se) { se.printStackTrace(); }
    } catch (Exception e) {
        message = "An unexpected error occurred: " + e.getMessage();
        e.printStackTrace();
        if (conn != null) try { conn.rollback(); } catch (SQLException se) { se.printStackTrace(); }
    } finally {
        if (rsProduct != null) try { rsProduct.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (psGetProduct != null) try { psGetProduct.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (psUpdateProduct != null) try { psUpdateProduct.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (psInsertMovement != null) try { psInsertMovement.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (psInsertAdjustmentLog != null) try { psInsertAdjustmentLog.close(); } catch (SQLException e) { e.printStackTrace(); }
        if (conn != null) {
            try {
                if (!conn.getAutoCommit()) { // If still in transaction mode due to early exit without commit/rollback
                    conn.setAutoCommit(true); // Reset auto-commit
                }
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    response.sendRedirect(redirectURL + "?message=" + java.net.URLEncoder.encode(message, "UTF-8") + "&type=" + messageType);
%>