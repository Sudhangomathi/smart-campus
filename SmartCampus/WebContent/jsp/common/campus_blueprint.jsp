<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.CampusBlueprint" %>
<%@ page import="model.CampusLocation" %>
<%@ page import="model.User" %>
<%@ page import="java.util.List" %>
<%
    User user = (User) session.getAttribute("user");
    if (user == null) {
        response.sendRedirect(request.getContextPath() + "/login?role=student");
        return;
    }

    boolean isSupervisor = "supervisor".equalsIgnoreCase(user.getRole());

    CampusBlueprint blueprint = (CampusBlueprint) request.getAttribute("blueprint");
    String blueprintPath = (blueprint != null) ? blueprint.getFilePath() : request.getContextPath() + "/images/kit_campus_blueprint.png";
    List<CampusLocation> locations = (List<CampusLocation>) request.getAttribute("locations");
    String successMsg = request.getParameter("success");
    String errorMsg = request.getParameter("error");
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
        transform: translate(-50%, -105%) scale(1.15);
        z-index: 100;
    }
    .blueprint-pin-label {
        background: rgba(15, 23, 42, 0.95);
        color: #fff;
        padding: 2px 6px;
        border-radius: 4px;
        font-size: 9px;
        font-weight: 600;
        white-space: nowrap;
        margin-top: -2px;
        border: 1px solid rgba(255, 255, 255, 0.15);
        box-shadow: 0 4px 6px rgba(0, 0, 0, 0.15);
    }
</style>

