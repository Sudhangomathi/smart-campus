package controller;

import dao.CampusBlueprintDAO;
import model.CampusBlueprint;
import model.Supervisor;

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

@WebServlet("/campus-blueprint")
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
    maxFileSize = 1024 * 1024 * 15,       // 15MB
    maxRequestSize = 1024 * 1024 * 60     // 60MB
)
public class CampusBlueprintServlet extends HttpServlet {
    private final CampusBlueprintDAO blueprintDAO = new CampusBlueprintDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        
        // Verify that at least one valid user role session is active
        if (session.getAttribute("student") == null && 
            session.getAttribute("supervisor") == null && 
            session.getAttribute("worker") == null) {
            response.sendRedirect(request.getContextPath() + "/login?role=student");
            return;
        }

        CampusBlueprint blueprint = blueprintDAO.getLatestBlueprint();
        request.setAttribute("blueprint", blueprint);

        dao.CampusLocationDAO locationDAO = new dao.CampusLocationDAO();
        request.setAttribute("locations", locationDAO.getAllLocations());
        
        request.getRequestDispatcher("/jsp/common/campus_blueprint.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession();
        Supervisor supervisor = (Supervisor) session.getAttribute("supervisor");
        
        // Only Supervisor role is permitted to upload or update the campus blueprint
        if (supervisor == null) {
            response.sendError(HttpServletResponse.SC_FORBIDDEN, "Only the Supervisor can upload, update, or replace the campus blueprint.");
            return;
        }

        try {
            Part filePart = request.getPart("blueprintImage");
            if (filePart != null && filePart.getSize() > 0) {
                String fileName = filePart.getSubmittedFileName();
                // Basic validation for image formats
                if (fileName != null && (fileName.toLowerCase().endsWith(".png") || 
                                         fileName.toLowerCase().endsWith(".jpg") || 
                                         fileName.toLowerCase().endsWith(".jpeg") || 
                                         fileName.toLowerCase().endsWith(".svg") || 
                                         fileName.toLowerCase().endsWith(".webp"))) {
                    
                    String appPath = request.getServletContext().getRealPath("");
                    String saveDir = "uploads";
                    String fileUploadPath = appPath + File.separator + saveDir;
                    
                    File fileSaveDir = new File(fileUploadPath);
                    if (!fileSaveDir.exists()) {
                        fileSaveDir.mkdir();
                    }
                    
                    String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
                    filePart.write(fileUploadPath + File.separator + uniqueFileName);
                    
                    String relativePath = request.getContextPath() + "/" + saveDir + "/" + uniqueFileName;
                    boolean success = blueprintDAO.saveBlueprint(relativePath);
                    
                    if (success) {
                        response.sendRedirect(request.getContextPath() + "/campus-blueprint?success=Blueprint+updated+successfully!");
                    } else {
                        response.sendRedirect(request.getContextPath() + "/campus-blueprint?error=Database+save+failed.");
                    }
                } else {
                    response.sendRedirect(request.getContextPath() + "/campus-blueprint?error=Invalid+file+format.+Only+images+are+allowed.");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/campus-blueprint?error=Please+select+a+file+to+upload.");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/campus-blueprint?error=An+unexpected+error+occurred.");
        }
    }
}
