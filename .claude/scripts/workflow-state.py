#!/usr/bin/env python3
"""
Workflow State Manager
Handles workflow state persistence and session recovery for sp.autonomous
"""

import json
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional, Dict, List, Any

WORKFLOW_STATE_FILE = Path(".specify/workflow-state.json")
PROGRESS_LOG_FILE = Path(".specify/workflow-progress.log")

# ═══════════════════════════════════════════════════════════════════════════════
# STATE MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════════

def read_state() -> Dict[str, Any]:
    """Read workflow state from file."""
    if not WORKFLOW_STATE_FILE.exists():
        return init_state()

    with open(WORKFLOW_STATE_FILE) as f:
        return json.load(f)


def write_state(state: Dict[str, Any]):
    """Write workflow state to file."""
    state["last_updated"] = datetime.now().isoformat()
    WORKFLOW_STATE_FILE.parent.mkdir(parents=True, exist_ok=True)

    with open(WORKFLOW_STATE_FILE, "w") as f:
        json.dump(state, f, indent=2)


def init_state() -> Dict[str, Any]:
    """Initialize workflow state."""
    session_id = f"session-{datetime.now().strftime('%Y%m%d-%H%M%S')}"

    state = {
        "version": "2.0",
        "last_updated": datetime.now().isoformat(),
        "current_phase": 0,
        "project_type": "unknown",
        "session_id": session_id,
        "phases_completed": [],
        "phases_in_progress": [],
        "total_phases": 13,
        "complexity": "SIMPLE",
        "features": {
            "total": 0,
            "completed": [],
            "current": None,
            "pending": []
        },
        "artifacts": {
            "constitution": False,
            "spec": False,
            "plan": False,
            "tasks": False,
            "implementation_started": False,
            "tests_passing": False
        },
        "validation_status": {
            "last_validation_phase": None,
            "last_validation_grade": None,
            "validation_reports": []
        },
        "resume_capability": {
            "can_resume": False,
            "resume_point": None,
            "resume_instructions": None
        }
    }

    write_state(state)
    log_progress("SESSION_START", {"session_id": session_id})

    return state


# ═══════════════════════════════════════════════════════════════════════════════
# LOGGING
# ═══════════════════════════════════════════════════════════════════════════════

def log_progress(event: str, data: Dict[str, Any]):
    """Log progress event."""
    timestamp = datetime.now().isoformat()
    data_str = " ".join(f"{k}={v}" for k, v in data.items())
    log_entry = f"[{timestamp}] {event} {data_str}\n"

    PROGRESS_LOG_FILE.parent.mkdir(parents=True, exist_ok=True)

    with open(PROGRESS_LOG_FILE, "a") as f:
        f.write(log_entry)


# ═══════════════════════════════════════════════════════════════════════════════
# PHASE MANAGEMENT
# ═══════════════════════════════════════════════════════════════════════════════

def update_phase(phase: int, status: str, feature: Optional[str] = None, grade: Optional[str] = None):
    """Update phase progress."""
    state = read_state()

    if status == "start":
        state["current_phase"] = phase
        if phase not in state["phases_in_progress"]:
            state["phases_in_progress"].append(phase)

        data = {"phase": phase}
        if feature:
            data["feature"] = feature
        log_progress("PHASE_START", data)

    elif status == "complete":
        if phase not in state["phases_completed"]:
            state["phases_completed"].append(phase)
        if phase in state["phases_in_progress"]:
            state["phases_in_progress"].remove(phase)

        state["validation_status"]["last_validation_phase"] = phase
        state["validation_status"]["last_validation_grade"] = grade or "N/A"

        data = {"phase": phase, "grade": grade or "N/A"}
        if feature:
            data["feature"] = feature
        log_progress("PHASE_COMPLETE", data)

    elif status == "fail":
        data = {"phase": phase}
        if feature:
            data["feature"] = feature
        log_progress("PHASE_FAIL", data)

    update_resume_point(state)
    write_state(state)


