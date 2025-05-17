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
import java.sql.SQLException;
import java.util.Date;
import java.text.SimpleDateFormat;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

/**
 *
 * @author User
 */

@WebServlet("/updateProduct")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
        maxFileSize = 1024 * 1024 * 10,             // 10MB
        maxRequestSize = 1024 * 1024 * 50)          // 50MB
public class UpdateProductServlet extends HttpServlet {

    // Database connection details
    private static final String DB_URL = "jdbc:mysql://localhost:3306/Swift_Database";
    private static final String DB_USER = "root";
    private static final String DB_PASSWORD = ""; // Replace with your actual MySQL password if not empty

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        Connection con = null; // Declare connection here

        try {
            // Set character encoding for proper handling of form data
            request.setCharacterEncoding("UTF-8");

            // 1. Get form parameters safely
            String productId = getSafeParam(request, "product_id");
            String name = getSafeParam(request, "product_name");
            String category = getSafeParam(request, "product_category");
            String sku = getSafeParam(request, "product_sku");
            String stockStr = getSafeParam(request, "product_stock");
            String priceStr = getSafeParam(request, "product_price");
            String supplier = getSafeParam(request, "product_supplier");
            String status = getSafeParam(request, "product_status");
            String currentImagePath = getSafeParam(request, "current_image_path");

            // Validate product ID
            if (productId.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/Admin/products.jsp?error=missing_id");
                return;
            }

            int id;
            try {
                id = Integer.parseInt(productId);
            } catch (NumberFormatException e) {
                response.sendRedirect(request.getContextPath() + "/Admin/products.jsp?error=invalid_id");
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

            // 2. Handle image upload with duplicate filename check
            Part imagePart = request.getPart("productImage");
            String submittedFileName = imagePart != null ? imagePart.getSubmittedFileName() : null;
            String imagePath = currentImagePath; // Use current image path by default

            // Only process new image if one was uploaded
            if (submittedFileName != null && !submittedFileName.isEmpty()) {
                String originalFileName = Paths.get(submittedFileName).getFileName().toString(); // Get just the filename

                // Get the real path to the "Images" folder inside the web application
                String uploadPath = getServletContext().getRealPath("/Images");
                File fileSaveDir = new File(uploadPath);

                // Create directory if it doesn't exist
                if (!fileSaveDir.exists()) {
                    boolean dirCreated = fileSaveDir.mkdirs();
                    if(!dirCreated) {
                        System.err.println("Failed to create upload directory: " + uploadPath);
                        response.sendRedirect(request.getContextPath() + "/Admin/update_product.jsp?id=" + id + "&error=upload_dir_failed");
                        return;
                    }
                }

                // Only proceed with file saving if directory exists and is writable
                if (fileSaveDir.exists() && fileSaveDir.isDirectory() && fileSaveDir.canWrite()) {
                    String baseFileName = originalFileName;
                    String extension = "";
                    int dotIndex = originalFileName.lastIndexOf('.');
                    if (dotIndex > 0 && dotIndex < originalFileName.length() - 1) {
                        baseFileName = originalFileName.substring(0, dotIndex);
                        extension = originalFileName.substring(dotIndex); // Includes the dot
                    }

                    // Generate unique filename with timestamp
                    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");
                    String timestamp = sdf.format(new Date());
                    String uniqueFileName = baseFileName + "_" + timestamp + extension;
                    File targetFile = new File(fileSaveDir, uniqueFileName);

                    try {
                        // Write the image file to the server
                        imagePart.write(targetFile.getAbsolutePath());
                        
                        // Verify the file was written successfully
                        if (targetFile.exists() && targetFile.length() > 0) {
                            // Store the relative path (accessible from the browser) in the database
                            imagePath = "Images/" + uniqueFileName;
                            System.out.println("Image saved successfully to: " + targetFile.getAbsolutePath());
                            
                            // Delete old image file if it's not the default
                            if (currentImagePath != null && !currentImagePath.isEmpty() && !currentImagePath.equals("Images/default.jpg")) {
                                File oldImageFile = new File(getServletContext().getRealPath("/") + currentImagePath);
                                if (oldImageFile.exists() && oldImageFile.isFile()) {
                                    if (!oldImageFile.delete()) {
                                        System.err.println("Warning: Failed to delete old image file: " + currentImagePath);
                                    }
                                }
                            }
                        } else {
                            System.err.println("Failed to save image file: " + targetFile.getAbsolutePath());
                            response.sendRedirect(request.getContextPath() + "/Admin/update_product.jsp?id=" + id + "&error=file_save_failed");
                            return;
                        }
                    } catch (Exception e) {
                        System.err.println("Error saving image file: " + e.getMessage());
                        response.sendRedirect(request.getContextPath() + "/Admin/update_product.jsp?id=" + id + "&error=file_save_error");
                        return;
                    }
                } else {
                    System.err.println("Upload directory is not writable: " + uploadPath);
                    response.sendRedirect(request.getContextPath() + "/Admin/update_product.jsp?id=" + id + "&error=dir_not_writable");
                    return;
                }
            }

            // 3. Database update
            // Using DriverManager directly
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            String sql = "UPDATE products SET name=?, category=?, price=?, sku=?, stock=?, supplier=?, " +
                    "image_path=?, status=? WHERE id=?";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, category);
            ps.setDouble(3, price);
            ps.setString(4, sku);
            ps.setInt(5, stock);
            ps.setString(6, supplier);
            ps.setString(7, imagePath);  // Store the path (either new or current) in the database
            ps.setString(8, status);
            ps.setInt(9, id);

            int result = ps.executeUpdate();  // Execute the SQL update
            if (result > 0) {
                System.out.println("Product updated successfully.");
                response.sendRedirect(request.getContextPath() + "/Admin/update_product.jsp?id=" + id + "&success=1"); // Redirect on success
            } else {
                System.err.println("Failed to update product in database.");
                response.sendRedirect(request.getContextPath() + "/Admin/update_product.jsp?id=" + id + "&error=db_update");  // Redirect on failure
            }

            ps.close(); // Close PreparedStatement

        } catch (SQLException e) {
            // Catch SQL specific errors
            System.err.println("Database error during product update: " + e.getMessage());
            e.printStackTrace(); // Log the full stack trace
            response.sendRedirect(request.getContextPath() + "/Admin/update_product.jsp?id=" + request.getParameter("product_id") + "&error=sql_exception");
        } catch (IOException e) {
            // Catch IO errors, possibly during file upload/writing
            System.err.println("File upload or processing error: " + e.getMessage());
            e.printStackTrace(); // Log the full stack trace
            response.sendRedirect(request.getContextPath() + "/Admin/update_product.jsp?id=" + request.getParameter("product_id") + "&error=io_exception");
        } catch (ServletException e) {
            // Catch Servlet errors, possibly from getPart
            System.err.println("Servlet error processing request: " + e.getMessage());
            e.printStackTrace(); // Log the full stack trace
            response.sendRedirect(request.getContextPath() + "/Admin/update_product.jsp?id=" + request.getParameter("product_id") + "&error=servlet_exception");
        } catch (ClassNotFoundException e) {
            // Catch JDBC driver not found error
            System.err.println("JDBC Driver not found: " + e.getMessage());
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/Admin/update_product.jsp?id=" + request.getParameter("product_id") + "&error=driver_not_found");
        } catch (Exception e) {
            // Catch any other unexpected exceptions
            System.err.println("An unexpected error occurred during product update: " + e.getMessage());
            e.printStackTrace(); // Log the full stack trace
            // Redirect back to update page with a generic error flag
            response.sendRedirect(request.getContextPath() + "/Admin/update_product.jsp?id=" + request.getParameter("product_id") + "&error=unexpected");
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
}