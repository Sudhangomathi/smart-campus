package utility;

import model.Complaint;
import dao.ComplaintDAO;
import java.util.ArrayList;

public class TestInsert {
    public static void main(String[] args) {
        try {
            ComplaintDAO dao = new ComplaintDAO();
            Complaint c = new Complaint();
            c.setStudentId(1);
            c.setTitle("Test Title");
            c.setDescription("Test Description");
            c.setCategory("Electrical");
            c.setBuilding("Academic Block A");
            c.setBlock("Block A");
            c.setFloor("Ground Floor");
            c.setRoomNo("101");
            c.setPriority("Low");
            c.setLatitude(12.34);
            c.setLongitude(56.78);
            
            boolean ok = dao.raiseComplaint(c, new ArrayList<>());
            System.out.println("Insert result: " + ok);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
