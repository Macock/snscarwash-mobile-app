import '../../domain/entities/booking.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingModel extends Booking {
  const BookingModel({
    required String id,
    required String userId,
    required String userName,
    required String userEmail,
    required String carWashId,
    required String carWashName,
    required String carWashAddress,
    required DateTime date,
    required String time,
    required String paymentMethod,
    required BookingStatus status,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super(
          id: id,
          userId: userId,
          userName: userName,
          userEmail: userEmail,
          carWashId: carWashId,
          carWashName: carWashName,
          carWashAddress: carWashAddress,
          date: date,
          time: time,
          paymentMethod: paymentMethod,
          status: status,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  factory BookingModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return BookingModel(
      id: doc.id,
      userId: data['userId'] ?? '',
      userName: data['userName'] ?? '',
      userEmail: data['userEmail'] ?? '',
      carWashId: data['carWashId'] ?? '',
      carWashName: data['carWashName'] ?? '',
      carWashAddress: data['carWashAddress'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      time: data['time'] ?? '',
      paymentMethod: data['paymentMethod'] ?? '',
      status: _statusFromString(data['status'] ?? 'pending'),
      createdAt: (data['createdAt'] as Timestamp).toDate(),
      updatedAt: (data['updatedAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'carWashId': carWashId,
      'carWashName': carWashName,
      'carWashAddress': carWashAddress,
      'date': Timestamp.fromDate(date),
      'time': time,
      'paymentMethod': paymentMethod,
      'status': _statusToString(status),
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  static BookingStatus _statusFromString(String status) {
    switch (status) {
      case 'confirmed':
        return BookingStatus.confirmed;
      case 'completed':
        return BookingStatus.completed;
      case 'cancelled':
        return BookingStatus.cancelled;
      default:
        return BookingStatus.pending;
    }
  }

  static String _statusToString(BookingStatus status) {
    switch (status) {
      case BookingStatus.confirmed:
        return 'confirmed';
      case BookingStatus.completed:
        return 'completed';
      case BookingStatus.cancelled:
        return 'cancelled';
      default:
        return 'pending';
    }
  }
}