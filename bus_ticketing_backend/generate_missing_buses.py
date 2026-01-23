import re
import random

def generate_missing_buses():
    data_sql_path = r'c:\manikanta chary\my_app\bus_ticketing_backend\src\main\resources\data.sql'
    
    with open(data_sql_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 1. Extract bus stops
    stops = {}
    stop_matches = re.finditer(r'\((\d+),\s*\'(.*?)\',\s*(-?\d+\.\d+),\s*(-?\d+\.\d+)\)', content)
    for match in stop_matches:
        stop_id = match.group(1)
        stop_name = match.group(2).strip().upper()
        stops[stop_name] = stop_id

    # 2. Extract routes
    routes = []
    # (id, route_name, origin, destination, distance)
    route_matches = list(re.finditer(r'\((\d+),\s*\'(.*?)\',\s*\'(.*?)\',\s*\'(.*?)\',\s*(\d+\.\d+)\)', content))
    print(f"Found {len(route_matches)} route matches")
    for match in route_matches:
        routes.append({
            'id': match.group(1),
            'name': match.group(2),
            'origin': match.group(3).strip().upper(),
            'destination': match.group(4).strip().upper()
        })

    # 3. Extract existing buses
    # We want to see which route NAMES are covered, but also which combinations
    existing_bus_configs = set()
    # (id, bus_number, route, capacity, available_seats, current_location, rating, price, route_stops_order)
    bus_matches = re.finditer(r'\((\d+),\s*\'(.*?)\',\s*\'(.*?)\',\s*(\d+),\s*(\d+),\s*\'(.*?)\',\s*(\d+\.\d+),\s*(\d+\.\d+),\s*\'(.*?)\'\)', content)
    for match in bus_matches:
        route_name = match.group(3)
        stops_order = match.group(9)
        existing_bus_configs.add((route_name, stops_order))

    # 4. Generate missing buses
    new_buses = []
    current_bus_id = 1000 # Start from 1000
    
    for route in routes:
        route_name = route['name']
        origin_id = stops.get(route['origin'])
        dest_id = stops.get(route['destination'])
        
        if origin_id and dest_id:
            stops_order = f"{origin_id},{dest_id}"
            if (route_name, stops_order) not in existing_bus_configs:
                bus_num = f"TS09UB{random.randint(2000, 9999)}"
                capacity = 40
                available = random.randint(5, 35)
                location = route['origin'].title()
                rating = round(random.uniform(4.0, 4.9), 1)
                price = float(random.randint(15, 50))
                
                new_buses.append(f"({current_bus_id}, '{bus_num}', '{route_name}', {capacity}, {available}, '{location}', {rating}, {price}, '{stops_order}')")
                current_bus_id += 1
                existing_bus_configs.add((route_name, stops_order))

    if not new_buses:
        print("No missing buses to generate.")
        return

    # 5. Insert into data.sql before the sequence resets
    insert_stmt = "\n-- Automatically generated buses for remaining routes\n"
    insert_stmt += "INSERT INTO buses (id, bus_number, route, capacity, available_seats, current_location, rating, price, route_stops_order) VALUES\n"
    insert_stmt += ",\n".join(new_buses)
    insert_stmt += " ON CONFLICT (id) DO NOTHING;\n\n"

    # Find the position before sequence resets
    reset_pos = content.find("-- Reset sequences")
    if reset_pos != -1:
        new_content = content[:reset_pos] + insert_stmt + content[reset_pos:]
    else:
        new_content = content + insert_stmt

    with open(data_sql_path, 'w', encoding='utf-8') as f:
        f.write(new_content)
    
    print(f"Successfully generated {len(new_buses)} new buses.")

if __name__ == "__main__":
    generate_missing_buses()
