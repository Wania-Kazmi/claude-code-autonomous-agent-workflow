#!/usr/bin/env python3
"""
Component Utilization Validation Script

Validates that custom skills, agents, and hooks are being utilized.
Works independently of hook logging (which is broken in Claude Code).

Usage:
    python3 validate-utilization.py [phase_number]
"""

import json
import os
import sys
from pathlib import Path
from datetime import datetime
from typing import Dict, List, Tuple, Optional

def is_safe_path(base_path: Path, target_path: Path) -> bool:
    """
    Verify target path is within the base path (prevent path traversal).

    Security: Protects against symlink attacks and path traversal attempts.
    """
    try:
        target_resolved = target_path.resolve()
        base_resolved = base_path.resolve()
        return target_resolved.is_relative_to(base_resolved)
    except (ValueError, RuntimeError, OSError):
        return False

def get_available_skills() -> List[str]:
    """Get list of available skills."""
    skills_dir = Path('.claude/skills')
    if not skills_dir.exists():
        return []

    return [
        d.name for d in skills_dir.iterdir()
        if d.is_dir() and not d.name.startswith('.')
    ]

def get_available_agents() -> List[str]:
    """Get list of available agents."""
    agents_dir = Path('.claude/agents')
    if not agents_dir.exists():
        return []

    return [
        f.stem for f in agents_dir.glob('*.md')
        if not f.name.startswith('.')
    ]

def analyze_transcript_for_skills(transcript_path: Path = None) -> List[str]:
    """
    Analyze conversation transcript for skill invocations.

    Since hook logging is broken, we analyze the transcript file directly.
    """
    skills_used = set()

    # Try to find the most recent transcript
    if transcript_path is None:
        claude_dir = Path.home() / '.claude' / 'projects'
        project_name = Path.cwd().name

        # Search for transcript files (with path traversal protection)
        transcript_files = list(claude_dir.rglob('*.jsonl'))
        if transcript_files:
            # Filter to only safe paths within .claude directory
            safe_files = [f for f in transcript_files if is_safe_path(claude_dir, f)]
            if safe_files:
                # Get most recent
                transcript_path = max(safe_files, key=lambda p: p.stat().st_mtime)

    if transcript_path and transcript_path.exists():
        try:
            with open(transcript_path, 'r') as f:
                for line in f:
                    try:
                        data = json.loads(line)
                        # Look for Skill tool usage in tool_uses
                        if 'message' in data and 'content' in data['message']:
                            for content_block in data['message']['content']:
                                if isinstance(content_block, dict):
                                    if content_block.get('type') == 'tool_use' and content_block.get('name') == 'Skill':
                                        skill_name = content_block.get('input', {}).get('skill')
                                        if skill_name:
                                            skills_used.add(skill_name)
                    except json.JSONDecodeError:
                        continue
        except Exception as e:
            print(f"Warning: Could not analyze transcript: {e}", file=sys.stderr)

    return list(skills_used)

def analyze_transcript_for_agents(transcript_path: Path = None) -> List[str]:
    """
    Analyze conversation transcript for agent (Task tool) invocations.
    """
    agents_used = set()

    if transcript_path is None:
        claude_dir = Path.home() / '.claude' / 'projects'
        transcript_files = list(claude_dir.rglob('*.jsonl'))
        if transcript_files:
            # Filter to only safe paths within .claude directory
            safe_files = [f for f in transcript_files if is_safe_path(claude_dir, f)]
            if safe_files:
                transcript_path = max(safe_files, key=lambda p: p.stat().st_mtime)

    if transcript_path and transcript_path.exists():
        try:
            with open(transcript_path, 'r') as f:
                for line in f:
                    try:
                        data = json.loads(line)
                        if 'message' in data and 'content' in data['message']:
                            for content_block in data['message']['content']:
                                if isinstance(content_block, dict):
                                    if content_block.get('type') == 'tool_use' and content_block.get('name') == 'Task':
                                        subagent_type = content_block.get('input', {}).get('subagent_type')
                                        if subagent_type:
                                            agents_used.add(subagent_type)
                    except json.JSONDecodeError:
                        continue
        except Exception as e:
            print(f"Warning: Could not analyze transcript for agents: {e}", file=sys.stderr)

    return list(agents_used)

def count_hooks() -> int:
    """Count configured hooks."""
    hooks_count = 0

    for hook_file in [Path('.claude/hooks.json'), Path('.claude/settings.json')]:
        if hook_file.exists():
            try:
                with open(hook_file) as f:
                    data = json.load(f)
                    if 'hooks' in data:
                        for hook_type in ['PreToolUse', 'PostToolUse', 'Stop', 'UserPromptSubmit']:
                            if hook_type in data['hooks']:
                                hooks_count += len(data['hooks'][hook_type])
            except (json.JSONDecodeError, IOError, OSError, KeyError) as e:
                print(f"Warning: Could not read {hook_file}: {e}", file=sys.stderr)

    return hooks_count

