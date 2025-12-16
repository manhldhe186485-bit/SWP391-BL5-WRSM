package com.warranty.model;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;

/**
 * Model class representing a product serial (sold product)
 */
public class ProductSerial {
    private int serialId;
    private String serialNumber;
    private int productId;
    private int customerId;
    private Date purchaseDate;
    private Date warrantyStartDate;
    private Date warrantyEndDate;
    private BigDecimal purchasePrice;
    private String storeLocation;
    private String invoiceNumber;
    private SerialStatus status;
    private String notes;
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // Additional fields for joined data
    private Product product;
    private Customer customer;

    public enum SerialStatus {
        ACTIVE, EXPIRED, VOID
    }

    // Constructors
    public ProductSerial() {
        this.status = SerialStatus.ACTIVE;
    }

    // Getters and Setters
    public int getSerialId() {
        return serialId;
    }

    public void setSerialId(int serialId) {
        this.serialId = serialId;
    }

    public String getSerialNumber() {
        return serialNumber;
    }

    public void setSerialNumber(String serialNumber) {
        this.serialNumber = serialNumber;
    }

    public int getProductId() {
        return productId;
    }

    public void setProductId(int productId) {
        this.productId = productId;
    }

    public int getCustomerId() {
        return customerId;
    }

    public void setCustomerId(int customerId) {
        this.customerId = customerId;
    }

    public Date getPurchaseDate() {
        return purchaseDate;
    }

    public void setPurchaseDate(Date purchaseDate) {
        this.purchaseDate = purchaseDate;
    }

    public Date getWarrantyStartDate() {
        return warrantyStartDate;
    }

    public void setWarrantyStartDate(Date warrantyStartDate) {
        this.warrantyStartDate = warrantyStartDate;
    }

    public Date getWarrantyEndDate() {
        return warrantyEndDate;
    }

    public void setWarrantyEndDate(Date warrantyEndDate) {
        this.warrantyEndDate = warrantyEndDate;
    }

    public BigDecimal getPurchasePrice() {
        return purchasePrice;
    }

    public void setPurchasePrice(BigDecimal purchasePrice) {
        this.purchasePrice = purchasePrice;
    }

    public String getStoreLocation() {
        return storeLocation;
    }

    public void setStoreLocation(String storeLocation) {
        this.storeLocation = storeLocation;
    }

    public String getInvoiceNumber() {
        return invoiceNumber;
    }

    public void setInvoiceNumber(String invoiceNumber) {
        this.invoiceNumber = invoiceNumber;
    }

    public SerialStatus getStatus() {
        return status;
    }

    public void setStatus(SerialStatus status) {
        this.status = status;
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

    public Product getProduct() {
        return product;
    }

    public void setProduct(Product product) {
        this.product = product;
    }

    public Customer getCustomer() {
        return customer;
    }

    public void setCustomer(Customer customer) {
        this.customer = customer;
    }

    // Delegate methods to related objects
    public int getWarrantyMonths() {
        if (product != null) {
            return product.getWarrantyPeriodMonths();
        }
        return 12; // default
    }

    public void setWarrantyMonths(int warrantyMonths) {
        if (product != null) {
            product.setWarrantyPeriodMonths(warrantyMonths);
        }
    }

    public String getProductName() {
        if (product != null) {
            return product.getProductName();
        }
        return null;
    }

    public void setProductName(String productName) {
        // Helper method - product name is set through product object
        // This is a no-op setter for compatibility
    }

    public String getCustomerName() {
        if (customer != null) {
            return customer.getFullName();
        }
        return null;
    }

    public void setCustomerName(String customerName) {
        // Helper method - customer name is set through customer object
        // This is a no-op setter for compatibility
    }

    public String getCustomerPhone() {
        if (customer != null) {
            return customer.getPhone();
        }
        return null;
    }

    public void setCustomerPhone(String customerPhone) {
        // Helper method - customer phone is set through customer object
        // This is a no-op setter for compatibility
    }

    public String getCustomerEmail() {
        if (customer != null) {
            return customer.getEmail();
        }
        return null;
    }

    public void setCustomerEmail(String customerEmail) {
        // Helper method - customer email is set through customer object
        // This is a no-op setter for compatibility
    }

    @Override
    public String toString() {
        return "ProductSerial{" +
                "serialId=" + serialId +
                ", serialNumber='" + serialNumber + '\'' +
                ", status=" + status +
                '}';
    }
}