<div class="app-container">
    <!-- Sidebar Navigation -->
    <jsp:include page="/jsp/common/sidebar.jsp" />

    <!-- Main Content Area -->
    <div class="main-content">
        <!-- Top Navbar -->
        <jsp:include page="/jsp/common/navbar.jsp" />

        <div class="content-wrapper">
            <!-- Greeting Header -->
            <div class="glass-panel py-4 px-5 mb-4">
                <h3 class="fw-bold mb-1">Campus Blueprint Portal</h3>
                <p class="text-secondary m-0">
                    Use this schematic to identify key buildings and rooms on the campus of Karpagam Institute of Technology (KIT).
                    <% if (isSupervisor) { %>
                        <strong>Click anywhere on the blueprint</strong> to register a new predefined location marker.
                    <% } %>
                </p>
            </div>

            <% if (successMsg != null) { %>
                <div class="alert alert-success alert-dismissible fade show bg-success bg-opacity-10 text-success border-success border-opacity-10 mb-4" role="alert">
                    <i class="bi bi-check-circle-fill me-2"></i> <%= successMsg %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>

            <% if (errorMsg != null) { %>
                <div class="alert alert-danger alert-dismissible fade show bg-danger bg-opacity-10 text-danger border-danger border-opacity-10 mb-4" role="alert">
                    <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= errorMsg %>
                    <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                </div>
            <% } %>

            <div class="row g-4">
                <!-- Large Zoomable View Column -->
                <div class="col-lg-8">
                    <div class="glass-panel py-4 h-100 d-flex flex-column">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h5 class="fw-bold m-0"><i class="bi bi-compass text-indigo me-2"></i> Interactive Blueprint Viewer</h5>
                            <span class="text-muted small">Scroll wheel to zoom, click and drag to pan</span>
                        </div>
                        
                        <!-- Blueprint Viewport -->
                        <div class="blueprint-viewport border rounded-4 overflow-hidden position-relative flex-grow-1 bg-dark bg-opacity-10 d-flex align-items-center justify-content-center" 
                             style="height: 520px; min-height: 400px; cursor: grab; user-select: none;">
                            
                            <div id="blueprint-wrapper" style="position: relative; display: inline-block; transform-origin: center center; transition: transform 0.05s ease-out; transform: scale(1) translate(0px, 0px);" onclick="handleBlueprintClick(event)">
                                <img id="blueprint-img" src="<%= blueprintPath %>" style="max-height: 500px; max-width: 100%; display: block; pointer-events: none;" />
                                
                                <!-- Predefined Markers/Pins plotted on percentages -->
                                <%
                                    if (locations != null) {
                                        for (CampusLocation loc : locations) {
                                %>
                                    <div class="blueprint-pin" 
                                         style="left: <%= loc.getLongitude() %>%; top: <%= loc.getLatitude() %>%;"
                                         data-id="<%= loc.getLocationId() %>"
                                         data-name="<%= loc.getName() %>"
                                         data-lat="<%= loc.getLatitude() %>"
                                         data-lng="<%= loc.getLongitude() %>"
                                         onclick="handlePinClick(event, this)">
                                        <i class="bi bi-geo-alt-fill text-indigo fs-4" style="color: #4f46e5 !important;"></i>
                                        <span class="blueprint-pin-label"><%= loc.getName() %></span>
                                    </div>
                                <%
                                        }
                                    }
                                %>
                            </div>
                            
                            <!-- Floating Controls -->
                            <div class="position-absolute bottom-0 end-0 m-3 d-flex gap-2" style="z-index: 110;">
                                <button class="btn btn-sm btn-indigo text-white shadow-sm" onclick="zoomBlueprint(0.1)" style="background-color: #4f46e5; border:none; width: 32px; height: 32px;">
                                    <i class="bi bi-zoom-in"></i>
                                </button>
                                <button class="btn btn-sm btn-indigo text-white shadow-sm" onclick="zoomBlueprint(-0.1)" style="background-color: #4f46e5; border:none; width: 32px; height: 32px;">
                                    <i class="bi bi-zoom-out"></i>
                                </button>
                                <button class="btn btn-sm btn-light border shadow-sm px-3" onclick="resetBlueprint()">
                                    <i class="bi bi-arrow-counterclockwise me-1"></i> Reset
                                </button>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Legend and Actions Column -->
                <div class="col-lg-4">
                    <div class="d-flex flex-column gap-4">
                        <!-- Campus Buildings Legend -->
                        <div class="glass-panel py-4">
                            <h5 class="fw-bold mb-3"><i class="bi bi-bookmark-star text-indigo me-2"></i> Predefined Landmarks</h5>
                            <p class="text-secondary small mb-3">Mapped coordinates on the blueprint:</p>
                            <div class="list-group list-group-flush small" style="max-height: 250px; overflow-y: auto;">
                                <% if (locations == null || locations.isEmpty()) { %>
                                    <p class="text-muted small">No predefined landmarks pinned yet.</p>
                                <% } else { 
                                    for (CampusLocation loc : locations) {
                                %>
                                    <div class="list-group-item bg-transparent px-0 py-2 border-bottom-0 d-flex justify-content-between align-items-center">
                                        <span><i class="bi bi-geo-alt-fill text-indigo me-2"></i><%= loc.getName() %></span>
                                        <span class="text-muted text-monospace" style="font-size:9px;">(X:<%= String.format("%.0f", loc.getLongitude()) %>%, Y:<%= String.format("%.0f", loc.getLatitude()) %>%)</span>
                                    </div>
                                <% 
                                    }
                                } %>
                            </div>
                        </div>

                        <!-- Supervisor Upload Panel -->
                        <% if (isSupervisor) { %>
                            <div class="glass-panel py-4">
                                <h5 class="fw-bold mb-3"><i class="bi bi-cloud-arrow-up text-indigo me-2"></i> Replace Blueprint</h5>
                                <p class="text-secondary small mb-3">Upload a new blueprint schematic of KIT. Note: Replacing the blueprint updates it for all users.</p>
                                
                                <form action="<%= request.getContextPath() %>/campus-blueprint" method="POST" enctype="multipart/form-data">
                                    <div class="mb-3">
                                        <label for="blueprintImage" class="form-label small fw-semibold">Select Image File</label>
                                        <input type="file" class="form-control form-control-sm" id="blueprintImage" name="blueprintImage" accept="image/*" required>
                                    </div>
                                    <button type="submit" class="btn btn-indigo text-white btn-sm w-100 py-2" style="background-color: #4f46e5; border:none;">
                                        <i class="bi bi-cloud-check-fill me-2"></i> Update Blueprint
                                    </button>
                                </form>
                            </div>
                        <% } else { %>
                            <div class="glass-panel py-4 text-center">
                                <i class="bi bi-info-circle text-muted fs-3 mb-2 d-block"></i>
                                <span class="text-secondary small d-block">You are viewing the blueprint in read-only mode. Only supervisors can configure blueprint settings.</span>
                            </div>
                        <% } %>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Manage Predefined Pin Modal (Supervisor Only) -->
<% if (isSupervisor) { %>
<div class="modal fade" id="managePinModal" tabindex="-1" aria-labelledby="managePinModalLabel" aria-hidden="true" style="z-index: 1080;">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content border-0 rounded-4 shadow">
            <div class="modal-header border-0 bg-light rounded-top-4">
                <h5 class="modal-title fw-bold" id="managePinModalLabel">Manage Campus Landmark Pin</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body p-4">
                <input type="hidden" id="pin-id" value="">
                <input type="hidden" id="pin-lat" value="">
                <input type="hidden" id="pin-lng" value="">
                
                <div class="mb-3">
                    <label for="pin-name" class="form-label small fw-semibold">Landmark Name</label>
                    <input type="text" class="form-control" id="pin-name" placeholder="e.g. Canteen, Academic Block B..." required>
                </div>
                <div class="row g-2">
                    <div class="col">
                        <label class="form-label small text-muted mb-1">X Coordinate (%)</label>
                        <input type="text" class="form-control form-control-sm" id="pin-lng-disp" readonly>
                    </div>
                    <div class="col">
                        <label class="form-label small text-muted mb-1">Y Coordinate (%)</label>
                        <input type="text" class="form-control form-control-sm" id="pin-lat-disp" readonly>
                    </div>
                </div>
            </div>
            <div class="modal-footer border-0 p-3 bg-light rounded-bottom-4 justify-content-between">
                <div>
                    <button type="button" class="btn btn-danger" id="delete-pin-btn" style="display: none;" onclick="submitDeletePin()">Delete Pin</button>
                </div>
                <div>
                    <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                    <button type="button" class="btn btn-indigo text-white px-4" style="background-color: #4f46e5;" onclick="submitSavePin()">Save Pin</button>
                </div>
            </div>
        </div>
    </div>
</div>
<% } %>

<script>
    let scale = 1;
    let translate = { x: 0, y: 0 };
    let isDragging = false;
    let startCoords = { x: 0, y: 0 };
    
    const viewport = document.querySelector('.blueprint-viewport');
    const wrapper = document.getElementById('blueprint-wrapper');
    
    function updateTransform() {
        wrapper.style.transform = `scale(${scale}) translate(${translate.x}px, ${translate.y}px)`;
    }
    
    function zoomBlueprint(amount) {
        scale = Math.min(Math.max(scale + amount, 0.5), 3.5);
        updateTransform();
    }
    
    function resetBlueprint() {
        scale = 1;
        translate = { x: 0, y: 0 };
        updateTransform();
    }
    
    // Pan mouse drag events
    viewport.addEventListener('mousedown', (e) => {
        // Only trigger drag if clicked on background or image (not on pin elements)
        if (e.target.closest('.blueprint-pin')) return;
        
        e.preventDefault();
        isDragging = true;
        viewport.style.cursor = 'grabbing';
        startCoords = { x: e.clientX - translate.x, y: e.clientY - translate.y };
    });
    
    window.addEventListener('mouseup', () => {
        isDragging = false;
        viewport.style.cursor = 'grab';
    });
    
    viewport.addEventListener('mousemove', (e) => {
        if (!isDragging) return;
        translate.x = e.clientX - startCoords.x;
        translate.y = e.clientY - startCoords.y;
        updateTransform();
    });
    
    // Zoom via scroll wheel
    viewport.addEventListener('wheel', (e) => {
        e.preventDefault();
        const zoomIntensity = 0.08;
        if (e.deltaY < 0) {
            zoomBlueprint(zoomIntensity);
        } else {
            zoomBlueprint(-zoomIntensity);
        }
    });

    // Handle clicking a pin (Supervisor only triggers edit/delete, standard users do nothing)
    function handlePinClick(event, pinEl) {
        event.stopPropagation(); // Avoid triggering wrapper click
        <% if (isSupervisor) { %>
            const id = pinEl.getAttribute('data-id');
            const name = pinEl.getAttribute('data-name');
            const lat = pinEl.getAttribute('data-lat');
            const lng = pinEl.getAttribute('data-lng');

            document.getElementById('pin-id').value = id;
            document.getElementById('pin-name').value = name;
            document.getElementById('pin-lat').value = lat;
            document.getElementById('pin-lng').value = lng;
            document.getElementById('pin-lat-disp').value = parseFloat(lat).toFixed(1) + "%";
            document.getElementById('pin-lng-disp').value = parseFloat(lng).toFixed(1) + "%";

            document.getElementById('managePinModalLabel').innerText = "Edit Landmark Pin";
            document.getElementById('delete-pin-btn').style.display = "block";

            var pinModal = new bootstrap.Modal(document.getElementById('managePinModal'));
            pinModal.show();
        <% } %>
    }

    // Handle clicking background blueprint image
    function handleBlueprintClick(event) {
        // Prevent click trigger if dragging
        if (isDragging) return;
        <% if (isSupervisor) { %>
            const rect = wrapper.getBoundingClientRect();
            // Calculate percentage click offset relative to the image wrapper
            const clickX = ((event.clientX - rect.left) / rect.width) * 100;
            const clickY = ((event.clientY - rect.top) / rect.height) * 100;

            document.getElementById('pin-id').value = '';
            document.getElementById('pin-name').value = '';
            document.getElementById('pin-lat').value = clickY;
            document.getElementById('pin-lng').value = clickX;
            document.getElementById('pin-lat-disp').value = clickY.toFixed(1) + "%";
            document.getElementById('pin-lng-disp').value = clickX.toFixed(1) + "%";

            document.getElementById('managePinModalLabel').innerText = "Add Predefined Landmark Pin";
            document.getElementById('delete-pin-btn').style.display = "none";

            var pinModal = new bootstrap.Modal(document.getElementById('managePinModal'));
            pinModal.show();
        <% } %>
    }

    // Save pin marker handler
    function submitSavePin() {
        const id = document.getElementById('pin-id').value;
        const name = document.getElementById('pin-name').value;
        const lat = document.getElementById('pin-lat').value;
        const lng = document.getElementById('pin-lng').value;

        if (!name || name.trim() === '') {
            alert("Marker name is required!");
            return;
        }

        const formData = new URLSearchParams();
        if (id) {
            formData.append('action', 'edit');
            formData.append('locationId', id);
        } else {
            formData.append('action', 'add');
        }
        formData.append('name', name);
        formData.append('latitude', lat);
        formData.append('longitude', lng);

        fetch('<%= request.getContextPath() %>/campus-map', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: formData.toString()
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                window.location.reload();
            } else {
                alert("Error saving pin: " + (data.error || "Unknown error"));
            }
        })
        .catch(err => console.error("Error saving pin:", err));
    }

    // Delete pin marker handler
    function submitDeletePin() {
        const id = document.getElementById('pin-id').value;
        if (!id) return;
        
        if (!confirm("Are you sure you want to delete this landmark pin?")) {
            return;
        }

        const formData = new URLSearchParams();
        formData.append('action', 'delete');
        formData.append('locationId', id);

        fetch('<%= request.getContextPath() %>/campus-map', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/x-www-form-urlencoded'
            },
            body: formData.toString()
        })
        .then(res => res.json())
        .then(data => {
            if (data.success) {
                window.location.reload();
            } else {
                alert("Error deleting pin: " + (data.error || "Unknown error"));
            }
        })
        .catch(err => console.error("Error deleting pin:", err));
    }
</script>

<jsp:include page="/jsp/common/footer.jsp" />
