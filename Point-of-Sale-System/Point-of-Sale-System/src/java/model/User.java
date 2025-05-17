/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author dulan
 */

import java.sql.Timestamp;
import java.time.LocalDateTime; // Alternative to Timestamp

public class User {
    private int id;
    private String userDisplayId;
    private String firstName;
    private String lastName;
    private String username;
    private String email;
    private String passwordHash; // Store only the hash
    private String profileImagePath; // Path to the image file on the server
    private String role;
    private String status;
    private Timestamp createdAt;
    private Timestamp updatedAt;
    // Or use LocalDateTime:
    // private LocalDateTime createdAt;
    // private LocalDateTime updatedAt;


    // Constructors
    public User() {
    }

    // Constructor for creating a new user (ID, createdAt, updatedAt are auto-generated/set)
    public User(String userDisplayId, String firstName, String lastName, String username, String email, String passwordHash, String profileImagePath, String role, String status) {
        this.userDisplayId = userDisplayId;
        this.firstName = firstName;
        this.lastName = lastName;
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
        this.profileImagePath = profileImagePath;
        this.role = role;
        this.status = status;
    }


    // Getters and Setters
    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getUserDisplayId() {
        return userDisplayId;
    }

    public void setUserDisplayId(String userDisplayId) {
        this.userDisplayId = userDisplayId;
    }

    public String getFirstName() {
        return firstName;
    }

    public void setFirstName(String firstName) {
        this.firstName = firstName;
    }

    public String getLastName() {
        return lastName;
    }

    public void setLastName(String lastName) {
        this.lastName = lastName;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    public String getProfileImagePath() {
        return profileImagePath;
    }

    public void setProfileImagePath(String profileImagePath) {
        this.profileImagePath = profileImagePath;
    }

    public String getRole() {
        return role;
    }

    public void setRole(String role) {
        this.role = role;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    // Using LocalDateTime (optional, more modern Java time API)
    // public LocalDateTime getCreatedAt() {
    //     return createdAt;
    // }

    // public void setCreatedAt(LocalDateTime createdAt) {
    //     this.createdAt = createdAt;
    // }

    // public LocalDateTime getUpdatedAt() {
    //     return updatedAt;
    // }

    // public void setUpdatedAt(LocalDateTime updatedAt) {
    //     this.updatedAt = updatedAt;
    // }

    @Override
    public String toString() {
        return "User{" +
                "id=" + id +
                ", userDisplayId='" + userDisplayId + '\'' +
                ", firstName='" + firstName + '\'' +
                ", lastName='" + lastName + '\'' +
                ", username='" + username + '\'' +
                ", email='" + email + '\'' +
                // Do NOT include passwordHash in typical toString() for security reasons
                ", profileImagePath='" + profileImagePath + '\'' +
                ", role='" + role + '\'' +
                ", status='" + status + '\'' +
                ", createdAt=" + createdAt +
                ", updatedAt=" + updatedAt +
                '}';
    }
}