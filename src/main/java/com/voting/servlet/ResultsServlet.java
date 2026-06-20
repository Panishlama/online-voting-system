package com.voting.servlet;

import com.voting.util.MySQLUtil;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/results")
public class ResultsServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        Connection conn = null;
        List<CandidateResult> results = new ArrayList<>();
        long totalVotes = 0;

        try {
            conn = MySQLUtil.getConnection();

            // Get total votes
            String totalSql = "SELECT COUNT(*) as total FROM votes";
            try (PreparedStatement pstmt = conn.prepareStatement(totalSql);
                 ResultSet rs = pstmt.executeQuery()) {

                if (rs.next()) {
                    totalVotes = rs.getLong("total");
                }
            }

            // Get vote counts per candidate
            String sql = "SELECT c.id, c.name, c.party, COUNT(v.id) as voteCount " +
                    "FROM candidates c " +
                    "LEFT JOIN votes v ON c.id = v.candidateId " +
                    "GROUP BY c.id, c.name, c.party " +
                    "ORDER BY voteCount DESC";

            try (PreparedStatement pstmt = conn.prepareStatement(sql);
                 ResultSet rs = pstmt.executeQuery()) {

                while (rs.next()) {
                    CandidateResult result = new CandidateResult();
                    result.setId(rs.getInt("id"));
                    result.setName(rs.getString("name"));
                    result.setParty(rs.getString("party"));
                    result.setVoteCount(rs.getLong("voteCount"));

                    if (totalVotes > 0) {
                        double percentage = (rs.getLong("voteCount") * 100.0) / totalVotes;
                        result.setPercentage(Math.round(percentage * 100.0) / 100.0);
                    } else {
                        result.setPercentage(0.0);
                    }

                    results.add(result);
                }
            }

            req.setAttribute("results", results);
            req.setAttribute("totalVotes", totalVotes);
            req.getRequestDispatcher("/results.jsp").forward(req, resp);

        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Database error: " + e.getMessage());
            req.getRequestDispatcher("/error.jsp").forward(req, resp);
        }
    }

    public static class CandidateResult {
        private int id;
        private String name;
        private String party;
        private long voteCount;
        private double percentage;

        public int getId() { return id; }
        public void setId(int id) { this.id = id; }

        public String getName() { return name; }
        public void setName(String name) { this.name = name; }

        public String getParty() { return party; }
        public void setParty(String party) { this.party = party; }

        public long getVoteCount() { return voteCount; }
        public void setVoteCount(long voteCount) { this.voteCount = voteCount; }

        public double getPercentage() { return percentage; }
        public void setPercentage(double percentage) { this.percentage = percentage; }
    }
}