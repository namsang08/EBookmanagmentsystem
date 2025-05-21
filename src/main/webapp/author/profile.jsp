<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="mode.User"%>
<%@ page import="mode.Category"%>
<%@ page import="dao.CategoryDAO"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Upload Book - E-Library Hub</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        .dashboard-container {
            display: grid;
            grid-template-columns: 250px 1fr;
            min-height: calc(100vh - 60px);
        }
        
        .sidebar {
            background-color: #2c3e50;
            color: white;
            padding: 20px 0;
        }
        
        .sidebar-header {
            padding: 0 20px 20px;
            border-bottom: 1px solid rgba(255, 255, 255, 0.1);
            margin-bottom: 20px;
        }
        
        .sidebar-header h2 {
            font-size: 1.2rem;
            margin-bottom: 5px;
        }
        
        .sidebar-header p {
            font-size: 0.9rem;
            opacity: 0.7;
        }
        
        .sidebar-menu {
            list-style: none;
        }
        
        .sidebar-menu li {
            margin-bottom: 5px;
        }
        
        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 10px 20px;
            color: rgba(255, 255, 255, 0.7);
            transition: all 0.3s ease;
        }
        
        .sidebar-menu a:hover, .sidebar-menu a.active {
            background-color: rgba(255, 255, 255, 0.1);
            color: white;
        }
        
        .sidebar-menu i {
            margin-right: 10px;
            width: 20px;
            text-align: center;
        }
        
        .main-content {
            padding: 20px;
            background-color: #f8f9fa;
        }
        
        .dashboard-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .dashboard-title {
            font-size: 1.5rem;
        }
        
        .upload-form-container {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 30px;
            box-shadow: var(--shadow);
            max-width: 800px;
            margin: 0 auto;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 8px;
            font-weight: 500;
        }
        
        .form-control {
            width: 100%;
            padding: 10px 15px;
            border: 1px solid var(--border-color);
            border-radius: var(--border-radius);
            font-size: 1rem;
        }
        
        .form-control:focus {
            border-color: var(--primary-color);
            outline: none;
        }
        
        textarea.form-control {
            min-height: 150px;
            resize: vertical;
        }
        
        .form-hint {
            font-size: 0.8rem;
            color: var(--text-light);
            margin-top: 5px;
        }
        
        .form-row {
            display: flex;
            gap: 20px;
        }
        
        .form-row .form-group {
            flex: 1;
        }
        
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 30px;
        }
        
        @media (max-width: 992px) {
            .dashboard-container {
                grid-template-columns: 1fr;
            }
            
            .sidebar {
                display: none;
            }
            
            .form-row {
                flex-direction: column;
                gap: 0;
            }
        }
    </style>
