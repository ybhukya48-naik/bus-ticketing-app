
import re
import os

def fix_sql_syntax(file_path):
    if not os.path.exists(file_path):
        print(f"File {file_path} not found.")
        return

    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Find patterns like:
    # );
    # ON CONFLICT (id) DO NOTHING;
    # and replace with:
    # )
    # ON CONFLICT (id) DO NOTHING;
    
    # We need to be careful to only replace the semicolon that precedes ON CONFLICT
    pattern = re.compile(r'\);\s+ON CONFLICT \(id\) DO NOTHING;', re.MULTILINE | re.IGNORECASE)
    new_content = pattern.sub(r')\nON CONFLICT (id) DO NOTHING;', content)

    # Also handle cases where there might be multiple spaces or newlines
    pattern2 = re.compile(r'\);\s*\n\s*ON CONFLICT \(id\) DO NOTHING;', re.MULTILINE | re.IGNORECASE)
    new_content = pattern2.sub(r')\nON CONFLICT (id) DO NOTHING;', new_content)

    if content != new_content:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Fixed syntax in {file_path}")
    else:
        print(f"No changes needed in {file_path}")

if __name__ == "__main__":
    sql_file = "src/main/resources/data.sql"
    fix_sql_syntax(sql_file)
