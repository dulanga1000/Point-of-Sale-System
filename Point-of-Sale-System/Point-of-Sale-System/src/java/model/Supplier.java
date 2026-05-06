/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author dulan
 */

import java.math.BigDecimal;
import java.sql.Timestamp;

// All other code for Supplier.java remains the same as provided in
// my "fixed full code" response from Tuesday, May 13, 2025 at 1:29:28 PM +0530
// (getters, setters, constructors)
public class Supplier {

    private int supplierId;
    private String companyName;
    private String category;
    private String businessRegNo;
    private String taxId;
    private String companyAddress;
    private String contactPerson;
    private String contactPosition;
    private String contactPhone;
    private String contactEmail;
    private String paymentMethod;
    private String paymentTerms;
    private BigDecimal creditLimit;
    private String deliveryTerms;
    private int leadTime;
    private String productCategories;
    private String additionalNotes;
    private Timestamp createdAt;

    public Supplier() {}

    public Supplier(String companyName, String category, String businessRegNo, String taxId,
                    String companyAddress, String contactPerson, String contactPosition,
                    String contactPhone, String contactEmail, String paymentMethod,
                    String paymentTerms, BigDecimal creditLimit, String deliveryTerms,
                    int leadTime, String productCategories, String additionalNotes) {
        this.companyName = companyName;
        this.category = category;
        this.businessRegNo = businessRegNo;
        this.taxId = taxId;
        this.companyAddress = companyAddress;
        this.contactPerson = contactPerson;
        this.contactPosition = contactPosition;
        this.contactPhone = contactPhone;
        this.contactEmail = contactEmail;
        this.paymentMethod = paymentMethod;
        this.paymentTerms = paymentTerms;
        this.creditLimit = creditLimit;
        this.deliveryTerms = deliveryTerms;
        this.leadTime = leadTime;
        this.productCategories = productCategories;
        this.additionalNotes = additionalNotes;
    }

    // --- Getters and Setters ---
    public int getSupplierId() { return supplierId; }
    public void setSupplierId(int supplierId) { this.supplierId = supplierId; }
    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }
    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
    public String getBusinessRegNo() { return businessRegNo; }
    public void setBusinessRegNo(String businessRegNo) { this.businessRegNo = businessRegNo; }
    public String getTaxId() { return taxId; }
    public void setTaxId(String taxId) { this.taxId = taxId; }
    public String getCompanyAddress() { return companyAddress; }
    public void setCompanyAddress(String companyAddress) { this.companyAddress = companyAddress; }
    public String getContactPerson() { return contactPerson; }
    public void setContactPerson(String contactPerson) { this.contactPerson = contactPerson; }
    public String getContactPosition() { return contactPosition; }
    public void setContactPosition(String contactPosition) { this.contactPosition = contactPosition; }
    public String getContactPhone() { return contactPhone; }
    public void setContactPhone(String contactPhone) { this.contactPhone = contactPhone; }
    public String getContactEmail() { return contactEmail; }
    public void setContactEmail(String contactEmail) { this.contactEmail = contactEmail; }
    public String getPaymentMethod() { return paymentMethod; }
    public void setPaymentMethod(String paymentMethod) { this.paymentMethod = paymentMethod; }
    public String getPaymentTerms() { return paymentTerms; }
    public void setPaymentTerms(String paymentTerms) { this.paymentTerms = paymentTerms; }
    public BigDecimal getCreditLimit() { return creditLimit; }
    public void setCreditLimit(BigDecimal creditLimit) { this.creditLimit = creditLimit; }
    public String getDeliveryTerms() { return deliveryTerms; }
    public void setDeliveryTerms(String deliveryTerms) { this.deliveryTerms = deliveryTerms; }
    public int getLeadTime() { return leadTime; }
    public void setLeadTime(int leadTime) { this.leadTime = leadTime; }
    public String getProductCategories() { return productCategories; }
    public void setProductCategories(String productCategories) { this.productCategories = productCategories; }
    public String getAdditionalNotes() { return additionalNotes; }
    public void setAdditionalNotes(String additionalNotes) { this.additionalNotes = additionalNotes; }
    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    @Override
    public String toString() {
        return "Supplier{companyName='" + companyName + "', contactPerson='" + contactPerson + "'}";
    }

    public void setSupplierStatus(String supplierStatus) {
        throw new UnsupportedOperationException("Not supported yet."); // Generated from nbfs://nbhost/SystemFileSystem/Templates/Classes/Code/GeneratedMethodBody
    }
}