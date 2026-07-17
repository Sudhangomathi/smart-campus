<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%
    User sidebarUser = (User) session.getAttribute("user");
    String sidebarRole = sidebarUser != null ? sidebarUser.getRole() : "student";
    String currentURI = request.getRequestURI();
%>
<aside class="sidebar">
    <div class="sidebar-header">
        <div class="user-avatar bg-white text-primary fw-bold" style="width:36px; height:36px;">
            <i class="bi bi-shield-fill-exclamation fs-5 text-indigo"></i>
        </div>
        <div class="sidebar-logo">Smart Campus</div>
    </div>

    <nav class="sidebar-menu">
        <% if ("student".equalsIgnoreCase(sidebarRole)) { %>
            <a href="<%= request.getContextPath() %>/jsp/student/dashboard.jsp" 
               class="menu-item <%= currentURI.contains("/student/dashboard.jsp") ? "active" : "" %>">
                <i class="bi bi-grid-1x2-fill"></i> Dashboard
            </a>
            <a href="<%= request.getContextPath() %>/jsp/student/raise_complaint.jsp" 
               class="menu-item <%= currentURI.contains("/student/raise_complaint.jsp") ? "active" : "" %>">
                <i class="bi bi-plus-circle-fill"></i> Raise Complaint
            </a>
            <a href="<%= request.getContextPath() %>/jsp/student/history.jsp" 
               class="menu-item <%= currentURI.contains("/student/history.jsp") ? "active" : "" %>">
                <i class="bi bi-clock-history"></i> Complaint History
            </a>
            <a href="<%= request.getContextPath() %>/campus-blueprint" 
               class="menu-item <%= currentURI.contains("/campus-blueprint") ? "active" : "" %>">
                <i class="bi bi-map-fill"></i> Campus Blueprint
            </a>
            <a href="<%= request.getContextPath() %>/jsp/student/settings.jsp" 
               class="menu-item <%= currentURI.contains("/student/settings.jsp") ? "active" : "" %>">
                <i class="bi bi-gear-fill"></i> Settings &amp; Profile
            </a>
        <% } else if ("supervisor".equalsIgnoreCase(sidebarRole)) { %>
            <a href="<%= request.getContextPath() %>/jsp/supervisor/dashboard.jsp" 
               class="menu-item <%= currentURI.contains("/supervisor/dashboard.jsp") ? "active" : "" %>">
                <i class="bi bi-speedometer2"></i> Dashboard
            </a>
            <a href="<%= request.getContextPath() %>/jsp/supervisor/complaints.jsp" 
               class="menu-item <%= currentURI.contains("/supervisor/complaints.jsp") ? "active" : "" %>">
                <i class="bi bi-card-checklist"></i> Manage Issues
            </a>
            <a href="<%= request.getContextPath() %>/jsp/supervisor/reports.jsp" 
               class="menu-item <%= currentURI.contains("/supervisor/reports.jsp") ? "active" : "" %>">
                <i class="bi bi-file-earmark-bar-graph-fill"></i> View Reports
            </a>
            <a href="<%= request.getContextPath() %>/campus-blueprint" 
               class="menu-item <%= currentURI.contains("/campus-blueprint") ? "active" : "" %>">
                <i class="bi bi-map-fill"></i> Campus Blueprint
            </a>
            <a href="<%= request.getContextPath() %>/jsp/supervisor/settings.jsp" 
               class="menu-item <%= currentURI.contains("/supervisor/settings.jsp") ? "active" : "" %>">
                <i class="bi bi-gear-fill"></i> Settings &amp; Profile
            </a>
        <% } else if ("worker".equalsIgnoreCase(sidebarRole)) { %>
            <a href="<%= request.getContextPath() %>/jsp/worker/dashboard.jsp" 
               class="menu-item <%= currentURI.contains("/worker/dashboard.jsp") ? "active" : "" %>">
                <i class="bi bi-house-door-fill"></i> My Dashboard
            </a>
            <a href="<%= request.getContextPath() %>/campus-blueprint" 
               class="menu-item <%= currentURI.contains("/campus-blueprint") ? "active" : "" %>">
                <i class="bi bi-map-fill"></i> Campus Blueprint
            </a>
            <a href="<%= request.getContextPath() %>/jsp/worker/settings.jsp" 
               class="menu-item <%= currentURI.contains("/worker/settings.jsp") ? "active" : "" %>">
                <i class="bi bi-gear-fill"></i> Profile &amp; Settings
        <% } %>
    </nav>

    <div class="sidebar-footer">
        <a href="<%= request.getContextPath() %>/logout" class="menu-item text-danger border border-danger-subtle border-opacity-10">
            <i class="bi bi-box-arrow-left"></i> Logout
        </a>
    </div>
</aside>
