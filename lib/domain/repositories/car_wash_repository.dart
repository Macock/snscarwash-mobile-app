import '../entities/car_wash.dart';


abstract class CarWashRepository {
  Future<List<CarWash>> getAllCarWashes();
  Future<CarWash> getCarWashById(String id);
  Future<List<CarWash>> getFavorites();
  Future<void> addToFavorites(String carWashId);
  Future<void> removeFromFavorites(String carWashId);
}