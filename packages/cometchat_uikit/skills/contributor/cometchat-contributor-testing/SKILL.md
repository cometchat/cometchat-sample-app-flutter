---
name: cometchat-contributor-testing
description: >
  Use when writing tests for the cometchat_chat_uikit package source code. Covers
  BLoC testing with bloc_test, use case testing, repository testing with mocktail,
  widget testing with flutter_test, coverage targets per layer, test file placement,
  mock patterns, fixture conventions, and running tests from the chat_uikit directory.
  Also use when asking about test coverage, how to mock the SDK, how to test a BLoC,
  or how to write widget tests for CometChat components.
license: MIT
compatibility: "cometchat_chat_uikit ^6.0.0; bloc_test ^9.1.0; mocktail ^1.0.3"
metadata:
  author: CometChat
  version: "1.0.0"
  tags: "cometchat contributor testing bloc-test mocktail widget-test coverage"
---

# CometChat UIKit — Contributor Testing

Testing patterns and coverage targets for the `chat_uikit` package.

## Coverage Targets

| Layer | Target | Rationale |
|-------|--------|-----------|
| BLoC | 90% | Core business logic, most bugs surface here |
| Use Cases | 95% | Pure functions, easy to test exhaustively |
| Repository | 90% | SDK integration boundary |
| Widgets | 80% | UI rendering, harder to cover edge cases |

## Test File Placement

Mirror the `lib/` structure under `test/`:
```
chat_uikit/test/
├── chat_ui/
│   ├── conversations/
│   │   ├── bloc/
│   │   │   └── conversations_bloc_test.dart
│   │   ├── domain/
│   │   │   └── get_conversations_usecase_test.dart
│   │   ├── data/
│   │   │   └── conversations_repository_impl_test.dart
│   │   └── widgets/
│   │       └── cometchat_conversations_test.dart
│   ├── message_list/
│   ├── message_composer/
│   │   └── widgets/
│   │       └── rich_text_toolbar/   # 288 WYSIWYG tests
│   └── ...
└── shared_ui/
    └── rich_text_formatting/        # 164 clean architecture tests
```

## Running Tests

```bash
# All tests — run from chat_uikit/ directory
cd chat_uikit && flutter test

# Specific component
flutter test test/chat_ui/conversations/

# Specific test file
flutter test test/chat_ui/conversations/bloc/conversations_bloc_test.dart

# With coverage
flutter test --coverage
```

## BLoC Testing with bloc_test

```dart
import 'package:bloc_test/bloc_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_test/flutter_test.dart';

// Mock use cases
class MockGetConversationsUseCase extends Mock implements GetConversationsUseCase {}
class MockDeleteConversationUseCase extends Mock implements DeleteConversationUseCase {}

void main() {
  late ConversationsBloc bloc;
  late MockGetConversationsUseCase mockGetConversations;

  setUp(() {
    mockGetConversations = MockGetConversationsUseCase();
    bloc = ConversationsBloc(
      getConversationsUseCase: mockGetConversations,
      // ... other use cases
    );
  });

  tearDown(() => bloc.close());

  blocTest<ConversationsBloc, ConversationsState>(
    'emits [Loading, Loaded] when LoadConversations succeeds',
    build: () {
      when(() => mockGetConversations.call(any()))
          .thenAnswer((_) async => Success([mockConversation]));
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadConversations()),
    expect: () => [
      isA<ConversationsLoading>(),
      isA<ConversationsLoaded>()
          .having((s) => s.conversations.length, 'count', 1),
    ],
  );

  blocTest<ConversationsBloc, ConversationsState>(
    'emits [Loading, Error] when LoadConversations fails',
    build: () {
      when(() => mockGetConversations.call(any()))
          .thenAnswer((_) async => Failure(message: 'Network error'));
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadConversations()),
    expect: () => [
      isA<ConversationsLoading>(),
      isA<ConversationsError>()
          .having((s) => s.message, 'message', 'Network error'),
    ],
  );
}
```

## Use Case Testing

```dart
void main() {
  late GetConversationsUseCase useCase;
  late MockConversationsRepository mockRepo;

  setUp(() {
    mockRepo = MockConversationsRepository();
    useCase = GetConversationsUseCase(mockRepo);
  });

  test('returns conversations from repository', () async {
    when(() => mockRepo.getConversations(any()))
        .thenAnswer((_) async => Success([mockConversation]));

    final result = await useCase.call(GetConversationsParams(limit: 30));

    expect(result, isA<Success<List<Conversation>>>());
    verify(() => mockRepo.getConversations(any())).called(1);
  });
}
```

