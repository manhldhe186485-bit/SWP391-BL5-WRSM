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
 * Servlet for Technician Dashboard
 */
@WebServlet("/technician/dashboard")
public class TechnicianDashboardServlet extends HttpServlet {

    private RepairTicketService repairTicketService = new RepairTicketService(); // ← GỌI SERVICE Ở ĐÂY

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if user is logged in and has TECHNICIAN role
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !role.equals("TECHNICIAN")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get technician ID from session
        Integer technicianId = (Integer) request.getSession().getAttribute("userId");
        
        // DEBUG: Print to console
        System.out.println("=== TECHNICIAN DASHBOARD DEBUG ===");
        System.out.println("Technician ID from session: " + technicianId);
        System.out.println("Username from session: " + request.getSession().getAttribute("username"));
        
        // ========== GỌI SERVICE ĐỂ LẤY DỮ LIỆU ==========
        
        // Get tickets assigned to this technician (includes related objects)
        List<RepairTicket> myTickets = repairTicketService.getTicketsByTechnician(technicianId);
        
        // DEBUG: Print tickets
        System.out.println("Total tickets found: " + myTickets.size());
        for (RepairTicket t : myTickets) {
            System.out.println("  - Ticket: " + t.getTicketNumber() + " | Status: " + t.getStatus() + " | Assigned to: " + t.getAssignedTechnicianId());
        }
        System.out.println("=================================");
        
        // Count tickets by status (bao gồm cả ASSIGNED - mới được giao)
        long totalTickets = myTickets.size();
        long newAssignedCount = myTickets.stream()
                .filter(t -> t.getStatus() == RepairTicket.TicketStatus.ASSIGNED)
                .count();
        long inProgressCount = myTickets.stream()
                .filter(t -> t.getStatus() == RepairTicket.TicketStatus.IN_PROGRESS)
                .count();
        long waitingPartsCount = myTickets.stream()
                .filter(t -> t.getStatus() == RepairTicket.TicketStatus.WAITING_PARTS)
                .count();
        long completedCount = myTickets.stream()
                .filter(t -> t.getStatus() == RepairTicket.TicketStatus.COMPLETED)
                .count();
        
        // Set attributes for JSP
        request.setAttribute("myTickets", myTickets);
        request.setAttribute("totalTickets", totalTickets);
        request.setAttribute("newAssignedCount", newAssignedCount);
        request.setAttribute("inProgressCount", inProgressCount);
        request.setAttribute("waitingPartsCount", waitingPartsCount);
        request.setAttribute("completedCount", completedCount);

        // Forward to dashboard page
        request.getRequestDispatcher("/views/technician/dashboard.jsp").forward(request, response);
    }
}
