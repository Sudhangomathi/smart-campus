package utility;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBConnection {
    private static final String DEFAULT_HOST = "localhost";
    private static final String DEFAULT_PORT = "3306";
    private static final String DEFAULT_DB = "smart_campus";
    private static final String DEFAULT_USER = "root";
    private static final String DEFAULT_PASSWORD = "root";
    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";

    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL Driver not found in classpath!");
            e.printStackTrace();
        }
    }

    public static Connection getConnection() throws SQLException {
        // Read environment variables (standard for cloud platforms like Railway / Render)
        String host = System.getenv("MYSQLHOST");
        if (host == null) host = System.getenv("DB_HOST");
        if (host == null) host = DEFAULT_HOST;

        String port = System.getenv("MYSQLPORT");
        if (port == null) port = System.getenv("DB_PORT");
        if (port == null) port = DEFAULT_PORT;

        String database = System.getenv("MYSQLDATABASE");
        if (database == null) database = System.getenv("DB_NAME");
        if (database == null) database = DEFAULT_DB;

        String user = System.getenv("MYSQLUSER");
        if (user == null) user = System.getenv("DB_USER");
        if (user == null) user = DEFAULT_USER;

        String password = System.getenv("MYSQLPASSWORD");
        if (password == null) password = System.getenv("DB_PASSWORD");
        if (password == null) password = DEFAULT_PASSWORD;

        // Custom JDBC URL support
        String jdbcUrl = System.getenv("MYSQL_URL");
        if (jdbcUrl == null) jdbcUrl = System.getenv("DATABASE_URL");
        
        if (jdbcUrl != null && jdbcUrl.startsWith("jdbc:mysql:")) {
            return DriverManager.getConnection(jdbcUrl);
        }

        String url = "jdbc:mysql://" + host + ":" + port + "/" + database + "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";
        return DriverManager.getConnection(url, user, password);
    }
}
