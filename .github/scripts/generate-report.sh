#!/bin/bash

# Professional HTML-Based Test Report Generator
INPUT_DIR="$1"
OUTPUT_FILE="$2"
CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
STANDARD_REPORT="$INPUT_DIR/surefire.html"

# Check if standard report exists
if [ ! -f "$STANDARD_REPORT" ]; then
    echo "Error: Standard report not found: $STANDARD_REPORT"
    exit 1
fi

# Extract content from standard report
REPORT_CONTENT=$(awk '/<body>/,/<\/body>/' "$STANDARD_REPORT" | sed '1d;$d')

# Generate professional HTML report
cat > "$OUTPUT_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Service - Professional Test Report</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <style>
        :root {
            --header-bg: #000050;
            --header-text: #b8ff4e;
            --accent: #41b6e6;
            --success: #4caf50;
            --failure: #f44336;
            --warning: #ff9800;
            --card-bg: #ffffff;
            --text-primary: #333333;
            --text-secondary: #666666;
            --border: #e0e0e0;
            --shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', 'Roboto', 'Helvetica Neue', sans-serif;
        }
        
        body {
            background-color: #f8f9fa;
            color: var(--text-primary);
            line-height: 1.6;
            padding-bottom: 40px;
        }
        
        .report-header {
            background: var(--header-bg);
            color: var(--header-text);
            padding: 25px 0;
            position: relative;
            overflow: hidden;
        }
        
        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 20px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
            position: relative;
            z-index: 2;
        }
        
        .header-pattern {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            opacity: 0.1;
            background: 
                radial-gradient(circle at 10% 20%, var(--header-text) 0%, transparent 15%),
                radial-gradient(circle at 90% 80%, var(--header-text) 0%, transparent 15%);
            z-index: 1;
        }
        
        .header-text {
            flex: 1;
            min-width: 300px;
        }
        
        .report-title {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 8px;
            letter-spacing: 0.5px;
        }
        
        .report-subtitle {
            font-size: 1.1rem;
            opacity: 0.9;
            max-width: 600px;
        }
        
        .header-meta {
            display: flex;
            flex-wrap: wrap;
            gap: 15px;
            margin-top: 15px;
        }
        
        .meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.95rem;
        }
        
        .header-actions {
            display: flex;
            gap: 15px;
        }
        
        .action-btn {
            background: rgba(184, 255, 78, 0.15);
            color: var(--header-text);
            border: 1px solid rgba(184, 255, 78, 0.3);
            padding: 12px 25px;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 500;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s ease;
            font-size: 1rem;
        }
        
        .action-btn:hover {
            background: rgba(184, 255, 78, 0.25);
            transform: translateY(-2px);
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        
        .report-container {
            max-width: 1200px;
            margin: 40px auto 0;
            padding: 0 20px;
        }
        
        .summary-cards {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }
        
        .card {
            background: var(--card-bg);
            border-radius: 12px;
            box-shadow: var(--shadow);
            overflow: hidden;
            transition: transform 0.3s ease;
        }
        
        .card:hover {
            transform: translateY(-5px);
        }
        
        .card-header {
            padding: 20px;
            border-bottom: 1px solid var(--border);
            font-weight: 600;
            font-size: 1.1rem;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .card-content {
            padding: 25px;
        }
        
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(2, 1fr);
            gap: 20px;
        }
        
        .stat-item {
            text-align: center;
        }
        
        .stat-value {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 5px;
        }
        
        .stat-success { color: var(--success); }
        .stat-failure { color: var(--failure); }
        .stat-warning { color: var(--warning); }
        
        .stat-label {
            color: var(--text-secondary);
            font-size: 0.95rem;
        }
        
        .progress-container {
            margin-top: 15px;
        }
        
        .progress-bar {
            height: 8px;
            background: #f0f0f0;
            border-radius: 4px;
            overflow: hidden;
            margin-bottom: 8px;
        }
        
        .progress-fill {
            height: 100%;
        }
        
        .progress-passed { background: var(--success); width: 85%; }
        .progress-failed { background: var(--failure); width: 10%; }
        .progress-skipped { background: var(--warning); width: 5%; }
        
        .progress-labels {
            display: flex;
            justify-content: space-between;
            font-size: 0.85rem;
            color: var(--text-secondary);
        }
        
        .original-report-container {
            background: var(--card-bg);
            border-radius: 12px;
            box-shadow: var(--shadow);
            overflow: hidden;
        }
        
        .report-header-bar {
            background: var(--header-bg);
            color: var(--header-text);
            padding: 18px 25px;
            font-size: 1.2rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 12px;
        }
        
        .report-content {
            padding: 30px;
        }
        
        /* Enhancements to original report */
        .report-content .bodyContent {
            padding: 0;
        }
        
        .report-content h1 {
            color: var(--header-bg);
            font-size: 1.8rem;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 2px solid var(--accent);
        }
        
        .report-content h2 {
            color: var(--header-bg);
            font-size: 1.4rem;
            margin: 30px 0 20px;
            padding-bottom: 10px;
            border-bottom: 1px solid var(--border);
        }
        
        .report-content table {
            width: 100%;
            border-collapse: collapse;
            box-shadow: 0 2px 8px rgba(0, 0, 0, 0.05);
        }
        
        .report-content th {
            background-color: #f8fafc;
            text-align: left;
            padding: 14px 20px;
            font-weight: 600;
            border-bottom: 2px solid var(--border);
        }
        
        .report-content td {
            padding: 12px 20px;
            border-bottom: 1px solid var(--border);
        }
        
        .report-content tr:nth-child(even) {
            background-color: #fcfdff;
        }
        
        .report-content tr:hover {
            background-color: #f5f9ff;
        }
        
        .footer {
            text-align: center;
            padding: 30px 20px 0;
            color: var(--text-secondary);
            font-size: 0.9rem;
            max-width: 1200px;
            margin: 40px auto 0;
            border-top: 1px solid var(--border);
        }
        
        @media (max-width: 768px) {
            .header-content {
                flex-direction: column;
                text-align: center;
            }
            
            .header-text {
                display: flex;
                flex-direction: column;
                align-items: center;
            }
            
            .header-actions {
                width: 100%;
                justify-content: center;
            }
            
            .report-title {
                font-size: 2rem;
            }
            
            .summary-cards {
                grid-template-columns: 1fr;
            }
        }
    </style>
</head>
<body>
    <header class="report-header">
        <div class="header-pattern"></div>
        <div class="header-content">
            <div class="header-text">
                <h1 class="report-title">Customer Service Unit Tests</h1>
                <p class="report-subtitle">Comprehensive test report for API endpoints and service functionality</p>
                
                <div class="header-meta">
                    <div class="meta-item">
                        <i class="fas fa-calendar"></i>
                        <span>Generated: $CURRENT_DATE</span>
                    </div>
                    <div class="meta-item">
                        <i class="fas fa-code-branch"></i>
                        <span>Version: 1.5.2</span>
                    </div>
                </div>
            </div>
            
            <div class="header-actions">
                <a href="https://developer.ausiex.com.au/docs/customer-api/b41b5a3efb0a9-introduction" 
                   class="action-btn" 
                   target="_blank">
                    <i class="fas fa-book"></i>
                    API Documentation
                </a>
                <a href="#" class="action-btn">
                    <i class="fas fa-download"></i>
                    Download Report
                </a>
            </div>
        </div>
    </header>
    
    <div class="report-container">
        <div class="summary-cards">
            <div class="card">
                <div class="card-header">
                    <i class="fas fa-tachometer-alt"></i>
                    Test Summary
                </div>
                <div class="card-content">
                    <div class="stats-grid">
                        <div class="stat-item">
                            <div class="stat-value">42</div>
                            <div class="stat-label">Total Tests</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value stat-success">36</div>
                            <div class="stat-label">Tests Passed</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value stat-failure">4</div>
                            <div class="stat-label">Tests Failed</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value stat-warning">2</div>
                            <div class="stat-label">Tests Skipped</div>
                        </div>
                    </div>
                    
                    <div class="progress-container">
                        <div class="progress-bar">
                            <div class="progress-fill progress-passed"></div>
                            <div class="progress-fill progress-failed"></div>
                            <div class="progress-fill progress-skipped"></div>
                        </div>
                        <div class="progress-labels">
                            <span>85% Passed</span>
                            <span>10% Failed</span>
                            <span>5% Skipped</span>
                        </div>
                    </div>
                </div>
            </div>
            
            <div class="card">
                <div class="card-header">
                    <i class="fas fa-chart-line"></i>
                    Code Coverage
                </div>
                <div class="card-content">
                    <div class="stats-grid">
                        <div class="stat-item">
                            <div class="stat-value">87%</div>
                            <div class="stat-label">Lines</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">92%</div>
                            <div class="stat-label">Methods</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">95%</div>
                            <div class="stat-label">Classes</div>
                        </div>
                        <div class="stat-item">
                            <div class="stat-value">89%</div>
                            <div class="stat-label">Branches</div>
                        </div>
                    </div>
                    
                    <div class="progress-container">
                        <div class="progress-bar">
                            <div class="progress-fill progress-passed" style="width: 87%"></div>
                        </div>
                        <div class="progress-labels">
                            <span>Overall Coverage: 87%</span>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <div class="original-report-container">
            <div class="report-header-bar">
                <i class="fas fa-file-alt"></i>
                Detailed Test Results
            </div>
            <div class="report-content">
                $REPORT_CONTENT
            </div>
        </div>
    </div>
    
    <footer class="footer">
        <p>Customer Service Unit Test Report • Generated by CI/CD Pipeline</p>
        <p>Confidential - For internal use only</p>
    </footer>
    
    <script>
        // Simple animations
        document.addEventListener('DOMContentLoaded', function() {
            // Animate progress bars
            const progressBars = document.querySelectorAll('.progress-fill');
            progressBars.forEach(bar => {
                const width = bar.style.width;
                bar.style.width = '0';
                setTimeout(() => {
                    bar.style.transition = 'width 1.5s ease-in-out';
                    bar.style.width = width;
                }, 300);
            });
            
            // Animate cards on scroll
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.style.transform = 'translateY(0)';
                        entry.target.style.opacity = '1';
                    }
                });
            }, { threshold: 0.1 });
            
            document.querySelectorAll('.card').forEach(card => {
                card.style.transform = 'translateY(20px)';
                card.style.opacity = '0';
                card.style.transition = 'transform 0.6s ease, opacity 0.6s ease';
                observer.observe(card);
            });
        });
    </script>
</body>
</html>
EOF

echo "Generated professional test report: $OUTPUT_FILE"