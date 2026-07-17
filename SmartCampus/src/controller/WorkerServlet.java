package controller;

import dao.AssignmentDAO;
import dao.ComplaintDAO;
import dao.NotificationDAO;
import dao.UserDAO;
import dao.ActivityLogDAO;
import model.Complaint;
import model.Worker;

import javax.servlet.ServletException;
import javax.servlet.annotation.MultipartConfig;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Part;
import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collection;
import java.util.List;

@WebServlet("/worker")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class WorkerServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final ComplaintDAO complaintDAO = new ComplaintDAO();
    private final AssignmentDAO assignmentDAO = new AssignmentDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final ActivityLogDAO logDAO = new ActivityLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        response.sendRedirect(request.getContextPath() + "/jsp/worker/dashboard.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("register".equals(action)) {
            handleRegister(request, response);
            return;
        }

        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null || !"worker".equals(session.getAttribute("role"))) {
            response.sendRedirect(request.getContextPath() + "/login?role=worker");
            return;
        }

        Worker worker = (Worker) session.getAttribute("worker");

        if ("updateStatus".equals(action)) {
            handleUpdateStatus(request, response, worker);
        } else if ("complete".equals(action)) {
            handleComplete(request, response, worker);
        } else if ("updateProfile".equals(action)) {
            handleUpdateProfile(request, response, worker);
        }
    }

    private void handleUpdateStatus(HttpServletRequest request, HttpServletResponse response, Worker worker) 
            throws ServletException, IOException {
        int complaintId = Integer.parseInt(request.getParameter("complaintId"));
        String status = request.getParameter("status"); // Accepted, In Progress, Rejected
        String remarks = request.getParameter("remarks");

        boolean success = assignmentDAO.updateAssignmentStatus(complaintId, worker.getWorkerId(), status, remarks);
        if (success) {
            logDAO.logActivity(worker.getWorkerId(), "Worker updated assignment status to: " + status + " for complaint ID: " + complaintId);
            Complaint complaint = complaintDAO.getComplaintById(complaintId);
            
            // Notify Supervisor (User ID 2)
            notificationDAO.createNotification(2, "Worker " + worker.getName() + " updated complaint ID: " + complaintId + " status to " + status);

            // Notify Student
            if ("Accepted".equalsIgnoreCase(status)) {
                notificationDAO.createNotification(complaint.getStudentId(), "Worker has accepted your complaint '" + complaint.getTitle() + "' and will begin repairs.");
            } else if ("In Progress".equalsIgnoreCase(status)) {
                notificationDAO.createNotification(complaint.getStudentId(), "Worker has started repair work on your complaint '" + complaint.getTitle() + "'.");
            } else if ("Rejected".equalsIgnoreCase(status)) {
                notificationDAO.createNotification(complaint.getStudentId(), "Worker declined the assignment. It will be reassigned shortly.");
            }

            response.sendRedirect(request.getContextPath() + "/jsp/worker/dashboard.jsp?msg=Status updated successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/jsp/worker/dashboard.jsp?error=Failed to update status.");
        }
    }

    private void handleComplete(HttpServletRequest request, HttpServletResponse response, Worker worker) 
            throws ServletException, IOException {
        int complaintId = Integer.parseInt(request.getParameter("complaintId"));
        String remarks = request.getParameter("remarks");

        // Upload images handling
        String appPath = request.getServletContext().getRealPath("");
        String saveDir = "uploads";
        String fileUploadPath = appPath + File.separator + saveDir;
        File fileSaveDir = new File(fileUploadPath);
        if (!fileSaveDir.exists()) {
            fileSaveDir.mkdir();
        }

        List<String> repairImages = new ArrayList<>();
        Collection<Part> parts = request.getParts();
        for (Part part : parts) {
            if (part.getName().equals("repairImages") && part.getSize() > 0) {
                String fileName = System.currentTimeMillis() + "_repair_" + extractFileName(part);
                if (fileName != null && !fileName.trim().isEmpty() && !fileName.endsWith("_repair_")) {
                    part.write(fileUploadPath + File.separator + fileName);
                    repairImages.add(request.getContextPath() + "/" + saveDir + "/" + fileName);
                }
            }
        }

        boolean success = assignmentDAO.completeAssignment(complaintId, worker.getWorkerId(), remarks, repairImages);
        if (success) {
            logDAO.logActivity(worker.getWorkerId(), "Worker marked complaint ID: " + complaintId + " as Completed");
            Complaint complaint = complaintDAO.getComplaintById(complaintId);

            // Notify Supervisor
            notificationDAO.createNotification(2, "Worker " + worker.getName() + " completed task: '" + complaint.getTitle() + "'");

            // Notify Student
            notificationDAO.createNotification(complaint.getStudentId(), "Your complaint '" + complaint.getTitle() + "' has been resolved by the worker. Please provide feedback and rate the service.");

            response.sendRedirect(request.getContextPath() + "/jsp/worker/dashboard.jsp?msg=Job marked completed!");
        } else {
            response.sendRedirect(request.getContextPath() + "/jsp/worker/dashboard.jsp?error=Failed to submit completion report.");
        }
    }

    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response, Worker worker) 
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String phoneNo = request.getParameter("phoneNo");
        String specialization = request.getParameter("specialization");

        worker.setName(name);
        worker.setPhoneNo(phoneNo);
        worker.setSpecialization(specialization);

        boolean success = userDAO.updateWorkerProfile(worker);
        if (success) {
            HttpSession session = request.getSession();
            session.setAttribute("worker", worker);
            logDAO.logActivity(worker.getWorkerId(), "Updated worker profile details");
            response.sendRedirect(request.getContextPath() + "/jsp/worker/settings.jsp?msg=Profile updated successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/jsp/worker/settings.jsp?error=Failed to update profile.");
        }
    }

    private String extractFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] items = contentDisp.split(";");
        for (String s : items) {
            if (s.trim().startsWith("filename")) {
                return s.substring(s.indexOf("=") + 2, s.length() - 1);
            }
        }
        return "";
    }

    private void handleRegister(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String phoneNo = request.getParameter("phoneNo");
        String specialization = request.getParameter("specialization");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        Worker worker = new Worker();
        worker.setName(name);
        worker.setPhoneNo(phoneNo);
        worker.setSpecialization(specialization);

        boolean success = userDAO.registerWorker(worker, email, password);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/login?role=worker&msg=Registration successful! Please login.");
        } else {
            request.setAttribute("error", "Registration failed. Email might already exist.");
            request.getRequestDispatcher("/jsp/student/register.jsp").forward(request, response);
        }
    }
}
