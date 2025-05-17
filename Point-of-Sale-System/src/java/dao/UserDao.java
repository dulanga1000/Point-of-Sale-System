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
import java.sql.SQLException;
import java.util.List;

public interface UserDao {
    boolean addUser(User user) throws SQLException;
    boolean updateUser(User user) throws SQLException;
    boolean updateUserPassword(int userId, String newPasswordHash) throws SQLException;
    boolean deleteUser(int userId) throws SQLException;
    User getUserById(int userId) throws SQLException;
    User getUserByUsername(String username) throws SQLException;
    User getUserByEmail(String email) throws SQLException; // For checking uniqueness
    List<User> getAllUsers() throws SQLException;

    // Uniqueness checks (important for server-side validation before insert/update)
    boolean isEmailTaken(String email, Integer excludeUserId) throws SQLException;
    boolean isUsernameTaken(String username, Integer excludeUserId) throws SQLException;
    boolean isUserDisplayIdTaken(String userDisplayId, Integer excludeUserId) throws SQLException;
}