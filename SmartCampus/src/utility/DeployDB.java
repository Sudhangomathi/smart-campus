package utility;

import java.io.BufferedReader;
import java.io.FileReader;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Statement;

public class DeployDB {
    public static void main(String[] args) {
        String url = "jdbc:mysql://tokaido.proxy.rlwy.net:52822/railway?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
        String user = "root";
        String password = "nTcFdYwCmduRjTaHUNSDpXDDogFhQWze";
        String schemaPath = "db/schema.sql";

        System.out.println("Connecting to Railway MySQL database...");
        try (Connection conn = DriverManager.getConnection(url, user, password);
             Statement stmt = conn.createStatement()) {
            
            System.out.println("Reading schema.sql...");
            StringBuilder sb = new StringBuilder();
            try (BufferedReader reader = new BufferedReader(new FileReader(schemaPath))) {
                String line;
                while ((line = reader.readLine()) != null) {
                    // Skip comments and empty lines
                    if (line.trim().startsWith("--") || line.trim().startsWith("//") || line.trim().isEmpty()) {
                        continue;
                    }
                    sb.append(line).append("\n");
                }
            }

            // Split statements by semicolon
            String[] statements = sb.toString().split(";");
            System.out.println("Executing schema statements...");
            for (String sql : statements) {
                String trimmedSql = sql.trim();
                if (!trimmedSql.isEmpty()) {
                    // Skip database creation if it's already "railway" database
                    if (trimmedSql.toUpperCase().startsWith("CREATE DATABASE") || trimmedSql.toUpperCase().startsWith("USE ")) {
                        continue;
                    }
                    try {
                        stmt.execute(trimmedSql);
                    } catch (Exception e) {
                        System.err.println("Failed to execute: " + trimmedSql);
                        System.err.println("Error: " + e.getMessage());
                    }
                }
            }
            
            System.out.println("Running standard migrations (MigrateDB)...");
            stmt.executeUpdate("ALTER TABLE complaints MODIFY COLUMN status ENUM('Pending', 'Assigned', 'Accepted', 'In Progress', 'Completed', 'Closed', 'Rejected') DEFAULT 'Pending'");
            stmt.executeUpdate("ALTER TABLE assignments MODIFY COLUMN status ENUM('Assigned', 'Accepted', 'In Progress', 'Completed', 'Rejected') DEFAULT 'Assigned'");
            stmt.executeUpdate("ALTER TABLE users MODIFY COLUMN role ENUM('student', 'supervisor', 'worker', 'admin') NOT NULL");
            stmt.executeUpdate("INSERT IGNORE INTO users (user_id, email, password, role) VALUES (7, 'admin@campus.com', '5e883f22463109f71c3d26f0c3d24167e17f8eb57b8c5d29023d19e1640141f7', 'admin')");
            
            System.out.println("Creating campus locations...");
            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS campus_locations (" +
                    "location_id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "name VARCHAR(100) NOT NULL, " +
                    "latitude DOUBLE NOT NULL, " +
                    "longitude DOUBLE NOT NULL, " +
                    "created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                    ") ENGINE=InnoDB;");

            stmt.executeUpdate("CREATE TABLE IF NOT EXISTS campus_blueprint (" +
                    "blueprint_id INT AUTO_INCREMENT PRIMARY KEY, " +
                    "file_path VARCHAR(255) NOT NULL, " +
                    "uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP" +
                    ") ENGINE=InnoDB;");
            
            stmt.executeUpdate("DELETE FROM campus_locations");
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

            System.out.println("Railway database deployment completed successfully!");

        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
