# CometChat Flutter UIKit — E2E Integration Test Suite

This directory contains the end-to-end (E2E) integration tests for the **CometChat Flutter UIKit**. The tests drive the bundled `sample_app` (`BlocSampleApp`) as a real user would — launching the app, logging in, navigating, sending and receiving messages, reacting, creating groups, placing calls, and so on — and assert that the UIKit renders and behaves correctly. They run against a **live CometChat backend**, not mocks: a second user ("User B") is driven over the CometChat REST API from inside the same test process, so real WebSocket events flow back into the app under test. The suite covers roughly **260+ test cases** across **36 suite files**, organized by feature area (1-to-1 core, 1-to-1 messaging, groups), and is runnable on **iOS**, **Android**, and **Web**.

---

## 1. Quick start

All commands are run from the `examples/sample_app` directory. `<suite>` is any file under `integration_test/suites/` (e.g. `integration_test/suites/auth_test.dart`).

### iOS (single simulator)

```bash
# Auto-detect a booted iOS simulator and run every suite
./integration_test/run_ios.sh

# Or run one suite directly
flutter test integration_test/suites/auth_test.dart -d <SIMULATOR_UDID>
```

### Android (single emulator)

```bash
# Default emulator is emulator-5554
./integration_test/run_android.sh

# Or run one suite directly
flutter test integration_test/suites/auth_test.dart -d emulator-5554
```

### Web (Chrome via flutter drive)

```bash
# Runs every web wrapper; requires Chrome + a matching ChromeDriver (see §6)
./integration_test/run_web.sh

# Or run one suite directly (note: web targets the web_*.dart wrapper, not the suite)
export CHROME_EXECUTABLE="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"
flutter drive \
  --driver=test_driver/integration_test.dart \
  --target=integration_test/web_auth_test.dart \
  -d chrome \
  --chrome-binary="$CHROME_EXECUTABLE"
```

> **Note:** `calls_test.dart` and `composer_voice_test.dart` do **not** run on web — there is no WebRTC and no audio recording in headless web tests, so no `web_calls_test.dart` / `web_composer_voice_test.dart` wrappers exist.

---

## 2. Directory layout

