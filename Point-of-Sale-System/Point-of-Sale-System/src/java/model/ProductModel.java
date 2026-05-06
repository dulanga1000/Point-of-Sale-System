/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

import java.math.BigDecimal;

public class ProductModel {
    private int id;
    private String name;
    private String category;
    private BigDecimal price; // Use BigDecimal for currency
    private String sku;
    private int stock;
    private String supplierName; // This will hold the supplier's name from products.supplier
    private String imagePath;
    private String status;

    public ProductModel() {
    }

    public ProductModel(int id, String name, String category, BigDecimal price, String sku, int stock, String supplierName, String imagePath, String status) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.price = price;
        this.sku = sku;
        this.stock = stock;
        this.supplierName = supplierName;
        this.imagePath = imagePath;
        this.status = status;
    }

    // Getters
    public int getId() { return id; }
    public String getName() { return name; }
    public String getCategory() { return category; }
    public BigDecimal getPrice() { return price; }
    public String getSku() { return sku; }
    public int getStock() { return stock; }
    public String getSupplierName() { return supplierName; }
    public String getImagePath() { return imagePath; }
    public String getStatus() { return status; }

    // Setters
    public void setId(int id) { this.id = id; }
    public void setName(String name) { this.name = name; }
    public void setCategory(String category) { this.category = category; }
    public void setPrice(BigDecimal price) { this.price = price; }
    public void setSku(String sku) { this.sku = sku; }
    public void setStock(int stock) { this.stock = stock; }
    public void setSupplierName(String supplierName) { this.supplierName = supplierName; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }
    public void setStatus(String status) { this.status = status; }

    @Override
    public String toString() {
        return "ProductModel{" + "id=" + id + ", name='" + name + '\'' + ", supplierName='" + supplierName + '\'' + '}';
    }
}