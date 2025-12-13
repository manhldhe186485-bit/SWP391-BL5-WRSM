package com.warranty.servlet;

import com.warranty.dao.CustomerDAO;
import com.warranty.model.Customer;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Servlet for Admin to manage customers
 */
public class CustomerManagementServlet extends HttpServlet {

    private CustomerDAO customerDAO = new CustomerDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !role.equals("ADMIN")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // List all customers
        try {
            List<Customer> customers = customerDAO.getAllCustomers();
            request.setAttribute("customers", customers);
            request.getRequestDispatcher("/views/admin/customer-management.jsp").forward(request, response);
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi khi tải danh sách khách hàng: " + e.getMessage());
            request.getRequestDispatcher("/views/admin/customer-management.jsp").forward(request, response);
        }
    }
}