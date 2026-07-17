<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Supervisor Login - Smart Campus</title>
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
            <p class="text-secondary text-white-50">Campus Maintenance Management</p>
        </div>

        <!-- Login Tabs to Switch Roles -->
        <div class="login-tabs">
            <a href="<%= request.getContextPath() %>/login?role=student" class="login-tab-link">Student</a>
            <a href="<%= request.getContextPath() %>/login?role=supervisor" class="login-tab-link active">Supervisor</a>
            <a href="<%= request.getContextPath() %>/login?role=worker" class="login-tab-link">Worker</a>
        </div>

        <h4 class="mb-3 text-center fw-semibold text-warning">Supervisor Gate</h4>

        <!-- Alerts -->
        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger alert-dismissible fade show bg-danger bg-opacity-25 text-danger border-danger border-opacity-25" role="alert">
                <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= request.getAttribute("error") %>
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            </div>
        <% } %>

        <form action="<%= request.getContextPath() %>/login" method="POST">
            <input type="hidden" name="role" value="supervisor">
            
            <div class="mb-3">
                <label for="email" class="form-label text-white-50 small">Supervisor Email</label>
                <div class="input-group">
                    <span class="input-group-text bg-dark border-secondary border-opacity-25 text-white-50"><i class="bi bi-person-fill-lock"></i></span>
                    <input type="email" class="form-control bg-dark text-white border-secondary border-opacity-25" id="email" name="email" placeholder="supervisor@campus.edu" required>
                </div>
            </div>

            <div class="mb-4">
                <label for="password" class="form-label text-white-50 small">Security Key / Password</label>
                <div class="input-group">
                    <span class="input-group-text bg-dark border-secondary border-opacity-25 text-white-50"><i class="bi bi-key-fill"></i></span>
                    <input type="password" class="form-control bg-dark text-white border-secondary border-opacity-25" id="password" name="password" placeholder="••••••••" required>
                </div>
            </div>

            <button type="submit" class="btn btn-warning w-100 py-2 fw-semibold text-dark mb-3">Sign In as Supervisor</button>
        </form>

        <div class="text-center mt-2">
            <p class="text-white-50 small">New Supervisor? <a href="<%= request.getContextPath() %>/jsp/supervisor/register.jsp" class="text-warning fw-semibold text-decoration-none">Create an Account</a></p>
        </div>
    </div>

    <!-- Bootstrap Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
