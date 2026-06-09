#!/bin/bash
# Run all e2e test files sequentially on emulator and store results.
# Usage: ./integration_test/run_all_e2e.sh

set -o pipefail

DEVICE="${1:-emulator-5554}"
RESULTS_DIR="integration_test/e2e_results"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
RUN_DIR="$RESULTS_DIR/$TIMESTAMP"

mkdir -p "$RUN_DIR"

TEST_FILES=(
  "integration_test/e2e_message_header_test.dart"
  "integration_test/e2e_message_information_test.dart"
  "integration_test/e2e_conversations_test.dart"
  "integration_test/e2e_users_test.dart"
  "integration_test/e2e_message_list_test.dart"
  "integration_test/e2e_message_composer_test.dart"
  "integration_test/e2e_groups_test.dart"
  "integration_test/e2e_calls_test.dart"
)

TOTAL=0
PASSED=0
FAILED=0
ERRORS=()

echo "╔══════════════════════════════════════════════════════╗"
echo "║  CometChat Flutter UIKit — E2E Test Run             ║"
echo "║  Device: $DEVICE                                    ║"
echo "║  Started: $TIMESTAMP                                ║"
echo "╚══════════════════════════════════════════════════════╝"
echo ""

for TEST_FILE in "${TEST_FILES[@]}"; do
  BASENAME=$(basename "$TEST_FILE" .dart)
  LOG_FILE="$RUN_DIR/${BASENAME}.log"

  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "▶ Running: $BASENAME"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

  TOTAL=$((TOTAL + 1))

  flutter test "$TEST_FILE" -d "$DEVICE" 2>&1 | tee "$LOG_FILE"
  EXIT_CODE=${PIPESTATUS[0]}

  if [ $EXIT_CODE -eq 0 ]; then
    echo "✅ PASSED: $BASENAME"
    PASSED=$((PASSED + 1))
  else
    echo "❌ FAILED: $BASENAME (exit code: $EXIT_CODE)"
    FAILED=$((FAILED + 1))
    ERRORS+=("$BASENAME")
  fi
  echo ""
done

# Write summary
SUMMARY_FILE="$RUN_DIR/SUMMARY.md"
cat > "$SUMMARY_FILE" << EOF
# E2E Test Run Summary

**Date:** $TIMESTAMP
**Device:** $DEVICE
**Total Files:** $TOTAL
**Passed:** $PASSED
**Failed:** $FAILED

## Results

| Test File | Status |
|-----------|--------|
EOF

for TEST_FILE in "${TEST_FILES[@]}"; do
  BASENAME=$(basename "$TEST_FILE" .dart)
  if [[ " ${ERRORS[*]} " =~ " $BASENAME " ]]; then
    echo "| $BASENAME | ❌ Failed |" >> "$SUMMARY_FILE"
  else
    echo "| $BASENAME | ✅ Passed |" >> "$SUMMARY_FILE"
  fi
done

if [ ${#ERRORS[@]} -gt 0 ]; then
  echo "" >> "$SUMMARY_FILE"
  echo "## Failed Tests" >> "$SUMMARY_FILE"
  for ERR in "${ERRORS[@]}"; do
    echo "- \`$ERR\` — see \`$ERR.log\` for details" >> "$SUMMARY_FILE"
  done
fi

echo ""
echo "╔══════════════════════════════════════════════════════╗"
echo "║  SUMMARY                                            ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  Total:  $TOTAL                                     ║"
echo "║  Passed: $PASSED                                    ║"
echo "║  Failed: $FAILED                                    ║"
echo "╠══════════════════════════════════════════════════════╣"
echo "║  Results: $RUN_DIR/                                 ║"
echo "╚══════════════════════════════════════════════════════╝"

exit $FAILED
