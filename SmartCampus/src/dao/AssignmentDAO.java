package dao;

import model.Assignment;
import utility.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class AssignmentDAO {

    public boolean assignWorker(Assignment assignment) {
        String insertAssignmentSql = "INSERT INTO assignments (complaint_id, worker_id, assigned_by, status) VALUES (?, ?, ?, 'Assigned')";
        String updateComplaintSql = "UPDATE complaints SET status = 'Assigned' WHERE complaint_id = ?";
        String updateWorkerSql = "UPDATE workers SET status = 'busy' WHERE worker_id = ?";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Insert assignment
            try (PreparedStatement ps = conn.prepareStatement(insertAssignmentSql)) {
                ps.setInt(1, assignment.getComplaintId());
                ps.setInt(2, assignment.getWorkerId());
                ps.setInt(3, assignment.getAssignedBy());
                ps.executeUpdate();
            }

            // 2. Update complaint status
            try (PreparedStatement ps = conn.prepareStatement(updateComplaintSql)) {
                ps.setInt(1, assignment.getComplaintId());
                ps.executeUpdate();
            }

            // 3. Update worker status
            try (PreparedStatement ps = conn.prepareStatement(updateWorkerSql)) {
                ps.setInt(1, assignment.getWorkerId());
                ps.executeUpdate();
            }

            conn.commit();
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

    public boolean updateAssignmentStatus(int complaintId, int workerId, String status, String remarks) {
        String updateAssignmentSql = "UPDATE assignments SET status = ?, remarks = ? WHERE complaint_id = ? AND worker_id = ? AND status != 'Rejected' AND status != 'Completed'";
        String updateComplaintSql = "UPDATE complaints SET status = ? WHERE complaint_id = ?";
        String updateWorkerSql = "UPDATE workers SET status = ? WHERE worker_id = ?";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Update assignment
            try (PreparedStatement ps = conn.prepareStatement(updateAssignmentSql)) {
                ps.setString(1, status);
                ps.setString(2, remarks);
                ps.setInt(3, complaintId);
                ps.setInt(4, workerId);
                ps.executeUpdate();
            }

            // 2. Update complaint
            String complaintStatus = status; // e.g. Accepted, In Progress, Rejected
            if (status.equalsIgnoreCase("Rejected")) {
                complaintStatus = "Pending";
            }
            try (PreparedStatement ps = conn.prepareStatement(updateComplaintSql)) {
                ps.setString(1, complaintStatus);
                ps.setInt(2, complaintId);
                ps.executeUpdate();
            }

            // 3. Update worker status if rejected (set to available)
            if (status.equalsIgnoreCase("Rejected")) {
                try (PreparedStatement ps = conn.prepareStatement(updateWorkerSql)) {
                    ps.setString(1, "available");
                    ps.setInt(2, workerId);
                    ps.executeUpdate();
                }
            }

            conn.commit();
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

    public boolean completeAssignment(int complaintId, int workerId, String remarks, List<String> repairImages) {
        String updateAssignmentSql = "UPDATE assignments SET status = 'Completed', completed_date = CURRENT_TIMESTAMP, remarks = ? WHERE complaint_id = ? AND worker_id = ? AND status != 'Rejected'";
        String updateComplaintSql = "UPDATE complaints SET status = 'Completed' WHERE complaint_id = ?";
        String updateWorkerSql = "UPDATE workers SET status = 'available' WHERE worker_id = ?";
        String insertImageSql = "INSERT INTO complaint_images (complaint_id, image_path) VALUES (?, ?)";

        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Update assignment status to Completed
            try (PreparedStatement ps = conn.prepareStatement(updateAssignmentSql)) {
                ps.setString(1, remarks);
                ps.setInt(2, complaintId);
                ps.setInt(3, workerId);
                ps.executeUpdate();
            }

            // 2. Update complaint status to Completed
            try (PreparedStatement ps = conn.prepareStatement(updateComplaintSql)) {
                ps.setInt(1, complaintId);
                ps.executeUpdate();
            }

            // 3. Update worker status to available
            try (PreparedStatement ps = conn.prepareStatement(updateWorkerSql)) {
                ps.setInt(1, workerId);
                ps.executeUpdate();
            }

            // 4. Insert repair images if uploaded
            if (repairImages != null && !repairImages.isEmpty()) {
                try (PreparedStatement psImg = conn.prepareStatement(insertImageSql)) {
                    for (String path : repairImages) {
                        psImg.setInt(1, complaintId);
                        psImg.setString(2, path);
                        psImg.addBatch();
                    }
                    psImg.executeBatch();
                }
            }

            conn.commit();
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

    public Assignment getAssignmentByComplaintId(int complaintId) {
        String sql = "SELECT a.*, w.name as worker_name, c.title as complaint_title " +
                     "FROM assignments a " +
                     "JOIN workers w ON a.worker_id = w.worker_id " +
                     "JOIN complaints c ON a.complaint_id = c.complaint_id " +
                     "WHERE a.complaint_id = ? AND a.status != 'Rejected' ORDER BY a.assigned_date DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, complaintId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Assignment a = new Assignment();
                    a.setAssignmentId(rs.getInt("assignment_id"));
                    a.setComplaintId(rs.getInt("complaint_id"));
                    a.setWorkerId(rs.getInt("worker_id"));
                    a.setAssignedBy(rs.getInt("assigned_by"));
                    a.setAssignedDate(rs.getTimestamp("assigned_date"));
                    a.setStatus(rs.getString("status"));
                    a.setCompletedDate(rs.getTimestamp("completed_date"));
                    a.setRemarks(rs.getString("remarks"));
                    a.setWorkerName(rs.getString("worker_name"));
                    a.setComplaintTitle(rs.getString("complaint_title"));
                    return a;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
}
