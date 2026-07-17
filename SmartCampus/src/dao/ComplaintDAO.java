package dao;

import model.Complaint;
import utility.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ComplaintDAO {

    public boolean raiseComplaint(Complaint complaint, List<String> imagePaths) {
        String insertComplaintSql = "INSERT INTO complaints (student_id, title, description, category, building, block, floor, room_no, priority, latitude, longitude, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, 'Pending')";
        String insertLocationSql = "INSERT INTO complaint_locations (complaint_id, address, latitude, longitude) VALUES (?, ?, ?, ?)";
        String insertImageSql = "INSERT INTO complaint_images (complaint_id, image_path) VALUES (?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int complaintId = -1;
            // 1. Insert complaint
            try (PreparedStatement ps = conn.prepareStatement(insertComplaintSql, Statement.RETURN_GENERATED_KEYS)) {
                ps.setInt(1, complaint.getStudentId());
                ps.setString(2, complaint.getTitle());
                ps.setString(3, complaint.getDescription());
                ps.setString(4, complaint.getCategory());
                ps.setString(5, complaint.getBuilding());
                ps.setString(6, complaint.getBlock());
                ps.setString(7, complaint.getFloor());
                ps.setString(8, complaint.getRoomNo());
                ps.setString(9, complaint.getPriority());
                if (complaint.getLatitude() != null) {
                    ps.setDouble(10, complaint.getLatitude());
                } else {
                    ps.setNull(10, Types.DOUBLE);
                }
                if (complaint.getLongitude() != null) {
                    ps.setDouble(11, complaint.getLongitude());
                } else {
                    ps.setNull(11, Types.DOUBLE);
                }
                
                ps.executeUpdate();
                try (ResultSet rs = ps.getGeneratedKeys()) {
                    if (rs.next()) {
                        complaintId = rs.getInt(1);
                    }
                }
            }

            if (complaintId == -1) {
                conn.rollback();
                return false;
            }

            // 2. Insert complaint location
            String locationAddress = String.format("%s, %s, %s, Room %s", 
                complaint.getBuilding(), complaint.getBlock(), complaint.getFloor(), complaint.getRoomNo());
            try (PreparedStatement psLoc = conn.prepareStatement(insertLocationSql)) {
                psLoc.setInt(1, complaintId);
                psLoc.setString(2, locationAddress);
                psLoc.setDouble(3, complaint.getLatitude() != null ? complaint.getLatitude() : 0.0);
                psLoc.setDouble(4, complaint.getLongitude() != null ? complaint.getLongitude() : 0.0);
                psLoc.executeUpdate();
            }

            // 3. Insert complaint images
            if (imagePaths != null && !imagePaths.isEmpty()) {
                try (PreparedStatement psImg = conn.prepareStatement(insertImageSql)) {
                    for (String path : imagePaths) {
                        psImg.setInt(1, complaintId);
                        psImg.setString(2, path);
                        psImg.addBatch();
                    }
                    psImg.executeBatch();
                }
            }

            conn.commit();
            complaint.setComplaintId(complaintId);
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    public List<Complaint> getComplaintsByStudent(int studentId) {
        List<Complaint> list = new ArrayList<>();
        String sql = "SELECT c.*, w.name as worker_name FROM complaints c " +
                     "LEFT JOIN assignments a ON c.complaint_id = a.complaint_id AND a.status != 'Rejected' " +
                     "LEFT JOIN workers w ON a.worker_id = w.worker_id " +
                     "WHERE c.student_id = ? ORDER BY c.created_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, studentId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(extractComplaint(rs));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Complaint> getComplaintsByWorker(int workerId) {
        List<Complaint> list = new ArrayList<>();
        String sql = "SELECT c.*, s.name as student_name, a.remarks as assignment_remarks, a.worker_id " +
                     "FROM complaints c " +
                     "JOIN assignments a ON c.complaint_id = a.complaint_id " +
                     "JOIN students s ON c.student_id = s.student_id " +
                     "WHERE a.worker_id = ? AND a.status != 'Rejected' ORDER BY c.updated_at DESC";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, workerId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Complaint c = extractComplaint(rs);
                    c.setStudentName(rs.getString("student_name"));
                    c.setAssignmentRemarks(rs.getString("assignment_remarks"));
                    c.setAssignedWorkerId(rs.getInt("worker_id"));
                    list.add(c);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Complaint> searchAndFilterComplaints(String query, String status, String category, String priority) {
        List<Complaint> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT c.*, s.name as student_name, s.roll_no as student_roll, w.name as worker_name, a.worker_id, a.remarks as assignment_remarks " +
            "FROM complaints c " +
            "JOIN students s ON c.student_id = s.student_id " +
            "LEFT JOIN assignments a ON c.complaint_id = a.complaint_id AND a.status != 'Rejected' " +
            "LEFT JOIN workers w ON a.worker_id = w.worker_id WHERE 1=1 "
        );

        List<Object> params = new ArrayList<>();

        if (status != null && !status.trim().isEmpty() && !status.equalsIgnoreCase("All")) {
            sql.append("AND c.status = ? ");
            params.add(status);
        }
        if (category != null && !category.trim().isEmpty() && !category.equalsIgnoreCase("All")) {
            sql.append("AND c.category = ? ");
            params.add(category);
        }
        if (priority != null && !priority.trim().isEmpty() && !priority.equalsIgnoreCase("All")) {
            sql.append("AND c.priority = ? ");
            params.add(priority);
        }
        if (query != null && !query.trim().isEmpty()) {
            sql.append("AND (c.title LIKE ? OR c.description LIKE ? OR s.name LIKE ? OR s.roll_no LIKE ? OR c.building LIKE ?) ");
            String q = "%" + query.trim() + "%";
            params.add(q);
            params.add(q);
            params.add(q);
            params.add(q);
            params.add(q);
        }

        sql.append("ORDER BY c.created_at DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Complaint c = extractComplaint(rs);
                    c.setStudentName(rs.getString("student_name"));
                    c.setStudentRollNo(rs.getString("student_roll"));
                    c.setAssignedWorkerName(rs.getString("worker_name"));
                    c.setAssignedWorkerId(rs.getInt("worker_id"));
                    c.setAssignmentRemarks(rs.getString("assignment_remarks"));
                    list.add(c);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public Complaint getComplaintById(int complaintId) {
        String sql = "SELECT c.*, s.name as student_name, s.roll_no as student_roll, w.name as worker_name, a.worker_id, a.remarks as assignment_remarks " +
                     "FROM complaints c " +
                     "JOIN students s ON c.student_id = s.student_id " +
                     "LEFT JOIN assignments a ON c.complaint_id = a.complaint_id AND a.status != 'Rejected' " +
                     "LEFT JOIN workers w ON a.worker_id = w.worker_id " +
                     "WHERE c.complaint_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, complaintId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Complaint c = extractComplaint(rs);
                    c.setStudentName(rs.getString("student_name"));
                    c.setStudentRollNo(rs.getString("student_roll"));
                    c.setAssignedWorkerName(rs.getString("worker_name"));
                    c.setAssignedWorkerId(rs.getInt("worker_id"));
                    c.setAssignmentRemarks(rs.getString("assignment_remarks"));
                    c.setImagePaths(getComplaintImages(complaintId));
                    return c;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updateComplaintStatus(int complaintId, String status) {
        String sql = "UPDATE complaints SET status = ? WHERE complaint_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, complaintId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateComplaintPriority(int complaintId, String priority) {
        String sql = "UPDATE complaints SET priority = ? WHERE complaint_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, priority);
            ps.setInt(2, complaintId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<String> getComplaintImages(int complaintId) {
        List<String> list = new ArrayList<>();
        String sql = "SELECT image_path FROM complaint_images WHERE complaint_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, complaintId);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    list.add(rs.getString("image_path"));
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    // Analytics Helpers
    public Map<String, Integer> getStatusCounts() {
        Map<String, Integer> map = new HashMap<>();
        // Initialize default keys
        map.put("Total", 0);
        map.put("Pending", 0);
        map.put("Assigned", 0);
        map.put("Accepted", 0);
        map.put("In Progress", 0);
        map.put("Completed", 0);
        map.put("Rejected", 0);

        String sql = "SELECT status, COUNT(*) as count FROM complaints GROUP BY status";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            int total = 0;
            while (rs.next()) {
                String status = rs.getString("status");
                int count = rs.getInt("count");
                map.put(status, count);
                total += count;
            }
            map.put("Total", total);
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    public double getAverageResolutionTimeInHours() {
        // Difference in hours between assignment.completed_date and complaints.created_at
        String sql = "SELECT AVG(TIMESTAMPDIFF(HOUR, c.created_at, a.completed_date)) as avg_time " +
                     "FROM complaints c JOIN assignments a ON c.complaint_id = a.complaint_id " +
                     "WHERE c.status = 'Completed' AND a.status = 'Completed' AND a.completed_date IS NOT NULL";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            if (rs.next()) {
                return rs.getDouble("avg_time");
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    public Map<String, Integer> getCategoryDistribution() {
        Map<String, Integer> map = new HashMap<>();
        String sql = "SELECT category, COUNT(*) as count FROM complaints GROUP BY category";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                map.put(rs.getString("category"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    public Map<String, Integer> getBuildingDistribution() {
        Map<String, Integer> map = new HashMap<>();
        String sql = "SELECT building, COUNT(*) as count FROM complaints GROUP BY building";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                map.put(rs.getString("building"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    public Map<String, Integer> getWeeklyTrends() {
        Map<String, Integer> map = new HashMap<>();
        // Last 7 days trend count
        String sql = "SELECT DATE_FORMAT(created_at, '%Y-%m-%d') as day, COUNT(*) as count " +
                     "FROM complaints WHERE created_at >= NOW() - INTERVAL 7 DAY " +
                     "GROUP BY day ORDER BY day ASC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                map.put(rs.getString("day"), rs.getInt("count"));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return map;
    }

    // Reports Helpers
    public List<Complaint> getComplaintsByDateRangeAndFilters(String startDate, String endDate, String category, String building, String status) {
        List<Complaint> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT c.*, s.name as student_name, s.roll_no as student_roll, w.name as worker_name, a.completed_date " +
            "FROM complaints c " +
            "JOIN students s ON c.student_id = s.student_id " +
            "LEFT JOIN assignments a ON c.complaint_id = a.complaint_id AND a.status = 'Completed' " +
            "LEFT JOIN workers w ON a.worker_id = w.worker_id WHERE 1=1 "
        );
        List<Object> params = new ArrayList<>();

        if (startDate != null && !startDate.trim().isEmpty()) {
            sql.append("AND c.created_at >= ? ");
            params.add(startDate + " 00:00:00");
        }
        if (endDate != null && !endDate.trim().isEmpty()) {
            sql.append("AND c.created_at <= ? ");
            params.add(endDate + " 23:59:59");
        }
        if (category != null && !category.trim().isEmpty() && !category.equalsIgnoreCase("All")) {
            sql.append("AND c.category = ? ");
            params.add(category);
        }
        if (building != null && !building.trim().isEmpty() && !building.equalsIgnoreCase("All")) {
            sql.append("AND c.building = ? ");
            params.add(building);
        }
        if (status != null && !status.trim().isEmpty() && !status.equalsIgnoreCase("All")) {
            sql.append("AND c.status = ? ");
            params.add(status);
        }

        sql.append("ORDER BY c.created_at DESC");

        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql.toString())) {
            for (int i = 0; i < params.size(); i++) {
                ps.setObject(i + 1, params.get(i));
            }
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Complaint c = extractComplaint(rs);
                    c.setStudentName(rs.getString("student_name"));
                    c.setStudentRollNo(rs.getString("student_roll"));
                    c.setAssignedWorkerName(rs.getString("worker_name"));
                    list.add(c);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    private Complaint extractComplaint(ResultSet rs) throws SQLException {
        Complaint c = new Complaint();
        c.setComplaintId(rs.getInt("complaint_id"));
        c.setStudentId(rs.getInt("student_id"));
        c.setTitle(rs.getString("title"));
        c.setDescription(rs.getString("description"));
        c.setCategory(rs.getString("category"));
        c.setBuilding(rs.getString("building"));
        c.setBlock(rs.getString("block"));
        c.setFloor(rs.getString("floor"));
        c.setRoomNo(rs.getString("room_no"));
        c.setPriority(rs.getString("priority"));
        
        double lat = rs.getDouble("latitude");
        c.setLatitude(rs.wasNull() ? null : lat);
        
        double lng = rs.getDouble("longitude");
        c.setLongitude(rs.wasNull() ? null : lng);
        
        c.setStatus(rs.getString("status"));
        c.setCreatedAt(rs.getTimestamp("created_at"));
        c.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        // Sometimes queries join assignments.worker_name
        try {
            c.setAssignedWorkerName(rs.getString("worker_name"));
        } catch (SQLException e) {
            // Ignore if column not in select
        }
        return c;
    }
}
