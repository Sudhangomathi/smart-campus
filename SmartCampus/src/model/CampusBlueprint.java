package model;

import java.sql.Timestamp;

public class CampusBlueprint {
    private int blueprintId;
    private String filePath;
    private Timestamp uploadedAt;

    public CampusBlueprint() {
    }

    public CampusBlueprint(int blueprintId, String filePath, Timestamp uploadedAt) {
        this.blueprintId = blueprintId;
        this.filePath = filePath;
        this.uploadedAt = uploadedAt;
    }

    public int getBlueprintId() {
        return blueprintId;
    }

    public void setBlueprintId(int blueprintId) {
        this.blueprintId = blueprintId;
    }

    public String getFilePath() {
        return filePath;
    }

    public void setFilePath(String filePath) {
        this.filePath = filePath;
    }

    public Timestamp getUploadedAt() {
        return uploadedAt;
    }

    public void setUploadedAt(Timestamp uploadedAt) {
        this.uploadedAt = uploadedAt;
    }
}
