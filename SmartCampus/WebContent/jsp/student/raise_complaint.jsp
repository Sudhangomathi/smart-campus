<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Student" %>
<%@ page import="model.CampusBlueprint" %>
<%@ page import="model.CampusLocation" %>
<%@ page import="java.util.List" %>
<%
    Student student = (Student) session.getAttribute("student");
    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/login?role=student");
        return;
    }

    dao.CampusBlueprintDAO blueprintDAO = new dao.CampusBlueprintDAO();
    CampusBlueprint blueprint = blueprintDAO.getLatestBlueprint();
    String blueprintPath = (blueprint != null) ? blueprint.getFilePath() : request.getContextPath() + "/images/kit_campus_blueprint.png";

    dao.CampusLocationDAO locationDAO = new dao.CampusLocationDAO();
    List<CampusLocation> landmarks = locationDAO.getAllLocations();
%>
<jsp:include page="/jsp/common/header.jsp" />

<style>
    .blueprint-pin {
        position: absolute;
        transform: translate(-50%, -100%);
        cursor: pointer;
        display: flex;
        flex-direction: column;
        align-items: center;
        z-index: 50;
        transition: transform 0.2s ease;
    }
    .blueprint-pin:hover {
        transform: translate(-50%, -105%) scale(1.1);
        z-index: 100;
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

<div class="app-container">
    <!-- Sidebar -->
    <jsp:include page="/jsp/common/sidebar.jsp" />

    <!-- Main Content Area -->
    <div class="main-content">
        <!-- Top Navbar -->
        <jsp:include page="/jsp/common/navbar.jsp" />

        <div class="content-wrapper">
            <div class="glass-panel">
                <h4 class="fw-bold mb-1"><i class="bi bi-file-earmark-plus-fill text-indigo me-2" style="color: #4f46e5;"></i> Raise A Maintenance Complaint</h4>
                <p class="text-secondary mb-4">Complete the fields below and tag the issue location on the map to alert the campus maintenance team.</p>

                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger mb-4"><%= request.getAttribute("error") %></div>
                <% } %>

                <form action="<%= request.getContextPath() %>/student" method="POST" enctype="multipart/form-data">
                    <input type="hidden" name="action" value="raise">
                    <div class="row g-4">
                        <!-- Left Details Column -->
                        <div class="col-lg-6">
                            <div class="mb-3">
                                <label for="title" class="form-label fw-semibold">Complaint Title</label>
                                <input type="text" class="form-control rounded-3" id="title" name="title" placeholder="Brief summary of the issue (e.g. Water leakage, broken fan)" required>
                            </div>

                            <div class="mb-3">
                                <label for="description" class="form-label fw-semibold">Detailed Description</label>
                                <textarea class="form-control rounded-3" id="description" name="description" rows="4" placeholder="Describe the issue, location details, or any hazards..." required></textarea>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="category" class="form-label fw-semibold">Category</label>
                                    <select class="form-select rounded-3" id="category" name="category" required>
                                        <option value="" disabled selected>Select Category</option>
                                        <option value="Electrical">Electrical</option>
                                        <option value="Water Leakage">Water Leakage</option>
                                        <option value="Internet">Internet</option>
                                        <option value="Classroom">Classroom</option>
                                        <option value="Laboratory">Laboratory</option>
                                        <option value="Hostel">Hostel</option>
                                        <option value="Washroom">Washroom</option>
                                        <option value="Furniture">Furniture</option>
                                        <option value="Cleaning">Cleaning</option>
                                        <option value="Garden">Garden</option>
                                        <option value="Road Damage">Road Damage</option>
                                        <option value="CCTV">CCTV</option>
                                        <option value="Security">Security</option>
                                        <option value="Other">Other</option>
                                    </select>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="priority" class="form-label fw-semibold">Complaint Priority</label>
                                    <select class="form-select rounded-3" id="priority" name="priority" required>
                                        <option value="Low">Low (General request)</option>
                                        <option value="Medium" selected>Medium (Standard issue)</option>
                                        <option value="High">High (Immediate attention)</option>
                                        <option value="Critical">Critical (Safety hazard / emergency)</option>
                                    </select>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="building" class="form-label fw-semibold">Building</label>
                                    <input type="text" class="form-control rounded-3" id="building" name="building" placeholder="e.g. Main Academic Building" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="block" class="form-label fw-semibold">Block / Wing</label>
                                    <input type="text" class="form-control rounded-3" id="block" name="block" placeholder="e.g. Block A" required>
                                </div>
                            </div>

                            <div class="row">
                                <div class="col-md-6 mb-3">
                                    <label for="floor" class="form-label fw-semibold">Floor</label>
                                    <input type="text" class="form-control rounded-3" id="floor" name="floor" placeholder="e.g. 1st Floor" required>
                                </div>
                                <div class="col-md-6 mb-3">
                                    <label for="roomNo" class="form-label fw-semibold">Room Number</label>
                                    <input type="text" class="form-control rounded-3" id="roomNo" name="roomNo" placeholder="e.g. Room 102" required>
                                </div>
                            </div>
                        </div>

                        <!-- Hidden inputs for blueprint coordinate percentage mapping -->
                        <input type="hidden" id="latitude" name="latitude" value="">
                        <input type="hidden" id="longitude" name="longitude" value="">

                        <!-- Right Maps & Uploads Column -->
                        <div class="col-lg-6">
                            <!-- Drag and drop image upload -->
                            <div class="mb-4">
                                <label class="form-label fw-semibold">Upload Image Proofs</label>
                                <div class="upload-zone" id="upload-zone">
                                    <i class="bi bi-cloud-arrow-up-fill"></i>
                                    <p class="m-0 fw-semibold">Drag &amp; drop images here or click to browse</p>
                                    <span class="text-muted small">Supports multiple files (Max 10MB each)</span>
                                    <input type="file" id="images" name="images" class="d-none" accept="image/*" multiple>
                                </div>
                                <div class="image-preview-grid" style="display: none;">
                                    <!-- Previews populated dynamically by main.js -->
                                </div>
                            </div>

                            <!-- Interactive Blueprint Section -->
                            <div class="mb-4">
                                <label class="form-label fw-semibold">Select Location on Campus Blueprint</label>
                                <p class="text-secondary small mb-2">
                                    <i class="bi bi-info-circle-fill text-indigo"></i> Click a blue landmark pin to select that building, or click anywhere on the blueprint to place a custom red pin.
                                </p>
                                
                                <div class="blueprint-viewport border rounded-4 overflow-hidden position-relative bg-dark bg-opacity-10 d-flex align-items-center justify-content-center" 
                                     style="height: 330px; cursor: crosshair; user-select: none;">
                                    <div id="blueprint-wrapper" style="position: relative; display: inline-block;" onclick="selectBlueprintSpot(event)">
                                        <img id="blueprint-img" src="<%= blueprintPath %>" style="max-height: 310px; max-width: 100%; display: block; pointer-events: none;" />
                                        
                                        <!-- Plotted Predefined Pins -->
                                        <%
                                            if (landmarks != null) {
                                                for (CampusLocation loc : landmarks) {
                                        %>
                                            <div class="blueprint-pin" 
                                                 style="left: <%= loc.getLongitude() %>%; top: <%= loc.getLatitude() %>%;"
                                                 data-name="<%= loc.getName() %>"
                                                 data-lat="<%= loc.getLatitude() %>"
                                                 data-lng="<%= loc.getLongitude() %>"
                                                 onclick="selectPredefinedPin(event, this)">
                                                <i class="bi bi-geo-alt-fill text-indigo fs-4" style="color: #4f46e5 !important;"></i>
                                                <span class="blueprint-pin-label"><%= loc.getName() %></span>
                                            </div>
                                        <%
                                                }
                                            }
                                        %>
                                    </div>
                                </div>
                                
                                <div id="selected-coords-alert" class="alert alert-indigo bg-indigo bg-opacity-10 text-indigo border-indigo border-opacity-10 mt-2 py-2 small d-none">
                                    <i class="bi bi-geo-alt-fill text-danger me-1"></i> Selected Spot: <span id="display-coords" class="fw-semibold"></span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="border-top pt-4 mt-4 d-flex justify-content-end gap-3">
                        <a href="<%= request.getContextPath() %>/jsp/student/dashboard.jsp" class="btn btn-light px-4 py-2 border">Cancel</a>
                        <button type="submit" class="btn btn-indigo text-white px-5 py-2" style="background-color: #4f46e5;">Submit Complaint</button>
                    </div>
                </form>
            </div>
        </div>
    </div>
