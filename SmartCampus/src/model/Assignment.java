package model;

import java.sql.Timestamp;

public class Assignment {
    private int assignmentId;
    private int complaintId;
    private int workerId;
    private int assignedBy; // references supervisor_id
    private Timestamp assignedDate;
    private String status; // Assigned, Accepted, In Progress, Completed, Rejected
    private Timestamp completedDate;
    private String remarks;

    // Helper fields
    private String workerName;
    private String complaintTitle;

    public Assignment() {}

    public Assignment(int assignmentId, int complaintId, int workerId, int assignedBy, Timestamp assignedDate, String status, Timestamp completedDate, String remarks) {
        this.assignmentId = assignmentId;
        this.complaintId = complaintId;
        this.workerId = workerId;
        this.assignedBy = assignedBy;
        this.assignedDate = assignedDate;
        this.status = status;
        this.completedDate = completedDate;
        this.remarks = remarks;
    }

    public int getAssignmentId() {
        return assignmentId;
    }

    public void setAssignmentId(int assignmentId) {
        this.assignmentId = assignmentId;
    }

    public int getComplaintId() {
        return complaintId;
    }

    public void setComplaintId(int complaintId) {
        this.complaintId = complaintId;
    }

    public int getWorkerId() {
        return workerId;
    }

    public void setWorkerId(int workerId) {
        this.workerId = workerId;
    }

    public int getAssignedBy() {
        return assignedBy;
    }

    public void setAssignedBy(int assignedBy) {
        this.assignedBy = assignedBy;
    }

    public Timestamp getAssignedDate() {
        return assignedDate;
    }

    public void setAssignedDate(Timestamp assignedDate) {
        this.assignedDate = assignedDate;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public Timestamp getCompletedDate() {
        return completedDate;
    }

    public void setCompletedDate(Timestamp completedDate) {
        this.completedDate = completedDate;
    }

    public String getRemarks() {
        return remarks;
    }

    public void setRemarks(String remarks) {
        this.remarks = remarks;
    }

    public String getWorkerName() {
        return workerName;
    }

    public void setWorkerName(String workerName) {
        this.workerName = workerName;
    }

    public String getComplaintTitle() {
        return complaintTitle;
    }

    public void setComplaintTitle(String complaintTitle) {
        this.complaintTitle = complaintTitle;
    }
}
