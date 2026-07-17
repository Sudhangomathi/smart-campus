<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%@ page import="model.Student" %>
<%@ page import="model.Supervisor" %>
<%@ page import="model.Worker" %>
<%
    User navUser = (User) session.getAttribute("user");
    String displayName = "User";
    String displayRole = "Guest";
    
    if (navUser != null) {
        displayRole = navUser.getRole();
        if ("student".equalsIgnoreCase(displayRole)) {
            Student s = (Student) session.getAttribute("student");
            if (s != null) displayName = s.getName();
        } else if ("supervisor".equalsIgnoreCase(displayRole)) {
            Supervisor sv = (Supervisor) session.getAttribute("supervisor");
            if (sv != null) displayName = sv.getName();
        } else if ("worker".equalsIgnoreCase(displayRole)) {
            Worker w = (Worker) session.getAttribute("worker");
            if (w != null) displayName = w.getName();
        }
    }
    
    // Get initials for profile badge
    String initials = "U";
    if (displayName != null && !displayName.trim().isEmpty()) {
        String[] parts = displayName.trim().split("\\s+");
        if (parts.length > 1) {
            initials = "" + parts[0].charAt(0) + parts[1].charAt(0);
        } else {
            initials = "" + displayName.charAt(0);
        }
        initials = initials.toUpperCase();
    }
%>
<header class="topbar">
    <div class="d-flex align-items-center gap-3">
        <button class="btn btn-link p-0 text-white sidebar-responsive-toggle d-lg-none" type="button">
            <i class="bi bi-list fs-2 text-dark"></i>
        </button>
        <span class="topbar-title text-capitalize fw-bold"><%= displayRole %> Portal</span>
    </div>

    <div class="topbar-actions">
        <!-- Theme Toggle Button -->
        <button class="theme-toggle-btn" title="Toggle Light/Dark Theme" aria-label="Toggle Theme">
            <i class="bi bi-moon-stars-fill"></i>
        </button>

        <!-- Notification Bell Button -->
        <button class="notification-bell-btn" title="Notifications" aria-label="Notifications">
            <i class="bi bi-bell-fill"></i>
            <span class="badge-count" style="display: none;">0</span>
        </button>
        
        <!-- Notifications Dropdown -->
        <div class="notifications-dropdown">
            <div class="notifications-dropdown-header">
                <h6>Notifications</h6>
                <span class="mark-read-btn">Mark all read</span>
            </div>
            <div class="notifications-list">
                <div class="notification-empty">Loading notifications...</div>
            </div>
        </div>

        <!-- User Profile Info -->
        <div class="user-profile-badge d-none d-md-flex align-items-center">
            <div class="user-avatar"><%= initials %></div>
            <div class="user-info">
                <div class="user-name text-truncate" style="max-width: 120px;"><%= displayName %></div>
                <div class="user-role text-capitalize"><%= displayRole %></div>
            </div>
        </div>
    </div>
</header>
