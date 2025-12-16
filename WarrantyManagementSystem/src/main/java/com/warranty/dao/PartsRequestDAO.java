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
            
            // 1. Insert parts_requests
            String sql1 = "INSERT INTO parts_requests (ticket_id, technician_id, request_date, " +
                         "priority, status, notes) VALUES (?, ?, NOW(), ?, 'pending', ?)";
            stmt1 = conn.prepareStatement(sql1, Statement.RETURN_GENERATED_KEYS);
            stmt1.setInt(1, request.getTicketId());
            stmt1.setInt(2, request.getTechnicianId());
            stmt1.setString(3, request.getPriority());
            stmt1.setString(4, request.getNotes());
            stmt1.executeUpdate();
            
            // Get generated request_id
            ResultSet keys = stmt1.getGeneratedKeys();
            if (!keys.next()) {
                conn.rollback();
                return false;
            }
            int requestId = keys.getInt(1);
            
            // 2. Insert parts_request_items
            String sql2 = "INSERT INTO parts_request_items (request_id, inventory_item_id, " +
                         "quantity_requested, notes) VALUES (?, ?, ?, ?)";
            stmt2 = conn.prepareStatement(sql2);
            
            for (PartsRequestItem item : items) {
                stmt2.setInt(1, requestId);
                stmt2.setInt(2, item.getInventoryItemId());
                stmt2.setInt(3, item.getQuantityRequested());
                stmt2.setString(4, item.getNotes());
                stmt2.addBatch();
            }
            stmt2.executeBatch();
            
            conn.commit();
            request.setRequestId(requestId);
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
            
            while (rs.next()) {
                PartsRequest pr = mapResultSet(rs);
                list.add(pr);
            }
        }
        return list;
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
        pr.setTicketId(rs.getInt("ticket_id"));
        pr.setTechnicianId(rs.getInt("technician_id"));
        pr.setRequestDate(rs.getTimestamp("request_date"));
        pr.setPriority(rs.getString("priority"));
        pr.setStatus(PartsRequest.RequestStatus.valueOf(rs.getString("status")));
        pr.setNotes(rs.getString("notes"));
        pr.setProcessedBy(rs.getInt("processed_by"));
        pr.setProcessedDate(rs.getTimestamp("processed_date"));
        pr.setProcessingNotes(rs.getString("processing_notes"));
        
        // Additional fields if available
        if (hasColumn(rs, "technician_name")) {
            pr.setTechnicianName(rs.getString("technician_name"));
        }
        if (hasColumn(rs, "ticket_number")) {
            pr.setTicketCode(rs.getString("ticket_number"));
        }
        
        return pr;
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
