package com.voting.servlet;

import com.voting.util.MySQLUtil;
import com.voting.util.InMemoryStore;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

@WebServlet("/vote")
public class VoteServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("voterId") == null) {
            response.sendRedirect("login.jsp?error=" + encode("Please login first"));
            return;
        }

        String loggedInVoterId = (String) session.getAttribute("voterId");
        String username = (String) session.getAttribute("username");
        Integer userId = (Integer) session.getAttribute("userId");
        String selectedParty = request.getParameter("party");

        if (selectedParty == null || selectedParty.trim().isEmpty()) {
            response.sendRedirect("vote.jsp?error=" + encode("Please select a party"));
            return;
        }

        Connection conn = null;
        PreparedStatement checkVoterStmt = null;
        PreparedStatement checkVoteStmt = null;
        PreparedStatement getCandidateStmt = null;
        PreparedStatement insertVoteStmt = null;
        PreparedStatement updateCandidateStmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();
            conn.setAutoCommit(false);

            // Get user ID if not in session
            if (userId == null) {
                String userSql = "SELECT id FROM users WHERE voterId = ? OR username = ?";
                checkVoterStmt = conn.prepareStatement(userSql);
                checkVoterStmt.setString(1, loggedInVoterId);
                checkVoterStmt.setString(2, username);
                rs = checkVoterStmt.executeQuery();

                if (!rs.next()) {
                    response.sendRedirect("login.jsp?error=" + encode("User not found"));
                    return;
                }
                userId = rs.getInt("id");
                rs.close();
                checkVoterStmt.close();
                session.setAttribute("userId", userId);
            }

            // Check if already voted
            String checkVoteSql = "SELECT id FROM votes WHERE userId = ?";
            checkVoteStmt = conn.prepareStatement(checkVoteSql);
            checkVoteStmt.setInt(1, userId);
            rs = checkVoteStmt.executeQuery();

            if (rs.next()) {
                conn.rollback();
                response.sendRedirect("vote.jsp?error=" + encode("You have already voted!"));
                return;
            }
            rs.close();
            checkVoteStmt.close();

            // Get candidate ID
            String candidateSql = "SELECT id FROM candidates WHERE name = ?";
            getCandidateStmt = conn.prepareStatement(candidateSql);
            getCandidateStmt.setString(1, selectedParty.trim());
            rs = getCandidateStmt.executeQuery();

            if (!rs.next()) {
                conn.rollback();
                response.sendRedirect("vote.jsp?error=" + encode("Invalid party selected"));
                return;
            }
            int candidateId = rs.getInt("id");
            rs.close();
            getCandidateStmt.close();

            // Insert vote
            String insertVoteSql = "INSERT INTO votes (userId, candidateId, votedAt) VALUES (?, ?, ?)";
            insertVoteStmt = conn.prepareStatement(insertVoteSql);
            insertVoteStmt.setInt(1, userId);
            insertVoteStmt.setInt(2, candidateId);
            insertVoteStmt.setLong(3, System.currentTimeMillis());
            int rowsInserted = insertVoteStmt.executeUpdate();
            insertVoteStmt.close();

            if (rowsInserted == 0) {
                conn.rollback();
                response.sendRedirect("vote.jsp?error=" + encode("Failed to record vote"));
                return;
            }

            // Update candidate vote count
            String updateCandidateSql = "UPDATE candidates SET voteCount = voteCount + 1 WHERE id = ?";
            updateCandidateStmt = conn.prepareStatement(updateCandidateSql);
            updateCandidateStmt.setInt(1, candidateId);
            updateCandidateStmt.executeUpdate();
            updateCandidateStmt.close();

            conn.commit();
            session.setAttribute("hasVoted", true);

            String msg = "Vote cast successfully for " + selectedParty + "! Thank you!";
            response.sendRedirect("vote.jsp?success=" + encode(msg));

        } catch (SQLException e) {
            e.printStackTrace();
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            response.sendRedirect("vote.jsp?error=" + encode("Database error: " + e.getMessage()));
        } finally {
            try {
                if (rs != null) rs.close();
                if (checkVoterStmt != null) checkVoterStmt.close();
                if (checkVoteStmt != null) checkVoteStmt.close();
                if (getCandidateStmt != null) getCandidateStmt.close();
                if (insertVoteStmt != null) insertVoteStmt.close();
                if (updateCandidateStmt != null) updateCandidateStmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("voterId") == null) {
            response.sendRedirect("login.jsp?error=" + encode("Please login first"));
            return;
        }

        String username = (String) session.getAttribute("username");
        if (InMemoryStore.alreadyVoted(username)) {
            request.setAttribute("alreadyVoted", true);
        }

        java.util.List<String> candidates = java.util.Arrays.asList(
                "Nepali Congress (NC)",
                "CPN (UML)",
                "CPN (Maoist Centre)",
                "Rastriya Swatantra Party (RSP)",
                "Rastriya Prajatantra Party (RPP)",
                "Janata Samajbadi Party (JSP-N)",
                "Loktantrik Samajbadi Party (LSP)",
                "Rastriya Janamorcha",
                "Shram Sanskriti Party",
                "Ujyaalo Nepal Party",
                "Bibeksheel Sajha Party",
                "Hamro Nepali Party"
        );
        request.setAttribute("candidates", candidates);
        request.getRequestDispatcher("/vote.jsp").forward(request, response);
    }

    private String encode(String value) {
        return URLEncoder.encode(value, StandardCharsets.UTF_8);
    }
}