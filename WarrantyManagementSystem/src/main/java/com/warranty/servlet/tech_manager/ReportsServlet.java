package com.warranty.servlet.tech_manager;

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
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Servlet for Tech Manager to view statistics and reports
 */
@WebServlet("/tech-manager/reports")
public class ReportsServlet extends HttpServlet {

    private RepairTicketDAO repairTicketDAO = new RepairTicketDAO();
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || (!role.equals("TECH_MANAGER") && !role.equals("ADMIN"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get all tickets for statistics
        List<RepairTicket> allTickets = repairTicketDAO.getAllTickets();

        // Calculate statistics by status
        Map<String, Integer> statusStats = new HashMap<>();
        statusStats.put("PENDING_ASSIGNMENT", 0);
        statusStats.put("ASSIGNED", 0);
        statusStats.put("IN_DIAGNOSIS", 0);
        statusStats.put("AWAITING_PARTS", 0);
        statusStats.put("IN_REPAIR", 0);
        statusStats.put("QUALITY_CHECK", 0);
        statusStats.put("COMPLETED", 0);
        statusStats.put("DELIVERED", 0);
        statusStats.put("CANCELLED", 0);

        for (RepairTicket ticket : allTickets) {
            String status = ticket.getStatus().name();
            statusStats.put(status, statusStats.getOrDefault(status, 0) + 1);
        }

        // Calculate statistics by priority
        Map<String, Integer> priorityStats = new HashMap<>();
        priorityStats.put("LOW", 0);
        priorityStats.put("MEDIUM", 0);
        priorityStats.put("HIGH", 0);
        priorityStats.put("CRITICAL", 0);

        for (RepairTicket ticket : allTickets) {
            String priority = ticket.getPriority().name();
            priorityStats.put(priority, priorityStats.getOrDefault(priority, 0) + 1);
        }

        // Calculate statistics by ticket type
        Map<String, Integer> typeStats = new HashMap<>();
        typeStats.put("WARRANTY", 0);
        typeStats.put("PAID_REPAIR", 0);

        for (RepairTicket ticket : allTickets) {
            String type = ticket.getTicketType().name();
            typeStats.put(type, typeStats.getOrDefault(type, 0) + 1);
        }

        // Get technician workload
        List<User> technicians = userDAO.getUsersByRole(User.UserRole.TECHNICIAN);
        Map<String, Integer> technicianWorkload = new HashMap<>();

        for (User technician : technicians) {
            int activeTickets = repairTicketDAO.countActiveTicketsByTechnician(technician.getUserId());
            technicianWorkload.put(technician.getFullName(), activeTickets);
        }

        // Set attributes
        request.setAttribute("statusStats", statusStats);
        request.setAttribute("priorityStats", priorityStats);
        request.setAttribute("typeStats", typeStats);
        request.setAttribute("technicianWorkload", technicianWorkload);
        request.setAttribute("totalTickets", allTickets.size());

        // Forward to reports page
        request.getRequestDispatcher("/views/tech-manager/reports.jsp").forward(request, response);
    }
}
