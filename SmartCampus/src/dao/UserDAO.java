package dao;

import model.User;
import model.Student;
import model.Supervisor;
import model.Worker;
import utility.DBConnection;
import utility.PasswordUtil;

import java.sql.*;

public class UserDAO {

    public User authenticate(String email, String password) {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, email);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    String dbHashedPassword = rs.getString("password");
                    if (PasswordUtil.verifyPassword(password, dbHashedPassword)) {
                        User user = new User();
                        user.setUserId(rs.getInt("user_id"));
                        user.setEmail(rs.getString("email"));
                        user.setPassword(dbHashedPassword);
                        user.setRole(rs.getString("role"));
                        user.setCreatedAt(rs.getTimestamp("created_at"));
                        return user;
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean registerStudent(Student student, String email, String password) {
        String insertUserSql = "INSERT INTO users (email, password, role) VALUES (?, ?, 'student')";
        String insertStudentSql = "INSERT INTO students (student_id, name, roll_no, phone_no, department) VALUES (?, ?, ?, ?, ?)";
        
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // start transaction

            // 1. Insert into users
            int userId = -1;
            try (PreparedStatement psUser = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                psUser.setString(1, email);
                psUser.setString(2, PasswordUtil.hashPassword(password));
                int affected = psUser.executeUpdate();
                if (affected == 0) {
                    conn.rollback();
                    return false;
                }
                try (ResultSet generatedKeys = psUser.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        userId = generatedKeys.getInt(1);
                    }
                }
            }

            if (userId == -1) {
                conn.rollback();
                return false;
            }

            // 2. Insert into students
            try (PreparedStatement psStudent = conn.prepareStatement(insertStudentSql)) {
                psStudent.setInt(1, userId);
                psStudent.setString(2, student.getName());
                psStudent.setString(3, student.getRollNo());
                psStudent.setString(4, student.getPhoneNo());
                psStudent.setString(5, student.getDepartment());
                psStudent.executeUpdate();
            }

            conn.commit();
            student.setStudentId(userId);
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    public boolean registerSupervisor(Supervisor supervisor, String email, String password) {
        String insertUserSql = "INSERT INTO users (email, password, role) VALUES (?, ?, 'supervisor')";
        String insertSupervisorSql = "INSERT INTO supervisors (supervisor_id, name, phone_no, department) VALUES (?, ?, ?, ?)";
        
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int userId = -1;
            try (PreparedStatement psUser = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                psUser.setString(1, email);
                psUser.setString(2, PasswordUtil.hashPassword(password));
                int affected = psUser.executeUpdate();
                if (affected == 0) {
                    conn.rollback();
                    return false;
                }
                try (ResultSet generatedKeys = psUser.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        userId = generatedKeys.getInt(1);
                    }
                }
            }

            if (userId == -1) {
                conn.rollback();
                return false;
            }

            try (PreparedStatement psSupervisor = conn.prepareStatement(insertSupervisorSql)) {
                psSupervisor.setInt(1, userId);
                psSupervisor.setString(2, supervisor.getName());
                psSupervisor.setString(3, supervisor.getPhoneNo());
                psSupervisor.setString(4, supervisor.getDepartment());
                psSupervisor.executeUpdate();
            }

            conn.commit();
            supervisor.setSupervisorId(userId);
            return true;

        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }

    public boolean registerWorker(Worker worker, String email, String password) {
        String insertUserSql = "INSERT INTO users (email, password, role) VALUES (?, ?, 'worker')";
        String insertWorkerSql = "INSERT INTO workers (worker_id, name, phone_no, specialization, status) VALUES (?, ?, ?, ?, 'available')";
        
        Connection conn = null;
        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false);

