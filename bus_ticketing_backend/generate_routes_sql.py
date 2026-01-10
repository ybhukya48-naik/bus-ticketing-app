import csv

def parse_route_data(file_path):
    routes = []
    with open(file_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            route_name = row['route']
            route_id = row['route_id']
            origin_dest = row['origin_destination']
            
            # Split origin and destination
            # Try " TO " (case insensitive)
            parts = None
            for separator in [" TO ", " To ", " to ", " To  "]:
                if separator in origin_dest:
                    parts = origin_dest.split(separator)
                    break
            
            if not parts:
                # Try space if no " TO "
                if " " in origin_dest:
                    # Special case for some entries that might just have a space
                    # But be careful with spaces in names
                    # For now, let's assume if no " TO ", the last word is the destination
                    words = origin_dest.split()
                    if len(words) >= 2:
                        parts = [" ".join(words[:-1]), words[-1]]
                    else:
                        parts = [origin_dest, ""]
                else:
                    parts = [origin_dest, ""]
            
            origin = parts[0].strip()
            destination = parts[1].strip() if len(parts) > 1 else ""
            
            routes.append(f"({route_id}, '{route_name}', '{origin}', '{destination}', 0.0)")
    
    return routes

def parse_stop_data(file_path):
    stops = []
    with open(file_path, 'r') as f:
        reader = csv.DictReader(f)
        for row in reader:
            stop_id = row['stop_id']
            stop_name = row['stop_name'].strip().replace("'", "''")
            lat = row['lat'] if row['lat'] else '0.0'
            lng = row['lng'] if row['lng'] else '0.0'
            stops.append(f"({stop_id}, '{stop_name}', {lat}, {lng})")
    return stops

def generate_bus_data():
    buses = [
        "(1, 'TS09UB1234', '10H', 40, 25, 'Secunderabad', 4.5, 25.0, '2084,1027,953')",
        "(2, 'TS09UB5678', '222A', 40, 15, 'Koti', 4.2, 35.0, '15,16,88')",
        "(3, 'TS09UB9012', '113M/W', 40, 30, 'Uppal', 4.8, 40.0, '2140,1265,398')",
        "(4, 'TS09UB3456', '17H/10H', 40, 10, 'ECIL', 4.0, 30.0, '1027,1265,1554')",
        "(5, 'TS09UB7890', '218L', 40, 20, 'Lingampally', 4.3, 35.0, '398,953,88')",
        "(6, 'TS09UB2468', '10H', 45, 12, 'Kondapur', 4.6, 25.0, '151,152,1027')",
        "(7, 'TS09UB1357', '222A', 42, 28, 'Patancheru', 4.1, 35.0, '16,88,15')",
        "(8, 'TS09UB8642', '113M/K', 38, 5, 'Uppal', 4.7, 45.0, '2140,2142,398')",
        "(9, 'TS09UB9753', '10H/W', 40, 35, 'Waverock', 4.4, 30.0, '1255,1265,2084')",
        "(10, 'TS09UB5432', '1C', 50, 45, 'CBS', 3.9, 15.0, '1438,1440,2084')",
        "(11, 'TS09UB0987', '218L', 40, 18, 'Dilsukhnagar', 4.2, 35.0, '89,953,398')",
        "(12, 'TS09UB6789', '113M/W', 40, 22, 'Wave Rock', 4.5, 40.0, '1266,2140,398')",
        "(13, 'TS09UB1122', '10H/17H', 40, 8, 'Kondapur', 4.3, 30.0, '131,1027,497')",
        "(14, 'TS09UB3344', '17H/10H', 40, 30, 'Waverock', 4.6, 30.0, '1555,1027,1265')",
        "(15, 'TS09UB5566', '10H/W', 40, 15, 'Secunderabad', 4.4, 30.0, '1257,1265,2084')"
    ]
    return buses

routes_sql = parse_route_data('c:\\manikanta chary\\my_app\\bus_ticketing_backend\\route_ids.csv')
stops_sql = parse_stop_data('c:\\manikanta chary\\my_app\\bus_ticketing_backend\\stops_id.csv')
buses_sql = generate_bus_data()

with open('c:\\manikanta chary\\my_app\\bus_ticketing_backend\\src\\main\\resources\\data.sql', 'w') as f:
    f.write("DELETE FROM Route;\n")
    f.write("INSERT INTO Route (id, routeName, origin, destination, distance) VALUES\n")
    f.write(",\n".join(routes_sql) + ";\n\n")
    
    f.write("DELETE FROM BusStop;\n")
    f.write("INSERT INTO BusStop (id, stopName, latitude, longitude) VALUES\n")
    f.write(",\n".join(stops_sql) + ";\n\n")

    f.write("DELETE FROM Bus;\n")
    f.write("INSERT INTO Bus (id, busNumber, route, capacity, availableSeats, currentLocation, rating, price, routeStopsOrder) VALUES\n")
    f.write(",\n".join(buses_sql) + ";\n")
