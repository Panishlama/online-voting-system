<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.voting.util.MySQLUtil" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Vote - E-Matdaan</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <script src="https://cdn.tailwindcss.com"></script>

    <style>
        body {
            background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 100%);
            min-height: 100vh;
            padding-top: 80px;
        }

        .navbar-glass {
            background: rgba(15, 23, 42, 0.95) !important;
            backdrop-filter: blur(14px);
            -webkit-backdrop-filter: blur(14px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
            padding: 12px 0;
        }

        /* ===== BIG RED LOGOUT BUTTON IN NAVBAR ===== */
        .btn-logout-nav {
            background: #dc2626 !important;
            border: none !important;
            color: white !important;
            padding: 10px 28px !important;
            border-radius: 50px !important;
            font-weight: 700 !important;
            transition: all 0.3s ease !important;
            font-size: 0.95rem !important;
            text-decoration: none !important;
            display: inline-block !important;
            box-shadow: 0 4px 20px rgba(220, 38, 38, 0.4) !important;
            letter-spacing: 0.5px;
        }

        .btn-logout-nav:hover {
            background: #b91c1c !important;
            transform: translateY(-3px) !important;
            box-shadow: 0 8px 35px rgba(220, 38, 38, 0.6) !important;
            color: white !important;
        }

        .btn-logout-nav i {
            font-size: 1.2rem;
            margin-right: 10px;
        }

        /* ===== LOGOUT BUTTON INSIDE PAGE (BACKUP) ===== */
        .btn-logout-page {
            background: #dc2626 !important;
            border: none !important;
            color: white !important;
            padding: 12px 40px !important;
            border-radius: 50px !important;
            font-weight: 700 !important;
            transition: all 0.3s ease !important;
            font-size: 1.1rem !important;
            text-decoration: none !important;
            display: inline-block !important;
            box-shadow: 0 4px 20px rgba(220, 38, 38, 0.4) !important;
        }

        .btn-logout-page:hover {
            background: #b91c1c !important;
            transform: translateY(-3px) !important;
            box-shadow: 0 8px 35px rgba(220, 38, 38, 0.6) !important;
            color: white !important;
        }

        .btn-logout-page i {
            font-size: 1.2rem;
            margin-right: 10px;
        }

        .navbar-brand {
            font-size: 1.8rem !important;
        }

        .nav-link-hover {
            transition: all 0.3s ease;
            position: relative;
            color: rgba(255, 255, 255, 0.75) !important;
            font-weight: 500;
            padding: 8px 16px !important;
        }

        .nav-link-hover:hover {
            color: white !important;
        }

        .nav-link-hover::after {
            content: '';
            position: absolute;
            bottom: 0;
            left: 50%;
            width: 0;
            height: 2px;
            background: white;
            transition: all 0.3s ease;
            transform: translateX(-50%);
        }

        .nav-link-hover:hover::after {
            width: 60%;
        }

        .nav-link-hover.active {
            color: white !important;
        }

        .nav-link-hover.active::after {
            width: 60%;
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
            transform: translateY(-2px);
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.08);
        }

        .voted-card {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(8px);
            border: 2px solid rgba(16, 185, 129, 0.2);
            border-radius: 1.5rem;
            padding: 2.5rem;
            text-align: center;
            max-width: 600px;
            margin: 0 auto;
            transition: all 0.3s ease;
            animation: fadeInUp 0.6s ease;
        }

        .voted-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 16px 48px rgba(0, 0, 0, 0.08);
            border-color: rgba(16, 185, 129, 0.4);
        }

        .not-voted-card {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(8px);
            border: 2px solid rgba(245, 158, 11, 0.2);
            border-radius: 1.5rem;
            padding: 2.5rem;
            text-align: center;
            max-width: 600px;
            margin: 0 auto;
            transition: all 0.3s ease;
            animation: fadeInUp 0.6s ease;
        }

        .not-voted-card:hover {
            transform: translateY(-4px);
            box-shadow: 0 16px 48px rgba(0, 0, 0, 0.08);
            border-color: rgba(245, 158, 11, 0.4);
        }

        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }

        @keyframes pulse-green {
            0% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0.4); }
            70% { box-shadow: 0 0 0 20px rgba(16, 185, 129, 0); }
            100% { box-shadow: 0 0 0 0 rgba(16, 185, 129, 0); }
        }

        @keyframes bounce-in {
            0% { transform: scale(0); opacity: 0; }
            50% { transform: scale(1.2); }
            70% { transform: scale(0.9); }
            100% { transform: scale(1); opacity: 1; }
        }

        .vote-confirmed-badge {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
            padding: 8px 30px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 0.9rem;
            display: inline-block;
            animation: pulse-green 2s ease-in-out infinite;
        }

        .party-name-display {
            font-size: 2rem;
            font-weight: 700;
            background: linear-gradient(135deg, #4f46e5, #7c3aed);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        .check-icon {
            font-size: 4rem;
            color: #10b981;
            animation: bounce-in 0.8s ease;
        }

        .warning-icon {
            font-size: 4rem;
            color: #f59e0b;
            animation: bounce-in 0.8s ease;
        }

        .party-badge {
            background: rgba(79, 70, 229, 0.08);
            border: 1px solid rgba(79, 70, 229, 0.15);
            padding: 0.5rem 1.5rem;
            border-radius: 50px;
            font-weight: 500;
            color: #4f46e5;
        }

        .welcome-avatar {
            width: 56px;
            height: 56px;
            border-radius: 50%;
            background: linear-gradient(135deg, #4f46e5, #7c3aed);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.6rem;
            color: white;
            transition: transform 0.3s ease;
        }

        .welcome-avatar:hover {
            transform: scale(1.1) rotate(5deg);
        }

        .btn-gradient-primary {
            background: linear-gradient(135deg, #4f46e5, #7c3aed);
            border: none;
            transition: all 0.3s ease;
            color: white;
        }

        .btn-gradient-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(79, 70, 229, 0.3);
            color: white;
        }

        .btn-gradient-warning {
            background: linear-gradient(135deg, #f59e0b, #d97706);
            border: none;
            transition: all 0.3s ease;
            color: white;
        }

        .btn-gradient-warning:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(245, 158, 11, 0.3);
            color: white;
        }

        .btn-outline-secondary-custom {
            border: 2px solid #e2e8f0;
            transition: all 0.3s ease;
            background: white;
            color: #475569;
        }

        .btn-outline-secondary-custom:hover {
            background: #f8fafc;
            transform: translateY(-2px);
            color: #1e293b;
        }

        @media (max-width: 991.98px) {
            .navbar-nav {
                margin-top: 10px;
                gap: 5px;
            }
            .btn-logout-nav {
                width: 100%;
                text-align: center;
                padding: 12px !important;
            }
        }

        @media (max-width: 640px) {
            .voted-card, .not-voted-card {
                padding: 1.5rem;
            }
            .party-name-display {
                font-size: 1.5rem;
            }
            .welcome-avatar {
                width: 44px;
                height: 44px;
                font-size: 1.2rem;
            }
            .navbar-brand {
                font-size: 1.3rem !important;
            }
        }
    </style>
</head>
<body>

<%
    // Check if user is logged in
    String voterId = (String) session.getAttribute("voterId");
    if (voterId == null) {
        response.sendRedirect("login.jsp?error=" + URLEncoder.encode("Please login first", StandardCharsets.UTF_8));
        return;
    }

    String fullName = (String) session.getAttribute("fullName");
    String username = (String) session.getAttribute("username");
    String role = (String) session.getAttribute("role");

    // Variables for user's vote
    String myVoteParty = null;
    boolean hasVoted = false;

    Connection conn = null;
    PreparedStatement pstmt = null;
    ResultSet rs = null;

    try {
        conn = MySQLUtil.getConnection();

        // Get user's vote
        String myVoteSql = "SELECT c.name as partyName FROM votes v " +
                          "JOIN users u ON v.userId = u.id " +
                          "JOIN candidates c ON v.candidateId = c.id " +
                          "WHERE u.voterId = ? OR u.username = ?";
        pstmt = conn.prepareStatement(myVoteSql);
        pstmt.setString(1, voterId);
        pstmt.setString(2, username != null ? username : "");
        rs = pstmt.executeQuery();

        if (rs.next()) {
            myVoteParty = rs.getString("partyName");
            hasVoted = true;
        }
        rs.close();
        pstmt.close();

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

<!-- ========== NAVBAR WITH BIG RED LOGOUT ========== -->
<nav class="navbar navbar-expand-lg navbar-dark navbar-glass fixed-top">
    <div class="container">
        <a class="navbar-brand fw-bold text-white d-flex align-items-center gap-2" href="dashboard.jsp">
            <span style="font-size: 2rem;">🗳️</span>
            <span class="fw-semibold">E-Matdaan</span>
        </a>
        <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto align-items-center gap-1 gap-lg-2">
                <li class="nav-item">
                    <a class="nav-link nav-link-hover" href="dashboard.jsp">
                        <i class="bi bi-grid-1x2-fill me-1"></i> Dashboard
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link nav-link-hover" href="vote.jsp">
                        <i class="bi bi-check2-circle me-1"></i> Vote
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link nav-link-hover active" href="myvote.jsp">
                        <i class="bi bi-person-check me-1"></i> My Vote
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link nav-link-hover" href="results.jsp">
                        <i class="bi bi-bar-chart-fill me-1"></i> Results
                    </a>
                </li>
                <% if ("admin".equals(role)) { %>
                    <li class="nav-item">
                        <a class="nav-link nav-link-hover text-warning" href="admin_dashboard.jsp">
                            <i class="bi bi-shield-lock-fill me-1"></i> Admin
                        </a>
                    </li>
                <% } %>
                <!-- ===== BIG RED LOGOUT BUTTON IN NAVBAR ===== -->
                <li class="nav-item ms-2">
                    <a class="btn btn-logout-nav" href="logout">
                        <i class="bi bi-box-arrow-right"></i> Logout
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- ========== MAIN CONTENT ========== -->
<main class="container py-4">

    <!-- ===== HEADER ===== -->
    <div class="text-center mb-4">
        <div class="d-flex align-items-center justify-content-center gap-3 mb-3">
            <div class="welcome-avatar">
                <i class="bi bi-person-fill"></i>
            </div>
            <div>
                <h2 class="fw-bold text-dark mb-0">🗳️ My Vote</h2>
                <p class="text-secondary-emphasis mb-0">
                    Welcome, <strong><%= fullName != null ? fullName : "Voter" %></strong>!
                </p>
            </div>
        </div>
        <div class="d-flex justify-content-center gap-3 flex-wrap">
            <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill">
                <i class="bi bi-shield-check me-1"></i> Secure & Private
            </span>
            <span class="badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill">
                <i class="bi bi-person-check me-1"></i> One Vote Per Voter
            </span>
        </div>
    </div>

    <!-- ===== ERROR MESSAGE ===== -->
    <%
        String error = (String) request.getAttribute("error");
        if (error != null) {
    %>
        <div class="alert alert-danger alert-dismissible fade show mb-4" role="alert">
            <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= error %>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    <% } %>

    <!-- ===== VOTE STATUS CARD ===== -->
    <div class="row justify-content-center">
        <div class="col-lg-8">
            <% if (hasVoted) { %>
                <!-- ✅ VOTED -->
                <div class="voted-card">
                    <div class="check-icon">
                        <i class="bi bi-check-circle-fill"></i>
                    </div>

                    <div class="vote-confirmed-badge mb-3">
                        <i class="bi bi-check-circle me-2"></i> VOTE CONFIRMED
                    </div>

                    <h5 class="text-muted mb-3">You have successfully voted for</h5>

                    <div class="glass-card p-4 mb-3">
                        <div class="party-name-display">
                            <%= myVoteParty %>
                        </div>
                        <div class="mt-3">
                            <span class="party-badge">
                                <i class="bi bi-check-circle-fill text-success me-2"></i>
                                Vote Recorded Successfully!
                            </span>
                        </div>
                    </div>

                    <div class="mt-4">
                        <p class="text-muted small">
                            <i class="bi bi-clock me-1"></i>
                            Thank you for participating in the election!
                        </p>
                    </div>

                    <div class="d-flex flex-wrap justify-content-center gap-3 mt-3">
                        <a href="results.jsp" class="btn btn-gradient-primary rounded-pill px-4 py-2 shadow-sm">
                            <i class="bi bi-eye me-2"></i> View Results
                        </a>
                        <a href="dashboard.jsp" class="btn btn-outline-secondary-custom rounded-pill px-4 py-2">
                            <i class="bi bi-arrow-left me-2"></i> Dashboard
                        </a>
                    </div>
                </div>
            <% } else { %>
                <!-- ❌ NOT VOTED -->
                <div class="not-voted-card">
                    <div class="warning-icon">
                        <i class="bi bi-exclamation-triangle-fill"></i>
                    </div>

                    <h4 class="fw-bold text-dark mb-2">You haven't voted yet!</h4>
                    <p class="text-muted mb-4">
                        Your voice matters! Cast your vote now to make a difference in the election.
                    </p>

                    <div class="glass-card p-4 mb-3">
                        <p class="text-muted mb-0">
                            <i class="bi bi-info-circle me-2"></i>
                            You have <strong>one vote</strong> to cast. Make it count!
                        </p>
                    </div>

                    <div class="d-flex flex-wrap justify-content-center gap-3">
                        <a href="vote.jsp" class="btn btn-gradient-warning rounded-pill px-5 py-2 shadow-sm">
                            <i class="bi bi-check2-circle me-2"></i> Vote Now
                        </a>
                        <a href="dashboard.jsp" class="btn btn-outline-secondary-custom rounded-pill px-4 py-2">
                            <i class="bi bi-arrow-left me-2"></i> Dashboard
                        </a>
                    </div>

                    <!-- ===== LOGOUT BUTTON INSIDE THE PAGE (BACKUP) ===== -->
                    <div class="mt-4 pt-3 border-top">
                        <p class="text-muted small mb-3">Need to leave?</p>
                        <a href="logout" class="btn btn-logout-page">
                            <i class="bi bi-box-arrow-right"></i> Logout
                        </a>
                    </div>
                </div>
            <% } %>
        </div>
    </div>

    <!-- ===== QUICK INFO ===== -->
    <div class="row mt-4 g-3">
        <div class="col-md-6">
            <div class="glass-card p-3 d-flex align-items-center gap-3">
                <span class="fs-2">🔒</span>
                <div>
                    <h6 class="fw-semibold mb-0 text-dark">Secure Voting</h6>
                    <small class="text-muted">Your vote is encrypted and private</small>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="glass-card p-3 d-flex align-items-center gap-3">
                <span class="fs-2">📅</span>
                <div>
                    <h6 class="fw-semibold mb-0 text-dark">Election 2082</h6>
                    <small class="text-muted">One vote per voter — make it count!</small>
                </div>
            </div>
        </div>
    </div>

</main>

<!-- ========== FOOTER ========== -->
<footer class="text-center py-4 mt-4 border-top bg-white bg-opacity-50">
    <div class="container">
        <span class="text-muted small">
            © <%= java.time.Year.now() %> E-Matdaan · Online Voting System
        </span>
        <span class="text-muted mx-2">·</span>
        <span class="text-muted small">Built with ❤️ for Nepal Election 2082</span>
    </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>