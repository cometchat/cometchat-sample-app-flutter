import '../domain/repositories/users_repository.dart';
import '../domain/usecases/get_users_usecase.dart';
import '../domain/usecases/get_logged_in_user_usecase.dart';
import '../domain/usecases/get_user_usecase.dart';
import '../domain/usecases/block_user_usecase.dart';
import '../domain/usecases/unblock_user_usecase.dart';
import '../data/datasources/users_remote_datasource.dart';
import '../data/datasources/users_local_datasource.dart';
import '../data/repositories/users_repository_impl.dart';

class UsersServiceLocator {
  static final UsersServiceLocator _instance = UsersServiceLocator._internal();
  UsersServiceLocator._internal();
  static UsersServiceLocator get instance => _instance;

  late UsersRemoteDataSource _remoteDataSource;
  late UsersLocalDataSource _localDataSource;
  late UsersRepository _repository;
  late GetUsersUseCase _getUsersUseCase;
  late GetLoggedInUserUseCase _getLoggedInUserUseCase;
  late GetUserUseCase _getUserUseCase;
  late BlockUserUseCase _blockUserUseCase;
  late UnblockUserUseCase _unblockUserUseCase;
  bool _isInitialized = false;

  void setup() {
    if (_isInitialized) return;
    _remoteDataSource = UsersRemoteDataSourceImpl();
    _localDataSource = UsersLocalDataSourceImpl();
    _repository = UsersRepositoryImpl(
      remoteDataSource: _remoteDataSource,
      localDataSource: _localDataSource,
    );
    _getUsersUseCase = GetUsersUseCase(_repository);
    _getLoggedInUserUseCase = GetLoggedInUserUseCase(_repository);
    _getUserUseCase = GetUserUseCase(_repository);
    _blockUserUseCase = BlockUserUseCase(_repository);
    _unblockUserUseCase = UnblockUserUseCase(_repository);
    _isInitialized = true;
  }

  bool get isInitialized => _isInitialized;
  GetUsersUseCase get getUsersUseCase {
    _ensureInitialized();
    return _getUsersUseCase;
  }

  GetLoggedInUserUseCase get getLoggedInUserUseCase {
    _ensureInitialized();
    return _getLoggedInUserUseCase;
  }

  GetUserUseCase get getUserUseCase {
    _ensureInitialized();
    return _getUserUseCase;
  }

  BlockUserUseCase get blockUserUseCase {
    _ensureInitialized();
    return _blockUserUseCase;
  }

  UnblockUserUseCase get unblockUserUseCase {
    _ensureInitialized();
    return _unblockUserUseCase;
  }

  UsersRepository get repository {
    _ensureInitialized();
    return _repository;
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError(
        'UsersServiceLocator is not initialized. Call setup() first.',
      );
    }
  }

  Future<void> reset() async {
    _isInitialized = false;
  }
}
