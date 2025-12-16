package com.warranty.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * Model class representing a repair ticket
 */
public class RepairTicket {
    private int ticketId;
    private String ticketNumber;
    private int serialId;
    private int customerId;
    private int intakeTechnicianId;
    private Integer assignedTechnicianId;
    private Integer techManagerId;
    private String issueDescription;
    private String initialDiagnosis;
    private Priority priority;
    private TicketType ticketType;
    private TicketStatus status;
    private Timestamp receivedDate;
    private Date estimatedCompletionDate;
    private Timestamp actualCompletionDate;
    private Timestamp deliveryDate;
    private BigDecimal totalCost;
    private BigDecimal laborCost;
    private BigDecimal partsCost;
    private boolean isPaid;
    private Timestamp paymentDate;
    private String notes;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Additional fields for joined data
    private ProductSerial productSerial;
    private Customer customer;
    private User intakeTechnician;
    private User assignedTechnician;
    private User techManager;

    public enum Priority {
        LOW, MEDIUM, HIGH, URGENT
    }

    public enum TicketType {
        WARRANTY, PAID_REPAIR, INSPECTION
    }

    public enum TicketStatus {
        PENDING, PENDING_ASSIGNMENT, ASSIGNED, IN_DIAGNOSIS, IN_PROGRESS, WAITING_APPROVAL,
        APPROVED, IN_REPAIR, WAITING_PARTS, COMPLETED,
        WAITING_PAYMENT, PAID, DELIVERED, CANCELLED
    }

    // Constructors
    public RepairTicket() {
        this.priority = Priority.MEDIUM;
        this.ticketType = TicketType.WARRANTY;
        this.status = TicketStatus.PENDING_ASSIGNMENT;
        this.totalCost = BigDecimal.ZERO;
        this.laborCost = BigDecimal.ZERO;
        this.partsCost = BigDecimal.ZERO;
        this.isPaid = false;
    }

    // Getters and Setters
    public int getTicketId() {
        return ticketId;
    }

    public void setTicketId(int ticketId) {
        this.ticketId = ticketId;
    }

    public String getTicketNumber() {
        return ticketNumber;
    }

    public void setTicketNumber(String ticketNumber) {
        this.ticketNumber = ticketNumber;
    }

    public int getSerialId() {
        return serialId;
    }

    public void setSerialId(int serialId) {
        this.serialId = serialId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public int getIntakeTechnicianId() {
        return intakeTechnicianId;
    }

    public void setIntakeTechnicianId(int intakeTechnicianId) {
        this.intakeTechnicianId = intakeTechnicianId;
    }

    public Integer getAssignedTechnicianId() {
        return assignedTechnicianId;
    }

    public void setAssignedTechnicianId(Integer assignedTechnicianId) {
        this.assignedTechnicianId = assignedTechnicianId;
    }

    public Integer getTechManagerId() {
        return techManagerId;
    }

    public void setTechManagerId(Integer techManagerId) {
        this.techManagerId = techManagerId;
    }

    public String getIssueDescription() {
        return issueDescription;
    }

    public void setIssueDescription(String issueDescription) {
        this.issueDescription = issueDescription;
    }

    public String getInitialDiagnosis() {
        return initialDiagnosis;
    }

    public void setInitialDiagnosis(String initialDiagnosis) {
        this.initialDiagnosis = initialDiagnosis;
    }

    public Priority getPriority() {
        return priority;
    }

    public void setPriority(Priority priority) {
        this.priority = priority;
    }

    public TicketType getTicketType() {
        return ticketType;
    }

    public void setTicketType(TicketType ticketType) {
        this.ticketType = ticketType;
    }

    public TicketStatus getStatus() {
        return status;
    }

    public void setStatus(TicketStatus status) {
        this.status = status;
    }

    public Timestamp getReceivedDate() {
        return receivedDate;
    }

    public void setReceivedDate(Timestamp receivedDate) {
        this.receivedDate = receivedDate;
    }

    public Date getEstimatedCompletionDate() {
        return estimatedCompletionDate;
    }

    public void setEstimatedCompletionDate(Date estimatedCompletionDate) {
        this.estimatedCompletionDate = estimatedCompletionDate;
    }

    public Timestamp getActualCompletionDate() {
        return actualCompletionDate;
    }

    public void setActualCompletionDate(Timestamp actualCompletionDate) {
        this.actualCompletionDate = actualCompletionDate;
    }

    public Timestamp getDeliveryDate() {
        return deliveryDate;
    }

    public void setDeliveryDate(Timestamp deliveryDate) {
        this.deliveryDate = deliveryDate;
    }

    public BigDecimal getTotalCost() {
        return totalCost;
    }

    public void setTotalCost(BigDecimal totalCost) {
        this.totalCost = totalCost;
    }

    public BigDecimal getLaborCost() {
        return laborCost;
    }

    public void setLaborCost(BigDecimal laborCost) {
        this.laborCost = laborCost;
    }

    public BigDecimal getPartsCost() {
        return partsCost;
    }

    public void setPartsCost(BigDecimal partsCost) {
        this.partsCost = partsCost;
    }

    public boolean isPaid() {
        return isPaid;
    }

    public void setPaid(boolean paid) {
        isPaid = paid;
    }

    public Timestamp getPaymentDate() {
        return paymentDate;
    }

    public void setPaymentDate(Timestamp paymentDate) {
        this.paymentDate = paymentDate;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
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

    public ProductSerial getProductSerial() {
        return productSerial;
    }

    public void setProductSerial(ProductSerial productSerial) {
        this.productSerial = productSerial;
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    public User getIntakeTechnician() {
        return intakeTechnician;
    }

    public void setIntakeTechnician(User intakeTechnician) {
        this.intakeTechnician = intakeTechnician;
    }

    public User getAssignedTechnician() {
        return assignedTechnician;
    }

    public void setAssignedTechnician(User assignedTechnician) {
        this.assignedTechnician = assignedTechnician;
    }

    public User getTechManager() {
        return techManager;
    }

    public void setTechManager(User techManager) {
        this.techManager = techManager;
    }

    // Alias methods for backward compatibility
    public String getTicketCode() {
        return getTicketNumber();
    }

    public void setTicketCode(String ticketCode) {
        setTicketNumber(ticketCode);
    }

    public Integer getTechnicianId() {
        return getAssignedTechnicianId();
    }

    public void setTechnicianId(int technicianId) {
        setAssignedTechnicianId(technicianId);
    }

    public void setTechnicianId(Integer technicianId) {
        setAssignedTechnicianId(technicianId);
    }

    public void setReceivedBy(Integer receivedBy) {
        if (receivedBy != null) {
            setIntakeTechnicianId(receivedBy);
        }
    }

    public boolean getIsUnderWarranty() {
        return ticketType == TicketType.WARRANTY;
    }

    public void setIsUnderWarranty(boolean isUnderWarranty) {
        if (isUnderWarranty) {
            setTicketType(TicketType.WARRANTY);
        } else {
            setTicketType(TicketType.PAID_REPAIR);
        }
    }

    @Override
    public String toString() {
        return "RepairTicket{" +
                "ticketId=" + ticketId +
                ", ticketNumber='" + ticketNumber + '\'' +
                ", status=" + status +
                ", priority=" + priority +
                '}';
    }
}
