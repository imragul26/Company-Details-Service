#!/bin/bash

# HTML-Based Enhanced Test Report Generator
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

# Generate enhanced HTML report with custom UI
cat > "$OUTPUT_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Service - Enhanced Test Report</title>
    <style>
        :root {
            --heading-bg: #000050;
            --text-color: #b8ff4e;
            --accent-color: #41b6e6;
        }
        
        body {
            margin: 0;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background-color: #f0f4f8;
            color: #333;
            line-height: 1.6;
        }
        
        .custom-header {
            background: var(--heading-bg);
            color: var(--text-color);
            padding: 30px 40px;
        }
        
        .header-content {
            max-width: 1200px;
            margin: 0 auto;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .report-title {
            font-size: 32px;
            margin: 0;
        }
        
        .report-subtitle {
            font-size: 18px;
            opacity: 0.9;
        }
        
        .action-btn {
            background: rgba(184, 255, 78, 0.15);
            color: var(--text-color);
            border: 1px solid rgba(184, 255, 78, 0.3);
            padding: 10px 20px;
            border-radius: 30px;
            text-decoration: none;
            font-weight: 500;
            transition: all 0.3s ease;
        }
        
        .action-btn:hover {
            background: rgba(184, 255, 78, 0.25);
        }
        
        .report-container {
            max-width: 1200px;
            margin: 30px auto;
            padding: 0 20px;
        }
        
        .original-report {
            background: white;
            border-radius: 10px;
            box-shadow: 0 5px 15px rgba(0, 0, 0, 0.05);
            overflow: hidden;
        }
        
        /* Enhancements to original report styling */
        .original-report .bodyContent {
            padding: 20px;
        }
        
        .original-report h1 {
            color: #000050;
            border-bottom: 2px solid #41b6e6;
            padding-bottom: 10px;
        }
        
        .original-report table {
            border-collapse: collapse;
            width: 100%;
        }
        
        .original-report th {
            background-color: #f0f4f8;
        }
        
        .original-report tr:nth-child(even) {
            background-color: #fafafa;
        }
        
        @media (max-width: 768px) {
            .header-content {
                flex-direction: column;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <header class="custom-header">
        <div class="header-content">
            <div>
                <h1 class="report-title">Customer Service Unit Tests</h1>
                <p class="report-subtitle">Enhanced Report • $CURRENT_DATE</p>
            </div>
            <a href="https://developer.ausiex.com.au/docs/customer-api/b41b5a3efb0a9-introduction" 
               class="action-btn" 
               target="_blank">
                API Documentation
            </a>
        </div>
    </header>
    
    <div class="report-container">
        <div class="original-report">
            $REPORT_CONTENT
        </div>
    </div>
    
    <footer style="text-align: center; padding: 20px; color: #666;">
        <p>Report generated using standard Surefire report with enhanced UI</p>
    </footer>
</body>
</html>
EOF

echo "Generated HTML-enhanced report: $OUTPUT_FILE"