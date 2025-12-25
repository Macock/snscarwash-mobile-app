import '../entities/user.dart';
import '../entities/booking.dart';
import '../entities/car_wash.dart';

abstract class FirebaseRepository {
  // Auth
  Future<User> register(String email, String password, String name);
  Future<User> login(String email, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
  Stream<User?> get authStateChanges;

  // Bookings
  Future<Booking> createBooking({
    required String userId,
    required String userName,
    required String userEmail,
    required String carWashId,
    required String carWashName,
    required String carWashAddress,
    required DateTime date,
    required String time,
    required String paymentMethod,
  });
  Stream<List<Booking>> getUserBookings(String userId);
  Stream<List<Booking>> getAllBookings();
  Future<void> updateBookingStatus(String bookingId, BookingStatus status);
  Future<void> deleteBooking(String bookingId);

  // Car Washes
  Stream<List<CarWash>> getCarWashes();
}
