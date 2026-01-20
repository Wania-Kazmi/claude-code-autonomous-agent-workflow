#!/usr/bin/env python3
"""
Test Dynamic Skill Activation System
Validates that the skill enforcement hooks work with dynamically generated skills
"""

import json
import os
import subprocess
import sys
from pathlib import Path

def print_header(title):
    print("=" * 60)
    print(f"       {title}")
    print("=" * 60)
    print()

def check_pass(msg):
    print(f"  ✓ {msg}")
    return True

def check_fail(msg):
    print(f"  ✗ {msg}")
    return False

def main():
    script_dir = Path(__file__).parent
    claude_dir = script_dir.parent
    project_dir = claude_dir.parent

    print_header("DYNAMIC SKILL ACTIVATION SYSTEM TEST")

    all_passed = True

    # Test 1: Check skill-rules.json has technology patterns (not hardcoded skills)
    print("[TEST 1] Checking skill-rules.json structure...")
    rules_file = claude_dir / "skill-rules.json"
    if rules_file.exists():
        with open(rules_file) as f:
            rules = json.load(f)

        if "technologyPatterns" in rules:
            pattern_count = len(rules.get("technologyPatterns", {}))
            check_pass(f"skill-rules.json has {pattern_count} technology patterns")
        else:
            all_passed = check_fail("Missing technologyPatterns - still using old format?")

        if "skills" in rules:
            all_passed = check_fail("Found 'skills' key - should use technologyPatterns instead")
        else:
            check_pass("No hardcoded skill names (correct)")
    else:
        all_passed = check_fail("skill-rules.json NOT FOUND")

    # Test 2: Check hook scripts exist
    print()
    print("[TEST 2] Checking hook scripts...")
    activator = claude_dir / "hooks" / "skill-activator.sh"
    stop_hook = claude_dir / "hooks" / "skill-enforcement-stop.sh"

    if activator.exists():
        # Check if it scans skills directory dynamically
        content = activator.read_text()
        if "discover_skills" in content or "SKILLS_DIR" in content:
            check_pass("skill-activator.sh uses dynamic skill discovery")
        else:
            all_passed = check_fail("skill-activator.sh may not be dynamic")
    else:
        all_passed = check_fail("skill-activator.sh missing")

    if stop_hook.exists():
        content = stop_hook.read_text()
        if "SKILLS_DIR" in content and "find" in content:
            check_pass("skill-enforcement-stop.sh uses dynamic skill discovery")
        else:
            all_passed = check_fail("skill-enforcement-stop.sh may not be dynamic")
    else:
        all_passed = check_fail("skill-enforcement-stop.sh missing")

    # Test 3: Check settings.json has hooks configured
    print()
    print("[TEST 3] Checking settings.json hooks...")
    settings_file = claude_dir / "settings.json"
    if settings_file.exists():
        with open(settings_file) as f:
            settings = json.load(f)

        hooks = settings.get("hooks", {})
        if "UserPromptSubmit" in hooks:
            check_pass("UserPromptSubmit hook configured")
        else:
            all_passed = check_fail("UserPromptSubmit hook NOT configured")

        if "Stop" in hooks:
            check_pass("Stop hook configured")
        else:
            all_passed = check_fail("Stop hook NOT configured")
    else:
        all_passed = check_fail("settings.json NOT FOUND")

    # Test 4: Test technology pattern matching
    print()
    print("[TEST 4] Testing technology pattern matching...")
    if rules_file.exists():
        patterns = rules.get("technologyPatterns", {})

        # Check for key patterns
        if "python-api" in patterns:
            keywords = patterns["python-api"].get("keywords", [])
            if "fastapi" in keywords:
                check_pass("'fastapi' keyword in python-api pattern")
            else:
                all_passed = check_fail("'fastapi' keyword missing from python-api")
        else:
            all_passed = check_fail("python-api pattern not found")

        if "testing" in patterns:
            keywords = patterns["testing"].get("keywords", [])
            if "test" in keywords or "pytest" in keywords:
                check_pass("Test-related keywords defined")
            else:
                all_passed = check_fail("Test keywords missing")
        else:
            all_passed = check_fail("testing pattern not found")

        if "project-init" in patterns:
            keywords = patterns["project-init"].get("keywords", [])
            if "requirements" in [k.lower() for k in keywords] or "requirements file" in keywords:
                check_pass("'requirements' keyword in project-init pattern")
            else:
                all_passed = check_fail("'requirements' keyword missing")
        else:
            all_passed = check_fail("project-init pattern not found")

    # Test 5: Check enforcement rules
    print()
    print("[TEST 5] Checking enforcement rules...")
    if rules_file.exists():
        enforcement = rules.get("enforcementRules", {})
        mandatory = enforcement.get("mandatory", {}).get("categories", [])
        suggested = enforcement.get("suggested", {}).get("categories", [])

        if mandatory:
            check_pass(f"Mandatory categories: {', '.join(mandatory)}")
        else:
            all_passed = check_fail("No mandatory categories defined")

        if suggested:
            check_pass(f"Suggested categories: {', '.join(suggested)}")

    # Test 6: Check CLAUDE.md has enforcement section
    print()
    print("[TEST 6] Checking CLAUDE.md enforcement...")
    claude_md = project_dir / "CLAUDE.md"
    if claude_md.exists():
        content = claude_md.read_text()
        if "MANDATORY SKILL ACTIVATION PROTOCOL" in content:
            check_pass("CLAUDE.md has mandatory skill activation section")
        else:
            all_passed = check_fail("CLAUDE.md missing enforcement section")

        if "STEP 1: EVALUATE" in content and "STEP 2: ACTIVATE" in content:
            check_pass("CLAUDE.md has commitment contract steps")
        else:
            all_passed = check_fail("CLAUDE.md missing commitment contract")
    else:
        all_passed = check_fail("CLAUDE.md NOT FOUND")

    # Test 7: Check skills directory structure
    print()
    print("[TEST 7] Checking skills directory...")
    skills_dir = claude_dir / "skills"
    if skills_dir.exists():
        skill_count = len(list(skills_dir.glob("*/SKILL.md")))
        check_pass(f"Skills directory exists with {skill_count} skill(s)")

        # List actual skills
        if skill_count > 0:
            skills = [d.name for d in skills_dir.iterdir() if d.is_dir() and (d / "SKILL.md").exists()]
            print(f"      Current skills: {', '.join(skills)}")
    else:
        check_pass("Skills directory not yet created (will be generated from requirements)")

    # Test 8: Test hook execution (dry run)
    print()
    print("[TEST 8] Testing hook execution...")
    try:
        # Test skill-activator with a sample prompt
        result = subprocess.run(
            ["bash", str(activator)],
            input='{"prompt": "create a fastapi endpoint"}',
            capture_output=True,
            text=True,
            timeout=10
        )
        if "MANDATORY SKILL ACTIVATION PROTOCOL" in result.stdout:
            check_pass("skill-activator.sh executes and outputs protocol")
        else:
            all_passed = check_fail("skill-activator.sh output unexpected")

        if "python-api" in result.stdout.lower() or "fastapi" in result.stdout.lower():
            check_pass("Technology pattern detection working")
    except Exception as e:
        all_passed = check_fail(f"Hook execution failed: {e}")

    # Summary
    print()
    if all_passed:
        print_header("ALL TESTS PASSED")
        print("Dynamic Skill Enforcement System is properly configured:")
        print()
        print("  • Technology patterns define triggers (not hardcoded skill names)")
        print("  • Hooks dynamically scan .claude/skills/ at runtime")
        print("  • Works with ANY skills generated from requirements")
        print("  • UserPromptSubmit: Injects forced-eval template")
        print("  • Stop: Blocks completion if skills missed")
        print()
        print("Flow:")
        print("  1. User provides requirements file")
        print("  2. Agent generates skills based on requirements")
        print("  3. Hooks automatically discover generated skills")
        print("  4. Prompts matched against technology patterns")
        print("  5. Available skills shown in forced-eval template")
        print()
        return 0
    else:
        print_header("SOME TESTS FAILED")
        print("Please fix the issues above before using the system.")
        return 1

if __name__ == "__main__":
    sys.exit(main())
