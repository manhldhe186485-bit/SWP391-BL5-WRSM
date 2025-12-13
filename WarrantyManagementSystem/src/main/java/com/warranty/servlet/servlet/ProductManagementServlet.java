package com.warranty.servlet;

import com.warranty.dao.ProductDAO;
import com.warranty.model.Product;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.util.List;

/**
 * Servlet for Admin to manage products (CRUD operations)
 */
@WebServlet("/admin/products")
public class ProductManagementServlet extends HttpServlet {

    private ProductDAO productDAO = new ProductDAO();

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
            // List all products
            List<Product> products = productDAO.getAllProducts();
            request.setAttribute("products", products);
            request.getRequestDispatcher("/views/admin/product-management.jsp").forward(request, response);
            
        } else if ("edit".equals(action)) {
            // Edit product form
            int productId = Integer.parseInt(request.getParameter("productId"));
            Product product = productDAO.getProductById(productId);
            
            if (product != null) {
                request.setAttribute("product", product);
                request.setAttribute("editMode", true);
            }
            
            List<Product> products = productDAO.getAllProducts();
            request.setAttribute("products", products);
            request.getRequestDispatcher("/views/admin/product-management.jsp").forward(request, response);
            
        } else if ("delete".equals(action)) {
            // Delete product
            int productId = Integer.parseInt(request.getParameter("productId"));
            boolean success = productDAO.deleteProduct(productId);
            
            if (success) {
                request.getSession().setAttribute("message", "Xóa sản phẩm thành công!");
            } else {
                request.getSession().setAttribute("error", "Không thể xóa sản phẩm!");
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/products?action=list");
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
            // Create new product
            Product product = new Product();
            product.setProductCode(request.getParameter("productCode"));
            product.setName(request.getParameter("name"));
            product.setCategory(request.getParameter("category"));
            product.setBrand(request.getParameter("brand"));
            product.setModel(request.getParameter("model"));
            product.setDescription(request.getParameter("description"));
            
            String warrantyMonthsStr = request.getParameter("warrantyMonths");
            if (warrantyMonthsStr != null && !warrantyMonthsStr.isEmpty()) {
                product.setWarrantyMonths(Integer.parseInt(warrantyMonthsStr));
            }
            
            boolean success = productDAO.createProduct(product);
            
            if (success) {
                request.getSession().setAttribute("message", "Tạo sản phẩm mới thành công!");
            } else {
                request.getSession().setAttribute("error", "Không thể tạo sản phẩm!");
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/products?action=list");
            
        } else if ("update".equals(action)) {
            // Update product
            int productId = Integer.parseInt(request.getParameter("productId"));
            Product product = productDAO.getProductById(productId);
            
            if (product != null) {
                product.setProductCode(request.getParameter("productCode"));
                product.setName(request.getParameter("name"));
                product.setCategory(request.getParameter("category"));
                product.setBrand(request.getParameter("brand"));
                product.setModel(request.getParameter("model"));
                product.setDescription(request.getParameter("description"));
                
                String warrantyMonthsStr = request.getParameter("warrantyMonths");
                if (warrantyMonthsStr != null && !warrantyMonthsStr.isEmpty()) {
                    product.setWarrantyMonths(Integer.parseInt(warrantyMonthsStr));
                }
                
                boolean success = productDAO.updateProduct(product);
                
                if (success) {
                    request.getSession().setAttribute("message", "Cập nhật sản phẩm thành công!");
                } else {
                    request.getSession().setAttribute("error", "Không thể cập nhật sản phẩm!");
                }
            }
            
            response.sendRedirect(request.getContextPath() + "/admin/products?action=list");
        }
    }
}
