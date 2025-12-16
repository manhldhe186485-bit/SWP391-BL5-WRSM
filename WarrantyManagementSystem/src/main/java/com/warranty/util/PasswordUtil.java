package com.warranty.util;

import org.mindrot.jbcrypt.BCrypt;

/**
 * Password utility class for hashing and verification
 */
public class PasswordUtil {
    
    private static final int BCRYPT_ROUNDS = 10;

    /**
     * Hash a password using BCrypt
     */
    public static String hashPassword(String plainPassword) {
        return BCrypt.hashpw(plainPassword, BCrypt.gensalt(BCRYPT_ROUNDS));
    }

    /**
     * Verify a password against a hash
     */
    public static boolean verifyPassword(String plainPassword, String hashedPassword) {
        try {
            return BCrypt.checkpw(plainPassword, hashedPassword);
        } catch (Exception e) {
            return false;
        }
    }

    /**
     * Check if password meets minimum requirements
     */
    public static boolean isValidPassword(String password) {
        if (password == null || password.length() < 6) {
            return false;
        }
        // Add more validation rules as needed
        return true;
    }
}
