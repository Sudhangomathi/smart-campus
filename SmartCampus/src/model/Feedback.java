package model;

import java.sql.Timestamp;

public class Feedback {
    private int feedbackId;
    private int complaintId;
    private int studentId;
    private int rating;
    private String feedback;
    private String satisfactionLevel;
    private Timestamp submittedDate;

    // Helper fields
    private String studentName;
    private String complaintTitle;

    public Feedback() {}

    public Feedback(int feedbackId, int complaintId, int studentId, int rating, String feedback, String satisfactionLevel, Timestamp submittedDate) {
        this.feedbackId = feedbackId;
        this.complaintId = complaintId;
        this.studentId = studentId;
        this.rating = rating;
        this.feedback = feedback;
        this.satisfactionLevel = satisfactionLevel;
        this.submittedDate = submittedDate;
    }

    public int getFeedbackId() {
        return feedbackId;
    }

    public void setFeedbackId(int feedbackId) {
        this.feedbackId = feedbackId;
    }

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

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getFeedback() {
        return feedback;
    }

    public void setFeedback(String feedback) {
        this.feedback = feedback;
    }

    public String getSatisfactionLevel() {
        return satisfactionLevel;
    }

    public void setSatisfactionLevel(String satisfactionLevel) {
        this.satisfactionLevel = satisfactionLevel;
    }

    public Timestamp getSubmittedDate() {
        return submittedDate;
    }

    public void setSubmittedDate(Timestamp submittedDate) {
        this.submittedDate = submittedDate;
    }

    public String getStudentName() {
        return studentName;
    }

    public void setStudentName(String studentName) {
        this.studentName = studentName;
    }

    public String getComplaintTitle() {
        return complaintTitle;
    }

    public void setComplaintTitle(String complaintTitle) {
        this.complaintTitle = complaintTitle;
    }
}