```
integration_test/
├── suites/                       # All test suites (the actual tests live here)
│   ├── auth_test.dart            #   1-to-1 core: login/logout, cached session
│   ├── conversations_test.dart   #   1-to-1 core: conversation list + realtime updates
│   ├── users_test.dart           #   1-to-1 core: users list, pagination, search, presence
│   ├── presence_test.dart        #   1-to-1 core: online/offline indicators
│   ├── message_header_test.dart  #   1-to-1 core: chat header (name/avatar/calls/typing)
│   ├── block_user_test.dart      #   1-to-1 core: block/unblock + side effects
│   ├── user_info_test.dart       #   1-to-1 core: user info screen
│   ├── search_test.dart          #   1-to-1 core: search users/groups/messages
│   ├── pagination_test.dart      #   1-to-1 core: message-list scroll/pagination
│   ├── connection_test.dart      #   1-to-1 core: offline/reconnect resilience
│   ├── configuration_test.dart   #   1-to-1 core: rotation, draft, theme
│   ├── edge_cases_test.dart      #   1-to-1 core: race conditions, stress, lifecycle
│   ├── ui_surfaces_test.dart     #   1-to-1 core: avatar, badge, date rendering
│   ├── typing_indicator_test.dart#   1-to-1 core: typing flow (REST-limited)
│   ├── read_receipts_test.dart   #   1-to-1 core: sent/delivered/read ticks
│   ├── message_actions_test.dart #   1-to-1 messaging: long-press action overlay
│   ├── media_messages_test.dart  #   1-to-1 messaging: attachments (send + receive)
│   ├── reactions_test.dart       #   1-to-1 messaging: emoji reactions
│   ├── thread_replies_test.dart  #   1-to-1 messaging: threads
│   ├── composer_test.dart        #   1-to-1 messaging: composer UI affordances
│   ├── composer_voice_test.dart  #   1-to-1 messaging: voice recorder (no web)
│   ├── calls_test.dart           #   1-to-1 messaging: voice/video signaling (no web)
│   ├── groups_test.dart          #   groups: list/creation/members + membership events
│   ├── groups_extended_test.dart #   groups: create-sheet, join, leave flows
│   ├── groups_realtime_test.dart #   groups: live incoming content from members
│   ├── group_composer_test.dart  #   groups: composer + mentions/@all
│   ├── group_header_test.dart    #   groups: header identity + details nav
│   ├── group_members_test.dart   #   groups: details screen, permissions, scope/ban/transfer
│   ├── group_message_actions_test.dart  # groups: edit/delete/copy with permission gating
│   ├── group_media_messages_test.dart   # groups: media send + incoming bubbles
│   ├── group_reactions_test.dart #   groups: reactions + multi-reactor counts
│   ├── group_thread_messages_test.dart  # groups: threads + sender-name visibility
│   └── messaging/                # Core message CRUD, split out as foundational
│       ├── send_message_test.dart
│       ├── receive_message_test.dart
│       ├── edit_message_test.dart
│       └── delete_message_test.dart
│
├── helpers_v2/                   # Shared test helpers (the "v2" harness, see §4)
│   ├── app_launcher.dart         #   launch + login as User A (Keychain wipe, FocusTrap fix)
│   ├── navigation_helper.dart    #   tab/conversation/group navigation
│   ├── message_helper.dart       #   composer + message-action interactions
│   ├── assertion_helper.dart     #   sliver-aware finders + tolerant assertions
│   ├── pump_helper.dart          #   realtime-aware waits (no pumpAndSettle)
│   ├── cleanup_helper.dart       #   REST-based per-test isolation
│   └── screenshot_helper.dart    #   auto-numbered screenshots (non-fatal)
│
├── sdk_user_b/                   # Headless "User B" peer, driven entirely over REST (see §7)
│   ├── sdk_user_b.dart           #   core HTTP client (onBehalfOf header, login/logout)
│   ├── messaging_actions.dart    #   send/edit/delete/media + fetchLatestMessageIdFromA
│   ├── receipt_actions.dart      #   markAsDelivered / markAsRead (cumulative)
│   ├── typing_actions.dart       #   typing (REST-limited; throws UnsupportedError)
│   ├── presence_actions.dart     #   goOnline / goOffline
│   ├── block_actions.dart        #   block/unblock as B
│   ├── reaction_actions.dart     #   add/remove reactions
│   ├── thread_actions.dart       #   thread replies
│   ├── call_actions.dart         #   initiate/reject voice & video calls
│   ├── group_actions.dart        #   group membership operations
│   └── group_test_actions.dart   #   group fixture seeding helpers
│
├── config/
│   ├── test_credentials.dart     #   App ID/region/keys + User A/B/group, via --dart-define
│   └── test_tags.dart            #   tag constants: smoke/full/realtime/edge/network/group/calling
│
├── web_auth_test.dart            # 34 web wrappers: each re-exports a suite's main() so
├── web_groups_test.dart          #   `flutter drive` can resolve relative imports from the
├── ...  (one per runnable suite)  #   integration_test/ root (see §6). No web_calls /
│                                  #   web_composer_voice wrapper exists.
├── web_smoke_test.dart           # Standalone web smoke test (not a re-export wrapper)
│
├── e2e_test.dart                 # Aggregate entry point listing all suites
│
├── run_ios.sh                    # Per-platform / orchestration runners (see §6)
├── run_android.sh                #   runs each suite, writes SUMMARY.md
├── run_web.sh                    #   ChromeDriver restart + flutter-drive-hang workaround
├── run_all_resumable.sh          #   resumable full run (skip-if-done)
├── run_remaining.sh              #   resume an interrupted run
├── run_new_groups.sh             #   group suites only
│
├── e2e_results/                  # Timestamped per-run log dirs + SUMMARY.md (gitignored output)
│
└── e2e_coverage_map.csv          # test_id → sheet_tab → status → suite_file (1:1 coverage map)
```

