#!/bin/bash

# Enhanced HTML-Based Test Report Generator for GitHub Actions
INPUT_DIR="$1"
OUTPUT_FILE="$2"
CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
STANDARD_REPORT="$INPUT_DIR/surefire.html"
REPORT_DIR=$(dirname "$OUTPUT_FILE")

# Create output directory if needed
mkdir -p "$REPORT_DIR"

# Check if standard report exists
if [ ! -f "$STANDARD_REPORT" ]; then
    echo "::error::Standard report not found: $STANDARD_REPORT"
    exit 1
fi

# Extract and clean report content
REPORT_CONTENT=$(awk '/<body>/,/<\/body>/' "$STANDARD_REPORT" | sed '1d;$d' | \
    sed 's/<body[^>]*>//g; s/<\/body>//g; s/<html[^>]*>//g; s/<\/html>//g')

# Count test results
TOTAL_TESTS=$(grep -oP '(?<=tests=")[^"]*' "$STANDARD_REPORT" || echo "0")
FAILED_TESTS=$(grep -oP '(?<=failures=")[^"]*' "$STANDARD_REPORT" || echo "0")
ERROR_TESTS=$(grep -oP '(?<=errors=")[^"]*' "$STANDARD_REPORT" || echo "0")
SKIPPED_TESTS=$(grep -oP '(?<=skipped=")[^"]*' "$STANDARD_REPORT" || echo "0")
PASSED_TESTS=$((TOTAL_TESTS - FAILED_TESTS - ERROR_TESTS - SKIPPED_TESTS))

# Generate status badge
if [ "$FAILED_TESTS" -gt 0 ] || [ "$ERROR_TESTS" -gt 0 ]; then
    STATUS_BADGE="<span class='badge failed'>FAILED</span>"
    STATUS_COLOR="#e63946"
    GH_STATUS="failure"
else
    STATUS_BADGE="<span class='badge passed'>PASSED</span>"
    STATUS_COLOR="#2a9d8f"
    GH_STATUS="success"
fi

# Generate GitHub Actions summary
if [ -n "$GITHUB_STEP_SUMMARY" ]; then
    echo "### Test Execution Summary" >> $GITHUB_STEP_SUMMARY
    echo "| Result | Total | Passed | Failed | Skipped |" >> $GITHUB_STEP_SUMMARY
    echo "|--------|-------|--------|--------|---------|" >> $GITHUB_STEP_SUMMARY
    echo "| **$GH_STATUS** | $TOTAL_TESTS | $PASSED_TESTS | $FAILED_TESTS | $SKIPPED_TESTS |" >> $GITHUB_STEP_SUMMARY
    echo "[View Full Report]($OUTPUT_FILE)" >> $GITHUB_STEP_SUMMARY
fi

