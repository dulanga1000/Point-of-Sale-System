/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package util;

/**
 *
 * @author dulan
 */

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.security.SecureRandom; // For generating salts in a real scenario
// For a real application, use a library like jBCrypt or Spring Security for password hashing.

public class PasswordUtil {

    /**
     * Hashes a password using SHA-256.
     * WARNING: THIS IS A SIMPLIFIED EXAMPLE FOR DEMONSTRATION.
     * For production, use a strong adaptive hashing algorithm like Argon2, scrypt, or bcrypt
     * with a unique salt for each user.
     *
     * @param password The plain text password.
     * @return The SHA-256 hashed password as a hex string, or null if an error occurs.
     */
    public static String hashPassword(String password) {
        if (password == null || password.isEmpty()) {
            return null;
        }
        try {
            MessageDigest digest = MessageDigest.getInstance("SHA-256");
            byte[] encodedhash = digest.digest(password.getBytes(StandardCharsets.UTF_8));
            return bytesToHex(encodedhash);
        } catch (NoSuchAlgorithmException e) {
            System.err.println("SHA-256 algorithm not found: " + e.getMessage());
            // Use a proper logger in a real application
            return null; // Or throw a runtime exception
        }
    }

    /**
     * Converts a byte array to a hexadecimal string.
     * @param hash The byte array.
     * @return The hexadecimal string.
     */
    private static String bytesToHex(byte[] hash) {
        StringBuilder hexString = new StringBuilder(2 * hash.length);
        for (byte b : hash) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) {
                hexString.append('0');
            }
            hexString.append(hex);
        }
        return hexString.toString();
    }

    /**
     * Verifies a plain text password against a stored hash.
     * This method would need to re-hash the provided plainPassword and compare it to the storedHash.
     * For bcrypt/scrypt/Argon2, dedicated verify methods provided by the libraries are used.
     *
     * @param plainPassword The password to verify.
     * @param storedHash The stored hashed password.
     * @return true if the password matches the hash, false otherwise.
     */
    public static boolean verifyPassword(String plainPassword, String storedHash) {
        if (plainPassword == null || storedHash == null) {
            return false;
        }
        String hashOfInput = hashPassword(plainPassword);
        return storedHash.equals(hashOfInput);
    }

    // Example for generating a salt (you would store this with the password_hash)
    // public static byte[] generateSalt() {
    //     SecureRandom random = new SecureRandom();
    //     byte[] salt = new byte[16]; // 16 bytes is a common size
    //     random.nextBytes(salt);
    //     return salt;
    // }
}