---

## 3. How a test is structured

Every test follows the same five-phase shape: **launch + login → navigate → act → assert → cleanup**. Each phase is powered by a dedicated helper so suites stay short and consistent.

| Phase | Helper(s) | What it does |
|-------|-----------|--------------|
| **Launch + login** | `AppLauncher.launchAndLogin(tester)` | Wipes the iOS Keychain, pre-seeds credentials, pumps `BlocSampleApp`, logs in as User A (with the FocusTrap workaround). |
| **Navigate** | `NavigationHelper.goToTab` / `openUserBConversation` / `openTestGroup` | Moves to the right screen (Chats/Users/Groups tab, a conversation, a group). |
| **Act** | `MessageHelper.*` (User A via UI) and/or `UserBMessaging.*` etc. (User B via REST) | Performs the action under test — type/send, long-press, react, or have the peer send/edit/delete. |
| **Wait** | `pumpUntilFound` / `pumpForRealtime` / `AssertionHelper.waitForMessage` | Waits for the realtime event to land (never `pumpAndSettle` — see §4). |
| **Assert** | `AssertionHelper.expectMessageVisible` / tolerant tree finders | Verifies the UI. Structural assertions are **fatal**; timing-dependent text/colors are **logged, non-fatal**. |
| **Cleanup** | `CleanupHelper.fullReset()` (in `setUp`/`tearDown`); `setUpAll` seeds | Restores state (unblock, delete conversation, B offline) so the next test starts clean. |

### Illustrative snippet

```dart
testWidgets('RT-MSG-001: Receive text message', (WidgetTester tester) async {
  await CleanupHelper.fullReset();                      // clean state
  await AppLauncher.launchAndLogin(tester);             // launch + login as User A

  await NavigationHelper.openUserBConversation(tester); // navigate to B's chat

  await SdkUserB.login();                               // make B "online"
  await UserBMessaging.sendTextToA('Hello from User B'); // B acts via REST

  await AssertionHelper.waitForMessage(                 // wait for the WebSocket event
    tester, 'Hello from User B',
  );
  AssertionHelper.expectMessageVisible(                 // fatal structural assertion
    tester, 'Hello from User B',
  );

  await CleanupHelper.fullReset();                      // cleanup
});
```

**Assertion philosophy.** The minimum guarantee for every test is *stability + no crash* — no test ever leaves an empty body. Message presence, screen stability, navigation state, and composer presence are **fatal** assertions. Things that depend on server debounce or UIKit rendering (presence text like "Online", "Typing…", exact tick colors, exact widget types) are observed with tolerant finders and `debugPrint`-logged for CI visibility rather than failing the suite.

**Message text rule.** Never put underscores in test message strings. The UIKit markdown formatter interprets `_text_` as italic and strips the underscores, which breaks text finders.

---

## 4. The helper layer (`helpers_v2`)

The harness uses a **single-device, dual-user** model: **User A** is the full Flutter app driven by `WidgetTester`; **User B** is headless and driven over REST (see §7). `helpers_v2/` is the shared library that makes this ergonomic.

| Helper | Responsibility |
|--------|----------------|
| `app_launcher.dart` | Bootstraps and logs in User A. Contains the two most important workarounds below. |
| `navigation_helper.dart` | High-level navigation for the bottom-tabbed UI (`goToTab`, `openUserBConversation`, `openTestGroup`, `goBack`). Uses `.last` on tab labels because labels appear in both the nav bar and the app bar. |
| `message_helper.dart` | Composer + message actions (`typeInComposer`, `sendMessage`, `longPressMessage`, `tapAction`, `editMessage`, `deleteMessage`, `addReaction`). Falls back across multiple send-button finder strategies. |
| `assertion_helper.dart` | Sliver-aware finders (`messageExistsInTree`, `anyTextInTree`, `waitForMessageInTree`) plus assertion wrappers. |
| `pump_helper.dart` | Realtime-aware waits: `pumpForRealtime` (fixed), `pumpUntilFound` / `pumpUntilGone` (event-driven), `pumpFor` (bare). |
| `cleanup_helper.dart` | REST-based isolation (`deleteConversation`, `unblockAll`, `seedConversation`, `fullReset`). All best-effort and non-fatal. |
| `screenshot_helper.dart` | Auto-numbered screenshots saved per-suite/per-test. Non-fatal on failure. |

