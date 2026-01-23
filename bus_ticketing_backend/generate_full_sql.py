import csv

def generate_sql():
    # Process Routes
    routes_sql = []
    with open('route_ids.csv', 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            route_name = row['route']
            route_id = row['route_id']
            origin_dest = row['origin_destination']
            
            parts = None
            for separator in [" TO ", " To ", " to ", " To  "]:
                if separator in origin_dest:
                    parts = origin_dest.split(separator)
                    break
            
            if not parts:
                if " " in origin_dest:
                    words = origin_dest.split()
                    if len(words) >= 2:
                        parts = [" ".join(words[:-1]), words[-1]]
                    else:
                        parts = [origin_dest, ""]
                else:
                    parts = [origin_dest, ""]
            
            origin = parts[0].strip().replace("'", "''")
            destination = parts[1].strip().replace("'", "''") if len(parts) > 1 else ""
            
            routes_sql.append(f"({route_id}, '{route_name}', '{origin}', '{destination}', 0.0)")

    # Process Stops
    stops_sql = []
    with open('stops_id.csv', 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        for row in reader:
            stop_id = row['stop_id']
            stop_name = row['stop_name'].strip().replace("'", "''")
            lat = row['lat'] if row['lat'] else '0.0'
            lng = row['lng'] if row['lng'] else '0.0'
            stops_sql.append(f"({stop_id}, '{stop_name}', {lat}, {lng})")

    # Generate the SQL file
    with open('full_data_import.sql', 'w', encoding='utf-8') as f:
        # Routes
        f.write("INSERT INTO routes (id, route_name, origin, destination, distance) VALUES\n")
        f.write(",\n".join(routes_sql))
        f.write("\nON CONFLICT (id) DO NOTHING;\n\n")
        
        # Stops
        f.write("INSERT INTO bus_stops (id, stop_name, latitude, longitude) VALUES\n")
        f.write(",\n".join(stops_sql))
        f.write("\nON CONFLICT (id) DO NOTHING;\n\n")

if __name__ == "__main__":
    generate_sql()
