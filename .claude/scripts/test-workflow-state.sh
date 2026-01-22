#!/bin/bash

# Test script for workflow state persistence system

set -e

LOGGER=".claude/scripts/workflow-logger.sh"
TEST_DIR=".specify-test"

echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                 WORKFLOW STATE PERSISTENCE TEST                            ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""

# Cleanup function
cleanup() {
    echo ""
    echo "Cleaning up test directory..."
    rm -rf "${TEST_DIR}"
}

trap cleanup EXIT

# Create test directory
mkdir -p "${TEST_DIR}"
cd "${TEST_DIR}"
mkdir -p .claude/scripts
cp "../${LOGGER}" .claude/scripts/

echo "✓ Test environment created"
echo ""

# Test 1: Initialize workflow state
echo "Test 1: Initialize workflow state"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
mkdir -p .specify
SESSION_ID=$("${LOGGER}" init)
echo "Session ID: ${SESSION_ID}"

if [ -f ".specify/workflow-state.json" ]; then
    echo "✓ workflow-state.json created"
else
    echo "✗ workflow-state.json NOT created"
    exit 1
fi

if [ -f ".specify/workflow-progress.log" ]; then
    echo "✓ workflow-progress.log created"
else
    echo "✗ workflow-progress.log NOT created"
    exit 1
fi

CURRENT_PHASE=$(jq -r '.current_phase' .specify/workflow-state.json)
if [ "${CURRENT_PHASE}" = "0" ]; then
    echo "✓ Current phase is 0"
else
    echo "✗ Current phase is ${CURRENT_PHASE}, expected 0"
    exit 1
fi

echo ""

# Test 2: Log phase start
echo "Test 2: Log phase start"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"${LOGGER}" phase-start 1 "INIT"

CURRENT_PHASE=$(jq -r '.current_phase' .specify/workflow-state.json)
if [ "${CURRENT_PHASE}" = "1" ]; then
    echo "✓ Current phase updated to 1"
else
    echo "✗ Current phase is ${CURRENT_PHASE}, expected 1"
    exit 1
fi

IN_PROGRESS=$(jq -r '.phases_in_progress | contains([1])' .specify/workflow-state.json)
if [ "${IN_PROGRESS}" = "true" ]; then
    echo "✓ Phase 1 marked as in progress"
else
    echo "✗ Phase 1 NOT marked as in progress"
    exit 1
fi

echo ""

# Test 3: Log phase completion
echo "Test 3: Log phase completion"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"${LOGGER}" phase-complete 1 "A"

COMPLETED=$(jq -r '.phases_completed | contains([1])' .specify/workflow-state.json)
if [ "${COMPLETED}" = "true" ]; then
    echo "✓ Phase 1 marked as completed"
else
    echo "✗ Phase 1 NOT marked as completed"
    exit 1
fi

IN_PROGRESS=$(jq -r '.phases_in_progress | contains([1])' .specify/workflow-state.json)
if [ "${IN_PROGRESS}" = "false" ]; then
    echo "✓ Phase 1 removed from in progress"
else
    echo "✗ Phase 1 still in progress"
    exit 1
fi

LAST_GRADE=$(jq -r '.validation_status.last_validation_grade' .specify/workflow-state.json)
if [ "${LAST_GRADE}" = "A" ]; then
    echo "✓ Last validation grade is A"
else
    echo "✗ Last validation grade is ${LAST_GRADE}, expected A"
    exit 1
fi

echo ""

# Test 4: Run multiple phases
echo "Test 4: Run multiple phases"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"${LOGGER}" phase-start 2 "ANALYZE_PROJECT"
"${LOGGER}" phase-complete 2 "B"
"${LOGGER}" phase-start 3 "ANALYZE_REQUIREMENTS"
"${LOGGER}" phase-complete 3 "A"

COMPLETED=$(jq -r '.phases_completed | length' .specify/workflow-state.json)
if [ "${COMPLETED}" = "3" ]; then
    echo "✓ 3 phases completed"
else
    echo "✗ ${COMPLETED} phases completed, expected 3"
    exit 1
fi

CURRENT_PHASE=$(jq -r '.current_phase' .specify/workflow-state.json)
if [ "${CURRENT_PHASE}" = "3" ]; then
    echo "✓ Current phase is 3"
else
    echo "✗ Current phase is ${CURRENT_PHASE}, expected 3"
    exit 1
fi

echo ""

# Test 5: Feature progress tracking
echo "Test 5: Feature progress tracking"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Set complexity to COMPLEX
jq '.complexity = "COMPLEX" | .features.total = 3 | .features.pending = ["F-01", "F-02", "F-03"]' \
   .specify/workflow-state.json > .specify/workflow-state.json.tmp