## Repository Testing

```dart
void main() {
  late ConversationsRepositoryImpl repo;
  late MockRemoteDataSource mockRemote;
  late MockLocalDataSource mockLocal;

  setUp(() {
    mockRemote = MockRemoteDataSource();
    mockLocal = MockLocalDataSource();
    repo = ConversationsRepositoryImpl(
      remoteDataSource: mockRemote,
      localDataSource: mockLocal,
    );
  });

  test('delegates to remote datasource', () async {
    when(() => mockRemote.getConversations(any()))
        .thenAnswer((_) async => [mockConversation]);

    final result = await repo.getConversations(params);

    expect(result, isA<Success>());
    verify(() => mockRemote.getConversations(any())).called(1);
  });
}
```

## Widget Testing

```dart
void main() {
  late MockConversationsBloc mockBloc;

  setUp(() {
    mockBloc = MockConversationsBloc();
  });

  testWidgets('shows loading shimmer when state is Loading', (tester) async {
    when(() => mockBloc.state).thenReturn(const ConversationsLoading());

    await tester.pumpWidget(
      MaterialApp(
        home: BlocProvider<ConversationsBloc>.value(
          value: mockBloc,
          child: const CometChatConversations(),
        ),
      ),
    );

    expect(find.byType(CometChatShimmerEffect), findsOneWidget);
  });
}
```

## Mock Patterns

```dart
// Mock BLoC for widget tests
class MockConversationsBloc extends MockBloc<ConversationsEvent, ConversationsState>
    implements ConversationsBloc {}

// Mock SDK classes
class MockCometChat extends Mock implements CometChat {}

// Register fallback values for mocktail
setUpAll(() {
  registerFallbackValue(ConversationsRequestBuilder());
  registerFallbackValue(const LoadConversations());
});
```

## Rich Text Test Suites

Two separate test suites — don't confuse them:

| Suite | Location | Count | Tests |
|-------|----------|-------|-------|
| WYSIWYG (active runtime) | `test/chat_ui/message_composer/widgets/rich_text_toolbar/` | 288 | Span tracking, markdown rendering, format application |
| Clean Architecture (test-only) | `test/shared_ui/rich_text_formatting/` | 164 | Repository, datasource, use case layers |

Bug fixes go in WYSIWYG tests. The clean architecture tests validate the unused module.

## Gotchas

- Always `tearDown(() => bloc.close())` — BLoC tests that don't close the BLoC leak SDK listeners.
- `blocTest` runs events asynchronously. If your BLoC does async work in event handlers, use `wait: Duration(milliseconds: 100)` or increase the default.
- `registerFallbackValue` must be called in `setUpAll` for any custom types used with `any()` in mocktail.
- Widget tests need `MaterialApp` wrapper for theme resolution. CometChat widgets call `CometChatThemeHelper.getColorPalette(context)` which needs `Theme.of(context)`.
- Use `network_image_mock` package for tests that render `CachedNetworkImage` (avatars, image bubbles).

## Anti-Patterns

```dart
// ❌ WRONG — testing implementation details
blocTest(
  'calls repository.getConversations exactly once',
  // This tests HOW, not WHAT
)

// ✅ CORRECT — testing behavior
blocTest(
  'emits Loaded with 5 conversations when repository returns 5',
  // This tests WHAT the BLoC produces
)
```

```dart
// ❌ WRONG — not closing BLoC in tearDown
setUp(() { bloc = ConversationsBloc(...); });
// Missing tearDown → listener leaks across tests

// ✅ CORRECT
setUp(() { bloc = ConversationsBloc(...); });
tearDown(() => bloc.close());
```

```dart
// ❌ WRONG — testing the clean architecture rich text module for a WYSIWYG bug
// test/shared_ui/rich_text_formatting/ tests are for the unused module

// ✅ CORRECT — test WYSIWYG system for runtime bugs
// test/chat_ui/message_composer/widgets/rich_text_toolbar/
```

## Checklist — Before Submitting Tests

- [ ] BLoC tests cover: initial load, pagination, error, real-time events, edge cases
- [ ] Use case tests cover: success, failure, parameter validation
- [ ] Repository tests verify delegation to correct datasource
- [ ] Widget tests cover: loading, loaded, empty, error states
- [ ] All BLoCs closed in `tearDown`
- [ ] `registerFallbackValue` called for custom types
- [ ] Tests run from `chat_uikit/` directory
- [ ] Coverage meets targets: BLoC 90%, UseCase 95%, Repo 90%, Widget 80%
