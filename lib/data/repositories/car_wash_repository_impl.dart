import '../../domain/entities/car_wash.dart';
import '../../domain/repositories/car_wash_repository.dart';
import '../datasources/local_datasource.dart';

class CarWashRepositoryImpl implements CarWashRepository {
  final LocalDataSource localDataSource;

  CarWashRepositoryImpl(this.localDataSource);

  @override
  Future<List<CarWash>> getAllCarWashes() async {
    return await localDataSource.getCarWashes();
  }

  @override
  Future<CarWash> getCarWashById(String id) async {
    return await localDataSource.getCarWashById(id);
  }

  @override
  Future<List<CarWash>> getFavorites() async {
    return await localDataSource.getFavorites();
  }

  @override
  Future<void> addToFavorites(String carWashId) async {
    await localDataSource.addToFavorites(carWashId);
  }

  @override
  Future<void> removeFromFavorites(String carWashId) async {
    await localDataSource.removeFromFavorites(carWashId);
  }
}