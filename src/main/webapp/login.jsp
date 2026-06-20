<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - E-Matdaan</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <script src="https://cdn.tailwindcss.com"></script>

    <style>
        body {
            background: linear-gradient(135deg, #e0e7ff 0%, #c7d2fe 100%);
            min-height: 100vh;
        }
        .login-card {
            background: white;
            border-radius: 16px;
            padding: 40px;
            width: 100%;
            max-width: 420px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.1);
            transition: transform 0.3s ease;
        }
        .login-card:hover {
            transform: translateY(-5px);
        }
        .login-header {
            text-align: center;
            margin-bottom: 30px;
        }
        .login-header .icon {
            font-size: 48px;
            margin-bottom: 10px;
        }
        .login-header h3 {
            font-weight: 700;
            color: #1e293b;
        }
        .login-header p {
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
        .btn-login {
            height: 48px;
            border-radius: 10px;
            font-weight: 600;
            background: linear-gradient(135deg, #4f46e5, #7c3aed);
            border: none;
            transition: all 0.3s ease;
        }
        .btn-login:hover {
            transform: translateY(-2px);
            box-shadow: 0 8px 25px rgba(79, 70, 229, 0.3);
        }
        .alert {
            border-radius: 10px;
            border: none;
        }
        .register-link {
            color: #4f46e5;
            font-weight: 600;
            text-decoration: none;
            transition: color 0.3s ease;
        }
        .register-link:hover {
            color: #7c3aed;
            text-decoration: underline;
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
        .forgot-password {
            color: #64748b;
            font-size: 13px;
            text-decoration: none;
            transition: color 0.3s ease;
        }
        .forgot-password:hover {
            color: #4f46e5;
            text-decoration: underline;
        }
        .divider {
            display: flex;
            align-items: center;
            text-align: center;
            margin: 20px 0;
        }
        .divider::before,
        .divider::after {
            content: '';
            flex: 1;
            border-bottom: 1px solid #e2e8f0;
        }
        .divider::before {
            margin-right: 15px;
        }
        .divider::after {
            margin-left: 15px;
        }
        .divider span {
            color: #94a3b8;
            font-size: 13px;
        }
    </style>
</head>

<body>

<%
    // If already logged in, redirect properly
    if (session.getAttribute("voterId") != null && session.getAttribute("role") != null) {
        String role = (String) session.getAttribute("role");
        if ("admin".equals(role)) {
            response.sendRedirect("totalVote");
        } else {
            response.sendRedirect("dashboard.jsp");
        }
        return;
    }
%>

<div class="container d-flex justify-content-center align-items-center" style="min-height:100vh;">
    <div class="login-card">

        <!-- Header -->
        <div class="login-header">
            <div class="icon">🔐</div>
            <h3>Welcome Back</h3>
            <p>Login to your account to cast your vote</p>
        </div>

        <!-- Error Messages -->
        <%
            String error = request.getParameter("error");
            String success = request.getParameter("success");

            if (error != null && !error.isEmpty()) {
        %>
            <div class="alert alert-danger alert-dismissible fade show" role="alert">
                <strong>❌ </strong> <%= error %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <% if (success != null && !success.isEmpty()) { %>
            <div class="alert alert-success alert-dismissible fade show" role="alert">
                <strong>✅ </strong> <%= success %>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <% } %>

        <!-- Login Form -->
        <form action="${pageContext.request.contextPath}/login" method="post">
            <div class="mb-3">
                <label class="form-label fw-semibold">
                    <span>👤</span> Voter ID / Username
                </label>
                <input type="text"
                       name="loginId"
                       class="form-control"
                       placeholder="Enter your voter ID or username"
                       required>
            </div>

            <div class="mb-3">
                <label class="form-label fw-semibold">
                    <span>🔑</span> Password
                </label>
                <div class="input-group">
                    <input type="password"
                           name="password"
                           id="password"
                           class="form-control"
                           placeholder="Enter your password"
                           required>
                    <button class="btn btn-outline-secondary"
                            type="button"
                            onclick="togglePassword()"
                            style="border-radius: 0 10px 10px 0; border: 2px solid #e2e8f0; border-left: none;">
                        👁️
                    </button>
                </div>
            </div>

            <!-- Forgot Password Link -->
            <div class="text-end mb-3">
                <a href="forgot-password.jsp" class="forgot-password">Forgot password?</a>
            </div>

            <button type="submit" class="btn btn-login w-100 text-white">
                Login
            </button>
        </form>

        <!-- Divider -->
        <div class="divider">
            <span>or</span>
        </div>

        <!-- Quick Links -->
        <div class="d-grid gap-2">
            <a href="register.jsp" class="btn btn-outline-primary rounded-pill py-2 fw-semibold">
                <i class="bi bi-person-plus"></i> Create New Account
            </a>
        </div>

        <!-- Register Link -->
        <p class="text-center mt-3 mb-0">
            No account?
            <a href="register.jsp" class="register-link">Register here</a>
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
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>