### Why `helpers_v2` does things its own way

**iOS Keychain wipe (`AppLauncher.launchAndLogin`).** On iOS, `flutter_secure_storage` persists auth tokens in the Keychain *across test runs and reinstalls*. Without intervention, a token from a previous run survives, the SDK silently reuses it, and the login UI is skipped — leaving the app in the wrong user context and making tests flaky. The launcher calls `FlutterSecureStorage().deleteAll()` before launch to guarantee a fresh login. (It runs on Android too, harmlessly, for symmetry.)

**FocusTrap / AbsorbPointer login workaround.** When a `TextFormField` has focus and the keyboard is shown, Flutter overlays an `AbsorbPointer` (a "FocusTrap") that intercepts taps and prevents the "Continue" button from being tapped. The fix is to dismiss the keyboard and drop focus *before* tapping:

```dart
await tester.testTextInput.receiveAction(TextInputAction.done);
FocusManager.instance.primaryFocus?.unfocus();
await tester.pump(const Duration(milliseconds: 500));
// FocusTrap is now gone — the Continue tap lands normally.
```

**No `pumpAndSettle()`.** CometChat apps keep a WebSocket open and animate incoming events, so the widget tree never reaches a "settled" state — `pumpAndSettle()` would hang forever. Use `pumpForRealtime` (fixed wait) or `pumpUntilFound` (exits as soon as the condition is met) instead.

**Tree-walking finders.** The UIKit message list is a `CustomScrollView` built with slivers. Standard `find.text()` cannot reach sliver-rendered messages, so `AssertionHelper.messageExistsInTree()` recursively walks the element tree (matching `Text` and `RichText`) and returns a bool without throwing.

---

## 5. Test catalog

Suites are grouped into three feature areas. Counts are approximate and reflect the consolidated suites.

### 1-to-1 core (15 suites)

| Suite | Feature | Test-ID prefixes | ~Count |
|-------|---------|------------------|-------:|
| `auth_test.dart` | Login / logout / cached session | `E2E-001`…`004` | 4 |
| `conversations_test.dart` | Conversation list + realtime updates | `1TO1-001`…, `E2E-005`…, `RT-MSG-011`… | 14 |
| `users_test.dart` | Users list, pagination, search, presence | `E2E-010`…`013` | 4 |
| `presence_test.dart` | Online/offline indicators | `RT-PRES-001`…`006` | 6 |
| `message_header_test.dart` | Chat header (name/avatar/calls/typing) | `1TO1-006`…, `E2E-026`… | 12 |
| `block_user_test.dart` | Block/unblock + side effects | `1TO1-058`…, `RT-BLOCK-001`… | 9 |
| `user_info_test.dart` | User info screen | `1TO1-063`…`069` | 7 |
| `search_test.dart` | Search users/groups/messages | `E2E-053`…`056` | 4 |
| `pagination_test.dart` | Message-list scroll/pagination | `1TO1-070`…`073` | 4 |
| `connection_test.dart` | Offline / reconnect resilience | `E2E-060`…, `RT-CONN-001`… | 7 |
| `configuration_test.dart` | Rotation, draft, theme | `E2E-064`…`067` | 4 |
| `edge_cases_test.dart` | Race conditions, stress, lifecycle | `1TO1-097`…, `RT-EDGE-001`… | 14 |
| `ui_surfaces_test.dart` | Avatar, badge, date rendering | `E2E-057`…`059` | 3 |
| `typing_indicator_test.dart` | Typing flow (REST-limited) | `1TO1-054`…, `RT-TYPE-001`… | 10 |
| `read_receipts_test.dart` | Sent/delivered/read ticks | `1TO1-041`…, `E2E-044`…, `RT-RCPT-001`… | 18 |

