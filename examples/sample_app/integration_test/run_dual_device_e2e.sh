#!/bin/bash
# Dual-device E2E test orchestrator.
#
# Launches tests on two emulators simultaneously:
#   Device A (primary): Runs the main E2E test suite as User A
#   Device B (companion): Runs companion actions as User B
#
# Usage:
#   ./integration_test/run_dual_device_e2e.sh [device_a] [device_b]
#
# Examples:
#   ./integration_test/run_dual_device_e2e.sh emulator-5554 emulator-5556
#   ./integration_test/run_dual_device_e2e.sh              # Uses defaults
#
# Prerequisites:
#   - Two Android emulators running (or two iOS simulators)
#   - Both emulators listed in `flutter devices`

set -o pipefail

DEVICE_A="${1:-emulator-5554}"
DEVICE_B="${2:-emulator-5556}"
RESULTS_DIR="integration_test/e2e_results"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
RUN_DIR="$RESULTS_DIR/dual_$TIMESTAMP"

mkdir -p "$RUN_DIR"

echo "╔══════════════════════════════════════════════════════════╗"
echo "║  CometChat Flutter UIKit — Dual-Device E2E Test Run     ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║  Device A (User A): $DEVICE_A                           ║"
echo "║  Device B (User B): $DEVICE_B                           ║"
echo "║  Started: $TIMESTAMP                                    ║"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Verify both devices are connected
echo "Checking devices..."
DEVICES=$(flutter devices --machine 2>/dev/null)
if ! echo "$DEVICES" | grep -q "$DEVICE_A"; then
  echo "❌ Device A ($DEVICE_A) not found. Run 'flutter devices' to check."
  exit 1
fi
if ! echo "$DEVICES" | grep -q "$DEVICE_B"; then
  echo "❌ Device B ($DEVICE_B) not found. Run 'flutter devices' to check."
  exit 1
fi
echo "✅ Both devices detected"
echo ""

# ============================================================================
# PHASE 1: Single-device tests (only need Device A)
# These tests use REST API via PeerActions/SeedData to simulate User B
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "PHASE 1: Single-device tests (Device A only)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

SINGLE_DEVICE_TESTS=(
  "integration_test/e2e_message_header_test.dart"
  "integration_test/e2e_message_information_test.dart"
  "integration_test/e2e_users_test.dart"
  "integration_test/e2e_groups_test.dart"
  "integration_test/e2e_message_composer_test.dart"
  "integration_test/e2e_calls_test.dart"
)

TOTAL=0
PASSED=0
FAILED=0
ERRORS=()

for TEST_FILE in "${SINGLE_DEVICE_TESTS[@]}"; do
  BASENAME=$(basename "$TEST_FILE" .dart)
  LOG_FILE="$RUN_DIR/${BASENAME}.log"

  echo "▶ Running: $BASENAME (Device A)"
  TOTAL=$((TOTAL + 1))

  flutter test "$TEST_FILE" -d "$DEVICE_A" 2>&1 | tee "$LOG_FILE"
  EXIT_CODE=${PIPESTATUS[0]}

  if [ $EXIT_CODE -eq 0 ]; then
    echo "  ✅ PASSED"
    PASSED=$((PASSED + 1))
  else
    echo "  ❌ FAILED (exit: $EXIT_CODE)"
    FAILED=$((FAILED + 1))
    ERRORS+=("$BASENAME")
  fi
done

echo ""

# ============================================================================
# PHASE 2: Dual-device tests (Device A + Device B simultaneously)
# These tests require real-time interaction between two logged-in users.
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "PHASE 2: Dual-device tests (Device A + Device B)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# --- Test: Real-time messaging ---
echo "▶ Running: dual_messaging (both devices)"
TOTAL=$((TOTAL + 1))

# Start companion on Device B (background)
flutter test integration_test/companion/companion_app_test.dart \
  -d "$DEVICE_B" \
  --plain-name "Send text message to User A" \
  2>&1 > "$RUN_DIR/companion_messaging.log" &
COMPANION_PID=$!

# Give companion time to login
sleep 8

# Run primary test on Device A
flutter test integration_test/e2e_dual_messaging_test.dart \
  -d "$DEVICE_A" \
  2>&1 | tee "$RUN_DIR/dual_messaging.log"
PRIMARY_EXIT=${PIPESTATUS[0]}

# Wait for companion to finish
wait $COMPANION_PID 2>/dev/null

if [ $PRIMARY_EXIT -eq 0 ]; then
  echo "  ✅ PASSED: dual_messaging"
  PASSED=$((PASSED + 1))
else
  echo "  ❌ FAILED: dual_messaging (exit: $PRIMARY_EXIT)"
  FAILED=$((FAILED + 1))
  ERRORS+=("dual_messaging")
fi

# --- Test: Real-time conversations update ---
echo "▶ Running: dual_conversations (both devices)"
TOTAL=$((TOTAL + 1))

# Start companion sending messages
flutter test integration_test/companion/companion_app_test.dart \
  -d "$DEVICE_B" \
  --plain-name "Send text message to User A" \
  2>&1 > "$RUN_DIR/companion_conversations.log" &
COMPANION_PID=$!

sleep 8

flutter test integration_test/e2e_conversations_test.dart \
  -d "$DEVICE_A" \
  2>&1 | tee "$RUN_DIR/dual_conversations.log"
