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

# Extract body content from standard report
REPORT_CONTENT=$(awk '/<body>/,/<\/body>/' "$STANDARD_REPORT" | sed '1d;$d')

# Generate professional HTML report
cat > "$OUTPUT_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Service - Enhanced Test Report</title>
    <style>
        :root {
            --header-bg: #000050;
            --header-text: #b8ff4e;
            --accent: #41b6e6;
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
        }
        
        .report-header {
            background: var(--header-bg);
            color: var(--header-text);
            padding: 40px 0;
            position: relative;
            overflow: hidden;
            text-align: center;
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
        
        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            padding: 0 30px;
            position: relative;
            z-index: 2;
        }
        
        .report-title {
            font-size: 2.8rem;
            font-weight: 700;
            margin-bottom: 15px;
            letter-spacing: 0.5px;
        }
        
        .report-subtitle {
            font-size: 1.3rem;
            opacity: 0.9;
            max-width: 800px;
            margin: 0 auto 25px;
        }
        
        .report-actions {
            display: flex;
            justify-content: center;
            gap: 20px;
            margin-top: 30px;
        }
        
        .action-btn {
            background: rgba(184, 255, 78, 0.2);
            color: var(--header-text);
            border: 1px solid rgba(184, 255, 78, 0.4);
            padding: 14px 28px;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s ease;
            font-size: 1.1rem;
        }
        
        .action-btn:hover {
            background: rgba(184, 255, 78, 0.3);
            transform: translateY(-3px);
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.15);
        }
        
        .report-container {
            max-width: 1200px;
            margin: 50px auto;
            padding: 0 30px;
        }
        
        .original-report {
            background: var(--card-bg);
            border-radius: 15px;
            box-shadow: var(--shadow);
            overflow: hidden;
        }
        
        .report-content {
            padding: 40px;
        }
        
        /* Enhancements to original report */
        .report-content .bodyContent {
            padding: 0;
        }
        
        .report-content h1 {
            color: var(--header-bg);
            font-size: 2.2rem;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 3px solid var(--accent);
        }
        
        .report-content h2 {
            color: var(--header-bg);
            font-size: 1.8rem;
            margin: 40px 0 25px;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--border);
        }
        
        .report-content table {
            width: 100%;
            border-collapse: collapse;
            box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
            margin: 25px 0;
            border-radius: 8px;
            overflow: hidden;
        }
        
        .report-content th {
            background-color: var(--header-bg);
            color: var(--header-text);
            text-align: left;
            padding: 16px 20px;
            font-weight: 600;
            font-size: 1.1rem;
        }
        
        .report-content td {
            padding: 14px 20px;
            border-bottom: 1px solid var(--border);
        }
        
        .report-content tr:nth-child(even) {
            background-color: #fcfdff;
        }
        
        .report-content tr:hover {
            background-color: #f5f9ff;
        }
        
        .report-footer {
            text-align: center;
            padding: 30px;
            color: var(--text-secondary);
            font-size: 0.95rem;
            border-top: 1px solid var(--border);
            margin-top: 50px;
        }
        
        @media (max-width: 768px) {
            .report-title {
                font-size: 2.2rem;
            }
            
            .action-btn {
                padding: 12px 20px;
                font-size: 1rem;
            }
            
            .report-content {
                padding: 25px;
            }
            
            .report-content h1 {
                font-size: 1.8rem;
            }
            
            .report-content h2 {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <header class="report-header">
        <div class="header-pattern"></div>
        <div class="header-content">
            <h1 class="report-title">Customer Service Unit Tests</h1>
            <p class="report-subtitle">Enhanced Test Report • $CURRENT_DATE</p>
            
            <div class="report-actions">
                <a href="https://developer.ausiex.com.au/docs/customer-api/b41b5a3efb0a9-introduction" 
                   class="action-btn" 
                   target="_blank">
                    API Documentation
                </a>
                <a href="#" class="action-btn">
                    Download Report
                </a>
            </div>
        </div>
    </header>
    
    <div class="report-container">
        <div class="original-report">
            <div class="report-content">
                $REPORT_CONTENT
            </div>
        </div>
    </div>
    
    <footer class="report-footer">
        <p>Customer Service Unit Test Report • Generated by CI/CD Pipeline</p>
        <p>Confidential - For internal use only</p>
    </footer>
</body>
</html>
EOF

echo "Generated enhanced HTML report: $OUTPUT_FILE"