#!/bin/bash

# Enhanced HTML Test Report Generator
INPUT_DIR="$1"  # Directory containing TEST-*.xml files (target/surefire-reports)
OUTPUT_FILE="$2" # Output HTML file (target/reports/test-report.html)
CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')
STANDARD_REPORT="$(dirname "$OUTPUT_FILE")/surefire.html"

# Initialize counts
TOTAL_TESTS=0
FAILURES=0
ERRORS=0
SKIPPED=0
TIME=0

# Process all XML files (updated aggregation logic)
while IFS= read -r xml_file; do
    while read -r line; do
        case $line in
            *"testsuite"*)
                # Extract values safely
                tests=$(grep -o 'tests="[0-9]*"' <<< "$line" | cut -d'"' -f2)
                failures=$(grep -o 'failures="[0-9]*"' <<< "$line" | cut -d'"' -f2)
                errors=$(grep -o 'errors="[0-9]*"' <<< "$line" | cut -d'"' -f2)
                skipped=$(grep -o 'skipped="[0-9]*"' <<< "$line" | cut -d'"' -f2)
                time_val=$(grep -o 'time="[0-9.]*"' <<< "$line" | cut -d'"' -f2)
                
                # Aggregate values
                TOTAL_TESTS=$((TOTAL_TESTS + ${tests:-0}))
                FAILURES=$((FAILURES + ${failures:-0}))
                ERRORS=$((ERRORS + ${errors:-0}))
                SKIPPED=$((SKIPPED + ${skipped:-0}))
                TIME=$(awk "BEGIN {print $TIME + ${time_val:-0}}")
                ;;
        esac
    done < "$xml_file"
done < <(find "$INPUT_DIR" -name "TEST-*.xml")

# Calculate passed tests
PASSED=$((TOTAL_TESTS - FAILURES - ERRORS - SKIPPED))

# Calculate percentages
if [ $TOTAL_TESTS -gt 0 ]; then
    PASSED_PERCENT=$((PASSED * 100 / TOTAL_TESTS))
    FAILED_PERCENT=$(((FAILURES + ERRORS) * 100 / TOTAL_TESTS))
    SKIPPED_PERCENT=$((SKIPPED * 100 / TOTAL_TESTS))
else
    PASSED_PERCENT=0
    FAILED_PERCENT=0
    SKIPPED_PERCENT=0
fi

