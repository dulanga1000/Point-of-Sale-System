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

@WebServlet("/addProduct")
@MultipartConfig(fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
        maxFileSize = 1024 * 1024 * 10,             // 10MB
        maxRequestSize = 1024 * 1024 * 50)          // 50MB
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
            Part imagePart = request.getPart("product_image");
            String submittedFileName = imagePart != null ? imagePart.getSubmittedFileName() : null;
            String imagePath = "Images/default.jpg"; // Default image path

            if (submittedFileName != null && !submittedFileName.isEmpty()) {
                 String originalFileName = Paths.get(submittedFileName).getFileName().toString(); // Get just the filename

                 // Get the real path to the "Images" folder inside the web application
                 String uploadPath = getServletContext().getRealPath("/Images");
                 File fileSaveDir = new File(uploadPath);

                 // Create directory if it doesn't exist
                 if (!fileSaveDir.exists()) {
                     boolean dirCreated = fileSaveDir.mkdirs();
                     if(dirCreated) {
                         System.out.println("Created upload directory: " + uploadPath);
                     } else {
                         System.err.println("Failed to create upload directory: " + uploadPath);
                         // If directory creation fails, we cannot save the image
                         // Proceed with default image and log error
                         System.err.println("Image upload failed: Could not create upload directory.");
                         // Skip saving the file and use default imagePath
                         originalFileName = null; // Indicate that file was not saved
                     }
                 }

                 // Only proceed with file saving if directory exists and is writable (basic check)
                 if (originalFileName != null && fileSaveDir.exists() && fileSaveDir.isDirectory()) {
                     String baseFileName = originalFileName;
                     String extension = "";
                     int dotIndex = originalFileName.lastIndexOf('.');
                     if (dotIndex > 0 && dotIndex < originalFileName.length() - 1) {
                         baseFileName = originalFileName.substring(0, dotIndex);
                         extension = originalFileName.substring(dotIndex); // Includes the dot
                     }

                     File targetFile = new File(fileSaveDir, originalFileName);
                     int count = 0;
                     String uniqueFileName = originalFileName;

                     // Check for existing file and generate unique name if necessary
                     while (targetFile.exists()) {
                         // Option 1: Append a counter
                         // uniqueFileName = baseFileName + "_" + count + extension;
                         // Option 2: Append a timestamp (more unique)
                         SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");
                         String timestamp = sdf.format(new Date());
                         uniqueFileName = baseFileName + "_" + timestamp + extension;

                         targetFile = new File(fileSaveDir, uniqueFileName);
                         count++;
                         // Optional: Add a limit to count to prevent infinite loops, though timestamp is better
                         // if (count > 100) { throw new IOException("Could not generate unique filename."); }
                     }

                     String filePath = fileSaveDir.getAbsolutePath() + File.separator + uniqueFileName;
                     imagePart.write(filePath); // Write the image file to the server

                     // Store the relative path (accessible from the browser) in the database
                     imagePath = "Images/" + uniqueFileName;
                     System.out.println("Image saved to: " + filePath + ", DB path: " + imagePath);
                 } else {
                     // Directory didn't exist or originalFileName was null after checks
                     System.err.println("Image upload failed: Could not save file to directory.");
                     // imagePath remains default.jpg
                 }

            } else {
                 // No image uploaded or part was empty, use default image path
                 System.out.println("No image file uploaded or part was empty. Using default image.");
                 imagePath = "Images/default.jpg";
            }


            // 3. Database insert
            // Using DriverManager directly as in your original code
            Class.forName("com.mysql.cj.jdbc.Driver");
            con = DriverManager.getConnection(DB_URL, DB_USER, DB_PASSWORD);

            String sql = "INSERT INTO products (name, category, price, sku, stock, supplier, image_path, status) " +
                        "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";

            PreparedStatement ps = con.prepareStatement(sql);
            ps.setString(1, name);
            ps.setString(2, category);
            ps.setDouble(3, price);
            ps.setString(4, sku);
            ps.setInt(5, stock);
            ps.setString(6, supplier);
            ps.setString(7, imagePath);  // Store the (potentially renamed) relative path in the database
            ps.setString(8, status);

            int result = ps.executeUpdate();  // Execute the SQL insert
            if (result > 0) {
                System.out.println("Product added successfully.");
                response.sendRedirect(request.getContextPath() + "/Admin/add_product.jsp?success=1"); // Redirect on success
            } else {
                 System.err.println("Failed to add product to database.");
                 response.sendRedirect(request.getContextPath() + "/Admin/add_product.jsp?error=db_insert");  // Redirect on failure
            }

            ps.close(); // Close PreparedStatement

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
}
