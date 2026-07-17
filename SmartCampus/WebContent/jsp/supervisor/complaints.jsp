<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Supervisor" %>
<%@ page import="model.Complaint" %>
<%@ page import="model.Worker" %>
<%@ page import="model.CampusBlueprint" %>
<%@ page import="dao.ComplaintDAO" %>
<%@ page import="dao.WorkerDAO" %>
<%@ page import="dao.FeedbackDAO" %>
<%@ page import="model.Feedback" %>
<%@ page import="java.util.List" %>
<%
    Supervisor supervisor = (Supervisor) session.getAttribute("supervisor");
    if (supervisor == null) {
        response.sendRedirect(request.getContextPath() + "/login?role=supervisor");
        return;
    }

    ComplaintDAO complaintDAO = new ComplaintDAO();
    WorkerDAO workerDAO = new WorkerDAO();
    FeedbackDAO feedbackDAO = new FeedbackDAO();
    
    dao.CampusBlueprintDAO blueprintDAO = new dao.CampusBlueprintDAO();
    CampusBlueprint blueprint = blueprintDAO.getLatestBlueprint();
    String blueprintPath = (blueprint != null) ? blueprint.getFilePath() : request.getContextPath() + "/images/kit_campus_blueprint.png";

    // Query parameters for search & filters
    String searchQuery = request.getParameter("query");
    String filterStatus = request.getParameter("status");
    String filterCategory = request.getParameter("category");
    String filterPriority = request.getParameter("priority");

    List<Complaint> list = complaintDAO.searchAndFilterComplaints(searchQuery, filterStatus, filterCategory, filterPriority);
    List<Worker> workers = workerDAO.getAllWorkers();

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
            <!-- Alert Messages -->
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



            <!-- Search and Filter Panel -->
            <div class="glass-panel py-3">
                <form action="complaints.jsp" method="GET" class="row g-3">
                    <div class="col-lg-3 col-md-6">
                        <div class="input-group">
                            <span class="input-group-text bg-white border-end-0"><i class="bi bi-search text-muted"></i></span>
                            <input type="text" class="form-control border-start-0" name="query" placeholder="Search title, room, category..." value="<%= searchQuery != null ? searchQuery : "" %>">
                        </div>
                    </div>
                    
                    <div class="col-lg-2 col-md-3 col-6">
                        <select class="form-select" name="status">
                            <option value="All">All Statuses</option>
                            <option value="Pending" <%= "Pending".equals(filterStatus) ? "selected" : "" %>>Pending</option>
                            <option value="Assigned" <%= "Assigned".equals(filterStatus) ? "selected" : "" %>>Assigned</option>
                            <option value="Accepted" <%= "Accepted".equals(filterStatus) ? "selected" : "" %>>Accepted</option>
                            <option value="In Progress" <%= "In Progress".equals(filterStatus) ? "selected" : "" %>>In Progress</option>
                            <option value="Completed" <%= "Completed".equals(filterStatus) ? "selected" : "" %>>Completed</option>
                            <option value="Closed" <%= "Closed".equals(filterStatus) ? "selected" : "" %>>Closed</option>
                            <option value="Rejected" <%= "Rejected".equals(filterStatus) ? "selected" : "" %>>Rejected</option>
                        </select>
                    </div>

                    <div class="col-lg-2 col-md-3 col-6">
                        <select class="form-select" name="category">
                            <option value="All">All Categories</option>
                            <option value="Electrical" <%= "Electrical".equals(filterCategory) ? "selected" : "" %>>Electrical</option>
                            <option value="Water Leakage" <%= "Water Leakage".equals(filterCategory) ? "selected" : "" %>>Water Leakage</option>
                            <option value="Internet" <%= "Internet".equals(filterCategory) ? "selected" : "" %>>Internet</option>
                            <option value="Furniture" <%= "Furniture".equals(filterCategory) ? "selected" : "" %>>Furniture</option>
                            <option value="Cleaning" <%= "Cleaning".equals(filterCategory) ? "selected" : "" %>>Cleaning</option>
                            <option value="Hostel" <%= "Hostel".equals(filterCategory) ? "selected" : "" %>>Hostel</option>
                            <option value="Washroom" <%= "Washroom".equals(filterCategory) ? "selected" : "" %>>Washroom</option>
                            <option value="Other" <%= "Other".equals(filterCategory) ? "selected" : "" %>>Other</option>
                        </select>
                    </div>

                    <div class="col-lg-2 col-md-3 col-6">
                        <select class="form-select" name="priority">
                            <option value="All">All Priorities</option>
                            <option value="Low" <%= "Low".equals(filterPriority) ? "selected" : "" %>>Low</option>
                            <option value="Medium" <%= "Medium".equals(filterPriority) ? "selected" : "" %>>Medium</option>
                            <option value="High" <%= "High".equals(filterPriority) ? "selected" : "" %>>High</option>
                            <option value="Critical" <%= "Critical".equals(filterPriority) ? "selected" : "" %>>Critical</option>
                        </select>
                    </div>

                    <div class="col-lg-3 col-md-3 col-6 d-flex gap-2">
                        <button type="submit" class="btn btn-indigo text-white w-100" style="background-color:#4f46e5;"><i class="bi bi-filter"></i> Apply</button>
                        <a href="complaints.jsp" class="btn btn-light border w-100">Clear</a>
                    </div>
                </form>
            </div>

            <!-- Complaints List Panel -->
            <div class="glass-panel">
                <h5 class="fw-bold mb-4">Manage Campus Complaints</h5>
                
                <% if (list.isEmpty()) { %>
                    <div class="text-center py-5 text-secondary">
                        <i class="bi bi-clipboard-x fs-1 text-muted d-block mb-3"></i>
                        <p class="m-0">No complaints matching your query/filters were found.</p>
                    </div>
                <% } else { %>
                    <div class="table-responsive">
                        <table class="table align-middle border-0">
                            <thead>
                                <tr class="text-secondary small border-bottom">
                                    <th class="border-0 pb-3" style="width: 80px;">ID</th>
                                    <th class="border-0 pb-3">Issue Title</th>
                                    <th class="border-0 pb-3">Student Name</th>
                                    <th class="border-0 pb-3">Building/Room</th>
                                    <th class="border-0 pb-3">Priority</th>
                                    <th class="border-0 pb-3">Status</th>
                                    <th class="border-0 pb-3 text-end">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% for (Complaint c : list) { 
                                    Feedback fb = feedbackDAO.getFeedbackByComplaintId(c.getComplaintId());
                                %>
                                    <tr class="border-bottom" style="height: 75px;">
                                        <td class="fw-bold text-indigo">#<%= c.getComplaintId() %></td>
                                        <td>
                                            <div class="fw-semibold"><%= c.getTitle() %></div>
                                            <span class="text-muted small"><%= c.getCategory() %> | <%= c.getCreatedAt().toString().substring(0, 10) %></span>
                                        </td>
                                        <td>
                                             <div class="fw-semibold"><%= c.getStudentName() %></div>
                                        </td>
                                        <td><%= c.getBuilding() %>, Rm <%= c.getRoomNo() %></td>
                                        <td>
                                            <span class="badge-priority <%= c.getPriority().toLowerCase() %>"><%= c.getPriority() %></span>
                                        </td>
                                        <td>
                                            <span class="badge-status <%= c.getStatus().replaceAll(" ", "-").toLowerCase() %>"><%= c.getStatus() %></span>
                                        </td>
                                        <td class="text-end">
                                            <button type="button" class="btn btn-sm btn-outline-indigo px-3" 
                                                    style="color:#4f46e5; border-color:#4f46e5;"
                                                    onclick="toggleDetailRow(<%= c.getComplaintId() %>)">
                                                Details <i class="bi bi-chevron-down ms-1"></i>
                                            </button>
                                        </td>
                                    </tr>

                                    <!-- Expanded details drawer row -->
                                    <tr id="details-row-<%= c.getComplaintId() %>" class="d-none bg-light bg-opacity-25">
                                        <td colspan="7" class="p-4 border-bottom">
                                            <div class="row g-4">
                                                <!-- Descriptions Section -->
                                                <div class="col-lg-6">
                                                    <h6 class="fw-bold mb-2">Complaint Description</h6>
                                                    <p class="text-secondary small mb-3"><%= c.getDescription() %></p>

                                                    <!-- Images list -->
                                                    <%
                                                        List<String> images = complaintDAO.getComplaintImages(c.getComplaintId());
                                                        if (!images.isEmpty()) {
                                                    %>
                                                        <div class="mt-3">
                                                            <h6 class="fw-bold mb-2">Attached Images (Issues &amp; Repairs)</h6>
                                                            <div class="d-flex flex-wrap gap-2">
                                                                <% for (String img : images) { %>
                                                                    <a href="<%= img %>" target="_blank" class="image-preview-card border rounded" style="width: 70px; height: 70px;">
                                                                        <img src="<%= img %>" style="width:100%; height:100%; object-fit:cover;" />
                                                                    </a>
                                                                <% } %>
                                                            </div>
                                                        </div>
                                                    <% } %>
                                                </div>

                                                <!-- Operations and Workers allocation section -->
                                                <div class="col-lg-6">
                                                    <div class="floating-detail-panel h-100 m-0">
                                                        <h6 class="fw-bold mb-3 text-indigo" style="color:#4f46e5;"><i class="bi bi-sliders"></i> Operations Control</h6>
                                                        
                                                        <!-- Assignment & contact details -->
                                                        <div class="mb-3 small">
                                                            <div class="mb-1"><strong>Location:</strong> <%= c.getBuilding() %>, <%= c.getBlock() %>, <%= c.getFloor() %>, Rm <%= c.getRoomNo() %></div>
                                                            <div class="mb-1"><strong>Student:</strong> <%= c.getStudentName() %></div>
                                                            <div class="mb-1"><strong>Worker Assigned:</strong> 
                                                                <%= c.getAssignedWorkerName() != null ? c.getAssignedWorkerName() : "<span class='text-danger fw-semibold'>Unallocated</span>" %>
                                                            </div>
                                                            <div class="mb-1"><strong>Current Status:</strong> <span class="badge bg-secondary bg-opacity-10 text-dark font-monospace"><%= c.getStatus() %></span></div>
                                                            <% if (c.getAssignmentRemarks() != null) { %>
                                                                <div class="mb-1"><strong>Repair Remarks:</strong> <%= c.getAssignmentRemarks() %></div>
                                                            <% } %>
                                                            <% if (c.getLatitude() != null && c.getLongitude() != null) { %>
                                                                <div class="mt-2">
                                                                    <button type="button" class="btn btn-xs btn-outline-indigo text-indigo border-indigo border-opacity-50 py-1 px-2 rounded" style="font-size:11px;"
                                                                            onclick="showComplaintBlueprintSpot(<%= c.getLatitude() %>, <%= c.getLongitude() %>, '<%= c.getTitle().replace("'", "\\'") %>', '<%= c.getBuilding().replace("'", "\\'") %> Room <%= c.getRoomNo().replace("'", "\\'") %>')">
                                                                        <i class="bi bi-geo-alt-fill text-danger"></i> Locate on Blueprint
                                                                    </button>
                                                                </div>
                                                            <% } %>

                                                        </div>

                                                        <!-- Modify Priority and Status form inline -->
                                                        <div class="row g-2 mb-3">
                                                            <div class="col">
                                                                <form action="<%= request.getContextPath() %>/supervisor" method="POST">
                                                                    <input type="hidden" name="action" value="updatePriority">
                                                                    <input type="hidden" name="complaintId" value="<%= c.getComplaintId() %>">
                                                                    <label class="form-label small fw-semibold text-muted mb-1">Set Priority</label>
                                                                    <select class="form-select form-select-sm" name="priority" onchange="this.form.submit()">
                                                                        <option value="Low" <%= "Low".equals(c.getPriority()) ? "selected" : "" %>>Low</option>
                                                                        <option value="Medium" <%= "Medium".equals(c.getPriority()) ? "selected" : "" %>>Medium</option>
                                                                        <option value="High" <%= "High".equals(c.getPriority()) ? "selected" : "" %>>High</option>
                                                                        <option value="Critical" <%= "Critical".equals(c.getPriority()) ? "selected" : "" %>>Critical</option>
                                                                    </select>
                                                                </form>
                                                            </div>
                                                            <div class="col">
                                                                <form action="<%= request.getContextPath() %>/supervisor" method="POST">
                                                                    <input type="hidden" name="action" value="updateStatus">
                                                                    <input type="hidden" name="complaintId" value="<%= c.getComplaintId() %>">
                                                                    <label class="form-label small fw-semibold text-muted mb-1">Set Status</label>
                                                                    <select class="form-select form-select-sm" name="status" onchange="this.form.submit()">
                                                                        <option value="Pending" <%= "Pending".equals(c.getStatus()) ? "selected" : "" %>>Pending</option>
                                                                        <option value="Assigned" <%= "Assigned".equals(c.getStatus()) ? "selected" : "" %>>Assigned</option>
                                                                        <option value="Accepted" <%= "Accepted".equals(c.getStatus()) ? "selected" : "" %>>Accepted</option>
                                                                        <option value="In Progress" <%= "In Progress".equals(c.getStatus()) ? "selected" : "" %>>In Progress</option>
                                                                        <option value="Completed" <%= "Completed".equals(c.getStatus()) ? "selected" : "" %>>Completed</option>
                                                                        <option value="Closed" <%= "Closed".equals(c.getStatus()) ? "selected" : "" %>>Closed</option>
                                                                        <option value="Rejected" <%= "Rejected".equals(c.getStatus()) ? "selected" : "" %>>Rejected</option>
                                                                    </select>
                                                                </form>
                                                            </div>
                                                        </div>

                                                        <!-- Allocate Worker panel if Pending/Rejected -->
                                                        <% if ("Pending".equals(c.getStatus()) || "Rejected".equals(c.getStatus())) { %>
                                                            <div class="border-top pt-3 mt-3">
                                                                <label class="form-label small fw-bold text-indigo d-block mb-2">Allocate Maintenance Worker</label>
                                                                <button class="btn btn-sm btn-indigo text-white w-100" style="background-color:#4f46e5;"
                                                                        onclick="openAssignModal(<%= c.getComplaintId() %>, '<%= c.getCategory().replace("'", "\\'") %>')">
                                                                    <i class="bi bi-person-plus-fill"></i> Assign Available Staff
                                                                </button>
                                                            </div>
                                                        <% } %>

                                                        <!-- Feedback Display if submitted -->
                                                        <% if (fb != null) { %>
                                                            <div class="border-top pt-3 mt-3 bg-light p-3 rounded">
                                                                <span class="d-block small text-success fw-bold mb-1"><i class="bi bi-star-fill text-warning"></i> Student Feedback</span>
                                                                <div class="text-warning small mb-1">
                                                                    <% for (int i = 1; i <= 5; i++) { %>
                                                                        <i class="bi <%= i <= fb.getRating() ? "bi-star-fill" : "bi-star" %>"></i>
                                                                    <% } %>
                                                                </div>
                                                                <p class="text-secondary small mb-1"><strong>Satisfaction:</strong> <%= fb.getSatisfactionLevel() %></p>
                                                                <p class="text-secondary small italic m-0">"<%= fb.getFeedback() %>"</p>
                                                            </div>
                                                        <% } %>
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
            </div> <!-- End of glass-panel -->
        </div> <!-- End of content-wrapper -->
    </div> <!-- End of main-content -->
</div> <!-- End of app-container -->

<!-- Assign Worker modal popup -->
<div class="modal fade" id="assignModal" tabindex="-1" aria-labelledby="assignModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 rounded-4 shadow">
            <div class="modal-header border-0 bg-light rounded-top-4">
                <h5 class="modal-title fw-bold" id="assignModalLabel">Allocate Maintenance Worker</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form action="<%= request.getContextPath() %>/supervisor" method="POST">
                <input type="hidden" name="action" value="assign">
                <input type="hidden" id="assignComplaintId" name="complaintId" value="">
                
                <div class="modal-body p-4">
                    <p class="text-secondary mb-3 small">Select a worker from the list below. Suggested workers matching the issue category (<strong id="complaintCategoryDisplay"></strong>) are highlighted.</p>
                    
                    <div class="mb-3">
                        <label for="workerId" class="form-label small fw-semibold">Choose Worker</label>
                        <select class="form-select" id="workerId" name="workerId" required>
                            <option value="" disabled selected>Select staff member</option>
                            <% for (Worker w : workers) { %>
                                <option value="<%= w.getWorkerId() %>" 
                                        data-spec="<%= w.getSpecialization() %>"
                                        data-status="<%= w.getStatus() %>">
                                    <%= w.getName() %> (<%= w.getSpecialization() %>) - <%= w.getStatus() %>
                                </option>
                            <% } %>
                        </select>
                    </div>
                </div>

                <div class="modal-footer border-0 p-3 bg-light rounded-bottom-4">
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                    <button type="submit" class="btn btn-indigo text-white px-4" style="background-color: #4f46e5;">Confirm Assignment</button>
                </div>
            </form>
        </div>
    </div>
</div>

<script>
    function toggleDetailRow(id) {
        // Toggle display of detail row
        const row = document.getElementById("details-row-" + id);
        if (!row) return;

        row.classList.toggle("d-none");
    }

    function openAssignModal(complaintId, category) {
        document.getElementById("assignComplaintId").value = complaintId;
        document.getElementById("complaintCategoryDisplay").textContent = category;
        
        // Highlight matching specialties in the select dropdown
        const select = document.getElementById("workerId");
        const options = select.options;
        
        for (let i = 1; i < options.length; i++) {
            const spec = options[i].getAttribute("data-spec");
            const status = options[i].getAttribute("data-status");
            
            // Format labels for recommendations
            let suffix = "";
            if (spec.toLowerCase() === category.toLowerCase()) {
                suffix += " [RECOMENDED SPECIALTY]";
                options[i].style.fontWeight = "bold";
                options[i].style.backgroundColor = "rgba(79, 70, 229, 0.1)";
            } else {
                options[i].style.fontWeight = "normal";
                options[i].style.backgroundColor = "";
            }
            
            // Clean text
            const baseText = options[i].textContent.split(" - ")[0].split(" [")[0];
            options[i].textContent = baseText + " (" + spec + ") - " + status + suffix;
        }

        var myModal = new bootstrap.Modal(document.getElementById('assignModal'));
        myModal.show();
    }
</script>

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

<script>
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
