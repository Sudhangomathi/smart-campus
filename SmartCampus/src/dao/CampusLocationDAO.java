package dao;

import model.CampusLocation;
import utility.DBConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CampusLocationDAO {

    public List<CampusLocation> getAllLocations() {
        List<CampusLocation> list = new ArrayList<>();
        String sql = "SELECT * FROM campus_locations ORDER BY name ASC";
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            while (rs.next()) {
                CampusLocation loc = new CampusLocation();
                loc.setLocationId(rs.getInt("location_id"));
                loc.setName(rs.getString("name"));
                loc.setLatitude(rs.getDouble("latitude"));
                loc.setLongitude(rs.getDouble("longitude"));
                list.add(loc);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return list;
    }

    public boolean addLocation(CampusLocation loc) {
        String sql = "INSERT INTO campus_locations (name, latitude, longitude) VALUES (?, ?, ?)";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            ps.setString(1, loc.getName());
            ps.setDouble(2, loc.getLatitude());
            ps.setDouble(3, loc.getLongitude());
            int affected = ps.executeUpdate();
            if (affected > 0) {
                try (ResultSet generatedKeys = ps.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        loc.setLocationId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean deleteLocation(int locationId) {
        String sql = "DELETE FROM campus_locations WHERE location_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, locationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateLocation(int locationId, String name, double latitude, double longitude) {
        String sql = "UPDATE campus_locations SET name = ?, latitude = ?, longitude = ? WHERE location_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, name);
            ps.setDouble(2, latitude);
            ps.setDouble(3, longitude);
            ps.setInt(4, locationId);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