### 1-to-1 messaging (11 suites)

| Suite | Feature | Test-ID prefixes | ~Count |
|-------|---------|------------------|-------:|
| `messaging/send_message_test.dart` | Compose & send text | `1TO1-015`…, `E2E-019`… | 16 |
| `messaging/receive_message_test.dart` | Inbound messages, ordering | `1TO1-026`…, `RT-MSG-001`… | 15 |
| `messaging/edit_message_test.dart` | Edit own / peer-edit live | `1TO1-031`…, `RT-EDIT-001`… | 8 |
| `messaging/delete_message_test.dart` | Delete + placeholder behavior | `1TO1-036`…, `RT-DEL-001`… | 11 |
| `message_actions_test.dart` | Long-press action overlay | `1TO1-074`…`082` | 9 |
| `media_messages_test.dart` | Attachments (send + receive) | `1TO1-089`…, `E2E-021`…`077` | 12 |
| `reactions_test.dart` | Emoji reactions | `1TO1-045`…, `E2E-036`…, `RT-REACT-001`… | 13 |
| `thread_replies_test.dart` | Threads | `1TO1-049`…, `E2E-040`…, `RT-THREAD-001`… | 12 |
| `composer_test.dart` | Composer UI affordances | `1TO1-083`…`088` | 6 |
| `composer_voice_test.dart` | Voice recorder (web-skipped) | `1TO1-104` | 1 |
| `calls_test.dart` | Voice/video signaling (web-skipped) | `1TO1-094`…, `E2E-048`…, `RT-CALL-001`… | 12 |

### Groups (10 suites)

| Suite | Feature | Test-ID prefixes | ~Count |
|-------|---------|------------------|-------:|
| `groups_test.dart` | List/creation/members + membership events | `E2E-014`…, `RT-GRP-001`…`007` | 23 |
| `groups_extended_test.dart` | Create-sheet, join, leave flows | `GRP-001`…`012`, `GRP-090` | 13 |
| `groups_realtime_test.dart` | Live incoming content from members | `RT-GRP-008`…`015` | 8 |
| `group_composer_test.dart` | Composer + mentions / @all | `GRP-013`…`022` | 10 |
| `group_header_test.dart` | Header identity + details nav | `GRP-052`…`058` | 7 |
| `group_members_test.dart` | Details, permissions, scope/ban/transfer | `GRP-059`…`080` | 22 |
| `group_message_actions_test.dart` | Edit/delete/copy with permission gating | `GRP-023`…, `GRP-081`, `GRP-084`… | 16 |
| `group_media_messages_test.dart` | Media send + incoming bubbles | `GRP-032`…`038` | 7 |
| `group_reactions_test.dart` | Reactions + multi-reactor counts | `GRP-039`…`044` | 6 |
| `group_thread_messages_test.dart` | Threads + sender-name visibility | `GRP-045`…`051` | 7 |

> `groups_test.dart` covers **membership action messages** (joined/left/kicked/banned/scope-changed). `groups_realtime_test.dart` is distinct: it covers **live member content** (text/media/reactions arriving over WebSocket). Group suites create per-run unique-GUID throwaway groups so User A always owns the group for permission-gated tests.

---

## 6. Running the tests

### iOS

```bash
./integration_test/run_ios.sh [SIMULATOR_UDID]
```

- **Prereqs:** Xcode + a booted iOS Simulator visible in `flutter devices`.
- If no UDID is given, the runner auto-detects the first simulator from `flutter devices --machine`.
- Writes a timestamped log dir under `e2e_results/ios_YYYY-MM-DD_HH-MM-SS/`, runs every suite via `flutter test <suite> -d <DEVICE>`, and exits with the failed-suite count.

### Android

```bash
./integration_test/run_android.sh [emulator-5554]
```

- **Prereqs:** one Android emulator visible in `flutter devices` (defaults to `emulator-5554` if no id is given).
- Runs `flutter test <suite> -d <DEVICE>` for every suite, writes a `SUMMARY.md` (a per-suite pass/fail table) to the timestamped `e2e_results/android_YYYY-MM-DD_HH-MM-SS/` dir, and exits with the failed-suite count.

