package com.warranty.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet for Admin Dashboard
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if user is logged in and has ADMIN role
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !role.equals("ADMIN")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get statistics (placeholder for now)
        // TODO: Get real data from DAO
        request.setAttribute("totalCustomers", 0);
        request.setAttribute("totalProducts", 0);
        request.setAttribute("totalTickets", 0);
        request.setAttribute("totalUsers", 0);

        // Forward to dashboard page
        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
    }
}
