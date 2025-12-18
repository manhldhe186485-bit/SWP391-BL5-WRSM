package com.warranty.dao;

import com.warranty.model.PartsRequest;
import com.warranty.model.PartsRequestItem;
import com.warranty.util.DatabaseUtil;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class PartsRequestDAO {
    
    /**
     * Tạo yêu cầu linh kiện mới (với transaction)
     */
    public boolean createRequest(PartsRequest request, List<PartsRequestItem> items) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt1 = null;
        PreparedStatement stmt2 = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);
            
            System.out.println("========== PartsRequestDAO.createRequest() ==========");
            System.out.println("Ticket ID: " + request.getTicketId());
            System.out.println("Technician ID: " + request.getTechnicianId());
            System.out.println("Items count: " + items.size());
            
            // Generate request number
            String requestNumber = generateRequestNumber();
            System.out.println("Generated Request Number: " + requestNumber);
            
            // 1. Insert parts_requests
            String sql1 = "INSERT INTO parts_requests (request_number, ticket_id, technician_id, " +
                         "status, notes) VALUES (?, ?, ?, 'PENDING', ?)";
            stmt1 = conn.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS);
            stmt1.setString(1, requestNumber);
            stmt1.setInt(2, request.getTicketId());
            stmt1.setInt(3, request.getTechnicianId());
            stmt1.setString(4, request.getNotes());
            
            int rowsAffected = stmt1.executeUpdate();
            System.out.println("Rows affected in parts_requests: " + rowsAffected);
            
            // Get generated request_id
            ResultSet keys = stmt1.getGeneratedKeys();
            if (!keys.next()) {
                conn.rollback();
                return false;
            }
            int requestId = keys.getInt(1);
            System.out.println("Generated Request ID: " + requestId);
            
            // 2. Insert parts_request_items
            String sql2 = "INSERT INTO parts_request_items (request_id, item_id, " +
                         "quantity_requested, notes) VALUES (?, ?, ?, ?)";
            stmt2 = conn.prepareStatement(sql2);
            
            int itemCount = 0;
            for (PartsRequestItem item : items) {
                // Find or create inventory item
                int itemId = findOrCreateInventoryItem(conn, item.getPartName(), item.getPartNumber());
                
                if (itemId > 0) {
                    stmt2.setInt(1, requestId);
                    stmt2.setInt(2, itemId);
                    stmt2.setInt(3, item.getQuantityRequested());
                    stmt2.setString(4, item.getNotes());
                    stmt2.addBatch();
                    itemCount++;
                    System.out.println("  - Added item: " + item.getPartName() + " (ID: " + itemId + ")");
                } else {
                    System.err.println("  - ERROR: Could not find/create item: " + item.getPartName());
                }
            }
            
            if (itemCount == 0) {
                System.err.println("ERROR: No valid items to insert!");
                conn.rollback();
                return false;
            }
            
            int[] results = stmt2.executeBatch();
            System.out.println("Inserted " + results.length + " items into parts_request_items");
            
            conn.commit();
            System.out.println("✓ Transaction committed successfully!");
            request.setRequestId(requestId);
            request.setRequestNumber(requestNumber);
            System.out.println("========== PartsRequestDAO.createRequest() SUCCESS ==========");
            return true;
            
        } catch (SQLException e) {
            System.err.println("========== SQLException in createRequest ==========");
            System.err.println("Error Message: " + e.getMessage());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
            
            if (conn != null) {
                try {
                    conn.rollback();
                    System.out.println("Transaction rolled back");
                } catch (SQLException ex) {
                    System.err.println("Rollback failed: " + ex.getMessage());
                }
            }
            throw e;
        } catch (Exception e) {
            System.err.println("========== Exception in createRequest ==========");
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    System.err.println("Rollback failed: " + ex.getMessage());
                }
            }
            throw new SQLException("Failed to create request: " + e.getMessage(), e);
        } finally {
            if (stmt1 != null) stmt1.close();
            if (stmt2 != null) stmt2.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }
    
    /**
     * Lấy yêu cầu linh kiện theo ID (kèm items)
     */
    public PartsRequest getRequestById(int requestId) throws SQLException {
        String sql = "SELECT pr.*, u.full_name as technician_name, rt.ticket_number " +
                     "FROM parts_requests pr " +
                     "LEFT JOIN users u ON pr.technician_id = u.user_id " +
                     "LEFT JOIN repair_tickets rt ON pr.ticket_id = rt.ticket_id " +
                     "WHERE pr.request_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, requestId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                PartsRequest pr = mapResultSet(rs);
                
                // Load items
                pr.setItems(getItemsByRequestId(requestId));
                
                return pr;
            }
        }
        return null;
    }
    
    /**
     * Lấy danh sách items của một request
     */
    private List<PartsRequestItem> getItemsByRequestId(int requestId) throws SQLException {
        List<PartsRequestItem> items = new ArrayList<>();
        String sql = "SELECT pri.*, ii.part_name, ii.part_number, ii.quantity_available " +
                     "FROM parts_request_items pri " +
                     "LEFT JOIN inventory_items ii ON pri.inventory_item_id = ii.item_id " +
                     "WHERE pri.request_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, requestId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                PartsRequestItem item = new PartsRequestItem();
                item.setItemId(rs.getInt("item_id"));
                item.setRequestId(rs.getInt("request_id"));
                item.setInventoryItemId(rs.getInt("inventory_item_id"));
                item.setQuantityRequested(rs.getInt("quantity_requested"));
                item.setQuantityApproved(rs.getInt("quantity_approved"));
                item.setNotes(rs.getString("notes"));
                item.setPartName(rs.getString("part_name"));
                item.setPartNumber(rs.getString("part_number"));
                item.setQuantityAvailable(rs.getInt("quantity_available"));
                items.add(item);
            }
        }
        return items;
    }
    
    /**
     * Lấy yêu cầu theo technician
     */
    public List<PartsRequest> getRequestsByTechnician(int technicianId) throws SQLException {
        System.out.println("========== PartsRequestDAO.getRequestsByTechnician(" + technicianId + ") ==========");
        
        List<PartsRequest> list = new ArrayList<>();
        String sql = "SELECT pr.*, rt.ticket_number " +
                     "FROM parts_requests pr " +
                     "LEFT JOIN repair_tickets rt ON pr.ticket_id = rt.ticket_id " +
                     "WHERE pr.technician_id = ? " +
                     "ORDER BY pr.request_date DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, technicianId);
            ResultSet rs = stmt.executeQuery();
            
            int count = 0;
            while (rs.next()) {
                PartsRequest pr = mapResultSet(rs);
                
                // Count items for this request
                int itemCount = getItemCountByRequestId(pr.getRequestId());
                pr.setItemCount(itemCount);
                
                list.add(pr);
                count++;
                System.out.println("  - Request #" + count + ": ID=" + pr.getRequestId() + 
                                 ", Number=" + pr.getRequestNumber() + 
                                 ", Items=" + itemCount);
            }
            
            System.out.println("Total requests found: " + list.size());
        } catch (SQLException e) {
            System.err.println("ERROR in getRequestsByTechnician: " + e.getMessage());
            throw e;
        }
        return list;
    }
    
    /**
     * Count items in a request
     */
    private int getItemCountByRequestId(int requestId) throws SQLException {
        String sql = "SELECT COUNT(*) as count FROM parts_request_items WHERE request_id = ?";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, requestId);
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("count");
            }
        }
        return 0;
    }
    
    /**
     * Lấy yêu cầu theo ticket
     */
    public List<PartsRequest> getRequestsByTicket(int ticketId) throws SQLException {
        List<PartsRequest> list = new ArrayList<>();
        String sql = "SELECT pr.*, u.full_name as technician_name " +
                     "FROM parts_requests pr " +
                     "LEFT JOIN users u ON pr.technician_id = u.user_id " +
                     "WHERE pr.ticket_id = ? " +
                     "ORDER BY pr.request_date DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, ticketId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                PartsRequest pr = mapResultSet(rs);
                list.add(pr);
            }
        }
        return list;
    }
    
    /**
     * Lấy yêu cầu theo status
     */
    public List<PartsRequest> getRequestsByStatus(String... statuses) throws SQLException {
        List<PartsRequest> list = new ArrayList<>();
        
        // Build IN clause
        StringBuilder inClause = new StringBuilder();
        for (int i = 0; i < statuses.length; i++) {
            if (i > 0) inClause.append(",");
            inClause.append("?");
        }
        
        String sql = "SELECT pr.*, u.full_name as technician_name, rt.ticket_number " +
                     "FROM parts_requests pr " +
                     "LEFT JOIN users u ON pr.technician_id = u.user_id " +
                     "LEFT JOIN repair_tickets rt ON pr.ticket_id = rt.ticket_id " +
                     "WHERE pr.status IN (" + inClause + ") " +
                     "ORDER BY pr.request_date DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            for (int i = 0; i < statuses.length; i++) {
                stmt.setString(i + 1, statuses[i]);
            }
            
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                PartsRequest pr = mapResultSet(rs);
                // Load items for each request
                pr.setItems(getItemsByRequestId(pr.getRequestId()));
                list.add(pr);
            }
        }
        return list;
    }
    
    /**
     * Cập nhật status của yêu cầu
     */
    public boolean updateRequestStatus(int requestId, String status, int processedById, 
                                       String processingNotes) throws SQLException {
        String sql = "UPDATE parts_requests SET status=?, processed_by=?, " +
                     "processed_date=NOW(), processing_notes=? WHERE request_id=?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            stmt.setInt(2, processedById);
            stmt.setString(3, processingNotes);
            stmt.setInt(4, requestId);
            
            return stmt.executeUpdate() > 0;
        }
    }
    
    /**
     * Approve request và cập nhật inventory
     */
    public boolean approveRequest(int requestId, int warehouseStaffId, String notes) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt1 = null;
        PreparedStatement stmt2 = null;
        PreparedStatement stmt3 = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);
            
            // 1. Get request items
            List<PartsRequestItem> items = getItemsByRequestId(requestId);
            
            // 2. Update parts_request_items (set quantity_approved = quantity_requested)
            String sql1 = "UPDATE parts_request_items SET quantity_approved = quantity_requested " +
                         "WHERE request_id = ?";
            stmt1 = conn.prepareStatement(sql1);
            stmt1.setInt(1, requestId);
            stmt1.executeUpdate();
            
            // 3. Deduct from inventory
            String sql2 = "UPDATE inventory_items SET quantity_available = quantity_available - ? " +
                         "WHERE item_id = ?";
            stmt2 = conn.prepareStatement(sql2);
            
            for (PartsRequestItem item : items) {
                stmt2.setInt(1, item.getQuantityRequested());
                stmt2.setInt(2, item.getInventoryItemId());
                stmt2.addBatch();
            }
            stmt2.executeBatch();
            
            // 4. Update request status
            String sql3 = "UPDATE parts_requests SET status='approved', processed_by=?, " +
                         "processed_date=NOW(), processing_notes=? WHERE request_id=?";
            stmt3 = conn.prepareStatement(sql3);
            stmt3.setInt(1, warehouseStaffId);
            stmt3.setString(2, notes);
            stmt3.setInt(3, requestId);
            stmt3.executeUpdate();
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (stmt1 != null) stmt1.close();
            if (stmt2 != null) stmt2.close();
            if (stmt3 != null) stmt3.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }
    
    /**
     * Xóa yêu cầu
     */
    public boolean delete(int requestId) throws SQLException {
        Connection conn = null;
        PreparedStatement stmt1 = null;
        PreparedStatement stmt2 = null;
        
        try {
            conn = DatabaseUtil.getConnection();
            conn.setAutoCommit(false);
            
            // Delete items first
            String sql1 = "DELETE FROM parts_request_items WHERE request_id = ?";
            stmt1 = conn.prepareStatement(sql1);
            stmt1.setInt(1, requestId);
            stmt1.executeUpdate();
            
            // Delete request
            String sql2 = "DELETE FROM parts_requests WHERE request_id = ?";
            stmt2 = conn.prepareStatement(sql2);
            stmt2.setInt(1, requestId);
            stmt2.executeUpdate();
            
            conn.commit();
            return true;
            
        } catch (SQLException e) {
            if (conn != null) {
                conn.rollback();
            }
            throw e;
        } finally {
            if (stmt1 != null) stmt1.close();
            if (stmt2 != null) stmt2.close();
            if (conn != null) {
                conn.setAutoCommit(true);
                conn.close();
            }
        }
    }
    
    /**
     * Map ResultSet to PartsRequest
     */
    private PartsRequest mapResultSet(ResultSet rs) throws SQLException {
        PartsRequest pr = new PartsRequest();
        pr.setRequestId(rs.getInt("request_id"));
        
        // Set request_number if available
        if (hasColumn(rs, "request_number")) {
            pr.setRequestNumber(rs.getString("request_number"));
        }
        
        pr.setTicketId(rs.getInt("ticket_id"));
        pr.setTechnicianId(rs.getInt("technician_id"));
        
        // warehouse_staff_id (nullable)
        if (hasColumn(rs, "warehouse_staff_id")) {
            int warehouseStaffId = rs.getInt("warehouse_staff_id");
            if (!rs.wasNull()) {
                pr.setWarehouseStaffId(warehouseStaffId);
            }
        }
        
        pr.setStatus(PartsRequest.RequestStatus.valueOf(rs.getString("status")));
        pr.setRequestDate(rs.getTimestamp("request_date"));
        
        // approved_date (nullable)
        if (hasColumn(rs, "approved_date")) {
            Timestamp approvedDate = rs.getTimestamp("approved_date");
            if (approvedDate != null) {
                pr.setApprovedDate(approvedDate);
            }
        }
        
        // fulfilled_date (nullable)
        if (hasColumn(rs, "fulfilled_date")) {
            Timestamp fulfilledDate = rs.getTimestamp("fulfilled_date");
            if (fulfilledDate != null) {
                pr.setFulfilledDate(fulfilledDate);
            }
        }
        
        pr.setNotes(rs.getString("notes"));
        
        // rejection_reason (nullable)
        if (hasColumn(rs, "rejection_reason")) {
            pr.setRejectionReason(rs.getString("rejection_reason"));
        }
        
        // created_at, updated_at
        if (hasColumn(rs, "created_at")) {
            pr.setCreatedAt(rs.getTimestamp("created_at"));
        }
        if (hasColumn(rs, "updated_at")) {
            pr.setUpdatedAt(rs.getTimestamp("updated_at"));
        }
        
        // Additional fields if available (from JOIN)
        if (hasColumn(rs, "technician_name")) {
            pr.setTechnicianName(rs.getString("technician_name"));
        }
        if (hasColumn(rs, "ticket_number")) {
            pr.setTicketCode(rs.getString("ticket_number"));
        }
        
        return pr;
    }
    
    /**
     * Generate unique request number
     * Format: PR-YYYY-NNNN
     */
    private String generateRequestNumber() {
        int year = java.time.Year.now().getValue();
        int count = (int)(Math.random() * 9999) + 1;
        return String.format("PR-%d-%04d", year, count);
    }
    
    /**
     * Find inventory item by name/code, or create new one if not exists
     */
    private int findOrCreateInventoryItem(Connection conn, String partName, String partCode) throws SQLException {
        // Try to find existing item by code
        if (partCode != null && !partCode.trim().isEmpty()) {
            String sql = "SELECT item_id FROM inventory_items WHERE item_code = ?";
            try (PreparedStatement stmt = conn.prepareStatement(sql)) {
                stmt.setString(1, partCode.trim());
                ResultSet rs = stmt.executeQuery();
                if (rs.next()) {
                    return rs.getInt("item_id");
                }
            }
        }
        
        // Try to find by name
        String sql = "SELECT item_id FROM inventory_items WHERE item_name LIKE ?";
        try (PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, "%" + partName.trim() + "%");
            ResultSet rs = stmt.executeQuery();
            if (rs.next()) {
                return rs.getInt("item_id");
            }
        }
        
        // Create new item if not found
        String insertSql = "INSERT INTO inventory_items (item_code, item_name, category, " +
                          "quantity_in_stock, min_stock_level) VALUES (?, ?, 'REQUEST', 0, 0)";
        try (PreparedStatement stmt = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS)) {
            String itemCode = (partCode != null && !partCode.trim().isEmpty()) ? 
                             partCode.trim() : "REQ-" + System.currentTimeMillis();
            stmt.setString(1, itemCode);
            stmt.setString(2, partName.trim());
            stmt.executeUpdate();
            
            ResultSet keys = stmt.getGeneratedKeys();
            if (keys.next()) {
                int newId = keys.getInt(1);
                System.out.println("Created new inventory item: " + partName + " (ID: " + newId + ")");
                return newId;
            }
        }
        
        return 0;
    }
    
    /**
     * Check if column exists in ResultSet
     */
    private boolean hasColumn(ResultSet rs, String columnName) {
        try {
            rs.findColumn(columnName);
            return true;
        } catch (SQLException e) {
            return false;
        }
    }
}
