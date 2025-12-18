package com.warranty.dao;

import com.warranty.model.ProductSerial;
import com.warranty.model.Product;
import com.warranty.util.DatabaseUtil;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class ProductSerialDAO {
    
    /**
     * Lấy thông tin serial product theo số serial
     */
    public ProductSerial getBySerialNumber(String serialNumber) throws SQLException {
        String sql = "SELECT ps.*, p.product_name, p.category, p.brand, " +
                     "c.full_name as customer_name, c.phone as customer_phone, c.email as customer_email " +
                     "FROM product_serials ps " +
                     "LEFT JOIN products p ON ps.product_id = p.product_id " +
                     "LEFT JOIN customers c ON ps.customer_id = c.customer_id " +
                     "WHERE ps.serial_number = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, serialNumber);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                ProductSerial ps = new ProductSerial();
                ps.setSerialId(rs.getInt("serial_id"));
                ps.setProductId(rs.getInt("product_id"));
                ps.setSerialNumber(rs.getString("serial_number"));
                ps.setCustomerId(rs.getInt("customer_id"));
                ps.setPurchaseDate(rs.getDate("purchase_date"));
                ps.setWarrantyStartDate(rs.getDate("warranty_start_date"));
                ps.setWarrantyEndDate(rs.getDate("warranty_end_date"));
                ps.setNotes(rs.getString("notes"));
                ps.setCreatedAt(rs.getTimestamp("created_at"));
                
                // Load Product object if available
                String productName = rs.getString("product_name");
                if (productName != null && ps.getProductId() > 0) {
                    Product product = new Product();
                    product.setProductId(ps.getProductId());
                    product.setProductName(productName);
                    product.setCategory(rs.getString("category"));
                    product.setBrand(rs.getString("brand"));
                    ps.setProduct(product);
                }
                
                // Additional info
                ps.setProductName(productName);
                ps.setCustomerName(rs.getString("customer_name"));
                ps.setCustomerPhone(rs.getString("customer_phone"));
                ps.setCustomerEmail(rs.getString("customer_email"));
                
                return ps;
            }
        }
        return null;
    }

    /**
     * Get product serial by serial_id
     */
    public ProductSerial getBySerialId(int serialId) throws SQLException {
        String sql = "SELECT ps.*, p.product_name, p.category, p.brand, " +
                     "c.full_name as customer_name, c.phone as customer_phone, c.email as customer_email " +
                     "FROM product_serials ps " +
                     "LEFT JOIN products p ON ps.product_id = p.product_id " +
                     "LEFT JOIN customers c ON ps.customer_id = c.customer_id " +
                     "WHERE ps.serial_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, serialId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                ProductSerial ps = new ProductSerial();
                ps.setSerialId(rs.getInt("serial_id"));
                ps.setProductId(rs.getInt("product_id"));
                ps.setSerialNumber(rs.getString("serial_number"));
                ps.setCustomerId(rs.getInt("customer_id"));
                ps.setPurchaseDate(rs.getDate("purchase_date"));
                ps.setWarrantyStartDate(rs.getDate("warranty_start_date"));
                ps.setWarrantyEndDate(rs.getDate("warranty_end_date"));
                ps.setNotes(rs.getString("notes"));
                ps.setCreatedAt(rs.getTimestamp("created_at"));
                
                // Load Product object if available
                String productName = rs.getString("product_name");
                if (productName != null && ps.getProductId() > 0) {
                    Product product = new Product();
                    product.setProductId(ps.getProductId());
                    product.setProductName(productName);
                    product.setCategory(rs.getString("category"));
                    product.setBrand(rs.getString("brand"));
                    ps.setProduct(product);
                }
                
                // Additional info
                ps.setProductName(productName);
                ps.setCustomerName(rs.getString("customer_name"));
                ps.setCustomerPhone(rs.getString("customer_phone"));
                ps.setCustomerEmail(rs.getString("customer_email"));
                
                return ps;
            }
        }
        return null;
    }
    
    /**
     * Kiểm tra tình trạng bảo hành của serial
     */
    public boolean isUnderWarranty(String serialNumber) throws SQLException {
        ProductSerial ps = getBySerialNumber(serialNumber);
        if (ps == null || ps.getWarrantyEndDate() == null) {
            return false;
        }
        return ps.getWarrantyEndDate().after(new java.sql.Date(System.currentTimeMillis()));
    }
    
    /**
     * Lấy tất cả serial của một sản phẩm
     */
    public List<ProductSerial> getByProductId(int productId) throws SQLException {
        List<ProductSerial> list = new ArrayList<>();
        String sql = "SELECT ps.*, c.full_name as customer_name, c.phone as customer_phone " +
                     "FROM product_serials ps " +
                     "LEFT JOIN customers c ON ps.customer_id = c.customer_id " +
                     "WHERE ps.product_id = ? ORDER BY ps.serial_number";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, productId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                ProductSerial ps = new ProductSerial();
                ps.setSerialId(rs.getInt("serial_id"));
                ps.setProductId(rs.getInt("product_id"));
                ps.setSerialNumber(rs.getString("serial_number"));
                ps.setCustomerId(rs.getInt("customer_id"));
                ps.setPurchaseDate(rs.getDate("purchase_date"));
                ps.setWarrantyStartDate(rs.getDate("warranty_start_date"));
                ps.setWarrantyEndDate(rs.getDate("warranty_end_date"));
                ps.setCustomerName(rs.getString("customer_name"));
                ps.setCustomerPhone(rs.getString("customer_phone"));
                
                list.add(ps);
            }
        }
        return list;
    }
    
    /**
     * Tạo mới serial product
     */
    public boolean create(ProductSerial productSerial) throws SQLException {
        String sql = "INSERT INTO product_serials (product_id, serial_number, customer_id, " +
                     "purchase_date, warranty_start_date, warranty_end_date, notes) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, productSerial.getProductId());
            stmt.setString(2, productSerial.getSerialNumber());
            stmt.setInt(3, productSerial.getCustomerId());
            stmt.setDate(4, productSerial.getPurchaseDate());
            stmt.setDate(5, productSerial.getWarrantyStartDate());
            stmt.setDate(6, productSerial.getWarrantyEndDate());
            stmt.setString(7, productSerial.getNotes());
            
            int affected = stmt.executeUpdate();
            
            if (affected > 0) {
                ResultSet keys = stmt.getGeneratedKeys();
                if (keys.next()) {
                    productSerial.setSerialId(keys.getInt(1));
                }
                return true;
            }
        }
        return false;
    }
    
    /**
     * Cập nhật thông tin serial product
     */
    public boolean update(ProductSerial productSerial) throws SQLException {
        String sql = "UPDATE product_serials SET product_id=?, serial_number=?, customer_id=?, " +
                     "purchase_date=?, warranty_start_date=?, warranty_end_date=?, " +
                     "warranty_months=?, notes=? WHERE serial_id=?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, productSerial.getProductId());
            stmt.setString(2, productSerial.getSerialNumber());
            stmt.setObject(3, productSerial.getCustomerId() == 0 ? null : productSerial.getCustomerId());
            stmt.setDate(4, productSerial.getPurchaseDate());
            stmt.setDate(5, productSerial.getWarrantyStartDate());
            stmt.setDate(6, productSerial.getWarrantyEndDate());
            stmt.setInt(7, productSerial.getWarrantyMonths());
            stmt.setString(8, productSerial.getNotes());
            stmt.setInt(9, productSerial.getSerialId());
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Xóa serial product
     */
    public boolean delete(int serialId) throws SQLException {
        String sql = "DELETE FROM product_serials WHERE serial_id=?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, serialId);
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Lấy tất cả serial products
     */
    public List<ProductSerial> getAll() throws SQLException {
        List<ProductSerial> list = new ArrayList<>();
        String sql = "SELECT ps.*, p.product_name, c.full_name as customer_name " +
                     "FROM product_serials ps " +
                     "LEFT JOIN products p ON ps.product_id = p.product_id " +
                     "LEFT JOIN customers c ON ps.customer_id = c.customer_id " +
                     "ORDER BY ps.serial_number";
        
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                ProductSerial ps = new ProductSerial();
                ps.setSerialId(rs.getInt("serial_id"));
                ps.setProductId(rs.getInt("product_id"));
                ps.setSerialNumber(rs.getString("serial_number"));
                ps.setCustomerId(rs.getInt("customer_id"));
                ps.setPurchaseDate(rs.getDate("purchase_date"));
                ps.setWarrantyStartDate(rs.getDate("warranty_start_date"));
                ps.setWarrantyEndDate(rs.getDate("warranty_end_date"));
                ps.setProductName(rs.getString("product_name"));
                ps.setCustomerName(rs.getString("customer_name"));
                
                list.add(ps);
            }
        }
        return list;
    }
    
    /**
     * Lấy serial products của khách hàng
     */
    public List<ProductSerial> getByCustomerId(int customerId) throws SQLException {
        List<ProductSerial> list = new ArrayList<>();
        String sql = "SELECT ps.*, p.product_name " +
                     "FROM product_serials ps " +
                     "LEFT JOIN products p ON ps.product_id = p.product_id " +
                     "WHERE ps.customer_id = ? ORDER BY ps.purchase_date DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, customerId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                ProductSerial ps = new ProductSerial();
                ps.setSerialId(rs.getInt("serial_id"));
                ps.setProductId(rs.getInt("product_id"));
                ps.setSerialNumber(rs.getString("serial_number"));
                ps.setCustomerId(rs.getInt("customer_id"));
                ps.setPurchaseDate(rs.getDate("purchase_date"));
                ps.setWarrantyStartDate(rs.getDate("warranty_start_date"));
                ps.setWarrantyEndDate(rs.getDate("warranty_end_date"));
                ps.setProductName(rs.getString("product_name"));
                
                list.add(ps);
            }
        }
        return list;
    }
}
