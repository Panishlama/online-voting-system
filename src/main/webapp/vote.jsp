<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<%@ page import="java.sql.*" %>
<%@ page import="com.voting.util.MySQLUtil" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cast Your Vote - E-Matdaan</title>

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
            padding: 10px 0;
        }

        /* ===== BIG RED LOGOUT BUTTON ===== */
        .btn-logout {
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

        .party-card {
            cursor: pointer;
            transition: all 0.3s ease;
            border: 3px solid transparent;
            background: rgba(255, 255, 255, 0.85);
            backdrop-filter: blur(4px);
            border-radius: 1.25rem;
            box-shadow: 0 4px 15px rgba(0,0,0,0.06);
            height: 100%;
            display: flex;
            flex-direction: column;
            justify-content: center;
            align-items: center;
            padding: 1.5rem 1rem;
            position: relative;
            overflow: hidden;
            min-height: 200px;
        }

        .party-card:hover {
            transform: translateY(-8px);
            box-shadow: 0 16px 40px rgba(0, 0, 0, 0.1);
            border-color: #a5b4fc;
        }

        .party-card:has(input[type="radio"]:checked) {
            border-color: #10b981;
            background: rgba(16, 185, 129, 0.08);
            box-shadow: 0 0 0 4px rgba(16, 185, 129, 0.15), 0 16px 40px rgba(0, 0, 0, 0.08);
            transform: scale(1.02);
        }

        .party-card:has(input[type="radio"]:checked)::after {
            content: "✓ SELECTED";
            position: absolute;
            top: 12px;
            right: 12px;
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
            padding: 4px 14px;
            border-radius: 50px;
            font-size: 11px;
            font-weight: 700;
            box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
        }

        .party-card:has(input[type="radio"]:checked) .party-logo {
            transform: scale(1.05);
        }

        .party-logo {
            height: 80px;
            width: auto;
            max-width: 90%;
            object-fit: contain;
            margin-bottom: 0.75rem;
            border-radius: 12px;
            transition: transform 0.3s ease;
        }

        .party-name {
            font-weight: 700;
            color: #1e293b;
            margin: 0;
            font-size: 1rem;
            text-align: center;
        }

        .party-short {
            font-size: 0.75rem;
            color: #94a3b8;
            margin-top: 2px;
            font-weight: 500;
            background: rgba(0,0,0,0.05);
            padding: 2px 12px;
            border-radius: 50px;
        }

        input[type="radio"] {
            position: absolute;
            opacity: 0;
            width: 0;
            height: 0;
        }

        .btn-submit {
            min-width: 300px;
            font-size: 1.2rem;
            border-radius: 50px;
            padding: 16px 50px;
            transition: all 0.3s ease;
            background: linear-gradient(135deg, #10b981, #059669);
            border: none;
            font-weight: 600;
        }

        .btn-submit:hover:not(:disabled) {
            transform: translateY(-3px);
            box-shadow: 0 12px 40px rgba(16, 185, 129, 0.4);
        }

        .btn-submit:disabled {
            opacity: 0.5;
            cursor: not-allowed;
            transform: none !important;
        }

        .already-voted-banner {
            background: rgba(255, 255, 255, 0.9);
            backdrop-filter: blur(8px);
            border-radius: 1.5rem;
            padding: 3rem 2rem;
            text-align: center;
            border: 2px solid rgba(245, 158, 11, 0.3);
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.06);
        }

        .already-voted-banner .icon {
            font-size: 5rem;
            margin-bottom: 1rem;
            display: block;
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
        }

        .alert-custom {
            border-radius: 1rem;
            border: none;
            padding: 1rem 1.5rem;
        }

        .alert-custom-danger {
            background: rgba(239, 68, 68, 0.08);
            color: #dc2626;
            border-left: 4px solid #dc2626;
        }

        .alert-custom-success {
            background: rgba(16, 185, 129, 0.08);
            color: #059669;
            border-left: 4px solid #10b981;
        }

        .party-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
            gap: 1.25rem;
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

        @media (max-width: 991.98px) {
            .navbar-nav {
                margin-top: 10px;
                gap: 5px;
            }
            .btn-logout {
                width: 100%;
                text-align: center;
                padding: 12px !important;
            }
        }

        @media (max-width: 640px) {
            .party-grid {
                grid-template-columns: repeat(2, 1fr);
                gap: 0.75rem;
            }
            .party-card {
                padding: 1rem 0.75rem;
                min-height: 150px;
            }
            .party-logo {
                height: 60px;
            }
            .party-name {
                font-size: 0.85rem;
            }
            .btn-submit {
                min-width: 100%;
                padding: 14px 30px;
                font-size: 1rem;
            }
            .already-voted-banner {
                padding: 2rem 1.25rem;
            }
        }
    </style>
</head>
<body>

<%
    // Check if user is logged in
    String voterId = (String) session.getAttribute("voterId");
    String username = (String) session.getAttribute("username");
    String fullName = (String) session.getAttribute("fullName");
    Boolean hasVoted = (Boolean) session.getAttribute("hasVoted");
    String role = (String) session.getAttribute("role");

    if (voterId == null) {
        response.sendRedirect("login.jsp?error=" + URLEncoder.encode("Please login first", StandardCharsets.UTF_8));
        return;
    }

    if (fullName == null || fullName.trim().isEmpty()) {
        fullName = "Voter";
    }

    // Check if user has already voted (from database)
    if (hasVoted == null) {
        Connection conn = null;
        PreparedStatement pstmt = null;
        ResultSet rs = null;
        try {
            conn = MySQLUtil.getConnection();
            String sql = "SELECT v.id FROM votes v JOIN users u ON v.userId = u.id WHERE u.voterId = ? OR u.username = ?";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, voterId);
            pstmt.setString(2, username != null ? username : "");
            rs = pstmt.executeQuery();
            hasVoted = rs.next();
            session.setAttribute("hasVoted", hasVoted);
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            try {
                if (rs != null) rs.close();
                if (pstmt != null) pstmt.close();
            } catch (SQLException e) {}
        }
    }
