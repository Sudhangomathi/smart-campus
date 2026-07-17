-- Smart Campus Complaint Portal Database Schema
CREATE DATABASE IF NOT EXISTS smart_campus;
USE smart_campus;

-- Disable foreign key checks to make re-run safe
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS activity_logs;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS feedback;
DROP TABLE IF EXISTS assignments;
DROP TABLE IF EXISTS complaint_locations;
DROP TABLE IF EXISTS complaint_images;
DROP TABLE IF EXISTS campus_locations;
DROP TABLE IF EXISTS campus_blueprint;
DROP TABLE IF EXISTS complaints;
DROP TABLE IF EXISTS workers;
DROP TABLE IF EXISTS supervisors;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS users;

SET FOREIGN_KEY_CHECKS = 1;

-- 1. users table
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL, -- SHA-256 hashed password
    role ENUM('student', 'supervisor', 'worker', 'admin') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 2. students table
CREATE TABLE students (
    student_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    roll_no VARCHAR(50) UNIQUE NOT NULL,
    phone_no VARCHAR(20),
    department VARCHAR(100),
    FOREIGN KEY (student_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 3. supervisors table
CREATE TABLE supervisors (
    supervisor_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone_no VARCHAR(20),
    department VARCHAR(100),
    FOREIGN KEY (supervisor_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 4. workers table
CREATE TABLE workers (
    worker_id INT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone_no VARCHAR(20),
    specialization VARCHAR(100) NOT NULL,
    status ENUM('available', 'busy') DEFAULT 'available',
    FOREIGN KEY (worker_id) REFERENCES users(user_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 5. complaints table
CREATE TABLE complaints (
    complaint_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT NOT NULL,
    category VARCHAR(100) NOT NULL,
    building VARCHAR(100) NOT NULL,
    block VARCHAR(50) NOT NULL,
    floor VARCHAR(50) NOT NULL,
    room_no VARCHAR(50) NOT NULL,
    priority ENUM('Low', 'Medium', 'High', 'Critical') DEFAULT 'Medium',
    latitude DOUBLE,
    longitude DOUBLE,
    status ENUM('Pending', 'Assigned', 'Accepted', 'In Progress', 'Completed', 'Closed', 'Rejected') DEFAULT 'Pending',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE,
    INDEX idx_complaint_status (status),
    INDEX idx_complaint_category (category)
) ENGINE=InnoDB;

-- 6. complaint_images table
CREATE TABLE complaint_images (
    image_id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT NOT NULL,
    image_path VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (complaint_id) REFERENCES complaints(complaint_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7. complaint_locations table
CREATE TABLE complaint_locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT NOT NULL,
    address VARCHAR(255),
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    FOREIGN KEY (complaint_id) REFERENCES complaints(complaint_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 7.5. campus_locations table (custom landmarks/pins)
CREATE TABLE campus_locations (
    location_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    latitude DOUBLE NOT NULL,
    longitude DOUBLE NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 7.6. campus_blueprint table (single active campus blueprint)
CREATE TABLE campus_blueprint (
    blueprint_id INT AUTO_INCREMENT PRIMARY KEY,
    file_path VARCHAR(255) NOT NULL,
    uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- 8. assignments table
CREATE TABLE assignments (
    assignment_id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT NOT NULL,
    worker_id INT NOT NULL,
    assigned_by INT NOT NULL,
    assigned_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('Assigned', 'Accepted', 'In Progress', 'Completed', 'Rejected') DEFAULT 'Assigned',
    completed_date TIMESTAMP NULL DEFAULT NULL,
    remarks TEXT,
    FOREIGN KEY (complaint_id) REFERENCES complaints(complaint_id) ON DELETE CASCADE,
    FOREIGN KEY (worker_id) REFERENCES workers(worker_id) ON DELETE CASCADE,
    FOREIGN KEY (assigned_by) REFERENCES supervisors(supervisor_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 9. feedback table
CREATE TABLE feedback (
    feedback_id INT AUTO_INCREMENT PRIMARY KEY,
    complaint_id INT NOT NULL UNIQUE,
    student_id INT NOT NULL,
    rating INT CHECK (rating BETWEEN 1 AND 5),
    feedback TEXT,
    satisfaction_level VARCHAR(50),
    submitted_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (complaint_id) REFERENCES complaints(complaint_id) ON DELETE CASCADE,
    FOREIGN KEY (student_id) REFERENCES students(student_id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- 10. notifications table
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user_notification (user_id, is_read)
) ENGINE=InnoDB;

-- 11. activity_logs table
CREATE TABLE activity_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(255) NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- Seed Data (Password hash for 'password' is SHA-256: 5e883f22463109f71c3d26f0c3d24167e17f8eb57b8c5d29023d19e1640141f7)

-- Insert Users
INSERT INTO users (user_id, email, password, role) VALUES 
(1, 'student@campus.edu', '5e883f22463109f71c3d26f0c3d24167e17f8eb57b8c5d29023d19e1640141f7', 'student'),
(2, 'supervisor@campus.com', '4e4c56e4a15f89f05c2f4c72613da2a18c9665d4f0d6acce16415eb06f9be776', 'supervisor'),
(3, 'worker1@campus.com', '312bba6ac1c4274943d7d3c1f346e8e27310c731e407ce5592d82f0d101fbff1', 'worker'),
(4, 'worker2@campus.com', '312bba6ac1c4274943d7d3c1f346e8e27310c731e407ce5592d82f0d101fbff1', 'worker'),
(5, 'worker3@campus.com', '312bba6ac1c4274943d7d3c1f346e8e27310c731e407ce5592d82f0d101fbff1', 'worker'),
(6, 'worker4@campus.com', '312bba6ac1c4274943d7d3c1f346e8e27310c731e407ce5592d82f0d101fbff1', 'worker'),
(7, 'admin@campus.com', '5e883f22463109f71c3d26f0c3d24167e17f8eb57b8c5d29023d19e1640141f7', 'admin');

-- Insert Students
INSERT INTO students (student_id, name, roll_no, phone_no, department) VALUES 
(1, 'John Doe', 'CS2026001', '9876543210', 'Computer Science & Engineering');

-- Insert Supervisors
INSERT INTO supervisors (supervisor_id, name, phone_no, department) VALUES 
(2, 'Dr. Alice Smith', '9876543211', 'Campus Facilities & Maintenance');

-- Insert Workers
INSERT INTO workers (worker_id, name, phone_no, specialization, status) VALUES 
(3, 'Bob Johnson', '9876543212', 'Electrical', 'available'),
(4, 'Charlie Brown', '9876543213', 'Water Leakage', 'available'),
(5, 'David Miller', '9876543214', 'Cleaning', 'available'),
(6, 'Edward Wilson', '9876543215', 'Furniture', 'available');

-- Insert Mock Complaints
INSERT INTO complaints (complaint_id, student_id, title, description, category, building, block, floor, room_no, priority, latitude, longitude, status, created_at) VALUES 
(1, 1, 'Flickering Lights in Classroom', 'Three tube lights are flickering constantly in the main lecture hall, making it hard to read the board.', 'Electrical', 'Main Academic Building', 'Block A', '1st Floor', 'Room 102', 'High', 13.0285, 80.2458, 'Pending', NOW() - INTERVAL 5 DAY),
(2, 1, 'Water Pipe Leaking in Washroom', 'The basin inlet pipe is broken and leaking water onto the floor, causing a slip hazard.', 'Water Leakage', 'Science Block', 'Block B', 'Ground Floor', 'Washroom G1', 'Medium', 13.0290, 80.2465, 'Completed', NOW() - INTERVAL 10 DAY),
(3, 1, 'Broken Chair in Lab', 'One of the computer chairs has a broken adjustment lever and is stuck at the lowest height.', 'Furniture', 'IT Center', 'Block C', '3rd Floor', 'Lab 305', 'Low', 13.0275, 80.2450, 'Assigned', NOW() - INTERVAL 2 DAY);

-- Insert Mock Locations
INSERT INTO complaint_locations (complaint_id, address, latitude, longitude) VALUES 
(1, 'Main Academic Building, Block A, 1st Floor, Room 102', 13.0285, 80.2458),
(2, 'Science Block, Block B, Ground Floor, Washroom G1', 13.0290, 80.2465),
(3, 'IT Center, Block C, 3rd Floor, Lab 305', 13.0275, 80.2450);

-- Insert Mock Assignments
INSERT INTO assignments (complaint_id, worker_id, assigned_by, assigned_date, status, completed_date, remarks) VALUES 
(2, 4, 2, NOW() - INTERVAL 10 DAY, 'Completed', NOW() - INTERVAL 9 DAY, 'Replaced the damaged section of the PVC inlet pipe.'),
(3, 6, 2, NOW() - INTERVAL 2 DAY, 'Assigned', NULL, NULL);

-- Update completed complaint status and worker status
UPDATE complaints SET status = 'Completed' WHERE complaint_id = 2;
UPDATE complaints SET status = 'Assigned' WHERE complaint_id = 3;

-- Insert Mock Feedback
INSERT INTO feedback (complaint_id, student_id, rating, feedback, satisfaction_level, submitted_date) VALUES 
(2, 1, 5, 'Quick response and clean work! Thank you.', 'Highly Satisfied', NOW() - INTERVAL 9 DAY);

-- Insert Mock Notifications
INSERT INTO notifications (user_id, message, is_read, created_at) VALUES 
(1, 'Your complaint "Water Pipe Leaking in Washroom" has been completed.', TRUE, NOW() - INTERVAL 9 DAY),
(1, 'Your complaint "Broken Chair in Lab" has been assigned to a worker.', FALSE, NOW() - INTERVAL 2 DAY),
(6, 'You have been assigned a new complaint: "Broken Chair in Lab".', FALSE, NOW() - INTERVAL 2 DAY),
(2, 'A new complaint "Flickering Lights in Classroom" has been raised.', FALSE, NOW() - INTERVAL 5 DAY);

-- Insert Mock Activity Logs
INSERT INTO activity_logs (user_id, action, timestamp) VALUES 
(1, 'Raised complaint: Flickering Lights in Classroom', NOW() - INTERVAL 5 DAY),
(1, 'Raised complaint: Water Pipe Leaking in Washroom', NOW() - INTERVAL 10 DAY),
(2, 'Assigned complaint 2 to worker 4', NOW() - INTERVAL 10 DAY),
(4, 'Marked complaint 2 as completed', NOW() - INTERVAL 9 DAY),
(1, 'Submitted feedback for complaint 2', NOW() - INTERVAL 9 DAY);
