import '../../domain/repositories/repositories.dart';
import '../../domain/use_cases/message_use_cases.dart';
import '../../data/data_sources/data_sources.dart';
import '../../data/repositories/repository_impl.dart';
import '../../services/audio_state/domain/repositories/audio_state_repository.dart';
import '../../services/audio_state/domain/usecases/audio_state_usecases.dart';
import '../../services/audio_state/data/repositories/audio_state_repository_impl.dart';
import '../../services/audio_state/data/datasources/audio_state_remote_datasource.dart';
import '../../../../../chat_ui/src/conversations/di/conversations_service_locator.dart';

/// Service Locator for clean architecture dependency injection

class SharedUiServiceLocator {
  static final SharedUiServiceLocator _instance = SharedUiServiceLocator._internal();

  // Repository instances
  late MessageRepository _messageRepository;
  late UserRepository _userRepository;
  late GroupRepository _groupRepository;
  late AudioStateRepository _audioStateRepository;
  // Use case instances
  late GetMessagesUseCase _getMessagesUseCase;
  late SendMessageUseCase _sendMessageUseCase;
  late SearchMessagesUseCase _searchMessagesUseCase;
  late DeleteMessageUseCase _deleteMessageUseCase;
  late MarkMessagesAsReadUseCase _markMessagesAsReadUseCase;
  late GetUnreadCountUseCase _getUnreadCountUseCase;

  // Audio state use cases
  late GetAudioStateUseCase _getAudioStateUseCase;
  late PlayAudioUseCase _playAudioUseCase;
  late PauseAudioUseCase _pauseAudioUseCase;
  late StopAudioUseCase _stopAudioUseCase;
  late SeekAudioUseCase _seekAudioUseCase;
  late GetAudioStateStreamUseCase _getAudioStateStreamUseCase;

  SharedUiServiceLocator._internal();

  /// Get singleton instance
  factory SharedUiServiceLocator() {
    return _instance;
  }

  /// Initialize all dependencies and BLoCs
  /// Call this once during app startup
  static Future<void> setup() async {
    final instance = SharedUiServiceLocator();

    // Initialize conversations service locator
    await ConversationsServiceLocator.instance.setupAsync();

    // Initialize data sources
    final messageDataSource = MessageDataSourceImpl();
    final userDataSource = UserDataSourceImpl();
    final groupDataSource = GroupDataSourceImpl();
    final audioStateDataSource = AudioStateRemoteDataSourceImpl();

    // Initialize repositories
    instance._messageRepository = MessageRepositoryImpl(dataSource: messageDataSource);
    instance._userRepository = UserRepositoryImpl(dataSource: userDataSource);
    instance._groupRepository = GroupRepositoryImpl(dataSource: groupDataSource);
    instance._audioStateRepository = AudioStateRepositoryImpl(remoteDataSource: audioStateDataSource);

    // Initialize use cases
    instance._getMessagesUseCase = GetMessagesUseCase(
      repository: instance._messageRepository,
    );
    instance._sendMessageUseCase = SendMessageUseCase(
      repository: instance._messageRepository,
    );
    instance._searchMessagesUseCase = SearchMessagesUseCase(
      repository: instance._messageRepository,
    );
    instance._deleteMessageUseCase = DeleteMessageUseCase(
      repository: instance._messageRepository,
    );
    instance._markMessagesAsReadUseCase = MarkMessagesAsReadUseCase(
      repository: instance._messageRepository,
    );
    instance._getUnreadCountUseCase = GetUnreadCountUseCase(
      repository: instance._messageRepository,
    );

    // Initialize audio state use cases
    instance._getAudioStateUseCase = GetAudioStateUseCase(instance._audioStateRepository);
    instance._playAudioUseCase = PlayAudioUseCase(instance._audioStateRepository);
    instance._pauseAudioUseCase = PauseAudioUseCase(instance._audioStateRepository);
    instance._stopAudioUseCase = StopAudioUseCase(instance._audioStateRepository);
    instance._seekAudioUseCase = SeekAudioUseCase(instance._audioStateRepository);
    instance._getAudioStateStreamUseCase = GetAudioStateStreamUseCase(instance._audioStateRepository);

    // BLoCs removed - using controllers instead
  }

  // Repository accessors
  MessageRepository get messageRepository => _messageRepository;
  UserRepository get userRepository => _userRepository;
  GroupRepository get groupRepository => _groupRepository;
  AudioStateRepository get audioStateRepository => _audioStateRepository;

  // Use case accessors
  GetMessagesUseCase get getMessagesUseCase => _getMessagesUseCase;
  SendMessageUseCase get sendMessageUseCase => _sendMessageUseCase;
  SearchMessagesUseCase get searchMessagesUseCase => _searchMessagesUseCase;
  DeleteMessageUseCase get deleteMessageUseCase => _deleteMessageUseCase;
  MarkMessagesAsReadUseCase get markMessagesAsReadUseCase => _markMessagesAsReadUseCase;
  GetUnreadCountUseCase get getUnreadCountUseCase => _getUnreadCountUseCase;

  // Audio state use case accessors
  GetAudioStateUseCase get getAudioStateUseCase => _getAudioStateUseCase;
  PlayAudioUseCase get playAudioUseCase => _playAudioUseCase;
  PauseAudioUseCase get pauseAudioUseCase => _pauseAudioUseCase;
  StopAudioUseCase get stopAudioUseCase => _stopAudioUseCase;
  SeekAudioUseCase get seekAudioUseCase => _seekAudioUseCase;
  GetAudioStateStreamUseCase get getAudioStateStreamUseCase => _getAudioStateStreamUseCase;

  /// Returns a map of all services for integration
  Map<String, dynamic> asMap() {
    return {
      'messageRepository': _messageRepository,
      'userRepository': _userRepository,
      'groupRepository': _groupRepository,
      'audioStateRepository': _audioStateRepository,
      'getMessagesUseCase': _getMessagesUseCase,
      'sendMessageUseCase': _sendMessageUseCase,
      'searchMessagesUseCase': _searchMessagesUseCase,
      'deleteMessageUseCase': _deleteMessageUseCase,
      'markMessagesAsReadUseCase': _markMessagesAsReadUseCase,
      'getUnreadCountUseCase': _getUnreadCountUseCase,
      'getAudioStateUseCase': _getAudioStateUseCase,
      'playAudioUseCase': _playAudioUseCase,
      'pauseAudioUseCase': _pauseAudioUseCase,
      'stopAudioUseCase': _stopAudioUseCase,
      'seekAudioUseCase': _seekAudioUseCase,
      'getAudioStateStreamUseCase': _getAudioStateStreamUseCase,
    };
  }

  /// Reset all services (useful for testing)
  static Future<void> reset() async {
    // Reset conversations service locator
    await ConversationsServiceLocator.instance.reset();
    // Services can be re-initialized if needed
  }

  /// Cleanup resources
  static Future<void> cleanup() async {
    // Cleanup conversations service locator
    await ConversationsServiceLocator.instance.reset();
    // Cleanup if needed
  }
}
