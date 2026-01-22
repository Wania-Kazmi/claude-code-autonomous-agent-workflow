#!/bin/bash

# Workflow State Logger
# Helper script for logging workflow progress and managing state

set -e

WORKFLOW_STATE_FILE=".specify/workflow-state.json"
PROGRESS_LOG_FILE=".specify/workflow-progress.log"

# ═══════════════════════════════════════════════════════════════════════════════
# LOGGING FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

log_event() {
    local event="$1"
    shift
    local data="$@"
    local timestamp=$(date -Iseconds)

    echo "[${timestamp}] ${event} ${data}" >> "${PROGRESS_LOG_FILE}"
}

log_session_start() {
    local session_id="session-$(date +%Y%m%d-%H%M%S)"
    log_event "SESSION_START" "session_id=${session_id}"
    echo "${session_id}"
}

log_session_end() {
    log_event "SESSION_END" "status=complete"
}

log_session_interrupt() {
    local reason="${1:-User stopped process}"
    log_event "SESSION_INTERRUPT" "reason=\"${reason}\""
}

log_phase_start() {
    local phase="$1"
    local name="$2"
    local feature="${3:-}"

    if [ -n "${feature}" ]; then
        log_event "PHASE_START" "phase=${phase} name=${name} feature=${feature}"
    else
        log_event "PHASE_START" "phase=${phase} name=${name}"
    fi
}

log_phase_complete() {
    local phase="$1"
    local grade="${2:-N/A}"
    local feature="${3:-}"

    if [ -n "${feature}" ]; then
        log_event "PHASE_COMPLETE" "phase=${phase} grade=${grade} feature=${feature}"
    else
        log_event "PHASE_COMPLETE" "phase=${phase} grade=${grade}"
    fi
}

log_phase_fail() {
    local phase="$1"
    local reason="${2:-Unknown error}"
    local feature="${3:-}"

    if [ -n "${feature}" ]; then
        log_event "PHASE_FAIL" "phase=${phase} reason=\"${reason}\" feature=${feature}"
    else
        log_event "PHASE_FAIL" "phase=${phase} reason=\"${reason}\""
    fi
}

log_feature_start() {
    local feature_id="$1"
    local feature_name="$2"
    log_event "FEATURE_START" "feature=${feature_id} name=\"${feature_name}\""
}

log_feature_complete() {
    local feature_id="$1"
    log_event "FEATURE_COMPLETE" "feature=${feature_id}"
}

log_task_start() {
    local task_id="$1"
    local task_name="$2"
    log_event "TASK_START" "task=${task_id} name=\"${task_name}\""
}

log_task_complete() {
    local task_id="$1"
    log_event "TASK_COMPLETE" "task=${task_id}"
}

log_complexity_detected() {
    local type="$1"
    local features="$2"
    log_event "COMPLEXITY_DETECTED" "type=${type} features=${features}"
}

log_validation() {
    local phase="$1"
    local grade="$2"
    local status="$3"
    log_event "VALIDATION_COMPLETE" "phase=${phase} grade=${grade} status=${status}"
}

log_skill_loaded() {
    local skill="$1"
    log_event "SKILL_LOADED" "skill=${skill}"
}

log_agent_invoked() {
    local agent="$1"
    log_event "AGENT_INVOKED" "agent=${agent}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# STATE MANAGEMENT FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

init_workflow_state() {
    local session_id=$(log_session_start)

    cat > "${WORKFLOW_STATE_FILE}" <<EOF
{
  "version": "2.0",
  "last_updated": "$(date -Iseconds)",
  "current_phase": 0,
  "project_type": "unknown",
  "session_id": "${session_id}",
  "phases_completed": [],
  "phases_in_progress": [],
  "total_phases": 13,
  "complexity": "SIMPLE",
  "features": {
    "total": 0,
    "completed": [],
    "current": null,
    "pending": []
  },
  "artifacts": {
    "constitution": false,
    "spec": false,
    "plan": false,
    "tasks": false,
    "implementation_started": false,
    "tests_passing": false
  },
  "validation_status": {
    "last_validation_phase": null,
    "last_validation_grade": null,
    "validation_reports": []
  },
  "resume_capability": {
    "can_resume": false,
    "resume_point": null,
    "resume_instructions": null
  }
}
EOF

    echo "${session_id}"
}

update_phase_progress() {
    local phase="$1"
    local status="$2"  # start, complete, fail
    local feature="${3:-null}"
    local grade="${4:-null}"

    if [ ! -f "${WORKFLOW_STATE_FILE}" ]; then
        echo "Error: Workflow state file not found. Run init_workflow_state first."
        return 1
    fi

    local timestamp=$(date -Iseconds)

    # Use jq to update state
    case "${status}" in
        start)
            jq --arg phase "${phase}" \
               --arg timestamp "${timestamp}" \
               --arg feature "${feature}" \
               '.current_phase = ($phase | tonumber) |
                .phases_in_progress += [$phase | tonumber] |
                .last_updated = $timestamp' \
               "${WORKFLOW_STATE_FILE}" > "${WORKFLOW_STATE_FILE}.tmp"
            mv "${WORKFLOW_STATE_FILE}.tmp" "${WORKFLOW_STATE_FILE}"
            ;;

        complete)
            jq --arg phase "${phase}" \
               --arg grade "${grade}" \
               --arg timestamp "${timestamp}" \
               '.phases_completed += [$phase | tonumber] |
                .phases_in_progress -= [$phase | tonumber] |
                .validation_status.last_validation_phase = ($phase | tonumber) |
                .validation_status.last_validation_grade = $grade |
                .last_updated = $timestamp' \
               "${WORKFLOW_STATE_FILE}" > "${WORKFLOW_STATE_FILE}.tmp"
            mv "${WORKFLOW_STATE_FILE}.tmp" "${WORKFLOW_STATE_FILE}"
            ;;

        fail)
            log_phase_fail "${phase}" "Phase failed"
            ;;
    esac

    update_resume_point
}

