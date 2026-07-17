package dao;

import model.CampusBlueprint;
import utility.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class CampusBlueprintDAO {

    public CampusBlueprint getLatestBlueprint() {
        String sql = "SELECT * FROM campus_blueprint ORDER BY blueprint_id DESC LIMIT 1";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql);
             ResultSet rs = ps.executeQuery()) {
            if (rs.next()) {
                CampusBlueprint blueprint = new CampusBlueprint();
                blueprint.setBlueprintId(rs.getInt("blueprint_id"));
                blueprint.setFilePath(rs.getString("file_path"));
                blueprint.setUploadedAt(rs.getTimestamp("uploaded_at"));
                return blueprint;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean saveBlueprint(String filePath) {
        String sql = "INSERT INTO campus_blueprint (file_path) VALUES (?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, filePath);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
