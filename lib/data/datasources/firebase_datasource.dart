import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/booking_model.dart';
import '../models/car_wash_model.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/user.dart';

class FirebaseDataSource {
  final auth.FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  FirebaseDataSource({
    auth.FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
  })  : _firebaseAuth = firebaseAuth ?? auth.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================
  // AUTHENTICATION
  // ============================================

  Future<UserModel> registerWithEmail(
    String email,
    String password,
    String name,
  ) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = credential.user!.uid;

      final userModel = UserModel(
        id: userId,
        email: email,
        name: name,
        walletBalance: 0.0,
        role: UserRole.user,
        createdAt: DateTime.now(),
      );

      await _firestore.collection('users').doc(userId).set(userModel.toFirestore());

      return userModel;
    } catch (e) {
      throw Exception('Ошибка регистрации: $e');
    }
  }

  Future<UserModel> loginWithEmail(String email, String password) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = credential.user!.uid;
      final doc = await _firestore.collection('users').doc(userId).get();

      if (!doc.exists) {
        throw Exception('Пользователь не найден');
      }

      return UserModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Ошибка входа: $e');
    }
  }

  Future<void> logout() async {
    await _firebaseAuth.signOut();
  }

  Future<UserModel?> getCurrentUser() async {
    final currentUser = _firebaseAuth.currentUser;
    if (currentUser == null) return null;

    final doc = await _firestore.collection('users').doc(currentUser.uid).get();
    if (!doc.exists) return null;

    return UserModel.fromFirestore(doc);
  }

  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().asyncMap((authUser) async {
      if (authUser == null) return null;
      final doc = await _firestore.collection('users').doc(authUser.uid).get();
      if (!doc.exists) return null;
      return UserModel.fromFirestore(doc);
    });
  }

  // ============================================
  // BOOKINGS
  // ============================================

  Future<BookingModel> createBooking({
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
    try {
      final now = DateTime.now();
      final bookingData = {
        'userId': userId,
        'userName': userName,
        'userEmail': userEmail,
        'carWashId': carWashId,
        'carWashName': carWashName,
        'carWashAddress': carWashAddress,
        'date': Timestamp.fromDate(date),
        'time': time,
        'paymentMethod': paymentMethod,
        'status': 'pending',
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      };

      final docRef = await _firestore.collection('bookings').add(bookingData);
      final doc = await docRef.get();

      return BookingModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Ошибка создания бронирования: $e');
    }
  }

  Stream<List<BookingModel>> getUserBookings(String userId) {
    return _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
    });
  }

  Stream<List<BookingModel>> getAllBookings() {
    return _firestore
        .collection('bookings')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => BookingModel.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateBookingStatus(String bookingId, BookingStatus status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': _bookingStatusToString(status),
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Ошибка обновления статуса: $e');
    }
  }

  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
    } catch (e) {
      throw Exception('Ошибка удаления бронирования: $e');
    }
  }

  // Helper method for status conversion
  String _bookingStatusToString(BookingStatus status) {
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

  // ============================================
  // CAR WASHES
  // ============================================

  Future<void> seedCarWashes() async {
    final carWashes = [
      const CarWashModel(
        id: '1',
        name: 'Автомойка "Чистота"',
        address: 'проспект Абилкайыр хана, 60',
        rating: 4.8,
        reviewCount: 120,
        latitude: 50.2839,
        longitude: 57.1670,
      ),
      const CarWashModel(
        id: '2',
        name: 'Автомойка "Блеск"',
        address: 'улица Маресьева, 120',
        rating: 4.6,
        reviewCount: 85,
        latitude: 50.3050,
        longitude: 57.1850,
      ),
      const CarWashModel(
        id: '3',
        name: 'Автомойка "Shine"',
        address: 'проспект Санкибай батыра, 25',
        rating: 4.9,
        reviewCount: 200,
        latitude: 50.2650,
        longitude: 57.1450,
      ),
    ];

    for (final carWash in carWashes) {
      await _firestore.collection('carWashes').doc(carWash.id).set({
        'name': carWash.name,
        'address': carWash.address,
        'rating': carWash.rating,
        'reviewCount': carWash.reviewCount,
        'latitude': carWash.latitude,
        'longitude': carWash.longitude,
      });
    }
  }

  Stream<List<CarWashModel>> getCarWashes() {
    return _firestore.collection('carWashes').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return CarWashModel(
          id: doc.id,
          name: data['name'] ?? '',
          address: data['address'] ?? '',
          rating: (data['rating'] ?? 0).toDouble(),
          reviewCount: data['reviewCount'] ?? 0,
          latitude: (data['latitude'] ?? 0).toDouble(),
          longitude: (data['longitude'] ?? 0).toDouble(),
        );
      }).toList();
    });
  }
}