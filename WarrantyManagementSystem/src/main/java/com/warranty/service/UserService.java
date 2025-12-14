package com.warranty.service;

import com.warranty.dao.UserDAO;
import com.warranty.model.User;
import com.warranty.util.PasswordUtil;

/**
 * Service layer for User-related business logic
 */
public class UserService {
    
    private UserDAO userDAO;

    public UserService() {
        this.userDAO = new UserDAO();
    }

    /**
     * Authenticate user with username and password
     * @param username Username
     * @param password Plain password
     * @return User object if authentication successful, null otherwise
     */
    public User authenticate(String username, String password) {
        // Validate input
        if (username == null || username.trim().isEmpty() || 
            password == null || password.trim().isEmpty()) {
            return null;
        }

        // Get user from database
        User user = userDAO.getUserByUsername(username.trim());
        
        if (user == null) {
            return null;
        }

        // Check if user is active
        if (!user.isActive()) {
            return null;
        }

        // Verify password
        if (PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
            return user;
        }

        return null;
    }

    /**
     * Register new user
     * @param user User object with plain password
     * @return true if registration successful, false otherwise
     */
    public boolean registerUser(User user, String plainPassword) {
        // Validate input
        if (user == null || plainPassword == null) {
            return false;
        }

        // Check if username already exists
        if (userDAO.getUserByUsername(user.getUsername()) != null) {
            return false;
        }

        // Check if email already exists
        if (userDAO.getUserByEmail(user.getEmail()) != null) {
            return false;
        }

        // Hash password
        String hashedPassword = PasswordUtil.hashPassword(plainPassword);
        user.setPasswordHash(hashedPassword);

        // Create user in database
        return userDAO.createUser(user);
    }

    /**
     * Change user password
     * @param userId User ID
     * @param oldPassword Old password (plain)
     * @param newPassword New password (plain)
     * @return true if password changed successfully
     */
    public boolean changePassword(int userId, String oldPassword, String newPassword) {
        // Get user
        User user = userDAO.getUserById(userId);
        if (user == null) {
            return false;
        }

        // Verify old password
        if (!PasswordUtil.verifyPassword(oldPassword, user.getPasswordHash())) {
            return false;
        }

        // Validate new password
        if (!PasswordUtil.isValidPassword(newPassword)) {
            return false;
        }

        // Hash new password
        String hashedPassword = PasswordUtil.hashPassword(newPassword);

        // Update in database
        return userDAO.updatePassword(userId, hashedPassword);
    }

    /**
     * Get user by ID
     */
    public User getUserById(int userId) {
        return userDAO.getUserById(userId);
    }

    /**
     * Get user by username
     */
    public User getUserByUsername(String username) {
        return userDAO.getUserByUsername(username);
    }

    /**
     * Get user by email
     */
    public User getUserByEmail(String email) {
        return userDAO.getUserByEmail(email);
    }

    /**
     * Update user information
     */
    public boolean updateUser(User user) {
        if (user == null || user.getUserId() <= 0) {
            return false;
        }
        return userDAO.updateUser(user);
    }

    /**
     * Deactivate user account
     */
    public boolean deactivateUser(int userId) {
        return userDAO.deactivateUser(userId);
    }

    /**
     * Activate user account
     */
    public boolean activateUser(int userId) {
        return userDAO.activateUser(userId);
    }
}
