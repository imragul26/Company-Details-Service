#!/bin/bash

INPUT_DIR=$1         # e.g. target/site
OUTPUT_FILE=$2       # e.g. self-contained-report.html
CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Create temporary files
HEADER_FILE=$(mktemp)
CONTENT_FILE=$(mktemp)

# Enhanced custom header HTML with Ausiex theme
cat > "$HEADER_FILE" <<EOF
<div class="custom-header">
  <div class="header-content">
    <h1 class="project-title">Customer Service Unit Test Report</h1>
    <div class="report-meta">
      <span class="publish-date">Generated: ${CURRENT_DATE}</span>
      <a class="report-link" href="https://developer.ausiex.com.au/docs/customer-api/b41b5a3efb0a9-introduction" target="_blank">API Documentation</a>
    </div>
  </div>
</div>
EOF

# Copy original report for processing
cp "${INPUT_DIR}/surefire.html" "$CONTENT_FILE"

# Insert custom header at the top of the body
awk '
  /<body[^>]*>/ {
    print
    while ((getline line < "'"$HEADER_FILE"'") > 0) print line
    close("'"$HEADER_FILE"'")
    next
  }
  {print}
' "$CONTENT_FILE" > temp.html

# Build final HTML with Ausiex theme styling
{
  echo '<!DOCTYPE html>'
  echo '<html xmlns="http://www.w3.org/1999/xhtml" lang="en">'
  echo '<head>'
  echo '<meta charset="UTF-8">'
  echo '<meta name="viewport" content="width=device-width, initial-scale=1">'
  echo '<title>Customer Service - Unit Test Report</title>'
  
  # Ausiex-inspired theme CSS
  echo '<style>'
  echo ':root {'
  echo '  --primary-dark: #060667;'
  echo '  --primary-medium: #0070c0;'
  echo '  --primary-light: #e6f0fa;'
  echo '  --accent: #41b6e6;'
  echo '  --text-dark: #333;'
  echo '  --text-light: #fff;'
  echo '  --border: #d1d1d1;'
  echo '  --success: #4caf50;'
  echo '  --failure: #f44336;'
  echo '  --warning: #ff9800;'
  echo '}'
  echo ''
  echo 'body {'
  echo '  margin: 0;'
  echo '  font-family: "Segoe UI", "Roboto", "Oxygen", "Ubuntu", "Cantarell", "Fira Sans", "Droid Sans", "Helvetica Neue", sans-serif;'
  echo '  font-size: 15px;'
  echo '  line-height: 1.6;'
  echo '  color: var(--text-dark);'
  echo '  background-color: #f8f9fa;'
  echo '}'
  echo ''
  echo '.custom-header {'
  echo '  background: linear-gradient(135deg, var(--primary-dark), var(--primary-medium));'
  echo '  color: var(--text-light);'
  echo '  padding: 25px 0;'
  echo '  box-shadow: 0 2px 10px rgba(0,0,0,0.1);'
  echo '  margin-bottom: 25px;'
  echo '}'
  echo ''
  echo '.header-content {'
  echo '  max-width: 1200px;'
  echo '  margin: 0 auto;'
  echo '  padding: 0 20px;'
  echo '}'
  echo ''
  echo '.project-title {'
  echo '  font-size: 28px;'
  echo '  font-weight: 600;'
  echo '  margin: 0 0 8px 0;'
  echo '  letter-spacing: 0.5px;'
  echo '}'
  echo ''
  echo '.report-meta {'
  echo '  display: flex;'
  echo '  justify-content: space-between;'
  echo '  align-items: center;'
  echo '  font-size: 15px;'
  echo '  opacity: 0.9;'
  echo '}'
  echo ''
  echo '.report-link {'
  echo '  color: var(--accent);'
  echo '  text-decoration: none;'
  echo '  font-weight: 500;'
  echo '  display: inline-flex;'
  echo '  align-items: center;'
  echo '}'
  echo ''
  echo '.report-link:hover {'
  echo '  text-decoration: underline;'
  echo '}'
  echo ''
  echo '/* Main content container */'
  echo '.container {'
  echo '  max-width: 1200px;'
  echo '  margin: 0 auto;'
  echo '  padding: 0 20px;'
  echo '  background: white;'
  echo '  border-radius: 8px;'
  echo '  box-shadow: 0 2px 15px rgba(0,0,0,0.05);'
  echo '  padding: 25px;'
  echo '  margin-bottom: 40px;'
  echo '}'
  echo ''
  echo '/* Table styling */'
  echo '.table {'
  echo '  width: 100%;'
  echo '  border-collapse: collapse;'
  echo '  margin: 20px 0;'
  echo '}'
  echo ''
  echo '.table th {'
  echo '  background-color: var(--primary-light);'
  echo '  color: var(--primary-dark);'
  echo '  padding: 12px 15px;'
  echo '  text-align: left;'
  echo '  font-weight: 600;'
  echo '  border-bottom: 2px solid var(--primary-medium);'
  echo '}'
  echo ''
  echo '.table td {'
  echo '  padding: 12px 15px;'
  echo '  border-bottom: 1px solid var(--border);'
  echo '}'
  echo ''
  echo '.table-striped tbody tr:nth-child(odd) {'
  echo '  background-color: #fafafa;'
  echo '}'
  echo ''
  echo '.table-striped tbody tr:hover {'
  echo '  background-color: var(--primary-light);'
  echo '}'
  echo ''
  echo '/* Status badges */'
  echo '.badge {'
  echo '  padding: 4px 10px;'
  echo '  border-radius: 12px;'
  echo '  font-size: 13px;'
  echo '  font-weight: 500;'
  echo '}'
  echo ''
  echo '.badge-success {'
  echo '  background-color: #e8f5e9;'
  echo '  color: var(--success);'
  echo '}'
  echo ''
  echo '.badge-failure {'
  echo '  background-color: #ffebee;'
  echo '  color: var(--failure);'
  echo '}'
  echo ''
  echo '/* Section headers */'
  echo 'h1, h2, h3 {'
  echo '  color: var(--primary-dark);'
  echo '}'
  echo ''
  echo 'h1 {'
  echo '  border-bottom: 2px solid var(--primary-medium);'
  echo '  padding-bottom: 10px;'
  echo '  margin-top: 0;'
  echo '}'
  echo ''
  echo 'h2 {'
  echo '  margin-top: 30px;'
  echo '  padding-bottom: 8px;'
  echo '  border-bottom: 1px solid var(--border);'
  echo '}'
  echo ''
  echo '/* Breadcrumb styling */'
  echo '.breadcrumb {'
  echo '  background-color: #f0f4f8;'
  echo '  padding: 10px 15px;'
  echo '  border-radius: 6px;'
  echo '  margin-bottom: 20px;'
  echo '  font-size: 14px;'
  echo '}'
  echo ''
  echo '.breadcrumb .divider {'
  echo '  color: var(--primary-medium);'
  echo '  padding: 0 8px;'
  echo '}'
  echo ''
  echo '#bannerLeft h1 {'
  echo '  color: var(--primary-dark);'
  echo '  font-size: 22px;'
  echo '  margin: 5px 0;'
  echo '}'
  echo ''
  echo '@media (max-width: 768px) {'
  echo '  .header-content, .container {'
  echo '    padding: 0 15px;'
  echo '  }'
  echo '  .project-title {'
  echo '    font-size: 24px;'
  echo '  }'
  echo '  .report-meta {'
  echo '    flex-direction: column;'
  echo '    align-items: flex-start;'
  echo '    gap: 8px;'
  echo '  }'
  echo '}'
  echo '</style>'
  echo '</head>'
  
  # Insert modified body content
  echo '<body>'
  cat temp.html
  echo '</body>'
  echo '</html>'
} > "$OUTPUT_FILE"

