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
 * Servlet for Admin to manage customers (CRUD operations)
 */
@WebServlet("/admin/customers")
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

        String action = request.getParameter("action");
        
        if ("list".equals(action) || action == null) {
            // ========== LIST ALL CUSTOMERS ==========
            try {
                List<Customer> customers = customerDAO.getAllCustomers();
                request.setAttribute("customers", customers);
                request.getRequestDispatcher("/views/admin/customer-management.jsp").forward(request, response);
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error", "Lỗi khi tải danh sách khách hàng: " + e.getMessage());
                request.getRequestDispatcher("/views/admin/customer-management.jsp").forward(request, response);
            }
            
        } else if ("edit".equals(action)) {
            // ========== EDIT CUSTOMER FORM ==========
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/customers");
                return;
            }
            int customerId = Integer.parseInt(idParam);
            Customer customer = customerDAO.getCustomerById(customerId);
            
            if (customer != null) {
                request.setAttribute("customer", customer);
                request.setAttribute("editMode", true);
            }
            
            List<Customer> customers = customerDAO.getAllCustomers();
            request.setAttribute("customers", customers);
            request.getRequestDispatcher("/views/admin/customer-management.jsp").forward(request, response);
            
        } else if ("delete".equals(action)) {
            // ========== DELETE CUSTOMER ==========
            String idParam = request.getParameter("id");
            if (idParam == null || idParam.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/admin/customers");
                return;
            }
            int customerId = Integer.parseInt(idParam);
            boolean success = customerDAO.deleteCustomer(customerId);
            
            if (success) {
                request.getSession().setAttribute("message", "Xóa khách hàng thành công!");
            } else {
                request.getSession().setAttribute("error", "Không thể xóa khách hàng!");
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/customers?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || !role.equals("ADMIN")) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        
        if ("create".equals(action)) {
            // ========== CREATE NEW CUSTOMER ==========
            Customer customer = new Customer();
            customer.setFullName(request.getParameter("fullName"));
            customer.setEmail(request.getParameter("email"));
            customer.setPhone(request.getParameter("phone"));
            customer.setAddress(request.getParameter("address"));
            
            boolean success = customerDAO.createCustomer(customer);
            
            if (success) {
                request.getSession().setAttribute("message", "Tạo khách hàng mới thành công!");
            } else {
                request.getSession().setAttribute("error", "Không thể tạo khách hàng!");
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/customers?action=list");
            
        } else if ("update".equals(action)) {
            // ========== UPDATE CUSTOMER ==========
            int customerId = Integer.parseInt(request.getParameter("customerId"));
            Customer customer = customerDAO.getCustomerById(customerId);
            
            if (customer != null) {
                customer.setFullName(request.getParameter("fullName"));
                customer.setEmail(request.getParameter("email"));
                customer.setPhone(request.getParameter("phone"));
                customer.setAddress(request.getParameter("address"));
                
                boolean success = customerDAO.updateCustomer(customer);
                
                if (success) {
                    request.getSession().setAttribute("message", "Cập nhật khách hàng thành công!");
                } else {
                    request.getSession().setAttribute("error", "Không thể cập nhật khách hàng!");
                }
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/customers?action=list");
        }
    }
}