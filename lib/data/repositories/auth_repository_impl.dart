import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final LocalDataSource localDataSource;

  AuthRepositoryImpl(this.localDataSource);

  @override
  Future<User> login(String email, String password) async {
    return await localDataSource.login(email, password);
  }

  @override
  Future<void> logout() async {
    await localDataSource.logout();
  }

  @override
  Future<User?> getCurrentUser() async {
    return await localDataSource.getCurrentUser();
  }
}