def update_feature(feature_id: str, status: str):
    """Update feature progress."""
    state = read_state()

    if status == "start":
        state["features"]["current"] = feature_id
        log_progress("FEATURE_START", {"feature": feature_id})

    elif status == "complete":
        if feature_id not in state["features"]["completed"]:
            state["features"]["completed"].append(feature_id)
        if feature_id in state["features"]["pending"]:
            state["features"]["pending"].remove(feature_id)

        # Move to next feature
        next_feature = state["features"]["pending"][0] if state["features"]["pending"] else None
        state["features"]["current"] = next_feature

        log_progress("FEATURE_COMPLETE", {"feature": feature_id})

    update_resume_point(state)
    write_state(state)


def update_resume_point(state: Dict[str, Any]):
    """Update resume point based on current state."""
    phase = state["current_phase"]
    complexity = state["complexity"]
    current_feature = state["features"]["current"]

    phase_names = {
        1: "INIT",
        2: "ANALYZE_PROJECT",
        3: "ANALYZE_REQUIREMENTS",
        4: "GAP_ANALYSIS",
        5: "GENERATE_SKILLS",
        7: "CONSTITUTION",
        8: "SPEC",
        9: "PLAN",
        10: "TASKS",
        11: "IMPLEMENT",
        12: "QA",
        13: "DELIVER"
    }

    if complexity == "COMPLEX" and current_feature:
        resume_point = f"Phase {phase}: Feature {current_feature} - {phase_names.get(phase, 'UNKNOWN')}"
        instructions = f"Continue working on feature {current_feature} at phase {phase}"
    else:
        resume_point = f"Phase {phase}: {phase_names.get(phase, 'UNKNOWN')}"
        instructions = f"Resume from phase {phase}"

    state["resume_capability"] = {
        "can_resume": phase > 0,
        "resume_point": resume_point,
        "resume_instructions": instructions
    }


# ═══════════════════════════════════════════════════════════════════════════════
# RESUME & REPORTING
# ═══════════════════════════════════════════════════════════════════════════════

def generate_resume_report() -> str:
    """Generate resume report."""
    if not WORKFLOW_STATE_FILE.exists():
        return "No workflow state found."

    state = read_state()

    report = []
    report.append("╔════════════════════════════════════════════════════════════════════════════╗")
    report.append("║                    WORKFLOW RESUME REPORT                                   ║")
    report.append("╠════════════════════════════════════════════════════════════════════════════╣")
    report.append("")
    report.append(f"Project Type: {state['complexity']}")
    report.append(f"Current Phase: {state['current_phase']}")
    report.append(f"Phases Completed: {', '.join(map(str, state['phases_completed']))}")
    report.append("")

    if state["complexity"] == "COMPLEX":
        features = state["features"]
        report.append("Features:")
        report.append(f"  Total: {features['total']}")
        report.append(f"  Completed: {', '.join(features['completed']) or 'None'}")
        report.append(f"  Current: {features['current'] or 'None'}")
        report.append(f"  Pending: {', '.join(features['pending']) or 'None'}")
        report.append("")

    artifacts = state["artifacts"]
    report.append("Artifacts:")
    report.append(f"  ✓ Constitution: {'YES' if artifacts['constitution'] else 'NO'}")
    report.append(f"  ✓ Spec: {'YES' if artifacts['spec'] else 'NO'}")
    report.append(f"  ✓ Plan: {'YES' if artifacts['plan'] else 'NO'}")
    report.append(f"  ✓ Tasks: {'YES' if artifacts['tasks'] else 'NO'}")
    report.append(f"  ✓ Implementation: {'STARTED' if artifacts['implementation_started'] else 'NOT STARTED'}")
    report.append(f"  ✓ Tests Passing: {'YES' if artifacts['tests_passing'] else 'NO'}")
    report.append("")

    resume = state["resume_capability"]
    report.append("Resume Point:")
    report.append(f"  {resume['resume_point'] or 'N/A'}")
    report.append("")
    report.append("Instructions:")
    report.append(f"  {resume['resume_instructions'] or 'Start from Phase 0'}")
    report.append("")

    validation = state["validation_status"]
    report.append(f"Last Updated: {state['last_updated']}")
    report.append(f"Last Validation: Phase {validation['last_validation_phase'] or 'N/A'} - Grade {validation['last_validation_grade'] or 'N/A'}")
    report.append("")
    report.append("╚════════════════════════════════════════════════════════════════════════════╝")

    return "\n".join(report)


