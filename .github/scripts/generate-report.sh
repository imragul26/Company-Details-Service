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
REPORT_CONTENT=$(awk '/<main id="bodyColumn">/,/<\/main>/' "$STANDARD_REPORT" | sed '1d;$d')

# Extract test results summary
SUMMARY_TABLE=$(grep -A6 'Summary' "$STANDARD_REPORT" | grep -A5 '<table' | tail -n +2 | head -n 6)
TOTAL_TESTS=$(echo "$SUMMARY_TABLE" | grep -A1 '<tr class="b">' | tail -1 | sed -e 's/<td>//g' -e 's/<\/td>//g' -e 's/^[[:space:]]*//')
ERRORS=$(echo "$SUMMARY_TABLE" | grep -A1 '<tr class="b">' | tail -1 | awk -F'</?td>' '{print $4}')
FAILURES=$(echo "$SUMMARY_TABLE" | grep -A1 '<tr class="b">' | tail -1 | awk -F'</?td>' '{print $6}')
SKIPPED=$(echo "$SUMMARY_TABLE" | grep -A1 '<tr class="b">' | tail -1 | awk -F'</?td>' '{print $8}')
PASSED=$((TOTAL_TESTS - ERRORS - FAILURES - SKIPPED))

# Generate status badge
if [ "$FAILURES" -gt 0 ] || [ "$ERRORS" -gt 0 ]; then
    STATUS_BADGE="<span class='badge failed'>FAILED</span>"
    STATUS_COLOR="#e63946"
else
    STATUS_BADGE="<span class='badge passed'>PASSED</span>"
    STATUS_COLOR="#4CAF50"
fi