            int userId = -1;
            try (PreparedStatement psUser = conn.prepareStatement(insertUserSql, Statement.RETURN_GENERATED_KEYS)) {
                psUser.setString(1, email);
                psUser.setString(2, PasswordUtil.hashPassword(password));
                int affected = psUser.executeUpdate();
                if (affected == 0) {
                    conn.rollback();
                    return false;
                }
                try (ResultSet generatedKeys = psUser.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        userId = generatedKeys.getInt(1);
                    }
                }
            }

            if (userId == -1) {
                conn.rollback();
                return false;
            }

            try (PreparedStatement psWorker = conn.prepareStatement(insertWorkerSql)) {
                psWorker.setInt(1, userId);
                psWorker.setString(2, worker.getName());
                psWorker.setString(3, worker.getPhoneNo());
                psWorker.setString(4, worker.getSpecialization());
                psWorker.executeUpdate();
            }

            conn.commit();
            worker.setWorkerId(userId);
            return true;
        } catch (SQLException e) {
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
        } finally {
            if (conn != null) {
                try {
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
        return false;
    }


    public Student getStudentByUserId(int userId) {
        String sql = "SELECT s.*, u.email FROM students s JOIN users u ON s.student_id = u.user_id WHERE s.student_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Student student = new Student();
                    student.setStudentId(rs.getInt("student_id"));
                    student.setName(rs.getString("name"));
                    student.setRollNo(rs.getString("roll_no"));
                    student.setPhoneNo(rs.getString("phone_no"));
                    student.setDepartment(rs.getString("department"));
                    student.setEmail(rs.getString("email"));
                    return student;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Supervisor getSupervisorByUserId(int userId) {
        String sql = "SELECT sv.*, u.email FROM supervisors sv JOIN users u ON sv.supervisor_id = u.user_id WHERE sv.supervisor_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Supervisor supervisor = new Supervisor();
                    supervisor.setSupervisorId(rs.getInt("supervisor_id"));
                    supervisor.setName(rs.getString("name"));
                    supervisor.setPhoneNo(rs.getString("phone_no"));
                    supervisor.setDepartment(rs.getString("department"));
                    supervisor.setEmail(rs.getString("email"));
                    return supervisor;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public Worker getWorkerByUserId(int userId) {
        String sql = "SELECT w.*, u.email FROM workers w JOIN users u ON w.worker_id = u.user_id WHERE w.worker_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setInt(1, userId);
            try (ResultSet rs = ps.executeQuery()) {
                if (rs.next()) {
                    Worker worker = new Worker();
                    worker.setWorkerId(rs.getInt("worker_id"));
                    worker.setName(rs.getString("name"));
                    worker.setPhoneNo(rs.getString("phone_no"));
                    worker.setSpecialization(rs.getString("specialization"));
                    worker.setStatus(rs.getString("status"));
                    worker.setEmail(rs.getString("email"));
                    return worker;
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    public boolean updatePassword(String email, String newPassword) {
        String sql = "UPDATE users SET password = ? WHERE email = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, PasswordUtil.hashPassword(newPassword));
            ps.setString(2, email);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateStudentProfile(Student student) {
        String sql = "UPDATE students SET name = ?, phone_no = ?, department = ? WHERE student_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, student.getName());
            ps.setString(2, student.getPhoneNo());
            ps.setString(3, student.getDepartment());
            ps.setInt(4, student.getStudentId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateWorkerProfile(Worker worker) {
        String sql = "UPDATE workers SET name = ?, phone_no = ?, specialization = ? WHERE worker_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, worker.getName());
            ps.setString(2, worker.getPhoneNo());
            ps.setString(3, worker.getSpecialization());
            ps.setInt(4, worker.getWorkerId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    public boolean updateSupervisorProfile(Supervisor supervisor) {
        String sql = "UPDATE supervisors SET name = ?, phone_no = ?, department = ? WHERE supervisor_id = ?";
        try (Connection conn = DBConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, supervisor.getName());
            ps.setString(2, supervisor.getPhoneNo());
            ps.setString(3, supervisor.getDepartment());
            ps.setInt(4, supervisor.getSupervisorId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
}
