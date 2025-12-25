import '../../domain/entities/user.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/car_wash.dart';
import '../../domain/repositories/firebase_repository.dart';
import '../datasources/firebase_datasource.dart';

class FirebaseRepositoryImpl implements FirebaseRepository {
  final FirebaseDataSource dataSource;

  FirebaseRepositoryImpl(this.dataSource);

  @override
  Future<User> register(String email, String password, String name) {
    return dataSource.registerWithEmail(email, password, name);
  }

  @override
  Future<User> login(String email, String password) {
    return dataSource.loginWithEmail(email, password);
  }

  @override
  Future<void> logout() {
    return dataSource.logout();
  }

  @override
  Future<User?> getCurrentUser() {
    return dataSource.getCurrentUser();
  }

  @override
  Stream<User?> get authStateChanges => dataSource.authStateChanges;

  @override
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
  }) {
    return dataSource.createBooking(
      userId: userId,
      userName: userName,
      userEmail: userEmail,
      carWashId: carWashId,
      carWashName: carWashName,
      carWashAddress: carWashAddress,
      date: date,
      time: time,
      paymentMethod: paymentMethod,
    );
  }

  @override
  Stream<List<Booking>> getUserBookings(String userId) {
    return dataSource.getUserBookings(userId);
  }

  @override
  Stream<List<Booking>> getAllBookings() {
    return dataSource.getAllBookings();
  }

  @override
  Future<void> updateBookingStatus(String bookingId, BookingStatus status) {
    return dataSource.updateBookingStatus(bookingId, status);
  }

  @override
  Future<void> deleteBooking(String bookingId) {
    return dataSource.deleteBooking(bookingId);
  }

  @override
  Stream<List<CarWash>> getCarWashes() {
    return dataSource.getCarWashes();
  }
}