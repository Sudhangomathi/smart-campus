<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Supervisor" %>
<%@ page import="model.Complaint" %>
<%@ page import="dao.ComplaintDAO" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    Supervisor supervisor = (Supervisor) session.getAttribute("supervisor");
    if (supervisor == null) {
        response.sendRedirect(request.getContextPath() + "/login?role=supervisor");
        return;
    }

    ComplaintDAO complaintDAO = new ComplaintDAO();

    // Filters for Report querying
    String startDate = request.getParameter("startDate");
    String endDate = request.getParameter("endDate");
    String category = request.getParameter("category");
    String building = request.getParameter("building");
    String status = request.getParameter("status");

    List<Complaint> reportData = new ArrayList<>();
    boolean isQueried = (startDate != null || endDate != null || category != null || building != null || status != null);
    
    if (isQueried) {
        reportData = complaintDAO.getComplaintsByDateRangeAndFilters(startDate, endDate, category, building, status);
    } else {
        // Default: last 30 days
        startDate = java.time.LocalDate.now().minusDays(30).toString();
        endDate = java.time.LocalDate.now().toString();
        category = "All";
        building = "All";
        status = "All";
        reportData = complaintDAO.getComplaintsByDateRangeAndFilters(startDate, endDate, category, building, status);
    }
    
    // Construct query parameter string for export links
    String exportParams = String.format("startDate=%s&endDate=%s&category=%s&building=%s&status=%s",
        startDate != null ? startDate : "",
        endDate != null ? endDate : "",
        category != null ? category : "",
        building != null ? building : "",
        status != null ? status : ""
    );
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
            <div class="glass-panel">
                <h4 class="fw-bold mb-1"><i class="bi bi-file-earmark-bar-graph-fill text-indigo me-2" style="color:#4f46e5;"></i> Campus Maintenance Reports</h4>
                <p class="text-secondary mb-4">Generate and export filtered lists of complaints. Analyze repair performance by category, building, or date ranges.</p>

                <!-- Filter Form -->
                <form action="reports.jsp" method="GET" class="row g-3 border-bottom pb-4 mb-4">
                    <div class="col-md-3 col-6">
                        <label for="startDate" class="form-label small fw-semibold">Start Date</label>
                        <input type="date" class="form-control" id="startDate" name="startDate" value="<%= startDate %>">
                    </div>
                    <div class="col-md-3 col-6">
                        <label for="endDate" class="form-label small fw-semibold">End Date</label>
                        <input type="date" class="form-control" id="endDate" name="endDate" value="<%= endDate %>">
                    </div>
                    <div class="col-md-2 col-6">
                        <label for="category" class="form-label small fw-semibold">Category</label>
                        <select class="form-select" id="category" name="category">
                            <option value="All">All Categories</option>
                            <option value="Electrical" <%= "Electrical".equals(category) ? "selected" : "" %>>Electrical</option>
                            <option value="Water Leakage" <%= "Water Leakage".equals(category) ? "selected" : "" %>>Water Leakage</option>
                            <option value="Internet" <%= "Internet".equals(category) ? "selected" : "" %>>Internet</option>
                            <option value="Furniture" <%= "Furniture".equals(category) ? "selected" : "" %>>Furniture</option>
                            <option value="Cleaning" <%= "Cleaning".equals(category) ? "selected" : "" %>>Cleaning</option>
                            <option value="Hostel" <%= "Hostel".equals(category) ? "selected" : "" %>>Hostel</option>
                            <option value="Washroom" <%= "Washroom".equals(category) ? "selected" : "" %>>Washroom</option>
                            <option value="Other" <%= "Other".equals(category) ? "selected" : "" %>>Other</option>
                        </select>
                    </div>
                    <div class="col-md-2 col-6">
                        <label for="building" class="form-label small fw-semibold">Building</label>
                        <select class="form-select" id="building" name="building">
                            <option value="All">All Buildings</option>
                            <option value="Main Academic Building" <%= "Main Academic Building".equals(building) ? "selected" : "" %>>Main Academic Building</option>
                            <option value="Science Block" <%= "Science Block".equals(building) ? "selected" : "" %>>Science Block</option>
                            <option value="IT Center" <%= "IT Center".equals(building) ? "selected" : "" %>>IT Center</option>
                            <option value="Hostel Block A" <%= "Hostel Block A".equals(building) ? "selected" : "" %>>Hostel Block A</option>
                            <option value="Sports Complex" <%= "Sports Complex".equals(building) ? "selected" : "" %>>Sports Complex</option>
                        </select>
                    </div>
                    <div class="col-md-2 col-6">
                        <label for="status" class="form-label small fw-semibold">Status</label>
                        <select class="form-select" id="status" name="status">
                            <option value="All">All Statuses</option>
                            <option value="Pending" <%= "Pending".equals(status) ? "selected" : "" %>>Pending</option>
                            <option value="Assigned" <%= "Assigned".equals(status) ? "selected" : "" %>>Assigned</option>
                            <option value="Accepted" <%= "Accepted".equals(status) ? "selected" : "" %>>Accepted</option>
                            <option value="In Progress" <%= "In Progress".equals(status) ? "selected" : "" %>>In Progress</option>
                            <option value="Completed" <%= "Completed".equals(status) ? "selected" : "" %>>Completed</option>
                            <option value="Rejected" <%= "Rejected".equals(status) ? "selected" : "" %>>Rejected</option>
                        </select>
                    </div>

                    <div class="col-12 d-flex justify-content-end gap-3 mt-4">
                        <button type="submit" class="btn btn-indigo text-white px-4" style="background-color: #4f46e5;"><i class="bi bi-search"></i> Generate Report</button>
                    </div>
                </form>

                <!-- Actions / Export Toolbar -->
                <% if (!reportData.isEmpty()) { %>
                    <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-2">
                        <h5 class="fw-bold m-0 text-secondary" style="font-size: 1rem;"><%= reportData.size() %> records found</h5>
                        <div class="d-flex gap-2">
                            <!-- CSV Download Link -->
                            <a href="<%= request.getContextPath() %>/supervisor/report?<%= exportParams %>&amp;format=csv" class="btn btn-sm btn-outline-success">
                                <i class="bi bi-file-earmark-excel"></i> Export to Excel
                            </a>
                            <!-- Print PDF Link -->
                            <a href="<%= request.getContextPath() %>/supervisor/report?<%= exportParams %>&amp;format=print" target="_blank" class="btn btn-sm btn-outline-secondary">
                                <i class="bi bi-printer"></i> Print / Save PDF
                            </a>
                        </div>
                    </div>

                    <!-- Report Table -->
                    <div class="table-responsive">
                        <table class="table table-bordered table-striped align-middle small">
                            <thead class="table-light">
                                <tr>
                                    <th>ID</th>
                                    <th>Title</th>
                                    <th>Category</th>
                                    <th>Building/Room</th>
                                    <th>Priority</th>
                                    <th>Status</th>
                                    <th>Reporter</th>
                                    <th>Worker</th>
                                    <th>Submitted At</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Complaint c : reportData) { %>
                                    <tr>
                                        <td class="fw-bold">#<%= c.getComplaintId() %></td>
                                        <td><%= c.getTitle() %></td>
                                        <td><%= c.getCategory() %></td>
                                        <td><%= c.getBuilding() %>, Rm <%= c.getRoomNo() %></td>
                                        <td>
                                            <span class="badge-priority <%= c.getPriority().toLowerCase() %>"><%= c.getPriority() %></span>
                                        </td>
                                        <td>
                                            <span class="badge-status <%= c.getStatus().replaceAll(" ", "-").toLowerCase() %>"><%= c.getStatus() %></span>
                                        </td>
                                        <td><%= c.getStudentName() %></td>
                                        <td><%= c.getAssignedWorkerName() != null ? c.getAssignedWorkerName() : "<span class='text-muted'>Unassigned</span>" %></td>
                                        <td><%= c.getCreatedAt().toString().substring(0, 16) %></td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                <% } else { %>
                    <div class="text-center py-5 text-secondary">
                        <i class="bi bi-clipboard-x fs-1 text-muted d-block mb-3"></i>
                        <p class="m-0">No complaints matching the selected filters were found in this date range.</p>
                    </div>
                <% } %>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
