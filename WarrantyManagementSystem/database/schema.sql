-- Warranty Management System Database Schema
-- Created: 2025-12-10

DROP DATABASE IF EXISTS warranty_system;
CREATE DATABASE warranty_system CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE warranty_system;

-- =====================================
-- Table: users
-- Quản lý tất cả người dùng trong hệ thống
-- =====================================
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    role ENUM('ADMIN', 'TECH_MANAGER', 'TECHNICIAN', 'WAREHOUSE', 'CUSTOMER') NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_email (email),
    INDEX idx_role (role)
) ENGINE=InnoDB;

-- =====================================
-- Table: customers
-- Thông tin chi tiết khách hàng
-- =====================================
CREATE TABLE customers (
    customer_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT UNIQUE,
    customer_code VARCHAR(50) UNIQUE,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20) NOT NULL,
    address TEXT,
    id_number VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_customer_code (customer_code),
    INDEX idx_phone (phone)
) ENGINE=InnoDB;

-- =====================================
-- Table: products
-- Danh mục sản phẩm
-- =====================================
CREATE TABLE products (
    product_id INT AUTO_INCREMENT PRIMARY KEY,
    product_code VARCHAR(50) UNIQUE NOT NULL,
    product_name VARCHAR(200) NOT NULL,
    category VARCHAR(100),
    brand VARCHAR(100),
    model VARCHAR(100),
    description TEXT,
    warranty_period_months INT DEFAULT 12,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_product_code (product_code),
    INDEX idx_category (category)
) ENGINE=InnoDB;

