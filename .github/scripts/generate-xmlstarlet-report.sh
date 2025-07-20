#!/bin/bash

# XMLStarlet-based Professional Test Report Generator
REPORTS_DIR="${1:-target/surefire-reports}"
OUTPUT_FILE="$2"
CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Check for xmlstarlet
if ! command -v xmlstarlet &> /dev/null; then
    echo "Error: xmlstarlet is not installed. Please install it with: sudo apt-get install xmlstarlet"
    exit 1
fi

# Initialize counters
total_tests=0
passed=0
failed=0
skipped=0
test_cases=()

# Process all XML reports
while IFS= read -r -d $'\0' report; do
    [ -f "$report" ] || continue
    
    # Extract test cases
    while IFS='|' read -r name classname time status; do
        test_cases+=("$name|$classname|$time|$status")
        
        case "$status" in
            passed) ((passed++)) ;;
            failed) ((failed++)) ;;
            skipped) ((skipped++)) ;;
        esac
        ((total_tests++))
    done < <(xmlstarlet sel -t -m "//testcase" \
        -v "concat(@name, '|', @classname, '|', @time, '|')" \
        -i "failure" -o "failed" \
        -i "skipped" -o "skipped" \
        -i "not(failure) and not(skipped)" -o "passed" \
        -n "$report")
done < <(find "$REPORTS_DIR" -name '*.xml' -print0)

# Generate HTML report with professional UI
cat > "$OUTPUT_FILE" <<EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Customer Service - Unit Test Report</title>
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
        }
        
        .report-header {
            background: var(--header-bg);
            color: var(--header-text);
            padding: 40px 0;
            position: relative;
            overflow: hidden;
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
            text-align: center;
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
        
        .stats-container {
            display: flex;
            justify-content: center;
            flex-wrap: wrap;
            gap: 30px;
            margin-top: 25px;
        }
        
        .stat-card {
            background: rgba(255, 255, 255, 0.15);
            border-radius: 12px;
            padding: 20px 35px;
            min-width: 180px;
            text-align: center;
            backdrop-filter: blur(4px);
        }
        
        .stat-value {
            font-size: 2.5rem;
            font-weight: 700;
            margin-bottom: 8px;
        }
        
        .stat-label {
            font-size: 1.1rem;
            opacity: 0.9;
        }
        
        .stat-total { color: #ffffff; }
        .stat-passed { color: var(--success); }
        .stat-failed { color: var(--failure); }
        .stat-skipped { color: var(--warning); }
        
        .report-container {
            max-width: 1200px;
            margin: 50px auto;
            padding: 0 30px;
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
        
        .results-section {
            background: var(--card-bg);
            border-radius: 15px;
            box-shadow: var(--shadow);
            overflow: hidden;
        }
        
        .section-header {
            background: var(--header-bg);
            color: var(--header-text);
            padding: 20px 30px;
            font-size: 1.5rem;
            font-weight: 600;
        }
        
        .results-table {
            width: 100%;
            border-collapse: collapse;
        }
        
        .results-table th {
            background: #f8fafc;
            color: var(--header-bg);
            text-align: left;
            padding: 18px 25px;
            font-weight: 600;
            font-size: 1.1rem;
            border-bottom: 2px solid var(--border);
        }
        
        .results-table td {
            padding: 16px 25px;
            border-bottom: 1px solid var(--border);
        }
        
        .results-table tr:nth-child(even) {
            background-color: #fcfdff;
        }
        
        .results-table tr:hover {
            background-color: #f5f9ff;
        }
        
        .status-badge {
            display: inline-block;
            padding: 8px 18px;
            border-radius: 20px;
            font-size: 0.95rem;
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
            
            .stats-container {
                gap: 15px;
            }
            
            .stat-card {
                padding: 15px 20px;
                min-width: 140px;
            }
            
            .stat-value {
                font-size: 2rem;
            }
            
            .action-btn {
                padding: 12px 20px;
                font-size: 1rem;
            }
            
            .results-table th,
            .results-table td {
                padding: 14px 20px;
            }
        }
    </style>
</head>
<body>
    <header class="report-header">
        <div class="header-pattern"></div>
        <div class="header-content">
            <h1 class="report-title">Customer Service Unit Tests</h1>
            <p class="report-subtitle">Comprehensive test results • $CURRENT_DATE</p>
            
            <div class="stats-container">
                <div class="stat-card">
                    <div class="stat-value stat-total">$total_tests</div>
                    <div class="stat-label">Total Tests</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-value stat-passed">$passed</div>
                    <div class="stat-label">Passed</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-value stat-failed">$failed</div>
                    <div class="stat-label">Failed</div>
                </div>
                
                <div class="stat-card">
                    <div class="stat-value stat-skipped">$skipped</div>
                    <div class="stat-label">Skipped</div>
                </div>
            </div>
            
            <div class="report-actions">
                <a href="https://developer.ausiex.com.au/docs/customer-api/b41b5a3efb0a9-introduction" 
                   class="action-btn" 
                   target="_blank">
                    View API Documentation
                </a>
                <a href="#" class="action-btn">
                    Download Full Report
                </a>
            </div>
        </div>
    </header>
    
    <div class="report-container">
        <div class="results-section">
            <div class="section-header">
                Detailed Test Results
            </div>
            
            <table class="results-table">
                <thead>
                    <tr>
                        <th>Test Case</th>
                        <th>Class</th>
                        <th>Duration (s)</th>
                        <th>Status</th>
                    </tr>
                </thead>
                <tbody>
                    $(
                        for test in "${test_cases[@]}"; do
                            IFS='|' read -r name class time status <<< "$test"
                            status_cap="${status^}"
                            echo "<tr>"
                            echo "  <td>$name</td>"
                            echo "  <td>$class</td>"
                            echo "  <td>$time</td>"
                            echo "  <td><span class=\"status-badge status-$status\">$status_cap</span></td>"
                            echo "</tr>"
                        done
                    )
                </tbody>
            </table>
        </div>
    </div>
    
    <footer class="report-footer">
        <p>Customer Service Unit Test Report • Generated by CI/CD Pipeline</p>
        <p>Confidential - For internal use only</p>
    </footer>
    
    <script>
        // Add row hover effects
        document.querySelectorAll('.results-table tr').forEach(row => {
            row.addEventListener('mouseenter', () => {
                row.style.backgroundColor = '#f0f7ff';
            });
            
            row.addEventListener('mouseleave', () => {
                if (row.rowIndex % 2 === 0) {
                    row.style.backgroundColor = '#fcfdff';
                } else {
                    row.style.backgroundColor = '';
                }
            });
        });
    </script>
</body>
</html>
EOF

echo "Generated XMLStarlet report: $OUTPUT_FILE"