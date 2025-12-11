package com.warranty.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet for Tech Manager Dashboard
 */
@WebServlet("/tech-manager/dashboard")
public class TechManagerDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if user is logged in and has TECH_MANAGER role
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !role.equals("TECH_MANAGER")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get statistics (placeholder for now)
        // TODO: Get real data from DAO
        request.setAttribute("pendingTickets", 0);
        request.setAttribute("assignedTickets", 0);
        request.setAttribute("completedTickets", 0);
        request.setAttribute("totalTechnicians", 0);

        // Forward to dashboard page
        request.getRequestDispatcher("/views/tech-manager/dashboard.jsp").forward(request, response);
    }
}
