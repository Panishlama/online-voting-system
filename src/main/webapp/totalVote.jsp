<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.voting.util.MySQLUtil" %>
<%@ page import="java.util.*" %>

<%
/* ---------------- ADMIN SESSION CHECK ---------------- */
Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
String role = (String) session.getAttribute("role");

if (isAdmin == null || !isAdmin || !"admin".equals(role)) {
    response.sendRedirect("admin.jsp?error=Admin+login+required");
    return;
}

/* ---------------- MYSQL CONNECTION ---------------- */
long totalVotes = 0;
List<Map<String, Object>> partyRanking = new ArrayList<>();
List<Map<String, Object>> votersList = new ArrayList<>();

Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    conn = MySQLUtil.getConnection();

    // Get total votes
    String totalSql = "SELECT COUNT(*) as total FROM votes";
    pstmt = conn.prepareStatement(totalSql);
    rs = pstmt.executeQuery();
    if (rs.next()) {
        totalVotes = rs.getLong("total");
    }
    rs.close();
    pstmt.close();

    // Get party ranking
    String rankingSql = "SELECT c.name as party, COUNT(v.id) as votes " +
                        "FROM candidates c " +
                        "LEFT JOIN votes v ON c.id = v.candidateId " +
                        "GROUP BY c.id, c.name " +
                        "ORDER BY votes DESC";
    pstmt = conn.prepareStatement(rankingSql);
    rs = pstmt.executeQuery();

    int rank = 1;
    while (rs.next()) {
        Map<String, Object> party = new HashMap<>();
        party.put("rank", rank++);
        party.put("party", rs.getString("party"));
        party.put("votes", rs.getLong("votes"));
        partyRanking.add(party);
    }
    rs.close();
    pstmt.close();

    // Get voters list
    String votersSql = "SELECT u.voterId, u.fullName, u.username, c.name as votedParty " +
                       "FROM votes v " +
                       "JOIN users u ON v.userId = u.id " +
                       "JOIN candidates c ON v.candidateId = c.id " +
                       "ORDER BY v.votedAt DESC";
    pstmt = conn.prepareStatement(votersSql);
    rs = pstmt.executeQuery();

    int count = 1;
    while (rs.next()) {
        Map<String, Object> voter = new HashMap<>();
        voter.put("index", count++);
        voter.put("voterId", rs.getString("voterId"));
        voter.put("fullName", rs.getString("fullName"));
        voter.put("username", rs.getString("username"));
        voter.put("votedParty", rs.getString("votedParty"));
        votersList.add(voter);
    }

} catch (SQLException e) {
    e.printStackTrace();
    request.setAttribute("error", "Database error: " + e.getMessage());
} finally {
    try {
        if (rs != null) rs.close();
        if (pstmt != null) pstmt.close();
    } catch (SQLException e) {
        e.printStackTrace();
    }
}
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Total Votes - VoteEasy</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            background: #f0f2f5;
            padding-top: 20px;
        }
        .stats-card {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            margin-bottom: 25px;
        }
        .stats-card .number {
            font-size: 36px;
            font-weight: 700;
            color: #4f46e5;
        }
        .table-container {
            background: white;
            border-radius: 12px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.08);
            margin-bottom: 25px;
        }
        .table-container h4 {
            color: #1a1a2e;
            margin-bottom: 15px;
            border-bottom: 2px solid #e5e7eb;
            padding-bottom: 10px;
        }
        .rank-badge {
            display: inline-block;
            width: 30px;
            height: 30px;
            line-height: 30px;
            text-align: center;
            border-radius: 50%;
            font-weight: 700;
        }
        .rank-1 { background: #fcd34d; color: #92400e; }
        .rank-2 { background: #d1d5db; color: #4b5563; }
        .rank-3 { background: #d97706; color: #fff; }
        .rank-other { background: #e5e7eb; color: #6b7280; }
        .logout-btn {
            color: white;
            text-decoration: none;
            padding: 8px 20px;
            border: 1px solid rgba(255,255,255,0.3);
            border-radius: 8px;
            transition: all 0.3s ease;
        }
        .logout-btn:hover {
            background: rgba(255,255,255,0.1);
            color: white;
        }
        .empty-state {
            text-align: center;
            padding: 40px 20px;
            color: #6b7280;
        }
        .empty-state .icon {
            font-size: 48px;
            margin-bottom: 15px;
        }
        .badge-votes {
            background: #4f46e5;
            color: white;
            padding: 5px 12px;
            border-radius: 20px;
        }
    </style>
</head>

<body>

<!-- NAVBAR -->
<nav class="navbar navbar-expand-lg navbar-dark bg-primary shadow-sm">
    <div class="container-fluid px-4">
        <a class="navbar-brand fw-bold" href="admin_dashboard.jsp">🗳️ E-Matdaan Admin</a>
        <div class="ms-auto">
            <span class="text-white me-3">
                👤 <%= session.getAttribute("fullName") != null ? session.getAttribute("fullName") : "Admin" %>
            </span>
            <a class="logout-btn" href="logout">Logout</a>
        </div>
    </div>
</nav>

<!-- CONTENT -->
<div class="container mt-4">

    <!-- Error Message -->
    <%
        String error = (String) request.getAttribute("error");
        if (error != null) {
    %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <strong>❌ </strong> <%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <!-- Stats Card -->
    <div class="stats-card">
        <div class="row align-items-center">
            <div class="col-md-6">
                <h2>📊 Total Votes</h2>
                <p class="text-muted mb-0">All votes cast in the election</p>
            </div>
            <div class="col-md-6 text-end">
                <span class="number"><%= totalVotes %></span>
                <span class="text-muted ms-2">votes</span>
            </div>
        </div>
    </div>

    <!-- Party Ranking -->
    <div class="table-container">
        <h4>🏛️ Party Ranking</h4>
        <%
            if (partyRanking.isEmpty()) {
        %>
            <div class="empty-state">
                <div class="icon">📭</div>
                <p>No votes have been cast yet.</p>
            </div>
        <%
            } else {
        %>
            <table class="table table-striped table-hover">
                <thead>
                    <tr>
                        <th>Rank</th>
                        <th>Party</th>
                        <th>Votes</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    for (Map<String, Object> party : partyRanking) {
                        int rank = (Integer) party.get("rank");
                        String partyName = (String) party.get("party");
                        long votes = (Long) party.get("votes");

                        String rankClass = "rank-other";
                        if (rank == 1) rankClass = "rank-1";
                        else if (rank == 2) rankClass = "rank-2";
                        else if (rank == 3) rankClass = "rank-3";
                %>
                    <tr>
                        <td>
                            <span class="rank-badge <%= rankClass %>">
                                <%= rank == 1 ? "🏆" : rank == 2 ? "🥈" : rank == 3 ? "🥉" : "#" + rank %>
                            </span>
                        </td>
                        <td><strong><%= partyName %></strong></td>
                        <td><span class="badge-votes"><%= votes %></span></td>
                    </tr>
                <%
                    }
                %>
                </tbody>
            </table>
        <%
            }
        %>
    </div>

    <!-- Voters List -->
    <div class="table-container">
        <h4>👥 Voters List</h4>
        <%
            if (votersList.isEmpty()) {
        %>
            <div class="empty-state">
                <div class="icon">📭</div>
                <p>No voters have cast their vote yet.</p>
            </div>
        <%
            } else {
        %>
            <div class="table-responsive">
                <table class="table table-striped table-hover">
                    <thead>
                        <tr>
                            <th>#</th>
                            <th>Voter ID</th>
                            <th>Full Name</th>
                            <th>Username</th>
                            <th>Voted For</th>
                        </tr>
                    </thead>
                    <tbody>
                    <%
                        for (Map<String, Object> voter : votersList) {
                    %>
                        <tr>
                            <td><%= voter.get("index") %></td>
                            <td><code><%= voter.get("voterId") %></code></td>
                            <td><%= voter.get("fullName") %></td>
                            <td>@<%= voter.get("username") %></td>
                            <td><span class="badge bg-success"><%= voter.get("votedParty") %></span></td>
                        </tr>
                    <%
                        }
                    %>
                    </tbody>
                </table>
            </div>
        <%
            }
        %>
    </div>

    <!-- Back to Dashboard -->
    <div class="text-center mt-3 mb-4">
        <a href="admin_dashboard.jsp" class="btn btn-outline-primary">
            ← Back to Dashboard
        </a>
        <a href="results.jsp" class="btn btn-outline-success ms-2">
            📊 View Public Results
        </a>
    </div>

</div>

<!-- Footer -->
<footer class="text-center py-3 text-muted border-top mt-3 bg-white">
    <div class="container">
        <p class="mb-0">© <%= java.time.Year.now() %> E-Matdaan - Admin Panel</p>
        <small>Total Voters: <%= votersList.size() %> | Total Votes: <%= totalVotes %></small>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>