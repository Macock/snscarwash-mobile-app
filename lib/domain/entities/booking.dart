enum BookingStatus { pending, confirmed, completed, cancelled }

class Booking {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String carWashId;
  final String carWashName;
  final String carWashAddress;
  final DateTime date;
  final String time;
  final String paymentMethod;
  final BookingStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Booking({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.carWashId,
    required this.carWashName,
    required this.carWashAddress,
    required this.date,
    required this.time,
    required this.paymentMethod,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });
}