> If back-to-back installs hit `INSTALL_FAILED_INSUFFICIENT_STORAGE`, free space on the emulator with `adb -s <DEVICE> shell pm trim-caches 9999999999` before re-running (the runner does **not** do this automatically).

### Web (Chrome)

```bash
./integration_test/run_web.sh [RESULTS_DIR]
```

**Prerequisites:**

- **Google Chrome** — the script expects it at `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome` (edit the `CHROME_BIN` path in `run_web.sh` if yours differs).
- A matching **ChromeDriver** — the script expects it at `/tmp/cft-cd148/chromedriver-mac-arm64/chromedriver` (edit the `CHROMEDRIVER` path in `run_web.sh` if yours differs). Its major version **must** equal your installed Chrome's major version.
- The script exports `CHROME_EXECUTABLE` to the Chrome binary and passes `--chrome-binary` to `flutter drive`.

**The web-wrapper mechanism.** On web the tests run via `flutter drive`, whose driver process resolves the target's relative imports from the `integration_test/` root. Targeting `suites/<x>_test.dart` directly breaks those import paths. Instead, each suite has a thin wrapper at the `integration_test/` root that just re-exports the suite's `main()`:

```dart
// integration_test/web_auth_test.dart
import 'suites/auth_test.dart' as suite;
void main() => suite.main();
```

There are **34** wrappers — one per runnable suite — and `run_web.sh` drives exactly those 34. `calls_test.dart` and `composer_voice_test.dart` are intentionally **not** wrapped (no WebRTC, no audio recording on web). (A 35th file, `web_smoke_test.dart`, also lives at the root, but it is a standalone smoke test rather than a re-export wrapper, and the runner does not include it.)

**Per-suite ChromeDriver restart.** ChromeDriver exits when the browser session closes, so the runner respawns it for every suite and kills lingering Chrome windows between runs:

```bash
pkill -f "chromedriver --port=4444" 2>/dev/null
pkill -f "Google Chrome" 2>/dev/null
"$CHROMEDRIVER" --port=4444 &
```

**`flutter drive` hang workaround.** After the tests finish on web, `flutter drive` does not exit on its own. The runner backgrounds it and polls the log for completion markers — `All tests passed!` or `Some tests failed.` — kills the driver the moment a marker appears, and has a **20-minute (1200s) hard backstop** for genuine hangs.

### Resumable / skip-if-done

The orchestration runners (`run_all_resumable.sh`, `run_remaining.sh`, `run_new_groups.sh`) and the web runner are resumable. Before running a suite they check whether its log already contains a completion marker; if so, the suite is **skipped** and counted from the marker. Re-running after an interruption resumes from the first incomplete suite.

```bash
is_complete() { [ -f "$1" ] && grep -qE "All tests passed!|Some tests failed\." "$1"; }
```

### Tags

Tags from `config/test_tags.dart` (`smoke`, `full`, `realtime`, `edge`, `network`, `group`, `calling`) filter what runs:

```bash
flutter test integration_test/suites/auth_test.dart --tags smoke
flutter test integration_test/suites/auth_test.dart --exclude-tags edge
```

---

## 7. The two-user / realtime model

There is only ever **one device**. Realtime behavior is exercised by driving a second user, **User B**, entirely over the CometChat REST API from inside the test process (`integration_test/sdk_user_b/`). The event flow is:

```
User B REST call (onBehalfOf: userB)
        │
        ▼
CometChat server
        │  WebSocket broadcast
        ▼
User A's SDK listener  ──►  UIKit updates  ──►  WidgetTester asserts
```

