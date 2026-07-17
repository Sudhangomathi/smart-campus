<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Registration - Smart Campus</title>
    <!-- Bootstrap 5 CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <!-- Bootstrap Icons -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.2/font/bootstrap-icons.min.css">
    <!-- Custom Style Sheet -->
    <link rel="stylesheet" href="<%= request.getContextPath() %>/css/style.css?v=3">
</head>
<body>

    <div class="portal-container">
        <!-- Left Side: Branding & Welcome Message -->
        <div class="portal-left">
            <div class="portal-left-content">
                <img src="<%= request.getContextPath() %>/images/college_logo.png" alt="College Logo" class="portal-logo">
                <h1 class="portal-title">Smart Campus</h1>
                <p class="portal-subtitle">Complaint Redressal &amp; Maintenance Portal</p>
            </div>
        </div>

        <!-- Right Side: Sign Up Process -->
        <div class="portal-right">
            <div class="portal-card">
                <h3 class="fw-bold login-title text-center mb-4">Create Account</h3>

                <% if (request.getAttribute("error") != null) { %>
                    <div class="alert alert-danger alert-dismissible fade show bg-danger bg-opacity-10 text-danger border-danger border-opacity-10" role="alert">
                        <i class="bi bi-exclamation-triangle-fill me-2"></i> <%= request.getAttribute("error") %>
                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                    </div>
                <% } %>

                <form id="registerForm" action="<%= request.getContextPath() %>/student" method="POST">
                    <input type="hidden" name="action" value="register">

                    <!-- Role Selection -->
                    <div class="mb-3">
                        <label for="role" class="form-label login-label small">Select Registration Role</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-person-badge-fill"></i></span>
                            <select class="form-select" id="role" name="role" onchange="toggleRoleFields()" required>
                                <option value="student" selected>Student</option>
                                <option value="worker">Worker / Maintenance Staff</option>
                                <option value="supervisor">Supervisor</option>
                            </select>
                        </div>
                    </div>

                    <!-- Standard Fields: Full Name & Phone Number -->
                    <div class="row">
                        <div class="col-md-6 mb-3">
                            <label for="name" class="form-label login-label small">Full Name</label>
                            <input type="text" class="form-control" id="name" name="name" placeholder="John Doe" required>
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="phoneNo" class="form-label login-label small">Phone Number</label>
                            <input type="tel" class="form-control" id="phoneNo" name="phoneNo" placeholder="9876543210" required>
                        </div>
                    </div>

                    <!-- Dynamic Student-Specific Fields -->
                    <div id="studentFields" class="row">
                        <div class="col-md-6 mb-3">
                            <label for="rollNo" class="form-label login-label small">Roll Number</label>
                            <input type="text" class="form-control" id="rollNo" name="rollNo" placeholder="CS2026001">
                        </div>
                        <div class="col-md-6 mb-3">
                            <label for="department" class="form-label login-label small">Department</label>
                            <input type="text" class="form-control" id="department" name="department" placeholder="e.g. CSE">
                        </div>
                    </div>

                    <!-- Dynamic Worker-Specific Fields -->
                    <div id="workerFields" class="mb-3" style="display: none;">
                        <label for="specialization" class="form-label login-label small">Specialization / Skills</label>
                        <div class="input-group">
                            <span class="input-group-text"><i class="bi bi-tools"></i></span>
                            <select class="form-select" id="specialization" name="specialization">
                                <option value="" disabled selected>Select Skills</option>
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
                                <option value="Others">Others</option>
                            </select>
                        </div>
                    </div>

                    <!-- Email Address -->
                    <div class="mb-3">
                        <label for="email" class="form-label login-label small">Email Address (Username)</label>
                        <input type="email" class="form-control" id="email" name="email" placeholder="john.doe@campus.edu" required>
                    </div>

                    <!-- Password -->
                    <div class="mb-4">
                        <label for="password" class="form-label login-label small">Password</label>
                        <input type="password" class="form-control" id="password" name="password" placeholder="••••••••" required>
                    </div>

                    <button type="submit" class="btn btn-indigo w-100 py-2 fw-bold text-white mb-3">Register Account</button>
                </form>

                <div class="text-center mt-3 border-top pt-3">
                    <p class="login-label small mb-0">Already have an account? <a href="<%= request.getContextPath() %>/login" class="text-indigo fw-bold text-decoration-none">Sign In here</a></p>
                </div>
            </div>
        </div>
    </div>

    <!-- Bootstrap Bundle -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>

    <!-- JavaScript to toggle role fields dynamically -->
    <script>
        function toggleRoleFields() {
            const role = document.getElementById("role").value;
            const form = document.getElementById("registerForm");
            
            const studentFields = document.getElementById("studentFields");
            const workerFields = document.getElementById("workerFields");
            
            const rollNoInput = document.getElementById("rollNo");
            const deptInput = document.getElementById("department");
            const specializationSelect = document.getElementById("specialization");
            
            // Context Path extraction
            const contextPath = "<%= request.getContextPath() %>";

            if (role === "student") {
                form.action = contextPath + "/student";
                studentFields.style.display = "flex";
                workerFields.style.display = "none";
                
                rollNoInput.required = true;
                deptInput.required = true;
                specializationSelect.required = false;
            } else if (role === "worker") {
                form.action = contextPath + "/worker";
                studentFields.style.display = "none";
                workerFields.style.display = "block";
                
                rollNoInput.required = false;
                deptInput.required = false;
                specializationSelect.required = true;
            } else if (role === "supervisor") {
                form.action = contextPath + "/supervisor";
                studentFields.style.display = "none";
                workerFields.style.display = "none";
                
                rollNoInput.required = false;
                deptInput.required = false;
                specializationSelect.required = false;
            }
        }

        // Initialize fields validation on load
        window.addEventListener("DOMContentLoaded", () => {
            toggleRoleFields();
        });
    </script>
</body>
</html>
