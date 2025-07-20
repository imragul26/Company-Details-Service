import os
import base64
from bs4 import BeautifulSoup
import sys

def inline_resources(html_path, output_path):
    """Convert an HTML file with external resources to a self-contained file"""
    with open(html_path, 'r', encoding='utf-8') as f:
        soup = BeautifulSoup(f, 'html.parser')
    
    base_dir = os.path.dirname(html_path)
    
    # Inline CSS files
    for link in soup.find_all('link', rel='stylesheet'):
        if link.get('href'):
            css_path = os.path.join(base_dir, link['href'])
            try:
                with open(css_path, 'r', encoding='utf-8') as css_file:
                    css_content = css_file.read()
                style_tag = soup.new_tag('style')
                style_tag.string = css_content
                link.replace_with(style_tag)
            except Exception as e:
                print(f"⚠️ Skipping CSS: {css_path} - {str(e)}")
    
    # Inline images
    for img in soup.find_all('img'):
        if img.get('src'):
            img_path = os.path.join(base_dir, img['src'])
            try:
                with open(img_path, 'rb') as img_file:
                    img_data = img_file.read()
                ext = os.path.splitext(img_path)[1][1:].lower()
                if ext == 'svg': 
                    mime_type = 'image/svg+xml'
                else:
                    mime_type = f'image/{ext}'
                b64_data = base64.b64encode(img_data).decode('utf-8')
                img['src'] = f"data:{mime_type};base64,{b64_data}"
            except Exception as e:
                print(f"⚠️ Skipping image: {img_path} - {str(e)}")
    
    # Inline JavaScript
    for script in soup.find_all('script'):
        if script.get('src'):
            js_path = os.path.join(base_dir, script['src'])
            try:
                with open(js_path, 'r', encoding='utf-8') as js_file:
                    js_content = js_file.read()
                new_script = soup.new_tag('script')
                new_script.string = js_content
                script.replace_with(new_script)
            except Exception as e:
                print(f"⚠️ Skipping JS: {js_path} - {str(e)}")
    
    # Save final HTML
    with open(output_path, 'w', encoding='utf-8') as f:
        f.write(str(soup))
    print(f"✅ Created self-contained report at {output_path}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python inline_report.py <input.html> <output.html>")
        sys.exit(1)
    inline_resources(sys.argv[1], sys.argv[2])