-- =====================================
-- Table: product_serials
-- Sản phẩm đã bán với serial number
-- =====================================
CREATE TABLE product_serials (
    serial_id INT AUTO_INCREMENT PRIMARY KEY,
    serial_number VARCHAR(100) UNIQUE NOT NULL,
    product_id INT NOT NULL,
    customer_id INT NOT NULL,
    purchase_date DATE NOT NULL,
    warranty_start_date DATE NOT NULL,
    warranty_end_date DATE NOT NULL,
    purchase_price DECIMAL(15,2),
    store_location VARCHAR(100),
    invoice_number VARCHAR(50),
    status ENUM('ACTIVE', 'EXPIRED', 'VOID') DEFAULT 'ACTIVE',
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(product_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    INDEX idx_serial_number (serial_number),
    INDEX idx_warranty_dates (warranty_start_date, warranty_end_date),
    INDEX idx_status (status)
) ENGINE=InnoDB;

-- =====================================
-- Table: repair_tickets
-- Phiếu tiếp nhận bảo hành/sửa chữa
-- =====================================
CREATE TABLE repair_tickets (
    ticket_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_number VARCHAR(50) UNIQUE NOT NULL,
    serial_id INT NOT NULL,
    customer_id INT NOT NULL,
    intake_technician_id INT NOT NULL,
    assigned_technician_id INT,
    tech_manager_id INT,
    issue_description TEXT NOT NULL,
    initial_diagnosis TEXT,
    priority ENUM('LOW', 'MEDIUM', 'HIGH', 'URGENT') DEFAULT 'MEDIUM',
    ticket_type ENUM('WARRANTY', 'PAID_REPAIR', 'INSPECTION') DEFAULT 'WARRANTY',
    status ENUM('PENDING_ASSIGNMENT', 'ASSIGNED', 'IN_DIAGNOSIS', 'WAITING_APPROVAL', 
                'APPROVED', 'IN_REPAIR', 'WAITING_PARTS', 'COMPLETED', 
                'WAITING_PAYMENT', 'PAID', 'DELIVERED', 'CANCELLED') DEFAULT 'PENDING_ASSIGNMENT',
    received_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    estimated_completion_date DATE,
    actual_completion_date TIMESTAMP,
    delivery_date TIMESTAMP,
    total_cost DECIMAL(15,2) DEFAULT 0,
    labor_cost DECIMAL(15,2) DEFAULT 0,
    parts_cost DECIMAL(15,2) DEFAULT 0,
    is_paid BOOLEAN DEFAULT FALSE,
    payment_date TIMESTAMP,
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (serial_id) REFERENCES product_serials(serial_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
    FOREIGN KEY (intake_technician_id) REFERENCES users(user_id),
    FOREIGN KEY (assigned_technician_id) REFERENCES users(user_id),
    FOREIGN KEY (tech_manager_id) REFERENCES users(user_id),
    INDEX idx_ticket_number (ticket_number),
    INDEX idx_status (status),
    INDEX idx_customer (customer_id),
    INDEX idx_assigned_tech (assigned_technician_id),
    INDEX idx_dates (received_date, estimated_completion_date)
) ENGINE=InnoDB;

-- =====================================
-- Table: repair_sheets
-- Phiếu thông tin bảo hành (chi tiết sửa chữa)
-- =====================================
CREATE TABLE repair_sheets (
    sheet_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    technician_id INT NOT NULL,
    diagnosis TEXT,
    repair_actions TEXT,
    test_results TEXT,
    warranty_applicable BOOLEAN DEFAULT TRUE,
    requires_customer_approval BOOLEAN DEFAULT FALSE,
    customer_approved BOOLEAN,
    approval_date TIMESTAMP,
    estimated_repair_cost DECIMAL(15,2),
    actual_repair_cost DECIMAL(15,2),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES repair_tickets(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (technician_id) REFERENCES users(user_id),
    INDEX idx_ticket (ticket_id)
) ENGINE=InnoDB;

-- =====================================
-- Table: inventory_items
-- Kho linh kiện
-- =====================================
CREATE TABLE inventory_items (
    item_id INT AUTO_INCREMENT PRIMARY KEY,
    item_code VARCHAR(50) UNIQUE NOT NULL,
    item_name VARCHAR(200) NOT NULL,
    category VARCHAR(100),
    unit VARCHAR(20) DEFAULT 'PCS',
    quantity_in_stock INT DEFAULT 0,
    min_stock_level INT DEFAULT 10,
    unit_price DECIMAL(15,2),
    supplier VARCHAR(100),
    location VARCHAR(100),
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    INDEX idx_item_code (item_code),
    INDEX idx_category (category),
    INDEX idx_stock_level (quantity_in_stock)
) ENGINE=InnoDB;

-- =====================================
-- Table: parts_requests
-- Yêu cầu xuất linh kiện
-- =====================================
CREATE TABLE parts_requests (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    request_number VARCHAR(50) UNIQUE NOT NULL,
    ticket_id INT NOT NULL,
    technician_id INT NOT NULL,
    warehouse_staff_id INT,
    status ENUM('PENDING', 'APPROVED', 'REJECTED', 'FULFILLED', 'CANCELLED') DEFAULT 'PENDING',
    request_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_date TIMESTAMP,
    fulfilled_date TIMESTAMP,
    notes TEXT,
    rejection_reason TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES repair_tickets(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (technician_id) REFERENCES users(user_id),
    FOREIGN KEY (warehouse_staff_id) REFERENCES users(user_id),
    INDEX idx_request_number (request_number),
    INDEX idx_status (status),
    INDEX idx_ticket (ticket_id)
) ENGINE=InnoDB;

-- =====================================
-- Table: parts_request_items
-- Chi tiết linh kiện trong yêu cầu
-- =====================================
CREATE TABLE parts_request_items (
    request_item_id INT AUTO_INCREMENT PRIMARY KEY,
    request_id INT NOT NULL,
    item_id INT NOT NULL,
    quantity_requested INT NOT NULL,
    quantity_approved INT,
    quantity_issued INT,
    unit_price DECIMAL(15,2),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (request_id) REFERENCES parts_requests(request_id) ON DELETE CASCADE,
    FOREIGN KEY (item_id) REFERENCES inventory_items(item_id),
    INDEX idx_request (request_id)
) ENGINE=InnoDB;

-- =====================================
-- Table: inventory_transactions
-- Lịch sử giao dịch kho
-- =====================================
CREATE TABLE inventory_transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    item_id INT NOT NULL,
    transaction_type ENUM('IN', 'OUT', 'ADJUSTMENT', 'RETURN') NOT NULL,
    quantity INT NOT NULL,
    reference_type ENUM('PARTS_REQUEST', 'PURCHASE', 'RETURN', 'ADJUSTMENT'),
    reference_id INT,
    performed_by INT NOT NULL,
    notes TEXT,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES inventory_items(item_id),
    FOREIGN KEY (performed_by) REFERENCES users(user_id),
    INDEX idx_item (item_id),
    INDEX idx_date (transaction_date),
    INDEX idx_type (transaction_type)
) ENGINE=InnoDB;

-- =====================================
-- Table: repair_progress_logs
-- Nhật ký tiến trình sửa chữa
-- =====================================
CREATE TABLE repair_progress_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    ticket_id INT NOT NULL,
    technician_id INT NOT NULL,
    status VARCHAR(50) NOT NULL,
    progress_description TEXT NOT NULL,
    completion_percentage INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (ticket_id) REFERENCES repair_tickets(ticket_id) ON DELETE CASCADE,
    FOREIGN KEY (technician_id) REFERENCES users(user_id),
    INDEX idx_ticket (ticket_id),
    INDEX idx_date (created_at)
) ENGINE=InnoDB;

-- =====================================
-- Table: notifications
-- Thông báo cho người dùng
-- =====================================
CREATE TABLE notifications (
    notification_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(200) NOT NULL,
    message TEXT NOT NULL,
    reference_type VARCHAR(50),
    reference_id INT,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read_at TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    INDEX idx_user (user_id),
    INDEX idx_read (is_read),
    INDEX idx_date (created_at)
) ENGINE=InnoDB;

-- =====================================
-- Table: system_settings
-- Cấu hình hệ thống
-- =====================================
CREATE TABLE system_settings (
    setting_id INT AUTO_INCREMENT PRIMARY KEY,
    setting_key VARCHAR(100) UNIQUE NOT NULL,
    setting_value TEXT,
    setting_type VARCHAR(50),
    description TEXT,
    updated_by INT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (updated_by) REFERENCES users(user_id),
    INDEX idx_key (setting_key)
) ENGINE=InnoDB;

-- =====================================
-- Table: audit_logs
-- Nhật ký kiểm toán hệ thống
-- =====================================
CREATE TABLE audit_logs (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(100) NOT NULL,
    table_name VARCHAR(50),
    record_id INT,
    old_value TEXT,
    new_value TEXT,
    ip_address VARCHAR(45),
    user_agent TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE SET NULL,
    INDEX idx_user (user_id),
    INDEX idx_action (action),
    INDEX idx_table (table_name),
    INDEX idx_date (created_at)
) ENGINE=InnoDB;

-- =====================================
-- Insert Default Data
-- =====================================

-- Default Admin User (password: Admin@123)
INSERT INTO users (username, password_hash, full_name, email, phone, role) VALUES
('admin', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'System Administrator', 'admin@warranty.com', '0123456789', 'ADMIN');

-- Default Tech Manager (password: Manager@123)
INSERT INTO users (username, password_hash, full_name, email, phone, role) VALUES
('techmanager', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Technical Manager', 'techmanager@warranty.com', '0123456788', 'TECH_MANAGER');

-- Default Technician (password: Tech@123)
INSERT INTO users (username, password_hash, full_name, email, phone, role) VALUES
('tech01', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Technician 01', 'tech01@warranty.com', '0123456787', 'TECHNICIAN');

-- Default Warehouse Staff (password: Warehouse@123)
INSERT INTO users (username, password_hash, full_name, email, phone, role) VALUES
('warehouse', '$2a$10$N9qo8uLOickgx2ZMRZoMyeIjZAgcfl7p92ldGxad68LJZdL17lhWy', 'Warehouse Staff', 'warehouse@warranty.com', '0123456786', 'WAREHOUSE');

-- Default System Settings
INSERT INTO system_settings (setting_key, setting_value, setting_type, description) VALUES
('DEFAULT_WARRANTY_MONTHS', '12', 'INTEGER', 'Thời gian bảo hành mặc định (tháng)'),
('COMPANY_NAME', 'Warranty Management System', 'STRING', 'Tên công ty'),
('COMPANY_ADDRESS', '123 Main Street, City', 'STRING', 'Địa chỉ công ty'),
('COMPANY_PHONE', '1900-xxxx', 'STRING', 'Số điện thoại công ty'),
('COMPANY_EMAIL', 'contact@warranty.com', 'STRING', 'Email công ty'),
('MAX_FILE_UPLOAD_SIZE', '10485760', 'INTEGER', 'Kích thước file upload tối đa (bytes)'),
('LOW_STOCK_THRESHOLD', '10', 'INTEGER', 'Ngưỡng cảnh báo hàng tồn kho thấp');

-- Sample Product Categories
INSERT INTO products (product_code, product_name, category, brand, model, warranty_period_months) VALUES
('PROD001', 'Smart TV 55 inch', 'Television', 'Samsung', 'UA55AU7700', 24),
('PROD002', 'Laptop Gaming', 'Computer', 'ASUS', 'ROG Strix G15', 12),
('PROD003', 'Smartphone', 'Mobile', 'iPhone', '14 Pro Max', 12),
('PROD004', 'Air Conditioner', 'Home Appliance', 'Daikin', 'FTKC35UAVMV', 24);

-- Sample Inventory Items
INSERT INTO inventory_items (item_code, item_name, category, unit, quantity_in_stock, min_stock_level, unit_price) VALUES
('PART001', 'LCD Screen 55"', 'Display', 'PCS', 10, 5, 2500000.00),
('PART002', 'Laptop Battery', 'Battery', 'PCS', 20, 10, 500000.00),
('PART003', 'Phone Screen Protector', 'Accessory', 'PCS', 50, 20, 50000.00),
('PART004', 'AC Cooling Gas', 'Consumable', 'KG', 30, 10, 150000.00),
('PART005', 'Thermal Paste', 'Consumable', 'TUBE', 100, 30, 20000.00);