def get_required_technologies() -> List[str]:
    """Get required technologies from requirements analysis."""
    req_file = Path('.specify/requirements-analysis.json')
    if not req_file.exists():
        return []

    try:
        with open(req_file) as f:
            data = json.load(f)
            return data.get('technologies_required', [])
    except (json.JSONDecodeError, IOError, OSError, KeyError) as e:
        print(f"Warning: Could not read requirements file: {e}", file=sys.stderr)
        return []

def validate_component_utilization(phase: int = None) -> Dict:
    """
    Validate component utilization.

    Returns comprehensive utilization report.
    """
    # Gather data
    skills_available = get_available_skills()
    agents_available = get_available_agents()

    skills_used = analyze_transcript_for_skills()
    agents_used = analyze_transcript_for_agents()

    hooks_configured = count_hooks()
    technologies = get_required_technologies()

    # Calculate unused
    skills_unused = [s for s in skills_available if s not in skills_used]
    agents_unused = [a for a in agents_available if a not in agents_used]

    # Score calculation
    score = 0
    issues = []

    # Skill utilization (25%)
    if len(skills_available) > 0:
        skill_ratio = len(skills_used) / len(skills_available)
        if skill_ratio >= 0.5:
            score += 25
        elif skill_ratio >= 0.25:
            score += 15
            issues.append(f"Low skill utilization: {len(skills_used)}/{len(skills_available)} skills used")
        else:
            score += 5
            issues.append(f"CRITICAL: Only {len(skills_used)} skills used out of {len(skills_available)} available")
    else:
        score += 25

    # Technology matching (20%)
    if technologies:
        matched_techs = 0
        for tech in technologies:
            tech_patterns = [
                f"{tech}-patterns",
                f"{tech}-generator",
                tech.lower(),
                tech.replace('.', '').lower()
            ]
            if any(pattern in skill.lower() for skill in skills_used for pattern in tech_patterns):
                matched_techs += 1

        match_ratio = matched_techs / len(technologies) if technologies else 1.0
        if match_ratio >= 0.7:
            score += 20
        elif match_ratio >= 0.4:
            score += 12
            issues.append(f"Technology-skill mismatch: {matched_techs}/{len(technologies)} covered")
        else:
            score += 5
            issues.append("CRITICAL: Most technologies lack skill coverage")
    else:
        score += 20

    # Agent utilization (20%)
    if len(agents_available) > 0:
        expected_agents = ['code-reviewer', 'tdd-guide', 'build-error-resolver']
        expected_used = [a for a in expected_agents if a in agents_used]

        if len(expected_used) >= 2:
            score += 20
        elif len(expected_used) >= 1:
            score += 12
            issues.append(f"Limited agent usage: Only {expected_used} used")
        else:
            score += 5
            issues.append("CRITICAL: Core agents not used")
    else:
        score += 20

    # Hooks (15%)
    if hooks_configured >= 3:
        score += 15
    elif hooks_configured >= 1:
        score += 8
        issues.append(f"Limited hooks: Only {hooks_configured} configured")
    else:
        score += 0
        issues.append("No hooks configured")

    # Bypass detection (20%)
    bypass_detected = False
    if len(skills_available) > 3 and len(skills_used) == 0:
        bypass_detected = True
        issues.append("BYPASS: Skills exist but none used")

    if len(agents_available) > 5 and len(agents_used) == 0:
        bypass_detected = True
        issues.append("BYPASS: Agents exist but none used")

    if not bypass_detected:
        score += 20

    # Grade
    if score >= 90:
        grade = 'A'
    elif score >= 80:
        grade = 'B'
    elif score >= 70:
        grade = 'C'
    elif score >= 50:
        grade = 'D'
    else:
        grade = 'F'

    # Calculate utilization percentage
    total_components = len(skills_available) + len(agents_available)
    used_components = len(skills_used) + len(agents_used)
    utilization_pct = round((used_components / total_components * 100), 1) if total_components > 0 else 100

    return {
        'timestamp': datetime.now().isoformat(),
        'phase': phase,
        'score': score,
        'grade': grade,
        'utilization_percentage': utilization_pct,
        'skills': {
            'available': skills_available,
            'used': skills_used,
            'unused': skills_unused
        },
        'agents': {
            'available': agents_available,
            'used': agents_used,
            'unused': agents_unused
        },
        'hooks_configured': hooks_configured,
        'technologies_required': technologies,
        'issues': issues,
        'bypass_detected': bypass_detected
    }

