class Bus {
  final String id;
  final String busNumber;
  final String route;
  final int capacity;
  final int availableSeats;
  final String currentLocation;
  final double rating;
  final double price;
  final String? routeStopsOrder;

  Bus({
    required this.id,
    required this.busNumber,
    required this.route,
    required this.capacity,
    required this.availableSeats,
    required this.currentLocation,
    required this.rating,
    required this.price,
    this.routeStopsOrder,
  });

  factory Bus.fromJson(Map<String, dynamic> json) {
    return Bus(
      id: json['id'].toString(),
      busNumber: json['busNumber'],
      route: json['route'],
      capacity: json['capacity'],
      availableSeats: json['availableSeats'],
      currentLocation: json['currentLocation'],
      rating: json['rating'].toDouble(),
      price: json['price'].toDouble(),
      routeStopsOrder: json['routeStopsOrder'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'busNumber': busNumber,
      'route': route,
      'capacity': capacity,
      'availableSeats': availableSeats,
      'currentLocation': currentLocation,
      'rating': rating,
      'price': price,
      'routeStopsOrder': routeStopsOrder,
    };
  }
}
