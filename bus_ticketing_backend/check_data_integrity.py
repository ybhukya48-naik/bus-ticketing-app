
import re

with open('src/main/resources/data.sql', 'r') as f:
    content = f.read()

# Extract buses
bus_matches = re.findall(r"INSERT INTO buses .*? VALUES\s*(.*?);", content, re.DOTALL)
all_stop_ids = set()
for match in bus_matches:
    rows = re.findall(r"\((.*?)\)", match)
    for row in rows:
        parts = [p.strip().strip("'") for p in row.split(',')]
        if len(parts) >= 9:
            stops_order = parts[8]
            ids = [id.strip() for id in stops_order.split(',')]
            all_stop_ids.update(ids)

print(f"Total unique stop IDs used in buses: {len(all_stop_ids)}")

# Check if these IDs exist in bus_stops
stop_ids_in_sql = set()
stop_matches = re.findall(r"INSERT INTO bus_stops .*? VALUES\s*(.*?);", content, re.DOTALL)
for match in stop_matches:
    rows = re.findall(r"\((.*?)\)", match)
    for row in rows:
        parts = [p.strip() for p in row.split(',')]
        if len(parts) >= 1:
            stop_ids_in_sql.add(parts[0])

missing_ids = all_stop_ids - stop_ids_in_sql
print(f"Stop IDs used in buses but missing from bus_stops: {len(missing_ids)}")
if missing_ids:
    print(f"Example missing IDs: {list(missing_ids)[:10]}")
