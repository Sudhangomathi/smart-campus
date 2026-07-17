<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Smart Campus</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css">
    <!-- Custom Style Sheet -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=3">
</head>
<body>

    <div class="portal-container">
        <!-- Left Side: Branding & Welcome Message -->
        <div class="portal-left">
            <div class="portal-left-content">
                <img src="<%= request.getContextPath() %>/images/college_logo.png" alt="College Logo" class="portal-logo">
                <h1 class="portal-title">Smart Campus</h1>
                <p class="portal-subtitle">Complaint Redressal &amp; Maintenance Portal</p>
            </div>
        </div>

        <!-- Right Side: Login Process -->
        <div class="portal-right">
            <div class="portal-card">
                <h3 class="fw-bold login-title text-center mb-4">User Sign In</h3>

                <!-- Success or Error Alerts -->
                <% if (request.getParameter("msg") != null) { %>
                    <div class="alert alert-success alert-dismissible fade show bg-success bg-opacity-10 text-success border-success border-opacity-10" role="alert">
                        <i class="bi bi-check-circle-fill me-2"></i> <%= request.getParameter("msg") %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                <% } %>
                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show bg-danger bg-opacity-10 text-danger border-danger border-opacity-10" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= request.getAttribute("error") %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                <% } %>

                <form action="<%= request.getContextPath() %>/login" method="POST">
                    <!-- Email Input -->
                    <div class="mb-3">
                        <label for="email" class="form-label fw-semibold small login-label">Email Address</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-envelope-fill"></i></span>
                            <input type="email" class="form-control" id="email" name="email" placeholder="name@campus.edu" required>
                        </div>
                    </div>

                    <!-- Password Input -->
                    <div class="mb-3">
                        <div class="d-flex justify-content-between">
                            <label for="password" class="form-label fw-semibold small login-label">Password</label>
                            <a href="<%= request.getContextPath() %>/student?action=forgot" class="small text-indigo text-decoration-none fw-semibold">Forgot Password?</a>
                        </div>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-lock-fill"></i></span>
                            <input type="password" class="form-control" id="password" name="password" placeholder="••••••••" required>
                        </div>
                    </div>

                    <!-- Show Password Toggle -->
                    <div class="d-flex justify-content-between align-items-center mb-4">
                        <div class="form-check">
                            <input class="form-check-input" type="checkbox" id="showPassword" onclick="togglePasswordVisibility()">
                            <label class="form-check-label small fw-semibold login-label" style="cursor: pointer;" for="showPassword">
                                Show Password
                            </label>
                        </div>
                    </div>

                    <button type="submit" class="btn btn-indigo w-100 py-2 fw-bold text-white mb-3">Sign In</button>
                </form>

                <div class="text-center mt-3 border-top pt-3">
                    <p class="small mb-0 login-label">Don't have an account? <a href="<%= request.getContextPath() %>/jsp/student/register.jsp" class="text-indigo fw-bold text-decoration-none">Register here</a></p>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- Password visibility toggle script -->
    <script>
        function togglePasswordVisibility() {
            const passwordInput = document.getElementById("password");
            const showPasswordCheckbox = document.getElementById("showPassword");
            if (showPasswordCheckbox.checked) {
                passwordInput.type = "text";
            } else {
                passwordInput.type = "password";
            }
        }
    </script>
</body>
</html>
