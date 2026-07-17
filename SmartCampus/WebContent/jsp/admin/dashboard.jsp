<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%
    User sessionUser = (User) session.getAttribute("user");
    if (sessionUser == null || !"admin".equalsIgnoreCase(sessionUser.getRole())) {
        response.sendRedirect(request.getContextPath() + "/login?role=admin");
        return;
    }
%>
<jsp:include page="/jsp/common/header.jsp" />

<div class="app-container">
    <!-- Sidebar Navigation -->
    <jsp:include page="/jsp/common/sidebar.jsp" />

    <!-- Main Content Area -->
    <div class="main-content">
        <!-- Top Navbar -->
        <jsp:include page="/jsp/common/navbar.jsp" />

        <div class="content-wrapper">
            <!-- Greeting Header -->
            <div class="glass-panel py-4 px-5 d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <h3 class="fw-bold mb-1">Hello, Administrator!</h3>
                    <p class="text-secondary m-0">Welcome to your Smart Campus Admin dashboard. From here you can manage all maintenance activities and view blueprints.</p>
                </div>
            </div>

            <!-- Stats Row -->
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="stat-card-info">
                            <h3>Active</h3>
                            <p>System Online</p>
                        </div>
                        <div class="stat-card-icon bg-success bg-opacity-10 text-success">
                            <i class="bi bi-cpu-fill"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="stat-card-info">
                            <h3>Full Access</h3>
                            <p>All Privileges Enabled</p>
                        </div>
                        <div class="stat-card-icon bg-primary bg-opacity-10 text-primary">
                            <i class="bi bi-shield-lock-fill"></i>
                        </div>
                    </div>
                </div>
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="stat-card-info">
                            <h3>Reports</h3>
                            <p>System Audits &amp; Logs</p>
                        </div>
                        <div class="stat-card-icon bg-warning bg-opacity-10 text-warning">
                            <i class="bi bi-journal-check"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Panel Section -->
            <div class="glass-panel mt-4">
                <h5 class="fw-bold mb-3"><i class="bi bi-gear-wide-connected text-indigo me-2"></i> Administrative Controls</h5>
                <p class="text-secondary">Use the sidebar navigation to view and manage campus issues, locate pins on the interactive blueprint, and monitor overall system operations.</p>
                <div class="d-flex gap-3 mt-4">
                    <a href="<%= request.getContextPath() %>/jsp/supervisor/complaints.jsp" class="btn btn-indigo text-white px-4 py-2">Manage Issues</a>
                    <a href="<%= request.getContextPath() %>/campus-blueprint" class="btn btn-outline-indigo px-4 py-2">View Map Blueprint</a>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
