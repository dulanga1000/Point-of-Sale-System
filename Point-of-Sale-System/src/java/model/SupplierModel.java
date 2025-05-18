/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

public class SupplierModel {
    private int supplierId;
    private String companyName;

    public SupplierModel() {
    }

    public SupplierModel(int supplierId, String companyName) {
        this.supplierId = supplierId;
        this.companyName = companyName;
    }

    public int getSupplierId() { return supplierId; }
    public void setSupplierId(int supplierId) { this.supplierId = supplierId; }
    public String getCompanyName() { return companyName; }
    public void setCompanyName(String companyName) { this.companyName = companyName; }

    @Override
    public String toString() {
        return "SupplierModel{" + "supplierId=" + supplierId + ", companyName='" + companyName + '\'' + '}';
    }
}