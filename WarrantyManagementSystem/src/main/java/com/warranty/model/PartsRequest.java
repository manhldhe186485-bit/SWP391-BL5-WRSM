package com.warranty.model;

import java.sql.Timestamp;
import java.util.List;

/**
 * Model class representing a parts request from technician to warehouse
 */
public class PartsRequest {
    private int requestId;
    private String requestNumber;
    private int ticketId;
    private int technicianId;
    private Integer warehouseStaffId;
    private RequestStatus status;
    private Timestamp requestDate;
    private Timestamp approvedDate;
    private Timestamp fulfilledDate;
    private String notes;
    private String rejectionReason;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Additional fields for joined data
    private RepairTicket ticket;
    private User technician;
    private User warehouseStaff;
    private List<PartsRequestItem> items;
    private int itemCount; // Number of items in this request
    
    // Temporary fields for display (from JOIN queries)
    private String ticketCode; // ticket_number from JOIN
    private String ticketNumber; // alias for ticketCode

    public enum RequestStatus {
        PENDING, APPROVED, REJECTED, FULFILLED, CANCELLED
    }

    // Constructors
    public PartsRequest() {
        this.status = RequestStatus.PENDING;
    }

    // Getters and Setters
    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public String getRequestNumber() {
        return requestNumber;
    }

    public void setRequestNumber(String requestNumber) {
        this.requestNumber = requestNumber;
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

    public Integer getWarehouseStaffId() {
        return warehouseStaffId;
    }

    public void setWarehouseStaffId(Integer warehouseStaffId) {
        this.warehouseStaffId = warehouseStaffId;
    }

    public RequestStatus getStatus() {
        return status;
    }

    public void setStatus(RequestStatus status) {
        this.status = status;
    }

    public Timestamp getRequestDate() {
        return requestDate;
    }

    public void setRequestDate(Timestamp requestDate) {
        this.requestDate = requestDate;
    }

    public Timestamp getApprovedDate() {
        return approvedDate;
    }

    public void setApprovedDate(Timestamp approvedDate) {
        this.approvedDate = approvedDate;
    }

    public Timestamp getFulfilledDate() {
        return fulfilledDate;
    }

    public void setFulfilledDate(Timestamp fulfilledDate) {
        this.fulfilledDate = fulfilledDate;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public String getRejectionReason() {
        return rejectionReason;
    }

    public void setRejectionReason(String rejectionReason) {
        this.rejectionReason = rejectionReason;
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

    public RepairTicket getTicket() {
        return ticket;
    }

    public void setTicket(RepairTicket ticket) {
        this.ticket = ticket;
    }

    public User getTechnician() {
        return technician;
    }

    public void setTechnician(User technician) {
        this.technician = technician;
    }

    public User getWarehouseStaff() {
        return warehouseStaff;
    }

    public void setWarehouseStaff(User warehouseStaff) {
        this.warehouseStaff = warehouseStaff;
    }

    public List<PartsRequestItem> getItems() {
        return items;
    }

    public void setItems(List<PartsRequestItem> items) {
        this.items = items;
    }

    public int getItemCount() {
        return itemCount;
    }

    public void setItemCount(int itemCount) {
        this.itemCount = itemCount;
    }

    // Compatibility methods
    public String getPriority() {
        return "MEDIUM"; // default priority
    }

    public void setPriority(String priority) {
        // No-op method for compatibility
    }

    public Integer getRequestedBy() {
        return getTechnicianId();
    }

    public void setRequestedBy(Integer requestedBy) {
        if (requestedBy != null) {
            setTechnicianId(requestedBy);
        }
    }

    public void setProcessedBy(int processedBy) {
        setWarehouseStaffId(processedBy);
    }

    public void setProcessedDate(Timestamp processedDate) {
        setApprovedDate(processedDate);
    }

    public void setProcessingNotes(String processingNotes) {
        setNotes(processingNotes);
    }

    public void setTechnicianName(String technicianName) {
        // Helper method - technician name is set through technician object
        // This is a no-op setter for compatibility
    }

    public String getTicketCode() {
        if (ticket != null) {
            return ticket.getTicketNumber();
        }
        return ticketCode;
    }

    public void setTicketCode(String ticketCode) {
        this.ticketCode = ticketCode;
        this.ticketNumber = ticketCode; // Keep both in sync
    }

    public String getTicketNumber() {
        return getTicketCode(); // Delegate to ticketCode
    }

    public void setTicketNumber(String ticketNumber) {
        this.ticketNumber = ticketNumber;
        this.ticketCode = ticketNumber; // Keep both in sync
    }

    public void setProductSerialNumber(String productSerialNumber) {
        // Helper method - product serial is handled through ticket relation
        // This is a no-op setter for compatibility
    }

    @Override
    public String toString() {
        return "PartsRequest{" +
                "requestId=" + requestId +
                ", requestNumber='" + requestNumber + '\'' +
                ", status=" + status +
                '}';
    }
}
