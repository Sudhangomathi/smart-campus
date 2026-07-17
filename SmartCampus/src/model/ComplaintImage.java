package model;

import java.sql.Timestamp;

public class ComplaintImage {
    private int imageId;
    private int complaintId;
    private String imagePath;
    private Timestamp uploadedAt;

    public ComplaintImage() {}

    public ComplaintImage(int imageId, int complaintId, String imagePath, Timestamp uploadedAt) {
        this.imageId = imageId;
        this.complaintId = complaintId;
        this.imagePath = imagePath;
        this.uploadedAt = uploadedAt;
    }

    public int getImageId() {
        return imageId;
    }

    public void setImageId(int imageId) {
        this.imageId = imageId;
    }

    public int getComplaintId() {
        return complaintId;
    }

    public void setComplaintId(int complaintId) {
        this.complaintId = complaintId;
    }

    public String getImagePath() {
        return imagePath;
    }

    public void setImagePath(String imagePath) {
        this.imagePath = imagePath;
    }

    public Timestamp getUploadedAt() {
        return uploadedAt;
    }

    public void setUploadedAt(Timestamp uploadedAt) {
        this.uploadedAt = uploadedAt;
    }
}
