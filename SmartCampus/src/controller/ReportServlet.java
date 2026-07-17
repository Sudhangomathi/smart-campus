package controller;

import dao.ComplaintDAO;
import model.Complaint;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/supervisor/report")
public class ReportServlet extends HttpServlet {
    private final ComplaintDAO complaintDAO = new ComplaintDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null || !"supervisor".equals(session.getAttribute("role"))) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Access Denied.");
            return;
        }

        String startDate = request.getParameter("startDate");
        String endDate = request.getParameter("endDate");
        String category = request.getParameter("category");
        String building = request.getParameter("building");
        String status = request.getParameter("status");
        String format = request.getParameter("format"); // csv, print

        List<Complaint> list = complaintDAO.getComplaintsByDateRangeAndFilters(startDate, endDate, category, building, status);

        if ("csv".equalsIgnoreCase(format)) {
            response.setContentType("text/csv");
            response.setCharacterEncoding("UTF-8");
            response.setHeader("Content-Disposition", "attachment; filename=\"campus_complaint_report_" + System.currentTimeMillis() + ".csv\"");

            try (PrintWriter writer = response.getWriter()) {
                // BOM for Excel UTF-8 reading
                writer.write('\ufeff');
                writer.println("Complaint ID,Title,Description,Category,Building,Block,Floor,Room,Priority,Status,Created At,Worker Assigned,Completion Date");

                for (Complaint c : list) {
                    writer.println(String.format(
                        "\"%d\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\",\"%s\"",
                        c.getComplaintId(),
                        escapeCsv(c.getTitle()),
                        escapeCsv(c.getDescription()),
                        escapeCsv(c.getCategory()),
                        escapeCsv(c.getBuilding()),
                        escapeCsv(c.getBlock()),
                        escapeCsv(c.getFloor()),
                        escapeCsv(c.getRoomNo()),
                        c.getPriority(),
                        c.getStatus(),
                        c.getCreatedAt() != null ? c.getCreatedAt().toString() : "",
                        c.getAssignedWorkerName() != null ? escapeCsv(c.getAssignedWorkerName()) : "Unassigned",
                        c.getUpdatedAt() != null && "Completed".equals(c.getStatus()) ? c.getUpdatedAt().toString() : "N/A"
                    ));
                }
                writer.flush();
            }
        } else if ("print".equalsIgnoreCase(format)) {
            request.setAttribute("reportData", list);
            request.setAttribute("startDate", startDate);
            request.setAttribute("endDate", endDate);
            request.setAttribute("category", category);
            request.setAttribute("building", building);
            request.setAttribute("status", status);
            request.getRequestDispatcher("/jsp/supervisor/print_report.jsp").forward(request, response);
        } else {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Unknown format: " + format);
        }
    }

    private String escapeCsv(String val) {
        if (val == null) return "";
        return val.replace("\"", "\"\"");
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        doGet(request, response);
    }
}
