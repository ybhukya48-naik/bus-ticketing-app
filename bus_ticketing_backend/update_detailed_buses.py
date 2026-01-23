import os
import csv
import re

def process_detailed_routes():
    base_path = r'c:\manikanta chary\my_app\bus_ticketing_backend'
    data_sql_path = os.path.join(base_path, 'src', 'main', 'resources', 'data.sql')
    
    # Detailed route CSVs
    detailed_files = ['1005.csv', '1126.csv', '1127.csv', '151.csv', '152.csv']
    route_details = {}

    for filename in detailed_files:
        filepath = os.path.join(base_path, filename)
        if os.path.exists(filepath):
            stops = []
            route_id = None
            with open(filepath, 'r', encoding='utf-8') as f:
                reader = csv.reader(f)
                for row in reader:
                    if len(row) >= 5:
                        stops.append(row[0])
                        route_id = row[4]
            if route_id and stops:
                route_details[route_id] = ",".join(stops)

    # Route ID to Name mapping from route_ids.csv
    route_names = {}
    with open(os.path.join(base_path, 'route_ids.csv'), 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            route_names[row['route_id']] = row['route']

    # Read current data.sql
    with open(data_sql_path, 'r', encoding='utf-8') as f:
        lines = f.readlines()

    # Find buses insert section
    buses_start_idx = -1
    buses_end_idx = -1
    for i, line in enumerate(lines):
        if "INSERT INTO buses" in line:
            buses_start_idx = i
        if buses_start_idx != -1 and (line.strip().endswith("DO NOTHING;") or line.strip() == ""):
            if i > buses_start_idx:
                buses_end_idx = i

    if buses_start_idx != -1:
        # Generate new bus entries
        new_buses = []
        # Keep existing buses but update them if they match our detailed routes
        # For simplicity, we'll just add new buses for these detailed routes
        bus_id_counter = 31 # Starting after the existing 30
        
        for r_id, stops_order in route_details.items():
            r_name = route_names.get(r_id, f"Route_{r_id}")
            bus_num = f"TS09UB{bus_id_counter:04d}"
            # Find a realistic origin from the stops?
            # For now just placeholders
            new_buses.append(f"({bus_id_counter}, '{bus_num}', '{r_name}', 40, 20, 'Station', 4.5, 30.0, '{stops_order}')")
            bus_id_counter += 1

        if new_buses:
            # We'll append them to the existing INSERT INTO buses
            # Find the last entry line
            last_entry_idx = -1
            for i in range(buses_end_idx, buses_start_idx, -1):
                if lines[i].strip().endswith(");") or lines[i].strip().endswith("),"):
                    last_entry_idx = i
                    break
            
            if last_entry_idx != -1:
                # Change last entry's ending to comma if it was semicolon
                if lines[last_entry_idx].strip().endswith("DO NOTHING;"):
                    # This is tricky because it's a multi-line insert
                    # Let's just rewrite the whole buses section for safety
                    pass

    # Alternative: Just print the new SQL for now or append it as a new block
    # Given the complexity of parsing the existing block, I'll just append a new block
    # for these specific detailed buses.
    
    extra_buses_sql = "\n-- Detailed route buses\nINSERT INTO buses (id, bus_number, route, capacity, available_seats, current_location, rating, price, route_stops_order) VALUES\n"
    bus_id_counter = 31
    entries = []
    for r_id, stops_order in route_details.items():
        r_name = route_names.get(r_id, f"Route_{r_id}")
        bus_num = f"TS09UB{1000 + bus_id_counter}"
        entries.append(f"({bus_id_counter}, '{bus_num}', '{r_name}', 40, 20, 'Station', 4.5, 30.0, '{stops_order}')")
        bus_id_counter += 1
    
    extra_buses_sql += ",\n".join(entries) + "\nON CONFLICT (id) DO NOTHING;\n"

    # Insert before the sequence resets
    reset_idx = -1
    for i, line in enumerate(lines):
        if "-- Reset sequences" in line:
            reset_idx = i
            break
    
    if reset_idx != -1:
        lines.insert(reset_idx, extra_buses_sql)
    else:
        lines.append(extra_buses_sql)

    with open(data_sql_path, 'w', encoding='utf-8') as f:
        f.writelines(lines)
    print("Successfully updated data.sql with detailed route buses.")

if __name__ == "__main__":
    process_detailed_routes()
