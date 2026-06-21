package com.voting.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class MySQLUtil {
    private static Connection connection = null;

    // Your Railway MySQL Connection Details
    private static final String RAILWAY_HOST = "reseau.proxy.rlwy.net";
    private static final String RAILWAY_PORT = "20180";
    private static final String RAILWAY_DATABASE = "railway";
    private static final String RAILWAY_USERNAME = "root";
    private static final String RAILWAY_PASSWORD = "mRvzyIUPrmooLgeWmPrzXpwAPZDXncFa";

    // Your Local XAMPP Connection Details
    private static final String LOCAL_HOST = "localhost";
    private static final String LOCAL_PORT = "3306";
    private static final String LOCAL_DATABASE = "votingdb";
    private static final String LOCAL_USERNAME = "root";
    private static final String LOCAL_PASSWORD = "";

    public static Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            try {
                // =============================================
                // STEP 1: Try Environment Variables (Railway)
                // =============================================
                String host = System.getenv("DB_HOST");
                String port = System.getenv("DB_PORT");
                String dbName = System.getenv("DB_NAME");
                String username = System.getenv("DB_USERNAME");
                String password = System.getenv("DB_PASSWORD");

                // =============================================
                // STEP 2: Try Railway's Default Variables
                // =============================================
                if (host == null || host.isEmpty()) {
                    host = System.getenv("MYSQLHOST");
                }
                if (port == null || port.isEmpty()) {
                    port = System.getenv("MYSQLPORT");
                }
                if (dbName == null || dbName.isEmpty()) {
                    dbName = System.getenv("MYSQLDATABASE");
                }
                if (username == null || username.isEmpty()) {
                    username = System.getenv("MYSQLUSER");
                }
                if (password == null || password.isEmpty()) {
                    password = System.getenv("MYSQLPASSWORD");
                }

                // =============================================
                // STEP 3: Fallback to Hardcoded Values
                // =============================================
                // Check if running on Railway (by checking for RAILWAY_ENVIRONMENT)
                String railwayEnv = System.getenv("RAILWAY_ENVIRONMENT");
                boolean isRailway = (railwayEnv != null && !railwayEnv.isEmpty());

                if (host == null || host.isEmpty()) {
                    if (isRailway) {
                        host = RAILWAY_HOST;
                        System.out.println("📍 Using Railway host (hardcoded)");
                    } else {
                        host = LOCAL_HOST;
                        System.out.println("📍 Using localhost (XAMPP)");
                    }
                }

                if (port == null || port.isEmpty()) {
                    if (isRailway) {
                        port = RAILWAY_PORT;
                    } else {
                        port = LOCAL_PORT;
                    }
                }

                if (dbName == null || dbName.isEmpty()) {
                    if (isRailway) {
                        dbName = RAILWAY_DATABASE;
                    } else {
                        dbName = LOCAL_DATABASE;
                    }
                }

                if (username == null || username.isEmpty()) {
                    if (isRailway) {
                        username = RAILWAY_USERNAME;
                    } else {
                        username = LOCAL_USERNAME;
                    }
                }

                if (password == null || password.isEmpty()) {
                    if (isRailway) {
                        password = RAILWAY_PASSWORD;
                    } else {
                        password = LOCAL_PASSWORD;
                    }
                }

                // =============================================
                // STEP 4: Build Connection URL
                // =============================================
                String url = "jdbc:mysql://" + host + ":" + port + "/" + dbName +
                        "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

                // =============================================
                // STEP 5: Print Connection Details (Debugging)
                // =============================================
                System.out.println("=========================================");
                System.out.println("🔄 Connecting to database...");
                System.out.println("📍 Host: " + host);
                System.out.println("🔌 Port: " + port);
                System.out.println("📁 Database: " + dbName);
                System.out.println("👤 Username: " + username);
                System.out.println("🔑 Password: " + (password == null || password.isEmpty() ? "[empty]" : "****"));
                System.out.println("=========================================");

                // =============================================
                // STEP 6: Load Driver & Connect
                // =============================================
                Class.forName("com.mysql.cj.jdbc.Driver");
                connection = DriverManager.getConnection(url, username, password);
                System.out.println("✅ Database connected successfully!");
                System.out.println("=========================================");

            } catch (ClassNotFoundException e) {
                System.err.println("❌ MySQL Driver not found: " + e.getMessage());
                throw new SQLException("Driver not found", e);
            } catch (SQLException e) {
                System.err.println("❌ Database connection failed: " + e.getMessage());
                throw e;
            }
        }
        return connection;
    }

    public static void closeConnection() {
        if (connection != null) {
            try {
                connection.close();
                System.out.println("✅ Database connection closed.");
            } catch (SQLException e) {
                System.err.println("❌ Error closing connection: " + e.getMessage());
            }
        }
    }
}