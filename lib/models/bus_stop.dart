class BusStop {
  final int id;
  final String stopName;
  final double latitude;
  final double longitude;

  BusStop({
    required this.id,
    required this.stopName,
    required this.latitude,
    required this.longitude,
  });

  factory BusStop.fromJson(Map<String, dynamic> json) {
    return BusStop(
      id: json['id'],
      stopName: json['stopName'],
      latitude: json['latitude'],
      longitude: json['longitude'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'stopName': stopName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
