<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Supervisor" %>
<%@ page import="dao.ComplaintDAO" %>
<%@ page import="dao.WorkerDAO" %>
<%@ page import="dao.ActivityLogDAO" %>
<%@ page import="dao.FeedbackDAO" %>
<%@ page import="java.util.Map" %>
<%@ page import="java.util.List" %>
<%@ page import="com.google.gson.Gson" %>
<%
    Supervisor supervisor = (Supervisor) session.getAttribute("supervisor");
    if (supervisor == null) {
        response.sendRedirect(request.getContextPath() + "/login?role=supervisor");
        return;
    }

    ComplaintDAO complaintDAO = new ComplaintDAO();
    WorkerDAO workerDAO = new WorkerDAO();
    ActivityLogDAO logDAO = new ActivityLogDAO();
    FeedbackDAO feedbackDAO = new FeedbackDAO();

    // Query counters
    Map<String, Integer> statusCounts = complaintDAO.getStatusCounts();
    int total = statusCounts.get("Total");
    int pending = statusCounts.get("Pending");
    int assigned = statusCounts.get("Assigned");
    int completed = statusCounts.get("Completed");
    
    int totalWorkers = workerDAO.getAllWorkers().size();
    int availableWorkers = workerDAO.getAvailableWorkers().size();
    double avgResTime = complaintDAO.getAverageResolutionTimeInHours();

    // Load logs
    List<Map<String, Object>> recentLogs = logDAO.getRecentLogs(5);

    // Convert chart data to JSON
    Gson gson = new Gson();
    String statusCountsJson = gson.toJson(statusCounts);
    String categoryDistributionJson = gson.toJson(complaintDAO.getCategoryDistribution());
    String weeklyTrendsJson = gson.toJson(complaintDAO.getWeeklyTrends());
%>
<jsp:include page="/jsp/common/header.jsp" />

