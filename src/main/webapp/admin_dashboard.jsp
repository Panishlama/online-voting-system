<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.voting.util.MySQLUtil" %>

<%
/* ---------------- ADMIN SESSION CHECK ---------------- */
Boolean isAdmin = (Boolean) session.getAttribute("isAdmin");
if (isAdmin == null || !isAdmin) {
    response.sendRedirect("admin.jsp");
    return;
}

/* ---------------- MYSQL ---------------- */
long totalVotes = 0;
long totalUsers = 0;
long totalCandidates = 0;
Connection conn = null;
PreparedStatement pstmt = null;
ResultSet rs = null;

try {
    conn = MySQLUtil.getConnection();

    // Get total votes
    String voteSql = "SELECT COUNT(*) as total FROM votes";
    pstmt = conn.prepareStatement(voteSql);
    rs = pstmt.executeQuery();
    if (rs.next()) {
        totalVotes = rs.getLong("total");
    }
    rs.close();
    pstmt.close();

    // Get total users
    String userSql = "SELECT COUNT(*) as total FROM users";
    pstmt = conn.prepareStatement(userSql);
    rs = pstmt.executeQuery();
    if (rs.next()) {
        totalUsers = rs.getLong("total");
    }
    rs.close();
    pstmt.close();

    // Get total candidates
    String candidateSql = "SELECT COUNT(*) as total FROM candidates";
    pstmt = conn.prepareStatement(candidateSql);
    rs = pstmt.executeQuery();
    if (rs.next()) {
        totalCandidates = rs.getLong("total");
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
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Admin Dashboard - E-Matdaan</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <script src="https://cdn.tailwindcss.com"></script>

    <style>
        body {
            background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 100%);
            min-height: 100vh;
            padding-top: 80px;
        }

        .glass-card {
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.06);
            border-radius: 1.25rem;
            transition: all 0.3s ease;
        }

        .glass-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 16px 48px rgba(0, 0, 0, 0.1);
        }

        .stat-card {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(4px);
            border: 1px solid rgba(255, 255, 255, 0.6);
            border-radius: 1rem;
            padding: 1.5rem;
            transition: all 0.3s ease;
            text-align: center;
        }

        .stat-card:hover {
            transform: translateY(-6px);
            background: rgba(255, 255, 255, 0.95);
            box-shadow: 0 12px 32px rgba(0, 0, 0, 0.1);
            border-color: #a5b4fc;
        }

        .stat-card .number {
            font-size: 2.5rem;
            font-weight: 700;
            background: linear-gradient(135deg, #4f46e5, #7c3aed);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .stat-card .label {
            color: #64748b;
            font-weight: 500;
            margin-top: 0.25rem;
        }

        .stat-card .icon {
            font-size: 2rem;
            margin-bottom: 0.5rem;
            display: block;
        }

        .navbar-glass {
            background: rgba(15, 23, 42, 0.88);
            backdrop-filter: blur(14px);
            -webkit-backdrop-filter: blur(14px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        }

        .btn-gradient {
            background: linear-gradient(135deg, #4f46e5, #7c3aed);
            border: none;
            transition: all 0.3s ease;
        }

        .btn-gradient:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(79, 70, 229, 0.3);
        }

        .welcome-badge {
            background: linear-gradient(135deg, #fbbf24, #f59e0b);
            padding: 0.25rem 1rem;
            border-radius: 50px;
            font-weight: 600;
            color: #1e293b;
            font-size: 0.85rem;
        }

        .dashboard-card {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(4px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            border-radius: 1.25rem;
            padding: 2.5rem;
            text-align: center;
            transition: all 0.3s ease;
        }

        .dashboard-card:hover {
            transform: translateY(-6px);
            box-shadow: 0 16px 48px rgba(0, 0, 0, 0.1);
            background: rgba(255, 255, 255, 0.95);
        }

        .dashboard-card .icon {
            font-size: 4rem;
            margin-bottom: 1rem;
        }

        .dashboard-card .big-number {
            font-size: 4rem;
            font-weight: 700;
            background: linear-gradient(135deg, #4f46e5, #7c3aed);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .alert {
            border-radius: 1rem;
            border: none;
        }

        @media (max-width: 640px) {
            .dashboard-card .big-number {
                font-size: 2.8rem;
            }
            .stat-card .number {
                font-size: 2rem;
            }
        }
    </style>
</head>

<body>

<!-- ========== NAVBAR ========== -->
<nav class="navbar navbar-expand-lg navbar-dark navbar-glass fixed-top">
    <div class="container">
        <a class="navbar-brand fw-bold text-white fs-3 d-flex align-items-center gap-2" href="admin_dashboard.jsp">
            <span style="font-size: 2rem;">🗳️</span>
            <span class="fw-semibold">E-Matdaan Admin</span>
        </a>
        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-center gap-1 gap-lg-2">
                <li class="nav-item">
                    <a class="nav-link active text-white" href="admin_dashboard.jsp">
                        <i class="bi bi-speedometer2 me-1"></i> Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-light opacity-75 hover-opacity-100" href="totalVote">
                        <i class="bi bi-bar-chart-fill me-1"></i> View Results
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link btn btn-outline-light rounded-pill px-4 py-1 ms-2" href="logout">
                        <i class="bi bi-box-arrow-right me-1"></i> Logout
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- ========== MAIN CONTENT ========== -->
<main class="container py-4 mt-3">

    <!-- Welcome Section -->
    <div class="mb-4 d-flex flex-wrap align-items-center justify-content-between gap-2">
        <div>
            <h1 class="display-6 fw-bold text-dark mb-0">
                👋 Welcome, Admin!
            </h1>
            <p class="text-secondary-emphasis mt-1">
                Here's your election overview
            </p>
        </div>
        <div>
            <span class="welcome-badge">
                <i class="bi bi-calendar-check me-1"></i> Election 2082
            </span>
        </div>
    </div>

    <!-- Error Message -->
    <%
        String error = (String) request.getAttribute("error");
        if (error != null) {
    %>
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i>
            <strong>Error:</strong> <%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <!-- ===== STATS GRID ===== -->
    <div class="row g-4 mb-4">
        <div class="col-md-3 col-6">
            <div class="stat-card">
                <span class="icon">🗳️</span>
                <div class="number"><%= totalVotes %></div>
                <div class="label">Total Votes Cast</div>
            </div>
        </div>
        <div class="col-md-3 col-6">
            <div class="stat-card">
                <span class="icon">👥</span>
                <div class="number"><%= totalUsers %></div>
                <div class="label">Registered Voters</div>
            </div>
        </div>
        <div class="col-md-3 col-6">
            <div class="stat-card">
                <span class="icon">🏛️</span>
                <div class="number"><%= totalCandidates %></div>
                <div class="label">Total Candidates</div>
            </div>
        </div>
        <div class="col-md-3 col-6">
            <div class="stat-card">
                <span class="icon">📈</span>
                <div class="number">
                    <%= (totalVotes > 0 && totalUsers > 0) ? Math.round((totalVotes * 100.0) / totalUsers) : 0 %>%
                </div>
                <div class="label">Voter Turnout</div>
            </div>
        </div>
    </div>

    <!-- ===== VIEW RESULTS CARD ===== -->
    <div class="row justify-content-center">
        <div class="col-lg-6 col-md-8">
            <div class="dashboard-card">
                <div class="icon">📊</div>
                <h4 class="fw-bold text-dark mb-2">Election Results</h4>
                <p class="text-secondary-emphasis mb-3">
                    View complete election results and vote breakdown
                </p>
                <div class="big-number"><%= totalVotes %></div>
                <p class="text-muted small mt-1">Total votes recorded</p>
                <hr class="my-4 opacity-25">
                <a href="totalVote" class="btn btn-gradient btn-lg px-5 text-white rounded-pill shadow-sm">
                    <i class="bi bi-eye me-2"></i> View Full Results
                </a>
            </div>
        </div>
    </div>

</main>

<!-- ========== FOOTER ========== -->
<footer class="text-center py-4 mt-4 border-top bg-white bg-opacity-50">
    <div class="container">
        <span class="text-muted small">
            © <%= java.time.Year.now() %> E-Matdaan · Admin Dashboard
        </span>
        <span class="text-muted mx-2">·</span>
        <span class="text-muted small">Built with ❤️ for Nepal Election 2082</span>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>