mv .specify/workflow-state.json.tmp .specify/workflow-state.json

"${LOGGER}" feature-start "F-01" "User Authentication"

CURRENT_FEATURE=$(jq -r '.features.current' .specify/workflow-state.json)
if [ "${CURRENT_FEATURE}" = "F-01" ]; then
    echo "✓ Current feature is F-01"
else
    echo "✗ Current feature is ${CURRENT_FEATURE}, expected F-01"
    exit 1
fi

"${LOGGER}" feature-complete "F-01"

COMPLETED=$(jq -r '.features.completed | contains(["F-01"])' .specify/workflow-state.json)
if [ "${COMPLETED}" = "true" ]; then
    echo "✓ F-01 marked as completed"
else
    echo "✗ F-01 NOT marked as completed"
    exit 1
fi

CURRENT_FEATURE=$(jq -r '.features.current' .specify/workflow-state.json)
if [ "${CURRENT_FEATURE}" = "F-02" ]; then
    echo "✓ Current feature auto-updated to F-02"
else
    echo "✗ Current feature is ${CURRENT_FEATURE}, expected F-02"
    exit 1
fi

echo ""

# Test 6: Resume point generation
echo "Test 6: Resume point generation"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

CAN_RESUME=$(jq -r '.resume_capability.can_resume' .specify/workflow-state.json)
if [ "${CAN_RESUME}" = "true" ]; then
    echo "✓ Can resume is true"
else
    echo "✗ Can resume is ${CAN_RESUME}, expected true"
    exit 1
fi

RESUME_POINT=$(jq -r '.resume_capability.resume_point' .specify/workflow-state.json)
echo "Resume point: ${RESUME_POINT}"

if [[ "${RESUME_POINT}" == *"F-02"* ]]; then
    echo "✓ Resume point mentions F-02"
else
    echo "✗ Resume point doesn't mention F-02"
    exit 1
fi

echo ""

# Test 7: Generate resume report
echo "Test 7: Generate resume report"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
"${LOGGER}" resume-report
echo "✓ Resume report generated successfully"
echo ""

# Test 8: Progress log verification
echo "Test 8: Progress log verification"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

LOG_LINES=$(wc -l < .specify/workflow-progress.log)
echo "Progress log has ${LOG_LINES} lines"

if [ "${LOG_LINES}" -gt 5 ]; then
    echo "✓ Progress log has entries"
else
    echo "✗ Progress log has insufficient entries"
    exit 1
fi

# Check for expected events
if grep -q "SESSION_START" .specify/workflow-progress.log; then
    echo "✓ SESSION_START logged"
else
    echo "✗ SESSION_START NOT logged"
    exit 1
fi

if grep -q "PHASE_START.*phase=1" .specify/workflow-progress.log; then
    echo "✓ PHASE_START logged"
else
    echo "✗ PHASE_START NOT logged"
    exit 1
fi

if grep -q "PHASE_COMPLETE.*phase=1" .specify/workflow-progress.log; then
    echo "✓ PHASE_COMPLETE logged"
else
    echo "✗ PHASE_COMPLETE NOT logged"
    exit 1
fi

if grep -q "FEATURE_START.*F-01" .specify/workflow-progress.log; then
    echo "✓ FEATURE_START logged"
else
    echo "✗ FEATURE_START NOT logged"
    exit 1
fi

echo ""

# Test 9: State detection from artifacts
echo "Test 9: State detection from artifacts"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Create some artifacts
mkdir -p .claude/skills/test-skill
touch .claude/skills/test-skill/SKILL.md
mkdir -p .specify/templates
touch .specify/constitution.md
touch .specify/spec.md
touch .specify/plan.md

# Backup current state
mv .specify/workflow-state.json .specify/workflow-state.backup.json

# Detect state
"${LOGGER}" detect

DETECTED_PHASE=$(jq -r '.current_phase' .specify/workflow-state.json)
echo "Detected phase: ${DETECTED_PHASE}"

if [ "${DETECTED_PHASE}" -ge 7 ]; then
    echo "✓ Detected phase >= 7 (constitution exists)"
else
    echo "✗ Detected phase is ${DETECTED_PHASE}, expected >= 7"
    exit 1
fi

echo ""

# All tests passed
echo "╔════════════════════════════════════════════════════════════════════════════╗"
echo "║                          ALL TESTS PASSED ✓                                ║"
echo "╚════════════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Workflow state persistence system is working correctly!"
echo ""
