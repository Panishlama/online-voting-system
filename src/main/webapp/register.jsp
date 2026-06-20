<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="java.net.URLEncoder" %>
<%@ page import="java.nio.charset.StandardCharsets" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Register - E-Matdaan</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>

    <style>
        body {
            background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 100%);
            min-height: 100vh;
        }
        .register-card {
            background: white;
            border-radius: 16px;
            padding: 40px;
            width: 100%;
            max-width: 450px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }
        .register-card:hover {
            transform: translateY(-5px);
        }
        .register-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .register-header .icon {
            font-size: 48px;
            margin-bottom: 10px;
        }
        .register-header h3 {
            font-weight: 700;
            color: #1e293b;
        }
        .register-header p {
            color: #64748b;
            font-size: 14px;
        }
        .form-control {
            height: 48px;
            border-radius: 10px;
            border: 2px solid #e2e8f0;
            transition: all 0.3s ease;
        }
        .form-control:focus {
            border-color: #4f46e5;
            box-shadow: 0 0 0 3px rgba(79, 70, 229, 0.1);
        }
        .btn-register {
            height: 48px;
            border-radius: 10px;
            font-weight: 600;
            background: linear-gradient(135deg, #4f46e5, #7c3aed);
            border: none;
            transition: all 0.3s ease;
        }
        .btn-register:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(79, 70, 229, 0.3);
        }
        .alert {
            border-radius: 10px;
            border: none;
        }
        .login-link {
            color: #4f46e5;
            font-weight: 600;
            text-decoration: none;
            transition: color 0.3s ease;
        }
        .login-link:hover {
            color: #7c3aed;
            text-decoration: underline;
        }
        .password-strength {
            height: 4px;
            border-radius: 2px;
            margin-top: 5px;
            transition: all 0.3s ease;
        }
        .requirements {
            font-size: 12px;
            color: #64748b;
            margin-top: 5px;
        }
        .requirements .valid {
            color: #22c55e;
        }
        .requirements .invalid {
            color: #ef4444;
        }
        .input-group-text {
            background: white;
            border: 2px solid #e2e8f0;
            border-radius: 10px 0 0 10px;
        }
        .input-group .form-control {
            border-radius: 0 10px 10px 0;
            border-left: none;
        }
    </style>
</head>
<body>

<!-- Redirect if already logged in -->
<%
    if (session.getAttribute("voterId") != null || session.getAttribute("role") != null) {
        String role = (String) session.getAttribute("role");
        if ("admin".equals(role)) {
            response.sendRedirect("admin_dashboard.jsp");
        } else {
            response.sendRedirect("dashboard.jsp");
        }
        return;
    }
%>

<!-- Navbar -->
<nav class="navbar navbar-expand-lg navbar-dark bg-primary shadow-sm sticky-top">
    <div class="container">
        <a class="navbar-brand fw-bold text-white fs-4" href="index.jsp">
            🗳️ E-Matdaan
        </a>
        <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarNav">
            <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
            <ul class="navbar-nav ms-auto">
                <li class="nav-item">
                    <a class="nav-link text-white" href="login.jsp">Login</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link text-white active" href="register.jsp">Register</a>
                </li>
                <li class="nav-item">
                    <a class="nav-link btn btn-outline-light px-4 ms-3 rounded-pill" href="vote.jsp">
                        Vote Now
                    </a>
                </li>
            </ul>
        </div>
    </div>
</nav>

