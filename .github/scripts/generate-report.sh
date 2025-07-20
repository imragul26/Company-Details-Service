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
sed 's/Surefire Report/Unit Test Report/g' "${INPUT_DIR}/surefire-report.html" > "$CONTENT_FILE"

# Insert custom header at the beginning of the body
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
  
  echo '<style>'
  # Include original CSS
  [ -d "${INPUT_DIR}/css" ] && find "${INPUT_DIR}/css" -name '*.css' -exec cat {} \;
  # Add custom header styles
  echo '
    .custom-header {
      margin-bottom: 30px;
      border-bottom: 2px solid #e0e0e0;
      padding-bottom: 15px;
    }
    .project-title {
      font-size: 28px;
      font-weight: bold;
      color: #2c3e50;
    }
    .report-meta {
      display: flex;
      justify-content: left;
      margin-top: 10px;
    }
    .publish-date {
      color: #7f8c8d;
    }
  '
  echo '</style>'
  echo '</head>'
  
  # Insert modified body content
  sed -n '/<body[^>]*>/,/<\/body>/p' temp.html
} > "$OUTPUT_FILE"

# Inline images as Base64
for sub in images img logos; do
  dir="${INPUT_DIR}/${sub}"
  if [ -d "$dir" ]; then
    for img in "$dir"/*.{png,jpg,jpeg,gif,svg}; do
      [ -f "$img" ] || continue
      base_img=$(basename "$img")
      # Escape special characters for sed
      safe_img=$(printf '%s\n' "$base_img" | sed 's/[&/\]/\\&/g')
      ext="${img##*.}"
      if [ "$ext" = "svg" ]; then
        mime_type="image/svg+xml"
      else
        mime_type="image/$ext"
      fi
      data=$(base64 -w0 "$img")
      sed -i "s|src=[\"']${sub}/${safe_img}[\"']|src=\"data:${mime_type};base64,${data}\"|g" "$OUTPUT_FILE"
    done
  fi
done

# Clean up
rm "$HEADER_FILE" "$CONTENT_FILE" temp.html