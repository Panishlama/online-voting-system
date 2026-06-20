<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>E-Matdaan · Online Voting System</title>

    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" />

    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.min.css" />

    <!-- Tailwind CSS -->
    <script src="https://cdn.tailwindcss.com"></script>

    <style>
        /* ----- Custom Styles ----- */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            background: linear-gradient(145deg, #f1f5f9 0%, #e2e8f0 100%);
            font-family: 'Segoe UI', system-ui, -apple-system, sans-serif;
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }

        /* Glassmorphism card */
        .glass-card {
            background: rgba(255, 255, 255, 0.75);
            backdrop-filter: blur(8px);
            -webkit-backdrop-filter: blur(8px);
            border: 1px solid rgba(255, 255, 255, 0.5);
            box-shadow: 0 8px 32px rgba(0, 0, 0, 0.06);
        }

        /* Hero glow background */
        .hero-glow {
            background: radial-gradient(circle at 10% 20%, rgba(79, 70, 229, 0.10) 0%, rgba(124, 58, 237, 0.04) 80%);
        }

        /* Navbar with blur */
        .navbar-glass {
            background: rgba(15, 23, 42, 0.88);
            backdrop-filter: blur(14px);
            -webkit-backdrop-filter: blur(14px);
            border-bottom: 1px solid rgba(255, 255, 255, 0.08);
        }

        /* Feature card hover */
        .feature-card {
            background: rgba(255, 255, 255, 0.8);
            backdrop-filter: blur(4px);
            border: 1px solid rgba(255, 255, 255, 0.6);
            transition: all 0.25s ease;
            border-radius: 1.25rem;
        }
        .feature-card:hover {
            transform: translateY(-6px);
            background: rgba(255, 255, 255, 0.95);
            box-shadow: 0 20px 40px -12px rgba(0, 0, 0, 0.15);
            border-color: #a5b4fc;
        }

        /* Step circles */
        .step-circle {
            width: 76px;
            height: 76px;
            background: white;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            box-shadow: 0 8px 24px -8px rgba(0, 0, 0, 0.08), 0 0 0 1px rgba(255, 255, 255, 0.7);
            transition: all 0.2s;
            font-size: 2rem;
        }
        .step-circle:hover {
            transform: scale(1.04);
            box-shadow: 0 12px 32px -10px rgba(79, 70, 229, 0.2);
        }

        /* Election badge */
        .election-pill {
            background: linear-gradient(135deg, #fbbf24, #f59e0b);
            box-shadow: 0 4px 14px rgba(245, 158, 11, 0.35);
            padding: 0.4rem 1.4rem;
            border-radius: 50px;
            font-weight: 600;
            color: #1e293b;
            display: inline-flex;
            align-items: center;
            gap: 0.4rem;
        }

        /* Vote Now button pulse */
        @keyframes soft-pulse {
            0%   { box-shadow: 0 0 0 0 rgba(79, 70, 229, 0.35); }
            70%  { box-shadow: 0 0 0 14px rgba(79, 70, 229, 0); }
            100% { box-shadow: 0 0 0 0 rgba(79, 70, 229, 0); }
        }
        .btn-vote-pulse {
            animation: soft-pulse 2.2s infinite;
        }

        /* Gradient text */
        .gradient-text {
            background: linear-gradient(145deg, #4f46e5, #7c3aed);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            background-clip: text;
        }

        /* Footer */
        .footer-link {
            color: #94a3b8;
            transition: color 0.2s;
            text-decoration: none;
        }
        .footer-link:hover {
            color: #e2e8f0;
        }

        /* Responsive */
        @media (max-width: 640px) {
            .display-3 {
                font-size: 2.2rem;
            }
            .hero-glow {
                padding: 1.5rem !important;
            }
            .step-circle {
                width: 64px;
                height: 64px;
                font-size: 1.6rem;
            }
        }
    </style>
</head>

<body>

    <!-- ============================================================ -->
    <!--  NAVBAR
    <!-- ============================================================ -->
    <nav class="navbar navbar-expand-lg navbar-dark navbar-glass sticky-top">
        <div class="container">
            <a class="navbar-brand fw-bold text-white fs-2 d-flex align-items-center gap-2" href="#">
                <span style="font-size: 2rem;">🗳️</span>
                <span class="fw-semibold tracking-tight">E-Matdaan</span>
            </a>
            <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav"
                    aria-controls="navbarNav" aria-expanded="false" aria-label="Toggle navigation">
                <span class="navbar-toggler-icon"></span>
            </button>
            <div class="collapse navbar-collapse" id="navbarNav">
                <ul class="navbar-nav ms-auto align-items-center gap-1 gap-lg-2">
                    <li class="nav-item"><a class="nav-link text-light opacity-75 hover-opacity-100 px-3" href="#">Home</a></li>
                    <li class="nav-item"><a class="nav-link text-light opacity-75 hover-opacity-100 px-3" href="login.jsp">Login</a></li>
                    <li class="nav-item"><a class="nav-link text-light opacity-75 hover-opacity-100 px-3" href="register.jsp">Register</a></li>
                    <li class="nav-item"><a class="nav-link text-light opacity-75 hover-opacity-100 px-3" href="admin.jsp">Admin</a></li>
                    <li class="nav-item ms-1">
                        <a class="btn btn-vote-pulse btn-primary rounded-pill px-4 py-2 fw-semibold shadow-sm"
                           href="vote.jsp"
                           style="background: linear-gradient(135deg, #4f46e5, #7c3aed); border: none;">
                            <i class="bi bi-check2-circle me-1"></i> Vote Now
                        </a>
                    </li>
                </ul>
            </div>
        </div>
    </nav>

    <!-- ============================================================ -->
    <!--  MAIN CONTENT
    <!-- ============================================================ -->
    <main class="flex-grow-1">

        <!-- ===== HERO SECTION ===== -->
        <div class="container py-4 py-md-5">
            <div class="hero-glow glass-card rounded-4 p-4 p-md-5 shadow-lg position-relative overflow-hidden">

                <!-- Decorative dots -->
                <div class="position-absolute top-0 end-0 opacity-10 d-none d-sm-block" style="font-size: 5rem;">⏺⏺⏺</div>

                <div class="row align-items-center g-4">
                    <div class="col-lg-7">
                        <!-- Badge -->
                        <div class="mb-3 d-flex flex-wrap align-items-center gap-2">
                            <span class="election-pill">
                                <i class="bi bi-flag-fill"></i> 🇳🇵 Election 2082
                            </span>
                            <span class="badge bg-white text-dark bg-opacity-60 rounded-pill px-3 py-2">
                                <i class="bi bi-clock-history me-1"></i> Live
                            </span>
                        </div>

                        <h1 class="display-3 fw-bold text-dark lh-1 mb-3">
                            Your voice, <br class="d-sm-none" />
                            <span class="gradient-text">digitally</span> heard.
                        </h1>

                        <p class="lead text-secondary-emphasis mb-4 fs-5" style="max-width: 620px;">
                            Secure, fast & transparent online voting — cast your ballot from anywhere, anytime.
                        </p>

                        <!-- Action Buttons -->
                        <div class="d-flex flex-wrap gap-3 align-items-center">
                            <a href="register.jsp" class="btn btn-primary btn-lg rounded-pill px-5 py-3 shadow-sm fw-semibold"
                               style="background: linear-gradient(135deg, #4f46e5, #6d28d9); border: none;">
                                <i class="bi bi-person-plus me-2"></i> Get Started
                            </a>
                            <a href="login.jsp" class="btn btn-outline-secondary btn-lg rounded-pill px-4 py-3 border-2 fw-medium">
                                <i class="bi bi-box-arrow-in-right me-1"></i> Login
                            </a>
                            <a href="admin.jsp" class="btn btn-outline-primary btn-lg rounded-pill px-4 py-3 fw-medium">
                                <i class="bi bi-shield-lock me-1"></i> Admin
                            </a>
                        </div>

                        <!-- Trust badges -->
                        <div class="mt-4 d-flex flex-wrap align-items-center gap-3 text-muted small">
                            <span><i class="bi bi-shield-check text-success me-1"></i> BCrypt secured</span>
                            <span class="d-none d-sm-inline">•</span>
                            <span><i class="bi bi-person-check text-primary me-1"></i> One voter, one vote</span>
                            <span class="d-none d-sm-inline">•</span>
                            <span><i class="bi bi-clock text-warning me-1"></i> Real-time results</span>
                        </div>
                    </div>

                    <!-- Right side visual (desktop only) -->
                    <div class="col-lg-5 d-none d-lg-block text-center">
                        <div class="bg-white bg-opacity-30 rounded-4 p-4 shadow-sm border border-white border-opacity-50">
                            <div class="display-1 mb-2">🗳️</div>
                            <p class="fw-semibold text-dark fs-5">Cast your vote in</p>
                            <div class="d-flex justify-content-center gap-2 mt-2 flex-wrap">
                                <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill">1. Register</span>
                                <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill">2. Login</span>
                                <span class="badge bg-primary bg-opacity-10 text-primary px-3 py-2 rounded-pill">3. Vote</span>
                            </div>
                            <hr class="my-3 opacity-25" />
                            <p class="text-muted small mb-0"><i class="bi bi-check-circle-fill text-success"></i> 12,847 votes cast today</p>
                        </div>
                    </div>
                </div>
            </div>
        </div>

        <!-- ===== FEATURES SECTION ===== -->
        <div class="container py-3">
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="feature-card p-4 h-100 shadow-sm">
                        <div class="d-flex align-items-center gap-3 mb-3">
                            <span class="display-5 text-primary">🔒</span>
                            <h5 class="fw-bold mb-0">Secure & Private</h5>
                        </div>
                        <p class="text-secondary-emphasis mb-0">
                            BCrypt hashed credentials, session management, and encrypted votes — your privacy is our priority.
                        </p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="feature-card p-4 h-100 shadow-sm">
                        <div class="d-flex align-items-center gap-3 mb-3">
                            <span class="display-5 text-success">📊</span>
                            <h5 class="fw-bold mb-0">Live Results</h5>
                        </div>
                        <p class="text-secondary-emphasis mb-0">
                            Watch vote counts update in real-time. Transparent dashboards show election progress instantly.
                        </p>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="feature-card p-4 h-100 shadow-sm">
                        <div class="d-flex align-items-center gap-3 mb-3">
                            <span class="display-5 text-info">⚙️</span>
                            <h5 class="fw-bold mb-0">Admin Control</h5>
                        </div>
                        <p class="text-secondary-emphasis mb-0">
                            Full control over elections, candidates, and voter monitoring — all from a powerful dashboard.
                        </p>
                    </div>
                </div>
            </div>
        </div>

        <!-- ===== HOW IT WORKS ===== -->
        <div class="container py-4">
            <h2 class="text-center fw-bold mb-4 text-dark display-6">How It Works</h2>
            <div class="row g-4 justify-content-center">
                <div class="col-6 col-md-3 text-center">
                    <div class="step-circle mx-auto mb-3">1️⃣</div>
                    <h6 class="fw-semibold">Register</h6>
                    <p class="text-muted small">Create your account with a unique voter ID</p>
                </div>
                <div class="col-6 col-md-3 text-center">
                    <div class="step-circle mx-auto mb-3">2️⃣</div>
                    <h6 class="fw-semibold">Login</h6>
                    <p class="text-muted small">Access your account securely</p>
                </div>
                <div class="col-6 col-md-3 text-center">
                    <div class="step-circle mx-auto mb-3">3️⃣</div>
                    <h6 class="fw-semibold">Vote</h6>
                    <p class="text-muted small">Pick your candidate and submit</p>
                </div>
                <div class="col-6 col-md-3 text-center">
                    <div class="step-circle mx-auto mb-3">4️⃣</div>
                    <h6 class="fw-semibold">Track</h6>
                    <p class="text-muted small">Watch results live as they come in</p>
                </div>
            </div>
        </div>

        <!-- ===== CALL TO ACTION BANNER ===== -->
        <div class="container py-3 pb-5">
            <div class="rounded-4 p-4 p-md-5 text-center text-white shadow-lg"
                 style="background: linear-gradient(145deg, #4338ca, #6d28d9);">
                <div class="row align-items-center g-3">
                    <div class="col-md-8 text-md-start">
                        <h3 class="fw-bold mb-1"><i class="bi bi-megaphone-fill me-2"></i> Ready to make a difference?</h3>
                        <p class="mb-0 opacity-75">Join thousands of voters who already cast their ballot online.</p>
                    </div>
                    <div class="col-md-4 text-md-end">
                        <a href="vote.jsp" class="btn btn-light btn-lg rounded-pill px-5 fw-semibold shadow">
                            Vote now <i class="bi bi-arrow-right ms-1"></i>
                        </a>
                    </div>
                </div>
            </div>
        </div>

    </main>

    <!-- ============================================================ -->
    <!--  FOOTER
    <!-- ============================================================ -->
    <footer class="text-center py-4 mt-2 border-top bg-white bg-opacity-50">
        <div class="container">
            <div class="d-flex flex-wrap justify-content-center align-items-center gap-3">
                <span class="text-dark fw-semibold">🗳️ E-Matdaan</span>
                <span class="text-muted">© <%= java.time.Year.now() %></span>
                <span class="text-muted d-none d-sm-inline">·</span>
                <span class="text-muted small">One click for democracy 🇳🇵</span>
                <span class="text-muted d-none d-sm-inline">·</span>
                <span class="text-muted small">Built with ❤️ for Nepal Election 2082</span>
            </div>
            <div class="mt-3 d-flex justify-content-center gap-4 small">
                <a href="#" class="footer-link">Privacy Policy</a>
                <a href="#" class="footer-link">Terms of Service</a>
                <a href="#" class="footer-link">Support</a>
                <a href="#" class="footer-link"><i class="bi bi-github"></i> GitHub</a>
            </div>
            <div class="mt-2 text-muted small opacity-50">
                <i class="bi bi-shield-check"></i> Secure · Transparent · Trusted
            </div>
        </div>
    </footer>

    <!-- Bootstrap JS (for navbar toggle) -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>

</body>
</html>