# 2. Get HTML report content with replacements
REPORT_CONTENT=""
if [ -f "$STANDARD_REPORT" ]; then
    REPORT_CONTENT=$(awk '/<main id="bodyColumn">/,/<\/main>/' "$STANDARD_REPORT" | sed '1d;$d' | \
        sed '
            s/Surefire/Unit Test/gi;
            s/surefire/unit-test/gi;
            s/SUREFIRE/UNIT-TEST/gi
        ')
else
    REPORT_CONTENT="<div class='report-warning'>
        <i class='fas fa-exclamation-triangle'></i>
        Detailed test report not generated. Run 'mvn site' to generate full report.
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

# Generate professional HTML report
cat > "$OUTPUT_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Service - Unit Test Report</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
    <style>
        /* Modern CSS Reset */
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        /* Base Styles */
        :root {
            --header-bg: #060667; /* Primary dark blue */
            --header-text: #ffffff;
            --accent: #b8ff4e; /* Vibrant green from API docs */
            --accent-light: #d4ff9c;
            --card-bg: #ffffff;
            --text-primary: #333333;
            --text-secondary: #666666;
            --border: #e0e0e0;
            --shadow: 0 4px 20px rgba(0, 0, 0, 0.08);
            --success: #4CAF50;
            --warning: #FFC107;
            --danger: #e63946;
            --chart-passed: #4CAF50;
            --chart-failed: #e63946;
            --chart-skipped: #FFC107;
            --chart-error: #ff6b6b;
        }
        
        body {
            font-family: 'Segoe UI', 'Roboto', 'Helvetica Neue', sans-serif;
            background-color: #f8f9fa;
            color: var(--text-primary);
            line-height: 1.6;
            padding-bottom: 40px;
        }
        
        /* Header Styles */
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
        
        /* Status Cards */
        .status-container {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 30px;
            margin: 30px 0;
        }
        
        .status-card {
            background: rgba(255, 255, 255, 0.15);
            border-radius: 10px;
            padding: 20px 30px;
            min-width: 180px;
            text-align: center;
            backdrop-filter: blur(5px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
            position: relative;
            overflow: hidden;
            cursor: pointer;
        }
        
        .status-card:hover {
            transform: translateY(-5px);
            box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
            background: rgba(255, 255, 255, 0.25);
        }
        
        .status-card h3 {
            font-size: 1.1rem;
            color: rgba(255, 255, 255, 0.85);
            margin-bottom: 10px;
            position: relative;
            z-index: 2;
        }
        
        .status-card .value {
            font-size: 2.2rem;
            font-weight: 700;
            position: relative;
            z-index: 2;
        }
        
        .total-tests .value { color: white; }
        .passed-tests .value { color: var(--accent); }
        .failed-tests .value { color: #ff9aa2; }
        .skipped-tests .value { color: var(--warning); }
        
        /* Progress ring styles */
        .progress-ring {
            position: absolute;
            top: 15px;
            right: 15px;
            width: 40px;
            height: 40px;
            z-index: 1;
            opacity: 0.7;
        }
        
        .progress-ring-circle {
            stroke: var(--accent);
            stroke-width: 3;
            fill: none;
            stroke-linecap: round;
            transform: rotate(-90deg);
            transform-origin: 50% 50%;
        }
        
        /* Badges & Buttons */
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
            background-color: var(--accent);
            color: var(--header-bg);
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
        
        /* Main Content */
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
            position: relative;
            overflow: hidden;
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
        
        /* Chart container */
        .chart-container {
            display: flex;
            justify-content: center;
            margin: 30px 0;
            height: 120px;
        }
        
        /* Original Report Styling */
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
        
        .report-warning {
            background: #FFF3E0;
            border-left: 4px solid var(--warning);
            padding: 20px;
            margin: 20px 0;
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        /* FIX: Add this rule to hide images in embedded report */
        .report-content img {
            display: none !important;
        }
        
        /* Footer */
        .report-footer {
            text-align: center;
            padding: 30px;
            color: var(--text-secondary);
            font-size: 0.95rem;
            margin-top: 50px;
            background: linear-gradient(135deg, var(--header-bg) 0%, #0a0a8a 100%);
            color: white;
            border-radius: 15px 15px 0 0;
            position: relative;
            overflow: hidden;
        }
        
        .footer-pattern {
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
        
        .footer-content {
            position: relative;
            z-index: 2;
        }
        
        .footer-content p {
            margin: 10px 0;
        }
        
        /* Animations */
        @keyframes fadeIn {
            from { opacity: 0; transform: translateY(20px); }
            to { opacity: 1; transform: translateY(0); }
        }
        
        @keyframes pulse {
            0% { transform: scale(1); }
            50% { transform: scale(1.05); }
            100% { transform: scale(1); }
        }
        
        .status-card {
            animation: fadeIn 0.6s ease forwards;
            opacity: 0;
        }
        
        .status-card:nth-child(1) { animation-delay: 0.1s; }
        .status-card:nth-child(2) { animation-delay: 0.2s; }
        .status-card:nth-child(3) { animation-delay: 0.3s; }
        .status-card:nth-child(4) { animation-delay: 0.4s; }
        
        .badge {
            animation: pulse 2s infinite;
        }
        
        /* Responsive Design */
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
            
            .chart-container {
                height: 100px;
            }
        }
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
                    <svg class="progress-ring" viewBox="0 0 42 42">
                        <circle class="progress-ring-circle" stroke="#ffffff" stroke-dasharray="100, 100" cx="21" cy="21" r="15.9"></circle>
                    </svg>
                    <h3>Total Tests</h3>
                    <div class="value">$TOTAL_TESTS</div>
                </div>
                <div class="status-card passed-tests">
                    <svg class="progress-ring" viewBox="0 0 42 42">
                        <circle class="progress-ring-circle" stroke-dasharray="$PASSED_PERCENT, 100" cx="21" cy="21" r="15.9"></circle>
                    </svg>
                    <h3>Passed</h3>
                    <div class="value">$PASSED</div>
                </div>
                <div class="status-card failed-tests">
                    <svg class="progress-ring" viewBox="0 0 42 42">
                        <circle class="progress-ring-circle" stroke="#ff9aa2" stroke-dasharray="$FAILED_PERCENT, 100" cx="21" cy="21" r="15.9"></circle>
                    </svg>
                    <h3>Failed</h3>
                    <div class="value">$FAILURES</div>
                </div>
                <div class="status-card skipped-tests">
                    <svg class="progress-ring" viewBox="0 0 42 42">
                        <circle class="progress-ring-circle" stroke="#FFC107" stroke-dasharray="$SKIPPED_PERCENT, 100" cx="21" cy="21" r="15.9"></circle>
                    </svg>
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
                <p>Unit test execution completed with the above results. Below is the test distribution:</p>
                
                <div class="chart-container">
                    <canvas id="testDistributionChart"></canvas>
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
        <div class="footer-pattern"></div>
        <div class="footer-content">
            <p><i class="fas fa-code-branch"></i> Generated by CI/CD Pipeline • Customer Service Team</p>
            <p><i class="fas fa-lock"></i> Confidential - For internal use only</p>
            <p><i class="fas fa-sync-alt"></i> Report generated on $CURRENT_DATE</p>
        </div>
    </footer>
    
    <script>
        // Color code test results in the embedded report
        document.addEventListener('DOMContentLoaded', function() {
            const cells = document.querySelectorAll('.report-content td');
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
            
            // Create test distribution chart
            const ctx = document.getElementById('testDistributionChart').getContext('2d');
            new Chart(ctx, {
                type: 'doughnut',
                data: {
                    labels: ['Passed', 'Failed', 'Skipped'],
                    datasets: [{
                        data: [$PASSED, $FAILURES, $SKIPPED],
                        backgroundColor: [
                            '#4CAF50',
                            '#e63946',
                            '#FFC107'
                        ],
                        borderColor: '#ffffff',
                        borderWidth: 2,
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
                                    size: 12
                                },
                                padding: 20
                            }
                        },
                        tooltip: {
                            callbacks: {
                                label: function(context) {
                                    const label = context.label || '';
                                    const value = context.raw || 0;
                                    const total = $TOTAL_TESTS;
                                    const percentage = total ? Math.round((value / total) * 100) : 0;
                                    return \`\${label}: \${value} tests (\${percentage}%)\`;
                                }
                            }
                        }
                    },
                    cutout: '60%'
                }
            });
            
            // Animate progress rings
            document.querySelectorAll('.progress-ring-circle').forEach(circle => {
                const radius = circle.r.baseVal.value;
                const circumference = 2 * Math.PI * radius;
                
                circle.style.strokeDasharray = \`\${circumference} \${circumference}\`;
                circle.style.strokeDashoffset = circumference;
                
                const offset = circumference - (parseFloat(circle.getAttribute('stroke-dasharray').split(',')[0] / 100) * circumference;
                setTimeout(() => {
                    circle.style.transition = 'stroke-dashoffset 1s ease-in-out';
                    circle.style.strokeDashoffset = offset;
                }, 500);
            });
        });
    </script>
</body>
</html>
EOF

echo "Generated enhanced HTML report: $OUTPUT_FILE"