package com.warranty.dao;

import com.warranty.model.Product;
import com.warranty.util.DatabaseUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class ProductDAO {
    
    /**
     * Get all products
     */
    public List<Product> getAllProducts() {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products ORDER BY product_name";
        
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                products.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }
    
    /**
     * Get product by ID
     */
    public Product getProductById(int productId) {
        String sql = "SELECT * FROM products WHERE product_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, productId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Get product by code
     */
    public Product getProductByCode(String productCode) {
        String sql = "SELECT * FROM products WHERE product_code = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, productCode);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }
    
    /**
     * Create new product
     */
    public boolean createProduct(Product product) {
        String sql = "INSERT INTO products (product_code, product_name, category, brand, model, " +
                     "description, warranty_period_months) VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, product.getProductCode());
            stmt.setString(2, product.getName());
            stmt.setString(3, product.getCategory());
            stmt.setString(4, product.getBrand());
            stmt.setString(5, product.getModel());
            stmt.setString(6, product.getDescription());
            stmt.setInt(7, product.getWarrantyMonths());
            
            int affected = stmt.executeUpdate();
            
            if (affected > 0) {
                ResultSet keys = stmt.getGeneratedKeys();
                if (keys.next()) {
                    product.setProductId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Update product
     */
    public boolean updateProduct(Product product) {
        String sql = "UPDATE products SET product_code=?, product_name=?, category=?, brand=?, " +
                     "model=?, description=?, warranty_period_months=? WHERE product_id=?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, product.getProductCode());
            stmt.setString(2, product.getName());
            stmt.setString(3, product.getCategory());
            stmt.setString(4, product.getBrand());
            stmt.setString(5, product.getModel());
            stmt.setString(6, product.getDescription());
            stmt.setInt(7, product.getWarrantyMonths());
            stmt.setInt(8, product.getProductId());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Delete product
     */
    public boolean deleteProduct(int productId) {
        String sql = "DELETE FROM products WHERE product_id=?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, productId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Search products by keyword
     */
    public List<Product> searchProducts(String keyword) {
        List<Product> products = new ArrayList<>();
        String sql = "SELECT * FROM products WHERE product_name LIKE ? OR product_code LIKE ? " +
                     "OR brand LIKE ? OR category LIKE ? ORDER BY product_name";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            stmt.setString(1, searchPattern);
            stmt.setString(2, searchPattern);
            stmt.setString(3, searchPattern);
            stmt.setString(4, searchPattern);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                products.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return products;
    }
    
    /**
     * Map ResultSet to Product
     */
    private Product mapResultSet(ResultSet rs) throws SQLException {
        Product product = new Product();
        product.setProductId(rs.getInt("product_id"));
        product.setProductCode(rs.getString("product_code"));
        product.setName(rs.getString("product_name"));
        product.setCategory(rs.getString("category"));
        product.setBrand(rs.getString("brand"));
        product.setModel(rs.getString("model"));
        product.setDescription(rs.getString("description"));
        product.setWarrantyMonths(rs.getInt("warranty_period_months"));
        product.setCreatedAt(rs.getTimestamp("created_at"));
        product.setUpdatedAt(rs.getTimestamp("updated_at"));
        return product;
    }
}
