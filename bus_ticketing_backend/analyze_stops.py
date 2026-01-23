
import requests
import collections

try:
    response = requests.get('http://localhost:8080/api/stops')
    stops = response.json()
    
    stop_names = [s['stopName'].lower().strip() for s in stops]
    counts = collections.Counter(stop_names)
    
    duplicates = {name: count for name, count in counts.items() if count > 1}
    
    print(f"Total stops: {len(stops)}")
    print(f"Total unique names: {len(counts)}")
    print(f"Number of duplicate names: {len(duplicates)}")
    print("\nTop 20 duplicates:")
    for name, count in sorted(duplicates.items(), key=lambda x: x[1], reverse=True)[:20]:
        print(f"{name}: {count}")

except Exception as e:
    print(f"Error: {e}")