<div class="app-container">
    <!-- Sidebar -->
    <jsp:include page="/jsp/common/sidebar.jsp" />

    <!-- Main Content Area -->
    <div class="main-content">
        <!-- Top Navbar -->
        <jsp:include page="/jsp/common/navbar.jsp" />

        <div class="content-wrapper">
            <!-- Greeting Header -->
            <div class="glass-panel py-4 px-5">
                <h3 class="fw-bold mb-1">Welcome back, <%= supervisor.getName() %>!</h3>
                <p class="text-secondary m-0">Review real-time complaint analytics, monitor staff allocations, and resolve campus maintenance bottlenecks.</p>
            </div>

            <!-- Dashboard Stats Cards -->
            <div class="row g-4">
                <div class="col-md col-sm-6">
                    <div class="stat-card">
                        <div class="stat-card-info">
                            <h3><%= total %></h3>
                            <p>Total Complaints</p>
                        </div>
                        <div class="stat-card-icon bg-primary bg-opacity-10 text-primary">
                            <i class="bi bi-folder2-open"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md col-sm-6">
                    <div class="stat-card">
                        <div class="stat-card-info">
                            <h3><%= totalWorkers %></h3>
                            <p>Total Workers</p>
                        </div>
                        <div class="stat-card-icon bg-info bg-opacity-10 text-info">
                            <i class="bi bi-people-fill"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md col-sm-6">
                    <div class="stat-card">
                        <div class="stat-card-info">
                            <h3><%= pending %></h3>
                            <p>Pending Issues</p>
                        </div>
                        <div class="stat-card-icon bg-warning bg-opacity-10 text-warning">
                            <i class="bi bi-shield-fill-exclamation"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md col-sm-6">
                    <div class="stat-card">
                        <div class="stat-card-info">
                            <h3><%= assigned %></h3>
                            <p>Assigned Jobs</p>
                        </div>
                        <div class="stat-card-icon bg-primary bg-opacity-10 text-primary" style="color: #6366f1;">
                            <i class="bi bi-person-workspace"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md col-sm-6">
                    <div class="stat-card">
                        <div class="stat-card-info">
                            <h3><%= completed %></h3>
                            <p>Completed Tasks</p>
                        </div>
                        <div class="stat-card-icon bg-success bg-opacity-10 text-success">
                            <i class="bi bi-check2-all"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Availability & Resolution time widgets -->
            <div class="row g-4">
                <div class="col-md-6">
                    <div class="glass-panel h-100 py-4">
                        <h6 class="fw-bold mb-3"><i class="bi bi-clipboard-pulse text-indigo me-2"></i> Maintenance Health Index</h6>
                        <div class="d-flex align-items-center justify-content-between p-3 bg-light rounded-3 mb-3">
                            <div>
                                <span class="d-block small text-secondary fw-semibold">Average Resolution Time</span>
                                <span class="h4 fw-bold mb-0"><%= String.format("%.1f", avgResTime) %> hrs</span>
                            </div>
                            <i class="bi bi-clock-history fs-2 text-indigo"></i>
                        </div>
                        <div class="d-flex align-items-center justify-content-between p-3 bg-light rounded-3">
                            <div>
                                <span class="d-block small text-secondary fw-semibold">Staff Availability</span>
                                <span class="h4 fw-bold mb-0"><%= availableWorkers %> / <%= totalWorkers %> Available</span>
                            </div>
                            <i class="bi bi-person-check-fill fs-2 text-success"></i>
                        </div>
                    </div>
                </div>

                <!-- Recent Audit Logs -->
                <div class="col-md-6">
                    <div class="glass-panel h-100 py-4">
                        <h6 class="fw-bold mb-3"><i class="bi bi-clock-history text-indigo me-2"></i> Recent Activity Logs</h6>
                        <% if (recentLogs.isEmpty()) { %>
                            <p class="text-muted small text-center my-4">No logged activity logs</p>
                        <% } else { %>
                            <ul class="list-unstyled mb-0 d-flex flex-column gap-2 small">
                                <% for (Map<String, Object> log : recentLogs) { %>
                                    <li class="p-2 border-bottom d-flex justify-content-between align-items-center">
                                        <div>
                                            <span class="fw-semibold text-capitalize text-indigo"><%= log.get("email") != null ? log.get("email").toString().split("@")[0] : "System" %>:</span>
                                            <span><%= log.get("action") %></span>
                                        </div>
                                        <span class="text-muted small fs-6"><%= log.get("timestamp").toString().substring(11, 16) %></span>
                                    </li>
                                <% } %>
                            </ul>
                        <% } %>
                    </div>
                </div>
            </div>

            <!-- Worker Performance & Recent Feedback Section -->
            <div class="row g-4">
                <!-- Worker Performance Board -->
                <div class="col-lg-6">
                    <div class="glass-panel h-100 py-4">
                        <h6 class="fw-bold mb-3"><i class="bi bi-award-fill text-indigo me-2"></i> Worker Performance Metrics</h6>
                        <div class="table-responsive">
                            <table class="table table-sm align-middle small mb-0">
                                <thead>
                                    <tr class="text-secondary border-bottom">
                                        <th class="border-0 pb-2">Name</th>
                                        <th class="border-0 pb-2">Specialty</th>
                                        <th class="border-0 pb-2 text-center">Status</th>
                                        <th class="border-0 pb-2 text-center">Solved</th>
                                        <th class="border-0 pb-2 text-end">Avg Rating</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <%
                                        List<Map<String, Object>> workerPerf = workerDAO.getDetailedWorkerPerformance();
                                        if (workerPerf.isEmpty()) {
                                    %>
                                        <tr>
                                            <td colspan="5" class="text-center text-muted py-3">No worker performance metrics recorded.</td>
                                        </tr>
                                    <% } else {
                                        for (Map<String, Object> wp : workerPerf) {
                                            double avgRating = (Double) wp.get("avgRating");
                                    %>
                                        <tr class="border-bottom">
                                            <td class="fw-semibold py-2"><%= wp.get("name") %></td>
                                            <td><%= wp.get("specialization") %></td>
                                            <td class="text-center">
                                                <span class="badge rounded-pill bg-<%= "available".equals(wp.get("status")) ? "success" : "warning" %> bg-opacity-10 text-<%= "available".equals(wp.get("status")) ? "success" : "warning" %>" style="font-size:9px;">
                                                    <%= wp.get("status") %>
                                                </span>
                                            </td>
                                            <td class="text-center fw-bold text-dark"><%= wp.get("completedJobs") %></td>
                                            <td class="text-end text-warning">
                                                <% if (avgRating > 0) { %>
                                                    <i class="bi bi-star-fill text-warning me-1"></i><%= String.format("%.1f", avgRating) %>
                                                <% } else { %>
                                                    <span class="text-muted small">-</span>
                                                <% } %>
                                            </td>
                                        </tr>
                                    <% 
                                        } 
                                    } 
                                    %>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>

                <!-- Recent Student Feedback Highlights -->
                <div class="col-lg-6">
                    <div class="glass-panel h-100 py-4">
                        <h6 class="fw-bold mb-3"><i class="bi bi-chat-heart-fill text-indigo me-2"></i> Student Feedback Feed</h6>
                        <div class="d-flex flex-column gap-3 scrollable-feed" style="max-height: 230px; overflow-y: auto; padding-right: 5px;">
                            <%
                                List<model.Feedback> feedbackList = feedbackDAO.getAllFeedback();
                                if (feedbackList.isEmpty()) {
                            %>
                                <p class="text-muted small text-center my-4">No student feedback comments submitted yet.</p>
                            <% } else {
                                for (model.Feedback fb : feedbackList) {
                            %>
                                <div class="bg-light bg-opacity-50 p-3 rounded-4 border">
                                    <div class="d-flex justify-content-between align-items-center mb-1">
                                        <span class="fw-semibold text-dark small"><%= fb.getStudentName() %></span>
                                        <span class="text-warning small">
                                            <% for (int i = 1; i <= 5; i++) { %>
                                                <i class="bi <%= i <= fb.getRating() ? "bi-star-fill" : "bi-star" %>"></i>
                                            <% } %>
                                        </span>
                                    </div>
                                    <div class="text-secondary small mb-1">
                                        Complaint: <strong class="text-indigo">#<%= fb.getComplaintId() %> <%= fb.getComplaintTitle() %></strong>
                                    </div>
                                    <div class="small italic font-monospace text-secondary m-0">"<%= fb.getFeedback() %>"</div>
                                </div>
                            <% 
                                } 
                            } 
                            %>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Charts Section -->
            <div class="row g-4">
                <!-- Pie Chart for status -->
                <div class="col-lg-4">
                    <div class="glass-panel h-100">
                        <h6 class="fw-bold mb-4 text-center">Status Distribution</h6>
                        <div style="height: 250px; position: relative;">
                            <canvas id="statusChart"></canvas>
                        </div>
                    </div>
                </div>

                <!-- Bar Chart for categories -->
                <div class="col-lg-5">
                    <div class="glass-panel h-100">
                        <h6 class="fw-bold mb-4 text-center">Category Distribution</h6>
                        <div style="height: 250px; position: relative;">
                            <canvas id="categoryChart"></canvas>
                        </div>
                    </div>
                </div>

                <!-- Line Chart for weekly trends -->
                <div class="col-lg-3">
                    <div class="glass-panel h-100">
                        <h6 class="fw-bold mb-4 text-center">Weekly Complaint Trends</h6>
                        <div style="height: 250px; position: relative;">
                            <canvas id="trendsChart"></canvas>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Chart Initiation Scripts -->