def generate_report(result: Dict) -> str:
    """Generate markdown report from validation result."""
    report = f"""# Component Utilization Report

## Summary
| Metric | Value |
|--------|-------|
| Timestamp | {result['timestamp']} |
| Phase | {result.get('phase', 'N/A')} |
| Utilization Grade | **{result['grade']}** |
| Utilization Score | {result['score']}/100 |
| Overall Utilization | {result['utilization_percentage']}% |

## Skills Analysis
| Category | Count | Details |
|----------|-------|---------|
| Available | {len(result['skills']['available'])} | {', '.join(result['skills']['available']) or 'None'} |
| Used | {len(result['skills']['used'])} | {', '.join(result['skills']['used']) or 'None'} |
| Unused | {len(result['skills']['unused'])} | {', '.join(result['skills']['unused']) or 'None'} |

**Skill Coverage:** {len(result['skills']['used'])}/{len(result['skills']['available'])}

## Agents Analysis
| Category | Count | Details |
|----------|-------|---------|
| Available | {len(result['agents']['available'])} | {', '.join(result['agents']['available']) or 'None'} |
| Used | {len(result['agents']['used'])} | {', '.join(result['agents']['used']) or 'None'} |
| Unused | {len(result['agents']['unused'])} | {', '.join(result['agents']['unused']) or 'None'} |

**Agent Coverage:** {len(result['agents']['used'])}/{len(result['agents']['available'])}

## Hooks Configuration
**Hooks Configured:** {result['hooks_configured']}

## Issues Found
"""

    if result['issues']:
        for i, issue in enumerate(result['issues'], 1):
            report += f"{i}. {issue}\n"
    else:
        report += "No issues found.\n"

    report += f"""
## Bypass Detection
{'⚠️ **BYPASS DETECTED** - Components exist but are not being used!' if result['bypass_detected'] else '✅ No bypass detected'}

## Decision

"""

    if result['utilization_percentage'] >= 70:
        report += "✅ Component utilization is acceptable. Custom ecosystem is being leveraged.\n"
    elif result['utilization_percentage'] >= 50:
        report += "⚠️ Component utilization is low. Review which components should be used.\n"
    else:
        report += "❌ CRITICAL: Custom components are being bypassed.\n"

    return report

def parse_phase_arg() -> Optional[int]:
    """
    Parse and validate phase argument from command line.

    Security: Validates phase number is within reasonable bounds.

    Returns:
        Phase number (1-20) or None if not provided/invalid
    """
    if len(sys.argv) < 2:
        return None

    try:
        phase = int(sys.argv[1])
        if not 1 <= phase <= 20:  # Reasonable bounds for workflow phases
            print(f"Warning: Phase number should be between 1 and 20, got {phase}", file=sys.stderr)
            return None
        return phase
    except ValueError:
        print(f"Warning: Invalid phase number: {sys.argv[1]}", file=sys.stderr)
        return None

def main():
    """Main execution."""
    phase = parse_phase_arg()

    print("=" * 70)
    print("COMPONENT UTILIZATION VALIDATION")
    print("=" * 70)
    print()

    result = validate_component_utilization(phase)

    # Save JSON report (with secure file permissions)
    report_dir = Path('.specify/validations')
    os.makedirs(report_dir, mode=0o700, exist_ok=True)

    json_file = report_dir / 'component-utilization.json'
    # Create file with restrictive permissions (0600 = owner read/write only)
    with os.fdopen(os.open(str(json_file), os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600), 'w') as f:
        json.dump(result, f, indent=2)
    print(f"✓ JSON report saved to: {json_file}")

    # Generate and save markdown report (with secure file permissions)
    markdown_report = generate_report(result)
    md_file = report_dir / 'component-utilization-report.md'
    with os.fdopen(os.open(str(md_file), os.O_WRONLY | os.O_CREAT | os.O_TRUNC, 0o600), 'w') as f:
        f.write(markdown_report)
    print(f"✓ Markdown report saved to: {md_file}")

    # Print summary
    print()
    print("=" * 70)
    print("SUMMARY")
    print("=" * 70)
    print(f"Grade: {result['grade']}")
    print(f"Score: {result['score']}/100")
    print(f"Utilization: {result['utilization_percentage']}%")
    print(f"Skills Used: {len(result['skills']['used'])}/{len(result['skills']['available'])}")
    print(f"Agents Used: {len(result['agents']['used'])}/{len(result['agents']['available'])}")
    print()

    if result['issues']:
        print("Issues:")
        for issue in result['issues']:
            print(f"  - {issue}")

    # Exit code based on grade
    if result['grade'] in ['A', 'B', 'C']:
        sys.exit(0)
    else:
        sys.exit(1)

if __name__ == '__main__':
    main()
