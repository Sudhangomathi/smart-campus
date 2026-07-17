package dao;

import utility.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class ActivityLogDAO {

    public boolean logActivity(int userId, String action) {
        String sql = "INSERT INTO activity_logs (user_id, action) VALUES (?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            if (userId > 0) {
                ps.setInt(1, userId);
            } else {
                ps.setNull(1, Types.INTEGER);
            }
            ps.setString(2, action);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public List<Map<String, Object>> getRecentLogs(int limit) {
        List<Map<String, Object>> logs = new ArrayList<>();
        String sql = "SELECT l.*, u.email FROM activity_logs l " +
                     "LEFT JOIN users u ON l.user_id = u.user_id " +
                     "ORDER BY l.timestamp DESC LIMIT ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, limit);
            try (ResultSet rs = ps.executeQuery()) {
                while (rs.next()) {
                    Map<String, Object> log = new HashMap<>();
                    log.put("logId", rs.getInt("log_id"));
                    log.put("userId", rs.getInt("user_id"));
                    log.put("email", rs.getString("email"));
                    log.put("action", rs.getString("action"));
                    log.put("timestamp", rs.getTimestamp("timestamp"));
                    logs.add(log);
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return logs;
    }
}
