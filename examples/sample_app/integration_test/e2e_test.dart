/// CometChat Flutter UIKit — E2E Test Suite (consolidated)
///
/// Architecture:
///   - User A: Full Flutter app running on device (emulator/simulator/browser)
///   - User B: CometChat REST API calls from same test process (no second device)
///
/// User B's REST calls trigger real WebSocket events that User A's app
/// receives through the SDK's listener system. No timers. No second emulator.
///
/// Every test case from the three source sheets is implemented exactly once,
/// in one feature-named suite under `suites/`:
///   - "CometChat E2E Test Cases - 1to1 Conversations"  (1TO1-*)
///   - "CometChat E2E Test Cases - Realtime Dual Device" (RT-*)
///   - "CometChat Automated Test Cases - E2E Tests"      (E2E-*)
///
/// Run everything on a device:
///   ./integration_test/run_android.sh emulator-5554
///   ./integration_test/run_ios.sh
///   ./integration_test/run_web.sh
///
/// Or run a single suite:
///   flutter test integration_test/suites/<suite>_test.dart -d <device>
library;

// ── Consolidated suites (36 files, 358 test cases) ──────────────────────────
//
//   suites/auth_test.dart                      Login / logout (E2E-001..004)
//   suites/users_test.dart                     Users tab (E2E-010..013)
//   suites/conversations_test.dart             Conversation list + nav (1TO1-001..005, E2E-005..009, RT-MSG-011..015)
//   suites/message_header_test.dart            Header identity/presence/call buttons (1TO1-006..014, E2E-026..029)
//   suites/messaging/send_message_test.dart    Sending text + variants (1TO1-015..025, E2E-019..025)
//   suites/messaging/receive_message_test.dart Receiving realtime (1TO1-026..030, RT-MSG-001..010)
//   suites/messaging/edit_message_test.dart    Edit (1TO1-031..035, RT-EDIT-001..003)
//   suites/messaging/delete_message_test.dart  Delete (1TO1-036..040, RT-DEL-001..005)
//   suites/message_actions_test.dart           Long-press actions (1TO1-074..082)
//   suites/media_messages_test.dart            Image/video/audio/file (1TO1-089..093, E2E-021/022/073..077)
//   suites/reactions_test.dart                 Reactions (1TO1-045..048, E2E-036..039, RT-REACT-001..005)
//   suites/thread_replies_test.dart            Threads (1TO1-049..053, E2E-040..043, RT-THREAD-001..003)
//   suites/typing_indicator_test.dart          Typing (1TO1-054..057, RT-TYPE-001..006)
//   suites/read_receipts_test.dart             Receipts (1TO1-041..044, E2E-044..047, RT-RCPT-001..008)
//   suites/presence_test.dart                  Presence (RT-PRES-001..006)
//   suites/block_user_test.dart                Block/unblock (1TO1-058..062, RT-BLOCK-001..004)
//   suites/user_info_test.dart                 User info screen (1TO1-063..069)
//   suites/pagination_test.dart                Pagination (1TO1-070..073)
//   suites/composer_test.dart                  Composer affordances (1TO1-083..088)
//   suites/search_test.dart                    Search (E2E-053..056)
//   suites/calls_test.dart                     Calls (1TO1-094..096, E2E-048..052, RT-CALL-001..006)
//   suites/connection_test.dart                Reconnection / network (E2E-060..063, RT-CONN-001..003)
//   suites/configuration_test.dart             Orientation / theme (E2E-064..067)
//   suites/groups_test.dart                    Groups + members (E2E-014..018/030..035/068..072, RT-GRP-001..007)
//   suites/edge_cases_test.dart                Edge/stress/lifecycle (1TO1-097..103, RT-EDGE-001..010)
//   suites/ui_surfaces_test.dart               Avatar/badge/date (E2E-057..059)
//
//   ── Group suites (GRP-*, RT-GRP-*) ──
//   suites/groups_extended_test.dart           Group create/join/leave flows (GRP-001..012, GRP-090)
//   suites/group_composer_test.dart            Group composer + mentions/@all (GRP-013..022)
//   suites/group_message_actions_test.dart     Group msg edit/delete/copy + permissions (GRP-023..031, GRP-081..089)
//   suites/group_media_messages_test.dart      Group media send/receive (GRP-032..038)
//   suites/group_reactions_test.dart           Group reactions + multi-reactor (GRP-039..044)
//   suites/group_thread_messages_test.dart     Group threads + sender names (GRP-045..051)
//   suites/group_header_test.dart              Group header identity + details nav (GRP-052..058)
//   suites/group_members_test.dart             Group details/permissions/scope/ban/transfer (GRP-059..080)
//   suites/groups_realtime_test.dart           Live incoming group content (RT-GRP-008..015)
//   suites/composer_voice_test.dart            Voice recorder surface (1TO1-104)
