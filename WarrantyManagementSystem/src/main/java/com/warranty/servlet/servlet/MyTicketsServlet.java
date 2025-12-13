package com.warranty.servlet;

import com.warranty.model.RepairTicket;
import com.warranty.service.RepairTicketService;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Servlet to display technician's tickets
 */
@WebServlet("/technician/my-tickets")
public class MyTicketsServlet extends HttpServlet {

    private RepairTicketService repairTicketService = new RepairTicketService();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !role.equals("TECHNICIAN")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get technician ID
        Integer technicianId = (Integer) request.getSession().getAttribute("userId");
        
        // Get filter parameter (optional)
        String statusFilter = request.getParameter("status");
        
        // ========== GỌI SERVICE ==========
        List<RepairTicket> tickets;
        
        if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("all")) {
            // Filter by status
            try {
                RepairTicket.TicketStatus status = RepairTicket.TicketStatus.valueOf(statusFilter.toUpperCase());
                tickets = repairTicketService.getTicketsByStatus(status);
                // Filter only this technician's tickets
                tickets.removeIf(t -> t.getTechnicianId() != technicianId);
            } catch (IllegalArgumentException e) {
                // Invalid status, get all tickets
                tickets = repairTicketService.getTicketsByTechnician(technicianId);
            }
        } else {
            // Get all tickets for this technician
            tickets = repairTicketService.getTicketsByTechnician(technicianId);
        }
        
        // Count by status for filter badges
        long newCount = tickets.stream()
                .filter(t -> t.getStatus() == RepairTicket.TicketStatus.ASSIGNED)
                .count();
        long inProgressCount = tickets.stream()
                .filter(t -> t.getStatus() == RepairTicket.TicketStatus.IN_PROGRESS)
                .count();
        long waitingCount = tickets.stream()
                .filter(t -> t.getStatus() == RepairTicket.TicketStatus.WAITING_PARTS)
                .count();
        long completedCount = tickets.stream()
                .filter(t -> t.getStatus() == RepairTicket.TicketStatus.COMPLETED)
                .count();
        
        // Set attributes
        request.setAttribute("tickets", tickets);
        request.setAttribute("totalCount", tickets.size());
        request.setAttribute("newCount", newCount);
        request.setAttribute("inProgressCount", inProgressCount);
        request.setAttribute("waitingCount", waitingCount);
        request.setAttribute("completedCount", completedCount);
        request.setAttribute("currentFilter", statusFilter != null ? statusFilter : "all");
        
        // Forward to JSP
        request.getRequestDispatcher("/views/technician/my-tickets.jsp").forward(request, response);
    }
}
