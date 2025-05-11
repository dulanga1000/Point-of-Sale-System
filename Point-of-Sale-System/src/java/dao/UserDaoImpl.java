/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package dao;

/**
 *
 * @author dulan
 */
import model.User;
import util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class UserDaoImpl implements UserDao {

    @Override
    public boolean addUser(User user) throws SQLException {
        String sql = "INSERT INTO users (user_display_id, first_name, last_name, username, email, password_hash, profile_image_path, role, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) { // Get generated ID

            pstmt.setString(1, user.getUserDisplayId());
            pstmt.setString(2, user.getFirstName());
            pstmt.setString(3, user.getLastName());
            pstmt.setString(4, user.getUsername());
            pstmt.setString(5, user.getEmail());
            pstmt.setString(6, user.getPasswordHash());
            pstmt.setString(7, user.getProfileImagePath());
            pstmt.setString(8, user.getRole());
            pstmt.setString(9, user.getStatus());

            int rowsAffected = pstmt.executeUpdate();
            if (rowsAffected > 0) {
                try (ResultSet generatedKeys = pstmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        user.setId(generatedKeys.getInt(1)); // Set the auto-generated ID to the user object
                    }
                }
                return true;
            }
            return false;
        }
    }

    @Override
    public boolean updateUser(User user) throws SQLException {
        String sql = "UPDATE users SET user_display_id = ?, first_name = ?, last_name = ?, username = ?, " +
                     "email = ?, profile_image_path = ?, role = ?, status = ? " + // removed updated_at, DB handles it
                     "WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {

            pstmt.setString(1, user.getUserDisplayId());
            pstmt.setString(2, user.getFirstName());
            pstmt.setString(3, user.getLastName());
            pstmt.setString(4, user.getUsername());
            pstmt.setString(5, user.getEmail());
            pstmt.setString(6, user.getProfileImagePath());
            pstmt.setString(7, user.getRole());
            pstmt.setString(8, user.getStatus());
            pstmt.setInt(9, user.getId());

            return pstmt.executeUpdate() > 0;
        }
    }

    @Override
    public boolean updateUserPassword(int userId, String newPasswordHash) throws SQLException {
        String sql = "UPDATE users SET password_hash = ? WHERE id = ?"; // removed updated_at
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, newPasswordHash);
            pstmt.setInt(2, userId);
            return pstmt.executeUpdate() > 0;
        }
    }

    @Override
    public boolean deleteUser(int userId) throws SQLException {
        String sql = "DELETE FROM users WHERE id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            return pstmt.executeUpdate() > 0;
        }
    }

    @Override
    public User getUserById(int userId) throws SQLException {
        String sql = "SELECT * FROM users WHERE id = ?";
        User user = null;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setInt(1, userId);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) user = mapResultSetToUser(rs);
            }
        }
        return user;
    }
    
    @Override
    public User getUserByUsername(String username) throws SQLException {
        String sql = "SELECT * FROM users WHERE username = ?";
        User user = null;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) user = mapResultSetToUser(rs);
            }
        }
        return user;
    }

    @Override
    public User getUserByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ?";
        User user = null;
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, email);
            try (ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) user = mapResultSetToUser(rs);
            }
        }
        return user;
    }

    @Override
    public List<User> getAllUsers() throws SQLException {
        List<User> users = new ArrayList<>();
        String sql = "SELECT * FROM users ORDER BY first_name, last_name";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) users.add(mapResultSetToUser(rs));
        }
        return users;
    }

    private User mapResultSetToUser(ResultSet rs) throws SQLException {
        User user = new User();
        user.setId(rs.getInt("id"));
        user.setUserDisplayId(rs.getString("user_display_id"));
        user.setFirstName(rs.getString("first_name"));
        user.setLastName(rs.getString("last_name"));
        user.setUsername(rs.getString("username"));
        user.setEmail(rs.getString("email"));
        user.setPasswordHash(rs.getString("password_hash"));
        user.setProfileImagePath(rs.getString("profile_image_path"));
        user.setRole(rs.getString("role"));
        user.setStatus(rs.getString("status"));
        user.setCreatedAt(rs.getTimestamp("created_at"));
        user.setUpdatedAt(rs.getTimestamp("updated_at"));
        return user;
    }

    @Override
    public boolean isEmailTaken(String email, Integer excludeUserId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE email = ?";
        if (excludeUserId != null) sql += " AND id != ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, email);
            if (excludeUserId != null) pstmt.setInt(2, excludeUserId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    @Override
    public boolean isUsernameTaken(String username, Integer excludeUserId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE username = ?";
        if (excludeUserId != null) sql += " AND id != ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, username);
            if (excludeUserId != null) pstmt.setInt(2, excludeUserId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }

    @Override
    public boolean isUserDisplayIdTaken(String userDisplayId, Integer excludeUserId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM users WHERE user_display_id = ?";
        if (excludeUserId != null) sql += " AND id != ?";
        try (Connection conn = DBConnection.getConnection(); PreparedStatement pstmt = conn.prepareStatement(sql)) {
            pstmt.setString(1, userDisplayId);
            if (excludeUserId != null) pstmt.setInt(2, excludeUserId);
            try (ResultSet rs = pstmt.executeQuery()) {
                return rs.next() && rs.getInt(1) > 0;
            }
        }
    }
}