- **`SdkUserB`** (`sdk_user_b.dart`) is the HTTP client. `login()` / `logout()` create/delete User B's auth token — this makes B appear online so presence events fire (REST operations themselves work regardless of login state). Every write carries an `onBehalfOf` header so the server processes it as User B (or, via `asUserA: true`, as User A from "another device").
- **What B can drive:** send/edit/delete messages and media (`messaging_actions.dart`), reactions (`reaction_actions.dart`), thread replies (`thread_actions.dart`), presence (`presence_actions.dart`), block state (`block_actions.dart`), receipts (`receipt_actions.dart`), calls (`call_actions.dart`), and group operations (`group_actions.dart`, `group_test_actions.dart`).
- **Receipt tests** use `UserBMessaging.fetchLatestMessageIdFromA()`: User A sends via the UI (no message ID captured there), and B queries the latest A-authored message so it can mark it delivered/read.
- **Receipts are cumulative:** `markAsRead(id)` marks every message with ID ≤ `id` as read; `markAllAsRead(list)` therefore only marks the highest ID to save API calls.
- **Seeding & isolation:** `setUpAll` seeds a B→A conversation (`CleanupHelper.seedConversation`); `tearDown`/`setUp` calls `CleanupHelper.fullReset()` (unblock both directions, delete the conversation, settle) to isolate tests.

---

## 8. Test-ID taxonomy & coverage map

Three ID schemes run through the suites:

- **`1TO1-###`** — 1-to-1 UI flows on a single device (messaging CRUD, reactions, threads, typing, receipts, presence, blocking, user info, pagination, composer). Roughly `1TO1-001`…`1TO1-104`.
- **`RT-<AREA>-###`** — realtime cross-user scenarios, sub-prefixed by area: `MSG`, `EDIT`, `DEL`, `REACT`, `THREAD`, `TYPE`, `RCPT`, `PRES`, `BLOCK`, `CONN`, `CALL`, `GRP`, `EDGE`.
- **`E2E-###`** — end-to-end smoke/structural workflows (auth, users, conversations, media, search, calls, connection, config, groups, UI). Roughly `E2E-001`…`E2E-077`.
- **`GRP-###`** — group-specific extended IDs used by the group suites (composer, header, members, message actions, media, reactions, threads).

Every case maps 1:1 to a `testWidgets` in a suite file. The authoritative map lives at:

```
integration_test/e2e_coverage_map.csv   #  test_id | sheet_tab | status | suite_file
```

---

## 9. Troubleshooting

| Symptom | Cause | Fix |
|---------|-------|-----|
| Test reuses the wrong user / skips login on iOS | Stale auth token in the iOS Keychain (`flutter_secure_storage` persists across runs). | `AppLauncher.launchAndLogin` already wipes it via `deleteAll()`; ensure you launch through it rather than pumping the app directly. |
| "Continue" / a button tap silently misses | Keyboard FocusTrap (`AbsorbPointer`) is intercepting the tap. | Unfocus first: `testTextInput.receiveAction(TextInputAction.done)` + `primaryFocus?.unfocus()` + a `pump`. |
| Web run never finishes / driver session errors | ChromeDriver major version ≠ Chrome version, or a stale ChromeDriver/Chrome process. | Match ChromeDriver's major version to your installed Chrome; the runner restarts ChromeDriver and kills Chrome per suite. |
| `flutter drive` hangs after "All tests passed!" | Known web issue — the driver doesn't exit. | Handled by the runner (polls log markers, kills the driver, 20-min backstop). Don't `pumpAndSettle`-style wait on it. |
| Test hangs forever waiting for the UI to "settle" | `pumpAndSettle()` against a live WebSocket that never settles. | Use `pumpForRealtime` / `pumpUntilFound` instead. |
| Finder can't locate a message that's clearly on screen | Message is sliver-rendered; standard `find.text` can't reach it, or the text contains underscores. | Use `AssertionHelper.messageExistsInTree`; remove underscores from test text. |
| Android install fails between suites | `INSTALL_FAILED_INSUFFICIENT_STORAGE`. | Free emulator space with `adb -s <DEVICE> shell pm trim-caches 9999999999`, then re-run. |
| Typing test for the peer "doesn't fire" | REST has no start-typing endpoint (`UnsupportedError`). | Expected — peer typing is verified structurally; only A's typing is drivable. |
