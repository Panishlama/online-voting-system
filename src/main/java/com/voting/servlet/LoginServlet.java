package com.voting.servlet;

import com.voting.util.MySQLUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // Get login credentials - supports both loginId and username
        String loginId = request.getParameter("loginId");
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Use loginId if provided, otherwise use username
        String loginValue = (loginId != null && !loginId.isEmpty()) ? loginId : username;

        if (loginValue == null || password == null || loginValue.trim().isEmpty() || password.isEmpty()) {
            response.sendRedirect("login.jsp?error=" + encode("Please enter username and password"));
            return;
        }

        loginValue = loginValue.trim();

        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();

            // Check by username OR voterId
            String sql = "SELECT id, fullName, username, voterId, password, role FROM users WHERE username = ? OR voterId = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, loginValue);
            pstmt.setString(2, loginValue);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                String storedHashedPassword = rs.getString("password");

                if (BCrypt.checkpw(password, storedHashedPassword)) {
                    HttpSession session = request.getSession();
                    session.setAttribute("userId", rs.getInt("id"));
                    session.setAttribute("username", rs.getString("username"));
                    session.setAttribute("fullName", rs.getString("fullName"));
                    session.setAttribute("voterId", rs.getString("voterId"));
                    session.setAttribute("role", rs.getString("role"));
                    session.setAttribute("isAdmin", "admin".equals(rs.getString("role")));

                    // Check if user already voted
                    String voteCheckSql = "SELECT id FROM votes WHERE userId = ?";
                    PreparedStatement voteStmt = conn.prepareStatement(voteCheckSql);
                    voteStmt.setInt(1, rs.getInt("id"));
                    ResultSet voteRs = voteStmt.executeQuery();
                    session.setAttribute("hasVoted", voteRs.next());
                    voteRs.close();
                    voteStmt.close();

                    if ("admin".equals(rs.getString("role"))) {
                        response.sendRedirect("admin_dashboard.jsp");
                    } else {
                        response.sendRedirect("dashboard.jsp");
                    }
                } else {
                    response.sendRedirect("login.jsp?error=" + encode("Invalid username or password"));
                }
            } else {
                response.sendRedirect("login.jsp?error=" + encode("User not found. Please register."));
            }

        } catch (SQLException e) {
            e.printStackTrace();
            response.sendRedirect("login.jsp?error=" + encode("Database error: " + e.getMessage()));
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private String encode(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}