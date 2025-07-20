#!/bin/bash

INPUT_DIR="$1"       # e.g. target/site
OUTPUT_FILE="$2"     # e.g. self-contained-report.html
REPORTS_DIR="${3:-target/surefire-reports}"  # Surefire reports directory
CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Check for required dependencies
command -v xmlstarlet >/dev/null 2>&1 || {
    echo "Error: xmlstarlet is required but not installed. Please install it."
    exit 1
}

# Parse test results from XML files
parse_test_results() {
    local total_tests=0
    local passed=0
    local failed=0
    local skipped=0
    local test_cases=()
    
    # Process each XML report
    for report in "$REPORTS_DIR"/*.xml; do
        [ -f "$report" ] || continue
        
        # Extract test results from XML
        while IFS= read -r line; do
            IFS='|' read -r name classname time status <<< "$line"
            
            test_cases+=("$name|$classname|$time|$status")
            
            case "$status" in
                passed) ((passed++)) ;;
                failed) ((failed++)) ;;
                skipped) ((skipped++)) ;;
            esac
            ((total_tests++))
        done < <(xmlstarlet sel -t -m "//testcase" \
            -v "@name" -o "|" \
            -v "@classname" -o "|" \
            -v "@time" -o "|" \
            -i "failure" -o "failed" \
            -i "skipped" -o "skipped" \
            -i "not(failure) and not(skipped)" -o "passed" \
            -n "$report")
    done
    
    # Return results
    echo "${total_tests}|${passed}|${failed}|${skipped}|${test_cases[*]}"
}

# Generate the professional HTML report
generate_report() {
    # Parse test results
    IFS='|' read -r total passed failed skipped test_cases <<< "$(parse_test_results)"
    
    # Calculate percentages
    passed_pct=$((passed * 100 / total))
    failed_pct=$((failed * 100 / total))
    skipped_pct=$((skipped * 100 / total))
    
    # Generate the HTML
    cat <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Service - Unit Test Report</title>
    <style>
        :root {
            --heading-bg: #000050;
            --text-color: #b8ff4e;
            --accent-color: #41b6e6;
            --success: #4caf50;
            --failure: #f44336;
            --warning: #ff9800;
            --light-bg: #f8f9fa;
            --border-color: #d1d1d1;
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        }
        
        body {
            background-color: #f0f4f8;
            color: #333;
            line-height: 1.6;
            padding: 20px;
        }
        
        .report-container {
            max-width: 1200px;
            margin: 0 auto;
            background: white;
            border-radius: 10px;
            box-shadow: 0 5px 25px rgba(0, 0, 0, 0.1);
            overflow: hidden;
        }
        
        /* Header styling with your custom colors */
        .report-header {
            background: var(--heading-bg);
            color: var(--text-color);
            padding: 30px 40px;
            display: flex;
            justify-content: space-between;
            align-items: center;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .header-content {
            flex: 1;
            min-width: 300px;
        }
        
        .report-title {
            font-size: 32px;
            margin-bottom: 10px;
            font-weight: 700;
            letter-spacing: 0.5px;
        }
        
        .report-subtitle {
            font-size: 18px;
            opacity: 0.9;
            margin-bottom: 15px;
        }
        
        .report-meta {
            display: flex;
            gap: 20px;
            margin-top: 15px;
            flex-wrap: wrap;
        }
        
        .meta-item {
            display: flex;
            align-items: center;
            gap: 8px;
        }
        
        .meta-icon {
            background: rgba(184, 255, 78, 0.2);
            width: 30px;
            height: 30px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }
        
        .report-actions {
            display: flex;
            gap: 15px;
        }
        
        .action-btn {
            background: rgba(184, 255, 78, 0.15);
            color: var(--text-color);
            border: 1px solid rgba(184, 255, 78, 0.3);
            padding: 10px 20px;
            border-radius: 30px;
            cursor: pointer;
            transition: all 0.3s ease;
            font-weight: 500;
            display: flex;
            align-items: center;
            gap: 8px;
            text-decoration: none;
        }
        
        .action-btn:hover {
            background: rgba(184, 255, 78, 0.25);
            transform: translateY(-2px);
        }
        
        /* Summary section */
        .summary-section {
            padding: 30px 40px;
            background: var(--light-bg);
            border-bottom: 1px solid var(--border-color);
        }
        
        .section-title {
            color: var(--heading-bg);
            font-size: 24px;
            margin-bottom: 20px;
            padding-bottom: 10px;
            border-bottom: 2px solid var(--accent-color);
            display: flex;
            align-items: center;
            gap: 10px;
        }
        
        .stats-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 20px;
            margin-bottom: 30px;
        }
        
        .stat-card {
            background: white;
            border-radius: 10px;
            padding: 20px;
            box-shadow: 0 3px 10px rgba(0, 0, 0, 0.05);
            display: flex;
            flex-direction: column;
            align-items: center;
            text-align: center;
            transition: transform 0.3s ease;
        }
        
        .stat-card:hover {
            transform: translateY(-5px);
        }
        
        .stat-value {
            font-size: 42px;
            font-weight: 700;
            margin: 15px 0;
        }
        
        .stat-success {
            color: var(--success);
        }
        
        .stat-failure {
            color: var(--failure);
        }
        
        .stat-skipped {
            color: var(--warning);
        }
        
        .stat-label {
            font-size: 16px;
            color: #666;
        }
        
        /* Progress bars */
        .progress-container {
            margin-top: 30px;
        }
        
        .progress-bar {
            height: 8px;
            background: #e0e0e0;
            border-radius: 4px;
            overflow: hidden;
            margin: 10px 0;
        }
        
        .progress-fill {
            height: 100%;
        }
        
        .progress-passed {
            background: var(--success);
            width: ${passed_pct}%;
        }
        
        .progress-failed {
            background: var(--failure);
            width: ${failed_pct}%;
        }
        
        .progress-skipped {
            background: var(--warning);
            width: ${skipped_pct}%;
        }
        
        .progress-labels {
            display: flex;
            justify-content: space-between;
            font-size: 14px;
            color: #666;
        }
        
        /* Test results table */
        .results-section {
            padding: 30px 40px;
        }
        
        .results-table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 20px;
            box-shadow: 0 2px 10px rgba(0, 0, 0, 0.03);
        }
        
        .results-table th {
            background: var(--heading-bg);
            color: var(--text-color);
            text-align: left;
            padding: 15px 20px;
            font-weight: 600;
        }
        
        .results-table td {
            padding: 15px 20px;
            border-bottom: 1px solid var(--border-color);
        }
        
        .results-table tr:nth-child(even) {
            background-color: #fafcff;
        }
        
        .results-table tr:hover {
            background-color: #f0f7ff;
        }
        
        .status-badge {
            display: inline-block;
            padding: 5px 15px;
            border-radius: 20px;
            font-size: 14px;
            font-weight: 500;
        }
        
        .status-passed {
            background-color: #e8f5e9;
            color: var(--success);
        }
        
        .status-failed {
            background-color: #ffebee;
            color: var(--failure);
        }
        
        .status-skipped {
            background-color: #fff8e1;
            color: var(--warning);
        }
        
        /* Footer */
        .report-footer {
            padding: 25px 40px;
            background: var(--heading-bg);
            color: var(--text-color);
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        .footer-logo {
            font-weight: 700;
            font-size: 20px;
            letter-spacing: 1px;
        }
        
        .footer-links {
            display: flex;
            gap: 20px;
        }
        
        .footer-link {
            color: var(--text-color);
            opacity: 0.8;
            text-decoration: none;
            transition: opacity 0.3s;
        }
        
        .footer-link:hover {
            opacity: 1;
        }
        
        /* Responsive design */
        @media (max-width: 768px) {
            .report-header {
                padding: 20px;
                flex-direction: column;
                text-align: center;
            }
            
            .header-content, .report-actions {
                width: 100%;
                justify-content: center;
            }
            
            .report-title {
                font-size: 28px;
            }
            
            .report-meta {
                justify-content: center;
            }
            
            .section-title {
                font-size: 20px;
            }
            
            .stat-value {
                font-size: 36px;
            }
        }
    </style>
</head>
<body>
    <div class="report-container">
        <header class="report-header">
            <div class="header-content">
                <h1 class="report-title">Customer Service Unit Test Report</h1>
                <p class="report-subtitle">Comprehensive test results for API endpoints and service functionality</p>
                
                <div class="report-meta">
                    <div class="meta-item">
                        <div class="meta-icon">📅</div>
                        <span>Generated: $CURRENT_DATE</span>
                    </div>
                    <div class="meta-item">
                        <div class="meta-icon">🔄</div>
                        <span>Total Tests: $total</span>
                    </div>
                    <div class="meta-item">
                        <div class="meta-icon">✅</div>
                        <span>Passed: $passed</span>
                    </div>
                </div>
            </div>
            
            <div class="report-actions">
                <a href="https://developer.ausiex.com.au/docs/customer-api/b41b5a3efb0a9-introduction" class="action-btn" target="_blank">
                    <span>📚</span> API Documentation
                </a>
            </div>
        </header>
        
        <section class="summary-section">
            <h2 class="section-title">Test Summary</h2>
            
            <div class="stats-container">
                <div class="stat-card">
                    <div class="stat-icon">📊</div>
                    <div class="stat-value">$total</div>
                    <div class="stat-label">Total Tests</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">✅</div>
                    <div class="stat-value stat-success">$passed</div>
                    <div class="stat-label">Tests Passed</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">❌</div>
                    <div class="stat-value stat-failure">$failed</div>
                    <div class="stat-label">Tests Failed</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-icon">⏭️</div>
                    <div class="stat-value stat-skipped">$skipped</div>
                    <div class="stat-label">Tests Skipped</div>
                </div>
            </div>
            
            <div class="progress-container">
                <div class="progress-labels">
                    <span>Passed ($passed_pct%)</span>
                    <span>Failed ($failed_pct%)</span>
                    <span>Skipped ($skipped_pct%)</span>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill progress-passed"></div>
                    <div class="progress-fill progress-failed"></div>
                    <div class="progress-fill progress-skipped"></div>
                </div>
            </div>
        </section>
        
        <section class="results-section">
            <h2 class="section-title">Test Case Details</h2>
            
            <table class="results-table">
                <thead>
                    <tr>
                        <th>Test Case</th>
                        <th>Class</th>
                        <th>Duration</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    $(
                        # Generate test case rows
                        for test in "${test_cases[@]}"; do
                            IFS='|' read -r name class time status <<< "$test"
                            
                            # Capitalize status
                            status_cap="${status^}"
                            
                            echo "<tr>"
                            echo "  <td>$name</td>"
                            echo "  <td>$class</td>"
                            echo "  <td>${time}s</td>"
                            echo "  <td><span class=\"status-badge status-$status\">$status_cap</span></td>"
                            echo "</tr>"
                        done
                    )
                </tbody>
            </table>
        </section>
        
        <footer class="report-footer">
            <div class="footer-logo">CUSTOMER SERVICE</div>
            <div class="footer-links">
                <a href="https://your-company.com/dashboard" class="footer-link">Dashboard</a>
                <a href="https://developer.ausiex.com.au/docs" class="footer-link">Documentation</a>
                <a href="https://your-company.com/support" class="footer-link">Support</a>
            </div>
        </footer>
    </div>
    
    <script>
        // Simple animation for stats
        document.addEventListener('DOMContentLoaded', function() {
            const statValues = document.querySelectorAll('.stat-value');
            
            statValues.forEach(value => {
                const target = parseInt(value.textContent);
                let count = 0;
                const duration = 2000; // ms
                const increment = target / (duration / 16);
                
                const updateCount = () => {
                    if (count < target) {
                        count += increment;
                        value.textContent = Math.min(Math.ceil(count), target);
                        setTimeout(updateCount, 16);
                    } else {
                        value.textContent = target;
                    }
                };
                
                updateCount();
            });
        });
    </script>
</body>
</html>
EOF
}

# Generate the report with real data
generate_report > "$OUTPUT_FILE"

# Check if report was generated
if [ -s "$OUTPUT_FILE" ]; then
    echo "✅ Generated professional test report at: $OUTPUT_FILE"
    exit 0
else
    echo "❌ Error: Failed to generate test report"
    exit 1
fi