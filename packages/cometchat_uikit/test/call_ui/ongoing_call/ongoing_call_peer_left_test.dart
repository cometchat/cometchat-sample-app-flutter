import 'package:bloc_test/bloc_test.dart';
import 'package:cometchat_calls_sdk/cometchat_calls_sdk.dart' hide User;
import 'package:cometchat_sdk/cometchat_sdk.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cometchat_chat_uikit/call_ui/src/call_event_service.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_operations/data/datasources/call_operations_datasource.dart';
import 'package:cometchat_chat_uikit/call_ui/src/call_operations/di/call_operations_service_locator.dart';
import 'package:cometchat_chat_uikit/call_ui/src/ongoing_call/bloc/ongoing_call_bloc.dart';
import 'package:cometchat_chat_uikit/call_ui/src/ongoing_call/bloc/ongoing_call_event.dart';
import 'package:cometchat_chat_uikit/call_ui/src/ongoing_call/bloc/ongoing_call_state.dart';
import 'package:cometchat_chat_uikit/call_ui/src/utils/call_extension_constants.dart';
import 'package:cometchat_chat_uikit/shared_ui/src/cometchat_ui_kit/cometchat_ui_kit.dart';

// ===========================================================================
// Fakes
// ===========================================================================

/// Only the three methods the peer-left teardown path actually reaches are
/// implemented. Anything else throws, so a change that widens the path fails
/// loudly instead of silently hitting the real SDK.
class _FakeCallOperationsDataSource extends Fake
    implements CallOperationsDataSource {
  int endSessionCount = 0;
  int endCallCount = 0;

  @override
  Future<void> waitForCallsSdk() async {}

  @override
  Future<void> endSession() async => endSessionCount++;

  @override
  Future<Call> endCall(String sessionId) async {
    endCallCount++;
    return _call(receiverType: 'user');
  }
}

/// Records the events the bloc processes, so a test can assert that the
/// auto-teardown did — or did not — queue an [EndCallButtonPressed].
///
/// A [BlocObserver] cannot be used for this: `bloc_test` swaps in its own
/// observer that forwards only `onError`, so `onEvent` never reaches a
/// user-supplied one.
class _SpyOngoingCallBloc extends OngoingCallBloc {
  _SpyOngoingCallBloc({
    required super.sessionSettingsBuilder,
    required super.sessionId,
    super.callWorkFlow,
  });

  final List<OngoingCallEvent> seen = [];

  @override
  void onEvent(OngoingCallEvent event) {
    super.onEvent(event);
    seen.add(event);
  }

  int get endCallPresses => seen.whereType<EndCallButtonPressed>().length;
}

// ===========================================================================
// Helpers
// ===========================================================================

const _myUid = 'me';
const _peerUid = 'peer';

Call _call({required String receiverType}) => Call(
  sessionId: 'session_1',
  receiverUid: _peerUid,
  type: 'audio',
  receiverType: receiverType,
);

Participant _participant(String uid) => Participant(uid: uid);

