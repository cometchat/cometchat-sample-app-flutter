#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════════
# CometChat Flutter UIKit — E2E Test Runner (Web / Google Chrome)
#
# Runs all E2E test suites via ChromeDriver + Google Chrome.
# Skips: calls_test (platform N/A), composer_voice_test (audio recording N/A)
#
# Usage:
#   ./integration_test/run_web.sh [RESULTS_DIR]
#
# Prerequisites:
#   - Google Chrome installed at /Applications/Google Chrome.app
#   - chromedriver matching your Chrome major version, at the CHROMEDRIVER path below
# ═══════════════════════════════════════════════════════════════════════════════

set -o pipefail

# Browser + driver paths. Default to Google Chrome; override via env for any
# Chromium-based browser, e.g.  CHROME_BIN="/Applications/Brave Browser.app/Contents/MacOS/Brave Browser" ./run_web.sh
CHROME_BIN="${CHROME_BIN:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
CHROMEDRIVER="${CHROMEDRIVER:-/tmp/cft-cd148/chromedriver-mac-arm64/chromedriver}"

# Process name of whatever browser CHROME_BIN points at (e.g. "Google Chrome"
# or "Brave Browser"), so the per-suite kill actually matches the running
# browser regardless of which Chromium build is used.
BROWSER_NAME="$(basename "$CHROME_BIN")"

# Purge the throwaway browser data flutter drive + the Chromium engine leave in
# the temp dir. BOTH patterns matter: flutter sets --user-data-dir under
# flutter_tools.*, and the engine also spawns org.chromium.Chromium.scoped_dir.*
# (~260MB each). Left uncleaned they accumulate across 34 suites and fill the disk.
purge_browser_temp() {
  rm -rf /var/folders/*/*/T/flutter_tools.* 2>/dev/null
  rm -rf /var/folders/*/*/T/org.chromium.Chromium.scoped_dir.* 2>/dev/null
}

# Headless peer ("User B") for the web run. We override the default
# cometchat-uid-3 with cometchat-uid-5 (John Paul): User A (cometchat-uid-2)
# has a leaked, mutual block with cometchat-uid-3 left over from prior runs,
# which makes every peer `POST /messages` return 403 ERR_BLOCKED_RECEIVER and
# cascades failures across the receive/messaging/reactions/thread suites.
# uid-2 <-> uid-5 is verified clean.
WEB_USER_B_UID="cometchat-uid-5"
WEB_USER_B_NAME="John Paul"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
RESULTS_DIR="${1:-integration_test/e2e_results/web_$TIMESTAMP}"

export CHROME_EXECUTABLE="$CHROME_BIN"

mkdir -p "$RESULTS_DIR"

echo "╔══════════════════════════════════════════════════════════╗"
echo "║  CometChat Flutter UIKit — E2E Tests (Web/Chrome)       ║"
echo "╠══════════════════════════════════════════════════════════╣"
echo "║  Browser: Google Chrome                                 ║"
echo "║  Started: $TIMESTAMP"
echo "╚══════════════════════════════════════════════════════════╝"
echo ""

# Start ChromeDriver
pkill -f chromedriver 2>/dev/null
"$CHROMEDRIVER" --port=4444 &
CHROMEDRIVER_PID=$!
sleep 2
echo "ChromeDriver started (PID: $CHROMEDRIVER_PID)"
echo ""

# Web wrapper suites (one per original suite, in integration_test/ root)
SUITES=(
  "integration_test/web_auth_test.dart"
  "integration_test/web_users_test.dart"
  "integration_test/web_conversations_test.dart"
  "integration_test/web_message_header_test.dart"
  "integration_test/web_send_message_test.dart"
  "integration_test/web_receive_message_test.dart"
  "integration_test/web_edit_message_test.dart"
  "integration_test/web_delete_message_test.dart"
  "integration_test/web_message_actions_test.dart"
  "integration_test/web_media_messages_test.dart"
  "integration_test/web_reactions_test.dart"
  "integration_test/web_thread_replies_test.dart"
  "integration_test/web_typing_indicator_test.dart"
  "integration_test/web_read_receipts_test.dart"
  "integration_test/web_presence_test.dart"
  "integration_test/web_block_user_test.dart"
  "integration_test/web_user_info_test.dart"
  "integration_test/web_pagination_test.dart"
  "integration_test/web_composer_test.dart"
  "integration_test/web_search_test.dart"
  "integration_test/web_connection_test.dart"
  "integration_test/web_configuration_test.dart"
  "integration_test/web_groups_test.dart"
  "integration_test/web_edge_cases_test.dart"
  "integration_test/web_ui_surfaces_test.dart"
  "integration_test/web_groups_extended_test.dart"
  "integration_test/web_group_composer_test.dart"
  "integration_test/web_group_message_actions_test.dart"
  "integration_test/web_group_media_messages_test.dart"
  "integration_test/web_group_reactions_test.dart"
  "integration_test/web_group_thread_messages_test.dart"
  "integration_test/web_group_header_test.dart"
  "integration_test/web_group_members_test.dart"
  "integration_test/web_groups_realtime_test.dart"
  # Skipped: calls_test (calls N/A on web), composer_voice_test (audio N/A)
)

