package com.warranty.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Invoice {
    private int invoiceId;
    private int ticketId;
    private String ticketNumber;
    private BigDecimal laborCost;
    private BigDecimal partsCost;
    private BigDecimal totalAmount;
    private String notes;
    private int createdBy;
    private String creatorName;
    private Timestamp createdAt;
    private String status;

    // Constructors
    public Invoice() {}

    public Invoice(int invoiceId, int ticketId, BigDecimal laborCost, BigDecimal partsCost, 
                   BigDecimal totalAmount, String notes, int createdBy, Timestamp createdAt, String status) {
        this.invoiceId = invoiceId;
        this.ticketId = ticketId;
        this.laborCost = laborCost;
        this.partsCost = partsCost;
        this.totalAmount = totalAmount;
        this.notes = notes;
        this.createdBy = createdBy;
        this.createdAt = createdAt;
        this.status = status;
    }

    // Getters and Setters
    public int getInvoiceId() {
        return invoiceId;
    }

    public void setInvoiceId(int invoiceId) {
        this.invoiceId = invoiceId;
    }

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

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getNotes() {
        return notes;
    }

    public void setNotes(String notes) {
        this.notes = notes;
    }

    public int getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(int createdBy) {
        this.createdBy = createdBy;
    }

    public String getCreatorName() {
        return creatorName;
    }

    public void setCreatorName(String creatorName) {
        this.creatorName = creatorName;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
