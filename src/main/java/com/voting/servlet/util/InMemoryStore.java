package com.voting.util;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

public class InMemoryStore {

    static {
        initializeCandidates();
    }

    private static void initializeCandidates() {
        String[] parties = {
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
        };

        Connection conn = null;
        PreparedStatement checkStmt = null;
        PreparedStatement insertStmt = null;
        ResultSet rs = null;

        try {
            // Make sure MySQL driver is loaded first
            Class.forName("com.mysql.cj.jdbc.Driver");
            conn = MySQLUtil.getConnection();

            for (String party : parties) {
                String checkSql = "SELECT id FROM candidates WHERE name = ?";
                checkStmt = conn.prepareStatement(checkSql);
                checkStmt.setString(1, party);
                rs = checkStmt.executeQuery();

                if (!rs.next()) {
                    String insertSql = "INSERT INTO candidates (name, party, voteCount) VALUES (?, ?, 0)";
                    insertStmt = conn.prepareStatement(insertSql);
                    insertStmt.setString(1, party);
                    insertStmt.setString(2, extractPartyName(party));
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

        } catch (ClassNotFoundException e) {
            System.err.println("❌ MySQL JDBC Driver not found!");
            System.err.println("Please add mysql-connector-java to pom.xml");
            e.printStackTrace();
        } catch (SQLException e) {
            System.err.println("❌ Database error in initializeCandidates:");
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (checkStmt != null) checkStmt.close();
                if (insertStmt != null) insertStmt.close();
                // Don't close connection here - it's managed by MySQLUtil
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    private static String extractPartyName(String fullName) {
        int openParen = fullName.indexOf('(');
        if (openParen > 0) {
            return fullName.substring(0, openParen).trim();
        }
        return fullName;
    }

    public static boolean register(String username, String hashedPassword) {
        Connection conn = null;
        PreparedStatement checkStmt = null;
        PreparedStatement insertStmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();

            String checkSql = "SELECT id FROM users WHERE username = ?";
            checkStmt = conn.prepareStatement(checkSql);
            checkStmt.setString(1, username);
            rs = checkStmt.executeQuery();

            if (rs.next()) {
                return false;
            }
            rs.close();
            checkStmt.close();

            String voterId = java.util.UUID.randomUUID().toString().substring(0, 8).toUpperCase();
            String insertSql = "INSERT INTO users (username, password, voterId, role, fullName, createdAt) " +
                    "VALUES (?, ?, ?, 'voter', ?, ?)";
            insertStmt = conn.prepareStatement(insertSql);
            insertStmt.setString(1, username);
            insertStmt.setString(2, hashedPassword);
            insertStmt.setString(3, voterId);
            insertStmt.setString(4, username);
            insertStmt.setLong(5, System.currentTimeMillis());

            int rowsAffected = insertStmt.executeUpdate();
            return rowsAffected > 0;

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
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

    public static String getPasswordHash(String username) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();
            String sql = "SELECT password FROM users WHERE username = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getString("password");
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

    public static boolean alreadyVoted(String username) {
        Connection conn = null;
        PreparedStatement getUserStmt = null;
        PreparedStatement checkVoteStmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();

            String userSql = "SELECT id FROM users WHERE username = ?";
            getUserStmt = conn.prepareStatement(userSql);
            getUserStmt.setString(1, username);
            rs = getUserStmt.executeQuery();

            if (!rs.next()) {
                return false;
            }
            int userId = rs.getInt("id");
            rs.close();
            getUserStmt.close();

            String voteSql = "SELECT id FROM votes WHERE userId = ?";
            checkVoteStmt = conn.prepareStatement(voteSql);
            checkVoteStmt.setInt(1, userId);
            rs = checkVoteStmt.executeQuery();

            return rs.next();

        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            try {
                if (rs != null) rs.close();
                if (getUserStmt != null) getUserStmt.close();
                if (checkVoteStmt != null) checkVoteStmt.close();
            } catch (SQLException e) {
                e.printStackTrace();
            }
        }
    }

    public static void markVoted(String username) {
        System.out.println("✅ User marked as voted: " + username);
    }

    public static void addVote(int partyId) {
        System.out.println("Adding vote for party ID: " + partyId);
    }

    public static Map<Integer, Integer> getAllVotes() {
        Map<Integer, Integer> voteMap = new HashMap<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();
            String sql = "SELECT id, voteCount FROM candidates ORDER BY id";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                int candidateId = rs.getInt("id");
                int voteCount = rs.getInt("voteCount");
                voteMap.put(candidateId, voteCount);
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

        return voteMap;
    }

    public static Map<String, Integer> getAllVotesWithNames() {
        Map<String, Integer> voteMap = new HashMap<>();
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();
            String sql = "SELECT name, voteCount FROM candidates ORDER BY voteCount DESC";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                String candidateName = rs.getString("name");
                int voteCount = rs.getInt("voteCount");
                voteMap.put(candidateName, voteCount);
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

        return voteMap;
    }

    public static int getTotalUsers() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();
            String sql = "SELECT COUNT(*) as total FROM users";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("total");
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

    public static int getTotalVotes() {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();
            String sql = "SELECT COUNT(*) as total FROM votes";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("total");
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
            pstmt.close();

            conn.commit();
            System.out.println("✅ All data reset successfully");

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

    public static int getUserId(String username) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;

        try {
            conn = MySQLUtil.getConnection();
            String sql = "SELECT id FROM users WHERE username = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, username);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                return rs.getInt("id");
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
        return -1;
    }
}