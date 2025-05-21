<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List"%>
<%@ page import="java.util.ArrayList"%>
<%@ page import="mode.Book"%>
<%@ page import="mode.User"%>
<%@ page import="mode.Review"%>
<%@ page import="dao.BookDAO"%>
<%@ page import="dao.ReviewDAO"%>
<%@ page import="java.text.SimpleDateFormat"%>
<%@ page import="java.util.Date"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Author Dashboard - E-Library Hub</title>
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
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
        }
        
        .stat-card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 15px;
        }
        
        .stat-card-icon {
            width: 50px;
            height: 50px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
        }
        
        .stat-card-icon.books {
            background-color: rgba(74, 109, 167, 0.1);
            color: var(--primary-color);
        }
        
        .stat-card-icon.views {
            background-color: rgba(40, 167, 69, 0.1);
            color: #28a745;
        }
        
        .stat-card-icon.downloads {
            background-color: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }
        
        .stat-card-icon.ratings {
            background-color: rgba(220, 53, 69, 0.1);
            color: #dc3545;
        }
        
        .stat-card-value {
            font-size: 2rem;
            font-weight: 700;
            margin-bottom: 5px;
        }
        
        .stat-card-label {
            color: var(--text-light);
            font-size: 0.9rem;
        }
        
        .recent-section {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
            margin-bottom: 30px;
        }
        
        .recent-section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
        }
        
        .recent-section-title {
            font-size: 1.2rem;
        }
        
        .recent-section table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .recent-section th, .recent-section td {
            padding: 12px 15px;
            text-align: left;
            border-bottom: 1px solid var(--border-color);
        }
        
        .recent-section th {
            font-weight: 600;
            color: var(--text-light);
        }
        
        .recent-section tbody tr:hover {
            background-color: rgba(0, 0, 0, 0.02);
        }
        
        .status-badge {
            display: inline-block;
            padding: 5px 10px;
            border-radius: 20px;
            font-size: 0.8rem;
        }
        
        .status-badge.approved {
            background-color: rgba(40, 167, 69, 0.1);
            color: #28a745;
        }
        
        .status-badge.pending {
            background-color: rgba(255, 193, 7, 0.1);
            color: #ffc107;
        }
        
        .status-badge.rejected {
            background-color: rgba(220, 53, 69, 0.1);
            color: #dc3545;
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
        
        .quick-actions {
            display: grid;
            grid-template-columns: repeat(auto-fill, minmax(200px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .quick-action-card {
            background-color: white;
            border-radius: var(--border-radius);
            padding: 20px;
            box-shadow: var(--shadow);
            text-align: center;
            transition: all 0.3s ease;
        }
        
        .quick-action-card:hover {
            transform: translateY(-5px);
        }
        
        .quick-action-icon {
            width: 60px;
            height: 60px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.8rem;
            margin: 0 auto 15px;
            background-color: rgba(74, 109, 167, 0.1);
            color: var(--primary-color);
        }
        
        .quick-action-title {
            font-size: 1.1rem;
            margin-bottom: 10px;
        }
        
        .quick-action-desc {
            font-size: 0.9rem;
            color: var(--text-light);
            margin-bottom: 15px;
        }
        
        /* Modal styles */
        .modal {
            display: none;
            position: fixed;
            z-index: 1000;
            left: 0;
            top: 0;
            width: 100%;
            height: 100%;
            overflow: auto;
            background-color: rgba(0, 0, 0, 0.5);
        }
        
        .modal-content {
            background-color: #fefefe;
            margin: 10% auto;
            padding: 20px;
            border-radius: var(--border-radius);
            width: 80%;
            max-width: 600px;
            box-shadow: var(--shadow);
            position: relative;
        }
        
        .close-modal {
            position: absolute;
            right: 20px;
            top: 15px;
            font-size: 1.5rem;
            cursor: pointer;
        }
        
        .modal-header {
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border-color);
        }
        
        .modal-title {
            font-size: 1.3rem;
            margin: 0;
        }
        
        .modal-body {
            margin-bottom: 20px;
        }
        
        .modal-footer {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
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
    // Check if user is logged in and is an author
    User user = (User) session.getAttribute("user");
    if (user == null || user.getRole() != User.Role.AUTHOR) {
        response.sendRedirect(request.getContextPath() + "/login.jsp");
        return;
    }
    
    // Get author's books
    BookDAO bookDAO = new BookDAO();
    List<Book> authorBooks = new ArrayList<>();
    
    try {
        authorBooks = bookDAO.getBooksByAuthor(user.getUserId());
    } catch (Exception e) {
        e.printStackTrace();
    }
    
    // Calculate statistics
    int totalBooks = authorBooks.size();
    int totalViews = 0;
    int totalDownloads = 0;
    double totalRating = 0;
    int ratedBooks = 0;
    
    for (Book book : authorBooks) {
        totalViews += book.getViews();
        totalDownloads += book.getDownloads();
        if (book.getRating() > 0) {
            totalRating += book.getRating();
            ratedBooks++;
        }
    }
    
    double averageRating = ratedBooks > 0 ? totalRating / ratedBooks : 0;
    
    // Get recent reviews
    ReviewDAO reviewDAO = new ReviewDAO();
    List<Review> recentReviews = new ArrayList<>();
    
 
   
    
    // Format date
    SimpleDateFormat dateFormat = new SimpleDateFormat("MMM dd, yyyy");
    String currentDate = dateFormat.format(new Date());
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
                <li><a href="dashboard.jsp" class="active"><i class="fas fa-tachometer-alt"></i> Dashboard</a></li>
                <li><a href="my-books.jsp"><i class="fas fa-book"></i> My Books</a></li>
                <li><a href="upload-book.jsp"><i class="fas fa-upload"></i> Upload Book</a></li>
                <li><a href="analytics.jsp"><i class="fas fa-chart-line"></i> Analytics</a></li>
                <li><a href="reviews.jsp"><i class="fas fa-star"></i> Reviews</a></li>
                <li><a href="profile.jsp"><i class="fas fa-user"></i> Profile</a></li>
                <li><a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>
        
        <main class="main-content">
            <div class="dashboard-header">
                <h1 class="dashboard-title">Author Dashboard</h1>
                <div class="date">
                    <i class="far fa-calendar-alt"></i> <%= currentDate %>
                </div>
            </div>
            
            <div class="quick-actions">
                <div class="quick-action-card">
                    <div class="quick-action-icon">
                        <i class="fas fa-upload"></i>
                    </div>
                    <h3 class="quick-action-title">Upload Book</h3>
                    <p class="quick-action-desc">Share your knowledge by uploading a new e-book</p>
                    <a href="upload-book.jsp" class="btn-primary">Upload Now</a>
                </div>
                
                <div class="quick-action-card">
                    <div class="quick-action-icon">
                        <i class="fas fa-edit"></i>
                    </div>
                    <h3 class="quick-action-title">Edit Books</h3>
                    <p class="quick-action-desc">Update your existing e-books</p>
                    <a href="my-books.jsp" class="btn-primary">Manage Books</a>
                </div>
                
                <div class="quick-action-card">
                    <div class="quick-action-icon">
                        <i class="fas fa-chart-line"></i>
                    </div>
                    <h3 class="quick-action-title">View Analytics</h3>
                    <p class="quick-action-desc">Check your books' performance</p>
                    <a href="analytics.jsp" class="btn-primary">View Stats</a>
                </div>
                
                <div class="quick-action-card">
                    <div class="quick-action-icon">
                        <i class="fas fa-user-edit"></i>
                    </div>
                    <h3 class="quick-action-title">Update Profile</h3>
                    <p class="quick-action-desc">Edit your author profile</p>
                    <a href="profile.jsp" class="btn-primary">Edit Profile</a>
                </div>
            </div>
            
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-card-header">
                        <div>
                            <div class="stat-card-value"><%= totalBooks %></div>
                            <div class="stat-card-label">Published Books</div>
                        </div>
                        <div class="stat-card-icon books">
                            <i class="fas fa-book"></i>
                        </div>
                    </div>
                    <div class="stat-card-footer">
                        <span class="trend-up"><i class="fas fa-arrow-up"></i> 2</span> new this month
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card-header">
                        <div>
                            <div class="stat-card-value"><%= totalViews %></div>
                            <div class="stat-card-label">Total Views</div>
                        </div>
                        <div class="stat-card-icon views">
                            <i class="fas fa-eye"></i>
                        </div>
                    </div>
                    <div class="stat-card-footer">
                        <span class="trend-up"><i class="fas fa-arrow-up"></i> 12%</span> from last month
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card-header">
                        <div>
                            <div class="stat-card-value"><%= totalDownloads %></div>
                            <div class="stat-card-label">Total Downloads</div>
                        </div>
                        <div class="stat-card-icon downloads">
                            <i class="fas fa-download"></i>
                        </div>
                    </div>
                    <div class="stat-card-footer">
                        <span class="trend-up"><i class="fas fa-arrow-up"></i> 8%</span> from last month
                    </div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-card-header">
                        <div>
                            <div class="stat-card-value"><%= String.format("%.1f", averageRating) %></div>
                            <div class="stat-card-label">Average Rating</div>
                        </div>
                        <div class="stat-card-icon ratings">
                            <i class="fas fa-star"></i>
                        </div>
                    </div>
                    <div class="stat-card-footer">
                        <span class="trend-up"><i class="fas fa-arrow-up"></i> 0.2</span> from last month
                    </div>
                </div>
            </div>
            
            <div class="recent-section">
                <div class="recent-section-header">
                    <h2 class="recent-section-title">My Books</h2>
                    <a href="my-books.jsp" class="btn-secondary">View All</a>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Title</th>
                            <th>Category</th>
                            <th>Status</th>
                            <th>Views</th>
                            <th>Downloads</th>
                            <th>Rating</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        int displayLimit = Math.min(authorBooks.size(), 5);
                        for (int i = 0; i < displayLimit; i++) {
                            Book book = authorBooks.get(i);
                            String statusClass = "";
                            
                            if (book.getStatus() == Book.Status.APPROVED) {
                                statusClass = "approved";
                            } else if (book.getStatus() == Book.Status.PENDING) {
                                statusClass = "pending";
                            } else {
                                statusClass = "rejected";
                            }
                        %>
                        <tr>
                            <td><%= book.getTitle() %></td>
                            <td><%= book.getCategoryName() %></td>
                            <td><span class="status-badge <%= statusClass %>"><%= book.getStatus() %></span></td>
                            <td><%= book.getViews() %></td>
                            <td><%= book.getDownloads() %></td>
                            <td>
                                <% if (book.getRating() > 0) { %>
                                    <%= String.format("%.1f", book.getRating()) %> <i class="fas fa-star" style="color: gold;"></i>
                                <% } else { %>
                                    N/A
                                <% } %>
                            </td>
                            <td>
                                <div class="action-buttons">
                                    <button class="action-btn view-book-btn" data-id="<%= book.getBookId() %>"><i class="fas fa-eye"></i></button>
                                    <button class="action-btn edit-book-btn" data-id="<%= book.getBookId() %>"><i class="fas fa-edit"></i></button>
                                    <button class="action-btn delete-book-btn" data-id="<%= book.getBookId() %>"><i class="fas fa-trash"></i></button>
                                </div>
                            </td>
                        </tr>
                        <% } %>
                        
                        <% if (authorBooks.isEmpty()) { %>
                        <tr>
                            <td colspan="7" style="text-align: center; padding: 20px;">
                                <p>You haven't published any books yet.</p>
                                <a href="upload-book.jsp" class="btn-primary" style="display: inline-block; margin-top: 10px;">Upload Your First Book</a>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
            
            <div class="recent-section">
                <div class="recent-section-header">
                    <h2 class="recent-section-title">Recent Reviews</h2>
                    <a href="reviews.jsp" class="btn-secondary">View All</a>
                </div>
                <table>
                    <thead>
                        <tr>
                            <th>Book</th>
                            <th>User</th>
                            <th>Rating</th>
                            <th>Comment</th>
                            <th>Date</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        for (Review review : recentReviews) {
                        %>
                        <tr>
                            <td><%= review.getBookTitle() %></td>
                            <td><%= review.getUserName() %></td>
                            <td><%= review.getRating() %> <i class="fas fa-star" style="color: gold;"></i></td>
                            <td><%= review.getComment() %></td>
                            <td><%= dateFormat.format(review.getReviewDate()) %></td>
                        </tr>
                        <% } %>
                        
                        <% if (recentReviews.isEmpty()) { %>
                        <tr>
                            <td colspan="5" style="text-align: center; padding: 20px;">
                                <p>No reviews yet.</p>
                            </td>
                        </tr>
                        <% } %>
                    </tbody>
                </table>
            </div>
        </main>
    </div>
    
    <!-- View Book Modal -->
    <div id="viewBookModal" class="modal">
        <div class="modal-content">
            <span class="close-modal">&times;</span>
            <div class="modal-header">
                <h2 class="modal-title">Book Details</h2>
            </div>
            <div class="modal-body" id="bookDetailsContent">
                <!-- Book details will be loaded here -->
            </div>
            <div class="modal-footer">
                <button class="btn-secondary close-modal-btn">Close</button>
            </div>
        </div>
    </div>
    
    <!-- Delete Book Modal -->
    <div id="deleteBookModal" class="modal">
        <div class="modal-content">
            <span class="close-modal">&times;</span>
            <div class="modal-header">
                <h2 class="modal-title">Delete Book</h2>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete this book? This action cannot be undone.</p>
                <p><strong>Book Title: </strong><span id="deleteBookTitle"></span></p>
                <form id="deleteBookForm" action="../AuthorServlet" method="post">
                    <input type="hidden" name="action" value="deleteBook">
                    <input type="hidden" id="deleteBookId" name="bookId">
                </form>
            </div>
            <div class="modal-footer">
                <button class="btn-secondary close-modal-btn">Cancel</button>
                <button class="btn-danger" id="confirmDeleteBtn">Delete</button>
            </div>
        </div>
    </div>

    <script>
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            document.querySelector('.main-nav').classList.toggle('active');
        });
        
        // Modal functions
        function openModal(modalId) {
            document.getElementById(modalId).style.display = 'block';
            document.body.style.overflow = 'hidden';
        }
        
        function closeModal(modalId) {
            document.getElementById(modalId).style.display = 'none';
            document.body.style.overflow = 'auto';
        }
        
        // Close modals when clicking on X or close button
        document.querySelectorAll('.close-modal, .close-modal-btn').forEach(function(element) {
            element.addEventListener('click', function() {
                document.querySelectorAll('.modal').forEach(function(modal) {
                    modal.style.display = 'none';
                });
                document.body.style.overflow = 'auto';
            });
        });
        
        // Close modals when clicking outside the modal content
        window.addEventListener('click', function(event) {
            document.querySelectorAll('.modal').forEach(function(modal) {
                if (event.target === modal) {
                    modal.style.display = 'none';
                    document.body.style.overflow = 'auto';
                }
            });
        });
        
        // View Book button click
        document.querySelectorAll('.view-book-btn').forEach(function(button) {
            button.addEventListener('click', function() {
                const bookId = this.getAttribute('data-id');
                
                // Fetch book details
                fetch('../AuthorServlet?action=getBookDetails&bookId=' + bookId)
                    .then(response => response.json())
                    .then(book => {
                        // Format dates
                        const uploadDate = new Date(book.uploadDate);
                        const formattedUploadDate = new Intl.DateTimeFormat('en-US', {
                            year: 'numeric',
                            month: 'long',
                            day: 'numeric'
                        }).format(uploadDate);
                        
                        const publicationDate = new Date(book.publicationDate);
                        const formattedPublicationDate = new Intl.DateTimeFormat('en-US', {
                            year: 'numeric',
                            month: 'long',
                            day: 'numeric'
                        }).format(publicationDate);
                        
                        // Create HTML for book details
                        let statusClass = '';
                        if (book.status === 'APPROVED') {
                            statusClass = 'approved';
                        } else if (book.status === 'PENDING') {
                            statusClass = 'pending';
                        } else {
                            statusClass = 'rejected';
                        }
                        
                        const bookDetailsHTML = `
                            <div style="display: flex; gap: 20px; margin-bottom: 20px;">
                                <div style="flex: 0 0 150px;">
                                    <img src="${book.coverImagePath}" alt="${book.title}" style="width: 100%; border-radius: 5px;">
                                </div>
                                <div style="flex: 1;">
                                    <h3 style="margin-top: 0;">${book.title}</h3>
                                    <p><strong>Category:</strong> ${book.categoryName}</p>
                                    <p><strong>Status:</strong> <span class="status-badge ${statusClass}">${book.status}</span></p>
                                    <p><strong>Publication Date:</strong> ${formattedPublicationDate}</p>
                                    <p><strong>Upload Date:</strong> ${formattedUploadDate}</p>
                                    <p><strong>Language:</strong> ${book.language}</p>
                                    <p><strong>Pages:</strong> ${book.pages}</p>
                                </div>
                            </div>
                            <div style="margin-bottom: 20px;">
                                <h4>Description</h4>
                                <p>${book.description}</p>
                            </div>
                            <div style="display: flex; gap: 20px;">
                                <div style="flex: 1;">
                                    <h4>Statistics</h4>
                                    <p><strong>Views:</strong> ${book.views}</p>
                                    <p><strong>Downloads:</strong> ${book.downloads}</p>
                                    <p><strong>Rating:</strong> ${book.rating > 0 ? book.rating.toFixed(1) + ' <i class="fas fa-star" style="color: gold;"></i>' : 'N/A'}</p>
                                </div>
                                <div style="flex: 1;">
                                    <h4>File Information</h4>
                                    <p><strong>Format:</strong> ${book.format}</p>
                                    <p><strong>Size:</strong> ${book.fileSize}</p>
                                    <a href="../DownloadServlet?id=${book.bookId}" class="btn-primary" style="display: inline-block; margin-top: 10px;">Download</a>
                                </div>
                            </div>
                        `;
                        
                        document.getElementById('bookDetailsContent').innerHTML = bookDetailsHTML;
                        openModal('viewBookModal');
                    })
                    .catch(error => console.error('Error fetching book details:', error));
            });
        });
        
        // Edit Book button click
        document.querySelectorAll('.edit-book-btn').forEach(function(button) {
            button.addEventListener('click', function() {
                const bookId = this.getAttribute('data-id');
                window.location.href = 'edit-book.jsp?id=' + bookId;
            });
        });
        
        // Delete Book button click
        document.querySelectorAll('.delete-book-btn').forEach(function(button) {
            button.addEventListener('click', function() {
                const bookId = this.getAttribute('data-id');
                
                // Fetch book details to show title in confirmation
                fetch('../AuthorServlet?action=getBookDetails&bookId=' + bookId)
                    .then(response => response.json())
                    .then(book => {
                        document.getElementById('deleteBookTitle').textContent = book.title;
                        document.getElementById('deleteBookId').value = book.bookId;
                        openModal('deleteBookModal');
                    })
                    .catch(error => console.error('Error fetching book details:', error));
            });
        });
        
        // Confirm Delete button click
        document.getElementById('confirmDeleteBtn').addEventListener('click', function() {
            document.getElementById('deleteBookForm').submit();
        });
    </script>
</body>
</html>