<script>
    // Injected JSON data
    const statusData = <%= statusCountsJson %>;
    const categoryData = <%= categoryDistributionJson %>;
    const trendsData = <%= weeklyTrendsJson %>;

    document.addEventListener("DOMContentLoaded", () => {
        // 1. Status distribution Pie Chart
        const statusCtx = document.getElementById('statusChart').getContext('2d');
        new Chart(statusCtx, {
            type: 'pie',
            data: {
                labels: ['Pending', 'Assigned', 'Accepted', 'In Progress', 'Completed', 'Rejected'],
                datasets: [{
                    data: [
                        statusData.Pending || 0, 
                        statusData.Assigned || 0, 
                        statusData.Accepted || 0, 
                        statusData.In_Progress || statusData['In Progress'] || 0, 
                        statusData.Completed || 0, 
                        statusData.Rejected || 0
                    ],
                    backgroundColor: ['#c8e6c9', '#a5d6a7', '#81c784', '#4caf50', '#2e7d32', '#757575'],
                    borderWidth: 1
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: { position: 'bottom', labels: { boxWidth: 12, font: { size: 10 } } }
                }
            }
        });

        // 2. Category distribution Bar Chart
        const catLabels = Object.keys(categoryData);
        const catCounts = Object.values(categoryData);
        const catCtx = document.getElementById('categoryChart').getContext('2d');
        new Chart(catCtx, {
            type: 'bar',
            data: {
                labels: catLabels,
                datasets: [{
                    label: 'Complaints',
                    data: catCounts,
                    backgroundColor: '#2e7d32',
                    borderRadius: 6
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    x: { grid: { display: false }, ticks: { font: { size: 9 } } },
                    y: { beginAtZero: true, ticks: { precision: 0 } }
                }
            }
        });

        // 3. Weekly Trends Line Chart
        const trendLabels = Object.keys(trendsData);
        const trendCounts = Object.values(trendsData);
        const trendsCtx = document.getElementById('trendsChart').getContext('2d');
        new Chart(trendsCtx, {
            type: 'line',
            data: {
                labels: trendLabels.map(d => d.substring(5)), // Format to MM-DD
                datasets: [{
                    label: 'Raised',
                    data: trendCounts,
                    borderColor: '#2e7d32',
                    backgroundColor: 'rgba(46, 125, 50, 0.1)',
                    fill: true,
                    tension: 0.3
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: { legend: { display: false } },
                scales: {
                    x: { grid: { display: false }, ticks: { font: { size: 9 } } },
                    y: { beginAtZero: true, ticks: { precision: 0 } }
                }
            }
        });
    });
</script>

<jsp:include page="/jsp/common/footer.jsp" />