def detect_state_from_artifacts() -> Dict[str, Any]:
    """Detect workflow state from filesystem artifacts."""
    print("Detecting workflow state from artifacts...")

    state = init_state()
    phase = 0
    complexity = "SIMPLE"
    phases_completed = []

    # Check phase artifacts
    if Path(".specify").exists() and Path(".claude").exists():
        phase = 1
        phases_completed.append(1)

    if Path(".specify/project-analysis.json").exists():
        phase = 2
        phases_completed.append(2)

    if Path(".specify/requirements-analysis.json").exists():
        phase = 3
        phases_completed.append(3)

    if Path(".specify/gap-analysis.json").exists():
        phase = 4
        phases_completed.append(4)

    skill_count = len(list(Path(".claude/skills").glob("*/SKILL.md"))) if Path(".claude/skills").exists() else 0
    if skill_count > 5:
        phase = 5
        phases_completed.append(5)

    if Path(".specify/feature-breakdown.json").exists():
        complexity = "COMPLEX"

    if Path(".specify/constitution.md").exists():
        phase = 7
        phases_completed.append(7)
        state["artifacts"]["constitution"] = True

    if Path(".specify/spec.md").exists():
        phase = 8
        phases_completed.append(8)
        state["artifacts"]["spec"] = True

    if Path(".specify/plan.md").exists():
        phase = 9
        phases_completed.append(9)
        state["artifacts"]["plan"] = True

    if Path(".specify/tasks.md").exists():
        phase = 10
        phases_completed.append(10)
        state["artifacts"]["tasks"] = True

    if Path("src").exists() or Path("lib").exists():
        phase = 11
        phases_completed.append(11)
        state["artifacts"]["implementation_started"] = True

    state["current_phase"] = phase
    state["complexity"] = complexity
    state["phases_completed"] = phases_completed

    print(f"Detected state:")
    print(f"  Phase: {phase}")
    print(f"  Complexity: {complexity}")
    print(f"  Completed phases: {phases_completed}")

    update_resume_point(state)
    write_state(state)

    return state


# ═══════════════════════════════════════════════════════════════════════════════
# CLI
# ═══════════════════════════════════════════════════════════════════════════════

def main():
    if len(sys.argv) < 2:
        print("Usage: workflow-state.py <command> [args...]")
        print("")
        print("Commands:")
        print("  init                                  - Initialize workflow state")
        print("  phase-start <phase> [feature]         - Update phase start")
        print("  phase-complete <phase> [grade] [feat] - Update phase completion")
        print("  feature-start <id>                    - Update feature start")
        print("  feature-complete <id>                 - Update feature completion")
        print("  resume-report                         - Generate resume report")
        print("  detect                                - Detect state from artifacts")
        print("  get <key>                             - Get state value")
        sys.exit(1)

    command = sys.argv[1]

    if command == "init":
        state = init_state()
        print(state["session_id"])

    elif command == "phase-start":
        phase = int(sys.argv[2])
        feature = sys.argv[3] if len(sys.argv) > 3 else None
        update_phase(phase, "start", feature)

    elif command == "phase-complete":
        phase = int(sys.argv[2])
        grade = sys.argv[3] if len(sys.argv) > 3 else None
        feature = sys.argv[4] if len(sys.argv) > 4 else None
        update_phase(phase, "complete", feature, grade)

    elif command == "feature-start":
        feature_id = sys.argv[2]
        update_feature(feature_id, "start")

    elif command == "feature-complete":
        feature_id = sys.argv[2]
        update_feature(feature_id, "complete")

    elif command == "resume-report":
        print(generate_resume_report())

    elif command == "detect":
        detect_state_from_artifacts()

    elif command == "get":
        state = read_state()
        key = sys.argv[2]
        keys = key.split(".")

        value = state
        for k in keys:
            if isinstance(value, dict):
                value = value.get(k)
            else:
                value = None
                break

        print(json.dumps(value) if value is not None else "null")

    else:
        print(f"Unknown command: {command}")
        sys.exit(1)


if __name__ == "__main__":
    main()
