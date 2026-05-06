/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import java.io.File;
import java.io.IOException;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.UUID;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

@WebServlet("/ImageUploadServlet")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024, // 1 MB
    maxFileSize = 1024 * 1024 * 5,   // 5 MB
    maxRequestSize = 1024 * 1024 * 10 // 10 MB
)
public class ImageUploadServlet extends HttpServlet {
    
    private static final String UPLOAD_DIRECTORY = "web/Images";
    
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        
        // Get the absolute path of the web application
        String applicationPath = request.getServletContext().getRealPath("");
        // Create upload directory if it doesn't exist
        String uploadPath = applicationPath + File.separator + UPLOAD_DIRECTORY;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists()) {
            uploadDir.mkdirs(); // Use mkdirs() to create parent directories if needed
        }
        
        try {
            // Get the uploaded file part
            Part filePart = request.getPart("productImage");
            String fileName = getSubmittedFileName(filePart);
            
            if (fileName != null && !fileName.isEmpty()) {
                // Generate unique filename
                String uniqueFileName = UUID.randomUUID().toString() + getFileExtension(fileName);
                
                // Save the file
                Path filePath = Paths.get(uploadPath + File.separator + uniqueFileName);
                Files.copy(filePart.getInputStream(), filePath);
                
                // Return the relative path for database storage
                String relativePath = UPLOAD_DIRECTORY + "/" + uniqueFileName;
                
                // Set content type to plain text
                response.setContentType("text/plain");
                response.getWriter().write(relativePath);
            } else {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.getWriter().write("No file uploaded");
            }
            
        } catch (Exception e) {
            e.printStackTrace(); // Log the error
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.getWriter().write("Error uploading file: " + e.getMessage());
        }
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
    
    private String getFileExtension(String fileName) {
        int lastIndexOf = fileName.lastIndexOf(".");
        if (lastIndexOf == -1) {
            return ""; // Empty extension
        }
        return fileName.substring(lastIndexOf);
    }
} 