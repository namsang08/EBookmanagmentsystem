<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="mode.User, mode.Author, java.util.List, dao.AuthorDAO, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Authors - E-Library Hub</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.19/dist/sweetalert2.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.19/dist/sweetalert2.all.min.js"></script>
    <style>
        /* Reuse the same styles from users.jsp */
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
        
        .page-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .page-title {
            font-size: 1.5rem;
        }
        
        .authors-container {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
        }
        
        .authors-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .authors-table th, .authors-table td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }
        
        .authors-table th {
            font-weight: 600;
            color: var(--text-light);
        }
        
        .authors-table tbody tr:hover {
            background-color: rgba(0, 0, 0, 0.02);
        }
        
        .status-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
        }
        
        .status-badge.active {
            background-color: rgba(40, 167, 69, 0.1);
            color: #28a745;
        }
        
        .status-badge.inactive {
            background-color: rgba(108, 117, 125, 0.1);
            color: #6c757d;
        }
        
        .action-buttons {
            display: flex;
            gap: 5px;
        }
        
        .action-btn {
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            background-color: var(--secondary-color);
            color: var(--text-color);
            border: none;
            cursor: pointer;
            transition: all 0.3s ease;
        }
        
        .action-btn:hover {
            background-color: var(--primary-color);
            color: white;
        }
        
        .action-btn.view:hover {
            background-color: #17a2b8;
        }
        
        .action-btn.edit:hover {
            background-color: #ffc107;
        }
        
        .action-btn.delete:hover {
            background-color: #dc3545;
        }
        
        @media (max-width: 992px) {
            .dashboard-container {
                grid-template-columns: 1fr;
            }
            
            .sidebar {
                display: none;
            }
        }
    </style>
</head>
<body>
    <%
        // Check if user is logged in and is an admin
        User user = (User) session.getAttribute("user");
        if (user == null || user.getRole() != User.Role.ADMIN) {
            response.sendRedirect("../login.jsp?error=unauthorized");
            return;
        }
        
        // Get authors from DAO
        AuthorDAO authorDAO = new AuthorDAO();
        List<Author> authors = authorDAO.getAllAuthors();
        
        // Date formatter
        SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
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
                <h2>Admin Dashboard</h2>
                <p>Welcome, <%= user.getFirstName() %></p>
            </div>
            <ul class="sidebar-menu">
                <li><a href="dashboard.jsp"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="books.jsp"><i class="fas fa-book"></i> Books</a></li>
                <li><a href="users.jsp"><i class="fas fa-users"></i> Users</a></li>
                <li><a href="authors.jsp" class="active"><i class="fas fa-user-edit"></i> Authors</a></li>
                <li><a href="categories.jsp"><i class="fas fa-tags"></i> Categories</a></li>
                <li><a href="reports.jsp"><i class="fas fa-chart-bar"></i> Reports</a></li>
                <li><a href="settings.jsp"><i class="fas fa-cog"></i> Settings</a></li>
                <li><a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>
        
        <main class="main-content">
            <div class="page-header">
                <h1 class="page-title">Manage Authors</h1>
                <a href="add-author.jsp" class="btn-primary"><i class="fas fa-plus"></i> Add New Author</a>
            </div>
            
            <div class="authors-container">
                <table class="authors-table">
                    <thead>
                        <tr>
                            <th>Name</th>
                            <th>Email</th>
                            <th>Registration Date</th>
                            <th>Status</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% if (authors != null && !authors.isEmpty()) {
                            for (Author author : authors) {
                        %>
                        <tr>
                            <td><%= author.getFirstName() + " " + author.getLastName() %></td>
                            <td><%= author.getEmail() %></td>
                            <td><%= dateFormat.format(author.getRegistrationDate()) %></td>
                            <td>
                                <% if (author.isActive()) { %>
                                    <span class="status-badge active">Active</span>
                                <% } else { %>
                                    <span class="status-badge inactive">Inactive</span>
                                <% } %>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <button class="action-btn view" onclick="viewAuthor(<%= author.getUserId() %>)">
                                        <i class="fas fa-eye"></i>
                                    </button>
                                    <button class="action-btn edit" onclick="editAuthor(<%= author.getUserId() %>)">
                                        <i class="fas fa-edit"></i>
                                    </button>
                                    <button class="action-btn delete" onclick="confirmDeleteAuthor(<%= author.getUserId() %>, '<%= author.getFirstName() + " " + author.getLastName() %>')">
                                        <i class="fas fa-trash"></i>
                                    </button>
                                </div>
                            </td>
                        </tr>
                        <% 
                            }
                        } else { 
                        %>
                        <tr>
                            <td colspan="5" style="text-align: center;">No authors found</td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </main>
    </div>

    <script>
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            document.querySelector('.main-nav').classList.toggle('active');
        });
        
        // Author actions
        function viewAuthor(authorId) {
            window.location.href = "author-details.jsp?id=" + authorId;
        }
        
        function editAuthor(authorId) {
            window.location.href = "edit-author.jsp?id=" + authorId;
        }
        
        function confirmDeleteAuthor(authorId, authorName) {
            Swal.fire({
                title: 'Delete Author',
                text: 'Are you sure you want to delete "' + authorName + '"? This will also delete all books by this author.',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#dc3545',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Yes, delete it!'
            }).then((result) => {
                if (result.isConfirmed) {
                    deleteAuthor(authorId);
                }
            });
        }
        
        function deleteAuthor(authorId) {
            fetch('../AdminAuthorServlet?action=delete&id=' + authorId, {
                method: 'POST'
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.text();
            })
            .then(text => {
                let data;
                try {
                    data = JSON.parse(text);
                } catch (e) {
                    // If the response is not JSON, create a simple object
                    data = { success: false, message: text };
                }
                
                if (data.success) {
                    Swal.fire({
                        title: 'Deleted!',
                        text: data.message || 'Author has been deleted successfully.',
                        icon: 'success'
                    }).then(() => {
                        window.location.reload();
                    });
                } else {
                    Swal.fire({
                        title: 'Error!',
                        text: data.message || 'An error occurred while deleting the author.',
                        icon: 'error'
                    });
                }
            })
            .catch(error => {
                console.error('Error:', error);
                Swal.fire({
                    title: 'Error!',
                    text: 'An error occurred while deleting the author.',
                    icon: 'error'
                });
            });
        }
    </script>
</body>
</html>