PRIMARY_EXIT=${PIPESTATUS[0]}

wait $COMPANION_PID 2>/dev/null

if [ $PRIMARY_EXIT -eq 0 ]; then
  echo "  ✅ PASSED: dual_conversations"
  PASSED=$((PASSED + 1))
else
  echo "  ❌ FAILED: dual_conversations (exit: $PRIMARY_EXIT)"
  FAILED=$((FAILED + 1))
  ERRORS+=("dual_conversations")
fi

# --- Test: Online status ---
echo "▶ Running: dual_online_status (both devices)"
TOTAL=$((TOTAL + 1))

# Companion stays online
flutter test integration_test/companion/companion_app_test.dart \
  -d "$DEVICE_B" \
  --plain-name "Stay online as idle peer" \
  2>&1 > "$RUN_DIR/companion_online.log" &
COMPANION_PID=$!

sleep 8

flutter test integration_test/e2e_dual_online_status_test.dart \
  -d "$DEVICE_A" \
  2>&1 | tee "$RUN_DIR/dual_online_status.log"
PRIMARY_EXIT=${PIPESTATUS[0]}

# Kill companion (it runs for 60s)
kill $COMPANION_PID 2>/dev/null
wait $COMPANION_PID 2>/dev/null

if [ $PRIMARY_EXIT -eq 0 ]; then
  echo "  ✅ PASSED: dual_online_status"
  PASSED=$((PASSED + 1))
else
  echo "  ❌ FAILED: dual_online_status (exit: $PRIMARY_EXIT)"
  FAILED=$((FAILED + 1))
  ERRORS+=("dual_online_status")
fi

# --- Test: Message list with real-time incoming ---
echo "▶ Running: dual_message_list (both devices)"
TOTAL=$((TOTAL + 1))

# Companion sends batch messages
flutter test integration_test/companion/companion_app_test.dart \
  -d "$DEVICE_B" \
  --plain-name "Send multiple messages for pagination test" \
  2>&1 > "$RUN_DIR/companion_batch.log" &
COMPANION_PID=$!

sleep 8

flutter test integration_test/e2e_message_list_test.dart \
  -d "$DEVICE_A" \
  2>&1 | tee "$RUN_DIR/dual_message_list.log"
PRIMARY_EXIT=${PIPESTATUS[0]}

wait $COMPANION_PID 2>/dev/null

if [ $PRIMARY_EXIT -eq 0 ]; then
  echo "  ✅ PASSED: dual_message_list"
  PASSED=$((PASSED + 1))
else
  echo "  ❌ FAILED: dual_message_list (exit: $PRIMARY_EXIT)"
  FAILED=$((FAILED + 1))
  ERRORS+=("dual_message_list")
fi

echo ""

# ============================================================================
# SUMMARY
# ============================================================================

SUMMARY_FILE="$RUN_DIR/SUMMARY.md"
cat > "$SUMMARY_FILE" << EOF
# Dual-Device E2E Test Run Summary

**Date:** $TIMESTAMP
**Device A:** $DEVICE_A (User A: ${TEST_USER_A_UID:-cometchat-uid-2})
**Device B:** $DEVICE_B (User B: ${TEST_USER_B_UID:-cometchat-uid-3})
**Total:** $TOTAL | **Passed:** $PASSED | **Failed:** $FAILED

## Phase 1: Single-Device Tests

| Test File | Status |
|-----------|--------|
EOF

for TEST_FILE in "${SINGLE_DEVICE_TESTS[@]}"; do
  BASENAME=$(basename "$TEST_FILE" .dart)
  if [[ " ${ERRORS[*]} " =~ " $BASENAME " ]]; then
    echo "| $BASENAME | ❌ Failed |" >> "$SUMMARY_FILE"
  else
    echo "| $BASENAME | ✅ Passed |" >> "$SUMMARY_FILE"
  fi
done

cat >> "$SUMMARY_FILE" << EOF

## Phase 2: Dual-Device Tests

| Test | Status |
|------|--------|
| dual_messaging | $(if [[ " ${ERRORS[*]} " =~ " dual_messaging " ]]; then echo "❌ Failed"; else echo "✅ Passed"; fi) |
| dual_conversations | $(if [[ " ${ERRORS[*]} " =~ " dual_conversations " ]]; then echo "❌ Failed"; else echo "✅ Passed"; fi) |
| dual_online_status | $(if [[ " ${ERRORS[*]} " =~ " dual_online_status " ]]; then echo "❌ Failed"; else echo "✅ Passed"; fi) |
| dual_message_list | $(if [[ " ${ERRORS[*]} " =~ " dual_message_list " ]]; then echo "❌ Failed"; else echo "✅ Passed"; fi) |
EOF

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo "" >> "$SUMMARY_FILE"
  echo "## Failed Tests" >> "$SUMMARY_FILE"
  for ERR in "${ERRORS[@]}"; do
    echo "- \`$ERR\` — see \`$ERR.log\`" >> "$SUMMARY_FILE"
  done
fi

echo "╔══════════════════════════════════════════════════════════╗"
echo "║  SUMMARY                                                ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║  Total:  $TOTAL                                         ║"
echo "║  Passed: $PASSED                                        ║"
echo "║  Failed: $FAILED                                        ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║  Results: $RUN_DIR/                                     ║"
echo "╚══════════════════════════════════════════════════════════╝"

exit $FAILED
