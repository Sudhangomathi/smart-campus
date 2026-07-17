package controller;

import dao.AssignmentDAO;
import dao.ComplaintDAO;
import dao.NotificationDAO;
import dao.UserDAO;
import dao.ActivityLogDAO;
import model.Assignment;
import model.Complaint;
import model.Supervisor;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/supervisor")
public class SupervisorServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final ComplaintDAO complaintDAO = new ComplaintDAO();
    private final AssignmentDAO assignmentDAO = new AssignmentDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final ActivityLogDAO logDAO = new ActivityLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        // Default redirect
        response.sendRedirect(request.getContextPath() + "/jsp/supervisor/dashboard.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("register".equals(action)) {
            handleRegister(request, response);
        } else {
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user") == null || !"supervisor".equals(session.getAttribute("role"))) {
                response.sendRedirect(request.getContextPath() + "/login?role=supervisor");
                return;
            }

            Supervisor supervisor = (Supervisor) session.getAttribute("supervisor");

            if ("assign".equals(action)) {
                handleAssignWorker(request, response, supervisor);
            } else if ("updatePriority".equals(action)) {
                handleUpdatePriority(request, response, supervisor);
            } else if ("updateStatus".equals(action)) {
                handleUpdateStatus(request, response, supervisor);
            } else if ("updateProfile".equals(action)) {
                handleUpdateProfile(request, response, supervisor);
            }
        }
    }

    private void handleRegister(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String phoneNo = request.getParameter("phoneNo");
        String department = "";
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        Supervisor supervisor = new Supervisor(0, name, phoneNo, department);
        boolean success = userDAO.registerSupervisor(supervisor, email, password);

        if (success) {
            logDAO.logActivity(supervisor.getSupervisorId(), "Supervisor registered account: " + email);
            notificationDAO.createNotification(supervisor.getSupervisorId(), "Welcome, registration successful!");
            response.sendRedirect(request.getContextPath() + "/login?role=supervisor&msg=Registration successful! Please log in.");
        } else {
            request.setAttribute("error", "Registration failed. Email might already exist.");
            request.getRequestDispatcher("/jsp/student/register.jsp").forward(request, response);
        }
    }


    private void handleAssignWorker(HttpServletRequest request, HttpServletResponse response, Supervisor supervisor) 
            throws ServletException, IOException {
        int complaintId = Integer.parseInt(request.getParameter("complaintId"));
        int workerId = Integer.parseInt(request.getParameter("workerId"));

        Assignment assignment = new Assignment();
        assignment.setComplaintId(complaintId);
        assignment.setWorkerId(workerId);
        assignment.setAssignedBy(supervisor.getSupervisorId());

        boolean success = assignmentDAO.assignWorker(assignment);
        if (success) {
            Complaint complaint = complaintDAO.getComplaintById(complaintId);
            
            // Log activity
            logDAO.logActivity(supervisor.getSupervisorId(), "Assigned complaint ID: " + complaintId + " to worker ID: " + workerId);
            
            // Notify Worker
            notificationDAO.createNotification(workerId, "New task assigned: '" + complaint.getTitle() + "' at Room " + complaint.getRoomNo());
            
            // Notify Student
            notificationDAO.createNotification(complaint.getStudentId(), "Your complaint '" + complaint.getTitle() + "' has been assigned to worker: " + complaint.getAssignedWorkerName());

            response.sendRedirect(request.getContextPath() + "/jsp/supervisor/complaints.jsp?msg=Worker assigned successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/jsp/supervisor/complaints.jsp?error=Failed to assign worker.");
        }
    }

    private void handleUpdatePriority(HttpServletRequest request, HttpServletResponse response, Supervisor supervisor) 
            throws ServletException, IOException {
        int complaintId = Integer.parseInt(request.getParameter("complaintId"));
        String priority = request.getParameter("priority");

        boolean success = complaintDAO.updateComplaintPriority(complaintId, priority);
        if (success) {
            logDAO.logActivity(supervisor.getSupervisorId(), "Updated priority of complaint ID: " + complaintId + " to: " + priority);
            response.sendRedirect(request.getContextPath() + "/jsp/supervisor/complaints.jsp?msg=Priority updated successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/jsp/supervisor/complaints.jsp?error=Failed to update priority.");
        }
    }

    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response, Supervisor supervisor) 
            throws ServletException, IOException {
        int complaintId = Integer.parseInt(request.getParameter("complaintId"));
        String status = request.getParameter("status");

        boolean success = complaintDAO.updateComplaintStatus(complaintId, status);
        if (success) {
            logDAO.logActivity(supervisor.getSupervisorId(), "Updated status of complaint ID: " + complaintId + " to: " + status);
            
            Complaint complaint = complaintDAO.getComplaintById(complaintId);
            if ("Completed".equalsIgnoreCase(status)) {
                notificationDAO.createNotification(complaint.getStudentId(), "Your complaint '" + complaint.getTitle() + "' has been completed! Please rate the service.");
            } else {
                notificationDAO.createNotification(complaint.getStudentId(), "Your complaint '" + complaint.getTitle() + "' status has been updated to: " + status);
            }

            response.sendRedirect(request.getContextPath() + "/jsp/supervisor/complaints.jsp?msg=Status updated successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/jsp/supervisor/complaints.jsp?error=Failed to update status.");
        }
    }

    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response, Supervisor supervisor) 
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String phoneNo = request.getParameter("phoneNo");
        String department = "";

        supervisor.setName(name);
        supervisor.setPhoneNo(phoneNo);
        supervisor.setDepartment(department);

        boolean success = userDAO.updateSupervisorProfile(supervisor);
        if (success) {
            HttpSession session = request.getSession();
            session.setAttribute("supervisor", supervisor);
            logDAO.logActivity(supervisor.getSupervisorId(), "Updated supervisor profile details");
            response.sendRedirect(request.getContextPath() + "/jsp/supervisor/settings.jsp?msg=Profile updated successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/jsp/supervisor/settings.jsp?error=Failed to update profile.");
        }
    }
}
