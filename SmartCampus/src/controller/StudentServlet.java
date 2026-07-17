package controller;

import dao.ComplaintDAO;
import dao.FeedbackDAO;
import dao.NotificationDAO;
import dao.UserDAO;
import dao.ActivityLogDAO;
import model.Complaint;
import model.Feedback;
import model.Student;
import model.User;

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

@WebServlet("/student")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 10,       // 10MB
    maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class StudentServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final ComplaintDAO complaintDAO = new ComplaintDAO();
    private final FeedbackDAO feedbackDAO = new FeedbackDAO();
    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final ActivityLogDAO logDAO = new ActivityLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("forgot".equals(action)) {
            request.getRequestDispatcher("/jsp/student/forgot_password.jsp").forward(request, response);
            return;
        }
        
        // Default student redirect
        response.sendRedirect(request.getContextPath() + "/jsp/student/dashboard.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");

        if ("register".equals(action)) {
            handleRegister(request, response);
        } else if ("forgotPassword".equals(action)) {
            handleForgotPassword(request, response);
        } else {
            // Require session and student role for subsequent operations
            HttpSession session = request.getSession(false);
            if (session == null || session.getAttribute("user") == null || !"student".equals(session.getAttribute("role"))) {
                response.sendRedirect(request.getContextPath() + "/login?role=student");
                return;
            }

            if ("raise".equals(action)) {
                handleRaiseComplaint(request, response);
            } else if ("feedback".equals(action)) {
                handleFeedback(request, response);
            } else if ("updateProfile".equals(action)) {
                handleUpdateProfile(request, response);
            }
        }
    }

    private void handleRegister(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String name = request.getParameter("name");
        String rollNo = request.getParameter("rollNo");
        String phoneNo = request.getParameter("phoneNo");
        String department = request.getParameter("department");
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        Student student = new Student(0, name, rollNo, phoneNo, department);
        boolean success = userDAO.registerStudent(student, email, password);

        if (success) {
            logDAO.logActivity(student.getStudentId(), "Student registered account: " + email);
            notificationDAO.createNotification(student.getStudentId(), "Welcome to Smart Campus Portal, registration successful!");
            response.sendRedirect(request.getContextPath() + "/login?role=student&msg=Registration successful! Please log in.");
        } else {
            request.setAttribute("error", "Registration failed. Email or Roll Number might already exist.");
            request.getRequestDispatcher("/jsp/student/register.jsp").forward(request, response);
        }
    }

    private void handleForgotPassword(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String newPassword = request.getParameter("newPassword");
        String confirmPassword = request.getParameter("confirmPassword");

        if (newPassword == null || !newPassword.equals(confirmPassword)) {
            request.setAttribute("error", "Passwords do not match.");
            request.getRequestDispatcher("/jsp/student/forgot_password.jsp").forward(request, response);
            return;
        }

        boolean success = userDAO.updatePassword(email, newPassword);
        if (success) {
            response.sendRedirect(request.getContextPath() + "/login?role=student&msg=Password reset successful. Please log in.");
        } else {
            request.setAttribute("error", "Failed to reset password. Email not found.");
            request.getRequestDispatcher("/jsp/student/forgot_password.jsp").forward(request, response);
        }
    }

    private void handleRaiseComplaint(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Student student = (Student) session.getAttribute("student");
        User user = (User) session.getAttribute("user");

        String title = request.getParameter("title");
        String description = request.getParameter("description");
        String category = request.getParameter("category");
        String building = request.getParameter("building");
        String block = request.getParameter("block");
        String floor = request.getParameter("floor");
        String roomNo = request.getParameter("roomNo");
        String priority = request.getParameter("priority");
        Double latitude = null;
        Double longitude = null;
        try {
            if (request.getParameter("latitude") != null && !request.getParameter("latitude").isEmpty()) {
                latitude = Double.parseDouble(request.getParameter("latitude"));
            }
            if (request.getParameter("longitude") != null && !request.getParameter("longitude").isEmpty()) {
                longitude = Double.parseDouble(request.getParameter("longitude"));
            }
        } catch (NumberFormatException e) {
            e.printStackTrace();
        }

        Complaint complaint = new Complaint();
        complaint.setStudentId(student.getStudentId());
        complaint.setTitle(title);
        complaint.setDescription(description);
        complaint.setCategory(category);
        complaint.setBuilding(building);
        complaint.setBlock(block);
        complaint.setFloor(floor);
        complaint.setRoomNo(roomNo);
        complaint.setPriority(priority);
        complaint.setLatitude(latitude);
        complaint.setLongitude(longitude);

        // Upload images handling
        String appPath = request.getServletContext().getRealPath("");
        String saveDir = "uploads";
        String fileUploadPath = appPath + File.separator + saveDir;
        File fileSaveDir = new File(fileUploadPath);
        if (!fileSaveDir.exists()) {
            fileSaveDir.mkdir();
        }

        List<String> imagePaths = new ArrayList<>();
        Collection<Part> parts = request.getParts();
        for (Part part : parts) {
            if (part.getName().equals("images") && part.getSize() > 0) {
                String fileName = System.currentTimeMillis() + "_" + extractFileName(part);
                if (fileName != null && !fileName.trim().isEmpty() && !fileName.endsWith("_")) {
                    part.write(fileUploadPath + File.separator + fileName);
                    imagePaths.add(request.getContextPath() + "/" + saveDir + "/" + fileName);
                }
            }
        }

        boolean success = complaintDAO.raiseComplaint(complaint, imagePaths);

        if (success) {
            logDAO.logActivity(user.getUserId(), "Raised new complaint: " + title);
            notificationDAO.createNotification(user.getUserId(), "Your complaint '" + title + "' has been submitted successfully!");
            
            // Notify Supervisor (User ID 2 in seed data)
            notificationDAO.createNotification(2, "New complaint raised: '" + title + "' (Category: " + category + ")");
            
            response.sendRedirect(request.getContextPath() + "/jsp/student/history.jsp?msg=Complaint submitted successfully!");
        } else {
            request.setAttribute("error", "Failed to submit complaint. Please check your database settings.");
            request.getRequestDispatcher("/jsp/student/raise_complaint.jsp").forward(request, response);
        }
    }

    private void handleFeedback(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Student student = (Student) session.getAttribute("student");

        int complaintId = Integer.parseInt(request.getParameter("complaintId"));
        int rating = Integer.parseInt(request.getParameter("rating"));
        String comment = request.getParameter("comment");
        String satisfactionLevel = request.getParameter("satisfactionLevel");

        Feedback feedback = new Feedback();
        feedback.setComplaintId(complaintId);
        feedback.setStudentId(student.getStudentId());
        feedback.setRating(rating);
        feedback.setFeedback(comment);
        feedback.setSatisfactionLevel(satisfactionLevel);

        boolean success = feedbackDAO.submitFeedback(feedback);
        if (success) {
            complaintDAO.updateComplaintStatus(complaintId, "Closed");
            // Update complaint status to closed or log it
            logDAO.logActivity(student.getStudentId(), "Submitted feedback for complaint ID: " + complaintId + " with rating: " + rating);
            notificationDAO.createNotification(student.getStudentId(), "Thank you for sharing your feedback!");
            
            // Notify supervisor (User ID 2)
            notificationDAO.createNotification(2, "New student feedback submitted for complaint ID: " + complaintId + ". Status set to Closed.");
            
            response.sendRedirect(request.getContextPath() + "/jsp/student/history.jsp?msg=Feedback submitted successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/jsp/student/history.jsp?error=Failed to submit feedback.");
        }
    }

    private void handleUpdateProfile(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Student student = (Student) session.getAttribute("student");

        String name = request.getParameter("name");
        String phoneNo = request.getParameter("phoneNo");
        String department = request.getParameter("department");

        student.setName(name);
        student.setPhoneNo(phoneNo);
        student.setDepartment(department);

        boolean success = userDAO.updateStudentProfile(student);
        if (success) {
            session.setAttribute("student", student);
            logDAO.logActivity(student.getStudentId(), "Updated student profile details");
            response.sendRedirect(request.getContextPath() + "/jsp/student/settings.jsp?msg=Profile updated successfully!");
        } else {
            response.sendRedirect(request.getContextPath() + "/jsp/student/settings.jsp?error=Failed to update profile.");
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
}