%>

<!-- ========== NAVBAR WITH BIG RED LOGOUT ========== -->
<nav class="navbar navbar-expand-lg navbar-dark navbar-glass fixed-top">
    <div class="container">
        <a class="navbar-brand fw-bold text-white fs-3 d-flex align-items-center gap-2" href="dashboard.jsp">
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
                    <a class="nav-link nav-link-hover active" href="vote.jsp">
                        <i class="bi bi-check2-circle me-1"></i> Vote
                    </a>
                </li>
                <li class="nav-item">
                    <a class="nav-link nav-link-hover" href="myvote.jsp">
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
                <!-- ===== BIG RED LOGOUT BUTTON ===== -->
                <li class="nav-item ms-2">
                    <a class="btn btn-logout" href="logout">
                        <i class="bi bi-box-arrow-right"></i> Logout
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- ========== MAIN CONTENT ========== -->
<main class="container py-4">

    <!-- Already Voted Check -->
    <% if (hasVoted) { %>
        <div class="row justify-content-center">
            <div class="col-lg-8">
                <div class="already-voted-banner">
                    <span class="icon">✅</span>
                    <h3 class="fw-bold text-dark mb-2">You Have Already Voted!</h3>
                    <p class="text-muted mb-3 fs-5">
                        Thank you for participating in the election. Your voice has been heard.
                    </p>
                    <div class="d-flex flex-wrap justify-content-center gap-3">
                        <a href="results.jsp" class="btn btn-primary btn-lg rounded-pill px-5 shadow-sm"
                           style="background: linear-gradient(135deg, #4f46e5, #7c3aed); border: none;">
                            <i class="bi bi-eye me-2"></i> View Results
                        </a>
                        <a href="dashboard.jsp" class="btn btn-outline-secondary btn-lg rounded-pill px-5">
                            <i class="bi bi-arrow-left me-2"></i> Dashboard
                        </a>
                    </div>
                </div>
            </div>
        </div>
    <% } else { %>

        <!-- ===== HEADER ===== -->
        <div class="text-center mb-4">
            <div class="d-flex align-items-center justify-content-center gap-3 mb-3">
                <div class="welcome-avatar">
                    <i class="bi bi-person-fill"></i>
                </div>
                <div>
                    <h2 class="fw-bold text-dark mb-0">🗳️ Cast Your Vote</h2>
                    <p class="text-secondary-emphasis mb-0">
                        Welcome, <strong><%= fullName %></strong>! Select your preferred candidate
                    </p>
                </div>
            </div>
            <div class="d-flex justify-content-center gap-3 flex-wrap">
                <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill">
                    <i class="bi bi-shield-check me-1"></i> Secure & Private
                </span>
                <span class="badge bg-success bg-opacity-10 text-success px-3 py-2 rounded-pill">
                    <i class="bi bi-clock me-1"></i> One Vote Per Voter
                </span>
                <span class="badge bg-warning bg-opacity-10 text-warning px-3 py-2 rounded-pill">
                    <i class="bi bi-lock me-1"></i> Encrypted
                </span>
            </div>
        </div>

        <!-- ===== MESSAGES ===== -->
        <%
            String error = request.getParameter("error");
            String success = request.getParameter("success");
            if (error != null && !error.isEmpty()) {
        %>
            <div class="alert alert-custom alert-custom-danger alert-dismissible fade show mb-4" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= error %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>
        <%
            if (success != null && !success.isEmpty()) {
        %>
            <div class="alert alert-custom alert-custom-success alert-dismissible fade show mb-4" role="alert">
                <i class="bi bi-check-circle-fill me-2"></i> <%= success %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <!-- ===== VOTE FORM ===== -->
        <form action="${pageContext.request.contextPath}/vote" method="post" id="voteForm">
            <div class="party-grid">

                <!-- 1 - Nepali Congress -->
                <div class="col">
                    <label class="party-card">
                        <input type="radio" name="party" value="Nepali Congress (NC)" required>
                        <img src="images/nc.jpg" class="party-logo" alt="Nepali Congress" onerror="this.src='https://via.placeholder.com/100x100/0d6efd/white?text=NC'">
                        <p class="party-name">Nepali Congress</p>
                        <span class="party-short">NC</span>
                    </label>
                </div>

                <!-- 2 - CPN-UML -->
                <div class="col">
                    <label class="party-card">
                        <input type="radio" name="party" value="CPN (UML)">
                        <img src="images/uml.webp" class="party-logo" alt="CPN-UML" onerror="this.src='https://via.placeholder.com/100x100/dc3545/white?text=UML'">
                        <p class="party-name">CPN-UML</p>
                        <span class="party-short">UML</span>
                    </label>
                </div>

                <!-- 3 - RSP -->
                <div class="col">
                    <label class="party-card">
                        <input type="radio" name="party" value="Rastriya Swatantra Party (RSP)">
                        <img src="images/rsp.jpg" class="party-logo" alt="RSP" onerror="this.src='https://via.placeholder.com/100x100/ffc107/white?text=RSP'">
                        <p class="party-name">Rastriya Swatantra</p>
                        <span class="party-short">RSP</span>
                    </label>
                </div>

                <!-- 4 - Maoist Centre -->
                <div class="col">
                    <label class="party-card">
                        <input type="radio" name="party" value="CPN (Maoist Centre)">
                        <img src="images/maoist.jpg" class="party-logo" alt="Maoist Centre" onerror="this.src='https://via.placeholder.com/100x100/dc3545/white?text=Maoist'">
                        <p class="party-name">CPN (Maoist Centre)</p>
                        <span class="party-short">Maoist</span>
                    </label>
                </div>

                <!-- 5 - RPP -->
                <div class="col">
                    <label class="party-card">
                        <input type="radio" name="party" value="Rastriya Prajatantra Party (RPP)">
                        <img src="images/rpp.jpg" class="party-logo" alt="RPP" onerror="this.src='https://via.placeholder.com/100x100/6c757d/white?text=RPP'">
                        <p class="party-name">Rastriya Prajatantra</p>
                        <span class="party-short">RPP</span>
                    </label>
                </div>

                <!-- 6 - JSP -->
                <div class="col">
                    <label class="party-card">
                        <input type="radio" name="party" value="Janata Samajbadi Party (JSP-N)">
                        <img src="images/jsp.webp" class="party-logo" alt="JSP" onerror="this.src='https://via.placeholder.com/100x100/198754/white?text=JSP'">
                        <p class="party-name">Janata Samajbadi</p>
                        <span class="party-short">JSP-N</span>
                    </label>
                </div>

                <!-- 7 - LSP -->
                <div class="col">
                    <label class="party-card">
                        <input type="radio" name="party" value="Loktantrik Samajbadi Party (LSP)">
                        <img src="images/lsp.jpg" class="party-logo" alt="LSP" onerror="this.src='https://via.placeholder.com/100x100/0dcaf0/white?text=LSP'">
                        <p class="party-name">Loktantrik Samajbadi</p>
                        <span class="party-short">LSP</span>
                    </label>
                </div>

                <!-- 8 - Unified Socialist -->
                <div class="col">
                    <label class="party-card">
                        <input type="radio" name="party" value="Unified Socialist Party">
                        <img src="images/hamro.png" class="party-logo" alt="Unified Socialist" onerror="this.src='https://via.placeholder.com/100x100/8e44ad/white?text=USP'">
                        <p class="party-name">Unified Socialist</p>
                        <span class="party-short">USP</span>
                    </label>
                </div>

                <!-- 9 - Shram Sanskriti -->
                <div class="col">
                    <label class="party-card">
                        <input type="radio" name="party" value="Shram Sanskriti Party">
                        <img src="images/shram.webp" class="party-logo" alt="Shram Sanskriti" onerror="this.src='https://via.placeholder.com/100x100/6f42c1/white?text=SSP'">
                        <p class="party-name">Shram Sanskriti</p>
                        <span class="party-short">SSP</span>
                    </label>
                </div>

                <!-- 10 - Ujyalo Nepal -->
                <div class="col">
                    <label class="party-card">
                        <input type="radio" name="party" value="Ujyaalo Nepal Party">
                        <img src="images/ujyaalo.webp" class="party-logo" alt="Ujyalo Nepal" onerror="this.src='https://via.placeholder.com/100x100/f39c12/white?text=UNP'">
                        <p class="party-name">Ujyalo Nepal</p>
                        <span class="party-short">UNP</span>
                    </label>
                </div>

                <!-- 11 - Bibeksheel Sajha -->
                <div class="col">
                    <label class="party-card">
                        <input type="radio" name="party" value="Bibeksheel Sajha Party">
                        <img src="images/bibeksheel.webp" class="party-logo" alt="Bibeksheel Sajha" onerror="this.src='https://via.placeholder.com/100x100/e74c3c/white?text=BSP'">
                        <p class="party-name">Bibeksheel Sajha</p>
                        <span class="party-short">BSP</span>
                    </label>
                </div>

                <!-- 12 - Rastriya Janamorcha -->
                <div class="col">
                    <label class="party-card">
                        <input type="radio" name="party" value="Rastriya Janamorcha">
                        <img src="images/janamorcha.jpg" class="party-logo" alt="Rastriya Janamorcha" onerror="this.src='https://via.placeholder.com/100x100/2ecc71/white?text=RJ'">
                        <p class="party-name">Rastriya Janamorcha</p>
                        <span class="party-short">RJ</span>
                    </label>
                </div>

            </div>

            <!-- ===== SUBMIT SECTION ===== -->
            <div class="text-center mt-5">
                <div class="glass-card p-4 p-md-5">
                    <p class="text-muted mb-3">
                        <i class="bi bi-info-circle me-1"></i> You will be asked to confirm your Voter ID before submitting
                    </p>
                    <button type="submit" class="btn btn-submit text-white" id="submitBtn">
                        <i class="bi bi-check2-circle me-2"></i> Submit Your Vote
                    </button>
                    <div class="mt-3 d-flex justify-content-center gap-4 flex-wrap">
                        <span class="text-muted small">
                            <i class="bi bi-shield-fill-check text-success me-1"></i> Encrypted
                        </span>
                        <span class="text-muted small">
                            <i class="bi bi-person-check text-primary me-1"></i> One vote per voter
                        </span>
                        <span class="text-muted small">
                            <i class="bi bi-clock text-warning me-1"></i> Your vote is final
                        </span>
                    </div>
                </div>
            </div>
        </form>
    <% } %>

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

<!-- ===== VOTER ID CONFIRMATION ===== -->
<script>
    document.getElementById('voteForm')?.addEventListener('submit', function(e) {
        e.preventDefault();

        // Check if a party is selected
        const selected = document.querySelector('input[name="party"]:checked');
        if (!selected) {
            alert('⚠️ Please select a party to vote for.');
            return;
        }

        const expectedVoterId = "<%= voterId %>";
        const entered = prompt(
            "🔐 Confirm Your Voter ID\n\n" +
            "Your registered Voter ID is: " + expectedVoterId + "\n\n" +
            "Please type your Voter ID to confirm:"
        );

        if (!entered || entered.trim() !== expectedVoterId) {
            alert("❌ Incorrect Voter ID! Voting cancelled.");
            return;
        }

        // Disable submit button to prevent double submission
        const submitBtn = document.getElementById('submitBtn');
        submitBtn.disabled = true;
        submitBtn.innerHTML = '<i class="bi bi-arrow-repeat me-2 spinner"></i> Submitting...';

        this.submit();
    });

    // Add some visual feedback when a card is clicked
    document.querySelectorAll('.party-card').forEach(card => {
        card.addEventListener('click', function() {
            document.querySelectorAll('.party-card').forEach(c => {
                c.classList.remove('selected');
            });
            this.classList.add('selected');
        });
    });
</script>

</body>
</html>