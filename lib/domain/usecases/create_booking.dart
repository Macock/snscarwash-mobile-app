import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class CreateBooking {
  final BookingRepository repository;

  CreateBooking(this.repository);

  Future<Booking> call(Booking booking) async {
    return await repository.createBooking(booking);
  }
}