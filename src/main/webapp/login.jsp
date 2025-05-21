<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - E-Library Hub</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .auth-container {
            max-width: 450px;
            margin: 60px auto;
            padding: 30px;
            background-color: white;
            border-radius: var(--border-radius);
            box-shadow: var(--shadow);
        }
        
        .auth-header {
            text-align: center;
            margin-bottom: 30px;
        }
        
        .auth-header .logo {
            justify-content: center;
            margin-bottom: 20px;
        }
        
        .auth-form .form-group {
            margin-bottom: 20px;
        }
        
        .auth-form label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
        }
        
        .auth-form input {
            width: 100%;
            padding: 12px 15px;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            font-size: 1rem;
        }
        
        .auth-form .password-field {
            position: relative;
        }
        
        .auth-form .toggle-password {
            position: absolute;
            right: 15px;
            top: 50%;
            transform: translateY(-50%);
            cursor: pointer;
            color: var(--text-light);
        }
        
        .auth-form .form-footer {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-top: 15px;
            margin-bottom: 25px;
        }
        
        .auth-form .remember-me {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .auth-form .remember-me input {
            width: auto;
        }
        
        .auth-form .forgot-password {
            color: var(--primary-color);
            font-size: 0.9rem;
        }
        
        .auth-form .btn-primary {
            width: 100%;
            padding: 12px;
            font-size: 1rem;
        }
        
        .auth-divider {
            display: flex;
            align-items: center;
            margin: 25px 0;
            color: var(--text-light);
        }
        
        .auth-divider::before,
        .auth-divider::after {
            content: "";
            flex: 1;
            height: 1px;
            background-color: var(--border-color);
        }
        
        .auth-divider span {
            padding: 0 15px;
            font-size: 0.9rem;
        }
        
        .social-login {
            display: grid;
            grid-template-columns: 1fr;
            gap: 15px;
            margin-bottom: 25px;
        }
        
        .social-btn {
            display: flex;
            align-items: center;
            justify-content: center;
            gap: 10px;
            padding: 12px;
            border-radius: var(--border-radius);
            border: 1px solid var(--border-color);
            background-color: white;
            cursor: pointer;
            transition: background-color var(--transition-speed) ease;
        }
        
        .social-btn:hover {
            background-color: var(--secondary-color);
        }
        
        .auth-footer {
            text-align: center;
            margin-top: 20px;
            font-size: 0.9rem;
        }
        
        .auth-footer a {
            color: var(--primary-color);
            font-weight: 500;
        }
        
        .error-message {
            background-color: #f8d7da;
            color: #721c24;
            padding: 10px;
            border-radius: var(--border-radius);
            margin-bottom: 20px;
            text-align: center;
        }
        
        .success-message {
            background-color: #d4edda;
            color: #155724;
            padding: 10px;
            border-radius: var(--border-radius);
            margin-bottom: 20px;
            text-align: center;
        }
    </style>
</head>
<body>
    <header class="main-header">
        <div class="container">
            <div class="logo">
                <i class="fas fa-book-open"></i>
                <h1>E-Library Hub</h1>
            </div>
            <nav class="main-nav">
                <ul>
                    <li><a href="index.jsp">Home</a></li>
                    <li><a href="browsebook.jsp">Browse Books</a></li>
                    <li class="active"><a href="login.jsp">Login</a></li>
                    <li><a href="register.jsp" class="btn-primary">Register</a></li>
                </ul>
            </nav>
            <button class="mobile-menu-toggle">
                <i class="fas fa-bars"></i>
            </button>
        </div>
    </header>

    <main>
        <div class="container">
            <div class="auth-container">
                <div class="auth-header">
                    <div class="logo">
                        <i class="fas fa-book-open"></i>
                        <h2>E-Library Hub</h2>
                    </div>
                    <h2>Welcome Back</h2>
                    <p>Sign in to access your account</p>
                </div>
                
                <% if(request.getAttribute("errorMessage") != null) { %>
                    <div class="error-message">
                        <%= request.getAttribute("errorMessage") %>
                    </div>
                <% } %>
                
                <% if(request.getAttribute("successMessage") != null) { %>
                    <div class="success-message">
                        <%= request.getAttribute("successMessage") %>
                    </div>
                <% } %>
                
                <form class="auth-form" action="LoginServlet" method="post">
                    <div class="form-group">
                        <label for="email">Email</label>
                        <input type="email" id="email" name="email" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="password">Password</label>
                        <div class="password-field">
                            <input type="password" id="password" name="password" required>
                            <i class="toggle-password fas fa-eye"></i>
                        </div>
                    </div>
                    
                    <div class="form-footer">
                        <div class="remember-me">
                            <input type="checkbox" id="remember" name="remember">
                            <label for="remember">Remember me</label>
                        </div>
                        <a href="forgot-password.jsp" class="forgot-password">Forgot Password?</a>
                    </div>
                    
                    <button type="submit" class="btn-primary">Sign In</button>
                </form>
                
                <div class="auth-divider">
                    <span>OR</span>
                </div>
                
                <div class="social-login">
                    <button class="social-btn">
                        <i class="fab fa-google"></i>
                        <span>Continue with Google</span>
                    </button>
                    <button class="social-btn">
                        <i class="fab fa-facebook-f"></i>
                        <span>Continue with Facebook</span>
                    </button>
                </div>
                
                <div class="auth-footer">
                    Don't have an account? <a href="register.jsp">Sign Up</a>
                </div>
            </div>
        </div>
    </main>

    <footer class="main-footer">
        <div class="container">
            <div class="footer-grid">
                <div class="footer-about">
                    <div class="logo">
                        <i class="fas fa-book-open"></i>
                        <h2>E-Library Hub</h2>
                    </div>
                    <p>A platform for readers and authors to share knowledge through e-books.</p>
                </div>
                <div class="footer-links">
                    <h3>Quick Links</h3>
                    <ul>
                        <li><a href="index.jsp">Home</a></li>
                        <li><a href="browsebook.jsp">Browse Books</a></li>
                        <li><a href="login.jsp">Login</a></li>
                        <li><a href="register.jsp">Register</a></li>
                    </ul>
                </div>
                <div class="footer-links">
                    <h3>Information</h3>
                    <ul>
                        <li><a href="about_us.jsp">About Us</a></li>
                        <li><a href="contact_us.jsp">Contact Us</a></li>
                        <li><a href="privacy.html">Privacy Policy</a></li>
                        <li><a href="terms.html">Terms of Service</a></li>
                    </ul>
                </div>
                <div class="footer-contact">
                    <h3>Contact Us</h3>
                    <p><i class="fas fa-envelope"></i> info@elibraryhub.com</p>
                    <p><i class="fas fa-phone"></i> +1 (555) 123-4567</p>
                    <div class="social-links">
                        <a href="#"><i class="fab fa-facebook"></i></a>
                        <a href="#"><i class="fab fa-twitter"></i></a>
                        <a href="#"><i class="fab fa-instagram"></i></a>
                        <a href="#"><i class="fab fa-linkedin"></i></a>
                    </div>
                </div>
            </div>
            <div class="footer-bottom">
                <p>&copy; 2023 E-Library Hub. All rights reserved.</p>
            </div>
        </div>
    </footer>

    <script>
        // Toggle password visibility
        document.querySelector('.toggle-password').addEventListener('click', function() {
            const passwordField = document.getElementById('password');
            const type = passwordField.getAttribute('type') === 'password' ? 'text' : 'password';
            passwordField.setAttribute('type', type);
            this.classList.toggle('fa-eye');
            this.classList.toggle('fa-eye-slash');
        });
        
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            document.querySelector('.main-nav').classList.toggle('active');
        });
    </script>
</body>
</html>