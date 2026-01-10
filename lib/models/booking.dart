class Booking {
  final String id;
  final String busNumber;
  final String route;
  final String bookingDate;
  final int numberOfSeats;
  final double totalPrice;
  final String? qrCodeData;

  Booking({
    required this.id,
    required this.busNumber,
    required this.route,
    required this.bookingDate,
    required this.numberOfSeats,
    required this.totalPrice,
    this.qrCodeData,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      busNumber: json['busNumber'] ?? '',
      route: json['route'] ?? '',
      bookingDate: json['bookingDate'] ?? '',
      numberOfSeats: json['numberOfSeats'] ?? 0,
      totalPrice: (json['totalPrice'] ?? 0).toDouble(),
      qrCodeData: json['qrCodeData'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'busNumber': busNumber,
      'route': route,
      'bookingDate': bookingDate,
      'numberOfSeats': numberOfSeats,
      'totalPrice': totalPrice,
      'qrCodeData': qrCodeData,
    };
  }
}