update_feature_progress() {
    local feature_id="$1"
    local status="$2"  # start, complete

    if [ ! -f "${WORKFLOW_STATE_FILE}" ]; then
        echo "Error: Workflow state file not found."
        return 1
    fi

    local timestamp=$(date -Iseconds)

    case "${status}" in
        start)
            jq --arg feature "${feature_id}" \
               --arg timestamp "${timestamp}" \
               '.features.current = $feature |
                .last_updated = $timestamp' \
               "${WORKFLOW_STATE_FILE}" > "${WORKFLOW_STATE_FILE}.tmp"
            mv "${WORKFLOW_STATE_FILE}.tmp" "${WORKFLOW_STATE_FILE}"
            ;;

        complete)
            jq --arg feature "${feature_id}" \
               --arg timestamp "${timestamp}" \
               '.features.completed += [$feature] |
                .features.pending -= [$feature] |
                .last_updated = $timestamp' \
               "${WORKFLOW_STATE_FILE}" > "${WORKFLOW_STATE_FILE}.tmp"
            mv "${WORKFLOW_STATE_FILE}.tmp" "${WORKFLOW_STATE_FILE}"

            # Set current to next pending feature
            local next_feature=$(jq -r '.features.pending[0] // null' "${WORKFLOW_STATE_FILE}")
            jq --arg next "${next_feature}" \
               '.features.current = (if $next == "null" then null else $next end)' \
               "${WORKFLOW_STATE_FILE}" > "${WORKFLOW_STATE_FILE}.tmp"
            mv "${WORKFLOW_STATE_FILE}.tmp" "${WORKFLOW_STATE_FILE}"
            ;;
    esac

    update_resume_point
}

update_resume_point() {
    if [ ! -f "${WORKFLOW_STATE_FILE}" ]; then
        return
    fi

    local current_phase=$(jq -r '.current_phase' "${WORKFLOW_STATE_FILE}")
    local complexity=$(jq -r '.complexity' "${WORKFLOW_STATE_FILE}")
    local current_feature=$(jq -r '.features.current // "null"' "${WORKFLOW_STATE_FILE}")

    local phase_names=(
        [1]="INIT"
        [2]="ANALYZE_PROJECT"
        [3]="ANALYZE_REQUIREMENTS"
        [4]="GAP_ANALYSIS"
        [5]="GENERATE_SKILLS"
        [7]="CONSTITUTION"
        [8]="SPEC"
        [9]="PLAN"
        [10]="TASKS"
        [11]="IMPLEMENT"
        [12]="QA"
        [13]="DELIVER"
    )

    local resume_point
    local resume_instructions

    if [ "${complexity}" = "COMPLEX" ] && [ "${current_feature}" != "null" ]; then
        resume_point="Phase ${current_phase}: Feature ${current_feature} - ${phase_names[$current_phase]}"
        resume_instructions="Continue working on feature ${current_feature} at phase ${current_phase}"
    else
        resume_point="Phase ${current_phase}: ${phase_names[$current_phase]}"
        resume_instructions="Resume from phase ${current_phase}"
    fi

    jq --arg point "${resume_point}" \
       --arg instructions "${resume_instructions}" \
       '.resume_capability.can_resume = true |
        .resume_capability.resume_point = $point |
        .resume_capability.resume_instructions = $instructions' \
       "${WORKFLOW_STATE_FILE}" > "${WORKFLOW_STATE_FILE}.tmp"
    mv "${WORKFLOW_STATE_FILE}.tmp" "${WORKFLOW_STATE_FILE}"
}

