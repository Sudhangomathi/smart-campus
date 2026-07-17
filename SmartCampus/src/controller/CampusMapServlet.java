package controller;

import dao.CampusLocationDAO;
import dao.ComplaintDAO;
import model.CampusLocation;
import model.Complaint;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.util.List;

@WebServlet("/campus-map")
public class CampusMapServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    
    private final CampusLocationDAO campusLocationDAO = new CampusLocationDAO();
    private final ComplaintDAO complaintDAO = new ComplaintDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        if ("getLocations".equalsIgnoreCase(action)) {
            List<CampusLocation> locations = campusLocationDAO.getAllLocations();
            out.print(buildLocationsJson(locations));
        } else if ("getComplaints".equalsIgnoreCase(action)) {
            List<Complaint> complaints = complaintDAO.searchAndFilterComplaints(null, null, null, null);
            out.print(buildComplaintsJson(complaints));
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Invalid action\"}");
        }
        out.flush();
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response) 
            throws ServletException, IOException {
        String action = request.getParameter("action");
        response.setContentType("application/json");
        response.setCharacterEncoding("UTF-8");
        PrintWriter out = response.getWriter();

        // Check if supervisor role is active for modify operations
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("user") == null || !"supervisor".equals(session.getAttribute("role"))) {
            response.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            out.print("{\"error\":\"Unauthorized\"}");
            out.flush();
            return;
        }

        if ("add".equalsIgnoreCase(action)) {
            try {
                String name = request.getParameter("name");
                double latitude = Double.parseDouble(request.getParameter("latitude"));
                double longitude = Double.parseDouble(request.getParameter("longitude"));

                if (name == null || name.trim().isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\":\"Pin name is required\"}");
                } else {
                    CampusLocation loc = new CampusLocation(name.trim(), latitude, longitude);
                    boolean success = campusLocationDAO.addLocation(loc);
                    if (success) {
                        out.print("{\"success\":true,\"locationId\":" + loc.getLocationId() + "}");
                    } else {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        out.print("{\"error\":\"Failed to save pin\"}");
                    }
                }
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Invalid parameters\"}");
            }
        } else if ("delete".equalsIgnoreCase(action)) {
            try {
                int locationId = Integer.parseInt(request.getParameter("locationId"));
                boolean success = campusLocationDAO.deleteLocation(locationId);
                if (success) {
                    out.print("{\"success\":true}");
                } else {
                    response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                    out.print("{\"error\":\"Failed to delete pin\"}");
                }
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Invalid parameters\"}");
            }
        } else if ("edit".equalsIgnoreCase(action)) {
            try {
                int locationId = Integer.parseInt(request.getParameter("locationId"));
                String name = request.getParameter("name");
                double latitude = Double.parseDouble(request.getParameter("latitude"));
                double longitude = Double.parseDouble(request.getParameter("longitude"));

                if (name == null || name.trim().isEmpty()) {
                    response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                    out.print("{\"error\":\"Pin name is required\"}");
                } else {
                    boolean success = campusLocationDAO.updateLocation(locationId, name.trim(), latitude, longitude);
                    if (success) {
                        out.print("{\"success\":true}");
                    } else {
                        response.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                        out.print("{\"error\":\"Failed to update pin\"}");
                    }
                }
            } catch (Exception e) {
                response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                out.print("{\"error\":\"Invalid parameters\"}");
            }
        } else {
            response.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            out.print("{\"error\":\"Invalid action\"}");
        }
        out.flush();
    }

    private String buildLocationsJson(List<CampusLocation> locations) {
        StringBuilder json = new StringBuilder("[");
        for (int i = 0; i < locations.size(); i++) {
            CampusLocation loc = locations.get(i);
            json.append("{")
                .append("\"locationId\":").append(loc.getLocationId()).append(",")
                .append("\"name\":\"").append(escapeJson(loc.getName())).append("\",")
                .append("\"latitude\":").append(loc.getLatitude()).append(",")
                .append("\"longitude\":").append(loc.getLongitude())
                .append("}");
            if (i < locations.size() - 1) {
                json.append(",");
            }
        }
        json.append("]");
        return json.toString();
    }

    private String buildComplaintsJson(List<Complaint> complaints) {
        StringBuilder json = new StringBuilder("[");
        boolean first = true;
        for (Complaint c : complaints) {
            if (c.getLatitude() == null || c.getLongitude() == null) {
                continue;
            }
            if (!first) {
                json.append(",");
            }
            json.append("{")
                .append("\"complaintId\":").append(c.getComplaintId()).append(",")
                .append("\"title\":\"").append(escapeJson(c.getTitle())).append("\",")
                .append("\"description\":\"").append(escapeJson(c.getDescription())).append("\",")
                .append("\"category\":\"").append(escapeJson(c.getCategory())).append("\",")
                .append("\"building\":\"").append(escapeJson(c.getBuilding())).append("\",")
                .append("\"roomNo\":\"").append(escapeJson(c.getRoomNo())).append("\",")
                .append("\"priority\":\"").append(escapeJson(c.getPriority())).append("\",")
                .append("\"status\":\"").append(escapeJson(c.getStatus())).append("\",")
                .append("\"latitude\":").append(c.getLatitude()).append(",")
                .append("\"longitude\":").append(c.getLongitude())
                .append("}");
            first = false;
        }
        json.append("]");
        return json.toString();
    }

    private String escapeJson(String val) {
        if (val == null) {
            return "";
        }
        return val.replace("\\", "\\\\")
                  .replace("\"", "\\\"")
                  .replace("\r", "\\r")
                  .replace("\n", "\\n")
                  .replace("\t", "\\t");
    }
}
