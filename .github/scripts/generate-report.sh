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
  
  # Add custom styles
  echo '<style>'
  
  # Inline all CSS files
  [ -d "${INPUT_DIR}/css" ] && find "${INPUT_DIR}/css" -name '*.css' -exec cat {} \;
  
  # Add custom header styles
  echo '
    .custom-header {
      margin-bottom: 20px;
      border-bottom: 2px solid #e0e0e0;
      padding: 15px;
      background: #f8f9fa;
    }
    .project-title {
      font-size: 24px;
      font-weight: bold;
      color: #2c3e50;
    }
    .report-meta {
      display: flex;
      justify-content: space-between;
      margin-top: 10px;
      font-size: 14px;
    }
    .publish-date {
      color: #7f8c8d;
    }
    /* Fix spacing after custom header */
    .container-top {
      margin-top: 0 !important;
    }
    /* Ensure breadcrumb appears correctly */
    .breadcrumb {
      padding: 8px 15px !important;
      margin-bottom: 20px !important;
    }
  '
  echo '</style>'
  echo '</head>'
  
  # Insert modified body content
  cat temp.html
} > "$OUTPUT_FILE"

# Inline JavaScript
while IFS= read -r js_path; do
  [ -f "${INPUT_DIR}/${js_path}" ] || continue
  js_content=$(< "${INPUT_DIR}/${js_path}")
  
  # Escape special characters for sed
  js_content_escaped=$(printf '%s\n' "$js_content" | sed ':a;N;$!ba;s/\n/\\n/g; s/[\&/]/\\&/g; s/$/\\n/')
  
  # Replace script reference with inline JavaScript
  sed -i "s|<script src=\"${js_path}\"></script>|<script>${js_content_escaped}</script>|g" "$OUTPUT_FILE"
done < <(grep -o 'src="[^"]*\.js"' "$CONTENT_FILE" | sed 's/src="//;s/"//')

# Inline images
for sub in images img; do
  dir="${INPUT_DIR}/${sub}"
  if [ -d "$dir" ]; then
    for img in "$dir"/*.{png,jpg,jpeg,gif,svg}; do
      [ -f "$img" ] || continue
      base_img=$(basename "$img")
      
      # Escape special characters for sed
      safe_img=$(printf '%s\n' "$base_img" | sed 's/[][\/.^$*]/\\&/g')
      
      # Determine MIME type
      ext="${img##*.}"
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
      sed -i "s|url([\"']${sub}/${safe_img}[\"'])|url(data:${mime_type};base64,${data})|g" "$OUTPUT_FILE"
    done
  fi
done

# Final cleanup
rm "$HEADER_FILE" "$CONTENT_FILE" temp.html