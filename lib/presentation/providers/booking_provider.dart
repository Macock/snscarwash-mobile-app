// Update your BookingProvider class with this addition

import 'package:flutter/material.dart';
import '../../domain/entities/booking.dart';
import '../../domain/repositories/firebase_repository.dart';

class BookingProvider extends ChangeNotifier {
  final FirebaseRepository _repository;

  BookingProvider(this._repository);

  bool _isLoading = false;
  String? _error;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Add this alias method for backward compatibility with BookingScreen
  Future<bool> book({
    required String userId,
    required String userName,
    required String userEmail,
    required String carWashId,
    required String carWashName,
    required String carWashAddress,
    required DateTime date,
    required String time,
    required String paymentMethod,
  }) async {
    return await createBooking(
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

  Future<bool> createBooking({
    required String userId,
    required String userName,
    required String userEmail,
    required String carWashId,
    required String carWashName,
    required String carWashAddress,
    required DateTime date,
    required String time,
    required String paymentMethod,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.createBooking(
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
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Stream<List<Booking>> getUserBookingsStream(String userId) {
    return _repository.getUserBookings(userId);
  }

  Stream<List<Booking>> getAllBookingsStream() {
    return _repository.getAllBookings();
  }

  Future<void> updateStatus(String bookingId, BookingStatus status) async {
    try {
      await _repository.updateBookingStatus(bookingId, status);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    try {
      await _repository.deleteBooking(bookingId);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}