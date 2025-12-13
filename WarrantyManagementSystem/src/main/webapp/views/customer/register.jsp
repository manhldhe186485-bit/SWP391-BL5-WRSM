<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Đăng Ký Tài Khoản</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .register-container {
            background: white;
            padding: 40px;
            border-radius: 15px;
            box-shadow: 0 10px 40px rgba(0,0,0,0.2);
            max-width: 500px;
            width: 100%;
        }
        .logo {
            text-align: center;
            margin-bottom: 30px;
        }
        .logo h1 {
            color: #667eea;
            font-size: 32px;
            margin-bottom: 10px;
        }
        .logo p {
            color: #666;
            font-size: 16px;
        }
        .form-group {
            margin-bottom: 20px;
        }
        label {
            display: block;
            margin-bottom: 8px;
            color: #555;
            font-weight: 600;
        }
        .required {
            color: #dc3545;
        }
        input {
            width: 100%;
            padding: 12px;
            border: 2px solid #ddd;
            border-radius: 8px;
            font-size: 16px;
            transition: border-color 0.3s;
        }
        input:focus {
            outline: none;
            border-color: #667eea;
        }
        .btn {
            width: 100%;
            padding: 15px;
            border: none;
            border-radius: 8px;
            font-size: 18px;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s;
        }
        .btn-primary {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
        }
        .btn-primary:hover {
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(102, 126, 234, 0.4);
        }
        .alert {
            padding: 15px;
            border-radius: 8px;
            margin-bottom: 20px;
        }
        .alert-success {
            background: #d4edda;
            color: #155724;
            border: 1px solid #c3e6cb;
        }
        .alert-danger {
            background: #f8d7da;
            color: #721c24;
            border: 1px solid #f5c6cb;
        }
        .login-link {
            text-align: center;
            margin-top: 20px;
            color: #666;
        }
        .login-link a {
            color: #667eea;
            text-decoration: none;
            font-weight: 600;
        }
        .login-link a:hover {
            text-decoration: underline;
        }
        .password-strength {
            font-size: 12px;
            margin-top: 5px;
        }
        .strength-weak { color: #dc3545; }
        .strength-medium { color: #ffc107; }
        .strength-strong { color: #28a745; }
    </style>
</head>
<body>
    <div class="register-container">
        <div class="logo">
            <h1>🔧 Hệ Thống Bảo Hành</h1>
            <p>Đăng ký tài khoản khách hàng</p>
        </div>

        <% if (request.getAttribute("success") != null) { %>
            <div class="alert alert-success">
                <%= request.getAttribute("success") %>
            </div>
        <% } %>

        <% if (request.getAttribute("error") != null) { %>
            <div class="alert alert-danger">
                <%= request.getAttribute("error") %>
            </div>
        <% } %>

        <form action="${pageContext.request.contextPath}/register" method="post" onsubmit="return validateForm()">
            <div class="form-group">
                <label>Tên Đăng Nhập <span class="required">*</span></label>
                <input type="text" name="username" id="username" required 
                       minlength="3" maxlength="50"
                       placeholder="Tối thiểu 3 ký tự">
            </div>

            <div class="form-group">
                <label>Mật Khẩu <span class="required">*</span></label>
                <input type="password" name="password" id="password" required 
                       minlength="6"
                       placeholder="Tối thiểu 6 ký tự"
                       oninput="checkPasswordStrength()">
                <div id="passwordStrength" class="password-strength"></div>
            </div>

            <div class="form-group">
                <label>Xác Nhận Mật Khẩu <span class="required">*</span></label>
                <input type="password" name="confirmPassword" id="confirmPassword" required 
                       minlength="6"
                       placeholder="Nhập lại mật khẩu">
            </div>

            <div class="form-group">
                <label>Họ Tên <span class="required">*</span></label>
                <input type="text" name="fullName" required 
                       placeholder="Họ và tên đầy đủ">
            </div>

            <div class="form-group">
                <label>Email <span class="required">*</span></label>
                <input type="email" name="email" required 
                       placeholder="example@email.com">
            </div>

            <div class="form-group">
                <label>Số Điện Thoại</label>
                <input type="tel" name="phone" 
                       pattern="[0-9]{10,11}"
                       placeholder="Số điện thoại 10-11 số">
            </div>

            <button type="submit" class="btn btn-primary">✅ Đăng Ký</button>
        </form>

        <div class="login-link">
            Đã có tài khoản? <a href="${pageContext.request.contextPath}/login">Đăng Nhập</a>
        </div>
    </div>

    <script>
        function checkPasswordStrength() {
            const password = document.getElementById('password').value;
            const strengthDiv = document.getElementById('passwordStrength');
            
            if (password.length === 0) {
                strengthDiv.textContent = '';
                return;
            }
            
            let strength = 0;
            if (password.length >= 8) strength++;
            if (/[a-z]/.test(password) && /[A-Z]/.test(password)) strength++;
            if (/[0-9]/.test(password)) strength++;
            if (/[^a-zA-Z0-9]/.test(password)) strength++;
            
            if (strength <= 1) {
                strengthDiv.textContent = '⚠️ Mật khẩu yếu';
                strengthDiv.className = 'password-strength strength-weak';
            } else if (strength <= 2) {
                strengthDiv.textContent = '⚠️ Mật khẩu trung bình';
                strengthDiv.className = 'password-strength strength-medium';
            } else {
                strengthDiv.textContent = '✅ Mật khẩu mạnh';
                strengthDiv.className = 'password-strength strength-strong';
            }
        }
        
        function validateForm() {
            const password = document.getElementById('password').value;
            const confirmPassword = document.getElementById('confirmPassword').value;
            
            if (password !== confirmPassword) {
                alert('Mật khẩu xác nhận không khớp!');
                return false;
            }
            
            if (password.length < 6) {
                alert('Mật khẩu phải có ít nhất 6 ký tự!');
                return false;
            }
            
            return true;
        }
    </script>
</body>
</html>