// ===========================================================================
// Tests — auto-teardown when the remote party leaves a 1-on-1 session
//
// Covers ParticipantListChanged / ParticipantLeft -> _evaluatePeerLeft, and
// the four guards it applies: workflow, 1-on-1, locally-ended, and the
// _otherCount participant arithmetic (including excludeUid).
// ===========================================================================

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _FakeCallOperationsDataSource dataSource;

  /// The bloc joins no session here: [CallEventService.isCallsSdkReady] is
  /// false under test, so LoadCallingScreen bails with an error state before
  /// touching the native SDK. The participant handlers under test are
  /// unaffected — they are driven directly.
  _SpyOngoingCallBloc buildBloc({
    CallWorkFlow workFlow = CallWorkFlow.defaultCalling,
  }) => _SpyOngoingCallBloc(
    sessionSettingsBuilder: SessionSettingsBuilder(),
    sessionId: 'session_1',
    callWorkFlow: workFlow,
  );

  setUp(() async {
    await CallOperationsServiceLocator.instance.reset();
    dataSource = _FakeCallOperationsDataSource();
    CallOperationsServiceLocator.instance.setup(dataSource: dataSource);

    CometChatUIKit.loggedInUser = User(uid: _myUid, name: 'Me');
    CallEventService.instance.activeCall = _call(receiverType: 'user');
  });

  tearDown(() async {
    CallEventService.instance.activeCall = null;
    CometChatUIKit.loggedInUser = null;
    await CallOperationsServiceLocator.instance.reset();
  });

  // =========================================================================
  // ParticipantListChanged — the signal iOS actually delivers
  // =========================================================================

  group('ParticipantListChanged', () {
    blocTest<_SpyOngoingCallBloc, OngoingCallState>(
      'ends the call when the list empties on a 1-on-1 call',
      build: buildBloc,
      act: (bloc) => bloc.add(const ParticipantListChanged([])),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.endCallPresses, 1);
        expect(dataSource.endSessionCount, 1);
        expect(dataSource.endCallCount, 1);
      },
    );

    blocTest<_SpyOngoingCallBloc, OngoingCallState>(
      'does not end the call while the peer is still present',
      build: buildBloc,
      act: (bloc) => bloc.add(
        ParticipantListChanged([_participant(_myUid), _participant(_peerUid)]),
      ),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.endCallPresses, 0);
        expect(dataSource.endCallCount, 0);
        expect(bloc.state.participantsList.length, 2);
      },
    );

    blocTest<_SpyOngoingCallBloc, OngoingCallState>(
      'ends the call when only the local user remains',
      build: buildBloc,
      act: (bloc) => bloc.add(ParticipantListChanged([_participant(_myUid)])),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) => expect(bloc.endCallPresses, 1),
    );

    blocTest<_SpyOngoingCallBloc, OngoingCallState>(
      'a peer-present update followed by an empty one ends the call once',
      build: buildBloc,
      act: (bloc) async {
        bloc.add(
          ParticipantListChanged([
            _participant(_myUid),
            _participant(_peerUid),
          ]),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(const ParticipantListChanged([]));
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) => expect(bloc.endCallPresses, 1),
    );
  });

  // =========================================================================
  // ParticipantLeft — platforms that deliver a discrete leave event
  // =========================================================================

  group('ParticipantLeft', () {
    blocTest<_SpyOngoingCallBloc, OngoingCallState>(
      'ends the call even when the list has not refreshed yet',
      build: buildBloc,
      act: (bloc) async {
        // The list still shows both parties; only excludeUid discounts the
        // leaver, so without it this update would look like a live call.
        bloc.add(
          ParticipantListChanged([
            _participant(_myUid),
            _participant(_peerUid),
          ]),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(ParticipantLeft(_participant(_peerUid)));
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.endCallPresses, 1);
        expect(dataSource.endCallCount, 1);
      },
    );

    blocTest<_SpyOngoingCallBloc, OngoingCallState>(
      'does not end the call while another participant remains',
      build: buildBloc,
      act: (bloc) async {
        bloc.add(
          ParticipantListChanged([
            _participant(_myUid),
            _participant(_peerUid),
            _participant('third'),
          ]),
        );
        await Future<void>.delayed(const Duration(milliseconds: 10));
        bloc.add(ParticipantLeft(_participant(_peerUid)));
      },
      wait: const Duration(milliseconds: 50),
      verify: (bloc) => expect(bloc.endCallPresses, 0),
    );
  });

  // =========================================================================
  // Guards
  // =========================================================================

  group('_evaluatePeerLeft guards', () {
    blocTest<_SpyOngoingCallBloc, OngoingCallState>(
      'directCalling (meetings) never auto-ends',
      build: () => buildBloc(workFlow: CallWorkFlow.directCalling),
      act: (bloc) => bloc.add(const ParticipantListChanged([])),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) {
        expect(bloc.endCallPresses, 0);
        expect(dataSource.endCallCount, 0);
      },
    );

    blocTest<_SpyOngoingCallBloc, OngoingCallState>(
      'group calls never auto-end',
      build: () {
        CallEventService.instance.activeCall = _call(receiverType: 'group');
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ParticipantListChanged([])),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) => expect(bloc.endCallPresses, 0),
    );

    blocTest<_SpyOngoingCallBloc, OngoingCallState>(
      'no active call means no auto-end',
      build: () {
        CallEventService.instance.activeCall = null;
        return buildBloc();
      },
      act: (bloc) => bloc.add(const ParticipantListChanged([])),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) => expect(bloc.endCallPresses, 0),
    );

    blocTest<_SpyOngoingCallBloc, OngoingCallState>(
      '_peerLeftHandled latches — a burst of updates ends the call once',
      build: buildBloc,
      // Deliberately no awaits between the adds: they all land before the
      // first teardown completes and sets isCallEndedByMe, so _peerLeftHandled
      // is the only thing that can stop a second end-call sequence.
      act: (bloc) {
        bloc.add(const ParticipantListChanged([]));
        bloc.add(const ParticipantListChanged([]));
        bloc.add(ParticipantLeft(_participant(_peerUid)));
      },
      wait: const Duration(milliseconds: 80),
      verify: (bloc) {
        expect(bloc.endCallPresses, 1);
        expect(dataSource.endSessionCount, 1);
        expect(dataSource.endCallCount, 1);
      },
    );

    blocTest<_SpyOngoingCallBloc, OngoingCallState>(
      'a locally-ended call does not auto-end a second time',
      build: buildBloc,
      act: (bloc) async {
        bloc.add(const EndCallButtonPressed());
        await Future<void>.delayed(const Duration(milliseconds: 30));
        bloc.add(const ParticipantListChanged([]));
      },
      wait: const Duration(milliseconds: 80),
      verify: (bloc) {
        // The one press is the local hangup; the empty list adds no second.
        expect(bloc.endCallPresses, 1);
        expect(dataSource.endCallCount, 1);
      },
    );
  });

  // =========================================================================
  // Pre-join behaviour
  //
  // Reviewed on PR #585: an empty participant list is ambiguous — it can mean
  // "the peer left" or "the peer has not joined yet" — so the question was
  // whether a `_peerEverJoined` latch is needed to stop a call ending before
  // it is answered.
  //
  // It is not, because this bloc cannot exist before the call is answered.
  // Every defaultCalling construction site is post-acceptance
  // (OutgoingCallBloc._onOutgoingCallAccepted, IncomingCallBloc after
  // acceptCall, and the two VoIP accept paths in master_app); the two
  // remaining sites pass directCalling, which the first guard rejects.
  // OutgoingCallBloc — the screen that is up while the callee's device rings
  // — never joins a session at all. Listeners are also attached only after
  // startSession succeeds, so no callback can arrive before the local join.
  //
  // A latch keyed on `_otherCount(...) > 0` would also be unsafe here: on iOS
  // the native Calls SDK emits no participant join/leave events, so if a
  // populated list never arrives the latch would never set and the teardown
  // this PR adds would silently stop working.
  //
  // The test below pins that decision: teardown on an empty list is
  // unconditional by design, not by oversight.
  // =========================================================================

  group('pre-join behaviour (documents the no-latch decision)', () {
    blocTest<_SpyOngoingCallBloc, OngoingCallState>(
      'an empty list ends the call even if no peer was ever seen',
      build: buildBloc,
      act: (bloc) => bloc.add(const ParticipantListChanged([])),
      wait: const Duration(milliseconds: 50),
      verify: (bloc) => expect(bloc.endCallPresses, 1),
    );
  });
}
