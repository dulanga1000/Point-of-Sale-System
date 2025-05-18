/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.IOException;
import java.io.File;
import java.nio.file.Paths;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.SQLException; // Import SQLException
import java.util.Date; // Import Date for timestamp
import java.text.SimpleDateFormat; // Import SimpleDateFormat for formatting timestamp
import java.sql.ResultSet;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;
import model.Product;
import dao.ProductDAO;

/**
 *
 * @author User
 */

@WebServlet("/AddProductServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1 MB
    maxFileSize = 1024 * 1024 * 5,   // 5 MB
    maxRequestSize = 1024 * 1024 * 10 // 10 MB
)
public class AddProductServlet extends HttpServlet {

    // Database connection details (as provided in your original code)
    private static final String DB_URL = "jdbc:mysql://localhost:3306/Swift_Database";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = ""; // <-- Replace with your actual MySQL password if not empty

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection con = null; // Declare connection here

        try {
            // Set character encoding for proper handling of form data
            request.setCharacterEncoding("UTF-8");

            // 1. Get form parameters safely
            String name = getSafeParam(request, "product_name");
            String category = getSafeParam(request, "product_category");
            String sku = getSafeParam(request, "product_sku");
            String stockStr = getSafeParam(request, "product_stock");
            String priceStr = getSafeParam(request, "product_price");
            String supplier = getSafeParam(request, "product_supplier");
            String status = getSafeParam(request, "product_status");

            // Validate required fields
            if (name.isEmpty() || category.isEmpty() || sku.isEmpty() || 
                stockStr.isEmpty() || priceStr.isEmpty() || supplier.isEmpty() || status.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/Admin/add_product.jsp?error=missing_fields");
                return;
            }

            int stock = 0;
            double price = 0.0;

            // Safely parse stock
            if (!stockStr.isEmpty()) {
                try {
                    stock = Integer.parseInt(stockStr);
                } catch (NumberFormatException e) {
                     System.err.println("Invalid stock format: " + stockStr + " - defaulting to 0.");
                    stock = 0; // Default stock value in case of an error
                }
            }

            // Safely parse price
             if (!priceStr.isEmpty()) {
                try {
                    price = Double.parseDouble(priceStr);
                } catch (NumberFormatException e) {
                     System.err.println("Invalid price format: " + priceStr + " - defaulting to 0.0.");
                    price = 0.0; // Default price value in case of an error
                }
            }

            // Establish database connection first
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            // Validate SKU format
            if (!sku.matches("^[A-Z0-9!@#$%^&*()_+\\-=\\[\\]{};':\"\\\\|,.<>\\/?]*$")) {
                response.sendRedirect(request.getContextPath() + "/Admin/add_product.jsp?error=invalid_sku");
                return;
            }

            // Check if SKU already exists
            String checkSkuQuery = "SELECT COUNT(*) FROM products WHERE sku = ?";
            PreparedStatement checkSkuStmt = con.prepareStatement(checkSkuQuery);
            checkSkuStmt.setString(1, sku);
            ResultSet rs = checkSkuStmt.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                response.sendRedirect(request.getContextPath() + "/Admin/add_product.jsp?error=sku_exists");
                return;
            }
            checkSkuStmt.close();

