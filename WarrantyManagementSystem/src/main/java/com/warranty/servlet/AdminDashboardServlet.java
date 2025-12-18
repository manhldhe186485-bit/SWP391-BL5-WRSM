package com.warranty.servlet;

import com.warranty.dao.CustomerDAO;
import com.warranty.dao.ProductSerialDAO;
import com.warranty.dao.UserDAO;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import com.warranty.util.DatabaseUtil;

/**
 * Servlet for Admin Dashboard
 */
@WebServlet("/admin/dashboard")
public class AdminDashboardServlet extends HttpServlet {

    private CustomerDAO customerDAO = new CustomerDAO();
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check if user is logged in and has ADMIN role
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !role.equals("ADMIN")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // Get statistics
        int totalCustomers = getTotalCustomers();
        int totalProductsSold = getTotalProductsSold();
        int totalWarrantyTickets = getTotalWarrantyTickets();
        int totalEmployees = getTotalEmployees();
        
        request.setAttribute("totalCustomers", totalCustomers);
        request.setAttribute("totalProductsSold", totalProductsSold);
        request.setAttribute("totalWarrantyTickets", totalWarrantyTickets);
        request.setAttribute("totalEmployees", totalEmployees);

        // Forward to dashboard page
        request.getRequestDispatcher("/views/admin/dashboard.jsp").forward(request, response);
    }
    
    private int getTotalCustomers() {
        try {
            return customerDAO.getAllCustomers().size();
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }
    
    private int getTotalProductsSold() {
        String sql = "SELECT COUNT(*) as total FROM product_serials WHERE customer_id IS NOT NULL";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    private int getTotalWarrantyTickets() {
        String sql = "SELECT COUNT(*) as total FROM repair_tickets";
        try (Connection conn = DatabaseUtil.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getInt("total");
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }
    
    private int getTotalEmployees() {
        try {
            return userDAO.getAllUsers().size();
        } catch (Exception e) {
            e.printStackTrace();
            return 0;
        }
    }
}
