import '../entities/car_wash.dart';
import '../repositories/car_wash_repository.dart';

class GetCarWashes {
  final CarWashRepository repository;

  GetCarWashes(this.repository);

  Future<List<CarWash>> call() async {
    return await repository.getAllCarWashes();
  }
}