# ═══════════════════════════════════════════════════════════════════════════════
# RESUME FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

generate_resume_report() {
    if [ ! -f "${WORKFLOW_STATE_FILE}" ]; then
        echo "No workflow state found."
        return 1
    fi

    local project_type=$(jq -r '.complexity' "${WORKFLOW_STATE_FILE}")
    local current_phase=$(jq -r '.current_phase' "${WORKFLOW_STATE_FILE}")
    local phases_completed=$(jq -r '.phases_completed | join(", ")' "${WORKFLOW_STATE_FILE}")
    local resume_point=$(jq -r '.resume_capability.resume_point // "N/A"' "${WORKFLOW_STATE_FILE}")
    local resume_instructions=$(jq -r '.resume_capability.resume_instructions // "Start from Phase 0"' "${WORKFLOW_STATE_FILE}")
    local last_updated=$(jq -r '.last_updated' "${WORKFLOW_STATE_FILE}")
    local last_validation_phase=$(jq -r '.validation_status.last_validation_phase // "N/A"' "${WORKFLOW_STATE_FILE}")
    local last_validation_grade=$(jq -r '.validation_status.last_validation_grade // "N/A"' "${WORKFLOW_STATE_FILE}")

    echo "╔════════════════════════════════════════════════════════════════════════════╗"
    echo "║                    WORKFLOW RESUME REPORT                                   ║"
    echo "╠════════════════════════════════════════════════════════════════════════════╣"
    echo ""
    echo "Project Type: ${project_type}"
    echo "Current Phase: ${current_phase}"
    echo "Phases Completed: ${phases_completed}"
    echo ""

    if [ "${project_type}" = "COMPLEX" ]; then
        local total_features=$(jq -r '.features.total' "${WORKFLOW_STATE_FILE}")
        local completed_features=$(jq -r '.features.completed | join(", ")' "${WORKFLOW_STATE_FILE}")
        local current_feature=$(jq -r '.features.current // "None"' "${WORKFLOW_STATE_FILE}")
        local pending_features=$(jq -r '.features.pending | join(", ")' "${WORKFLOW_STATE_FILE}")

        echo "Features:"
        echo "  Total: ${total_features}"
        echo "  Completed: ${completed_features:-None}"
        echo "  Current: ${current_feature}"
        echo "  Pending: ${pending_features:-None}"
        echo ""
    fi

    local constitution=$(jq -r '.artifacts.constitution' "${WORKFLOW_STATE_FILE}")
    local spec=$(jq -r '.artifacts.spec' "${WORKFLOW_STATE_FILE}")
    local plan=$(jq -r '.artifacts.plan' "${WORKFLOW_STATE_FILE}")
    local tasks=$(jq -r '.artifacts.tasks' "${WORKFLOW_STATE_FILE}")
    local implementation=$(jq -r '.artifacts.implementation_started' "${WORKFLOW_STATE_FILE}")
    local tests=$(jq -r '.artifacts.tests_passing' "${WORKFLOW_STATE_FILE}")

    echo "Artifacts:"
    echo "  ✓ Constitution: $([ "$constitution" = "true" ] && echo "YES" || echo "NO")"
    echo "  ✓ Spec: $([ "$spec" = "true" ] && echo "YES" || echo "NO")"
    echo "  ✓ Plan: $([ "$plan" = "true" ] && echo "YES" || echo "NO")"
    echo "  ✓ Tasks: $([ "$tasks" = "true" ] && echo "YES" || echo "NO")"
    echo "  ✓ Implementation: $([ "$implementation" = "true" ] && echo "STARTED" || echo "NOT STARTED")"
    echo "  ✓ Tests Passing: $([ "$tests" = "true" ] && echo "YES" || echo "NO")"
    echo ""
    echo "Resume Point:"
    echo "  ${resume_point}"
    echo ""
    echo "Instructions:"
    echo "  ${resume_instructions}"
    echo ""
    echo "Last Updated: ${last_updated}"
    echo "Last Validation: Phase ${last_validation_phase} - Grade ${last_validation_grade}"
    echo ""
    echo "╚════════════════════════════════════════════════════════════════════════════╝"
}

