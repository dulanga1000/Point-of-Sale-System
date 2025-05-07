/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author User
 */

public class Product {
    private int id;
    private String name;
    private String category;
    private double price;
    private String sku;
    private int stock;
    private String supplier;
    private String imagePath;
    private String status;

    public Product(int id, String name, String category, double price, String sku, int stock, String supplier, String imagePath, String status) {
        this.id = id;
        this.name = name;
        this.category = category;
        this.price = price;
        this.sku = sku;
        this.stock = stock;
        this.supplier = supplier;
        this.imagePath = imagePath;
        this.status = status;
    }

    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }

    public double getPrice() { return price; }
    public void setPrice(double price) { this.price = price; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }

    public String getSupplier() { return supplier; }
    public void setSupplier(String supplier) { this.supplier = supplier; }

    public String getImagePath() { return imagePath; }
    public void setImagePath(String imagePath) { this.imagePath = imagePath; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
}
