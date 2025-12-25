// presentation/providers/car_wash_provider.dart (ПОЛНОСТЬЮ ОБНОВЛЕННЫЙ)
import 'package:flutter/material.dart';
import '../../domain/entities/car_wash.dart';
import '../../domain/repositories/firebase_repository.dart';
import '../../domain/repositories/car_wash_repository.dart';

class CarWashProvider extends ChangeNotifier {
  final FirebaseRepository? _firebaseRepository;
  final CarWashRepository? _localRepository;

  CarWashProvider({
    FirebaseRepository? firebaseRepository,
    CarWashRepository? localRepository,
  })  : _firebaseRepository = firebaseRepository,
        _localRepository = localRepository;

  List<CarWash> _carWashes = [];
  List<CarWash> _favorites = [];
  bool _isLoading = false;
  String? _error;

  List<CarWash> get carWashes => _carWashes;
  List<CarWash> get favorites => _favorites;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Инициализация - подписка на stream автомоек из Firebase
  void init() {
    if (_firebaseRepository != null) {
      _firebaseRepository!.getCarWashes().listen(
        (carWashes) {
          _carWashes = carWashes;
          notifyListeners();
        },
        onError: (error) {
          _error = error.toString();
          notifyListeners();
        },
      );
    }
  }

  Future<void> loadCarWashes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Если используем Firebase
      if (_firebaseRepository != null) {
        // Данные уже загружаются через stream в init()
        _isLoading = false;
        notifyListeners();
      }
      // Если используем локальный источник
      else if (_localRepository != null) {
        _carWashes = await _localRepository!.getAllCarWashes();
        _isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadFavorites() async {
    try {
      if (_firebaseRepository != null) {
        // TODO: Реализовать избранное в Firebase
        // Пока используем локальную фильтрацию
        _favorites = [];
        notifyListeners();
      } else if (_localRepository != null) {
        _favorites = await _localRepository!.getFavorites();
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> toggleFavorite(String carWashId) async {
    try {
      if (_localRepository != null) {
        final isFavorite = _favorites.any((cw) => cw.id == carWashId);

        if (isFavorite) {
          await _localRepository!.removeFromFavorites(carWashId);
        } else {
          await _localRepository!.addToFavorites(carWashId);
        }
        await loadFavorites();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }
}