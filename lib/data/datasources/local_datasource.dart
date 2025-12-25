// data/datasources/local_datasource.dart
import '../models/car_wash_model.dart';
import '../models/booking_model.dart';
import '../models/user_model.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/user.dart';

class LocalDataSource {
  // Автомойки с реальными координатами в Актобе
  final List<CarWashModel> _carWashes = [
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
    const CarWashModel(
      id: '4',
      name: 'Автомойка "Кристалл"',
      address: 'улица Жубанова, 45',
      rating: 4.7,
      reviewCount: 156,
      latitude: 50.2920,
      longitude: 57.1950,
    ),
    const CarWashModel(
      id: '5',
      name: 'Автомойка "Идеал"',
      address: 'улица Айтеке би, 78',
      rating: 4.5,
      reviewCount: 98,
      latitude: 50.2750,
      longitude: 57.1380,
    ),
    const CarWashModel(
      id: '6',
      name: 'Автомойка Express',
      address: 'проспект Алии Молдагуловой, 32',
      rating: 4.8,
      reviewCount: 187,
      latitude: 50.3120,
      longitude: 57.2050,
    ),
  ];

  final List<String> _favorites = [];
  final List<BookingModel> _bookings = [];
  UserModel? _currentUser;

  Future<List<CarWashModel>> getCarWashes() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _carWashes;
  }

  Future<CarWashModel> getCarWashById(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _carWashes.firstWhere((carWash) => carWash.id == id);
  }

  Future<List<CarWashModel>> getFavorites() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _carWashes.where((cw) => _favorites.contains(cw.id)).toList();
  }

  Future<void> addToFavorites(String carWashId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (!_favorites.contains(carWashId)) {
      _favorites.add(carWashId);
    }
  }

  Future<void> removeFromFavorites(String carWashId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _favorites.remove(carWashId);
  }

  Future<BookingModel> createBooking(BookingModel booking) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _bookings.add(booking);
    return booking;
  }

  Future<List<BookingModel>> getUserBookings(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _bookings.where((b) => b.userId == userId).toList();
  }

  Future<UserModel> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    _currentUser = UserModel(
      id: '1',
      email: 'user@example.com',
      name: 'Пользователь',
      walletBalance: 1500.0,
      role: UserRole.user,
      createdAt: DateTime.now(),
    );
    return _currentUser!;
  }

  Future<void> logout() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentUser = null;
  }

  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }
}