package com.warranty.servlet;

import com.warranty.dao.UserDAO;
import com.warranty.model.User;
import com.warranty.util.PasswordUtil;
import com.google.gson.Gson;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Servlet for Admin to manage system users (CRUD operations)
 */
@WebServlet("/admin/users")
public class UserManagementServlet extends HttpServlet {

    private UserDAO userDAO = new UserDAO();
    private Gson gson = new Gson();

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
            // ========== LIST ALL USERS ==========
            List<User> users = userDAO.getAllUsers();
            request.setAttribute("users", users);
            request.getRequestDispatcher("/views/admin/user-management.jsp").forward(request, response);
            
        } else if ("edit".equals(action)) {
            // ========== EDIT USER FORM ==========
            int userId = Integer.parseInt(request.getParameter("userId"));
            User user = userDAO.getUserById(userId);
            
            if (user != null) {
                request.setAttribute("user", user);
                request.setAttribute("editMode", true);
            }
            
            List<User> users = userDAO.getAllUsers();
            request.setAttribute("users", users);
            request.getRequestDispatcher("/views/admin/user-management.jsp").forward(request, response);
            
        } else if ("delete".equals(action)) {
            // ========== DELETE USER ==========
            int userId = Integer.parseInt(request.getParameter("userId"));
            boolean success = userDAO.deleteUser(userId);
            
            if (success) {
                request.getSession().setAttribute("message", "Xóa người dùng thành công!");
            } else {
                request.getSession().setAttribute("error", "Không thể xóa người dùng!");
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
            
        } else if ("toggle-status".equals(action)) {
            // ========== ACTIVATE/DEACTIVATE USER ==========
            int userId = Integer.parseInt(request.getParameter("userId"));
            User user = userDAO.getUserById(userId);
            
            if (user != null) {
                boolean newStatus = !user.isActive();
                boolean success;
                
                if (newStatus) {
                    success = userDAO.activateUser(userId);
                } else {
                    success = userDAO.deactivateUser(userId);
                }
                
                if (success) {
                    request.getSession().setAttribute("message", 
                        newStatus ? "Kích hoạt người dùng thành công!" : "Vô hiệu hóa người dùng thành công!");
                }
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
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
            // ========== CREATE NEW USER ==========
            String username = request.getParameter("username");
            String password = request.getParameter("password");
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String roleStr = request.getParameter("role");
            
            // Validate input
            if (username == null || password == null || fullName == null || 
                email == null || roleStr == null) {
                request.getSession().setAttribute("error", "Vui lòng điền đầy đủ thông tin!");
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
                return;
            }
            
            // Check if username exists
            if (userDAO.usernameExists(username)) {
                request.getSession().setAttribute("error", "Tên đăng nhập đã tồn tại!");
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
                return;
            }
            
            // Check if email exists
            if (userDAO.emailExists(email)) {
                request.getSession().setAttribute("error", "Email đã được sử dụng!");
                response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
                return;
            }
            
            // Create user
            User user = new User();
            user.setUsername(username);
            user.setPasswordHash(PasswordUtil.hashPassword(password));
            user.setFullName(fullName);
            user.setEmail(email);
            user.setPhone(phone);
            user.setRole(User.UserRole.valueOf(roleStr));
            user.setActive(true);
            
            boolean success = userDAO.createUser(user);
            
            if (success) {
                request.getSession().setAttribute("message", "Tạo người dùng mới thành công!");
            } else {
                request.getSession().setAttribute("error", "Không thể tạo người dùng!");
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
            
        } else if ("update".equals(action)) {
            // ========== UPDATE USER ==========
            int userId = Integer.parseInt(request.getParameter("userId"));
            String fullName = request.getParameter("fullName");
            String email = request.getParameter("email");
            String phone = request.getParameter("phone");
            String roleStr = request.getParameter("role");
            
            User user = userDAO.getUserById(userId);
            if (user != null) {
                user.setFullName(fullName);
                user.setEmail(email);
                user.setPhone(phone);
                user.setRole(User.UserRole.valueOf(roleStr));
                
                boolean success = userDAO.updateUser(user);
                
                if (success) {
                    request.getSession().setAttribute("message", "Cập nhật người dùng thành công!");
                } else {
                    request.getSession().setAttribute("error", "Không thể cập nhật người dùng!");
                }
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
            
        } else if ("reset-password".equals(action)) {
            // ========== RESET PASSWORD ==========
            int userId = Integer.parseInt(request.getParameter("userId"));
            String newPassword = request.getParameter("newPassword");
            
            if (newPassword != null && !newPassword.trim().isEmpty()) {
                String hashedPassword = PasswordUtil.hashPassword(newPassword);
                boolean success = userDAO.updatePassword(userId, hashedPassword);
                
                if (success) {
                    request.getSession().setAttribute("message", "Đặt lại mật khẩu thành công!");
                } else {
                    request.getSession().setAttribute("error", "Không thể đặt lại mật khẩu!");
                }
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/users?action=list");
        }
    }
}
