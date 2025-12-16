package com.warranty.servlet;

import com.warranty.dao.RepairTicketDAO;
import com.warranty.dao.UserDAO;
import com.warranty.model.RepairTicket;
import com.warranty.model.User;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Servlet for Tech Manager Dashboard
 */
@WebServlet("/tech-manager/dashboard")
public class TechManagerDashboardServlet extends HttpServlet {

    private RepairTicketDAO repairTicketDAO = new RepairTicketDAO();
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if user is logged in and has TECH_MANAGER role
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !role.equals("TECH_MANAGER")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get statistics from database
        List<RepairTicket> pendingTickets = repairTicketDAO.getTicketsByStatus(
            RepairTicket.TicketStatus.PENDING_ASSIGNMENT
        );
        
        List<RepairTicket> assignedTickets = repairTicketDAO.getTicketsByStatus(
            RepairTicket.TicketStatus.ASSIGNED
        );
        
        List<RepairTicket> inProgressTickets = repairTicketDAO.getTicketsByStatus(
            RepairTicket.TicketStatus.IN_REPAIR
        );
        
        List<RepairTicket> completedTickets = repairTicketDAO.getTicketsByStatus(
            RepairTicket.TicketStatus.COMPLETED
        );
        
        List<User> technicians = userDAO.getUsersByRole(User.UserRole.TECHNICIAN);

        // Set statistics
        request.setAttribute("pendingCount", pendingTickets.size());
        request.setAttribute("waitingAssignCount", assignedTickets.size());
        request.setAttribute("inProgressCount", inProgressTickets.size());
        request.setAttribute("completedCount", completedTickets.size());
        request.setAttribute("totalTechnicians", technicians.size());

        // Forward to dashboard page
        request.getRequestDispatcher("/views/tech-manager/dashboard.jsp").forward(request, response);
    }
}
