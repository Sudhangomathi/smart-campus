package controller;

import dao.UserDAO;
import dao.ActivityLogDAO;
import model.User;
import model.Student;
import model.Supervisor;
import model.Worker;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private final UserDAO userDAO = new UserDAO();
    private final ActivityLogDAO logDAO = new ActivityLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String email = request.getParameter("email");
        String password = request.getParameter("password");

        if (email == null || password == null || email.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "All fields are required.");
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.authenticate(email, password);

        if (user != null) {
            HttpSession session = request.getSession(true);
            session.setAttribute("user", user);
            session.setAttribute("role", user.getRole());

            logDAO.logActivity(user.getUserId(), "User logged in with role: " + user.getRole());

            if (user.getRole().equalsIgnoreCase("student")) {
                Student student = userDAO.getStudentByUserId(user.getUserId());
                session.setAttribute("student", student);
                response.sendRedirect(request.getContextPath() + "/jsp/student/dashboard.jsp");
            } else if (user.getRole().equalsIgnoreCase("supervisor")) {
                Supervisor supervisor = userDAO.getSupervisorByUserId(user.getUserId());
                session.setAttribute("supervisor", supervisor);
                response.sendRedirect(request.getContextPath() + "/jsp/supervisor/dashboard.jsp");
            } else if (user.getRole().equalsIgnoreCase("worker")) {
                Worker worker = userDAO.getWorkerByUserId(user.getUserId());
                session.setAttribute("worker", worker);
                response.sendRedirect(request.getContextPath() + "/jsp/worker/dashboard.jsp");
            } else {
                request.setAttribute("error", "Role not supported.");
                request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
            }
        } else {
            request.setAttribute("error", "Invalid email or password.");
            request.getRequestDispatcher("/jsp/login.jsp").forward(request, response);
        }
    }
}