<!-- Register Form -->
<div class="container d-flex justify-content-center align-items-center" style="min-height: 80vh;">
    <div class="register-card">

        <!-- Header -->
        <div class="register-header">
            <div class="icon">📝</div>
            <h3>Create Your Account</h3>
            <p>Join E-Matdaan and cast your vote</p>
        </div>

        <!-- Messages -->
        <%
            String error = request.getParameter("error");
            String success = request.getParameter("success");

            if (error != null && !error.isEmpty()) {
        %>
            <div class="alert alert-danger alert-dismissible fade show text-center" role="alert">
                <strong>❌ </strong> <%= error %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <%
            if (success != null && !success.isEmpty()) {
        %>
            <div class="alert alert-success alert-dismissible fade show text-center" role="alert">
                <strong>✅ </strong> <%= success %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <!-- Registration Form -->
        <form action="${pageContext.request.contextPath}/register" method="post">
            <div class="mb-3">
                <label class="form-label fw-semibold">
                    <span>👤</span> Full Name
                </label>
                <input type="text"
                       class="form-control"
                       name="fullName"
                       placeholder="Enter your full name"
                       required>
            </div>

            <div class="mb-3">
                <label class="form-label fw-semibold">
                    <span>👤</span> Username
                </label>
                <input type="text"
                       class="form-control"
                       name="username"
                       placeholder="Choose a unique username"
                       required>
                <div class="requirements" id="usernameHelp">
                    Username must be unique and at least 3 characters
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label fw-semibold">
                    <span>🔑</span> Password
                </label>
                <div class="input-group">
                    <input type="password"
                           class="form-control"
                           name="password"
                           id="password"
                           placeholder="Create a strong password"
                           required
                           onkeyup="checkPasswordStrength(this.value)">
                    <button class="btn btn-outline-secondary"
                            type="button"
                            onclick="togglePassword()"
                            style="border-radius: 0 10px 10px 0; border: 2px solid #e2e8f0; border-left: none;">
                        👁️
                    </button>
                </div>
                <div class="password-strength" id="strengthBar"></div>
                <div class="requirements" id="passwordHelp">
                    Minimum 6 characters with letters and numbers
                </div>
            </div>

            <div class="mb-3">
                <label class="form-label fw-semibold">
                    <span>🔐</span> Confirm Password
                </label>
                <input type="password"
                       class="form-control"
                       name="confirmPassword"
                       id="confirmPassword"
                       placeholder="Repeat your password"
                       required
                       onkeyup="checkPasswordMatch()">
                <div class="requirements" id="matchHelp"></div>
            </div>

            <button type="submit" class="btn btn-register w-100 text-white">
                Register Now
            </button>
        </form>

        <!-- Login Link -->
        <p class="text-center mt-4 text-muted">
            Already have an account?
            <a href="login.jsp" class="login-link">Login here</a>
        </p>

        <!-- Back to Home -->
        <div class="text-center mt-2">
            <a href="index.jsp" class="text-muted text-decoration-none" style="font-size: 13px;">
                ← Back to Home
            </a>
        </div>

    </div>
</div>

<script>
    function togglePassword() {
        const pwd = document.getElementById("password");
        const type = pwd.getAttribute("type") === "password" ? "text" : "password";
        pwd.setAttribute("type", type);
    }

    function checkPasswordStrength(password) {
        const bar = document.getElementById("strengthBar");
        let strength = 0;
        let color = "#ef4444";
        let width = "0%";

        if (password.length >= 6) strength++;
        if (password.match(/[a-z]/)) strength++;
        if (password.match(/[A-Z]/)) strength++;
        if (password.match(/[0-9]/)) strength++;
        if (password.match(/[^a-zA-Z0-9]/)) strength++;

        switch(strength) {
            case 0:
            case 1:
                color = "#ef4444";
                width = "20%";
                break;
            case 2:
                color = "#f59e0b";
                width = "40%";
                break;
            case 3:
                color = "#f59e0b";
                width = "60%";
                break;
            case 4:
                color = "#22c55e";
                width = "80%";
                break;
            case 5:
                color = "#22c55e";
                width = "100%";
                break;
        }

        bar.style.width = width;
        bar.style.background = color;
    }

    function checkPasswordMatch() {
        const password = document.getElementById("password").value;
        const confirm = document.getElementById("confirmPassword").value;
        const help = document.getElementById("matchHelp");

        if (confirm.length === 0) {
            help.innerHTML = "";
            return;
        }

        if (password === confirm) {
            help.innerHTML = "✅ Passwords match";
            help.style.color = "#22c55e";
        } else {
            help.innerHTML = "❌ Passwords do not match";
            help.style.color = "#ef4444";
        }
    }
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>