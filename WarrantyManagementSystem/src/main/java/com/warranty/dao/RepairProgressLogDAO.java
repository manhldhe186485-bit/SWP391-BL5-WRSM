package com.warranty.dao;

import com.warranty.model.RepairProgressLog;
import com.warranty.util.DatabaseUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RepairProgressLogDAO {

    /**
     * Tạo log tiến độ mới
     */
    public boolean createProgressLog(RepairProgressLog log) {
        String sql = "INSERT INTO repair_progress_logs (ticket_id, technician_id, status, progress_description, completion_percentage, created_at) " +
                     "VALUES (?, ?, ?, ?, ?, ?)";
        
        System.out.println("========== RepairProgressLogDAO.createProgressLog() ==========");
        System.out.println("SQL: " + sql);
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            System.out.println("DEBUG - Database connection: " + (conn != null ? "OK" : "NULL"));
            
            stmt.setInt(1, log.getTicketId());
            stmt.setInt(2, log.getTechnicianId());
            stmt.setString(3, log.getStatus());
            stmt.setString(4, log.getProgressDescription());
            stmt.setInt(5, log.getCompletionPercentage());
            stmt.setTimestamp(6, log.getCreatedAt());
            
            System.out.println("DEBUG - Parameters set:");
            System.out.println("  1. ticket_id = " + log.getTicketId());
            System.out.println("  2. technician_id = " + log.getTechnicianId());
            System.out.println("  3. status = " + log.getStatus());
            System.out.println("  4. progress_description = " + log.getProgressDescription());
            System.out.println("  5. completion_percentage = " + log.getCompletionPercentage());
            System.out.println("  6. created_at = " + log.getCreatedAt());
            
            int rowsAffected = stmt.executeUpdate();
            System.out.println("DEBUG - Rows affected: " + rowsAffected);
            
            if (rowsAffected > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    int generatedId = rs.getInt(1);
                    log.setLogId(generatedId);
                    System.out.println("DEBUG - Generated log_id: " + generatedId);
                }
                System.out.println("========== INSERT SUCCESS ==========");
                return true;
            }
            System.out.println("========== INSERT FAILED - No rows affected ==========");
            return false;
        } catch (SQLException e) {
            System.err.println("========== SQL EXCEPTION ==========");
            System.err.println("Error Message: " + e.getMessage());
            System.err.println("SQL State: " + e.getSQLState());
            System.err.println("Error Code: " + e.getErrorCode());
            e.printStackTrace();
            return false;
        }
    }

    /**
     * Lấy danh sách progress logs của một ticket
     */
    public List<RepairProgressLog> getLogsByTicketId(int ticketId) {
        List<RepairProgressLog> logs = new ArrayList<>();
        String sql = "SELECT pl.*, u.full_name as technician_name " +
                     "FROM repair_progress_logs pl " +
                     "LEFT JOIN users u ON pl.technician_id = u.user_id " +
                     "WHERE pl.ticket_id = ? " +
                     "ORDER BY pl.created_at DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, ticketId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                RepairProgressLog log = new RepairProgressLog();
                log.setLogId(rs.getInt("log_id"));
                log.setTicketId(rs.getInt("ticket_id"));
                log.setTechnicianId(rs.getInt("technician_id"));
                log.setTechnicianName(rs.getString("technician_name"));
                log.setStatus(rs.getString("status"));
                log.setProgressDescription(rs.getString("progress_description"));
                log.setCompletionPercentage(rs.getInt("completion_percentage"));
                log.setCreatedAt(rs.getTimestamp("created_at"));
                logs.add(log);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return logs;
    }

    /**
     * Lấy log gần nhất của ticket
     */
    public RepairProgressLog getLatestLogByTicketId(int ticketId) {
        String sql = "SELECT pl.*, u.full_name as technician_name " +
                     "FROM repair_progress_logs pl " +
                     "LEFT JOIN users u ON pl.technician_id = u.user_id " +
                     "WHERE pl.ticket_id = ? " +
                     "ORDER BY pl.created_at DESC LIMIT 1";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, ticketId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                RepairProgressLog log = new RepairProgressLog();
                log.setLogId(rs.getInt("log_id"));
                log.setTicketId(rs.getInt("ticket_id"));
                log.setTechnicianId(rs.getInt("technician_id"));
                log.setTechnicianName(rs.getString("technician_name"));
                log.setStatus(rs.getString("status"));
                log.setProgressDescription(rs.getString("progress_description"));
                log.setCompletionPercentage(rs.getInt("completion_percentage"));
                log.setCreatedAt(rs.getTimestamp("created_at"));
                return log;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return null;
    }

    /**
     * Đếm số lượng logs của ticket
     */
    public int countLogsByTicketId(int ticketId) {
        String sql = "SELECT COUNT(*) FROM repair_progress_logs WHERE ticket_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, ticketId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        
        return 0;
    }

    /**
     * Lấy danh sách logs có status = 'COMPLETED' của một technician
     * Dùng để hiển thị đơn đã hoàn thành cho việc tạo phiếu thanh toán
     */
    public List<RepairProgressLog> getCompletedLogsByTechnician(int technicianId) {
        List<RepairProgressLog> logs = new ArrayList<>();
        String sql = "SELECT pl.*, u.full_name as technician_name " +
                     "FROM repair_progress_logs pl " +
                     "LEFT JOIN users u ON pl.technician_id = u.user_id " +
                     "WHERE pl.technician_id = ? AND pl.status = 'COMPLETED' " +
                     "ORDER BY pl.created_at DESC";
        
        System.out.println("========== RepairProgressLogDAO.getCompletedLogsByTechnician() ==========");
        System.out.println("SQL: " + sql);
        System.out.println("Technician ID: " + technicianId);
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, technicianId);
            ResultSet rs = stmt.executeQuery();
            
            int count = 0;
            while (rs.next()) {
                RepairProgressLog log = new RepairProgressLog();
                log.setLogId(rs.getInt("log_id"));
                log.setTicketId(rs.getInt("ticket_id"));
                log.setTechnicianId(rs.getInt("technician_id"));
                log.setTechnicianName(rs.getString("technician_name"));
                log.setStatus(rs.getString("status"));
                log.setProgressDescription(rs.getString("progress_description"));
                log.setCompletionPercentage(rs.getInt("completion_percentage"));
                log.setCreatedAt(rs.getTimestamp("created_at"));
                logs.add(log);
                count++;
                System.out.println("  - Log #" + count + ": ticket_id=" + log.getTicketId() + ", created_at=" + log.getCreatedAt());
            }
            
            System.out.println("DEBUG - Total COMPLETED logs found: " + count);
            
        } catch (SQLException e) {
            System.err.println("ERROR - SQL Exception:");
            e.printStackTrace();
        }
        
        System.out.println("=======================================================================");
        return logs;
    }
}
