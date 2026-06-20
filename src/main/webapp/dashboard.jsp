<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - E-Matdaan</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css">
    <script src="https://cdn.tailwindcss.com"></script>

    <style>
        body {
            background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 100%);
            min-height: 100vh;
            padding-top: 80px;
        }

        /* ===== CLEAN NAVBAR - ONLY LOGO ===== */
        .navbar-glass {
            background: #1e293b !important;
            backdrop-filter: blur(14px);
            -webkit-backdrop-filter: blur(14px);
            border-bottom: 2px solid rgba(255, 255, 255, 0.08);
            padding: 12px 0;
            box-shadow: 0 4px 20px rgba(0, 0, 0, 0.3);
        }

        /* Navbar brand - WHITE */
        .navbar-brand {
            color: white !important;
            font-weight: 700;
        }

        .navbar-brand span {
            color: #fcd34d !important;
        }

        /* ===== LOGOUT BUTTON STYLES (Below Navbar) ===== */
        .btn-logout {
            background: #dc2626 !important;
            border: none !important;
            color: white !important;
            padding: 12px 35px !important;
            border-radius: 50px !important;
            font-weight: 700 !important;
            transition: all 0.3s ease !important;
            font-size: 1rem !important;
            text-decoration: none !important;
            display: inline-block !important;
            box-shadow: 0 4px 20px rgba(220, 38, 38, 0.4) !important;
            letter-spacing: 0.5px;
        }

        .btn-logout:hover {
            background: #b91c1c !important;
            transform: translateY(-3px) !important;
            box-shadow: 0 8px 35px rgba(220, 38, 38, 0.6) !important;
            color: white !important;
        }

        .btn-logout i {
            font-size: 1.2rem;
            margin-right: 10px;
        }

        .glass-card {
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.06);
            border-radius: 1.25rem;
        }

        .welcome-card {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(8px);
            border: 1px solid rgba(255, 255, 255, 0.6);
            border-radius: 1.25rem;
            padding: 2rem;
            transition: all 0.3s ease;
        }

        .welcome-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 12px 40px rgba(0, 0, 0, 0.08);
        }

        .dashboard-card {
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(4px);
            border: 1px solid rgba(255, 255, 255, 0.6);
            border-radius: 1.25rem;
            padding: 2rem;
            text-align: center;
            transition: all 0.3s ease;
            height: 100%;
        }

        .dashboard-card:hover {
            transform: translateY(-8px);
            background: rgba(255, 255, 255, 0.95);
            box-shadow: 0 16px 48px rgba(0, 0, 0, 0.1);
            border-color: #a5b4fc;
        }

        .dashboard-card .icon {
            font-size: 3.5rem;
            margin-bottom: 1rem;
            display: block;
        }

        .dashboard-card .card-title {
            font-weight: 700;
            color: #1e293b;
            margin-bottom: 0.5rem;
        }

        .dashboard-card .card-desc {
            color: #64748b;
            font-size: 0.95rem;
            margin-bottom: 1.25rem;
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

        .btn-gradient-success {
            background: linear-gradient(135deg, #10b981, #059669);
            border: none;
            transition: all 0.3s ease;
            color: white;
        }

        .btn-gradient-success:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(16, 185, 129, 0.3);
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

        .voter-badge {
            background: rgba(79, 70, 229, 0.1);
            color: #4f46e5;
            padding: 0.25rem 1rem;
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .admin-badge {
            background: rgba(245, 158, 11, 0.2);
            color: #d97706;
            padding: 0.25rem 1rem;
            border-radius: 50px;
            font-size: 0.85rem;
            font-weight: 600;
        }

        .alert-custom {
            border-radius: 1rem;
            border: none;
            background: rgba(16, 185, 129, 0.1);
            color: #059669;
            padding: 0.75rem 1.25rem;
        }

        .welcome-icon {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            background: linear-gradient(135deg, #4f46e5, #7c3aed);
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            color: white;
        }

        .admin-card {
            border: 2px solid rgba(245, 158, 11, 0.3);
            background: rgba(255, 255, 255, 0.9);
        }

        .admin-card:hover {
            border-color: #f59e0b;
        }

        /* Logout container below navbar */
        .logout-container {
            display: flex;
            justify-content: flex-end;
            margin-bottom: 1rem;
        }

        @media (max-width: 991.98px) {
            .logout-container {
                justify-content: center;
                margin-top: 0.5rem;
            }
            .btn-logout {
                width: 100%;
                text-align: center;
                padding: 12px !important;
            }
        }

        @media (max-width: 640px) {
            .welcome-card {
                padding: 1.25rem;
            }
            .dashboard-card {
                padding: 1.5rem;
            }
            .dashboard-card .icon {
                font-size: 2.8rem;
            }
            .navbar-brand {
                font-size: 1.3rem !important;
            }
        }
    </style>
</head>

<body>

<%
    // Get session attributes
    String voterId = (String) session.getAttribute("voterId");
    String voterName = (String) session.getAttribute("fullName");
    String role = (String) session.getAttribute("role");
    String username = (String) session.getAttribute("username");

    // Check if user is logged in
    if (voterId == null) {
        response.sendRedirect("login.jsp?error=" +
                URLEncoder.encode("Please login first", StandardCharsets.UTF_8));
        return;
    }

    // Set default name if not available
    if (voterName == null || voterName.trim().isEmpty()) {
        voterName = username != null ? username : "Voter";
    }

    // Check if user has already voted (optional - you can add this)
    Boolean hasVoted = (Boolean) session.getAttribute("hasVoted");
    if (hasVoted == null) {
        hasVoted = false;
    }
%>

<!-- ========== CLEAN NAVBAR - ONLY LOGO (NO LINKS) ========== -->
<nav class="navbar navbar-glass fixed-top">
    <div class="container">
        <a class="navbar-brand fw-bold fs-3 d-flex align-items-center gap-2" href="dashboard.jsp">
            <span style="font-size: 2rem;">🗳️</span>
            <span>E-Matdaan</span>
        </a>
        <!-- NO NAV LINKS - COMPLETELY EMPTY -->
    </div>
</nav>

<!-- ========== MAIN CONTENT ========== -->
<main class="container py-4">

    <!-- ===== LOGOUT BUTTON BELOW NAVBAR ===== -->
    <div class="logout-container">
        <a class="btn btn-logout" href="logout">
            <i class="bi bi-box-arrow-right"></i> Logout
        </a>
    </div>

    <!-- ===== WELCOME CARD ===== -->
    <div class="welcome-card mb-4">
        <div class="row align-items-center g-3">
            <div class="col-md-8">
                <div class="d-flex align-items-center gap-3">
                    <div class="welcome-icon">
                        <i class="bi bi-person-fill"></i>
                    </div>
                    <div>
                        <h2 class="fw-bold text-dark mb-0">
                            Welcome back, <%= voterName %>!
                        </h2>
                        <div class="d-flex flex-wrap align-items-center gap-2 mt-1">
                            <span class="text-muted small">
                                <i class="bi bi-person-badge me-1"></i> ID: <strong><%= voterId %></strong>
                            </span>
                            <span class="voter-badge">
                                <i class="bi bi-person-check me-1"></i> <%= role != null ? role.toUpperCase() : "VOTER" %>
                            </span>
                            <% if ("admin".equals(role)) { %>
                                <span class="admin-badge">
                                    <i class="bi bi-star-fill me-1"></i> ADMIN
                                </span>
                            <% } %>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-md-4 text-md-end">
                <small class="text-muted">
                    <i class="bi bi-clock me-1"></i> Logged in as: <%= username != null ? username : "User" %>
                </small>
            </div>
        </div>

        <% if (hasVoted) { %>
            <div class="alert alert-custom mt-3 mb-0 d-flex align-items-center gap-2">
                <i class="bi bi-check-circle-fill fs-5"></i>
                <span>You have already cast your vote. Thank you for participating in the election!</span>
            </div>
        <% } %>
    </div>

    <!-- ===== DASHBOARD CARDS ===== -->
    <div class="row g-4">
        <!-- Vote Card -->
        <div class="col-md-4">
            <div class="dashboard-card">
                <span class="icon">🗳️</span>
                <h5 class="card-title">Cast Your Vote</h5>
                <p class="card-desc">Vote for your preferred candidate or party</p>
                <% if (hasVoted) { %>
                    <button class="btn btn-secondary rounded-pill px-4" disabled>
                        <i class="bi bi-check-circle me-1"></i> Already Voted
                    </button>
                <% } else { %>
                    <a href="vote.jsp" class="btn btn-gradient-primary text-white rounded-pill px-5 py-2 shadow-sm">
                        <i class="bi bi-check2-circle me-1"></i> Vote Now
                    </a>
                <% } %>
            </div>
        </div>

        <!-- Results Card -->
        <div class="col-md-4">
            <div class="dashboard-card">
                <span class="icon">📊</span>
                <h5 class="card-title">View Results</h5>
                <p class="card-desc">Check live vote counts and election statistics</p>
                <a href="results.jsp" class="btn btn-gradient-success text-white rounded-pill px-5 py-2 shadow-sm">
                    <i class="bi bi-eye me-1"></i> View Results
                </a>
            </div>
        </div>

        <!-- Admin Card (only for admins) -->
        <% if ("admin".equals(role)) { %>
            <div class="col-md-4">
                <div class="dashboard-card admin-card">
                    <span class="icon">⚡</span>
                    <h5 class="card-title">Admin Panel</h5>
                    <p class="card-desc">Manage votes, view all data, and control the election</p>
                    <a href="totalVote" class="btn btn-gradient-warning text-white rounded-pill px-5 py-2 shadow-sm fw-semibold">
                        <i class="bi bi-shield-lock me-1"></i> Admin Panel
                    </a>
                </div>
            </div>
        <% } %>
    </div>

    <!-- ===== QUICK INFO (Optional) ===== -->
    <div class="row mt-4 g-3">
        <div class="col-md-6">
            <div class="glass-card p-3 d-flex align-items-center gap-3">
                <span class="fs-2">📅</span>
                <div>
                    <h6 class="fw-semibold mb-0 text-dark">Election 2082</h6>
                    <small class="text-muted">Your voice matters — cast your vote today</small>
                </div>
            </div>
        </div>
        <div class="col-md-6">
            <div class="glass-card p-3 d-flex align-items-center gap-3">
                <span class="fs-2">🔒</span>
                <div>
                    <h6 class="fw-semibold mb-0 text-dark">Secure Voting</h6>
                    <small class="text-muted">Your vote is encrypted and private</small>
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