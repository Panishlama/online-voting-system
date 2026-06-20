package com.voting.servlet;

import com.voting.util.MySQLUtil;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.*;

public class VoteManager {

    private static final List<String> PARTIES = Arrays.asList(
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

    static {
        initializeCandidates();
    }

    private static void initializeCandidates() {
        Connection conn = null;
        PreparedStatement checkStmt = null;
        PreparedStatement insertStmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();

            for (String party : PARTIES) {
                String checkSql = "SELECT id FROM candidates WHERE name = ?";
                checkStmt = conn.prepareStatement(checkSql);
                checkStmt.setString(1, party);
                rs = checkStmt.executeQuery();

                if (!rs.next()) {
                    String insertSql = "INSERT INTO candidates (name, party, voteCount) VALUES (?, ?, 0)";
                    insertStmt = conn.prepareStatement(insertSql);
                    insertStmt.setString(1, party);
                    insertStmt.setString(2, party.split("\\(")[0].trim());
                    insertStmt.executeUpdate();
                    System.out.println("✅ Candidate initialized: " + party);
                }

                rs.close();
                checkStmt.close();
                if (insertStmt != null) {
                    insertStmt.close();
                    insertStmt = null;
                }
            }

        } catch (SQLException e) {
            e.printStackTrace();
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

    public static boolean vote(String party, String voterIdentifier) {
        if (voterIdentifier == null || voterIdentifier.trim().isEmpty()) {
            return false;
        }
        if (party == null || party.trim().isEmpty()) {
            return false;
        }

        if (hasAlreadyVoted(voterIdentifier)) {
            return false;
        }

        Connection conn = null;
        PreparedStatement checkVoterStmt = null;
        PreparedStatement getCandidateStmt = null;
        PreparedStatement insertVoteStmt = null;
        PreparedStatement updateCandidateStmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();
            conn.setAutoCommit(false);

            String voterSql = "SELECT id FROM users WHERE username = ? OR voterId = ?";
            checkVoterStmt = conn.prepareStatement(voterSql);
            checkVoterStmt.setString(1, voterIdentifier);
            checkVoterStmt.setString(2, voterIdentifier);
            rs = checkVoterStmt.executeQuery();

            if (!rs.next()) {
                conn.rollback();
                return false;
            }
            int userId = rs.getInt("id");
            rs.close();

            String candidateSql = "SELECT id FROM candidates WHERE name = ?";
            getCandidateStmt = conn.prepareStatement(candidateSql);
            getCandidateStmt.setString(1, party);
            rs = getCandidateStmt.executeQuery();

            if (!rs.next()) {
                conn.rollback();
                return false;
            }
            int candidateId = rs.getInt("id");
            rs.close();

            String insertVoteSql = "INSERT INTO votes (userId, candidateId, votedAt) VALUES (?, ?, ?)";
            insertVoteStmt = conn.prepareStatement(insertVoteSql);
            insertVoteStmt.setInt(1, userId);
            insertVoteStmt.setInt(2, candidateId);
            insertVoteStmt.setLong(3, System.currentTimeMillis());
            insertVoteStmt.executeUpdate();

            String updateCandidateSql = "UPDATE candidates SET voteCount = voteCount + 1 WHERE id = ?";
            updateCandidateStmt = conn.prepareStatement(updateCandidateSql);
            updateCandidateStmt.setInt(1, candidateId);
            updateCandidateStmt.executeUpdate();

            conn.commit();
            System.out.println("✅ Vote recorded: " + voterIdentifier + " voted for " + party);
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
            return false;
        } finally {
            try {
                if (rs != null) rs.close();
                if (checkVoterStmt != null) checkVoterStmt.close();
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

    public static Map<String, Integer> getVoteCounts() {
        Map<String, Integer> voteCounts = new HashMap<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();
            String sql = "SELECT name, voteCount FROM candidates ORDER BY voteCount DESC";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                voteCounts.put(rs.getString("name"), rs.getInt("voteCount"));
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        return Collections.unmodifiableMap(voteCounts);
    }

    public static boolean hasAlreadyVoted(String voterIdentifier) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();

            String userSql = "SELECT id FROM users WHERE username = ? OR voterId = ?";
            pstmt = conn.prepareStatement(userSql);
            pstmt.setString(1, voterIdentifier);
            pstmt.setString(2, voterIdentifier);
            rs = pstmt.executeQuery();

            if (!rs.next()) {
                return false;
            }
            int userId = rs.getInt("id");
            rs.close();
            pstmt.close();

            String voteSql = "SELECT id FROM votes WHERE userId = ?";
            pstmt = conn.prepareStatement(voteSql);
            pstmt.setInt(1, userId);
            rs = pstmt.executeQuery();

            return rs.next();

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public static int getVoteCountForCandidate(String party) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();
            String sql = "SELECT voteCount FROM candidates WHERE name = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, party);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("voteCount");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        return 0;
    }

    public static long getTotalVotes() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();
            String sql = "SELECT COUNT(*) as total FROM votes";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getLong("total");
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        return 0;
    }

    public static List<String> getCandidates() {
        return new ArrayList<>(PARTIES);
    }

    public static Map<String, Object> getVoteHistory(String voterIdentifier) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();

            String sql = "SELECT v.id, v.votedAt, c.name as candidateName, c.party " +
                    "FROM votes v " +
                    "JOIN users u ON v.userId = u.id " +
                    "JOIN candidates c ON v.candidateId = c.id " +
                    "WHERE u.username = ? OR u.voterId = ?";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, voterIdentifier);
            pstmt.setString(2, voterIdentifier);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                Map<String, Object> vote = new HashMap<>();
                vote.put("id", rs.getInt("id"));
                vote.put("candidateName", rs.getString("candidateName"));
                vote.put("party", rs.getString("party"));
                vote.put("votedAt", rs.getLong("votedAt"));
                return vote;
            }

        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }

        return null;
    }

    public static void reset() {
        Connection conn = null;
        PreparedStatement pstmt = null;

        try {
            conn = MySQLUtil.getConnection();
            conn.setAutoCommit(false);

            String deleteVotesSql = "DELETE FROM votes";
            pstmt = conn.prepareStatement(deleteVotesSql);
            pstmt.executeUpdate();
            pstmt.close();

            String resetCandidatesSql = "UPDATE candidates SET voteCount = 0";
            pstmt = conn.prepareStatement(resetCandidatesSql);
            pstmt.executeUpdate();

            conn.commit();
            System.out.println("✅ All votes have been reset");

        } catch (SQLException e) {
            e.printStackTrace();
            try {
                if (conn != null) {
                    conn.rollback();
                }
            } catch (SQLException ex) {
                ex.printStackTrace();
            }
        } finally {
            try {
                if (pstmt != null) pstmt.close();
                if (conn != null) {
                    conn.setAutoCommit(true);
                }
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }
}