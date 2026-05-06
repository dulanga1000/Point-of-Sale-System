/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/JSP_Servlet/Servlet.java to edit this template
 */
package controller;

import dao.UserDao;
import dao.UserDaoImpl;
import model.User;
import util.PasswordUtil;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.io.PrintWriter; // For sending JSON response
import java.sql.SQLException;
import java.util.Base64;
import java.util.List; // For list of users
import java.util.UUID;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

/**
 *
 * @author dulan
 */


@WebServlet("/userAction")
@MultipartConfig
public class UserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDao userDao;
    private static final String UPLOAD_DIR_NAME = "uploads" + File.separator + "profile_images";

    @Override
    public void init() {
        userDao = new UserDaoImpl();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("listall".equalsIgnoreCase(action)) {
            listAllUsers(request, response);
        } else {
            // Default GET behavior: If JSP is requested or other actions,
            // you might forward or redirect. Here, we assume user_management.jsp is accessed directly.
            // If an unknown GET action is provided, you could send an error or redirect.
            response.sendRedirect(request.getContextPath() + "/Admin/user_management.jsp");
        }
    }

    private void listAllUsers(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            List<User> users = userDao.getAllUsers();
            // Manually build JSON - A library like Jackson or Gson is recommended for production
            StringBuilder jsonBuilder = new StringBuilder("[");
            for (int i = 0; i < users.size(); i++) {
                User user = users.get(i);
                jsonBuilder.append("{");
                jsonBuilder.append("\"id\":").append(user.getId()).append(","); // Database ID
                jsonBuilder.append("\"userDisplayId\":\"").append(escapeJson(user.getUserDisplayId())).append("\",");
                jsonBuilder.append("\"firstName\":\"").append(escapeJson(user.getFirstName())).append("\",");
                jsonBuilder.append("\"lastName\":\"").append(escapeJson(user.getLastName())).append("\",");
                jsonBuilder.append("\"username\":\"").append(escapeJson(user.getUsername())).append("\",");
                jsonBuilder.append("\"email\":\"").append(escapeJson(user.getEmail())).append("\",");
                // DO NOT SEND PASSWORD HASH TO CLIENT
                String imagePath = user.getProfileImagePath();
                if (imagePath != null && !imagePath.isEmpty()) {
                    // Send relative path, JS can prepend context path if needed
                    jsonBuilder.append("\"profileImagePath\":\"").append(escapeJson(imagePath.replace(File.separator, "/"))).append("\",");
                } else {
                    jsonBuilder.append("\"profileImagePath\":null,");
                }
                jsonBuilder.append("\"role\":\"").append(escapeJson(user.getRole())).append("\",");
                jsonBuilder.append("\"status\":\"").append(escapeJson(user.getStatus())).append("\"");
                // CreatedAt/UpdatedAt can be added if needed by client
                jsonBuilder.append("}");
                if (i < users.size() - 1) {
                    jsonBuilder.append(",");
                }
            }
            jsonBuilder.append("]");

            response.setContentType("application/json");
            response.setCharacterEncoding("UTF-8");
            PrintWriter out = response.getWriter();
            out.print(jsonBuilder.toString());
            out.flush();

        } catch (SQLException e) {
            e.printStackTrace(); // Log this
            response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.setContentType("application/json");
            response.getWriter().print("{\"error\":\"Error fetching users from database: " + escapeJson(e.getMessage()) + "\"}");
        }
    }
    
    // Helper to escape strings for JSON
    private String escapeJson(String s) {
        if (s == null) return "";
        return s.replace("\\", "\\\\")
                .replace("\"", "\\\"")
                .replace("\b", "\\b")
                .replace("\f", "\\f")
                .replace("\n", "\\n")
                .replace("\r", "\\r")
                .replace("\t", "\\t");
    }


    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        String redirectPage = request.getContextPath() + "/Admin/user_management.jsp";

        try {
            if (action == null) {
                request.getSession().setAttribute("userActionError", "Action parameter is missing.");
                response.sendRedirect(redirectPage);
                return;
            }

            switch (action.toLowerCase()) {
                case "add":
                    addUser(request, response);
                    break;
                case "update":
                    updateUser(request, response);
                    break;
                case "delete":
                    deleteUser(request, response);
                    break;
                default:
                    request.getSession().setAttribute("userActionError", "Unknown action: " + action);
                    response.sendRedirect(redirectPage);
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.getSession().setAttribute("userActionError", "Database error: " + e.getMessage());
            response.sendRedirect(redirectPage);
        } catch (Exception e) {
            e.printStackTrace();
            request.getSession().setAttribute("userActionError", "An unexpected error occurred: " + e.getMessage());
            response.sendRedirect(redirectPage);
        }
    }

    private void addUser(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        // ... (Validation logic as before) ...
        String userDisplayId = request.getParameter("userDisplayId");
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");
        String role = request.getParameter("role");
        String status = request.getParameter("status");
        String imageBase64 = request.getParameter("imageBase64");
        String redirectPage = request.getContextPath() + "/Admin/user_management.jsp";

        if (password == null || password.isEmpty() || !password.equals(confirmPassword)) {
            request.getSession().setAttribute("userActionError", "Passwords do not match or are empty.");
            response.sendRedirect(redirectPage); return;
        }
        if (password.length() < 6) {
            request.getSession().setAttribute("userActionError", "Password must be at least 6 characters.");
            response.sendRedirect(redirectPage); return;
        }
        if (userDao.isUsernameTaken(username, null)) {
            request.getSession().setAttribute("userActionError", "Username '" + username + "' is already taken.");
            response.sendRedirect(redirectPage); return;
        }
        if (userDao.isEmailTaken(email, null)) {
            request.getSession().setAttribute("userActionError", "Email '" + email + "' is already registered.");
            response.sendRedirect(redirectPage); return;
        }
         if (userDisplayId == null || userDisplayId.trim().isEmpty() || userDao.isUserDisplayIdTaken(userDisplayId.trim(), null)) {
            request.getSession().setAttribute("userActionError", "User Display ID is required and must be unique.");
            response.sendRedirect(redirectPage); return;
        }
        
        String hashedPassword = PasswordUtil.hashPassword(password);
        if (hashedPassword == null) {
            request.getSession().setAttribute("userActionError", "Error processing password.");
            response.sendRedirect(redirectPage); return;
        }

        String profileImagePathDb = null;
        if (imageBase64 != null && !imageBase64.isEmpty() && imageBase64.startsWith("data:image")) {
            profileImagePathDb = saveBase64ImageToServer(imageBase64, request);
            if (profileImagePathDb == null) {
                 request.getSession().setAttribute("userActionError", "Failed to save profile image.");
                 response.sendRedirect(redirectPage); return;
            }
        }

        User newUser = new User(userDisplayId, firstName, lastName, username, email, hashedPassword, profileImagePathDb, role, status);

        if (userDao.addUser(newUser)) { // addUser in DAO now sets the ID on the newUser object
            request.getSession().setAttribute("userActionSuccess", "User '" + newUser.getUsername() + "' added successfully with DB ID: " + newUser.getId());
        } else {
            request.getSession().setAttribute("userActionError", "Failed to add user.");
        }
        response.sendRedirect(redirectPage);
    }

    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException, ServletException {
        // ... (Validation logic as before) ...
        String redirectPage = request.getContextPath() + "/Admin/user_management.jsp";
        int id;
        try { id = Integer.parseInt(request.getParameter("userId")); }
        catch (NumberFormatException e) {
            request.getSession().setAttribute("userActionError", "Invalid User ID for update.");
            response.sendRedirect(redirectPage); return;
        }

        User existingUser = userDao.getUserById(id);
        if (existingUser == null) {
            request.getSession().setAttribute("userActionError", "User not found for update (ID: " + id + ").");
            response.sendRedirect(redirectPage); return;
        }
        
        String userDisplayId = request.getParameter("userDisplayId");
        String firstName = request.getParameter("firstName");
        String lastName = request.getParameter("lastName");
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String role = request.getParameter("role");
        String status = request.getParameter("status");
        String imageBase64 = request.getParameter("imageBase64");

        if (userDisplayId == null || userDisplayId.trim().isEmpty() || userDao.isUserDisplayIdTaken(userDisplayId.trim(), id)) {
             request.getSession().setAttribute("userActionError", "User Display ID is required and must be unique.");
            response.sendRedirect(redirectPage); return;
        }
        if (userDao.isUsernameTaken(username, id)) {
            request.getSession().setAttribute("userActionError", "Username '" + username + "' is already taken by another user.");
            response.sendRedirect(redirectPage); return;
        }
        if (userDao.isEmailTaken(email, id)) {
            request.getSession().setAttribute("userActionError", "Email '" + email + "' is already registered by another user.");
            response.sendRedirect(redirectPage); return;
        }

        existingUser.setUserDisplayId(userDisplayId);
        existingUser.setFirstName(firstName);
        existingUser.setLastName(lastName);
        existingUser.setUsername(username);
        existingUser.setEmail(email);
        existingUser.setRole(role);
        existingUser.setStatus(status);

        String newProfileImagePath = existingUser.getProfileImagePath(); // Keep old path by default
        if (imageBase64 != null && !imageBase64.isEmpty() && imageBase64.startsWith("data:image")) {
            if (existingUser.getProfileImagePath() != null && !existingUser.getProfileImagePath().isEmpty()) {
                deleteImageFile(existingUser.getProfileImagePath(), request); // Delete old image
            }
            newProfileImagePath = saveBase64ImageToServer(imageBase64, request);
             if (newProfileImagePath == null) {
                 request.getSession().setAttribute("userActionWarning", "Failed to save new profile image. Other details might have been updated.");
                 // Continue, but image won't be updated
             }
        }
        existingUser.setProfileImagePath(newProfileImagePath);


        boolean detailsUpdated = userDao.updateUser(existingUser);
        boolean passwordChangedSuccessfully = true; 

        String newPassword = request.getParameter("newPassword");
        String confirmNewPassword = request.getParameter("confirmNewPassword");

        if (newPassword != null && !newPassword.isEmpty()) {
            if (!newPassword.equals(confirmNewPassword)) {
                request.getSession().setAttribute("userActionError", "New passwords do not match. Other details " + (detailsUpdated ? "were" : "were not") + " updated.");
                response.sendRedirect(redirectPage); return;
            }
             if (newPassword.length() < 6) {
                request.getSession().setAttribute("userActionError", "New password must be at least 6 characters. Other details " + (detailsUpdated ? "were" : "were not") + " updated.");
                response.sendRedirect(redirectPage); return;
            }
            String newHashedPassword = PasswordUtil.hashPassword(newPassword);
            if (newHashedPassword == null) {
                 request.getSession().setAttribute("userActionError", "Error processing new password. Other details " + (detailsUpdated ? "were" : "were not") + " updated.");
                 response.sendRedirect(redirectPage); return;
            }
            passwordChangedSuccessfully = userDao.updateUserPassword(id, newHashedPassword);
        }

        if (detailsUpdated && passwordChangedSuccessfully) {
            request.getSession().setAttribute("userActionSuccess", "User updated successfully!");
        } else {
            // Construct a more specific error message if needed
            String errorMsg = "";
            if (!detailsUpdated) errorMsg += "Failed to update user details. ";
            if (!passwordChangedSuccessfully && (newPassword != null && !newPassword.isEmpty())) errorMsg += "Failed to update password.";
             if (request.getSession().getAttribute("userActionWarning") != null) { // Prepend warning if image save failed
                errorMsg = request.getSession().getAttribute("userActionWarning") + " " + errorMsg;
                request.getSession().removeAttribute("userActionWarning");
            }
            if (errorMsg.trim().isEmpty() && (newPassword == null || newPassword.isEmpty())) errorMsg = "No changes detected or update failed.";


            request.getSession().setAttribute("userActionError", errorMsg.trim());
        }
        response.sendRedirect(redirectPage);
    }

    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        String redirectPage = request.getContextPath() + "/Admin/user_management.jsp";
        int id;
        try { 
            id = Integer.parseInt(request.getParameter("userId")); 
            System.out.println("Attempting to delete user with ID: " + id);
        }
        catch (NumberFormatException e){
            System.out.println("Invalid user ID format: " + request.getParameter("userId"));
            request.getSession().setAttribute("userActionError", "Invalid User ID for deletion.");
            response.sendRedirect(redirectPage); return;
        }

        User userToDelete = userDao.getUserById(id);
        if (userToDelete == null) {
            System.out.println("User not found for deletion. ID: " + id);
            request.getSession().setAttribute("userActionError", "User not found for deletion (ID: " + id + ").");
            response.sendRedirect(redirectPage); return;
        }

        System.out.println("Found user to delete: " + userToDelete.getUsername() + " (ID: " + id + ")");

        if (userToDelete.getProfileImagePath() != null && !userToDelete.getProfileImagePath().isEmpty()) {
            System.out.println("Attempting to delete profile image: " + userToDelete.getProfileImagePath());
            deleteImageFile(userToDelete.getProfileImagePath(), request);
        }

        try {
            boolean deleted = userDao.deleteUser(id);
            if (deleted) {
                System.out.println("Successfully deleted user with ID: " + id);
                request.getSession().setAttribute("userActionSuccess", "User deleted successfully!");
            } else {
                System.out.println("Failed to delete user with ID: " + id);
                request.getSession().setAttribute("userActionError", "Failed to delete user. User might not exist (ID: "+id+").");
            }
        } catch (SQLException e) {
            System.out.println("SQL Exception while deleting user: " + e.getMessage());
            request.getSession().setAttribute("userActionError", "Database error while deleting user: " + e.getMessage());
        }
        response.sendRedirect(redirectPage);
    }

    private String saveBase64ImageToServer(String base64ImageString, HttpServletRequest request) throws IOException {
        // ... (logic as before) ...
        if (base64ImageString == null || !base64ImageString.contains(",")) return null;
        String[] parts = base64ImageString.split(",");
        if (parts.length != 2) return null;

        String metadata = parts[0]; String base64Data = parts[1];
        Pattern pattern = Pattern.compile("data:image/(.*?);base64");
        Matcher matcher = pattern.matcher(metadata);
        String extension = matcher.find() ? matcher.group(1) : "png";
        if ("jpeg".equalsIgnoreCase(extension)) extension = "jpg";

        byte[] imageBytes = Base64.getDecoder().decode(base64Data);
        String uploadPath = getServletContext().getRealPath("") + File.separator + UPLOAD_DIR_NAME;
        File uploadDir = new File(uploadPath);
        if (!uploadDir.exists() && !uploadDir.mkdirs()) {
            System.err.println("Failed to create upload directory: " + uploadPath);
            return null; // Indicate failure
        }

        String fileName = UUID.randomUUID().toString() + "." + extension;
        File imageFile = new File(uploadDir.getAbsolutePath() + File.separator + fileName);

        try (OutputStream os = new FileOutputStream(imageFile)) { os.write(imageBytes); }
        return UPLOAD_DIR_NAME + File.separator + fileName; // Return relative path
    }

    private void deleteImageFile(String relativeImagePath, HttpServletRequest request) {
        // ... (logic as before) ...
        if (relativeImagePath == null || relativeImagePath.isEmpty()) return;
        try {
            String fullPath = getServletContext().getRealPath("") + File.separator + relativeImagePath;
            File imageFile = new File(fullPath);
            if (imageFile.exists() && !imageFile.delete()) {
                System.err.println("Failed to delete image file: " + fullPath);
            }
        } catch (Exception e) {
            System.err.println("Error deleting image file " + relativeImagePath + ": " + e.getMessage());
        }
    }
}