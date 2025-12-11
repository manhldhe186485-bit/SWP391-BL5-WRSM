package com.warranty.dao;

import com.warranty.model.RepairTicket;
import com.warranty.model.RepairTicket.*;
import com.warranty.util.DatabaseUtil;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

/**
 * Data Access Object for RepairTicket entity
 */
public class RepairTicketDAO {

    /**
     * Create a new repair ticket
     */
    public boolean createTicket(RepairTicket ticket) {
        String sql = "INSERT INTO repair_tickets (ticket_number, serial_id, customer_id, intake_technician_id, " +
                    "issue_description, initial_diagnosis, priority, ticket_type, status) " +
                    "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, ticket.getTicketNumber());
            stmt.setInt(2, ticket.getSerialId());
            stmt.setInt(3, ticket.getCustomerId());
            stmt.setInt(4, ticket.getIntakeTechnicianId());
            stmt.setString(5, ticket.getIssueDescription());
            stmt.setString(6, ticket.getInitialDiagnosis());
            stmt.setString(7, ticket.getPriority().name());
            stmt.setString(8, ticket.getTicketType().name());
            stmt.setString(9, ticket.getStatus().name());
            
            int affectedRows = stmt.executeUpdate();
            
            if (affectedRows > 0) {
                try (ResultSet rs = stmt.getGeneratedKeys()) {
                    if (rs.next()) {
                        ticket.setTicketId(rs.getInt(1));
                    }
                }
                return true;
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Get ticket by ID
     */
    public RepairTicket getTicketById(int ticketId) {
        String sql = "SELECT * FROM repair_tickets WHERE ticket_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, ticketId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractTicketFromResultSet(rs);
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get ticket by ticket number
     */
    public RepairTicket getTicketByNumber(String ticketNumber) {
        String sql = "SELECT * FROM repair_tickets WHERE ticket_number = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, ticketNumber);
            
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return extractTicketFromResultSet(rs);
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return null;
    }

    /**
     * Get tickets by status
     */
    public List<RepairTicket> getTicketsByStatus(TicketStatus status) {
        List<RepairTicket> tickets = new ArrayList<>();
        String sql = "SELECT * FROM repair_tickets WHERE status = ? ORDER BY received_date DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, status.name());
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    tickets.add(extractTicketFromResultSet(rs));
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }

    /**
     * Get tickets assigned to a technician
     */
    public List<RepairTicket> getTicketsByTechnician(int technicianId) {
        List<RepairTicket> tickets = new ArrayList<>();
        String sql = "SELECT * FROM repair_tickets WHERE assigned_technician_id = ? " +
                    "ORDER BY received_date DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, technicianId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    tickets.add(extractTicketFromResultSet(rs));
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }

    /**
     * Get tickets by customer
     */
    public List<RepairTicket> getTicketsByCustomer(int customerId) {
        List<RepairTicket> tickets = new ArrayList<>();
        String sql = "SELECT * FROM repair_tickets WHERE customer_id = ? ORDER BY received_date DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, customerId);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    tickets.add(extractTicketFromResultSet(rs));
                }
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }

    /**
     * Update ticket status
     */
    public boolean updateTicketStatus(int ticketId, TicketStatus newStatus) {
        String sql = "UPDATE repair_tickets SET status = ? WHERE ticket_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, newStatus.name());
            stmt.setInt(2, ticketId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Assign ticket to technician
     */
    public boolean assignTicket(int ticketId, int technicianId, int managerId) {
        String sql = "UPDATE repair_tickets SET assigned_technician_id = ?, tech_manager_id = ?, " +
                    "status = ? WHERE ticket_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, technicianId);
            stmt.setInt(2, managerId);
            stmt.setString(3, TicketStatus.ASSIGNED.name());
            stmt.setInt(4, ticketId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Update ticket
     */
    public boolean updateTicket(RepairTicket ticket) {
        String sql = "UPDATE repair_tickets SET status = ?, priority = ?, estimated_completion_date = ?, " +
                    "total_cost = ?, labor_cost = ?, parts_cost = ?, notes = ? WHERE ticket_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, ticket.getStatus().name());
            stmt.setString(2, ticket.getPriority().name());
            stmt.setDate(3, ticket.getEstimatedCompletionDate());
            stmt.setBigDecimal(4, ticket.getTotalCost());
            stmt.setBigDecimal(5, ticket.getLaborCost());
            stmt.setBigDecimal(6, ticket.getPartsCost());
            stmt.setString(7, ticket.getNotes());
            stmt.setInt(8, ticket.getTicketId());
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Mark ticket as paid
     */
    public boolean markAsPaid(int ticketId) {
        String sql = "UPDATE repair_tickets SET is_paid = TRUE, payment_date = CURRENT_TIMESTAMP, " +
                    "status = ? WHERE ticket_id = ?";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, TicketStatus.PAID.name());
            stmt.setInt(2, ticketId);
            
            return stmt.executeUpdate() > 0;
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return false;
    }

    /**
     * Get all tickets
     */
    public List<RepairTicket> getAllTickets() {
        List<RepairTicket> tickets = new ArrayList<>();
        String sql = "SELECT * FROM repair_tickets ORDER BY received_date DESC";
        
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            
            while (rs.next()) {
                tickets.add(extractTicketFromResultSet(rs));
            }
            
        } catch (SQLException e) {
            e.printStackTrace();
        }
        return tickets;
    }

    /**
     * Extract RepairTicket from ResultSet
     */
    private RepairTicket extractTicketFromResultSet(ResultSet rs) throws SQLException {
        RepairTicket ticket = new RepairTicket();
        ticket.setTicketId(rs.getInt("ticket_id"));
        ticket.setTicketNumber(rs.getString("ticket_number"));
        ticket.setSerialId(rs.getInt("serial_id"));
        ticket.setCustomerId(rs.getInt("customer_id"));
        ticket.setIntakeTechnicianId(rs.getInt("intake_technician_id"));
        
        int assignedTechId = rs.getInt("assigned_technician_id");
        if (!rs.wasNull()) {
            ticket.setAssignedTechnicianId(assignedTechId);
        }
        
        int techManagerId = rs.getInt("tech_manager_id");
        if (!rs.wasNull()) {
            ticket.setTechManagerId(techManagerId);
        }
        
        ticket.setIssueDescription(rs.getString("issue_description"));
        ticket.setInitialDiagnosis(rs.getString("initial_diagnosis"));
        ticket.setPriority(Priority.valueOf(rs.getString("priority")));
        ticket.setTicketType(TicketType.valueOf(rs.getString("ticket_type")));
        ticket.setStatus(TicketStatus.valueOf(rs.getString("status")));
        ticket.setReceivedDate(rs.getTimestamp("received_date"));
        ticket.setEstimatedCompletionDate(rs.getDate("estimated_completion_date"));
        ticket.setActualCompletionDate(rs.getTimestamp("actual_completion_date"));
        ticket.setDeliveryDate(rs.getTimestamp("delivery_date"));
        ticket.setTotalCost(rs.getBigDecimal("total_cost"));
        ticket.setLaborCost(rs.getBigDecimal("labor_cost"));
        ticket.setPartsCost(rs.getBigDecimal("parts_cost"));
        ticket.setPaid(rs.getBoolean("is_paid"));
        ticket.setPaymentDate(rs.getTimestamp("payment_date"));
        ticket.setNotes(rs.getString("notes"));
        ticket.setCreatedAt(rs.getTimestamp("created_at"));
        ticket.setUpdatedAt(rs.getTimestamp("updated_at"));
        
        return ticket;
    }
}
