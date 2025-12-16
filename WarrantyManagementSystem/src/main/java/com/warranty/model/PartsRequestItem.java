package com.warranty.model;

import java.math.BigDecimal;
import java.sql.Timestamp;

/**
 * Model class representing an item in a parts request
 */
public class PartsRequestItem {
    private int requestItemId;
    private int requestId;
    private int itemId;
    private int quantityRequested;
    private Integer quantityApproved;
    private Integer quantityIssued;
    private BigDecimal unitPrice;
    private String notes;
    private Timestamp createdAt;

    // Additional field for joined data
    private InventoryItem inventoryItem;

    // Constructors
    public PartsRequestItem() {
    }

    public PartsRequestItem(int requestId, int itemId, int quantityRequested) {
        this.requestId = requestId;
        this.itemId = itemId;
        this.quantityRequested = quantityRequested;
    }

    // Getters and Setters
    public int getRequestItemId() {
        return requestItemId;
    }

    public void setRequestItemId(int requestItemId) {
        this.requestItemId = requestItemId;
    }

    public int getRequestId() {
        return requestId;
    }

    public void setRequestId(int requestId) {
        this.requestId = requestId;
    }

    public int getItemId() {
        return itemId;
    }

    public void setItemId(int itemId) {
        this.itemId = itemId;
    }

    public int getQuantityRequested() {
        return quantityRequested;
    }

    public void setQuantityRequested(int quantityRequested) {
        this.quantityRequested = quantityRequested;
    }

    public Integer getQuantityApproved() {
        return quantityApproved;
    }

    public void setQuantityApproved(Integer quantityApproved) {
        this.quantityApproved = quantityApproved;
    }

    public Integer getQuantityIssued() {
        return quantityIssued;
    }

    public void setQuantityIssued(Integer quantityIssued) {
        this.quantityIssued = quantityIssued;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
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

    public InventoryItem getInventoryItem() {
        return inventoryItem;
    }

    public void setInventoryItem(InventoryItem inventoryItem) {
        this.inventoryItem = inventoryItem;
    }

    public BigDecimal getTotalPrice() {
        if (unitPrice != null && quantityIssued != null) {
            return unitPrice.multiply(BigDecimal.valueOf(quantityIssued));
        }
        return BigDecimal.ZERO;
    }

    // Delegate methods for backward compatibility
    public int getInventoryItemId() {
        return getItemId();
    }

    public void setInventoryItemId(int inventoryItemId) {
        setItemId(inventoryItemId);
    }

    public String getPartName() {
        if (inventoryItem != null) {
            return inventoryItem.getItemName();
        }
        return null;
    }

    public void setPartName(String partName) {
        // Helper method - part name is set through inventoryItem object
        // This is a no-op setter for compatibility
    }

    public String getPartNumber() {
        if (inventoryItem != null) {
            return inventoryItem.getItemCode();
        }
        return null;
    }

    public void setPartNumber(String partNumber) {
        // Helper method - part number is set through inventoryItem object
        // This is a no-op setter for compatibility
    }

    public void setPartCode(String partCode) {
        // Helper method - part code is handled through inventoryItem
        // This is a no-op setter for compatibility
    }

    public int getQuantityAvailable() {
        if (inventoryItem != null) {
            return inventoryItem.getQuantityInStock();
        }
        return 0;
    }

    public void setQuantityAvailable(int quantityAvailable) {
        // Helper method - quantity available is set through inventoryItem object
        // This is a no-op setter for compatibility
    }

    @Override
    public String toString() {
        return "PartsRequestItem{" +
                "requestItemId=" + requestItemId +
                ", itemId=" + itemId +
                ", quantityRequested=" + quantityRequested +
                '}';
    }
}
