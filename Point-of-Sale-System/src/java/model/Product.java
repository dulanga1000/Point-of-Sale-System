/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package model;

/**
 *
 * @author User
 */

import java.math.BigDecimal;
import java.sql.Timestamp;

public class Product {
    private int id; // Corresponds to products.id
    private String name;
    private Integer productCategoryId; // Foreign Key
    private String sku;
    private String description;
    private BigDecimal purchaseUnitPrice; // Cost from supplier
    private BigDecimal sellingUnitPrice;  // Selling price in POS (your existing 'price')
    private int stockQuantity;
    private Integer reorderLevel;
    private Integer primarySupplierId; // Foreign Key
    private String imageFilename;
    private String status; // In DB: ENUM('Active','Inactive','Discontinued')
    private Timestamp createdAt;
    private Timestamp updatedAt;

    // For displaying category name and supplier name if joined
    private String productCategoryName;
    private String primarySupplierName;


    // Constructors
    public Product() {
    }

    // Constructor for creating a new product or when some fields are optional
    public Product(String name, Integer productCategoryId, String sku, BigDecimal purchaseUnitPrice, BigDecimal sellingUnitPrice, int stockQuantity, Integer primarySupplierId, String imageFilename, String status) {
        this.name = name;
        this.productCategoryId = productCategoryId;
        this.sku = sku;
        this.purchaseUnitPrice = purchaseUnitPrice;
        this.sellingUnitPrice = sellingUnitPrice;
        this.stockQuantity = stockQuantity;
        this.primarySupplierId = primarySupplierId;
        this.imageFilename = imageFilename;
        this.status = status;
    }
    
    // Full constructor (useful when fetching all data from DB)
    public Product(int id, String name, Integer productCategoryId, String sku, String description, BigDecimal purchaseUnitPrice, BigDecimal sellingUnitPrice, int stockQuantity, Integer reorderLevel, Integer primarySupplierId, String imageFilename, String status, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.name = name;
        this.productCategoryId = productCategoryId;
        this.sku = sku;
        this.description = description;
        this.purchaseUnitPrice = purchaseUnitPrice;
        this.sellingUnitPrice = sellingUnitPrice;
        this.stockQuantity = stockQuantity;
        this.reorderLevel = reorderLevel;
        this.primarySupplierId = primarySupplierId;
        this.imageFilename = imageFilename;
        this.status = status;
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }


    // Getters and Setters
    public int getId() { return id; }
    public void setId(int id) { this.id = id; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public Integer getProductCategoryId() { return productCategoryId; }
    public void setProductCategoryId(Integer productCategoryId) { this.productCategoryId = productCategoryId; }

    public String getSku() { return sku; }
    public void setSku(String sku) { this.sku = sku; }

    public String getDescription() { return description; }
    public void setDescription(String description) { this.description = description; }
    
    public BigDecimal getPurchaseUnitPrice() { return purchaseUnitPrice; }
    public void setPurchaseUnitPrice(BigDecimal purchaseUnitPrice) { this.purchaseUnitPrice = purchaseUnitPrice; }

    public BigDecimal getSellingUnitPrice() { return sellingUnitPrice; }
    public void setSellingUnitPrice(BigDecimal sellingUnitPrice) { this.sellingUnitPrice = sellingUnitPrice; }

    public int getStockQuantity() { return stockQuantity; }
    public void setStockQuantity(int stockQuantity) { this.stockQuantity = stockQuantity; }

    public Integer getReorderLevel() { return reorderLevel; }
    public void setReorderLevel(Integer reorderLevel) { this.reorderLevel = reorderLevel; }

    public Integer getPrimarySupplierId() { return primarySupplierId; }
    public void setPrimarySupplierId(Integer primarySupplierId) { this.primarySupplierId = primarySupplierId; }

    public String getImageFilename() { return imageFilename; }
    public void setImageFilename(String imageFilename) { this.imageFilename = imageFilename; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public Timestamp getCreatedAt() { return createdAt; }
    public void setCreatedAt(Timestamp createdAt) { this.createdAt = createdAt; }

    public Timestamp getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(Timestamp updatedAt) { this.updatedAt = updatedAt; }

    // Getters and setters for joined data (optional, fill these after a JOIN query)
    public String getProductCategoryName() { return productCategoryName; }
    public void setProductCategoryName(String productCategoryName) { this.productCategoryName = productCategoryName; }

    public String getPrimarySupplierName() { return primarySupplierName; }
    public void setPrimarySupplierName(String primarySupplierName) { this.primarySupplierName = primarySupplierName; }


    @Override
    public String toString() {
        return "Product{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", productCategoryId=" + productCategoryId +
                ", sku='" + sku + '\'' +
                ", sellingUnitPrice=" + sellingUnitPrice +
                ", stockQuantity=" + stockQuantity +
                ", primarySupplierId=" + primarySupplierId +
                ", status='" + status + '\'' +
                '}';
    }
}