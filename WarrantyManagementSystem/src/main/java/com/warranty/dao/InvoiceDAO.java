package com.warranty.dao;

import com.warranty.model.Invoice;
import com.warranty.util.DatabaseUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class InvoiceDAO {

    public boolean createInvoice(Invoice invoice) {
        String sql = "INSERT INTO invoices (ticket_id, labor_cost, parts_cost, total_amount, notes, created_by, created_at, status) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setInt(1, invoice.getTicketId());
            stmt.setBigDecimal(2, invoice.getLaborCost());
            stmt.setBigDecimal(3, invoice.getPartsCost());
            stmt.setBigDecimal(4, invoice.getTotalAmount());
            stmt.setString(5, invoice.getNotes());
            stmt.setInt(6, invoice.getCreatedBy());
            stmt.setTimestamp(7, invoice.getCreatedAt());
            stmt.setString(8, invoice.getStatus());
            
            int rowsAffected = stmt.executeUpdate();
            
            if (rowsAffected > 0) {
                ResultSet rs = stmt.getGeneratedKeys();
                if (rs.next()) {
                    invoice.setInvoiceId(rs.getInt(1));
                }
                return true;
            }
            return false;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    public Invoice getInvoiceById(int invoiceId) {
        String sql = "SELECT i.*, wt.ticket_number, u.full_name as creator_name " +
                     "FROM invoices i " +
                     "LEFT JOIN repair_tickets wt ON i.ticket_id = wt.ticket_id " +
                     "LEFT JOIN users u ON i.created_by = u.user_id " +
                     "WHERE i.invoice_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, invoiceId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapRowToInvoice(rs);
            }
            return null;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    public Invoice getInvoiceByTicketId(int ticketId) {
        String sql = "SELECT i.*, wt.ticket_number, u.full_name as creator_name " +
                     "FROM invoices i " +
                     "LEFT JOIN repair_tickets wt ON i.ticket_id = wt.ticket_id " +
                     "LEFT JOIN users u ON i.created_by = u.user_id " +
                     "WHERE i.ticket_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, ticketId);
            ResultSet rs = stmt.executeQuery();
            
            if (rs.next()) {
                return mapRowToInvoice(rs);
            }
            return null;
        } catch (SQLException e) {
            e.printStackTrace();
            return null;
        }
    }

    public List<Invoice> getAllInvoices() {
        List<Invoice> invoices = new ArrayList<>();
        String sql = "SELECT i.*, wt.ticket_number, u.full_name as creator_name " +
                     "FROM invoices i " +
                     "LEFT JOIN repair_tickets wt ON i.ticket_id = wt.ticket_id " +
                     "LEFT JOIN users u ON i.created_by = u.user_id " +
                     "ORDER BY i.created_at DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             Statement stmt = conn.createStatement();
             ResultSet rs = stmt.executeQuery(sql)) {
            
            while (rs.next()) {
                invoices.add(mapRowToInvoice(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return invoices;
    }

    public List<Invoice> getInvoicesByTechnician(int technicianId) {
        List<Invoice> invoices = new ArrayList<>();
        String sql = "SELECT i.*, wt.ticket_number, u.full_name as creator_name " +
                     "FROM invoices i " +
                     "LEFT JOIN repair_tickets wt ON i.ticket_id = wt.ticket_id " +
                     "LEFT JOIN users u ON i.created_by = u.user_id " +
                     "WHERE i.created_by = ? " +
                     "ORDER BY i.created_at DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, technicianId);
            ResultSet rs = stmt.executeQuery();
            
            while (rs.next()) {
                invoices.add(mapRowToInvoice(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return invoices;
    }

    public boolean updateInvoiceStatus(int invoiceId, String status) {
        String sql = "UPDATE invoices SET status = ? WHERE invoice_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status);
            stmt.setInt(2, invoiceId);
            
            return stmt.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        }
    }

    private Invoice mapRowToInvoice(ResultSet rs) throws SQLException {
        Invoice invoice = new Invoice();
        invoice.setInvoiceId(rs.getInt("invoice_id"));
        invoice.setTicketId(rs.getInt("ticket_id"));
        invoice.setTicketNumber(rs.getString("ticket_number"));
        invoice.setLaborCost(rs.getBigDecimal("labor_cost"));
        invoice.setPartsCost(rs.getBigDecimal("parts_cost"));
        invoice.setTotalAmount(rs.getBigDecimal("total_amount"));
        invoice.setNotes(rs.getString("notes"));
        invoice.setCreatedBy(rs.getInt("created_by"));
        invoice.setCreatorName(rs.getString("creator_name"));
        invoice.setCreatedAt(rs.getTimestamp("created_at"));
        invoice.setStatus(rs.getString("status"));
        return invoice;
    }
}
