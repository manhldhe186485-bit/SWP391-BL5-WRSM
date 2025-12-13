package com.warranty.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet for Warehouse Dashboard
 */
@WebServlet("/warehouse/dashboard")
public class WarehouseDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if user is logged in and has WAREHOUSE role
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !role.equals("WAREHOUSE")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get statistics (placeholder for now)
        // TODO: Get real data from DAO
        request.setAttribute("pendingRequests", 0);
        request.setAttribute("totalItems", 0);
        request.setAttribute("lowStockItems", 0);

        // Forward to dashboard page
        request.getRequestDispatcher("/views/warehouse/dashboard.jsp").forward(request, response);
    }
}
