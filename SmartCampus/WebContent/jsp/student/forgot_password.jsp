<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Forgot Password - Smart Campus</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css">
    <!-- Custom Style Sheet -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css">
</head>
<body class="login-gate-body">

    <div class="login-card">
        <div class="text-center mb-4">
            <h2 class="fw-bold">Smart Campus</h2>
            <p class="text-secondary text-white-50">Reset Password Credentials</p>
        </div>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger alert-dismissible fade show bg-danger bg-opacity-25 text-danger border-danger border-opacity-25" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= request.getAttribute("error") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/student" method="POST">
            <input type="hidden" name="action" value="forgotPassword">

            <div class="mb-3">
                <label for="email" class="form-label text-white-50 small">Registered Email Address</label>
                <div class="input-group">
                    <span class="input-group-text bg-dark border-secondary border-opacity-25 text-white-50"><i class="bi bi-envelope-fill"></i></span>
                    <input type="email" class="form-control bg-dark text-white border-secondary border-opacity-25" id="email" name="email" placeholder="john.doe@campus.edu" required>
                </div>
            </div>

            <div class="mb-3">
                <label for="newPassword" class="form-label text-white-50 small">New Password</label>
                <div class="input-group">
                    <span class="input-group-text bg-dark border-secondary border-opacity-25 text-white-50"><i class="bi bi-lock-fill"></i></span>
                    <input type="password" class="form-control bg-dark text-white border-secondary border-opacity-25" id="newPassword" name="newPassword" placeholder="••••••••" required>
                </div>
            </div>

            <div class="mb-4">
                <label for="confirmPassword" class="form-label text-white-50 small">Confirm New Password</label>
                <div class="input-group">
                    <span class="input-group-text bg-dark border-secondary border-opacity-25 text-white-50"><i class="bi bi-lock-fill"></i></span>
                    <input type="password" class="form-control bg-dark text-white border-secondary border-opacity-25" id="confirmPassword" name="confirmPassword" placeholder="••••••••" required>
                </div>
            </div>

            <button type="submit" class="btn btn-indigo w-100 py-2 fw-semibold text-white mb-3" style="background-color: #4f46e5; border: none;">Reset Password</button>
        </form>

        <div class="text-center mt-2">
            <a href="<%= request.getContextPath() %>/login?role=student" class="text-indigo fw-semibold text-decoration-none small" style="color: #818cf8;"><i class="bi bi-arrow-left"></i> Back to login</a>
        </div>
    </div>

    <!-- Bootstrap Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
