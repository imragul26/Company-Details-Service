#!/bin/bash

INPUT_DIR=$1         # e.g. target/site
OUTPUT_FILE=$2       # e.g. self-contained-report.html
CURRENT_DATE=$(date '+%Y-%m-%d %H:%M:%S')

# Create temporary files
HEADER_FILE=$(mktemp)
CONTENT_FILE=$(mktemp)

# Custom header HTML
cat > "$HEADER_FILE" <<EOF
<div class="custom-header">
  <div class="project-title">Customer Service</div>
  <div class="report-meta">
    <span class="publish-date">Last Published: ${CURRENT_DATE}</span>
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

# Build final HTML with proper structure
{
  echo '<!DOCTYPE html>'
  echo '<html xmlns="http://www.w3.org/1999/xhtml" lang="en">'
  echo '<head>'
  
  # Extract original meta tags and title
  grep -E '<meta|<title' "$CONTENT_FILE"
  
  # Add optimized styles
  echo '<style>'
  
  # Only include essential CSS for the report
  echo '/* ===== ESSENTIAL REPORT STYLES ===== */'
  echo 'body { margin:0; font-family:"Helvetica Neue",Helvetica,Arial,sans-serif; font-size:14px; line-height:20px; color:#333; background-color:#fff }'
  echo 'a { color:#08c; text-decoration:none } a:hover, a:focus { color:#005580; text-decoration:underline }'
  echo '.container { width:940px; margin:0 auto }'
  echo '.row { margin-left:-20px } .row:after { content:""; display:table; clear:both }'
  echo '.span12 { width:940px }'
  echo 'header { background:#f8f9fa; padding:15px 0; border-bottom:1px solid #e0e0e0 }'
  echo '#banner { overflow:hidden } #bannerLeft h1 { margin:0; font-size:24px }'
  echo '#breadcrumbs { background:#f5f5f5; border-radius:4px; padding:8px 15px; margin:15px 0 }'
  echo '.breadcrumb { margin:0; padding:0; list-style:none } .breadcrumb li { display:inline }'
  echo '.breadcrumb .divider { padding:0 5px; color:#ccc }'
  echo '.table { width:100%; margin-bottom:20px } .table th { text-align:left }'
  echo '.table-striped tbody > tr:nth-child(odd) > td { background-color:#f9f9f9 }'
  echo '.pull-left { float:left } .pull-right { float:right } .clear { clear:both }'
  
  # Add custom header styles
  echo '/* ===== CUSTOM HEADER STYLES ===== */'
  echo '.custom-header {'
  echo '  margin-bottom: 20px;'
  echo '  border-bottom: 2px solid #e0e0e0;'
  echo '  padding: 15px;'
  echo '  background: #f8f9fa;'
  echo '}'
  echo '.project-title {'
  echo '  font-size: 24px;'
  echo '  font-weight: bold;'
  echo '  color: #2c3e50;'
  echo '}'
  echo '.report-meta {'
  echo '  display: flex;'
  echo '  justify-content: space-between;'
  echo '  margin-top: 10px;'
  echo '  font-size: 14px;'
  echo '}'
  echo '.publish-date {'
  echo '  color: #7f8c8d;'
  echo '}'
  echo '</style>'
  echo '</head>'
  
  # Insert modified body content
  cat temp.html
} > "$OUTPUT_FILE"

# Only inline specific required JavaScript
for js_file in "apache-maven-fluido-2.0.0-M9.min.js"; do
  if [ -f "${INPUT_DIR}/js/${js_file}" ]; then
    # Extract only essential JS functions (toggleDisplay)
    grep -A 15 'function toggleDisplay' "${INPUT_DIR}/js/${js_file}" > essential.js
    
    js_content=$(< essential.js)
    # Escape special characters for sed
    js_content_escaped=$(printf '%s\n' "$js_content" | sed ':a;N;$!ba;s/\n/\\n/g; s/[\&/]/\\&/g; s/$/\\n/')
    # Replace script reference with inline JavaScript
    sed -i "s|<script src=\"./js/${js_file}\"></script>|<script>${js_content_escaped}</script>|g" "$OUTPUT_FILE"
    rm essential.js
  fi
done

# Only inline specific required images
for img_file in "feather.png" "feather@2x.png"; do
  for sub in images img; do
    if [ -f "${INPUT_DIR}/${sub}/${img_file}" ]; then
      img="${INPUT_DIR}/${sub}/${img_file}"
      # Escape special characters for sed
      safe_img=$(printf '%s\n' "$img_file" | sed 's/[][\/.^$*]/\\&/g')
      # Determine MIME type
      ext="${img_file##*.}"
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
      sed -i "s|src=[\"']${sub}/${safe_img}[\"']|src=\"data:${mime_type};base64,${data}\"|g" "$OUTPUT_FILE"
    fi
  done
done

# Final cleanup
rm "$HEADER_FILE" "$CONTENT_FILE" temp.html