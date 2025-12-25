import '../../domain/entities/booking.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/local_datasource.dart';
import '../models/booking_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final LocalDataSource localDataSource;

  BookingRepositoryImpl(this.localDataSource);

  @override
  Future<Booking> createBooking(Booking booking) async {
    final now = DateTime.now();
    final bookingModel = BookingModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      carWashId: booking.carWashId,
      userId: booking.userId,
      userName: booking.userName,
      userEmail: booking.userEmail,
      carWashName: booking.carWashName,
      carWashAddress: booking.carWashAddress,
      date: booking.date,
      time: booking.time,
      paymentMethod: booking.paymentMethod,
      status: booking.status,
      createdAt: now,
      updatedAt: now,
    );
    return await localDataSource.createBooking(bookingModel);
  }

  @override
  Future<List<Booking>> getUserBookings(String userId) async {
    return await localDataSource.getUserBookings(userId);
  }

  @override
  Future<void> cancelBooking(String bookingId) async {
    // Реализация отмены бронирования
  }
}