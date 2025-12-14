package com.warranty.dao;

import com.warranty.model.InventoryItem;
import com.warranty.util.DatabaseUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InventoryItemDAO {
    
    /**
     * Get all inventory items
     */
    public List<InventoryItem> getAllItems() {
        List<InventoryItem> items = new ArrayList<>();
        String sql = "SELECT * FROM inventory_items ORDER BY part_name";
        
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                items.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }
    
    /**
     * Get inventory item by ID
     */
    public InventoryItem getItemById(int itemId) {
        String sql = "SELECT * FROM inventory_items WHERE item_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, itemId);
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
     * Get inventory item by part number
     */
    public InventoryItem getItemByPartNumber(String partNumber) {
        String sql = "SELECT * FROM inventory_items WHERE part_number = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, partNumber);
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
     * Create new inventory item
     */
    public boolean createItem(InventoryItem item) {
        String sql = "INSERT INTO inventory_items (part_number, part_name, category, supplier, " +
                     "description, quantity_available, min_quantity, unit_price, location) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, item.getPartNumber());
            stmt.setString(2, item.getPartName());
            stmt.setString(3, item.getCategory());
            stmt.setString(4, item.getSupplier());
            stmt.setString(5, item.getDescription());
            stmt.setInt(6, item.getQuantityAvailable());
            stmt.setInt(7, item.getMinQuantity());
            stmt.setBigDecimal(8, item.getUnitPrice());
            stmt.setString(9, item.getLocation());
            
            int affected = stmt.executeUpdate();
            
            if (affected > 0) {
                ResultSet keys = stmt.getGeneratedKeys();
                if (keys.next()) {
                    item.setItemId(keys.getInt(1));
                }
                return true;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Update inventory item
     */
    public boolean updateItem(InventoryItem item) {
        String sql = "UPDATE inventory_items SET part_number=?, part_name=?, category=?, " +
                     "supplier=?, description=?, quantity_available=?, min_quantity=?, " +
                     "unit_price=?, location=? WHERE item_id=?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, item.getPartNumber());
            stmt.setString(2, item.getPartName());
            stmt.setString(3, item.getCategory());
            stmt.setString(4, item.getSupplier());
            stmt.setString(5, item.getDescription());
            stmt.setInt(6, item.getQuantityAvailable());
            stmt.setInt(7, item.getMinQuantity());
            stmt.setBigDecimal(8, item.getUnitPrice());
            stmt.setString(9, item.getLocation());
            stmt.setInt(10, item.getItemId());
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Delete inventory item
     */
    public boolean deleteItem(int itemId) {
        String sql = "DELETE FROM inventory_items WHERE item_id=?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, itemId);
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Increase quantity (import parts)
     */
    public boolean increaseQuantity(int itemId, int quantity) {
        String sql = "UPDATE inventory_items SET quantity_available = quantity_available + ? " +
                     "WHERE item_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, quantity);
            stmt.setInt(2, itemId);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Decrease quantity (export parts)
     */
    public boolean decreaseQuantity(int itemId, int quantity) {
        String sql = "UPDATE inventory_items SET quantity_available = quantity_available - ? " +
                     "WHERE item_id = ? AND quantity_available >= ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, quantity);
            stmt.setInt(2, itemId);
            stmt.setInt(3, quantity);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }
    
    /**
     * Get low stock items
     */
    public List<InventoryItem> getLowStockItems() {
        List<InventoryItem> items = new ArrayList<>();
        String sql = "SELECT * FROM inventory_items WHERE quantity_available <= min_quantity " +
                     "ORDER BY part_name";
        
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                items.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }
    
    /**
     * Search inventory items
     */
    public List<InventoryItem> searchItems(String keyword) {
        List<InventoryItem> items = new ArrayList<>();
        String sql = "SELECT * FROM inventory_items WHERE part_name LIKE ? OR part_number LIKE ? " +
                     "OR category LIKE ? ORDER BY part_name";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            String searchPattern = "%" + keyword + "%";
            stmt.setString(1, searchPattern);
            stmt.setString(2, searchPattern);
            stmt.setString(3, searchPattern);
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                items.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return items;
    }
    
    /**
     * Map ResultSet to InventoryItem
     */
    private InventoryItem mapResultSet(ResultSet rs) throws SQLException {
        InventoryItem item = new InventoryItem();
        item.setItemId(rs.getInt("item_id"));
        item.setPartNumber(rs.getString("part_number"));
        item.setPartName(rs.getString("part_name"));
        item.setCategory(rs.getString("category"));
        item.setSupplier(rs.getString("supplier"));
        item.setDescription(rs.getString("description"));
        item.setQuantityAvailable(rs.getInt("quantity_available"));
        item.setMinQuantity(rs.getInt("min_quantity"));
        item.setUnitPrice(rs.getBigDecimal("unit_price"));
        item.setLocation(rs.getString("location"));
        item.setCreatedAt(rs.getTimestamp("created_at"));
        item.setUpdatedAt(rs.getTimestamp("updated_at"));
        return item;
    }
}
