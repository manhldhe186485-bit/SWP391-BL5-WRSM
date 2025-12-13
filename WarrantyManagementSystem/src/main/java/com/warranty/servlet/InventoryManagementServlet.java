package com.warranty.servlet;

import com.warranty.dao.InventoryItemDAO;
import com.warranty.model.InventoryItem;

import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

/**
 * Servlet for Warehouse to manage inventory items
 */
@WebServlet("/warehouse/inventory")
public class InventoryManagementServlet extends HttpServlet {

    private InventoryItemDAO inventoryDAO = new InventoryItemDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || (!role.equals("WAREHOUSE") && !role.equals("ADMIN"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        
        if ("list".equals(action) || action == null) {
            // List all inventory items
            List<InventoryItem> items = inventoryDAO.getAllItems();
            request.setAttribute("items", items);
            request.getRequestDispatcher("/views/warehouse/inventory-management.jsp").forward(request, response);
            
        } else if ("edit".equals(action)) {
            // Edit inventory item
            int itemId = Integer.parseInt(request.getParameter("itemId"));
            InventoryItem item = inventoryDAO.getItemById(itemId);
            
            if (item != null) {
                request.setAttribute("item", item);
                request.setAttribute("editMode", true);
            }
            
            List<InventoryItem> items = inventoryDAO.getAllItems();
            request.setAttribute("items", items);
            request.getRequestDispatcher("/views/warehouse/inventory-management.jsp").forward(request, response);
            
        } else if ("delete".equals(action)) {
            // Delete inventory item
            int itemId = Integer.parseInt(request.getParameter("itemId"));
            boolean success = inventoryDAO.deleteItem(itemId);
            
            if (success) {
                request.getSession().setAttribute("message", "Xóa linh kiện thành công!");
            } else {
                request.getSession().setAttribute("error", "Không thể xóa linh kiện!");
            }
            
            response.sendRedirect(request.getContextPath() + "/warehouse/inventory?action=list");
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        request.setCharacterEncoding("UTF-8");
        
        // Check authorization
        String role = (String) request.getSession().getAttribute("role");
        if (role == null || (!role.equals("WAREHOUSE") && !role.equals("ADMIN"))) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        String action = request.getParameter("action");
        
        if ("create".equals(action)) {
            // Create new inventory item
            InventoryItem item = new InventoryItem();
            item.setPartNumber(request.getParameter("partNumber"));
            item.setPartName(request.getParameter("partName"));
            item.setCategory(request.getParameter("category"));
            item.setSupplier(request.getParameter("supplier"));
            item.setDescription(request.getParameter("description"));
            item.setLocation(request.getParameter("location"));
            
            String quantityStr = request.getParameter("quantity");
            if (quantityStr != null && !quantityStr.isEmpty()) {
                item.setQuantityAvailable(Integer.parseInt(quantityStr));
            }
            
            String minQuantityStr = request.getParameter("minQuantity");
            if (minQuantityStr != null && !minQuantityStr.isEmpty()) {
                item.setMinQuantity(Integer.parseInt(minQuantityStr));
            }
            
            String unitPriceStr = request.getParameter("unitPrice");
            if (unitPriceStr != null && !unitPriceStr.isEmpty()) {
                item.setUnitPrice(new BigDecimal(unitPriceStr));
            }
            
            boolean success = inventoryDAO.createItem(item);
            
            if (success) {
                request.getSession().setAttribute("message", "Thêm linh kiện mới thành công!");
            } else {
                request.getSession().setAttribute("error", "Không thể thêm linh kiện!");
            }
            
            response.sendRedirect(request.getContextPath() + "/warehouse/inventory?action=list");
            
        } else if ("update".equals(action)) {
            // Update inventory item
            int itemId = Integer.parseInt(request.getParameter("itemId"));
            InventoryItem item = inventoryDAO.getItemById(itemId);
            
            if (item != null) {
                item.setPartNumber(request.getParameter("partNumber"));
                item.setPartName(request.getParameter("partName"));
                item.setCategory(request.getParameter("category"));
                item.setSupplier(request.getParameter("supplier"));
                item.setDescription(request.getParameter("description"));
                item.setLocation(request.getParameter("location"));
                
                String quantityStr = request.getParameter("quantity");
                if (quantityStr != null && !quantityStr.isEmpty()) {
                    item.setQuantityAvailable(Integer.parseInt(quantityStr));
                }
                
                String minQuantityStr = request.getParameter("minQuantity");
                if (minQuantityStr != null && !minQuantityStr.isEmpty()) {
                    item.setMinQuantity(Integer.parseInt(minQuantityStr));
                }
                
                String unitPriceStr = request.getParameter("unitPrice");
                if (unitPriceStr != null && !unitPriceStr.isEmpty()) {
                    item.setUnitPrice(new BigDecimal(unitPriceStr));
                }
                
                boolean success = inventoryDAO.updateItem(item);
                
                if (success) {
                    request.getSession().setAttribute("message", "Cập nhật linh kiện thành công!");
                } else {
                    request.getSession().setAttribute("error", "Không thể cập nhật linh kiện!");
                }
            }
            
            response.sendRedirect(request.getContextPath() + "/warehouse/inventory?action=list");
            
        } else if ("import".equals(action)) {
            // Import parts (increase quantity)
            int itemId = Integer.parseInt(request.getParameter("itemId"));
            int quantity = Integer.parseInt(request.getParameter("quantity"));
            
            boolean success = inventoryDAO.increaseQuantity(itemId, quantity);
            
            if (success) {
                request.getSession().setAttribute("message", "Nhập linh kiện thành công!");
            } else {
                request.getSession().setAttribute("error", "Không thể nhập linh kiện!");
            }
            
            response.sendRedirect(request.getContextPath() + "/warehouse/inventory?action=list");
        }
    }
}