detect_current_state() {
    echo "Detecting workflow state from artifacts..."

    local phase=0
    local complexity="SIMPLE"
    local phases_completed=()

    # Check phase artifacts
    [ -d ".specify" ] && [ -d ".claude" ] && phase=1 && phases_completed+=(1)
    [ -f ".specify/project-analysis.json" ] && phase=2 && phases_completed+=(2)
    [ -f ".specify/requirements-analysis.json" ] && phase=3 && phases_completed+=(3)
    [ -f ".specify/gap-analysis.json" ] && phase=4 && phases_completed+=(4)

    local skill_count=$(find .claude/skills -name "SKILL.md" 2>/dev/null | wc -l)
    [ "${skill_count}" -gt 5 ] && phase=5 && phases_completed+=(5)

    [ -f ".specify/feature-breakdown.json" ] && complexity="COMPLEX"
    [ -f ".specify/constitution.md" ] && phase=7 && phases_completed+=(7)
    [ -f ".specify/spec.md" ] && phase=8 && phases_completed+=(8)
    [ -f ".specify/plan.md" ] && phase=9 && phases_completed+=(9)
    [ -f ".specify/tasks.md" ] && phase=10 && phases_completed+=(10)
    [ -d "src" ] || [ -d "lib" ] && phase=11 && phases_completed+=(11)

    echo "Detected state:"
    echo "  Phase: ${phase}"
    echo "  Complexity: ${complexity}"
    echo "  Completed phases: ${phases_completed[*]}"

    # Create state file if it doesn't exist
    if [ ! -f "${WORKFLOW_STATE_FILE}" ]; then
        init_workflow_state > /dev/null
        jq --argjson phase "${phase}" \
           --arg complexity "${complexity}" \
           --argjson completed "[$(IFS=,; echo "${phases_completed[*]}")]" \
           '.current_phase = $phase |
            .complexity = $complexity |
            .phases_completed = $completed' \
           "${WORKFLOW_STATE_FILE}" > "${WORKFLOW_STATE_FILE}.tmp"
        mv "${WORKFLOW_STATE_FILE}.tmp" "${WORKFLOW_STATE_FILE}"
        update_resume_point
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# CLI
# ═══════════════════════════════════════════════════════════════════════════════

case "${1:-}" in
    init)
        init_workflow_state
        ;;
    session-start)
        log_session_start
        ;;
    session-end)
        log_session_end
        ;;
    session-interrupt)
        log_session_interrupt "${2:-User stopped process}"
        ;;
    phase-start)
        log_phase_start "$2" "$3" "${4:-}"
        update_phase_progress "$2" "start" "${4:-}"
        ;;
    phase-complete)
        log_phase_complete "$2" "${3:-N/A}" "${4:-}"
        update_phase_progress "$2" "complete" "${4:-}" "${3:-N/A}"
        ;;
    phase-fail)
        log_phase_fail "$2" "${3:-Unknown error}" "${4:-}"
        update_phase_progress "$2" "fail" "${4:-}"
        ;;
    feature-start)
        log_feature_start "$2" "$3"
        update_feature_progress "$2" "start"
        ;;
    feature-complete)
        log_feature_complete "$2"
        update_feature_progress "$2" "complete"
        ;;
    task-start)
        log_task_start "$2" "$3"
        ;;
    task-complete)
        log_task_complete "$2"
        ;;
    complexity-detected)
        log_complexity_detected "$2" "$3"
        ;;
    validation)
        log_validation "$2" "$3" "$4"
        ;;
    skill-loaded)
        log_skill_loaded "$2"
        ;;
    agent-invoked)
        log_agent_invoked "$2"
        ;;
    resume-report)
        generate_resume_report
        ;;
    detect)
        detect_current_state
        ;;
    *)
        echo "Usage: workflow-logger.sh <command> [args...]"
        echo ""
        echo "Commands:"
        echo "  init                                  - Initialize workflow state"
        echo "  session-start                         - Log session start"
        echo "  session-end                           - Log session end"
        echo "  session-interrupt [reason]            - Log session interruption"
        echo "  phase-start <phase> <name> [feature]  - Log and update phase start"
        echo "  phase-complete <phase> [grade] [feat] - Log and update phase completion"
        echo "  phase-fail <phase> [reason] [feature] - Log phase failure"
        echo "  feature-start <id> <name>             - Log and update feature start"
        echo "  feature-complete <id>                 - Log and update feature completion"
        echo "  task-start <id> <name>                - Log task start"
        echo "  task-complete <id>                    - Log task completion"
        echo "  complexity-detected <type> <features> - Log complexity detection"
        echo "  validation <phase> <grade> <status>   - Log validation result"
        echo "  skill-loaded <name>                   - Log skill loading"
        echo "  agent-invoked <name>                  - Log agent invocation"
        echo "  resume-report                         - Generate resume report"
        echo "  detect                                - Detect state from artifacts"
        exit 1
        ;;
esac