</head>
<body>
    <%
    // Check if user is logged in and is an author
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRole() != User.Role.AUTHOR) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get categories for dropdown
    CategoryDAO categoryDAO = new CategoryDAO();
    List<Category> categories = categoryDAO.getAllCategories();
    %>

    <header class="main-header">
        <div class="container">
            <div class="logo">
                <i class="fas fa-book-open"></i>
                <h1>E-Library Hub</h1>
            </div>
            <nav class="main-nav">
                <ul>
                    <li><a href="../index.jsp">Home</a></li>
                    <li><a href="../browsebook.jsp">Browse Books</a></li>
                    <li><a href="../LogoutServlet">Logout</a></li>
                </ul>
            </nav>
            <button class="mobile-menu-toggle">
                <i class="fas fa-bars"></i>
            </button>
        </div>
    </header>

    <div class="dashboard-container">
        <aside class="sidebar">
            <div class="sidebar-header">
                <h2>Author Dashboard</h2>
                <p>Welcome, <%= user.getFirstName() %></p>
            </div>
            <ul class="sidebar-menu">
                <li><a href="dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="my-books.jsp"><i class="fas fa-book"></i> My Books</a></li>
                <li><a href="upload-book.jsp" class="active"><i class="fas fa-upload"></i> Upload Book</a></li>
                <li><a href="analytics.jsp"><i class="fas fa-chart-line"></i> Analytics</a></li>
                <li><a href="reviews.jsp"><i class="fas fa-star"></i> Reviews</a></li>
                <li><a href="profile.jsp"><i class="fas fa-user"></i> Profile</a></li>
                <li><a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>
        
        <main class="main-content">
            <div class="dashboard-header">
                <h1 class="dashboard-title">Upload New Book</h1>
            </div>
            
            <div class="upload-form-container">
                <form action="../AuthorServlet" method="post" enctype="multipart/form-data" id="uploadBookForm">
                    <input type="hidden" name="action" value="uploadBook">
                    
                    <div class="form-group">
                        <label for="title">Book Title *</label>
                        <input type="text" id="title" name="title" class="form-control" required>
                    </div>
                    
                    <div class="form-group">
                        <label for="description">Description *</label>
                        <textarea id="description" name="description" class="form-control" required></textarea>
                        <div class="form-hint">Provide a detailed description of your book.</div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="categoryId">Category *</label>
                            <select id="categoryId" name="categoryId" class="form-control" required>
                                <option value="">Select Category</option>
                                <% for (Category category : categories) { %>
                                <option value="<%= category.getCategoryId() %>"><%= category.getName() %></option>
                                <% } %>
                            </select>
                        </div>
                        
                        <div class="form-group">
                            <label for="language">Language *</label>
                            <select id="language" name="language" class="form-control" required>
                                <option value="">Select Language</option>
                                <option value="English">English</option>
                                <option value="Spanish">Spanish</option>
                                <option value="French">French</option>
                                <option value="German">German</option>
                                <option value="Chinese">Chinese</option>
                                <option value="Japanese">Japanese</option>
                                <option value="Russian">Russian</option>
                                <option value="Arabic">Arabic</option>
                                <option value="Hindi">Hindi</option>
                                <option value="Other">Other</option>
                            </select>
                        </div>
                    </div>
                    
                    <div class="form-row">
                        <div class="form-group">
                            <label for="pages">Number of Pages *</label>
                            <input type="number" id="pages" name="pages" class="form-control" min="1" required>
                        </div>
                        
                        <div class="form-group">
                            <label for="publicationDate">Publication Date *</label>
                            <input type="date" id="publicationDate" name="publicationDate" class="form-control" required>
                        </div>
                    </div>
                    
                    <div class="form-group">
                        <label for="tags">Tags</label>
                        <input type="text" id="tags" name="tags" class="form-control">
                        <div class="form-hint">Separate tags with commas (e.g., programming, web development, javascript)</div>
                    </div>
                    
                    <div class="form-group">
                        <label for="bookFile">Book File (PDF) *</label>
                        <input type="file" id="bookFile" name="bookFile" class="form-control" accept=".pdf" required>
                        <div class="form-hint">Maximum file size: 10MB</div>
                    </div>
                    
                    <div class="form-group">
                        <label for="coverImage">Cover Image *</label>
                        <input type="file" id="coverImage" name="coverImage" class="form-control" accept="image/*" required>
                        <div class="form-hint">Recommended size: 400x600 pixels. Maximum file size: 2MB</div>
                    </div>
                    
                    <div class="form-actions">
                        <button type="button" class="btn-secondary" onclick="window.location.href='dashboard.jsp'">Cancel</button>
                        <button type="submit" class="btn-primary">Upload Book</button>
                    </div>
                </form>
            </div>
        </main>
    </div>

    <script>
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            document.querySelector('.main-nav').classList.toggle('active');
        });
        
        // Form validation
        document.getElementById('uploadBookForm').addEventListener('submit', function(event) {
            const bookFile = document.getElementById('bookFile').files[0];
            const coverImage = document.getElementById('coverImage').files[0];
            
            // Check file sizes
            if (bookFile && bookFile.size > 10 * 1024 * 1024) {
                event.preventDefault();
                alert('Book file size exceeds the maximum limit of 10MB.');
                return;
            }
            
            if (coverImage && coverImage.size > 2 * 1024 * 1024) {
                event.preventDefault();
                alert('Cover image size exceeds the maximum limit of 2MB.');
                return;
            }
            
            // Check file types
            if (bookFile && !bookFile.type.includes('pdf')) {
                event.preventDefault();
                alert('Please upload a PDF file for the book.');
                return;
            }
            
            if (coverImage && !coverImage.type.includes('image')) {
                event.preventDefault();
                alert('Please upload an image file for the cover.');
                return;
            }
        });
    </script>
</body>
</html>