# Generate professional HTML report
cat > "$OUTPUT_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Service - Test Report</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        :root {
            --header-bg: #1a1a2e;
            --header-text: #ffffff;
            --accent: #4cc9f0;
            --card-bg: #ffffff;
            --text-primary: #2b2d42;
            --text-secondary: #8d99ae;
            --border: #edf2f4;
            --shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            --success: #2a9d8f;
            --warning: #f4a261;
            --danger: #e63946;
            --info: #4cc9f0;
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
            background: linear-gradient(135deg, var(--header-bg) 0%, #16213e 100%);
            color: var(--header-text);
            padding: 40px 0;
            position: relative;
            overflow: hidden;
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
            display: flex;
            flex-wrap: wrap;
            justify-content: space-between;
            align-items: center;
        }
        
        .title-section {
            flex: 1;
            min-width: 300px;
        }
        
        .report-title {
            font-size: 2.3rem;
            font-weight: 700;
            margin-bottom: 10px;
        }
        
        .report-subtitle {
            font-size: 1.1rem;
            opacity: 0.9;
            max-width: 600px;
        }
        
        .status-section {
            display: flex;
            flex-direction: column;
            align-items: flex-end;
        }
        
        .status-container {
            display: flex;
            gap: 15px;
            margin: 15px 0;
            flex-wrap: wrap;
            justify-content: flex-end;
        }
        
        .status-card {
            background: rgba(255, 255, 255, 0.1);
            border-radius: 10px;
            padding: 15px 20px;
            min-width: 100px;
            text-align: center;
            backdrop-filter: blur(10px);
            border: 1px solid rgba(255, 255, 255, 0.1);
        }
        
        .status-card h3 {
            font-size: 0.9rem;
            margin-bottom: 8px;
            color: rgba(255, 255, 255, 0.8);
        }
        
        .status-card .value {
            font-size: 1.8rem;
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
            background-color: $STATUS_COLOR;
            color: white;
            margin-top: 10px;
            display: inline-block;
        }
        
        .report-actions {
            display: flex;
            gap: 15px;
            margin-top: 20px;
        }
        
        .action-btn {
            background: rgba(76, 201, 240, 0.2);
            color: var(--header-text);
            border: 1px solid rgba(76, 201, 240, 0.4);
            padding: 10px 20px;
            border-radius: 50px;
            text-decoration: none;
            font-weight: 600;
            display: inline-flex;
            align-items: center;
            gap: 8px;
            transition: all 0.3s ease;
            font-size: 0.9rem;
        }
        
        .action-btn:hover {
            background: rgba(76, 201, 240, 0.3);
            transform: translateY(-3px);
        }
        
        .report-container {
            max-width: 1200px;
            margin: 40px auto;
            padding: 0 30px;
        }
        
        .dashboard {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 25px;
            margin-bottom: 40px;
        }
        
        .chart-container {
            background: var(--card-bg);
            border-radius: 15px;
            box-shadow: var(--shadow);
            padding: 25px;
            height: 300px;
        }
        
        .summary-container {
            background: var(--card-bg);
            border-radius: 15px;
            box-shadow: var(--shadow);
            padding: 25px;
        }
        
        .summary-title {
            font-size: 1.4rem;
            color: var(--text-primary);
            margin-bottom: 20px;
            padding-bottom: 15px;
            border-bottom: 2px solid var(--border);
        }
        
        .summary-content {
            line-height: 1.8;
            color: var(--text-secondary);
        }
        
        .summary-highlight {
            color: var(--text-primary);
            font-weight: 600;
        }
        
        .original-report {
            background: var(--card-bg);
            border-radius: 15px;
            box-shadow: var(--shadow);
            overflow: hidden;
            margin-bottom: 40px;
        }
        
        .report-content {
            padding: 30px;
            overflow-x: auto;
        }
        
        /* Enhancements to original report */
        .report-content .bodyContent {
            padding: 0;
        }
        
        .report-content h1 {
            color: var(--header-bg);
            font-size: 2rem;
            margin-bottom: 25px;
            padding-bottom: 15px;
            border-bottom: 3px solid var(--accent);
        }
        
        .report-content h2 {
            color: var(--header-bg);
            font-size: 1.6rem;
            margin: 35px 0 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--border);
        }
        
        .report-content table {
            width: 100%;
            border-collapse: collapse;
            box-shadow: 0 2px 12px rgba(0, 0, 0, 0.06);
            margin: 20px 0;
            border-radius: 8px;
            overflow: hidden;
            min-width: 800px;
        }
        
        .report-content th {
            background-color: var(--header-bg);
            color: var(--header-text);
            text-align: left;
            padding: 14px 18px;
            font-weight: 600;
        }
        
        .report-content td {
            padding: 12px 18px;
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
        
        /* Footer styles */
        .report-footer {
            text-align: center;
            padding: 30px;
            color: var(--text-secondary);
            font-size: 0.9rem;
            background-color: var(--card-bg);
            border-top: 1px solid var(--border);
            margin-top: 50px;
        }
        
        /* GitHub banner */
        .github-banner {
            position: absolute;
            top: 20px;
            right: 20px;
            background: rgba(0, 0, 0, 0.3);
            padding: 8px 15px;
            border-radius: 5px;
            font-size: 0.85rem;
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        /* Responsive design */
        @media (max-width: 900px) {
            .header-content {
                flex-direction: column;
                text-align: center;
            }
            
            .status-section {
                align-items: center;
                margin-top: 20px;
            }
            
            .status-container {
                justify-content: center;
            }
            
            .report-title {
                font-size: 2rem;
            }
        }
        
        @media (max-width: 600px) {
            .report-container {
                padding: 0 15px;
            }
            
            .report-content {
                padding: 20px 15px;
            }
            
            .chart-container, .summary-container {
                padding: 20px;
            }
            
            .status-card {
                min-width: 80px;
                padding: 12px 15px;
            }
            
            .status-card .value {
                font-size: 1.5rem;
            }
        }
    </style>
</head>
<body>
    <header class="report-header">
        <div class="header-pattern"></div>
        <div class="header-content">
            <div class="title-section">
                <h1 class="report-title">Customer Service Unit Tests</h1>
                <p class="report-subtitle">Enhanced Test Report • $CURRENT_DATE</p>
                
                <div class="report-actions">
                    <a href="https://developer.example.com/docs" 
                       class="action-btn" 
                       target="_blank">
                        <i class="fas fa-book"></i> API Docs
                    </a>
                    <a href="#" class="action-btn">
                        <i class="fas fa-download"></i> Download
                    </a>
                </div>
            </div>
            
            <div class="status-section">
                <div class="status-container">
                    <div class="status-card total-tests">
                        <h3>Total</h3>
                        <div class="value">$TOTAL_TESTS</div>
                    </div>
                    <div class="status-card passed-tests">
                        <h3>Passed</h3>
                        <div class="value">$PASSED_TESTS</div>
                    </div>
                    <div class="status-card failed-tests">
                        <h3>Failed</h3>
                        <div class="value">$FAILED_TESTS</div>
                    </div>
                    <div class="status-card skipped-tests">
                        <h3>Skipped</h3>
                        <div class="value">$SKIPPED_TESTS</div>
                    </div>
                </div>
                
                $STATUS_BADGE
            </div>
        </div>
        
        <div class="github-banner">
            <i class="fab fa-github"></i>
            GitHub Actions
        </div>
    </header>
    
    <div class="report-container">
        <div class="dashboard">
            <div class="chart-container">
                <canvas id="testChart"></canvas>
            </div>
            
            <div class="summary-container">
                <h2 class="summary-title">Test Summary</h2>
                <div class="summary-content">
                    <p>Test execution completed on <span class="summary-highlight">$CURRENT_DATE</span>.</p>
                    
                    <p><span class="summary-highlight">$TOTAL_TESTS tests</span> were executed with:</p>
                    <ul>
                        <li><span class="test-passed">$PASSED_TESTS passed</span></li>
                        <li><span class="test-failed">$FAILED_TESTS failed</span></li>
                        <li><span class="test-skipped">$SKIPPED_TESTS skipped</span></li>
                    </ul>
                    
                    <p>Overall status: $STATUS_BADGE</p>
                    
                    <p>The test suite covers core functionality including:</p>
                    <ul>
                        <li>Customer creation and validation</li>
                        <li>Data retrieval endpoints</li>
                        <li>Update and deletion workflows</li>
                        <li>Error handling scenarios</li>
                    </ul>
                </div>
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
        // Initialize test results chart
        const ctx = document.getElementById('testChart').getContext('2d');
        const testChart = new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: ['Passed', 'Failed', 'Skipped'],
                datasets: [{
                    data: [$PASSED_TESTS, $FAILED_TESTS, $SKIPPED_TESTS],
                    backgroundColor: [
                        '#2a9d8f',
                        '#e63946',
                        '#f4a261'
                    ],
                    borderWidth: 0,
                    hoverOffset: 15
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        position: 'bottom',
                        labels: {
                            font: {
                                size: 14,
                                family: "'Segoe UI', 'Roboto', sans-serif"
                            },
                            padding: 20
                        }
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.7)',
                        padding: 12,
                        titleFont: {
                            size: 16
                        },
                        bodyFont: {
                            size: 14
                        }
                    }
                },
                cutout: '65%'
            }
        });
        
        // Enhance test report table
        document.addEventListener('DOMContentLoaded', function() {
            // Color code test results
            const cells = document.querySelectorAll('td');
            cells.forEach(cell => {
                if (cell.textContent.includes('FAILURE')) {
                    cell.classList.add('test-failed');
                } else if (cell.textContent.includes('SUCCESS')) {
                    cell.classList.add('test-passed');
                } else if (cell.textContent.includes('SKIPPED')) {
                    cell.classList.add('test-skipped');
                } else if (cell.textContent.includes('ERROR')) {
                    cell.classList.add('test-error');
                }
            });
            
            // Make test rows clickable
            const testRows = document.querySelectorAll('tr');
            testRows.forEach(row => {
                row.addEventListener('click', function() {
                    this.classList.toggle('active');
                });
            });
        });
    </script>
</body>
</html>
EOF

echo "::notice::Generated enhanced HTML report: $OUTPUT_FILE"