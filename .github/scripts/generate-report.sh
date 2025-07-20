#!/bin/bash

# Enhanced HTML Test Report Generator with XML data and full UI
INPUT_DIR="$1"
OUTPUT_FILE="$2"
CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
STANDARD_REPORT="target/reports/surefire.html"

# 1. Get accurate test counts from XML
SUREFIRE_XML=$(find "$INPUT_DIR" -name "TEST-*.xml" | head -1)

# Initialize counts
TOTAL_TESTS=0 FAILURES=0 ERRORS=0 SKIPPED=0 TIME=0

if [ -f "$SUREFIRE_XML" ]; then
    while read -r line; do
        case $line in
            *"testsuite"*)
                TOTAL_TESTS=$(echo "$line" | grep -o 'tests="[0-9]*"' | cut -d'"' -f2)
                FAILURES=$(echo "$line" | grep -o 'failures="[0-9]*"' | cut -d'"' -f2)
                ERRORS=$(echo "$line" | grep -o 'errors="[0-9]*"' | cut -d'"' -f2)
                SKIPPED=$(echo "$line" | grep -o 'skipped="[0-9]*"' | cut -d'"' -f2)
                TIME=$(echo "$line" | grep -o 'time="[0-9.]*"' | cut -d'"' -f2)
                break
                ;;
        esac
    done < "$SUREFIRE_XML"
fi

# Default values if parsing fails
TOTAL_TESTS=${TOTAL_TESTS:-0}
FAILURES=${FAILURES:-0}
ERRORS=${ERRORS:-0}
SKIPPED=${SKIPPED:-0}
TIME=${TIME:-0}
PASSED=$((TOTAL_TESTS - FAILURES - ERRORS - SKIPPED))

# 2. Get HTML report content
REPORT_CONTENT=""
if [ -f "$STANDARD_REPORT" ]; then
    REPORT_CONTENT=$(awk '/<main id="bodyColumn">/,/<\/main>/' "$STANDARD_REPORT" | sed '1d;$d')
else
    REPORT_CONTENT="<div class='report-warning'>
        <i class='fas fa-exclamation-triangle'></i>
        Detailed test report not generated (run 'mvn site' first)
    </div>"
fi

# Generate status badge
if [ "$FAILURES" -gt 0 ] || [ "$ERRORS" -gt 0 ]; then
    STATUS_BADGE="<span class='badge failed'>FAILED</span>"
    STATUS_COLOR="#e63946"
else
    STATUS_BADGE="<span class='badge passed'>PASSED</span>"
    STATUS_COLOR="#4CAF50"
fi

# Generate FULL enhanced report
cat > "$OUTPUT_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Service - Unit Test Report</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
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
        
        /* [ALL YOUR PREVIOUS CSS STYLES HERE - TRUNCATED FOR BREVITY] */
        
        .report-warning {
            background: #FFF3E0;
            border-left: 4px solid var(--warning);
            padding: 20px;
            margin: 20px 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        /* [REST OF YOUR ORIGINAL STYLES] */
    </style>
</head>
<body>
    <header class="report-header">
        <div class="header-pattern"></div>
        <div class="header-content">
            <h1 class="report-title">Customer Service - Unit Test Report</h1>
            <p class="report-subtitle">Test Execution Summary • $CURRENT_DATE</p>
            
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
                    <i class="fas fa-book"></i> API Documentation
                </a>
            </div>
        </div>
    </header>
    
    <div class="report-container">
        <div class="test-summary">
            <div class="summary-header">
                <h2 class="summary-title">Test Execution Details</h2>
                <div class="execution-time">Total Duration: ${TIME}s</div>
            </div>
            <div class="summary-content">
                <p>Unit test execution completed with the above results.</p>
            </div>
        </div>
        
        <div class="original-report">
            <div class="report-content">
                $REPORT_CONTENT
            </div>
        </div>
    </div>
    
    <footer class="report-footer">
        <p><i class="fas fa-code-branch"></i> Generated by CI/CD Pipeline • Customer Service Team</p>
        <p><i class="fas fa-lock"></i> Confidential - For internal use only</p>
    </footer>
    
    <script>
        // Color code test results
        document.addEventListener('DOMContentLoaded', function() {
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
        });
    </script>
</body>
</html>
EOF

echo "Generated enhanced HTML report: $OUTPUT_FILE"