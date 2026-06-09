# E2E Integration Tests

End-to-end tests for the CometChat Flutter UIKit sample app using Flutter's `integration_test` package against the real CometChat SDK.

## Test Files

| File | Component | Description |
|------|-----------|-------------|
| `conversations_e2e_test.dart` | Conversations | List rendering, tap, long-press, delete, custom views |
| `e2e_conversations_test.dart` | Conversations | Pagination, caching, status indicators, delete flow |
| `e2e_users_test.dart` | Users | List load, search, pagination, block/unblock |
| `e2e_groups_test.dart` | Groups + GroupMembers | List load, search, join, member operations |
| `e2e_message_list_test.dart` | MessageList | Message rendering, pagination, send/delete |
| `e2e_message_header_test.dart` | MessageHeader | User/group names, blocked state, error handling |
| `e2e_message_composer_test.dart` | MessageComposer | Text input, send button, blocked users |
| `e2e_message_information_test.dart` | MessageInformation | Receipts, error states |
| `e2e_calls_test.dart` | CallLogs | Call history, pagination, tap callback |

## Prerequisites

1. **Running emulator or connected device** (Android or iOS)
2. **CometChat test app** with at least 2 users created
3. **Credentials** set via `--dart-define` or using defaults in `helpers/login_fixture.dart`

## Configuration

Credentials can be overridden via `--dart-define`:

```bash
flutter test integration_test/ \
  --dart-define=COMETCHAT_APP_ID=your_app_id \
  --dart-define=COMETCHAT_REGION=in \
  --dart-define=COMETCHAT_AUTH_KEY=your_auth_key \
  --dart-define=COMETCHAT_REST_API_KEY=your_rest_api_key \
  --dart-define=TEST_USER_UID=cometchat-uid-2 \
  --dart-define=TEST_PEER_UID=cometchat-uid-3
```

## Running

### Single test file
```bash
flutter test integration_test/e2e_users_test.dart -d emulator-5554
```

### All tests (sequential)
```bash
chmod +x integration_test/run_all_e2e.sh
./integration_test/run_all_e2e.sh
```

### With custom device
```bash
./integration_test/run_all_e2e.sh <device-id>
```

## Helpers

| Helper | Purpose |
|--------|---------|
| `helpers/login_fixture.dart` | SDK init + login/logout |
| `helpers/seed_data.dart` | Create/cleanup test conversations via REST API |
| `helpers/pump_helpers.dart` | Real-time pump utilities for async SDK calls |

## Architecture

Tests use standard `integration_test` (not Patrol) for maximum portability:

- `IntegrationTestWidgetsFlutterBinding.ensureInitialized()` in `main()`
- `setUpAll` for SDK init + login
- `tearDownAll` for logout + cleanup
- `pumpForDuration` for real wall-clock waiting (SDK calls are async)
- Direct widget mounting with `MaterialApp` + `CometChatConversations`/etc.

## Troubleshooting

### Test hangs on pumpAndSettle
CometChat widgets have perpetual SDK listeners that prevent `pumpAndSettle` from ever completing. Use `pumpForDuration` instead.

### "StateError: CometChatUIKit.init failed"
Check that credentials are correct. The default credentials point to an internal test app.

### "Failed to seed conversation: 401"
Check that `COMETCHAT_REST_API_KEY` is correct and has send-message permissions.

### Flaky on first run
The 2-second delay after seeding may not be enough for slow networks. Increase the delay in `setUpAll` if needed.

## Dual-Device Testing

For real-time interaction tests (messaging between 2 users, online status, typing indicators), we use two emulators simultaneously.

### Setup

1. Start two Android emulators:
```bash
emulator -avd Pixel_6_API_34 -port 5554 &   # Device A
emulator -avd Pixel_6_API_34 -port 5556 &   # Device B
```

2. Verify both are listed:
```bash
flutter devices
```

### Architecture

```
┌─────────────────────────────────────────────────────┐
│  Host Machine (orchestrator script)                  │
├─────────────────────┬───────────────────────────────┤
│  Device A           │  Device B                     │
│  (emulator-5554)    │  (emulator-5556)              │
│                     │                               │
│  User A logged in   │  User B logged in             │
│  Runs primary tests │  Runs companion actions       │
│  Verifies UI state  │  Sends messages/typing/calls  │
└─────────────────────┴───────────────────────────────┘
```

### Running Dual-Device Tests

```bash
# Full dual-device suite (Phase 1 single-device + Phase 2 dual-device)
./integration_test/run_dual_device_e2e.sh emulator-5554 emulator-5556

# Individual dual-device test (manually start companion first)
# Terminal 1 — Device B companion:
flutter test integration_test/companion/companion_app_test.dart \
  -d emulator-5556 --plain-name "Send text message to User A"

# Terminal 2 — Device A primary test:
flutter test integration_test/e2e_dual_messaging_test.dart -d emulator-5554
```

### Test Categories

| Category | Tests | Devices |
|----------|-------|---------|
| Single-device | message_header, users, groups, composer, calls, message_info | A only |
| Dual-device | dual_messaging, dual_online_status, conversations, message_list | A + B |

### Helpers

| Helper | Purpose |
|--------|---------|
| `helpers/dual_device_config.dart` | Shared config (user UIDs, credentials, signal commands) |
| `helpers/peer_actions.dart` | REST API calls to simulate User B actions from Device A |
| `companion/companion_app_test.dart` | Companion app tests (runs on Device B) |

### How It Works

**Phase 1 (single-device):** Tests that only need one user run on Device A. User B's actions are simulated via `PeerActions` (REST API calls from the test itself).

**Phase 2 (dual-device):** The orchestrator script launches a companion test on Device B (which logs in as User B and performs actions via the SDK). Then Device A's test verifies real-time events arrive correctly.

The companion app has individual test cases for specific actions:
- "Send text message to User A"
- "Send typing indicator to User A"
- "Send multiple messages for pagination test"
- "Send group message"
- "Stay online as idle peer (keep-alive)"

## CI Integration

```yaml
- name: Run E2E tests (single-device)
  env:
    COMETCHAT_APP_ID: ${{ secrets.COMETCHAT_APP_ID }}
    COMETCHAT_REGION: in
    COMETCHAT_AUTH_KEY: ${{ secrets.COMETCHAT_AUTH_KEY }}
    COMETCHAT_REST_API_KEY: ${{ secrets.COMETCHAT_REST_API_KEY }}
    TEST_USER_UID: ${{ secrets.TEST_USER_UID }}
    TEST_PEER_UID: ${{ secrets.TEST_PEER_UID }}
  run: |
    cd examples/sample_app
    flutter test integration_test/ \
      --dart-define=COMETCHAT_APP_ID=$COMETCHAT_APP_ID \
      --dart-define=COMETCHAT_REGION=$COMETCHAT_REGION \
      --dart-define=COMETCHAT_AUTH_KEY=$COMETCHAT_AUTH_KEY \
      --dart-define=COMETCHAT_REST_API_KEY=$COMETCHAT_REST_API_KEY \
      --dart-define=TEST_USER_UID=$TEST_USER_UID \
      --dart-define=TEST_PEER_UID=$TEST_PEER_UID

- name: Run E2E tests (dual-device)
  run: |
    cd examples/sample_app
    ./integration_test/run_dual_device_e2e.sh emulator-5554 emulator-5556
```
