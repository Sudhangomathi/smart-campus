#!/bin/bash

# Initialize MySQL data directory if not already initialized
if [ ! -d "/var/lib/mysql/mysql" ]; then
    echo "Initializing MySQL data directory..."
    mysqld --initialize-insecure --user=mysql
fi

# Start MySQL server daemon
echo "Starting MySQL..."
mysqld --user=mysql --daemonize

# Wait for MySQL to start
echo "Waiting for MySQL to start..."
until mysqladmin ping -h localhost --silent; do
    sleep 1
done

# Set root password to 'root' to match Java DBConnection credentials
echo "Configuring MySQL user credentials..."
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY 'root'; FLUSH PRIVILEGES;"

# Create database and import schema
echo "Initializing database schema..."
mysql -u root -proot -e "CREATE DATABASE IF NOT EXISTS smart_campus;"
mysql -u root -proot smart_campus < /app/db/schema.sql

# Seed locations and default admin user if not exists
echo "Running standard data migrations..."
mysql -u root -proot smart_campus -e "
ALTER TABLE complaints MODIFY COLUMN status ENUM('Pending', 'Assigned', 'Accepted', 'In Progress', 'Completed', 'Closed', 'Rejected') DEFAULT 'Pending';
ALTER TABLE assignments MODIFY COLUMN status ENUM('Assigned', 'Accepted', 'In Progress', 'Completed', 'Rejected') DEFAULT 'Assigned';
ALTER TABLE users MODIFY COLUMN role ENUM('student', 'supervisor', 'worker', 'admin') NOT NULL;
INSERT IGNORE INTO users (user_id, email, password, role) VALUES (7, 'admin@campus.com', '5e883f22463109f71c3d26f0c3d24167e17f8eb57b8c5d29023d19e1640141f7', 'admin');
CREATE TABLE IF NOT EXISTS campus_locations (location_id INT AUTO_INCREMENT PRIMARY KEY, name VARCHAR(100) NOT NULL, latitude DOUBLE NOT NULL, longitude DOUBLE NOT NULL, created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB;
CREATE TABLE IF NOT EXISTS campus_blueprint (blueprint_id INT AUTO_INCREMENT PRIMARY KEY, file_path VARCHAR(255) NOT NULL, uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP) ENGINE=InnoDB;
DELETE FROM campus_locations;
INSERT INTO campus_locations (name, latitude, longitude) VALUES ('Main Gate', 85.0, 15.0), ('Administrative Block', 50.0, 30.0), ('Academic Blocks', 30.0, 50.0), ('Library', 50.0, 55.0), ('Computer Labs', 32.0, 68.0), ('Canteen', 75.0, 35.0), ('Auditorium', 65.0, 75.0), ('Hostel', 40.0, 85.0), ('Parking Area', 25.0, 20.0), ('Sports Ground', 80.0, 80.0);
"

# Clean default Tomcat webapps directories at runtime to ensure ROOT.war takes full precedence
echo "Cleaning default webapps to ensure ROOT.war is unpacked cleanly..."
rm -rf /usr/local/tomcat/webapps/ROOT /usr/local/tomcat/webapps/examples /usr/local/tomcat/webapps/manager /usr/local/tomcat/webapps/host-manager /usr/local/tomcat/webapps/docs

# Start Tomcat in foreground
echo "Starting Tomcat..."
catalina.sh run
