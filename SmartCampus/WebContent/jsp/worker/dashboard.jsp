<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Worker" %>
<%@ page import="model.Complaint" %>
<%@ page import="model.CampusBlueprint" %>
<%@ page import="dao.ComplaintDAO" %>
<%@ page import="dao.AssignmentDAO" %>
<%@ page import="dao.FeedbackDAO" %>
<%@ page import="model.Feedback" %>
<%@ page import="model.Assignment" %>
<%@ page import="java.util.List" %>
<%@ page import="java.util.stream.Collectors" %>
<%@ page import="java.time.LocalDate" %>
<%
    Worker worker = (Worker) session.getAttribute("worker");
    if (worker == null) {
        response.sendRedirect(request.getContextPath() + "/login?role=worker");
        return;
    }

    ComplaintDAO complaintDAO = new ComplaintDAO();
    AssignmentDAO assignmentDAO = new AssignmentDAO();
    FeedbackDAO feedbackDAO = new FeedbackDAO();
    
    dao.CampusBlueprintDAO blueprintDAO = new dao.CampusBlueprintDAO();
    CampusBlueprint blueprint = blueprintDAO.getLatestBlueprint();
    String blueprintPath = (blueprint != null) ? blueprint.getFilePath() : request.getContextPath() + "/images/kit_campus_blueprint.png";

    List<Complaint> myJobs = complaintDAO.getComplaintsByWorker(worker.getWorkerId());

    // Calculate statistics
    long assignedCount = myJobs.stream().filter(c -> "Assigned".equalsIgnoreCase(c.getStatus())).count();
    long inProgressCount = myJobs.stream().filter(c -> "Accepted".equalsIgnoreCase(c.getStatus()) || "In Progress".equalsIgnoreCase(c.getStatus())).count();
    
    // Count completed jobs today
    LocalDate today = LocalDate.now();
    long completedToday = 0;
    for (Complaint c : myJobs) {
        if ("Completed".equalsIgnoreCase(c.getStatus())) {
            Assignment a = assignmentDAO.getAssignmentByComplaintId(c.getComplaintId());
            if (a != null && a.getCompletedDate() != null) {
                LocalDate compDate = a.getCompletedDate().toLocalDateTime().toLocalDate();
                if (compDate.equals(today)) {
                    completedToday++;
                }
            }
        }
    }

    // Filter complaints to show only ACTIVE ones (Pending acceptance, In Progress)
    List<Complaint> activeJobs = myJobs.stream()
        .filter(c -> !"Completed".equalsIgnoreCase(c.getStatus()) && !"Rejected".equalsIgnoreCase(c.getStatus()))
        .collect(Collectors.toList());

    String successMsg = request.getParameter("msg");
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
            <!-- Alerts -->
            <% if (successMsg != null) { %>
                <div class="alert alert-success alert-dismissible fade show bg-success bg-opacity-10 text-success border-success border-opacity-10" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> <%= successMsg %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>
            <% if (errMsg != null) { %>
                <div class="alert alert-danger alert-dismissible fade show bg-danger bg-opacity-10 text-danger border-danger border-opacity-10" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= errMsg %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>

            <!-- Greeting Panel -->
            <div class="glass-panel py-4 px-5">
                <h3 class="fw-bold mb-1">Worker Hub - Hello, <%= worker.getName() %>!</h3>
                <p class="text-secondary m-0">Specialization Area: <strong class="text-indigo"><%= worker.getSpecialization() %></strong>. Manage your assigned tasks, navigate to issue maps, and log completion reports.</p>
            </div>

            <!-- Stats Row -->
            <div class="row g-4">
                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="stat-card-info">
                            <h3><%= assignedCount %></h3>
                            <p>Assigned Jobs</p>
                        </div>
                        <div class="stat-card-icon bg-warning bg-opacity-10 text-warning">
                            <i class="bi bi-bell-fill"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="stat-card-info">
                            <h3><%= inProgressCount %></h3>
                            <p>In Progress / Accepted</p>
                        </div>
                        <div class="stat-card-icon bg-primary bg-opacity-10 text-primary">
                            <i class="bi bi-wrench-adjustable"></i>
                        </div>
                    </div>
                </div>

                <div class="col-md-4">
                    <div class="stat-card">
                        <div class="stat-card-info">
                            <h3><%= completedToday %></h3>
                            <p>Completed Today</p>
                        </div>
                        <div class="stat-card-icon bg-success bg-opacity-10 text-success">
                            <i class="bi bi-check-circle-fill"></i>
                        </div>
                    </div>
                </div>
            </div>

            <!-- Jobs List -->
            <div class="glass-panel">
                <h5 class="fw-bold mb-4"><i class="bi bi-card-checklist text-indigo me-2"></i> Active Job Queue</h5>

                <% if (activeJobs.isEmpty()) { %>
                    <div class="text-center py-5 text-secondary">
                        <i class="bi bi-emoji-smile fs-1 text-muted d-block mb-3"></i>
                        <p class="m-0">Great job! You have no pending or active repair jobs in your queue right now.</p>
                    </div>
                <% } else { %>
                    <div class="d-flex flex-column gap-4">
                        <% for (Complaint c : activeJobs) { 
                            boolean isAssigned = "Assigned".equalsIgnoreCase(c.getStatus());
                            boolean isAccepted = "Accepted".equalsIgnoreCase(c.getStatus());
                            boolean isInProgress = "In Progress".equalsIgnoreCase(c.getStatus());
                        %>
                            <div class="border rounded-4 p-4 bg-light bg-opacity-25 shadow-sm">
                                <div class="d-flex justify-content-between align-items-start flex-wrap gap-2 mb-3">
                                    <div>
                                        <h5 class="fw-bold m-0 text-indigo">#<%= c.getComplaintId() %>: <%= c.getTitle() %></h5>
                                        <span class="text-muted small">Category: <%= c.getCategory() %> | Priority: <strong><%= c.getPriority() %></strong></span>
                                    </div>
                                    <span class="badge-status <%= c.getStatus().replaceAll(" ", "-").toLowerCase() %>"><%= c.getStatus() %></span>
                                </div>

                                <div class="row g-4 small">
                                    <div class="col-md-6 border-end">
                                        <h6 class="fw-bold mb-2">Complaint Details</h6>
                                        <div class="mb-1"><strong>Building:</strong> <%= c.getBuilding() %>, <%= c.getBlock() %>, <%= c.getFloor() %>, Room <%= c.getRoomNo() %></div>
                                        <% if (c.getLatitude() != null && c.getLongitude() != null) { %>
                                            <div class="mb-2">
                                                <button type="button" class="btn btn-xs btn-outline-indigo text-indigo border-indigo border-opacity-50 py-0 px-2 rounded small" style="font-size: 11px;"
                                                        onclick="showComplaintBlueprintSpot(<%= c.getLatitude() %>, <%= c.getLongitude() %>, '<%= c.getTitle().replace("'", "\\'") %>', '<%= c.getBuilding().replace("'", "\\'") %> Room <%= c.getRoomNo().replace("'", "\\'") %>')">
                                                    <i class="bi bi-geo-alt-fill text-danger"></i> Locate on Blueprint
                                                </button>
                                            </div>
                                        <% } %>

                                        <div class="mb-2"><strong>Student:</strong> <%= c.getStudentName() %></div>
                                        <div class="text-secondary p-2 bg-light rounded"><%= c.getDescription() %></div>

                                        <!-- Load student images -->
                                        <%
                                            List<String> images = complaintDAO.getComplaintImages(c.getComplaintId());
                                            if (!images.isEmpty()) {
                                        %>
                                            <div class="mt-3">
                                                <strong>Attached Photos:</strong>
                                                <div class="d-flex flex-wrap gap-2 mt-1">
                                                    <% for (String img : images) { %>
                                                        <a href="<%= img %>" target="_blank" class="image-preview-card border rounded" style="width: 60px; height: 60px; display:block;">
                                                            <img src="<%= img %>" style="width:100%; height:100%; object-fit:cover;" />
                                                        </a>
                                                    <% } %>
                                                </div>
                                            </div>
                                        <% } %>
                                    </div>

                                    <div class="col-md-6">
                                        <h6 class="fw-bold mb-2">Action Controls</h6>
                                        
                                        <!-- If Assigned (Pending Acceptance) -->
                                        <% if (isAssigned) { %>
                                            <div class="d-flex gap-2">
                                                <form action="<%= request.getContextPath() %>/worker" method="POST" class="w-100">
                                                    <input type="hidden" name="action" value="updateStatus">
                                                    <input type="hidden" name="status" value="Accepted">
                                                    <input type="hidden" name="complaintId" value="<%= c.getComplaintId() %>">
                                                    <button type="submit" class="btn btn-sm btn-success w-100 py-2"><i class="bi bi-check2"></i> Accept Job</button>
                                                </form>
                                                
                                                <button class="btn btn-sm btn-outline-danger w-100 py-2" onclick="openRejectModal(<%= c.getComplaintId() %>)">
                                                    <i class="bi bi-x-lg"></i> Decline Job
                                                </button>
                                            </div>
                                        <% } %>

                                        <!-- If Accepted (Worker needs to start repair work) -->
                                        <% if (isAccepted) { %>
                                            <div class="d-flex flex-column gap-2">
                                                <form action="<%= request.getContextPath() %>/worker" method="POST">
                                                    <input type="hidden" name="action" value="updateStatus">
                                                    <input type="hidden" name="status" value="In Progress">
                                                    <input type="hidden" name="complaintId" value="<%= c.getComplaintId() %>">
                                                    <button type="submit" class="btn btn-sm btn-indigo text-white w-100 py-2" style="background-color: #4f46e5;"><i class="bi bi-play-fill"></i> Start Repair Work</button>
                                                </form>
                                            </div>
                                        <% } %>

                                        <!-- If In Progress (Worker can complete) -->
                                        <% if (isInProgress) { %>
                                            <div class="p-3 border rounded bg-white">
                                                <form action="<%= request.getContextPath() %>/worker" method="POST" enctype="multipart/form-data">
                                                    <input type="hidden" name="action" value="complete">
                                                    <input type="hidden" name="complaintId" value="<%= c.getComplaintId() %>">
                                                    
                                                    <div class="mb-2">
                                                        <label class="form-label small fw-semibold">Completion Remarks</label>
                                                        <textarea class="form-control form-control-sm" name="remarks" rows="2" placeholder="e.g. Replaced burnt fuse wiring" required></textarea>
                                                    </div>

                                                    <div class="mb-3">
                                                        <label class="form-label small fw-semibold">Upload Repair Photo (Verification)</label>
                                                        <input type="file" class="form-control form-control-sm" name="repairImages" accept="image/*" required>
                                                    </div>

                                                    <button type="submit" class="btn btn-sm btn-success w-100 py-2"><i class="bi bi-check2-all"></i> Submit Completion Report</button>
                                                </form>
                                            </div>
                                        <% } %>


                                    </div>
                                </div>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </div>

            <!-- Completed Jobs & Feedback Section -->
            <div class="glass-panel mt-4">
                <h5 class="fw-bold mb-4 text-success"><i class="bi bi-patch-check-fill me-2"></i> Completed Jobs &amp; Student Feedback</h5>
                <%
                    List<Complaint> completedJobs = myJobs.stream()
                        .filter(c -> "Completed".equalsIgnoreCase(c.getStatus()) || "Closed".equalsIgnoreCase(c.getStatus()))
                        .collect(Collectors.toList());
                        
                    if (completedJobs.isEmpty()) {
                %>
                    <div class="text-center py-4 text-secondary">
                        <p class="m-0">No completed jobs yet. Keep up the good work!</p>
                    </div>
                <% } else { %>
                    <div class="d-flex flex-column gap-3">
                        <% for (Complaint c : completedJobs) { 
                            Feedback fb = feedbackDAO.getFeedbackByComplaintId(c.getComplaintId());
                        %>
                            <div class="border rounded-4 p-3 bg-light bg-opacity-25 shadow-sm">
                                <div class="d-flex justify-content-between align-items-center mb-2">
                                    <span class="fw-bold text-dark">#<%= c.getComplaintId() %>: <%= c.getTitle() %></span>
                                    <span class="badge-status <%= c.getStatus().toLowerCase() %>"><%= c.getStatus() %></span>
                                </div>
                                <div class="text-muted small mb-2">
                                    Category: <%= c.getCategory() %> | Student: <%= c.getStudentName() %>
                                    <% if (c.getLatitude() != null && c.getLongitude() != null) { %>
                                        | <a href="javascript:void(0)" class="text-indigo text-decoration-none" onclick="showWorkerModalMap(<%= c.getLatitude() %>, <%= c.getLongitude() %>, '<%= c.getTitle().replace("'", "\\'") %>', '<%= c.getBuilding().replace("'", "\\'") %> Room <%= c.getRoomNo().replace("'", "\\'") %>')"><i class="bi bi-geo-alt-fill text-danger"></i> Locate Map</a>
                                    <% } %>
                                </div>
                                <% if (fb != null) { %>
                                    <div class="bg-white p-3 rounded border">
                                        <div class="d-flex justify-content-between align-items-center mb-1">
                                            <span class="small text-success fw-bold"><i class="bi bi-star-fill text-warning me-1"></i> Student Rating</span>
                                            <span class="small text-secondary"><%= fb.getSubmittedDate() != null ? fb.getSubmittedDate().toString().substring(0, 16) : "" %></span>
                                        </div>
                                        <div class="text-warning small mb-1">
                                            <% for (int i = 1; i <= 5; i++) { %>
                                                <i class="bi <%= i <= fb.getRating() ? "bi-star-fill" : "bi-star" %>"></i>
                                            <% } %>
                                        </div>
                                        <div class="small mb-1"><strong>Satisfaction:</strong> <%= fb.getSatisfactionLevel() %></div>
                                        <div class="small italic text-secondary font-monospace">"<%= fb.getFeedback() %>"</div>
                                    </div>
                                <% } else { %>
                                    <div class="text-secondary small italic bg-light p-2 rounded">
                                        <i class="bi bi-clock me-1"></i> Awaiting student rating &amp; comments feedback.
                                    </div>
                                <% } %>
                            </div>
                        <% } %>
                    </div>
                <% } %>
            </div>

        </div>
    </div>
</div>

<!-- Decline Job Modal -->
<div class="modal fade" id="rejectModal" tabindex="-1" aria-labelledby="rejectModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 rounded-4 shadow">
            <div class="modal-header border-0 bg-light rounded-top-4">
                <h5 class="modal-title fw-bold" id="rejectModalLabel">Decline Repair Job</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="<%= request.getContextPath() %>/worker" method="POST">
                <input type="hidden" name="action" value="updateStatus">
                <input type="hidden" name="status" value="Rejected">
                <input type="hidden" id="rejectComplaintId" name="complaintId" value="">
                
                <div class="modal-body p-4">
                    <p class="text-secondary mb-3 small">Please provide the reason for declining this repair assignment so it can be re-routed.</p>
                    
                    <div class="mb-3">
                        <label for="remarks" class="form-label small fw-semibold">Reason for Decline</label>
                        <textarea class="form-control" id="remarks" name="remarks" rows="3" placeholder="e.g. Requires a plumber, currently out of stock on electrical cables..." required></textarea>
                    </div>
                </div>

                <div class="modal-footer border-0 p-3 bg-light rounded-bottom-4">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-danger px-4">Decline Job</button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Complaint Blueprint Modal -->
<div class="modal fade" id="complaintBlueprintModal" tabindex="-1" aria-labelledby="complaintBlueprintModalLabel" aria-hidden="true" style="z-index: 1060;">
    <div class="modal-dialog modal-dialog-centered modal-lg">
        <div class="modal-content border-0 rounded-4 shadow">
            <div class="modal-header border-0 bg-light rounded-top-4">
                <h5 class="modal-title fw-bold" id="complaintBlueprintModalLabel">Complaint Location on Blueprint</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4 d-flex justify-content-center bg-light bg-opacity-50">
                <div id="modal-blueprint-wrapper" style="position: relative; display: inline-block;">
                    <img src="<%= blueprintPath %>" style="max-height: 480px; max-width: 100%; display: block; pointer-events: none;" />
                    <!-- Pinned complaint marker placed dynamically -->
                    <div id="modal-blueprint-pin" class="blueprint-pin" style="display: none; position: absolute; transform: translate(-50%, -100%);">
                        <i class="bi bi-geo-alt-fill text-danger fs-3" style="color: #ef4444 !important;"></i>
                        <span class="blueprint-pin-label" style="background:#ef4444 !important; color:#fff !important; font-size:9px; font-weight:600; padding:2px 6px; border-radius:4px; border:1px solid rgba(255,255,255,0.25); white-space:nowrap; margin-top:-2px; display:block;">Complaint Location</span>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-0 p-3 bg-light rounded-bottom-4">
                <span id="modal-blueprint-info" class="small text-secondary me-auto"></span>
                <button type="button" class="btn btn-secondary px-4" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
    </div>
</div>

<style>
    .blueprint-pin {
        position: absolute;
        transform: translate(-50%, -100%);
        display: flex;
        flex-direction: column;
        align-items: center;
        z-index: 50;
    }
    .blueprint-pin-label {
        background: rgba(15, 23, 42, 0.95);
        color: #fff;
        padding: 2px 6px;
        border-radius: 4px;
        font-size: 8px;
        font-weight: 600;
        white-space: nowrap;
        margin-top: -2px;
        border: 1px solid rgba(255, 255, 255, 0.15);
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.15);
    }
</style>

<script>
    function openRejectModal(complaintId) {
        document.getElementById("rejectComplaintId").value = complaintId;
        var myModal = new bootstrap.Modal(document.getElementById('rejectModal'));
        myModal.show();
    }

    function showComplaintBlueprintSpot(lat, lng, title, locationInfo) {
        document.getElementById('complaintBlueprintModalLabel').innerText = "Location Spot: " + title;
        document.getElementById('modal-blueprint-info').innerText = locationInfo + " (X: " + parseFloat(lng).toFixed(1) + "%, Y: " + parseFloat(lat).toFixed(1) + "%)";
        
        const pin = document.getElementById('modal-blueprint-pin');
        pin.style.left = lng + '%';
        pin.style.top = lat + '%';
        pin.style.display = 'block';
        
        var blueprintModal = new bootstrap.Modal(document.getElementById('complaintBlueprintModal'));
        blueprintModal.show();
    }
</script>

<jsp:include page="/jsp/common/footer.jsp" />
