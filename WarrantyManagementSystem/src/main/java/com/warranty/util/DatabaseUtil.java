package com.warranty.util;

import java.io.IOException;
import java.io.InputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;
import java.util.Properties;

/**
 * Database connection utility class
 */
public class DatabaseUtil {
    private static String URL;
    private static String USERNAME;
    private static String PASSWORD;
    private static String DRIVER;

    static {
        loadDatabaseProperties();
    }

    private static void loadDatabaseProperties() {
        try {
            // Check if running in Docker (environment variables are set)
            String dbHost = System.getenv("DB_HOST");
            
            if (dbHost != null && !dbHost.isEmpty()) {
                // Docker environment - use environment variables
                String dbPort = System.getenv("DB_PORT");
                String dbName = System.getenv("DB_NAME");
                String dbUser = System.getenv("DB_USER");
                String dbPassword = System.getenv("DB_PASSWORD");
                
                URL = String.format("jdbc:mysql://%s:%s/%s?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true",
                        dbHost, dbPort, dbName);
                USERNAME = dbUser;
                PASSWORD = dbPassword;
                DRIVER = "com.mysql.cj.jdbc.Driver";
                
                System.out.println("Database configuration loaded from environment variables (Docker mode)");
            } else {
                // Local environment - use properties file
                InputStream input = DatabaseUtil.class.getClassLoader()
                        .getResourceAsStream("database.properties");
                
                if (input == null) {
                    System.err.println("Unable to find database.properties");
                    throw new RuntimeException("Database configuration file not found");
                }

                Properties prop = new Properties();
                prop.load(input);

                URL = prop.getProperty("db.url");
                USERNAME = prop.getProperty("db.username");
                PASSWORD = prop.getProperty("db.password");
                DRIVER = prop.getProperty("db.driver");
                
                input.close();
                
                System.out.println("Database configuration loaded from properties file (Local mode)");
            }

            // Load JDBC driver
            Class.forName(DRIVER);
            System.out.println("JDBC Driver loaded successfully");
            
        } catch (IOException | ClassNotFoundException e) {
            e.printStackTrace();
            throw new RuntimeException("Failed to load database configuration", e);
        }
    }

    /**
     * Get a database connection
     */
    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USERNAME, PASSWORD);
    }

    /**
     * Close database connection
     */
    public static void closeConnection(Connection conn) {
        if (conn != null) {
            try {
                conn.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Close all database resources
     */
    public static void closeResources(AutoCloseable... resources) {
        for (AutoCloseable resource : resources) {
            if (resource != null) {
                try {
                    resource.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
