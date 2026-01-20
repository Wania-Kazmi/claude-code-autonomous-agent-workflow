#!/usr/bin/env python3
"""
Skill Coverage Checker

Analyzes skill-rules.json and available skills to report:
- Which skills are defined
- Which have trigger rules
- Coverage gaps
- Activation statistics from logs
"""

import json
import os
from pathlib import Path
from collections import defaultdict
from datetime import datetime

def load_skill_rules():
    """Load skill rules configuration."""
    rules_path = Path(__file__).parent.parent / "skill-rules.json"
    if not rules_path.exists():
        return None
    with open(rules_path) as f:
        return json.load(f)

def get_available_skills():
    """Scan .claude/skills/ for available skills."""
    skills_dir = Path(__file__).parent.parent / "skills"
    if not skills_dir.exists():
        return []

    skills = []
    for skill_dir in skills_dir.iterdir():
        if skill_dir.is_dir():
            skill_md = skill_dir / "SKILL.md"
            if skill_md.exists():
                skills.append(skill_dir.name)
    return skills

def parse_activation_logs():
    """Parse skill activation logs to get statistics."""
    logs_dir = Path(__file__).parent.parent / "logs"
    stats = defaultdict(int)

    # Check skill-activations.log
    activations_log = logs_dir / "skill-activations.log"
    if activations_log.exists():
        with open(activations_log) as f:
            for line in f:
                if "Matched:" in line:
                    # Extract matched skills
                    matched = line.split("Matched:")[1].strip()
                    if matched and matched != "none detected - evaluate all":
                        for skill in matched.split():
                            stats[skill] += 1

    # Check skill-invocations.log
    invocations_log = logs_dir / "skill-invocations.log"
    if invocations_log.exists():
        with open(invocations_log) as f:
            for line in f:
                if "Skill invoked:" in line:
                    skill = line.split("Skill invoked:")[1].strip()
                    stats[f"{skill}_invoked"] += 1

    return dict(stats)

def generate_report():
    """Generate coverage report."""
    rules = load_skill_rules()
    available = get_available_skills()
    stats = parse_activation_logs()

    print("=" * 70)
    print("                    SKILL COVERAGE REPORT")
    print("=" * 70)
    print(f"\nGenerated: {datetime.now().isoformat()}\n")

    # Available skills
    print("AVAILABLE SKILLS")
    print("-" * 40)
    for skill in sorted(available):
        has_rules = skill in rules.get("skills", {}) if rules else False
        status = "✓ Has rules" if has_rules else "✗ No rules"
        print(f"  {skill}: {status}")

    if rules:
        # Skills with rules but no SKILL.md
        print("\n\nRULES WITHOUT SKILLS")
        print("-" * 40)
        rules_skills = set(rules.get("skills", {}).keys())
        available_set = set(available)
        missing = rules_skills - available_set
        if missing:
            for skill in sorted(missing):
                print(f"  {skill}: Has rules but no SKILL.md")
        else:
            print("  All rules have corresponding skills")

        # Enforcement summary
        print("\n\nENFORCEMENT LEVELS")
        print("-" * 40)
        for skill, config in rules.get("skills", {}).items():
            enforcement = config.get("enforcement", "unknown")
            priority = config.get("priority", "unknown")
            print(f"  {skill}: {enforcement} (priority: {priority})")

    # Activation statistics
    if stats:
        print("\n\nACTIVATION STATISTICS")
        print("-" * 40)
        for key, count in sorted(stats.items(), key=lambda x: -x[1]):
            print(f"  {key}: {count} times")
    else:
        print("\n\nNo activation logs found yet.")

    print("\n" + "=" * 70)

if __name__ == "__main__":
    generate_report()
