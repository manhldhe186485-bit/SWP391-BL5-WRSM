package com.warranty.service;

import com.warranty.dao.RepairTicketDAO;
import com.warranty.model.RepairTicket;

import java.math.BigDecimal;
import java.util.List;

/**
 * Service layer for Repair Ticket business logic
 */
public class RepairTicketService {
    
    private RepairTicketDAO repairTicketDAO;

    public RepairTicketService() {
        this.repairTicketDAO = new RepairTicketDAO();
    }

    /**
     * Create new repair ticket
     * @param ticket Repair ticket object
     * @return true if created successfully
     */
    public boolean createRepairTicket(RepairTicket ticket) {
        // Validate input
        if (ticket == null) {
            return false;
        }

        // Business rules validation
        if (ticket.getSerialId() <= 0) {
            throw new IllegalArgumentException("Serial ID is required");
        }

        // Check if product is still under warranty
        // TODO: Add warranty validation logic

        // Set initial status
        if (ticket.getStatus() == null) {
            ticket.setStatus(RepairTicket.TicketStatus.PENDING);
        }

        // Generate ticket code
        if (ticket.getTicketCode() == null || ticket.getTicketCode().isEmpty()) {
            ticket.setTicketCode(generateTicketCode());
        }

        // Create ticket in database
        return repairTicketDAO.createTicket(ticket);
    }

    /**
     * Assign ticket to technician
     * @param ticketId Ticket ID
     * @param technicianId Technician user ID
     * @return true if assigned successfully
     */
    public boolean assignTicket(int ticketId, int technicianId) {
        RepairTicket ticket = repairTicketDAO.getTicketById(ticketId);
        
        if (ticket == null) {
            return false;
        }

        // Check if ticket is in assignable status
        if (ticket.getStatus() != RepairTicket.TicketStatus.PENDING_ASSIGNMENT) {
            throw new IllegalStateException("Ticket is not in PENDING_ASSIGNMENT status");
        }

        // Assign ticket
        ticket.setTechnicianId(technicianId);
        ticket.setStatus(RepairTicket.TicketStatus.ASSIGNED);

        return repairTicketDAO.updateTicket(ticket);
    }

    /**
     * Update ticket status
     * @param ticketId Ticket ID
     * @param newStatus New status
     * @param notes Update notes
     * @return true if updated successfully
     */
    public boolean updateTicketStatus(int ticketId, RepairTicket.TicketStatus newStatus, String notes) {
        RepairTicket ticket = repairTicketDAO.getTicketById(ticketId);
        
        if (ticket == null) {
            return false;
        }

        // Validate status transition
        if (!isValidStatusTransition(ticket.getStatus(), newStatus)) {
            throw new IllegalStateException("Invalid status transition from " + 
                                          ticket.getStatus() + " to " + newStatus);
        }

        // Update status
        ticket.setStatus(newStatus);

        // TODO: Create progress log entry with notes

        return repairTicketDAO.updateTicket(ticket);
    }

    /**
     * Get tickets assigned to technician
     * @param technicianId Technician user ID
     * @return List of tickets
     */
    public List<RepairTicket> getTicketsByTechnician(int technicianId) {
        List<RepairTicket> tickets = repairTicketDAO.getTicketsByTechnician(technicianId);
        repairTicketDAO.loadRelatedObjects(tickets); // Load ProductSerial & Customer
        return tickets;
    }

    /**
     * Get tickets by status
     * @param status Ticket status
     * @return List of tickets
     */
    public List<RepairTicket> getTicketsByStatus(RepairTicket.TicketStatus status) {
        List<RepairTicket> tickets = repairTicketDAO.getTicketsByStatus(status);
        repairTicketDAO.loadRelatedObjects(tickets); // Load ProductSerial & Customer
        return tickets;
    }

    /**
     * Get ticket by ID
     */
    public RepairTicket getTicketById(int ticketId) {
        RepairTicket ticket = repairTicketDAO.getTicketById(ticketId);
        if (ticket != null) {
            repairTicketDAO.loadRelatedObjects(ticket); // Load related objects
        }
        return ticket;
    }

    /**
     * Get ticket by code
     */
    public RepairTicket getTicketByCode(String ticketCode) {
        return repairTicketDAO.getTicketByCode(ticketCode);
    }

    /**
     * Complete ticket (mark as ready for customer pickup)
     * @param ticketId Ticket ID
     * @return true if completed successfully
     */
    public boolean completeTicket(int ticketId) {
        RepairTicket ticket = repairTicketDAO.getTicketById(ticketId);
        
        if (ticket == null) {
            return false;
        }

        // Check if all parts are available
        // TODO: Check parts availability

        // Update status
        ticket.setStatus(RepairTicket.TicketStatus.COMPLETED);

        return repairTicketDAO.updateTicket(ticket);
    }

    /**
     * Mark ticket as delivered to customer
     * @param ticketId Ticket ID
     * @return true if marked successfully
     */
    public boolean deliverTicket(int ticketId) {
        RepairTicket ticket = repairTicketDAO.getTicketById(ticketId);
        
        if (ticket == null) {
            return false;
        }

        // Check if ticket is completed and paid
        if (ticket.getStatus() != RepairTicket.TicketStatus.COMPLETED) {
            throw new IllegalStateException("Ticket must be completed before delivery");
        }

        // Check payment
        if (ticket.getTotalCost().compareTo(BigDecimal.ZERO) > 0 && !ticket.isPaid()) {
            throw new IllegalStateException("Ticket must be paid before delivery");
        }

        // Update status
        ticket.setStatus(RepairTicket.TicketStatus.DELIVERED);

        return repairTicketDAO.updateTicket(ticket);
    }

    /**
     * Generate unique ticket code
     * Format: WR-YYYY-NNNN (e.g., WR-2025-0001)
     */
    private String generateTicketCode() {
        int year = java.time.Year.now().getValue();
        int count = repairTicketDAO.countTicketsByYear(year);
        return String.format("WR-%d-%04d", year, count + 1);
    }

    /**
     * Validate status transition
     */
    private boolean isValidStatusTransition(RepairTicket.TicketStatus from, 
                                           RepairTicket.TicketStatus to) {
        // Define valid transitions
        switch (from) {
            case PENDING:
                return to == RepairTicket.TicketStatus.ASSIGNED || 
                       to == RepairTicket.TicketStatus.CANCELLED;
            
            case ASSIGNED:
                return to == RepairTicket.TicketStatus.IN_PROGRESS || 
                       to == RepairTicket.TicketStatus.CANCELLED;
            
            case IN_PROGRESS:
                return to == RepairTicket.TicketStatus.WAITING_PARTS || 
                       to == RepairTicket.TicketStatus.WAITING_APPROVAL ||
                       to == RepairTicket.TicketStatus.COMPLETED;
            
            case WAITING_PARTS:
                return to == RepairTicket.TicketStatus.IN_PROGRESS;
            
            case WAITING_APPROVAL:
                return to == RepairTicket.TicketStatus.IN_PROGRESS ||
                       to == RepairTicket.TicketStatus.CANCELLED;
            
            case COMPLETED:
                return to == RepairTicket.TicketStatus.DELIVERED;
            
            case DELIVERED:
                return false; // Final state
            
            case CANCELLED:
                return false; // Final state
            
            default:
                return false;
        }
    }
}
