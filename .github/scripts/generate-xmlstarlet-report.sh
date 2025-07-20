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

# Parse test results
test_cases=()
total_tests=0
passed=0
failed=0
skipped=0

# Process all XML reports
for report in "$REPORTS_DIR"/*.xml; do
    [ -f "$report" ] || continue
    
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
        
        .report-footer {
            padding: 25px 40px;
            background: var(--heading-bg);
            color: var(--text-color);
            display: flex;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 20px;
        }
        
        @media (max-width: 768px) {
            .report-header {
                padding: 20px;
                flex-direction: column;
                text-align: center;
            }
        }
    </style>
</head>
<body>
    <div class="report-container">
        <header class="report-header">
            <div>
                <h1 class="report-title">Customer Service Unit Test Report</h1>
                <p class="report-subtitle">Comprehensive test results • $CURRENT_DATE</p>
                <div class="report-meta">
                    <div>Total Tests: $total_tests</div>
                    <div>Passed: $passed</div>
                    <div>Failed: $failed</div>
                    <div>Skipped: $skipped</div>
                </div>
            </div>
            
            <div class="report-actions">
                <a href="https://developer.ausiex.com.au/docs/customer-api/b41b5a3efb0a9-introduction" class="action-btn" target="_blank">
                    API Documentation
                </a>
            </div>
        </header>
        
        <section class="results-section">
            <h2>Test Case Details</h2>
            
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
        </section>
        
        <footer class="report-footer">
            <div>CUSTOMER SERVICE</div>
            <div>Generated: $CURRENT_DATE</div>
        </footer>
    </div>
</body>
</html>
EOF

echo "Generated XMLStarlet-based report: $OUTPUT_FILE"