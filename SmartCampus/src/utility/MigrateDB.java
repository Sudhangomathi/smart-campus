package utility;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.Statement;

public class MigrateDB {
    public static void main(String[] args) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            try (Connection conn = DBConnection.getConnection();
                 Statement stmt = conn.createStatement()) {
                
                System.out.println("Altering complaints table status ENUM...");
                stmt.executeUpdate("ALTER TABLE complaints MODIFY COLUMN status ENUM('Pending', 'Assigned', 'Accepted', 'In Progress', 'Completed', 'Closed', 'Rejected') DEFAULT 'Pending'");
                
                System.out.println("Altering assignments table status ENUM... ");
                stmt.executeUpdate("ALTER TABLE assignments MODIFY COLUMN status ENUM('Assigned', 'Accepted', 'In Progress', 'Completed', 'Rejected') DEFAULT 'Assigned'");
                
                System.out.println("Altering users table role ENUM... ");
                stmt.executeUpdate("ALTER TABLE users MODIFY COLUMN role ENUM('student', 'supervisor', 'worker', 'admin') NOT NULL");
                
                System.out.println("Seeding admin user if not exists... ");
                stmt.executeUpdate("INSERT IGNORE INTO users (user_id, email, password, role) VALUES (7, 'admin@campus.com', '5e883f22463109f71c3d26f0c3d24167e17f8eb57b8c5d29023d19e1640141f7', 'admin')");
                
                System.out.println("Creating campus_locations table...");
                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS campus_locations (" +
                        "location_id INT AUTO_INCREMENT PRIMARY KEY, " +
                        "name VARCHAR(100) NOT NULL, " +
                        "latitude DOUBLE NOT NULL, " +
                        "longitude DOUBLE NOT NULL, " +
                        "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                        ") ENGINE=InnoDB;");

                System.out.println("Creating campus_blueprint table...");
                stmt.executeUpdate("CREATE TABLE IF NOT EXISTS campus_blueprint (" +
                        "blueprint_id INT AUTO_INCREMENT PRIMARY KEY, " +
                        "file_path VARCHAR(255) NOT NULL, " +
                        "uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                        ") ENGINE=InnoDB;");
                
                // Clear and re-seed landmarks to ensure new percentage offsets are applied
                stmt.executeUpdate("DELETE FROM campus_locations");
                int count = 0;
                
                if (count == 0) {
                    System.out.println("Seeding campus_locations...");
                    stmt.executeUpdate("INSERT INTO campus_locations (name, latitude, longitude) VALUES " +
                            "('Main Gate', 85.0, 15.0), " +
                            "('Administrative Block', 50.0, 30.0), " +
                            "('Academic Blocks', 30.0, 50.0), " +
                            "('Library', 50.0, 55.0), " +
                            "('Computer Labs', 32.0, 68.0), " +
                            "('Canteen', 75.0, 35.0), " +
                            "('Auditorium', 65.0, 75.0), " +
                            "('Hostel', 40.0, 85.0), " +
                            "('Parking Area', 25.0, 20.0), " +
                            "('Sports Ground', 80.0, 80.0)");
                }
                
                System.out.println("Database migration completed successfully!");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
