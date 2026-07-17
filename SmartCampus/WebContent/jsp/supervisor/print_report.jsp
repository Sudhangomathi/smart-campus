<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Complaint" %>
<%@ page import="java.util.List" %>
<%
    List<Complaint> reportData = (List<Complaint>) request.getAttribute("reportData");
    String startDate = (String) request.getAttribute("startDate");
    String endDate = (String) request.getAttribute("endDate");
    String category = (String) request.getAttribute("category");
    String building = (String) request.getAttribute("building");
    String status = (String) request.getAttribute("status");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <title>Maintenance Report Print - Smart Campus</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            background-color: #ffffff;
            color: #000000;
            padding: 30px;
            font-family: Arial, sans-serif;
        }
        .report-header {
            border-bottom: 2px solid #334155;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .filter-badge {
            background-color: #f1f5f9;
            padding: 4px 10px;
            border-radius: 4px;
            font-size: 0.85rem;
            border: 1px solid #cbd5e1;
        }
    </style>
</head>
<body>

    <!-- Header info -->
    <div class="report-header d-flex justify-content-between align-items-end">
        <div>
            <h2 class="fw-bold">Smart Campus Complaint Portal</h2>
            <h4 class="text-secondary mb-0">Maintenance &amp; Performance Audit Report</h4>
        </div>
        <div class="text-end">
            <p class="mb-1"><strong>Generated On:</strong> <%= java.time.LocalDateTime.now().toString().substring(0,16).replace("T", " ") %></p>
            <p class="mb-0"><strong>Status:</strong> Official Report</p>
        </div>
    </div>

    <!-- Filters Summary -->
    <div class="mb-4 bg-light p-3 rounded">
        <h6 class="fw-bold mb-2">Selected Filters:</h6>
        <div class="d-flex flex-wrap gap-2">
            <span class="filter-badge"><strong>Date Range:</strong> <%= startDate %> to <%= endDate %></span>
            <span class="filter-badge"><strong>Category:</strong> <%= category %></span>
            <span class="filter-badge"><strong>Building:</strong> <%= building %></span>
            <span class="filter-badge"><strong>Status:</strong> <%= status %></span>
        </div>
    </div>

    <!-- Report Table -->
    <% if (reportData != null && !reportData.isEmpty()) { %>
        <table class="table table-bordered table-striped align-middle small">
            <thead class="table-dark">
                <tr>
                    <th>ID</th>
                    <th>Complaint Title</th>
                    <th>Category</th>
                    <th>Building &amp; Room</th>
                    <th>Priority</th>
                    <th>Status</th>
                    <th>Student Name</th>
                    <th>Worker Assigned</th>
                    <th>Date Raised</th>
                </tr>
            </thead>
            <tbody>
                <% for (Complaint c : reportData) { %>
                    <tr>
                        <td class="fw-bold">#<%= c.getComplaintId() %></td>
                        <td><%= c.getTitle() %></td>
                        <td><%= c.getCategory() %></td>
                        <td><%= c.getBuilding() %>, Rm <%= c.getRoomNo() %></td>
                        <td><%= c.getPriority() %></td>
                        <td><%= c.getStatus() %></td>
                        <td><%= c.getStudentName() %></td>
                        <td><%= c.getAssignedWorkerName() != null ? c.getAssignedWorkerName() : "Unassigned" %></td>
                        <td><%= c.getCreatedAt().toString().substring(0, 16) %></td>
                    </tr>
                <% } %>
            </tbody>
        </table>

        <!-- Signatures and Verification section -->
        <div class="row mt-5 pt-5">
            <div class="col-4 text-center">
                <hr style="width: 80%; margin: 0 auto 10px;">
                <p class="mb-0 fw-semibold small">Maintenance Inspector</p>
            </div>
            <div class="col-4 text-center">
                <hr style="width: 80%; margin: 0 auto 10px;">
                <p class="mb-0 fw-semibold small">Facilities Lead</p>
            </div>
            <div class="col-4 text-center">
                <hr style="width: 80%; margin: 0 auto 10px;">
                <p class="mb-0 fw-semibold small">Campus Director</p>
            </div>
        </div>
    <% } else { %>
        <div class="alert alert-secondary text-center py-5">
            No records found for the selected filters.
        </div>
    <% } %>

    <!-- Automatically open browser printer -->
    <script>
        window.onload = function() {
            setTimeout(function() {
                window.print();
            }, 500);
        };
    </script>
</body>
</html>
