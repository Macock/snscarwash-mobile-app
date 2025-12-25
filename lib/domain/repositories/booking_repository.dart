import '../entities/booking.dart';


abstract class BookingRepository {
  Future<Booking> createBooking(Booking booking);
  Future<List<Booking>> getUserBookings(String userId);
  Future<void> cancelBooking(String bookingId);
}