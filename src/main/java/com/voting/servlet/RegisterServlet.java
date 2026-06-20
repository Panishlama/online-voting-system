package com.voting.servlet;

import com.voting.util.MySQLUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.UUID;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String fullName = request.getParameter("fullName");
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (fullName == null || username == null || password == null || confirmPassword == null ||
                fullName.trim().isEmpty() || username.trim().isEmpty() ||
                password.length() < 6 || !password.equals(confirmPassword)) {
            response.sendRedirect("register.jsp?error=" + encode("Invalid input or passwords do not match"));
            return;
        }

        username = username.trim();

        Connection conn = null;
        PreparedStatement checkStmt = null;
        PreparedStatement insertStmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();

            String checkSql = "SELECT username FROM users WHERE username = ?";
            checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, username);
            rs = checkStmt.executeQuery();

            if (rs.next()) {
                response.sendRedirect("register.jsp?error=" + encode("Username already taken"));
                return;
            }

            String voterId = UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt(12));

            String insertSql = "INSERT INTO users (fullName, username, voterId, password, role, createdAt) VALUES (?, ?, ?, ?, ?, ?)";
            insertStmt = conn.prepareStatement(insertSql);
            insertStmt.setString(1, fullName.trim());
            insertStmt.setString(2, username);
            insertStmt.setString(3, voterId);
            insertStmt.setString(4, hashedPassword);
            insertStmt.setString(5, "voter");
            insertStmt.setLong(6, System.currentTimeMillis());

            int rowsAffected = insertStmt.executeUpdate();

            if (rowsAffected > 0) {
                response.sendRedirect("login.jsp?success=" + encode("Registration successful! Your Voter ID is: " + voterId));
            } else {
                response.sendRedirect("register.jsp?error=" + encode("Registration failed. Please try again."));
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("register.jsp?error=" + encode("Database error: " + e.getMessage()));
        } finally {
            try {
                if (rs != null) rs.close();
                if (checkStmt != null) checkStmt.close();
                if (insertStmt != null) insertStmt.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private String encode(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}