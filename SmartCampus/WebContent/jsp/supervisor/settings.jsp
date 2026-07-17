<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Supervisor" %>
<%
    Supervisor supervisor = (Supervisor) session.getAttribute("supervisor");
    if (supervisor == null) {
        response.sendRedirect(request.getContextPath() + "/login?role=supervisor");
        return;
    }
    
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
            <!-- Alert Messages -->
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

            <div class="row g-4">
                <!-- Profile Summary card -->
                <div class="col-md-5">
                    <div class="glass-panel text-center">
                        <div class="user-avatar mx-auto mb-3" style="width: 80px; height: 80px; font-size: 2.2rem; background: linear-gradient(135deg, #eab308, #e0a905); color:#212529;">
                            <%= supervisor.getName().substring(0, 1).toUpperCase() %>
                        </div>
                        <h4 class="fw-bold mb-1"><%= supervisor.getName() %></h4>
                        <p class="text-secondary small mb-4">Facility Supervisor</p>
                        
                        <div class="border-top pt-3 text-start small">
                            <div class="mb-2"><strong>Email:</strong> <span class="text-secondary"><%= supervisor.getEmail() %></span></div>
                            <div class="mb-2"><strong>Phone:</strong> <span class="text-secondary"><%= supervisor.getPhoneNo() %></span></div>
                        </div>
                    </div>
                </div>

                <!-- Profile Editing form -->
                <div class="col-md-7">
                    <div class="glass-panel">
                        <h5 class="fw-bold mb-3"><i class="bi bi-person-fill-gear text-warning me-2"></i> Edit Supervisor Profile</h5>
                        <form action="<%= request.getContextPath() %>/supervisor" method="POST">
                            <input type="hidden" name="action" value="updateProfile">

                            <div class="mb-3">
                                <label for="name" class="form-label fw-semibold">Full Name</label>
                                <input type="text" class="form-control rounded-3" id="name" name="name" value="<%= supervisor.getName() %>" required>
                            </div>

                            <div class="mb-3">
                                <label for="phoneNo" class="form-label fw-semibold">Phone Number</label>
                                <input type="text" class="form-control rounded-3" id="phoneNo" name="phoneNo" value="<%= supervisor.getPhoneNo() %>" required>
                            </div>

                            <!-- Department field removed -->

                            <div class="d-flex justify-content-end">
                                <button type="submit" class="btn btn-warning text-dark px-5 py-2 fw-semibold">Save Profile Updates</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
