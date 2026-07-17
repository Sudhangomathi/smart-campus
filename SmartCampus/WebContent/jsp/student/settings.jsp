<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="model.Student" %>
<%
    Student student = (Student) session.getAttribute("student");
    if (student == null) {
        response.sendRedirect(request.getContextPath() + "/login?role=student");
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
            <!-- Messages -->
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
                <!-- Profile details card -->
                <div class="col-md-5">
                    <div class="glass-panel text-center">
                        <div class="user-avatar mx-auto mb-3" style="width: 80px; height: 80px; font-size: 2.2rem; background: linear-gradient(135deg, #4f46e5, #818cf8);">
                            <%= student.getName().substring(0, 1).toUpperCase() %>
                        </div>
                        <h4 class="fw-bold mb-1"><%= student.getName() %></h4>
                        <p class="text-secondary small mb-4"></p>
                        
                        <div class="border-top pt-3 text-start small">
                            <div class="mb-2"><strong>Email:</strong> <span class="text-secondary"><%= student.getEmail() %></span></div>
                            <div class="mb-2"><strong>Phone:</strong> <span class="text-secondary"><%= student.getPhoneNo() %></span></div>
                            <div class="mb-2"><strong>Department:</strong> <span class="text-secondary"><%= student.getDepartment() %></span></div>
                        </div>
                    </div>
                </div>

                <!-- Profile Editing form -->
                <div class="col-md-7">
                    <div class="glass-panel">
                        <h5 class="fw-bold mb-3"><i class="bi bi-person-fill-gear text-indigo me-2" style="color: #4f46e5;"></i> Edit Profile Details</h5>
                        <form action="<%= request.getContextPath() %>/student" method="POST">
                            <input type="hidden" name="action" value="updateProfile">

                            <div class="mb-3">
                                <label for="name" class="form-label fw-semibold">Full Name</label>
                                <input type="text" class="form-control rounded-3" id="name" name="name" value="<%= student.getName() %>" required>
                            </div>

                            <div class="mb-3">
                                <label for="phoneNo" class="form-label fw-semibold">Phone Number</label>
                                <input type="text" class="form-control rounded-3" id="phoneNo" name="phoneNo" value="<%= student.getPhoneNo() %>" required>
                            </div>

                            <div class="mb-4">
                                <label for="department" class="form-label fw-semibold">Department</label>
                                <input type="text" class="form-control rounded-3" id="department" name="department" value="<%= student.getDepartment() != null ? student.getDepartment() : "" %>" placeholder="e.g. Computer Science &amp; Engineering" required>
                            </div>

                            <div class="d-flex justify-content-end">
                                <button type="submit" class="btn btn-indigo text-white px-5 py-2" style="background-color: #4f46e5;">Save Profile Updates</button>
                            </div>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<jsp:include page="/jsp/common/footer.jsp" />
