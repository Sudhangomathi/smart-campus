<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.User" %>
<%
    // Global session auth check for internal pages
    User sessionUser = (User) session.getAttribute("user");
    boolean isLoginPage = request.getRequestURI().endsWith("login.jsp") || request.getRequestURI().endsWith("register.jsp") || request.getRequestURI().endsWith("forgot_password.jsp");
    if (sessionUser == null && !isLoginPage) {
        String reqRole = request.getParameter("role");
        if (reqRole == null) reqRole = "student";
        response.sendRedirect(request.getContextPath() + "/login?role=" + reqRole);
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Smart Campus Complaint Portal</title>
    
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css">
    

    <!-- Chart.js CDN (for supervisor dashboard) -->
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    

    
    <!-- Custom Style Sheet with Cache Buster -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=3">
</head>
<body>
