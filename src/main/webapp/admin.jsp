<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%
    // Handle login
    if ("POST".equalsIgnoreCase(request.getMethod())) {
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        // Admin credentials - in production, check from database
        final String ADMIN_USERNAME = "admin";
        final String ADMIN_PASSWORD = "admin123";

        if (ADMIN_USERNAME.equals(username) && ADMIN_PASSWORD.equals(password)) {
            session.setAttribute("isAdmin", true);
            session.setAttribute("role", "admin");
            session.setAttribute("username", username);
            session.setAttribute("fullName", "Admin");
            response.sendRedirect("admin_dashboard.jsp");
            return;
        } else {
            request.setAttribute("error", "invalid");
        }
    }
%>

<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Admin Login | E-Matdaan</title>
    <meta name="viewport" content="width=device-width, initial-scale=1">

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">

    <style>
        body {
            min-height: 100vh;
            background: linear-gradient(135deg, #0d6efd, #6610f2);
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-card {
            background: #fff;
            border-radius: 14px;
            padding: 2.5rem;
            width: 100%;
            max-width: 420px;
            box-shadow: 0 20px 45px rgba(0,0,0,0.15);
        }

        .brand-icon {
            font-size: 3rem;
        }

        .form-control {
            height: 48px;
        }

        .btn-login {
            height: 48px;
            font-weight: 600;
        }
    </style>
</head>

<body>

<div class="login-card">

    <!-- HEADER -->
    <div class="text-center mb-4">
        <div class="brand-icon text-primary">🛡️</div>
        <h3 class="fw-bold mt-2">Admin Login</h3>
        <p class="text-muted mb-0">E-Matdaan Control Panel</p>
    </div>

    <!-- ERROR MESSAGE -->
    <%
        String error = (String) request.getAttribute("error");
        if ("invalid".equals(error)) {
    %>
        <div class="alert alert-danger d-flex align-items-center">
            <strong class="me-2">⚠</strong>
            Invalid username or password
        </div>
    <% } %>

    <!-- LOGIN FORM -->
    <form action="admin.jsp" method="post">

        <div class="mb-3">
            <label class="form-label">Username</label>
            <input type="text"
                   name="username"
                   class="form-control"
                   placeholder="Enter admin username"
                   value="admin"
                   required>
        </div>

        <div class="mb-4">
            <label class="form-label">Password</label>
            <div class="input-group">
                <input type="password"
                       name="password"
                       id="password"
                       class="form-control"
                       placeholder="Enter password"
                       value="admin123"
                       required>
                <button class="btn btn-outline-secondary"
                        type="button"
                        onclick="togglePassword()">
                    👁
                </button>
            </div>
        </div>

        <button type="submit" class="btn btn-primary btn-login w-100">
            Login to Dashboard
        </button>
    </form>

    <!-- FOOTER -->
    <div class="text-center mt-4">
        <small class="text-muted">
            Authorized personnel only
        </small>
    </div>

</div>

<script>
    function togglePassword() {
        const pwd = document.getElementById("password");
        pwd.type = pwd.type === "password" ? "text" : "password";
    }
</script>

</body>
</html>