</div>

<script>
    function selectPredefinedPin(event, pinEl) {
        event.stopPropagation(); // Prevent trigger background wrapper click
        
        const name = pinEl.getAttribute('data-name');
        const lat = pinEl.getAttribute('data-lat');
        const lng = pinEl.getAttribute('data-lng');
        
        document.getElementById('building').value = name;
        document.getElementById('block').value = "Main";
        document.getElementById('floor').value = "Ground Floor";
        document.getElementById('roomNo').value = "N/A";
        
        setBlueprintCoordinates(lat, lng, name);
    }
    
    function selectBlueprintSpot(event) {
        const wrapper = document.getElementById('blueprint-wrapper');
        const rect = wrapper.getBoundingClientRect();
        
        const clickX = ((event.clientX - rect.left) / rect.width) * 100;
        const clickY = ((event.clientY - rect.top) / rect.height) * 100;
        
        setBlueprintCoordinates(clickY, clickX, "Custom Pinned Spot");
    }
    
    function setBlueprintCoordinates(lat, lng, label) {
        document.getElementById('latitude').value = lat;
        document.getElementById('longitude').value = lng;
        
        document.getElementById('display-coords').innerText = label + " (X: " + parseFloat(lng).toFixed(1) + "%, Y: " + parseFloat(lat).toFixed(1) + "%)";
        document.getElementById('selected-coords-alert').classList.remove('d-none');
        
        // Remove or create red custom pin indicator
        const wrapper = document.getElementById('blueprint-wrapper');
        let customPin = document.getElementById('student-custom-pin');
        if (!customPin) {
            customPin = document.createElement('div');
            customPin.id = 'student-custom-pin';
            customPin.className = 'blueprint-pin';
            customPin.innerHTML = '<i class="bi bi-geo-alt-fill text-danger fs-4"></i><span class="blueprint-pin-label" style="background:#ef4444 !important;">Tagged Location</span>';
            wrapper.appendChild(customPin);
        }
        customPin.style.left = lng + '%';
        customPin.style.top = lat + '%';
    }
</script>

<jsp:include page="/jsp/common/footer.jsp" />
