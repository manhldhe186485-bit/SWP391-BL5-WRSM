package com.warranty.util;

/**
 * Utility to generate BCrypt password hashes
 * Run this to generate hashes for default users
 */
public class GeneratePasswordHash {
    
    public static void main(String[] args) {
        // Generate hashes for default passwords
        System.out.println("=== Generated Password Hashes ===\n");
        
        System.out.println("Admin (Admin@123):");
        System.out.println(PasswordUtil.hashPassword("Admin@123"));
        System.out.println();
        
        System.out.println("Tech Manager (Manager@123):");
        System.out.println(PasswordUtil.hashPassword("Manager@123"));
        System.out.println();
        
        System.out.println("Technician (Tech@123):");
        System.out.println(PasswordUtil.hashPassword("Tech@123"));
        System.out.println();
        
        System.out.println("Warehouse (Warehouse@123):");
        System.out.println(PasswordUtil.hashPassword("Warehouse@123"));
        System.out.println();
    }
}
