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

# Process original report
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
  # Extract original head section
  sed -n '/<head>/,/<\/head>/p' "$CONTENT_FILE"
  
  # Add custom styles
  echo '<style>'
  echo '  .custom-header {'
  echo '    margin-bottom: 20px;'
  echo '    border-bottom: 2px solid #e0e0e0;'
  echo '    padding: 15px;'
  echo '    background: #f8f9fa;'
  echo '  }'
  echo '  .project-title {'
  echo '    font-size: 24px;'
  echo '    font-weight: bold;'
  echo '    color: #2c3e50;'
  echo '  }'
  echo '  .report-meta {'
  echo '    display: flex;'
  echo '    justify-content: space-between;'
  echo '    margin-top: 10px;'
  echo '    font-size: 14px;'
  echo '  }'
  echo '  .publish-date {'
  echo '    color: #7f8c8d;'
  echo '  }'
  echo '</style>'
  echo '</head>'
  
  # Insert modified body content
  cat temp.html
} > "$OUTPUT_FILE"

# Inline all CSS files
[ -d "${INPUT_DIR}/css" ] && find "${INPUT_DIR}/css" -name '*.css' -exec cat {} \; >> "$OUTPUT_FILE"

# Inline images as Base64
for sub in images img; do
  dir="${INPUT_DIR}/${sub}"
  if [ -d "$dir" ]; then
    for img in "$dir"/*.{png,jpg,jpeg,gif,svg}; do
      [ -f "$img" ] || continue
      base_img=$(basename "$img")
      # Escape special characters for sed
      safe_img=$(printf '%s\n' "$base_img" | sed 's/[][\/.^$*]/\\&/g')
      ext="${img##*.}"
      if [ "$ext" = "svg" ]; then
        mime_type="image/svg+xml"
      else
        mime_type="image/$ext"
      fi
      data=$(base64 -w0 "$img")
      # Use a temporary file for sed in-place editing
      sed -i.tmp "s|src=[\"']${sub}/${safe_img}[\"']|src=\"data:${mime_type};base64,${data}\"|gI" "$OUTPUT_FILE"
      rm -f "$OUTPUT_FILE.tmp"
    done
  fi
done

# Clean up
rm "$HEADER_FILE" "$CONTENT_FILE" temp.html 