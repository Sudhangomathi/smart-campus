package dao;

import model.Worker;
import utility.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class WorkerDAO {

    public List<Worker> getAllWorkers() {
        List<Worker> list = new ArrayList<>();
        String sql = "SELECT w.*, u.email FROM workers w JOIN users u ON w.worker_id = u.user_id ORDER BY w.name ASC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Worker w = new Worker();
                w.setWorkerId(rs.getInt("worker_id"));
                w.setName(rs.getString("name"));
                w.setPhoneNo(rs.getString("phone_no"));
                w.setSpecialization(rs.getString("specialization"));
                w.setStatus(rs.getString("status"));
                w.setEmail(rs.getString("email"));
                list.add(w);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public List<Worker> getAvailableWorkers() {
        List<Worker> list = new ArrayList<>();
        String sql = "SELECT w.*, u.email FROM workers w JOIN users u ON w.worker_id = u.user_id WHERE w.status = 'available' ORDER BY w.name ASC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Worker w = new Worker();
                w.setWorkerId(rs.getInt("worker_id"));
                w.setName(rs.getString("name"));
                w.setPhoneNo(rs.getString("phone_no"));
                w.setSpecialization(rs.getString("specialization"));
                w.setStatus(rs.getString("status"));
                w.setEmail(rs.getString("email"));
                list.add(w);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean updateWorkerStatus(int workerId, String status) {
        String sql = "UPDATE workers SET status = ? WHERE worker_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, status);
            ps.setInt(2, workerId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Map<String, Object> getWorkerPerformanceReport() {
        Map<String, Object> report = new HashMap<>();
        // Query to get total assigned, total completed, and avg resolution time per worker
        String sql = "SELECT w.name, w.specialization, " +
                     "COUNT(a.assignment_id) as total_jobs, " +
                     "SUM(CASE WHEN a.status = 'Completed' THEN 1 ELSE 0 END) as completed_jobs, " +
                     "AVG(CASE WHEN a.status = 'Completed' THEN TIMESTAMPDIFF(HOUR, a.assigned_date, a.completed_date) ELSE NULL END) as avg_hours " +
                     "FROM workers w " +
                     "LEFT JOIN assignments a ON w.worker_id = a.worker_id " +
                     "GROUP BY w.worker_id, w.name, w.specialization";
        List<Map<String, Object>> workerData = new ArrayList<>();
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> row = new HashMap<>();
                row.put("name", rs.getString("name"));
                row.put("specialization", rs.getString("specialization"));
                row.put("total_jobs", rs.getInt("total_jobs"));
                row.put("completed_jobs", rs.getInt("completed_jobs"));
                row.put("avg_hours", rs.getDouble("avg_hours"));
                workerData.add(row);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        report.put("workerPerformance", workerData);
        return report;
    }

    public List<Map<String, Object>> getDetailedWorkerPerformance() {
        List<Map<String, Object>> list = new ArrayList<>();
        String sql = "SELECT w.worker_id, w.name, w.specialization, w.status, " +
                     "COUNT(a.assignment_id) as total_jobs, " +
                     "SUM(CASE WHEN a.status = 'Completed' THEN 1 ELSE 0 END) as completed_jobs, " +
                     "AVG(f.rating) as avg_rating " +
                     "FROM workers w " +
                     "LEFT JOIN assignments a ON w.worker_id = a.worker_id " +
                     "LEFT JOIN feedback f ON a.complaint_id = f.complaint_id " +
                     "GROUP BY w.worker_id, w.name, w.specialization, w.status " +
                     "ORDER BY completed_jobs DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Map<String, Object> map = new HashMap<>();
                map.put("workerId", rs.getInt("worker_id"));
                map.put("name", rs.getString("name"));
                map.put("specialization", rs.getString("specialization"));
                map.put("status", rs.getString("status"));
                map.put("totalJobs", rs.getInt("total_jobs"));
                map.put("completedJobs", rs.getInt("completed_jobs"));
                
                double rating = rs.getDouble("avg_rating");
                map.put("avgRating", rs.wasNull() ? 0.0 : rating);
                list.add(map);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
