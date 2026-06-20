package com.voting.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class MySQLUtil {

    private static final String URL = "jdbc:mysql://localhost:3306/votingdb?useSSL=false&serverTimezone=UTC&allowPublicKeyRetrieval=true";
    private static final String USERNAME = "root";
    private static final String PASSWORD = "";  // ← XAMPP default is EMPTY

    private static Connection connection = null;

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            System.out.println("✅ MySQL Driver loaded!");

            connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
            System.out.println("✅ MySQL connection successful!");
            System.out.println("📊 Database: votingdb");

        } catch (ClassNotFoundException e) {
            System.err.println("❌ MySQL Driver not found!");
            throw new RuntimeException("MySQL Driver not found", e);

        } catch (SQLException e) {
            System.err.println("❌ Connection failed: " + e.getMessage());
            System.err.println("Please check:");
            System.err.println("1. XAMPP MySQL is running");
            System.err.println("2. Database 'votingdb' exists");
            System.err.println("3. Username/password is correct");
            throw new RuntimeException("Connection failed: " + e.getMessage(), e);
        }
    }

    public static Connection getConnection() throws SQLException {
        if (connection == null || connection.isClosed()) {
            connection = DriverManager.getConnection(URL, USERNAME, PASSWORD);
        }
        return connection;
    }

    public static void close() {
        if (connection != null) {
            try {
                connection.close();
                connection = null;
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}