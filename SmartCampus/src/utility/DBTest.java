package utility;

import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.ResultSetMetaData;
import java.sql.Statement;

public class DBTest {
    public static void main(String[] args) {
        try (Connection conn = DBConnection.getConnection();
             Statement stmt = conn.createStatement()) {
            
            System.out.println("Listing tables:");
            try (ResultSet rs = stmt.executeQuery("SHOW TABLES")) {
                while (rs.next()) {
                    System.out.println("- " + rs.getString(1));
                }
            }
            
            System.out.println("\nQuerying complaints:");
            try (ResultSet rs = stmt.executeQuery("SELECT * FROM complaints ORDER BY complaint_id DESC LIMIT 10")) {
                ResultSetMetaData meta = rs.getMetaData();
                int colCount = meta.getColumnCount();
                for (int i = 1; i <= colCount; i++) {
                    System.out.print(meta.getColumnName(i) + "\t");
                }
                System.out.println();
                while (rs.next()) {
                    for (int i = 1; i <= colCount; i++) {
                        System.out.print(rs.getString(i) + "\t");
                    }
                    System.out.println();
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
