<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Student" %>
<%@ page import="model.Complaint" %>
<%@ page import="dao.ComplaintDAO" %>
<%@ page import="dao.FeedbackDAO" %>
<%@ page import="model.Feedback" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.stream.Collectors" %>
<%
    Student student = (Student) session.getAttribute("student");
    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/login?role=student");
        return;
    }
    
    ComplaintDAO complaintDAO = new ComplaintDAO();
    FeedbackDAO feedbackDAO = new FeedbackDAO();
    
    List<Complaint> studentComplaints = complaintDAO.getComplaintsByStudent(student.getStudentId());
    
    int total = studentComplaints.size();
    long pending = studentComplaints.stream().filter(c -> "Pending".equalsIgnoreCase(c.getStatus())).count();
    long completed = studentComplaints.stream().filter(c -> "Completed".equalsIgnoreCase(c.getStatus()) || "Approved".equalsIgnoreCase(c.getStatus()) || "Closed".equalsIgnoreCase(c.getStatus())).count();
    
    // Count feedback entries
    List<Feedback> allFeedback = feedbackDAO.getAllFeedback();
    long feedbackCount = allFeedback.stream().filter(f -> f.getStudentId() == student.getStudentId()).count();
    
    // Get recent 3 complaints
    List<Complaint> recentComplaints = studentComplaints.stream().limit(3).collect(Collectors.toList());
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
                    <h3 class="fw-bold mb-1">Hello, <%= student.getName() %>!</h3>
                    <p class="text-secondary m-0">Welcome to your Smart Campus student dashboard. Monitor maintenance tasks or report new issues.</p>
                </div>
                <a href="<%= request.getContextPath() %>/jsp/student/raise_complaint.jsp" class="btn btn-indigo text-white px-4 py-2 rounded-3" style="background-color: #4f46e5;">
                    <i class="bi bi-plus-lg me-2"></i> File A Complaint
                </a>
            </div>

            <!-- Stats Row -->
            <div class="row g-4">
                <div class="col-md-3 col-sm-6">
                    <div class="stat-card">
                        <div class="stat-card-info">
                            <h3><%= total %></h3>
                            <p>Total Complaints</p>
                        </div>
                        <div class="stat-card-icon bg-primary bg-opacity-10 text-primary">
                            <i class="bi bi-card-text"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md-3 col-sm-6">
                    <div class="stat-card">
                        <div class="stat-card-info">
                            <h3><%= pending %></h3>
                            <p>Pending Issues</p>
                        </div>
                        <div class="stat-card-icon bg-warning bg-opacity-10 text-warning">
                            <i class="bi bi-hourglass-split"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md-3 col-sm-6">
                    <div class="stat-card">
                        <div class="stat-card-info">
                            <h3><%= completed %></h3>
                            <p>Completed Tasks</p>
                        </div>
                        <div class="stat-card-icon bg-success bg-opacity-10 text-success">
                            <i class="bi bi-check2-circle"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md-3 col-sm-6">
                    <div class="stat-card">
                        <div class="stat-card-info">
                            <h3><%= feedbackCount %></h3>
                            <p>Feedback Given</p>
                        </div>
                        <div class="stat-card-icon bg-info bg-opacity-10 text-info">
                            <i class="bi bi-star"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Recent Activity Table -->
            <div class="glass-panel">
                <div class="d-flex justify-content-between align-items-center mb-4">
                    <h5 class="fw-bold m-0"><i class="bi bi-activity me-2 text-indigo" style="color: #4f46e5;"></i> Recent Complaints</h5>
                    <a href="<%= request.getContextPath() %>/jsp/student/history.jsp" class="btn btn-link text-indigo p-0 small" style="color: #4f46e5;">View Full History</a>
                </div>

                <% if (recentComplaints.isEmpty()) { %>
                    <div class="text-center py-5 text-secondary">
                        <i class="bi bi-clipboard-x fs-1 text-muted d-block mb-3"></i>
                        <p class="m-0">You have not raised any campus complaints yet.</p>
                    </div>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="table align-middle border-0">
                            <thead>
                                <tr class="text-secondary small border-bottom">
                                    <th class="border-0 pb-3" style="width: 100px;">ID</th>
                                    <th class="border-0 pb-3">Complaint Details</th>
                                    <th class="border-0 pb-3">Category</th>
                                    <th class="border-0 pb-3">Priority</th>
                                    <th class="border-0 pb-3">Status</th>
                                    <th class="border-0 pb-3">Date Submitted</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Complaint c : recentComplaints) { %>
                                    <tr class="border-bottom" style="height: 70px;">
                                        <td class="fw-bold">#<%= c.getComplaintId() %></td>
                                        <td>
                                            <div class="fw-semibold text-truncate" style="max-width: 250px;"><%= c.getTitle() %></div>
                                            <div class="small text-secondary text-truncate" style="max-width: 250px;"><%= c.getBuilding() %>, Room <%= c.getRoomNo() %></div>
                                        </td>
                                        <td><%= c.getCategory() %></td>
                                        <td>
                                            <span class="badge-priority <%= c.getPriority().toLowerCase() %>"><%= c.getPriority() %></span>
                                        </td>
                                        <td>
                                            <span class="badge-status <%= c.getStatus().replaceAll(" ", "-").toLowerCase() %>"><%= c.getStatus() %></span>
                                        </td>
                                        <td class="text-secondary small">
                                            <%= c.getCreatedAt().toString().substring(0, 16) %>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
