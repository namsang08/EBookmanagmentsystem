<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="mode.User, java.util.List, dao.UserDAO, java.text.SimpleDateFormat" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Manage Users - E-Library Hub</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="../css/admin-styles.css">
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
        
        // Get users from DAO
        UserDAO userDAO = new UserDAO();
        List<User> allUsers = userDAO.getAllUsers();
        
        // Count users by role
        int totalUsers = 0;
        int adminCount = 0;
        int authorCount = 0;
        int userCount = 0;
        
        if (allUsers != null) {
            totalUsers = allUsers.size();
            for (User u : allUsers) {
                if (u.getRole().equals("ADMIN")) {
                    adminCount++;
                } else if (u.getRole().equals("AUTHOR")) {
                    authorCount++;
                } else if (u.getRole().equals("USER")) {
                    userCount++;
                }
            }
        }
        
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
                <li><a href="users.jsp" class="active"><i class="fas fa-users"></i> Users</a></li>
                <li><a href="authors.jsp"><i class="fas fa-user-edit"></i> Authors</a></li>
                <li><a href="categories.jsp"><i class="fas fa-tags"></i> Categories</a></li>
                <li><a href="reports.jsp"><i class="fas fa-chart-bar"></i> Reports</a></li>
                <li><a href="settings.jsp"><i class="fas fa-cog"></i> Settings</a></li>
                <li><a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>
        
        <main class="main-content">
            <div class="page-header">
                <h1 class="page-title">Manage Users</h1>
                <a href="add-user.jsp" class="btn-primary"><i class="fas fa-plus"></i> Add New User</a>
            </div>
            
            <!-- Statistics Cards -->
            <div class="stats-cards">
                <div class="stat-card">
                    <div class="icon total">
                        <i class="fas fa-users"></i>
                    </div>
                    <div class="content">
                        <h3><%= totalUsers %></h3>
                        <p>Total Users</p>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="icon admin">
                        <i class="fas fa-user-shield"></i>
                    </div>
                    <div class="content">
                        <h3><%= adminCount %></h3>
                        <p>Administrators</p>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="icon author">
                        <i class="fas fa-user-edit"></i>
                    </div>
                    <div class="content">
                        <h3><%= authorCount %></h3>
                        <p>Authors</p>
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="icon user">
                        <i class="fas fa-user"></i>
                    </div>
                    <div class="content">
                        <h3><%= userCount %></h3>
                        <p>Regular Users</p>
                    </div>
                </div>
            </div>
            
            <div class="users-container">
                <div class="search-filter-container">
                    <div class="search-box">
                        <i class="fas fa-search"></i>
                        <input type="text" id="searchInput" placeholder="Search by name or email...">
                    </div>
                    <div class="filter-dropdown">
                        <select id="roleFilter">
                            <option value="all">All Roles</option>
                            <option value="ADMIN">Admin</option>
                            <option value="AUTHOR">Author</option>
                            <option value="USER">User</option>
                        </select>
                    </div>
                    <div class="filter-dropdown">
                        <select id="statusFilter">
                            <option value="all">All Status</option>
                            <option value="active">Active</option>
                            <option value="inactive">Inactive</option>
                        </select>
                    </div>
                    <button class="btn-primary" id="applyFilters">
                        <i class="fas fa-filter"></i> Apply Filters
                    </button>
                </div>
                
                <% if (allUsers != null && !allUsers.isEmpty()) { %>
                <div class="table-responsive">
                    <table class="users-table">
                        <thead>
                            <tr>
                                <th>Name</th>
                                <th>Email</th>
                                <th>Role</th>
                                <th>Status</th>
                                <th>Joined Date</th>
                                <th>Last Login</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="usersTableBody">
                            <% for (User u : allUsers) {
                                if (u.getUserId() == user.getUserId()) continue; // Skip current admin
                            %>
                            <tr>
                                <td><%= u.getFirstName() + " " + u.getLastName() %></td>
                                <td><%= u.getEmail() %></td>
                                <td>
                                    <% if (u.getRole().equals("ADMIN")) { %>
                                        <span class="role-badge admin">Admin</span>
                                    <% } else if (u.getRole().equals("AUTHOR")) { %>
                                        <span class="role-badge author">Author</span>
                                    <% } else { %>
                                        <span class="role-badge user">User</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (u.isActive()) { %>
                                        <span class="status-badge active">Active</span>
                                    <% } else { %>
                                        <span class="status-badge inactive">Inactive</span>
                                    <% } %>
                                </td>
                                <td><%= u.getRegistrationDate() != null ? dateFormat.format(u.getRegistrationDate()) : "N/A" %></td>
                                <td><%= u.getLastLogin() != null ? dateFormat.format(u.getLastLogin()) : "Never" %></td>
                                <td>
                                    <div class="action-buttons">
                                        <button class="action-btn view" onclick="viewUser(<%= u.getUserId() %>)" title="View Details">
                                            <i class="fas fa-eye"></i>
                                        </button>
                                        <button class="action-btn edit" onclick="editUser(<%= u.getUserId() %>)" title="Edit User">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <button class="action-btn delete" onclick="confirmDeleteUser(<%= u.getUserId() %>, '<%= u.getFirstName() + " " + u.getLastName() %>')" title="Delete User">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
                <% } else { %>
                <div class="empty-state">
                    <i class="fas fa-users"></i>
                    <p>No users found</p>
                    <a href="add-user.jsp" class="btn-primary">Add New User</a>
                </div>
                <% } %>
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
        
        // Apply filters
        document.getElementById('applyFilters').addEventListener('click', function() {
            filterUsers();
        });
        
        // Search on enter key
        document.getElementById('searchInput').addEventListener('keyup', function(event) {
            if (event.key === 'Enter') {
                filterUsers();
            }
        });
        
        // Filter users based on search input and dropdown selections
        function filterUsers() {
            const searchQuery = document.getElementById('searchInput').value.toLowerCase();
            const roleFilter = document.getElementById('roleFilter').value;
            const statusFilter = document.getElementById('statusFilter').value;
            
            const rows = document.getElementById('usersTableBody').getElementsByTagName('tr');
            let visibleCount = 0;
            
            for (let i = 0; i < rows.length; i++) {
                const row = rows[i];
                const nameCell = row.cells[0];
                const emailCell = row.cells[1];
                const roleCell = row.cells[2];
                const statusCell = row.cells[3];
                
                if (!nameCell) continue; // Skip if row doesn't have cells
                
                const name = nameCell.textContent.toLowerCase();
                const email = emailCell.textContent.toLowerCase();
                const role = roleCell.textContent.toLowerCase();
                const status = statusCell.textContent.toLowerCase();
                
                const matchesSearch = name.includes(searchQuery) || email.includes(searchQuery);
                const matchesRole = roleFilter === 'all' || role.includes(roleFilter.toLowerCase());
                const matchesStatus = statusFilter === 'all' || status.includes(statusFilter.toLowerCase());
                
                if (matchesSearch && matchesRole && matchesStatus) {
                    row.style.display = '';
                    visibleCount++;
                } else {
                    row.style.display = 'none';
                }
            }
            
            // Show empty state message if no results
            const tableContainer = document.querySelector('.table-responsive');
            const emptyState = document.querySelector('.empty-state');
            
            if (visibleCount === 0 && tableContainer) {
                if (!emptyState) {
                    const newEmptyState = document.createElement('div');
                    newEmptyState.className = 'empty-state';
                    newEmptyState.innerHTML = `
                        <i class="fas fa-search"></i>
                        <p>No users match your search criteria</p>
                        <button class="btn-secondary" onclick="resetFilters()">Reset Filters</button>
                    `;
                    tableContainer.style.display = 'none';
                    document.querySelector('.users-container').appendChild(newEmptyState);
                }
            } else {
                if (tableContainer) tableContainer.style.display = 'block';
                const dynamicEmptyState = document.querySelector('.empty-state:not(:first-child)');
                if (dynamicEmptyState) dynamicEmptyState.remove();
            }
        }
        
        // Reset all filters
        function resetFilters() {
            document.getElementById('searchInput').value = '';
            document.getElementById('roleFilter').value = 'all';
            document.getElementById('statusFilter').value = 'all';
            filterUsers();
        }
        
        // User actions
        function viewUser(userId) {
            window.location.href = "user-details.jsp?id=" + userId;
        }
        
        function editUser(userId) {
            window.location.href = "edit-user.jsp?id=" + userId;
        }
        
        function showLoading() {
            document.getElementById('loadingOverlay').classList.add('active');
        }
        
        function hideLoading() {
            document.getElementById('loadingOverlay').classList.remove('active');
        }
        
        function confirmDeleteUser(userId, userName) {
            Swal.fire({
                title: 'Delete User',
                html: 'Are you sure you want to delete <strong>' + userName + '</strong>?<br><small>This action cannot be undone.</small>',
                icon: 'warning',
                showCancelButton: true,
                confirmButtonColor: '#dc3545',
                cancelButtonColor: '#6c757d',
                confirmButtonText: 'Yes, delete it!',
                cancelButtonText: 'Cancel'
            }).then((result) => {
                if (result.isConfirmed) {
                    deleteUser(userId);
                }
            });
        }
        
        function deleteUser(userId) {
            // Show loading state
            showLoading();
            
            fetch('../admin/users', {
                method: 'POST',
                headers: {
                    'Content-Type': 'application/x-www-form-urlencoded',
                },
                body: 'action=delete&id=' + userId
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
                        text: data.message || 'User has been deleted successfully.',
                        icon: 'success'
                    }).then(() => {
                        window.location.reload();
                    });
                } else {
                    Swal.fire({
                        title: 'Error!',
                        text: data.message || 'An error occurred while deleting the user.',
                        icon: 'error'
                    });
                }
            })
            .catch(error => {
                hideLoading();
                console.error('Error:', error);
                Swal.fire({
                    title: 'Error!',
                    text: 'An error occurred while deleting the user: ' + error.message,
                    icon: 'error'
                });
            });
        }
    </script>
</body>
</html>
