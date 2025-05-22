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
        /* Styles remain the same */
    </style>
</head>
<body>
    <%
        // Check if user is logged in and is an admin
        User user = (User) session.getAttribute("user");
        if (user == null || !user.getRole().equals("ADMIN")) {
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

    <div id="loadingOverlay" class="loading-overlay">
        <div class="loading-spinner"></div>
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
        
        function showLoading() {
            document.getElementById('loadingOverlay').classList.add('active');
        }
        
        function hideLoading() {
            document.getElementById('loadingOverlay').classList.remove('active');
        }
        
        function confirmDeleteAuthor(authorId, authorName) {
            Swal.fire({
                title: 'Delete Author',
                html: 'Are you sure you want to delete <strong>' + authorName + '</strong>?<br><small>This will also delete all books by this author.</small>',
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
            showLoading();
            
            fetch('../admin/authors', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'action=delete&id=' + authorId
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok: ' + response.status);
                }
                return response.text();
            })
            .then(text => {
                hideLoading();
                
                // Try to parse as JSON, but handle if it's not JSON
                let data;
                try {
                    data = JSON.parse(text);
                } catch (e) {
                    console.error('Failed to parse JSON response:', text);
                    // If not JSON, create a simple object with the text as message
                    data = { 
                        success: text.includes('success') || text.includes('deleted'), 
                        message: text 
                    };
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
                hideLoading();
                console.error('Error:', error);
                Swal.fire({
                    title: 'Error!',
                    text: 'An error occurred while deleting the author: ' + error.message,
                    icon: 'error'
                });
            });
        }
    </script>
</body>
</html>
