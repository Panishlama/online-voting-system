package com.voting.servlet;

import com.voting.util.MySQLUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@WebServlet("/totalVote")
public class TotalVoteServlet extends HttpServlet {

    private static final int PAGE_SIZE = 10;

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);

        // ✅ Check BOTH isAdmin AND role
        Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
        String role = (String) session.getAttribute("role");

        if (session == null || isAdmin == null || !isAdmin || !"admin".equals(role)) {
            response.sendRedirect("admin.jsp?error=Admin+login+required");
            return;
        }

        Connection conn = null;

        try {
            conn = MySQLUtil.getConnection();

            int page = 1;
            String pageParam = request.getParameter("page");
            if (pageParam != null && !pageParam.isEmpty()) {
                try {
                    page = Integer.parseInt(pageParam);
                } catch (NumberFormatException e) {
                    page = 1;
                }
            }

            int offset = (page - 1) * PAGE_SIZE;

            // Get total count
            String countSql = "SELECT COUNT(*) as total FROM votes";
            long totalRecords = 0;
            try (PreparedStatement pstmt = conn.prepareStatement(countSql);
                 ResultSet rs = pstmt.executeQuery()) {
                if (rs.next()) {
                    totalRecords = rs.getLong("total");
                }
            }

            long totalPages = (long) Math.ceil((double) totalRecords / PAGE_SIZE);

            // Get votes with pagination
            String sql = "SELECT v.id, v.userId, v.candidateId, v.votedAt, " +
                    "u.username, u.fullName, u.voterId, " +
                    "c.name as candidateName, c.party " +
                    "FROM votes v " +
                    "LEFT JOIN users u ON v.userId = u.id " +
                    "LEFT JOIN candidates c ON v.candidateId = c.id " +
                    "ORDER BY v.votedAt DESC " +
                    "LIMIT ? OFFSET ?";

            List<Map<String, Object>> votesList = new ArrayList<>();

            try (PreparedStatement pstmt = conn.prepareStatement(sql)) {
                pstmt.setInt(1, PAGE_SIZE);
                pstmt.setInt(2, offset);

                try (ResultSet rs = pstmt.executeQuery()) {
                    while (rs.next()) {
                        Map<String, Object> vote = new HashMap<>();
                        vote.put("id", rs.getInt("id"));
                        vote.put("userId", rs.getInt("userId"));
                        vote.put("candidateId", rs.getInt("candidateId"));
                        vote.put("votedAt", rs.getLong("votedAt"));
                        vote.put("username", rs.getString("username"));
                        vote.put("fullName", rs.getString("fullName"));
                        vote.put("voterId", rs.getString("voterId"));
                        vote.put("candidateName", rs.getString("candidateName"));
                        vote.put("party", rs.getString("party"));
                        votesList.add(vote);
                    }
                }
            }

            // Get candidate vote counts
            String candidateSql = "SELECT c.id, c.name, c.party, COUNT(v.id) as voteCount " +
                    "FROM candidates c " +
                    "LEFT JOIN votes v ON c.id = v.candidateId " +
                    "GROUP BY c.id, c.name, c.party " +
                    "ORDER BY voteCount DESC";

            List<Map<String, Object>> candidateResults = new ArrayList<>();
            try (PreparedStatement pstmt = conn.prepareStatement(candidateSql);
                 ResultSet rs = pstmt.executeQuery()) {

                while (rs.next()) {
                    Map<String, Object> candidate = new HashMap<>();
                    candidate.put("id", rs.getInt("id"));
                    candidate.put("name", rs.getString("name"));
                    candidate.put("party", rs.getString("party"));
                    candidate.put("voteCount", rs.getLong("voteCount"));
                    candidateResults.add(candidate);
                }
            }

            long totalVotes = 0;
            for (Map<String, Object> candidate : candidateResults) {
                totalVotes += (Long) candidate.get("voteCount");
            }

            request.setAttribute("votesList", votesList);
            request.setAttribute("candidateResults", candidateResults);
            request.setAttribute("totalVotes", totalVotes);
            request.setAttribute("currentPage", page);
            request.setAttribute("totalPages", totalPages);
            request.setAttribute("pageSize", PAGE_SIZE);
            request.setAttribute("totalRecords", totalRecords);

            request.getRequestDispatcher("/totalVote.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Database error: " + e.getMessage());
            request.getRequestDispatcher("/error.jsp").forward(request, response);
        }
    }
}