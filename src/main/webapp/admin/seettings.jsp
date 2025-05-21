<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="mode.User" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Settings - E-Library Hub</title>
    <link rel="stylesheet" href="../css/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.19/dist/sweetalert2.min.css">
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11.0.19/dist/sweetalert2.all.min.js"></script>
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
            padding: 0;
            margin: 0;
        }
        
        .sidebar-menu li {
            margin-bottom: 5px;
        }
        
        .sidebar-menu a {
            display: flex;
            align-items: center;
            padding: 10px 20px;
            color: rgba(255, 255, 255, 0.7);
            text-decoration: none;
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
            margin: 0;
        }
        
        .settings-container {
            background-color: white;
            border-radius: 8px;
            padding: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.1);
        }
        
        .settings-tabs {
            display: flex;
            border-bottom: 1px solid #e0e0e0;
            margin-bottom: 20px;
        }
        
        .settings-tab {
            padding: 10px 20px;
            cursor: pointer;
            border-bottom: 2px solid transparent;
            transition: all 0.3s ease;
        }
        
        .settings-tab.active {
            border-bottom-color: #3498db;
            color: #3498db;
        }
        
        .settings-content {
            display: none;
        }
        
        .settings-content.active {
            display: block;
        }
        
        .form-group {
            margin-bottom: 20px;
        }
        
        .form-group label {
            display: block;
            margin-bottom: 5px;
            font-weight: 600;
        }
        
        .form-group input, .form-group select, .form-group textarea {
            width: 100%;
            padding: 10px;
            border: 1px solid #e0e0e0;
            border-radius: 4px;
            font-size: 14px;
        }
        
        .form-group textarea {
            height: 100px;
            resize: vertical;
        }
        
        .form-actions {
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            margin-top: 20px;
        }
        
        .btn-primary {
            background-color: #3498db;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
        }
        
        .btn-primary:hover {
            background-color: #2980b9;
        }
        
        .btn-secondary {
            background-color: #95a5a6;
            color: white;
            border: none;
            padding: 10px 20px;
            border-radius: 4px;
            cursor: pointer;
            font-size: 14px;
            transition: background-color 0.3s;
        }
        
        .btn-secondary:hover {
            background-color: #7f8c8d;
        }
        
        .switch {
            position: relative;
            display: inline-block;
            width: 60px;
            height: 34px;
        }
        
        .switch input {
            opacity: 0;
            width: 0;
            height: 0;
        }
        
        .slider {
            position: absolute;
            cursor: pointer;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background-color: #ccc;
            transition: .4s;
            border-radius: 34px;
        }
        
        .slider:before {
            position: absolute;
            content: "";
            height: 26px;
            width: 26px;
            left: 4px;
            bottom: 4px;
            background-color: white;
            transition: .4s;
            border-radius: 50%;
        }
        
        input:checked + .slider {
            background-color: #3498db;
        }
        
        input:checked + .slider:before {
            transform: translateX(26px);
        }
        
        .toggle-container {
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .toggle-label {
            font-weight: 600;
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
                <li><a href="authors.jsp"><i class="fas fa-user-edit"></i> Authors</a></li>
                <li><a href="categories.jsp"><i class="fas fa-tags"></i> Categories</a></li>
                <li><a href="reports.jsp"><i class="fas fa-chart-bar"></i> Reports</a></li>
                <li><a href="settings.jsp" class="active"><i class="fas fa-cog"></i> Settings</a></li>
                <li><a href="../LogoutServlet"><i class="fas fa-sign-out-alt"></i> Logout</a></li>
            </ul>
        </aside>
        
        <main class="main-content">
            <div class="page-header">
                <h1 class="page-title">Settings</h1>
            </div>
            
            <div class="settings-container">
                <div class="settings-tabs">
                    <div class="settings-tab active" data-tab="general">General</div>
                    <div class="settings-tab" data-tab="email">Email</div>
                    <div class="settings-tab" data-tab="security">Security</div>
                    <div class="settings-tab" data-tab="backup">Backup & Restore</div>
                </div>
                
                <div class="settings-content active" id="general-settings">
                    <form id="generalSettingsForm">
                        <div class="form-group">
                            <label for="siteName">Site Name</label>
                            <input type="text" id="siteName" name="siteName" value="E-Library Hub">
                        </div>
                        <div class="form-group">
                            <label for="siteDescription">Site Description</label>
                            <textarea id="siteDescription" name="siteDescription">A digital library platform for readers and authors.</textarea>
                        </div>
                        <div class="form-group">
                            <label for="itemsPerPage">Items Per Page</label>
                            <select id="itemsPerPage" name="itemsPerPage">
                                <option value="10">10</option>
                                <option value="20" selected>20</option>
                                <option value="50">50</option>
                                <option value="100">100</option>
                            </select>
                        </div>
                        <div class="form-group">
                            <div class="toggle-container">
                                <span class="toggle-label">Maintenance Mode</span>
                                <label class="switch">
                                    <input type="checkbox" id="maintenanceMode" name="maintenanceMode">
                                    <span class="slider"></span>
                                </label>
                            </div>
                        </div>
                        <div class="form-actions">
                            <button type="submit" class="btn-primary">Save Changes</button>
                        </div>
                    </form>
                </div>
                
                <div class="settings-content" id="email-settings">
                    <form id="emailSettingsForm">
                        <div class="form-group">
                            <label for="smtpServer">SMTP Server</label>
                            <input type="text" id="smtpServer" name="smtpServer" value="smtp.example.com">
                        </div>
                        <div class="form-group">
                            <label for="smtpPort">SMTP Port</label>
                            <input type="number" id="smtpPort" name="smtpPort" value="587">
                        </div>
                        <div class="form-group">
                            <label for="smtpUsername">SMTP Username</label>
                            <input type="text" id="smtpUsername" name="smtpUsername" value="admin@example.com">
                        </div>
                        <div class="form-group">
                            <label for="smtpPassword">SMTP Password</label>
                            <input type="password" id="smtpPassword" name="smtpPassword" value="********">
                        </div>
                        <div class="form-group">
                            <label for="fromEmail">From Email</label>
                            <input type="email" id="fromEmail" name="fromEmail" value="noreply@elibraryhub.com">
                        </div>
                        <div class="form-group">
                            <div class="toggle-container">
                                <span class="toggle-label">Enable Email Notifications</span>
                                <label class="switch">
                                    <input type="checkbox" id="enableEmailNotifications" name="enableEmailNotifications" checked>
                                    <span class="slider"></span>
                                </label>
                            </div>
                        </div>
                        <div class="form-actions">
                            <button type="button" class="btn-secondary" id="testEmailBtn">Test Email</button>
                            <button type="submit" class="btn-primary">Save Changes</button>
                        </div>
                    </form>
                </div>
                
                <div class="settings-content" id="security-settings">
                    <form id="securitySettingsForm">
                        <div class="form-group">
                            <div class="toggle-container">
                                <span class="toggle-label">Enable Two-Factor Authentication</span>
                                <label class="switch">
                                    <input type="checkbox" id="enable2FA" name="enable2FA">
                                    <span class="slider"></span>
                                </label>
                            </div>
                        </div>
                        <div class="form-group">
                            <label for="sessionTimeout">Session Timeout (minutes)</label>
                            <input type="number" id="sessionTimeout" name="sessionTimeout" value="30">
                        </div>
                        <div class="form-group">
                            <label for="maxLoginAttempts">Max Login Attempts</label>
                            <input type="number" id="maxLoginAttempts" name="maxLoginAttempts" value="5">
                        </div>
                        <div class="form-group">
                            <div class="toggle-container">
                                <span class="toggle-label">Enable CAPTCHA</span>
                                <label class="switch">
                                    <input type="checkbox" id="enableCaptcha" name="enableCaptcha" checked>
                                    <span class="slider"></span>
                                </label>
                            </div>
                        </div>
                        <div class="form-actions">
                            <button type="submit" class="btn-primary">Save Changes</button>
                        </div>
                    </form>
                </div>
                
                <div class="settings-content" id="backup-settings">
                    <div class="form-group">
                        <h3>Database Backup</h3>
                        <p>Create a backup of your database or restore from a previous backup.</p>
                    </div>
                    <div class="form-actions">
                        <button type="button" class="btn-secondary" id="createBackupBtn">Create Backup</button>
                        <button type="button" class="btn-primary" id="restoreBackupBtn">Restore Backup</button>
                    </div>
                    
                    <div class="form-group" style="margin-top: 30px;">
                        <h3>Scheduled Backups</h3>
                        <div class="toggle-container">
                            <span class="toggle-label">Enable Scheduled Backups</span>
                            <label class="switch">
                                <input type="checkbox" id="enableScheduledBackups" name="enableScheduledBackups" checked>
                                <span class="slider"></span>
                            </label>
                        </div>
                    </div>
                    <div class="form-group">
                        <label for="backupFrequency">Backup Frequency</label>
                        <select id="backupFrequency" name="backupFrequency">
                            <option value="daily">Daily</option>
                            <option value="weekly" selected>Weekly</option>
                            <option value="monthly">Monthly</option>
                        </select>
                    </div>
                    <div class="form-group">
                        <label for="backupRetention">Backup Retention (days)</label>
                        <input type="number" id="backupRetention" name="backupRetention" value="30">
                    </div>
                    <div class="form-actions">
                        <button type="button" class="btn-primary" id="saveBackupSettingsBtn">Save Backup Settings</button>
                    </div>
                </div>
            </div>
        </main>
    </div>

    <script>
        // Mobile menu toggle
        document.querySelector('.mobile-menu-toggle').addEventListener('click', function() {
            document.querySelector('.main-nav').classList.toggle('active');
        });
        
        // Settings tabs
        document.querySelectorAll('.settings-tab').forEach(tab => {
            tab.addEventListener('click', function() {
                // Remove active class from all tabs and content
                document.querySelectorAll('.settings-tab').forEach(t => t.classList.remove('active'));
                document.querySelectorAll('.settings-content').forEach(c => c.classList.remove('active'));
                
                // Add active class to clicked tab and corresponding content
                this.classList.add('active');
                document.getElementById(this.dataset.tab + '-settings').classList.add('active');
            });
        });
        
        // Form submissions
        document.getElementById('generalSettingsForm').addEventListener('submit', function(e) {
            e.preventDefault();
            saveSettings('general');
        });
        
        document.getElementById('emailSettingsForm').addEventListener('submit', function(e) {
            e.preventDefault();
            saveSettings('email');
        });
        
        document.getElementById('securitySettingsForm').addEventListener('submit', function(e) {
            e.preventDefault();
            saveSettings('security');
        });
        
        // Test email button
        document.getElementById('testEmailBtn').addEventListener('click', function() {
            Swal.fire({
                title: 'Send Test Email',
                input: 'email',
                inputLabel: 'Email address',
                inputPlaceholder: 'Enter your email address',
                showCancelButton: true,
                confirmButtonText: 'Send',
                showLoaderOnConfirm: true,
                preConfirm: (email) => {
                    return fetch('../AdminSettingsServlet?action=testEmail&email=' + email)
                        .then(response => {
                            if (!response.ok) {
                                throw new Error('Network response was not ok');
                            }
                            return response.json();
                        })
                        .catch(error => {
                            Swal.showValidationMessage('Request failed: ' + error);
                        });
                },
                allowOutsideClick: () => !Swal.isLoading()
            }).then((result) => {
                if (result.isConfirmed) {
                    Swal.fire({
                        title: 'Success!',
                        text: 'Test email sent successfully.',
                        icon: 'success'
                    });
                }
            });
        });
        
        // Backup buttons
        document.getElementById('createBackupBtn').addEventListener('click', function() {
            Swal.fire({
                title: 'Create Backup',
                text: 'Are you sure you want to create a database backup?',
                icon: 'question',
                showCancelButton: true,
                confirmButtonText: 'Yes, create it!',
                showLoaderOnConfirm: true,
                preConfirm: () => {
                    return fetch('../AdminSettingsServlet?action=createBackup')
                        .then(response => {
                            if (!response.ok) {
                                throw new Error('Network response was not ok');
                            }
                            return response.json();
                        })
                        .catch(error => {
                            Swal.showValidationMessage('Request failed: ' + error);
                        });
                },
                allowOutsideClick: () => !Swal.isLoading()
            }).then((result) => {
                if (result.isConfirmed) {
                    Swal.fire({
                        title: 'Success!',
                        text: 'Backup created successfully.',
                        icon: 'success'
                    });
                }
            });
        });
        
        document.getElementById('restoreBackupBtn').addEventListener('click', function() {
            // This would typically show a list of available backups to restore from
            Swal.fire({
                title: 'Restore Backup',
                text: 'This feature is not yet implemented.',
                icon: 'info'
            });
        });
        
        document.getElementById('saveBackupSettingsBtn').addEventListener('click', function() {
            saveSettings('backup');
        });
        
        // Save settings function
        function saveSettings(settingsType) {
            let formData = new FormData();
            
            switch (settingsType) {
                case 'general':
                    formData.append('siteName', document.getElementById('siteName').value);
                    formData.append('siteDescription', document.getElementById('siteDescription').value);
                    formData.append('itemsPerPage', document.getElementById('itemsPerPage').value);
                    formData.append('maintenanceMode', document.getElementById('maintenanceMode').checked);
                    break;
                case 'email':
                    formData.append('smtpServer', document.getElementById('smtpServer').value);
                    formData.append('smtpPort', document.getElementById('smtpPort').value);
                    formData.append('smtpUsername', document.getElementById('smtpUsername').value);
                    formData.append('smtpPassword', document.getElementById('smtpPassword').value);
                    formData.append('fromEmail', document.getElementById('fromEmail').value);
                    formData.append('enableEmailNotifications', document.getElementById('enableEmailNotifications').checked);
                    break;
                case 'security':
                    formData.append('enable2FA', document.getElementById('enable2FA').checked);
                    formData.append('sessionTimeout', document.getElementById('sessionTimeout').value);
                    formData.append('maxLoginAttempts', document.getElementById('maxLoginAttempts').value);
                    formData.append('enableCaptcha', document.getElementById('enableCaptcha').checked);
                    break;
                case 'backup':
                    formData.append('enableScheduledBackups', document.getElementById('enableScheduledBackups').checked);
                    formData.append('backupFrequency', document.getElementById('backupFrequency').value);
                    formData.append('backupRetention', document.getElementById('backupRetention').value);
                    break;
            }
            
            fetch('../AdminSettingsServlet?action=saveSettings&type=' + settingsType, {
                method: 'POST',
                body: formData
            })
            .then(response => {
                if (!response.ok) {
                    throw new Error('Network response was not ok');
                }
                return response.text();
            })
            .then(data => {
                try {
                    const result = JSON.parse(data);
                    if (result.success) {
                        Swal.fire({
                            title: 'Success!',
                            text: 'Settings saved successfully.',
                            icon: 'success'
                        });
                    } else {
                        Swal.fire({
                            title: 'Error!',
                            text: result.message || 'Failed to save settings.',
                            icon: 'error'
                        });
                    }
                } catch (e) {
                    // Handle non-JSON response
                    if (data.includes('success') || data.includes('Success')) {
                        Swal.fire({
                            title: 'Success!',
                            text: 'Settings saved successfully.',
                            icon: 'success'
                        });
                    } else {
                        Swal.fire({
                            title: 'Error!',
                            text: 'An unexpected error occurred.',
                            icon: 'error'
                        });
                    }
                }
            })
            .catch(error => {
                console.error('Error:', error);
                Swal.fire({
                    title: 'Error!',
                    text: 'An error occurred while saving settings.',
                    icon: 'error'
                });
            });
        }
    </script>
</body>
</html>
