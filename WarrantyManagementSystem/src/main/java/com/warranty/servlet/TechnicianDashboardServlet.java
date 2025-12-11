package com.warranty.servlet;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Servlet for Technician Dashboard
 */
@WebServlet("/technician/dashboard")
public class TechnicianDashboardServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if user is logged in and has TECHNICIAN role
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !role.equals("TECHNICIAN")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Forward to dashboard page
        request.getRequestDispatcher("/views/technician/dashboard.jsp").forward(request, response);
    }
}
