import re

def make_sql_idempotent(file_path):
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # Split into statements
    # We look for INSERT INTO ... VALUES ... ;
    # But some might already have ON CONFLICT or might end in a newline
    
    # Pattern to find INSERT statements and their trailing semicolon or existing ON CONFLICT
    # This regex finds INSERT statements and replaces the final semicolon with ON CONFLICT
    # It handles multiple VALUES rows.
    
    def replace_func(match):
        stmt = match.group(0).strip()
        if 'ON CONFLICT' in stmt:
            return stmt
        if stmt.endswith(';'):
            return stmt[:-1] + ' ON CONFLICT (id) DO NOTHING;'
        return stmt + ' ON CONFLICT (id) DO NOTHING;'

    # Match INSERT statements that end with a semicolon
    # Using a simpler approach: find all INSERT INTO statements and ensure they end correctly
    
    statements = re.split(r';\s*', content)
    new_statements = []
    for stmt in statements:
        stmt = stmt.strip()
        if not stmt:
            continue
        if stmt.startswith('INSERT INTO') and 'ON CONFLICT' not in stmt:
            new_statements.append(stmt + ' ON CONFLICT (id) DO NOTHING;')
        else:
            if stmt.startswith('INSERT INTO'):
                new_statements.append(stmt + ';')
            else:
                new_statements.append(stmt + ';')
                
    with open(file_path, 'w', encoding='utf-8') as f:
        f.write('\n\n'.join(new_statements))

if __name__ == "__main__":
    make_sql_idempotent('bus_ticketing_backend/src/main/resources/data.sql')
    print("Successfully made data.sql idempotent.")
