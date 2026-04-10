import '../domain/repositories/threaded_header_repository.dart';
import '../domain/usecases/get_message_template_usecase.dart';
import '../data/datasources/threaded_header_datasource.dart';
import '../data/repositories/threaded_header_repository_impl.dart';

/// Service Locator for Threaded Header module.
/// Singleton — call [setup] once during app startup.
class ThreadedHeaderServiceLocator {
  static final ThreadedHeaderServiceLocator _instance =
      ThreadedHeaderServiceLocator._internal();
  ThreadedHeaderServiceLocator._internal();
  static ThreadedHeaderServiceLocator get instance => _instance;

  late ThreadedHeaderDataSource _dataSource;
  late ThreadedHeaderRepository _repository;
  late GetMessageTemplateUseCase _getMessageTemplateUseCase;
  late GetAllMessageTemplatesUseCase _getAllMessageTemplatesUseCase;

  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  void setup({ThreadedHeaderDataSource? dataSource}) {
    if (_isInitialized) return;

    _dataSource = dataSource ?? ThreadedHeaderDataSourceImpl();
    _repository = ThreadedHeaderRepositoryImpl(dataSource: _dataSource);
    _getMessageTemplateUseCase = GetMessageTemplateUseCase(_repository);
    _getAllMessageTemplatesUseCase = GetAllMessageTemplatesUseCase(_repository);

    _isInitialized = true;
  }

  GetMessageTemplateUseCase get getMessageTemplateUseCase {
    _ensureInitialized();
    return _getMessageTemplateUseCase;
  }

  GetAllMessageTemplatesUseCase get getAllMessageTemplatesUseCase {
    _ensureInitialized();
    return _getAllMessageTemplatesUseCase;
  }

  ThreadedHeaderRepository get repository {
    _ensureInitialized();
    return _repository;
  }

  /// Ensures the service locator is initialized.
  /// Auto-initializes with default datasource on first access.
  void _ensureInitialized() {
    if (!_isInitialized) {
      setup();
    }
  }

  Future<void> reset() async { _isInitialized = false; }
}
