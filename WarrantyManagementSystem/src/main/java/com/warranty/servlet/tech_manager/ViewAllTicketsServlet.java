package com.warranty.servlet.tech_manager;

import com.warranty.dao.RepairTicketDAO;
import com.warranty.model.RepairTicket;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Servlet for Tech Manager to view all repair tickets
 */
@WebServlet("/tech-manager/tickets")
public class ViewAllTicketsServlet extends HttpServlet {

    private RepairTicketDAO repairTicketDAO = new RepairTicketDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || (!role.equals("TECH_MANAGER") && !role.equals("ADMIN"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get filter parameters
        String statusFilter = request.getParameter("status");

        // Get all tickets or filtered by status
        List<RepairTicket> tickets;
        if (statusFilter != null && !statusFilter.isEmpty() && !statusFilter.equals("ALL")) {
            try {
                RepairTicket.TicketStatus status = RepairTicket.TicketStatus.valueOf(statusFilter);
                tickets = repairTicketDAO.getTicketsByStatus(status);
            } catch (IllegalArgumentException e) {
                // Invalid status, get all tickets
                tickets = repairTicketDAO.getAllTickets();
            }
        } else {
            tickets = repairTicketDAO.getAllTickets();
        }

        // Set attributes
        request.setAttribute("tickets", tickets);
        request.setAttribute("selectedStatus", statusFilter);

        // Forward to view page
        request.getRequestDispatcher("/views/tech-manager/view-tickets.jsp").forward(request, response);
    }
}
