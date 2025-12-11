package com.warranty.servlet;

import com.warranty.dao.UserDAO;
import com.warranty.model.User;
import com.warranty.util.PasswordUtil;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * Servlet for handling user login
 */
public class LoginServlet extends HttpServlet {
    
    private UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập tên đăng nhập và mật khẩu");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.getUserByUsername(username);

        if (user != null && PasswordUtil.verifyPassword(password, user.getPasswordHash())) {
            HttpSession session = request.getSession();
            session.setAttribute("user", user);
            session.setAttribute("userId", user.getUserId());
            session.setAttribute("username", user.getUsername());
            session.setAttribute("fullName", user.getFullName());
            session.setAttribute("role", user.getRole().name());

            // Redirect based on role
            String redirectUrl = getRedirectUrlByRole(user.getRole());
            response.sendRedirect(request.getContextPath() + redirectUrl);
        } else {
            request.setAttribute("error", "Tên đăng nhập hoặc mật khẩu không đúng");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }

    private String getRedirectUrlByRole(User.UserRole role) {
        switch (role) {
            case ADMIN:
                return "/views/admin/dashboard.jsp";
            case TECH_MANAGER:
                return "/tech-manager/dashboard";
            case TECHNICIAN:
                return "/technician/dashboard";
            case WAREHOUSE:
                return "/views/warehouse/dashboard.jsp";
            case CUSTOMER:
                return "/customer/track-ticket";
            default:
                return "/views/home.jsp";
        }
    }
}