# Generate professional HTML report
cat > "$OUTPUT_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Service - Unit Test Report</title>
    <style>
        :root {
            --header-bg: #060667;
            --header-text: #ffffff;
            --accent: #b8ff4e;
            --card-bg: #ffffff;
            --text-primary: #333333;
            --text-secondary: #666666;
            --border: #e0e0e0;
            --shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            --success: #4CAF50;
            --warning: #FFC107;
            --danger: #e63946;
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
            background: linear-gradient(135deg, var(--header-bg) 0%, #0a0a8a 100%);
            color: var(--header-text);
            padding: 40px 0;
            position: relative;
            overflow: hidden;
            text-align: center;
            box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
        }
        
        .header-pattern {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            opacity: 0.1;
            background: 
                radial-gradient(circle at 10% 20%, var(--accent) 0%, transparent 15%),
                radial-gradient(circle at 90% 80%, var(--accent) 0%, transparent 15%);
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
            margin-bottom: 10px;
            letter-spacing: 0.5px;
        }
        
        .report-subtitle {
            font-size: 1.3rem;
            opacity: 0.9;
            max-width: 800px;
            margin: 0 auto 20px;
        }
        
        .status-container {
            display: flex;
            justify-content: center;
            gap: 30px;
            margin: 30px 0;
            flex-wrap: wrap;
        }
        
        .status-card {
            background: rgba(255, 255, 255, 0.15);
            border-radius: 10px;
            padding: 20px 30px;
            min-width: 180px;
            text-align: center;
            backdrop-filter: blur(5px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .status-card h3 {
            font-size: 1.1rem;
            color: rgba(255, 255, 255, 0.85);
            margin-bottom: 10px;
        }
        
        .status-card .value {
            font-size: 2.2rem;
            font-weight: 700;
        }
        
        .total-tests .value { color: white; }
        .passed-tests .value { color: var(--success); }
        .failed-tests .value { color: var(--danger); }
        .skipped-tests .value { color: var(--warning); }
        
        .badge {
            padding: 8px 16px;
            border-radius: 50px;
            font-weight: 600;
            font-size: 1.1rem;
            letter-spacing: 0.5px;
            margin-top: 10px;
            display: inline-block;
        }
        
        .badge.passed {
            background-color: var(--success);
            color: white;
        }
        
        .badge.failed {
            background-color: var(--danger);
            color: white;
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
            padding: 12px 24px;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 10px;
            transition: all 0.3s ease;
            font-size: 1rem;
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
        
        .test-summary {
            background: var(--card-bg);
            border-radius: 15px;
            box-shadow: var(--shadow);
            padding: 30px;
            margin-bottom: 30px;
        }
        
        .summary-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 1px solid var(--border);
        }
        
        .summary-title {
            font-size: 1.5rem;
            color: var(--text-primary);
            font-weight: 600;
        }
        
        .summary-content {
            line-height: 1.8;
            color: var(--text-secondary);
        }
        
        .original-report {
            background: var(--card-bg);
            border-radius: 15px;
            box-shadow: var(--shadow);
            overflow: hidden;
            margin-bottom: 40px;
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
        
        /* Test case status indicators */
        .test-passed {
            color: var(--success);
            font-weight: 600;
        }
        
        .test-failed {
            color: var(--danger);
            font-weight: 600;
        }
        
        .test-skipped {
            color: var(--warning);
            font-weight: 600;
        }
        
        .test-error {
            color: var(--danger);
            font-weight: 600;
        }
        
        .report-footer {
            text-align: center;
            padding: 30px;
            color: var(--text-secondary);
            font-size: 0.95rem;
            border-top: 1px solid var(--border);
            margin-top: 50px;
        }
        
        /* Animation for status cards */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        .status-card {
            animation: fadeIn 0.6s ease forwards;
        }
        
        .status-card:nth-child(1) { animation-delay: 0.1s; }
        .status-card:nth-child(2) { animation-delay: 0.2s; }
        .status-card:nth-child(3) { animation-delay: 0.3s; }
        .status-card:nth-child(4) { animation-delay: 0.4s; }
        
        @media (max-width: 768px) {
            .report-title {
                font-size: 2.2rem;
            }
            
            .status-container {
                gap: 15px;
            }
            
            .status-card {
                min-width: 140px;
                padding: 15px 20px;
            }
            
            .status-card .value {
                font-size: 1.8rem;
            }
            
            .action-btn {
                padding: 10px 18px;
                font-size: 0.9rem;
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
            <h1 class="report-title">Customer Service - Unit Test Report</h1>
            <p class="report-subtitle">Comprehensive Test Execution Summary • $CURRENT_DATE</p>
            
            <div class="status-container">
                <div class="status-card total-tests">
                    <h3>Total Tests</h3>
                    <div class="value">$TOTAL_TESTS</div>
                </div>
                <div class="status-card passed-tests">
                    <h3>Passed</h3>
                    <div class="value">$PASSED</div>
                </div>
                <div class="status-card failed-tests">
                    <h3>Failed</h3>
                    <div class="value">$FAILURES</div>
                </div>
                <div class="status-card skipped-tests">
                    <h3>Skipped</h3>
                    <div class="value">$SKIPPED</div>
                </div>
            </div>
            
            <div style="margin-top: 20px;">
                $STATUS_BADGE
            </div>
            
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
        <div class="test-summary">
            <div class="summary-header">
                <h2 class="summary-title">Test Execution Summary</h2>
                <div class="execution-time">Generated on: $CURRENT_DATE</div>
            </div>
            <div class="summary-content">
                <p>This report provides detailed results of the automated unit tests for the Customer Service API. The test suite covers core functionality including customer creation, retrieval, updates, and validation.</p>
                <p>All tests were executed as part of the CI/CD pipeline with results captured in real-time.</p>
            </div>
        </div>
        
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
    
    <script>
        // Simple script to enhance the report
        document.addEventListener('DOMContentLoaded', function() {
            // Color code test results
            const cells = document.querySelectorAll('td');
            cells.forEach(cell => {
                const text = cell.textContent.trim();
                if (text.includes('FAILURE') || text.includes('Failure')) {
                    cell.classList.add('test-failed');
                } else if (text.includes('SUCCESS') || text.includes('Success')) {
                    cell.classList.add('test-passed');
                } else if (text.includes('SKIPPED') || text.includes('Skipped')) {
                    cell.classList.add('test-skipped');
                } else if (text.includes('ERROR') || text.includes('Error')) {
                    cell.classList.add('test-error');
                }
            });
            
            // Add click handlers for test rows to show more details
            const testRows = document.querySelectorAll('tr');
            testRows.forEach(row => {
                row.addEventListener('click', function() {
                    this.classList.toggle('expanded');
                });
            });
        });
    </script>
</body>
</html>
EOF

echo "Generated enhanced HTML report: $OUTPUT_FILE"