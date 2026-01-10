import csv

input_file = r'c:\manikanta chary\my_app\bus_ticketing_backend\route_ids.csv'
output_file = r'c:\manikanta chary\my_app\bus_ticketing_backend\routes_insert.sql'

routes = []
with open(input_file, mode='r', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for i, row in enumerate(reader):
        if i >= 140:
            break
        
        route_name = row['route']
        route_id = row['route_id']
        origin_dest = row['origin_destination']
        
        # Split origin and destination. Some have " TO ", some might just have " "
        if ' TO ' in origin_dest:
            origin, destination = origin_dest.split(' TO ', 1)
        elif ' To ' in origin_dest:
            origin, destination = origin_dest.split(' To ', 1)
        elif ' to ' in origin_dest:
            origin, destination = origin_dest.split(' to ', 1)
        else:
            # Fallback split by space if "TO" is missing
            parts = origin_dest.split(' ')
            if len(parts) >= 2:
                origin = parts[0]
                destination = ' '.join(parts[1:])
            else:
                origin = origin_dest
                destination = ""
        
        # Clean up
        origin = origin.strip().replace("'", "''")
        destination = destination.strip().replace("'", "''")
        route_name = route_name.strip().replace("'", "''")
        
        routes.append(f"({route_id}, '{route_name}', '{origin}', '{destination}')")

with open(output_file, mode='w', encoding='utf-8') as f:
    f.write("DELETE FROM Route;\n")
    f.write("INSERT INTO Route (id, routeName, origin, destination) VALUES\n")
    f.write(",\n".join(routes) + ";\n")