            // 2. Handle image upload
            String imagePath = "Images/default.jpg"; // Default image path
            Part filePart = request.getPart("productImage");
            if (filePart != null && filePart.getSize() > 0) {
                try {
                    // Always use the project-relative web/Images directory
                    String uploadPath = request.getServletContext().getRealPath("/Images");
                    
                    // Create upload directory if it doesn't exist
                    File uploadDir = new File(uploadPath);
                    if (!uploadDir.exists()) {
                        if (!uploadDir.mkdirs()) {
                            response.sendRedirect(request.getContextPath() + "/Admin/add_product.jsp?error=upload_dir_failed");
                            return;
                        }
                    }
                    
                    if (!uploadDir.canWrite()) {
                        response.sendRedirect(request.getContextPath() + "/Admin/add_product.jsp?error=dir_not_writable");
                        return;
                    }
                    
                    // Generate unique filename
                    String fileName = getSubmittedFileName(filePart);
                    String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
                    
                    // Save the file
                    File outputFile = new File(uploadDir, uniqueFileName);
                    
                    // Write the file
                    filePart.write(outputFile.getAbsolutePath());
                    
                    // Verify file was created
                    if (outputFile.exists()) {
                        imagePath = "Images/" + uniqueFileName;
                    } else {
                        response.sendRedirect(request.getContextPath() + "/Admin/add_product.jsp?error=file_save_failed");
                        return;
                    }
                    
                } catch (Exception e) {
                    System.err.println("Error during image upload: " + e.getMessage());
                    e.printStackTrace();
                    response.sendRedirect(request.getContextPath() + "/Admin/add_product.jsp?error=file_save_error");
                    return;
                }
            }

            // 3. Database insert
            String sql = "INSERT INTO products (name, category, price, sku, stock, supplier, image_path, status) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, category);
            ps.setDouble(3, price);
            ps.setString(4, sku);
            ps.setInt(5, stock);
            ps.setString(6, supplier);
            ps.setString(7, imagePath);
            ps.setString(8, status);

            int result = ps.executeUpdate();
            if (result > 0) {
                response.sendRedirect(request.getContextPath() + "/Admin/add_product.jsp?success=true");
            } else {
                response.sendRedirect(request.getContextPath() + "/Admin/add_product.jsp?error=db_error");
            }

            ps.close();

        } catch (SQLException e) {
            // Catch SQL specific errors
            System.err.println("Database error during product add: " + e.getMessage());
            e.printStackTrace(); // Log the full stack trace
            response.sendRedirect(request.getContextPath() + "/Admin/add_product.jsp?error=sql_exception");
        }
        catch (IOException e) {
             // Catch IO errors, possibly during file upload/writing
             System.err.println("File upload or processing error: " + e.getMessage());
             e.printStackTrace(); // Log the full stack trace
             response.sendRedirect(request.getContextPath() + "/Admin/add_product.jsp?error=io_exception");
        }
        catch (ServletException e) {
             // Catch Servlet errors, possibly from getPart
             System.err.println("Servlet error processing request: " + e.getMessage());
             e.printStackTrace(); // Log the full stack trace
             response.sendRedirect(request.getContextPath() + "/Admin/add_product.jsp?error=servlet_exception");
        }
         catch (ClassNotFoundException e) {
             // Catch JDBC driver not found error
             System.err.println("JDBC Driver not found: " + e.getMessage());
             e.printStackTrace();
             response.sendRedirect(request.getContextPath() + "/Admin/add_product.jsp?error=driver_not_found");
         }
        catch (Exception e) {
            // Catch any other unexpected exceptions
            System.err.println("An unexpected error occurred during product add: " + e.getMessage());
            e.printStackTrace(); // Log the full stack trace
             // Redirect back to add page with a generic error flag
            response.sendRedirect(request.getContextPath() + "/Admin/add_product.jsp?error=unexpected");
        } finally {
            // Ensure connection is closed in all cases
            if (con != null) {
                try {
                    con.close();
                    System.out.println("Database connection closed.");
                } catch (SQLException e) {
                    System.err.println("Error closing database connection: " + e.getMessage());
                    e.printStackTrace();
                }
            }
        }
    }

    /**
     * Helper method to safely get request parameters, returning trimmed value or empty string.
     * @param request The HttpServletRequest object.
     * @param paramName The name of the parameter to retrieve.
     * @return The trimmed parameter value, or an empty string if the parameter is null or empty.
     */
    private String getSafeParam(HttpServletRequest request, String paramName) {
        String value = request.getParameter(paramName);
        return (value != null) ? value.trim() : ""; // Return trimmed value or empty string if null
    }

    private String getSubmittedFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "";
    }
}
