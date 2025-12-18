package com.warranty.model;

import java.sql.Timestamp;

/**
 * Model class representing a repair progress log entry
 */
public class RepairProgressLog {
    private int logId;
    private int ticketId;
    private int technicianId;
    private String status;
    private String progressDescription;
    private int completionPercentage;
    private Timestamp createdAt;

    // Additional fields for joined data
    private User technician;
    private String technicianName;  // For direct name from SQL join

    // Constructors
    public RepairProgressLog() {
        this.completionPercentage = 0;
    }

    public RepairProgressLog(int ticketId, int technicianId, String status, String progressDescription) {
        this.ticketId = ticketId;
        this.technicianId = technicianId;
        this.status = status;
        this.progressDescription = progressDescription;
        this.completionPercentage = 0;
    }

    // Getters and Setters
    public int getLogId() {
        return logId;
    }

    public void setLogId(int logId) {
        this.logId = logId;
    }

    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public int getTechnicianId() {
        return technicianId;
    }

    public void setTechnicianId(int technicianId) {
        this.technicianId = technicianId;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public String getProgressDescription() {
        return progressDescription;
    }

    public void setProgressDescription(String progressDescription) {
        this.progressDescription = progressDescription;
    }

    public int getCompletionPercentage() {
        return completionPercentage;
    }

    public void setCompletionPercentage(int completionPercentage) {
        this.completionPercentage = completionPercentage;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public User getTechnician() {
        return technician;
    }

    public void setTechnician(User technician) {
        this.technician = technician;
    }

    public String getTechnicianName() {
        if (technicianName != null) {
            return technicianName;
        }
        if (technician != null) {
            return technician.getFullName();
        }
        return "N/A";
    }

    public void setTechnicianName(String technicianName) {
        this.technicianName = technicianName;
    }

    @Override
    public String toString() {
        return "RepairProgressLog{" +
                "logId=" + logId +
                ", ticketId=" + ticketId +
                ", status='" + status + '\'' +
                ", completionPercentage=" + completionPercentage +
                '}';
    }
}
