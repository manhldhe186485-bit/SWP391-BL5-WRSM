# HƯỚNG DẪN IMPORT EXCEL

## Cấu trúc File Excel Import

File Excel cần có cấu trúc như sau:

### Sheet 1: Product_Customer_Data

| Serial Number | Product Code | Product Name | Brand | Model | Category | Customer Name | Customer Phone | Customer Email | Customer Address | Purchase Date | Warranty Months | Purchase Price | Store Location | Invoice Number |
|--------------|--------------|--------------|-------|-------|----------|---------------|----------------|----------------|------------------|---------------|-----------------|----------------|----------------|----------------|
| SN001234567 | PROD001 | Smart TV 55" | Samsung | UA55AU7700 | Television | Nguyen Van A | 0901234567 | nguyenvana@email.com | 123 Le Loi, Q1, TPHCM | 2024-01-15 | 24 | 15000000 | Store HCMC | INV-2024-0001 |
| SN001234568 | PROD002 | Laptop Gaming | ASUS | ROG Strix | Computer | Tran Thi B | 0909876543 | tranthib@email.com | 456 Nguyen Hue, Q1, TPHCM | 2024-02-20 | 12 | 25000000 | Store HCMC | INV-2024-0002 |

## Quy tắc Dữ liệu

### 1. Serial Number (Bắt buộc)
- Là mã serial duy nhất của sản phẩm
- Không được trùng lặp
- Format: Chuỗi ký tự hoặc số
- Ví dụ: SN001234567, IMEI123456789

### 2. Product Code (Bắt buộc)
- Mã sản phẩm trong hệ thống
- Nếu chưa tồn tại sẽ được tạo mới
- Format: Chuỗi ký tự
- Ví dụ: PROD001, LAPTOP-001

### 3. Product Name (Bắt buộc)
- Tên sản phẩm
- Format: Chuỗi ký tự
- Ví dụ: Smart TV 55 inch, Laptop Gaming

### 4. Brand (Không bắt buộc)
- Thương hiệu sản phẩm
- Ví dụ: Samsung, LG, Sony

### 5. Model (Không bắt buộc)
- Model/mã model của sản phẩm
- Ví dụ: UA55AU7700, ROG Strix G15

### 6. Category (Không bắt buộc)
- Danh mục sản phẩm
- Ví dụ: Television, Computer, Mobile

### 7. Customer Name (Bắt buộc)
- Tên đầy đủ của khách hàng
- Format: Chuỗi ký tự
- Ví dụ: Nguyen Van A

### 8. Customer Phone (Bắt buộc)
- Số điện thoại khách hàng
- Format: Số điện thoại VN (10-11 số)
- Ví dụ: 0901234567, 0281234567

### 9. Customer Email (Không bắt buộc)
- Email của khách hàng
- Format: email@domain.com
- Ví dụ: customer@gmail.com

### 10. Customer Address (Không bắt buộc)
- Địa chỉ khách hàng
- Format: Chuỗi ký tự
- Ví dụ: 123 Le Loi, Quan 1, TPHCM

### 11. Purchase Date (Bắt buộc)
- Ngày mua hàng
- Format: YYYY-MM-DD hoặc DD/MM/YYYY
- Ví dụ: 2024-01-15, 15/01/2024

### 12. Warranty Months (Bắt buộc)
- Thời gian bảo hành (tháng)
- Format: Số nguyên
- Ví dụ: 12, 24, 36
- Mặc định: 12 tháng nếu để trống

### 13. Purchase Price (Không bắt buộc)
- Giá mua sản phẩm
- Format: Số
- Ví dụ: 15000000, 25000000.00

### 14. Store Location (Không bắt buộc)
- Địa điểm bán hàng
- Ví dụ: Store HCMC, Chi nhanh Ha Noi

### 15. Invoice Number (Không bắt buộc)
- Số hóa đơn
- Ví dụ: INV-2024-0001, HD-001

## Lưu ý Quan trọng

### ✅ DO (Nên làm)
- Đảm bảo file Excel là định dạng .xlsx
- Row 1 phải là header (tên cột)
- Dữ liệu bắt đầu từ row 2
- Serial Number không được trùng
- Điền đầy đủ các trường bắt buộc
- Format ngày tháng đúng
- Phone number đúng format VN

### ❌ DON'T (Không nên)
- Để trống các trường bắt buộc
- Sử dụng ký tự đặc biệt trong Serial Number
- Trùng lặp Serial Number
- Format ngày sai
- Để nhiều sheet (chỉ đọc sheet đầu tiên)

## Ví dụ Dữ liệu Mẫu

```
Serial Number: SN20240101001
Product Code: TV-SAM-001
Product Name: Smart TV Samsung 55 inch
Brand: Samsung
Model: UA55AU7700KXXV
Category: Television
Customer Name: Nguyễn Văn An
Customer Phone: 0901234567
Customer Email: nguyenvanan@gmail.com
Customer Address: 123 Lê Lợi, Phường Bến Thành, Quận 1, TP.HCM
Purchase Date: 15/01/2024
Warranty Months: 24
Purchase Price: 15000000
Store Location: Chi nhánh TP.HCM
Invoice Number: INV-2024-0001
```

## Xử lý Lỗi

### Lỗi thường gặp:

1. **Serial Number trùng**
   - Hệ thống sẽ bỏ qua dòng này
   - Hiển thị thông báo lỗi với số dòng

2. **Thiếu thông tin bắt buộc**
   - Dòng bị bỏ qua
   - Hiển thị trường nào bị thiếu

3. **Format ngày sai**
   - Dòng bị bỏ qua
   - Yêu cầu format lại

4. **Format số điện thoại sai**
   - Dòng bị bỏ qua
   - Yêu cầu format lại

## Sau khi Import

Hệ thống sẽ:
1. Tạo hoặc cập nhật thông tin sản phẩm
2. Tạo hoặc cập nhật thông tin khách hàng
3. Tạo record product_serial mới
4. Tính toán ngày hết hạn bảo hành tự động
5. Hiển thị báo cáo kết quả import:
   - Số dòng thành công
   - Số dòng lỗi
   - Chi tiết lỗi từng dòng

## Tải File Mẫu

File mẫu có thể download tại menu Import Excel trong hệ thống.

---

**Lưu ý**: Nên backup database trước khi import dữ liệu lớn.
