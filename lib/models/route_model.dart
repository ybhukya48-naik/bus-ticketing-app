class BusRoute {
  final int id;
  final String routeName;
  final String origin;
  final String destination;
  final double? distance;

  BusRoute({
    required this.id,
    required this.routeName,
    required this.origin,
    required this.destination,
    this.distance,
  });

  factory BusRoute.fromJson(Map<String, dynamic> json) {
    return BusRoute(
      id: json['id'],
      routeName: json['routeName'],
      origin: json['origin'],
      destination: json['destination'],
      distance: json['distance']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'routeName': routeName,
      'origin': origin,
      'destination': destination,
      'distance': distance,
    };
  }
}