TOTAL=0
PASSED=0
FAILED=0
ERRORS=()

for SUITE in "${SUITES[@]}"; do
  BASENAME=$(basename "$SUITE" .dart)
  LOG_FILE="$RESULTS_DIR/${BASENAME}.log"

  # Skip if already completed in a previous run
  if [ -f "$LOG_FILE" ] && grep -qE "All tests passed!|Some tests failed\." "$LOG_FILE" 2>/dev/null; then
    echo "  SKIP (already done): $BASENAME"
    if grep -q "All tests passed!" "$LOG_FILE"; then
      PASSED=$((PASSED + 1))
    else
      FAILED=$((FAILED + 1))
      ERRORS+=("$BASENAME")
    fi
    TOTAL=$((TOTAL + 1))
    continue
  fi

  echo "Running: $BASENAME"
  TOTAL=$((TOTAL + 1))

  # Restart ChromeDriver before each suite — it exits when the browser session
  # closes, so we must restart it for every run. Kill any lingering browser
  # windows first to ensure only one browser instance is open at a time, then
  # purge any leftover profile temp dirs.
  pkill -f "chromedriver --port=4444" 2>/dev/null
  pkill -f "$BROWSER_NAME" 2>/dev/null
  sleep 1
  purge_browser_temp
  "$CHROMEDRIVER" --port=4444 &
  CHROMEDRIVER_PID=$!
  sleep 2

  # `flutter drive` reliably HANGS after the test run finishes on web — the
  # browser session closes but the driver process never exits, blocking the
  # loop forever. So we run it in the background, then poll the log for the
  # final result marker ("All tests passed!" / "Some tests failed.") and kill
  # the process as soon as we see it. A hard 20-minute backstop covers a genuine
  # hang before any result is written.
  CHROME_EXECUTABLE="$CHROME_BIN" flutter drive \
    --driver=test_driver/integration_test.dart \
    --target="$SUITE" \
    -d chrome \
    --chrome-binary="$CHROME_BIN" \
    --dart-define=TEST_USER_B_UID="$WEB_USER_B_UID" \
    --dart-define=TEST_USER_B_NAME="$WEB_USER_B_NAME" \
    > "$LOG_FILE" 2>&1 &
  DRIVE_PID=$!

  RESULT=""        # "pass" | "fail" | "timeout"
  WAITED=0
  MAX_WAIT=1200    # 20 min hard backstop
  while kill -0 "$DRIVE_PID" 2>/dev/null; do
    if grep -q "All tests passed!" "$LOG_FILE" 2>/dev/null; then
      RESULT="pass"; break
    elif grep -q "Some tests failed\." "$LOG_FILE" 2>/dev/null; then
      RESULT="fail"; break
    fi
    if [ $WAITED -ge $MAX_WAIT ]; then
      RESULT="timeout"; break
    fi
    sleep 3
    WAITED=$((WAITED + 3))
  done

  # Tear down the (possibly hung) driver + browser for this suite, then purge
  # its profile temp dirs so they don't accumulate and fill the disk.
  kill "$DRIVE_PID" 2>/dev/null
  pkill -f "$BROWSER_NAME" 2>/dev/null
  sleep 1
  purge_browser_temp

  # If the process exited on its own before we caught a marker, read the log.
  if [ -z "$RESULT" ]; then
    if grep -q "All tests passed!" "$LOG_FILE" 2>/dev/null; then
      RESULT="pass"
    else
      RESULT="fail"
    fi
  fi

  case "$RESULT" in
    pass)
      echo "  PASSED: $BASENAME"
      PASSED=$((PASSED + 1)) ;;
    timeout)
      echo "  TIMEOUT after 20min: $BASENAME"
      FAILED=$((FAILED + 1)); ERRORS+=("$BASENAME (timeout)") ;;
    *)
      echo "  FAILED: $BASENAME"
      FAILED=$((FAILED + 1)); ERRORS+=("$BASENAME") ;;
  esac
  echo ""
done

kill $CHROMEDRIVER_PID 2>/dev/null

echo ""
echo "╔══════════════════════════════════════════════════════════╗"
echo "║  RESULTS (Web / Google Chrome)                          ║"
echo "╠══════════════════════════════════════════════════════════╣"
printf "║  Total:  %-4s                                          ║\n" "$TOTAL"
printf "║  Passed: %-4s                                          ║\n" "$PASSED"
printf "║  Failed: %-4s                                          ║\n" "$FAILED"
if [ ${#ERRORS[@]} -gt 0 ]; then
  echo "╠══════════════════════════════════════════════════════════╣"
  echo "║  Failed suites:                                         ║"
  for e in "${ERRORS[@]}"; do
    printf "║    %-54s║\n" "• $e"
  done
fi
echo "╠══════════════════════════════════════════════════════════╣"
echo "║  Results: $RESULTS_DIR/"
echo "╚══════════════════════════════════════════════════════════╝"

exit $FAILED