# Fix image paths in the HTML
sed -i 's|src="\./|src="|g' "$OUTPUT_FILE"
sed -i 's|url(\./|url(|g' "$OUTPUT_FILE"

# Inline all images from the images directory
if [ -d "${INPUT_DIR}/images" ]; then
  while IFS= read -r -d $'\0' img; do
    base_img=$(basename "$img")
    # Escape special characters for sed
    safe_img=$(printf '%s\n' "$base_img" | sed 's/[][\/.^$*]/\\&/g')
    
    # Determine MIME type
    ext="${base_img##*.}"
    case "$ext" in
      svg) mime_type="image/svg+xml" ;;
      png) mime_type="image/png" ;;
      jpg) mime_type="image/jpeg" ;;
      jpeg) mime_type="image/jpeg" ;;
      gif) mime_type="image/gif" ;;
      *) mime_type="image/$ext" ;;
    esac
    
    # Convert to base64
    data=$(base64 -w0 "$img")
    
    # Replace image references
    sed -i "s|src=[\"']images/${safe_img}[\"']|src=\"data:${mime_type};base64,${data}\"|gI" "$OUTPUT_FILE"
    sed -i "s|url([\"']images/${safe_img}[\"'])|url(data:${mime_type};base64,${data})|gI" "$OUTPUT_FILE"
  done < <(find "${INPUT_DIR}/images" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.gif" -o -iname "*.svg" \) -print0)
fi

# Final cleanup
rm "$HEADER_FILE" "$CONTENT_FILE" temp.html