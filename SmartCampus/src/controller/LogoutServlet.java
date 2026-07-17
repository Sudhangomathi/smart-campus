package controller;

import dao.ActivityLogDAO;
import model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

@WebServlet("/logout")
public class LogoutServlet extends HttpServlet {
    private final ActivityLogDAO logDAO = new ActivityLogDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        String role = "student";
        if (session != null) {
            User user = (User) session.getAttribute("user");
            if (user != null) {
                logDAO.logActivity(user.getUserId(), "User logged out");
                role = user.getRole();
            }
            session.invalidate();
        }
        
        response.sendRedirect(request.getContextPath() + "/login?role=" + role);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
