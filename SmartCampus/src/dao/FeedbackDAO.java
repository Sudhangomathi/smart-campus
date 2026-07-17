package dao;

import model.Feedback;
import utility.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class FeedbackDAO {

    public boolean submitFeedback(Feedback feedback) {
        String sql = "INSERT INTO feedback (complaint_id, student_id, rating, feedback, satisfaction_level) VALUES (?, ?, ?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, feedback.getComplaintId());
            ps.setInt(2, feedback.getStudentId());
            ps.setInt(3, feedback.getRating());
            ps.setString(4, feedback.getFeedback());
            ps.setString(5, feedback.getSatisfactionLevel());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public Feedback getFeedbackByComplaintId(int complaintId) {
        String sql = "SELECT f.*, s.name as student_name, c.title as complaint_title " +
                     "FROM feedback f JOIN students s ON f.student_id = s.student_id " +
                     "JOIN complaints c ON f.complaint_id = c.complaint_id " +
                     "WHERE f.complaint_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, complaintId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Feedback f = new Feedback();
                    f.setFeedbackId(rs.getInt("feedback_id"));
                    f.setComplaintId(rs.getInt("complaint_id"));
                    f.setStudentId(rs.getInt("student_id"));
                    f.setRating(rs.getInt("rating"));
                    f.setFeedback(rs.getString("feedback"));
                    f.setSatisfactionLevel(rs.getString("satisfaction_level"));
                    f.setSubmittedDate(rs.getTimestamp("submitted_date"));
                    f.setStudentName(rs.getString("student_name"));
                    f.setComplaintTitle(rs.getString("complaint_title"));
                    return f;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public List<Feedback> getAllFeedback() {
        List<Feedback> list = new ArrayList<>();
        String sql = "SELECT f.*, s.name as student_name, c.title as complaint_title " +
                     "FROM feedback f JOIN students s ON f.student_id = s.student_id " +
                     "JOIN complaints c ON f.complaint_id = c.complaint_id ORDER BY f.submitted_date DESC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                Feedback f = new Feedback();
                f.setFeedbackId(rs.getInt("feedback_id"));
                f.setComplaintId(rs.getInt("complaint_id"));
                f.setStudentId(rs.getInt("student_id"));
                f.setRating(rs.getInt("rating"));
                f.setFeedback(rs.getString("feedback"));
                f.setSatisfactionLevel(rs.getString("satisfaction_level"));
                f.setSubmittedDate(rs.getTimestamp("submitted_date"));
                f.setStudentName(rs.getString("student_name"));
                f.setComplaintTitle(rs.getString("complaint_title"));
                list.add(f);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }
}
