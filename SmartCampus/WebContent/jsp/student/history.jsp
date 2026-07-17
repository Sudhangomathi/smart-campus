<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Student" %>
<%@ page import="model.Complaint" %>
<%@ page import="dao.ComplaintDAO" %>
<%@ page import="dao.FeedbackDAO" %>
<%@ page import="model.Feedback" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.ArrayList" %>
<%
    Student student = (Student) session.getAttribute("student");
    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/login?role=student");
        return;
    }

    ComplaintDAO complaintDAO = new ComplaintDAO();
    FeedbackDAO feedbackDAO = new FeedbackDAO();

    List<Complaint> complaints = complaintDAO.getComplaintsByStudent(student.getStudentId());
    
    // Status text parsing helper
    String statusMsg = request.getParameter("msg");
    String errMsg = request.getParameter("error");
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
            <!-- Messages -->
            <% if (statusMsg != null) { %>
                <div class="alert alert-success alert-dismissible fade show bg-success bg-opacity-10 text-success border-success border-opacity-10" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> <%= statusMsg %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>
            <% if (errMsg != null) { %>
                <div class="alert alert-danger alert-dismissible fade show bg-danger bg-opacity-10 text-danger border-danger border-opacity-10" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= errMsg %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>

            <div class="glass-panel">
                <h4 class="fw-bold mb-1"><i class="bi bi-clock-history text-indigo me-2" style="color: #4f46e5;"></i> My Complaint History</h4>
                <p class="text-secondary mb-4">View status updates, details of assigned repair workers, and submit feedback for completed work.</p>

                <% if (complaints.isEmpty()) { %>
                    <div class="text-center py-5 text-secondary">
                        <i class="bi bi-clipboard-x fs-1 text-muted d-block mb-3"></i>
                        <p class="m-0">You have no complaints in your history yet.</p>
                        <a href="raise_complaint.jsp" class="btn btn-indigo text-white mt-3" style="background-color: #4f46e5;">Raise First Complaint</a>
                    </div>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="table align-middle border-0">
                            <thead>
                                <tr class="text-secondary small border-bottom">
                                    <th class="border-0 pb-3" style="width: 80px;">ID</th>
                                    <th class="border-0 pb-3">Title</th>
                                    <th class="border-0 pb-3">Building &amp; Room</th>
                                    <th class="border-0 pb-3">Category</th>
                                    <th class="border-0 pb-3">Priority</th>
                                    <th class="border-0 pb-3">Status</th>
                                    <th class="border-0 pb-3 text-end">Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Complaint c : complaints) { 
                                    Feedback fb = feedbackDAO.getFeedbackByComplaintId(c.getComplaintId());
                                    boolean hasFeedback = (fb != null);
                                %>
                                    <tr class="border-bottom" style="height: 75px;">
                                        <td class="fw-bold">#<%= c.getComplaintId() %></td>
                                        <td>
                                            <div class="fw-semibold"><%= c.getTitle() %></div>
                                            <span class="text-muted small">Submitted: <%= c.getCreatedAt().toString().substring(0, 10) %></span>
                                        </td>
                                        <td><%= c.getBuilding() %>, Room <%= c.getRoomNo() %></td>
                                        <td><%= c.getCategory() %></td>
                                        <td>
                                            <span class="badge-priority <%= c.getPriority().toLowerCase() %>"><%= c.getPriority() %></span>
                                        </td>
                                        <td>
                                            <span class="badge-status <%= c.getStatus().replaceAll(" ", "-").toLowerCase() %>"><%= c.getStatus() %></span>
                                        </td>
                                        <td class="text-end">
                                            <div class="d-inline-flex gap-2">
                                                <button type="button" class="btn btn-sm btn-outline-indigo px-3" 
                                                        style="color: #4f46e5; border-color: #4f46e5;"
                                                        onclick="showTrackPanel(<%= c.getComplaintId() %>)">
                                                    <i class="bi bi-activity"></i> Track
                                                </button>
                                                
                                                <% if ("Completed".equals(c.getStatus()) && !hasFeedback) { %>
                                                     <button type="button" class="btn btn-sm btn-success px-3" 
                                                             onclick="openFeedbackModal(<%= c.getComplaintId() %>, '<%= c.getTitle().replace("'", "\\'") %>')">
                                                         <i class="bi bi-star"></i> Rate
                                                     </button>
                                                 <% } %>
                                            </div>
                                        </td>
                                    </tr>
                                    
                                    <!-- Detailed Tracking Panel for each row (hidden by default) -->
                                    <tr id="track-row-<%= c.getComplaintId() %>" class="d-none bg-light bg-opacity-25 no-print">
                                        <td colspan="7" class="p-4 border-bottom">
                                            <div class="row g-4">
                                                <!-- Tracking and Description -->
                                                <div class="col-lg-7">
                                                    <h6 class="fw-bold mb-3 text-indigo" style="color: #4f46e5;">Progress Tracker</h6>
                                                    
                                                    <!-- Progress Bar Widget -->
                                                    <%
                                                        int step = 1;
                                                        if ("Assigned".equals(c.getStatus())) step = 2;
                                                        else if ("Accepted".equals(c.getStatus()) || "In Progress".equals(c.getStatus())) step = 3;
                                                        else if ("Completed".equals(c.getStatus()) || "Closed".equals(c.getStatus())) step = 4;
                                                        else if ("Rejected".equals(c.getStatus())) step = 0; // Rejected or other fallback
                                                        
                                                        double pct = 0;
                                                        if (step == 1) pct = 0;
                                                        else if (step == 2) pct = 33.33;
                                                        else if (step == 3) pct = 66.66;
                                                        else if (step == 4) pct = 100;
                                                    %>
                                                    <div class="progress-track">
                                                        <div class="progress-track-fill" style="width: <%= pct %>%;"></div>
                                                        <div class="progress-step <%= step >= 1 ? "active" : "" %>">
                                                            <div class="progress-step-dot"></div>
                                                            <div class="progress-step-label">Raised</div>
                                                        </div>
                                                        <div class="progress-step <%= step >= 2 ? "active" : "" %>">
                                                            <div class="progress-step-dot"></div>
                                                            <div class="progress-step-label">Assigned</div>
                                                        </div>
                                                        <div class="progress-step <%= step >= 3 ? "active" : "" %>">
                                                            <div class="progress-step-dot"></div>
                                                            <div class="progress-step-label">In Progress</div>
                                                        </div>
                                                        <div class="progress-step <%= step >= 4 ? "active" : "" %>">
                                                            <div class="progress-step-dot"></div>
                                                            <div class="progress-step-label">Completed</div>
                                                        </div>
                                                    </div>

                                                    <div class="mt-4">
                                                        <h6 class="fw-bold mb-2">Issue Description</h6>
                                                        <p class="text-secondary small m-0"><%= c.getDescription() %></p>
                                                    </div>

                                                    <!-- Images display -->
                                                    <%
                                                        // Load images list
                                                        List<String> images = complaintDAO.getComplaintImages(c.getComplaintId());
                                                        if (!images.isEmpty()) {
                                                    %>
                                                        <div class="mt-4">
                                                            <h6 class="fw-bold mb-2">Uploaded Images (Complaint &amp; Repair Proofs)</h6>
                                                            <div class="d-flex flex-wrap gap-2">
                                                                <% for (String img : images) { %>
                                                                    <a href="<%= img %>" target="_blank" class="image-preview-card border rounded" style="width: 80px; height: 80px; display: block;">
                                                                        <img src="<%= img %>" style="width:100%; height:100%; object-fit:cover;" />
                                                                    </a>
                                                                <% } %>
                                                            </div>
                                                        </div>
                                                    <% } %>
                                                </div>

                                                <!-- Location and Worker details column -->
                                                <div class="col-lg-5">
                                                    <div class="floating-detail-panel h-100 m-0">
                                                        <h6 class="fw-bold mb-3"><i class="bi bi-info-circle-fill me-2 text-primary"></i> Assignment &amp; Details</h6>
                                                        
                                                        <ul class="list-unstyled small mb-4 d-flex flex-column gap-2">
                                                            <li><strong>Location:</strong> <%= c.getBuilding() %>, <%= c.getBlock() %>, <%= c.getFloor() %>, Room <%= c.getRoomNo() %></li>
                                                            <% if (c.getLatitude() != null && c.getLongitude() != null) { %>
                                                                <li><strong>GPS Coords:</strong> <%= c.getLatitude() %>, <%= c.getLongitude() %></li>
                                                            <% } %>
                                                            <li><strong>Worker Assigned:</strong> <%= c.getAssignedWorkerName() != null ? c.getAssignedWorkerName() : "<span class='text-muted'>Pending Allocation</span>" %></li>
                                                            <% if (c.getAssignmentRemarks() != null) { %>
                                                                <li><strong>Repair Remarks:</strong> <%= c.getAssignmentRemarks() %></li>
                                                            <% } %>
                                                        </ul>

                                                        <!-- Show Feedback if given -->
                                                        <% if (hasFeedback) { %>
                                                            <div class="border-top pt-3 mt-3">
                                                                <h6 class="fw-bold mb-2 text-success"><i class="bi bi-star-fill me-2 text-warning"></i> Feedback Submitted</h6>
                                                                <div class="mb-2 text-warning fs-5">
                                                                    <% for (int i = 1; i <= 5; i++) { %>
                                                                        <i class="bi <%= i <= fb.getRating() ? "bi-star-fill" : "bi-star" %>"></i>
                                                                    <% } %>
                                                                </div>
                                                                <p class="text-secondary small mb-1"><strong>Satisfaction:</strong> <%= fb.getSatisfactionLevel() %></p>
                                                                <p class="text-secondary small italic m-0">"<%= fb.getFeedback() %>"</p>
                                                            </div>
                                                        <% } %>

                                                        <div class="mt-3 d-flex gap-2">
                                                            <button class="btn btn-sm btn-outline-secondary" onclick="window.print()"><i class="bi bi-printer"></i> Print Report</button>
                                                            <button class="btn btn-sm btn-light" onclick="hideTrackPanel(<%= c.getComplaintId() %>)">Collapse</button>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
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

<!-- Feedback Star Rating Modal -->
<div class="modal fade" id="feedbackModal" tabindex="-1" aria-labelledby="feedbackModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 rounded-4 shadow">
            <div class="modal-header border-0 bg-light rounded-top-4">
                <h5 class="modal-title fw-bold" id="feedbackModalLabel">Submit Performance Rating</h5>
                <button type="button" class="btn-close" data-bs-dismiss="alert" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="<%= request.getContextPath() %>/student" method="POST">
                <input type="hidden" name="action" value="feedback">
                <input type="hidden" id="modalComplaintId" name="complaintId" value="">
                
                <div class="modal-body p-4">
                    <p class="text-secondary mb-3 small">Please rate the campus repair speed and worker behavior for the complaint: <strong id="modalComplaintTitle"></strong>.</p>
                    
                    <!-- Star Rating Group -->
                    <div class="mb-4">
                        <label class="form-label small fw-semibold d-block">Service Rating</label>
                        <div class="star-rating">
                            <input type="radio" id="star5" name="rating" value="5" required />
                            <label for="star5" class="bi bi-star-fill" title="Excellent (5 stars)"></label>
                            <input type="radio" id="star4" name="rating" value="4" />
                            <label for="star4" class="bi bi-star-fill" title="Good (4 stars)"></label>
                            <input type="radio" id="star3" name="rating" value="3" />
                            <label for="star3" class="bi bi-star-fill" title="Satisfactory (3 stars)"></label>
                            <input type="radio" id="star2" name="rating" value="2" />
                            <label for="star2" class="bi bi-star-fill" title="Poor (2 stars)"></label>
                            <input type="radio" id="star1" name="rating" value="1" />
                            <label for="star1" class="bi bi-star-fill" title="Terrible (1 star)"></label>
                        </div>
                    </div>

                    <!-- Satisfaction Dropdown -->
                    <div class="mb-3">
                        <label for="satisfactionLevel" class="form-label small fw-semibold">Satisfaction Level</label>
                        <select class="form-select" id="satisfactionLevel" name="satisfactionLevel" required>
                            <option value="Highly Satisfied">Highly Satisfied</option>
                            <option value="Satisfied" selected>Satisfied</option>
                            <option value="Neutral">Neutral</option>
                            <option value="Unsatisfied">Unsatisfied</option>
                            <option value="Highly Unsatisfied">Highly Unsatisfied</option>
                        </select>
                    </div>

                    <!-- Feedback Comment -->
                    <div class="mb-3">
                        <label for="comment" class="form-label small fw-semibold">Remarks &amp; Comments</label>
                        <textarea class="form-control" id="comment" name="comment" rows="3" placeholder="Write any specific feedback for the repair crew here..." required></textarea>
                    </div>
                </div>

                <div class="modal-footer border-0 p-3 bg-light rounded-bottom-4">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-indigo text-white px-4" style="background-color: #4f46e5;">Submit Rating</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function showTrackPanel(id) {
        // Hide other open tracking rows
        document.querySelectorAll("tr[id^='track-row-']").forEach(tr => {
            if (tr.id !== 'track-row-' + id) tr.classList.add("d-none");
        });
        
        const row = document.getElementById("track-row-" + id);
        if (row) {
            row.classList.toggle("d-none");
        }
    }
    
    function hideTrackPanel(id) {
        const row = document.getElementById("track-row-" + id);
        if (row) {
            row.classList.add("d-none");
        }
    }

    function openFeedbackModal(complaintId, title) {
        document.getElementById("modalComplaintId").value = complaintId;
        document.getElementById("modalComplaintTitle").textContent = title;
        
        // Show bootstrap modal
        var myModal = new bootstrap.Modal(document.getElementById('feedbackModal'), {
            keyboard: false
        });
        myModal.show();
    }
</script>

<jsp:include page="/jsp/common/footer.jsp" />
