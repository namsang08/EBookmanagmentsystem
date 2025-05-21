<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="dao.BookDAO, mode.Book, java.util.List" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>E-Library Hub - Home</title>
    <link rel="stylesheet" href="css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
                    <li class="active"><a href="index.jsp">Home</a></li>
                    <li><a href="browsebook.jsp">Browse Books</a></li>
                    <li><a href="login.jsp">Login</a></li>
                    <li><a href="register.jsp" class="btn-primary">Register</a></li>
                </ul>
            </nav>
            <button class="mobile-menu-toggle">
                <i class="fas fa-bars"></i>
            </button>
        </div>
    </header>

    <div class="search-container">
        <div class="container">
            <form class="search-form" action="browsebook.jsp" method="get">
                <input type="text" name="search" placeholder="Search by title, author, or tags...">
                <button type="submit">
                    <i class="fas fa-search"></i>
                </button>
            </form>
        </div>
    </div>

    <main>
        <section class="hero">
            <div class="container">
                <div class="hero-content">
                    <h2>Discover, Read, and Share Knowledge</h2>
                    <p>Access thousands of e-books from various categories. Read anywhere, anytime.</p>
                    <div class="hero-buttons">
                        <a href="browsebook.jsp" class="btn-primary">Browse Books</a>
                        <a href="register.jsp" class="btn-secondary">Join Now</a>
                    </div>
                </div>
                <div class="hero-image">
                    <img src="css/images/logo.jpg" alt="Stack of books illustration">
                </div>
            </div>
        </section>

        <section class="featured-books">
            <div class="container">
                <h2 class="section-title">Featured Books</h2>
                <div class="book-grid">
                    <!-- Book Card 1 -->
                    <div class="book-card">
                        <div class="book-cover">
                            <img src="css/images/bookk.jpg" alt="Book Cover">
                            <div class="book-rating">
                                <i class="fas fa-star"></i>
                                <span>4.8</span>
                            </div>
                        </div>
                        <div class="book-info">
                            <h3>The Art of Programming</h3>
                            <p class="book-author">By John Smith</p>
                            <div class="book-tags">
                                <span>Technology</span>
                                <span>Programming</span>
                            </div>
                            <a href="bookdetails.jsp?id=1" class="btn-view">View Details</a>
                        </div>
                    </div>
                    
                    <!-- Book Card 2 -->
                    <div class="book-card">
                        <div class="book-cover">
                            <img src="css/images/bookkk.png" alt="Book Cover">
                            <div class="book-rating">
                                <i class="fas fa-star"></i>
                                <span>4.5</span>
                            </div>
                        </div>
                        <div class="book-info">
                            <h3>Modern Web Development</h3>
                            <p class="book-author">By Jane Doe</p>
                            <div class="book-tags">
                                <span>Web</span>
                                <span>Development</span>
                            </div>
                            <a href="bookdetails.jsp?id=2" class="btn-view">View Details</a>
                        </div>
                    </div>
                    
                    <!-- Book Card 3 -->
                    <div class="book-card">
                        <div class="book-cover">
                            <img src="css/images/bbook.jpg" alt="Book Cover">
                            <div class="book-rating">
                                <i class="fas fa-star"></i>
                                <span>4.7</span>
                            </div>
                        </div>
                        <div class="book-info">
                            <h3>Data Science Fundamentals</h3>
                            <p class="book-author">By Robert Johnson</p>
                            <div class="book-tags">
                                <span>Data</span>
                                <span>Science</span>
                            </div>
                            <a href="bookdetails.jsp?id=3" class="btn-view">View Details</a>
                        </div>
                    </div>
                    
                    <!-- Book Card 4 -->
                    <div class="book-card">
                        <div class="book-cover">
                            <img src="css/images/art.jpeg" alt="Book Cover">
                            <div class="book-rating">
                                <i class="fas fa-star"></i>
                                <span>4.6</span>
                            </div>
                        </div>
                        <div class="book-info">
                            <h3>Artificial Intelligence</h3>
                            <p class="book-author">By Sarah Williams</p>
                            <div class="book-tags">
                                <span>AI</span>
                                <span>Technology</span>
                            </div>
                            <a href="bookdetails.jsp?id=3" class="btn-view">View Details</a>
                        </div>
                    </div>
                </div>
                <div class="view-all">
                    <a href="browsebook.jsp" class="btn-secondary">View All Books</a>
                </div>
            </div>
        </section>

        <section class="categories">
            <div class="container">
                <h2 class="section-title">Browse by Category</h2>
                <div class="category-grid">
                    <a href="browsebook.jsp?category=fiction" class="category-card">
                        <i class="fas fa-book"></i>
                        <h3>Fiction</h3>
                        <span class="book-count">245 books</span>
                    </a>
                    <a href="browsebook.jsp?category=technology" class="category-card">
                        <i class="fas fa-laptop-code"></i>
                        <h3>Technology</h3>
                        <span class="book-count">187 books</span>
                    </a>
                    <a href="browsebook.jsp?category=science" class="category-card">
                        <i class="fas fa-flask"></i>
                        <h3>Science</h3>
                        <span class="book-count">156 books</span>
                    </a>
                    <a href="browsebook.jsp?category=business" class="category-card">
                        <i class="fas fa-chart-line"></i>
                        <h3>Business</h3>
                        <span class="book-count">132 books</span>
                    </a>
                    <a href="browsebook.jsp?category=history" class="category-card">
                        <i class="fas fa-landmark"></i>
                        <h3>History</h3>
                        <span class="book-count">98 books</span>
                    </a>
                    <a href="browsebook.jsp?category=biography" class="category-card">
                        <i class="fas fa-user-tie"></i>
                        <h3>Biography</h3>
                        <span class="book-count">76 books</span>
                    </a>
                </div>
            </div>
        </section>

        <section class="cta">
            <div class="container">
                <div class="cta-content">
                    <h2>Want to Share Your Knowledge?</h2>
                    <p>Join as an author and publish your e-books on our platform.</p>
                    <a href="register.jsp?role=author" class="btn-primary">Become an Author</a>
                </div>
            </div>
        </section>
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
        document.addEventListener('DOMContentLoaded', function() {
            // Mobile menu toggle
            const mobileMenuToggle = document.querySelector('.mobile-menu-toggle');
            const mainNav = document.querySelector('.main-nav');
            
            if (mobileMenuToggle) {
                mobileMenuToggle.addEventListener('click', function() {
                    mainNav.classList.toggle('active');
                    this.classList.toggle('active');
                });
            }
            
            // View Details button click handler
            const viewDetailsButtons = document.querySelectorAll('.btn-view');
            viewDetailsButtons.forEach(button => {
                button.addEventListener('click', function(e) {
                    // The href attribute already handles the navigation
                    // This is just for any additional functionality you might want to add
                    console.log('Viewing book details:', this.getAttribute('href').split('=')[1]);
                });
            });
        });
    </script>
</body>
</html>
