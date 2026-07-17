package model;

import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Complaint {
    private int complaintId;
    private int studentId;
    private String title;
    private String description;
    private String category;
    private String building;
    private String block;
    private String floor;
    private String roomNo;
    private String priority; // Low, Medium, High, Critical
    private Double latitude;
    private Double longitude;
    private String status; // Pending, Assigned, Accepted, In Progress, Completed, Rejected
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Helper fields for UI display
    private String studentName;
    private String studentRollNo;
    private String assignedWorkerName;
    private int assignedWorkerId;
    private String assignmentRemarks;
    private List<String> imagePaths = new ArrayList<>();

    public Complaint() {}

    public int getComplaintId() {
        return complaintId;
    }

    public void setComplaintId(int complaintId) {
        this.complaintId = complaintId;
    }

    public int getStudentId() {
        return studentId;
    }

    public void setStudentId(int studentId) {
        this.studentId = studentId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getCategory() {
        return category;
    }

    public void setCategory(String category) {
        this.category = category;
    }

    public String getBuilding() {
        return building;
    }

    public void setBuilding(String building) {
        this.building = building;
    }

    public String getBlock() {
        return block;
    }

    public void setBlock(String block) {
        this.block = block;
    }

    public String getFloor() {
        return floor;
    }

    public void setFloor(String floor) {
        this.floor = floor;
    }

    public String getRoomNo() {
        return roomNo;
    }

    public void setRoomNo(String roomNo) {
        this.roomNo = roomNo;
    }

    public String getPriority() {
        return priority;
    }

    public void setPriority(String priority) {
        this.priority = priority;
    }

    public Double getLatitude() {
        return latitude;
    }

    public void setLatitude(Double latitude) {
        this.latitude = latitude;
    }

    public Double getLongitude() {
        return longitude;
    }

    public void setLongitude(Double longitude) {
        this.longitude = longitude;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getStudentRollNo() {
        return studentRollNo;
    }

    public void setStudentRollNo(String studentRollNo) {
        this.studentRollNo = studentRollNo;
    }

    public String getAssignedWorkerName() {
        return assignedWorkerName;
    }

    public void setAssignedWorkerName(String assignedWorkerName) {
        this.assignedWorkerName = assignedWorkerName;
    }

    public int getAssignedWorkerId() {
        return assignedWorkerId;
    }

    public void setAssignedWorkerId(int assignedWorkerId) {
        this.assignedWorkerId = assignedWorkerId;
    }

    public String getAssignmentRemarks() {
        return assignmentRemarks;
    }

    public void setAssignmentRemarks(String assignmentRemarks) {
        this.assignmentRemarks = assignmentRemarks;
    }

    public List<String> getImagePaths() {
        return imagePaths;
    }

    public void setImagePaths(List<String> imagePaths) {
        this.imagePaths = imagePaths;
    }

    public void addImagePath(String imagePath) {
        this.imagePaths.add(imagePath);
    }
}
