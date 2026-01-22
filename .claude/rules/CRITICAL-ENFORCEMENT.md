# CRITICAL ENFORCEMENT RULES

> **These rules OVERRIDE all other instructions. Violation = Immediate stop.**

---

## 1. DIRECTORY CREATION (ABSOLUTELY FORBIDDEN)

### FORBIDDEN DIRECTORIES - NEVER CREATE THESE

```
╔════════════════════════════════════════════════════════════════════════════╗
║                        FORBIDDEN DIRECTORIES                                ║
╠════════════════════════════════════════════════════════════════════════════╣
║                                                                            ║
║  ✗ NEVER create: skill-lab/                                               ║
║  ✗ NEVER create: workspace/                                               ║
║  ✗ NEVER create: temp/                                                    ║
║  ✗ NEVER create: output/                                                  ║
║  ✗ NEVER create: test-*/                                                  ║
║  ✗ NEVER create: .claude/.claude/ (nested)                                ║
║  ✗ NEVER create: .specify/.specify/ (nested)                              ║
║  ✗ NEVER create: any directory outside project root                       ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
```

### ALLOWED DIRECTORIES - ONLY CREATE THESE

```
ALLOWED:
├── .claude/              # ONLY if doesn't exist
│   ├── skills/           # ONLY if doesn't exist
│   ├── agents/           # ONLY if doesn't exist
│   ├── commands/         # ONLY if doesn't exist
│   ├── rules/            # ONLY if doesn't exist
│   ├── logs/             # ONLY if doesn't exist
│   └── scripts/          # ONLY if doesn't exist
│
├── .specify/             # ONLY if doesn't exist
│   ├── templates/        # ONLY if doesn't exist
│   ├── validations/      # ONLY if doesn't exist
│   └── features/         # ONLY if doesn't exist (for COMPLEX projects)
│
└── src/                  # Project source code
    lib/                  # Project library code
    (standard project dirs)
```

### BEFORE CREATING ANY DIRECTORY

```bash
# CHECK 1: Is this directory allowed?
ALLOWED_DIRS=(".claude" ".specify" "src" "lib" "tests" "docs")
IS_ALLOWED=false

for allowed in "${ALLOWED_DIRS[@]}"; do
    if [[ "$NEW_DIR" == "$allowed"* ]]; then
        IS_ALLOWED=true
        break
    fi
done

if [ "$IS_ALLOWED" = "false" ]; then
    echo "ERROR: Cannot create $NEW_DIR - not in allowed list"
    exit 1
fi

# CHECK 2: Does it already exist?
if [ -d "$NEW_DIR" ]; then
    echo "SKIP: $NEW_DIR already exists"
    exit 0
fi

# CHECK 3: Is it nested (contains .claude in path twice)?
if [[ "$NEW_DIR" =~ \.claude/.*\.claude ]]; then
    echo "ERROR: Cannot create nested .claude directory"
    exit 1
fi

# ONLY THEN create
mkdir -p "$NEW_DIR"
```

---

## 2. SKILL CREATION (STRICT LIMITS)

### WHEN TO CREATE NEW SKILL

```
CREATE NEW SKILL ONLY IF:
  1. No existing skill covers this (check ALL existing skills first)
  2. Problem required >30 minutes investigation
  3. Solution is non-obvious and reusable
  4. Technology is NEW to the project

DO NOT CREATE SKILL IF:
  1. Existing skill can be UPDATED instead
  2. Problem is documented in official docs
  3. Solution is obvious or trivial
  4. You've already created 3+ skills this session
```

### BEFORE CREATING SKILL - MANDATORY CHECKS

```python
def can_create_new_skill(proposed_skill_name: str) -> bool:
    """
    Check if new skill creation is allowed.
    Returns False if should update existing or skip creation.
    """

    # 1. Check existing skills
    existing_skills = list(Path('.claude/skills').glob('*/SKILL.md'))

    for skill_file in existing_skills:
        skill_content = skill_file.read_text()

        # If skill name is similar, UPDATE instead of creating new
        if similar(proposed_skill_name, skill_file.parent.name):
            print(f"STOP: Similar skill exists: {skill_file.parent.name}")
            print(f"ACTION: Update existing skill instead")
            return False

        # If skill description overlaps, UPDATE instead
        if description_overlap(proposed_skill_name, skill_content) > 0.7:
            print(f"STOP: Skill with similar purpose exists")
            print(f"ACTION: Update existing skill to include new info")
            return False

    # 2. Check session skill count (max 3 per session)
    session_skills_created = count_skills_created_this_session()
    if session_skills_created >= 3:
        print(f"STOP: Already created {session_skills_created} skills this session")
        print(f"ACTION: Consolidate or optimize existing skills instead")
        return False

    # 3. Check total skill count (max 15 skills per project)
    if len(existing_skills) >= 15:
        print(f"STOP: Project already has {len(existing_skills)} skills")
        print(f"ACTION: Too many skills. Consolidate similar ones.")
        return False

    return True
```

### SKILL CONSOLIDATION TRIGGERS

If project has >10 skills, consolidate before creating new ones:

```
CONSOLIDATION RULES:
  1. Merge similar skills (e.g., "react-hooks" + "react-patterns" → "react-best-practices")
  2. Remove outdated skills (mark as deprecated, archive)
  3. Combine small skills into comprehensive skill
  4. Update general skill instead of creating specific variant
```

---

## 3. SKILL USAGE ENFORCEMENT (CRITICAL)

### MANDATORY SKILL CHECK BEFORE CODING

```
BEFORE writing ANY code:
  1. READ existing skills in .claude/skills/
  2. IDENTIFY which skills apply to current task
  3. LOAD those skills via Skill() tool OR Read tool
  4. APPLY patterns from loaded skills
  5. ONLY THEN write code
```

### SKILL INVOCATION PROTOCOL

```python
def write_code_with_skills(task: str):
    """
    MANDATORY protocol for writing code.
    NEVER skip these steps.
    """

    # STEP 1: Identify relevant skills
    relevant_skills = identify_skills_for_task(task)

    if len(relevant_skills) == 0:
        print("WARNING: No skills found for this task")
        print("ACTION: Proceeding without skill guidance")
    else:
        print(f"Found {len(relevant_skills)} relevant skills:")
        for skill in relevant_skills:
            print(f"  - {skill}")

    # STEP 2: Load each skill
    for skill in relevant_skills:
        skill_path = f".claude/skills/{skill}/SKILL.md"

        # Try Skill() tool first (if skill is registered)
        try:
            Skill(skill)
            print(f"✓ Loaded via Skill() tool: {skill}")
        except:
            # Fallback: Read file directly
            skill_content = Read(skill_path)
            print(f"✓ Loaded via Read: {skill}")

    # STEP 3: Apply skill patterns
    # ... write code following loaded skill guidance ...

    # STEP 4: Log skill usage
    log_skill_usage(relevant_skills)
```

### SKILL IDENTIFICATION BY TASK TYPE

```python
def identify_skills_for_task(task: str) -> list:
    """Map task to relevant skills."""

    task_skill_mapping = {
        # Coding
        'write code': ['coding-standards'],
        'implement': ['coding-standards'],
        'create function': ['coding-standards'],

        # Testing
        'write test': ['testing-patterns'],
        'add tests': ['testing-patterns'],

        # APIs
        'create api': ['api-patterns'],
        'add endpoint': ['api-patterns'],

        # Database
        'database': ['database-patterns'],
        'schema': ['database-patterns'],

        # Workflow
        'generate skill': ['skill-gap-analyzer', 'component-quality-validator'],
        'validate': ['workflow-validator'],
        'quality gate': ['workflow-validator'],
    }

    skills = []
    task_lower = task.lower()

    for trigger, skill_list in task_skill_mapping.items():
        if trigger in task_lower:
            skills.extend(skill_list)

    return list(set(skills))  # Remove duplicates
```

---

## 4. sp.autonomous ENFORCEMENT

### SKILL LOADING IN AUTONOMOUS MODE

```
PHASE 11 (IMPLEMENT) - MANDATORY SKILL USAGE:

  BEFORE implementing ANY feature:
    1. Read .specify/requirements-analysis.json
    2. Get technologies_required
    3. For EACH technology:
         skill_name = f"{technology}-patterns"
         IF skill exists in .claude/skills/{skill_name}/:
             Load skill content
             Apply patterns from skill
         ELSE:
             Use generic coding-standards skill

  EXAMPLE:
    technologies_required: ["react", "express", "postgresql"]

    → Load react-patterns skill
    → Load express-patterns skill
    → Load postgresql-patterns skill
    → Apply all patterns when implementing
```

### SKILL vs MANUAL CODING DECISION

```python
def should_use_skill_or_code_manually(task: str) -> str:
    """
    Determine if should use skill or code manually.
    ALWAYS prefer using existing skills.
    """

    # Check if skill exists for this task
    relevant_skills = identify_skills_for_task(task)

    if len(relevant_skills) > 0:
        return "USE_SKILL"  # ALWAYS use skill if one exists

    # Check if task is complex enough to need skill
    if is_complex_task(task):
        # Create skill first, then use it
        return "CREATE_SKILL_THEN_USE"

    # Only code manually for trivial tasks with no existing skill
    return "CODE_MANUALLY"


def is_complex_task(task: str) -> bool:
    """Check if task is complex enough to warrant skill."""

    complexity_indicators = [
        'multiple files',
        'integration',
        'authentication',
        'security',
        'database schema',
        'api design',
        'testing strategy',
    ]

    task_lower = task.lower()
    return any(indicator in task_lower for indicator in complexity_indicators)
```

---

## 5. OPTIMIZATION OVER CREATION

### BEFORE CREATING ANYTHING NEW

```
OPTIMIZATION CHECKLIST:

  ✓ Can existing skill be UPDATED instead of creating new one?
  ✓ Can existing code be REFACTORED instead of writing new code?
  ✓ Can existing agent be ENHANCED instead of creating new agent?
  ✓ Can existing workflow be IMPROVED instead of adding new phase?

  ONLY create new if ALL answers are NO.
```

### SKILL OPTIMIZATION PROTOCOL

```python
def optimize_before_create():
    """
    Run optimization pass before creating anything new.
    """

    # 1. Consolidate similar skills
    skills = list(Path('.claude/skills').glob('*/SKILL.md'))
    similar_pairs = find_similar_skills(skills)

    for skill_a, skill_b in similar_pairs:
        print(f"Consider merging: {skill_a} + {skill_b}")
        # Merge logic here

    # 2. Remove outdated skills
    for skill in skills:
        if is_outdated(skill):
            print(f"Mark deprecated: {skill}")
            # Deprecation logic here

    # 3. Update existing skills with new patterns
    for skill in skills:
        new_patterns = find_new_patterns_for_skill(skill)
        if new_patterns:
            print(f"Update {skill} with {len(new_patterns)} new patterns")
            # Update logic here
```

---

## 6. ENFORCEMENT HOOKS

### Pre-Tool-Use Enforcement

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "tool == 'Bash' && tool_input.command matches 'mkdir'",
        "hooks": [{
          "type": "command",
          "command": "#!/bin/bash\nDIR=$(echo \"$CLAUDE_TOOL_INPUT\" | grep -oP 'mkdir\\s+\\K[^\\s]+')\nFORBIDDEN=('skill-lab' 'workspace' 'temp' 'output')\nfor forbidden in \"${FORBIDDEN[@]}\"; do\n  if [[ \"$DIR\" == *\"$forbidden\"* ]]; then\n    echo \"ERROR: Cannot create forbidden directory: $DIR\"\n    exit 1\n  fi\ndone"
        }],
        "description": "Block creation of forbidden directories"
      },
      {
        "matcher": "tool == 'Write' && tool_input.file_path matches 'SKILL.md'",
        "hooks": [{
          "type": "command",
          "command": "#!/bin/bash\nSKILL_COUNT=$(find .claude/skills -name 'SKILL.md' 2>/dev/null | wc -l)\nif [ \"$SKILL_COUNT\" -gt 15 ]; then\n  echo \"WARNING: Project has $SKILL_COUNT skills. Consider consolidation.\"\nfi"
        }],
        "description": "Warn when creating skills if count > 15"
      }
    ]
  }
}
```

---

## 7. VIOLATION CONSEQUENCES

### WHEN RULES ARE VIOLATED

```
VIOLATION → IMMEDIATE STOP → FIX → RESUME

Example:
  Agent creates skill-lab/ directory
    → STOP immediately
    → DELETE skill-lab/
    → WARN user about violation
    → RESUME from before violation
```

### RESET PROTOCOL

```bash
#!/bin/bash
# detect-and-fix-violations.sh

echo "Checking for violations..."

# Check for forbidden directories
FORBIDDEN_DIRS=("skill-lab" "workspace" "temp" "output")
VIOLATIONS=()

for dir in "${FORBIDDEN_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        echo "VIOLATION: Forbidden directory detected: $dir"
        VIOLATIONS+=("$dir")
    fi
done

# Fix violations
if [ ${#VIOLATIONS[@]} -gt 0 ]; then
    echo ""
    echo "Fixing violations..."

    for dir in "${VIOLATIONS[@]}"; do
        echo "  Removing: $dir"
        rm -rf "$dir"
    done

    echo ""
    echo "✓ Violations fixed"
    echo "⚠️  Reminder: Only create directories in allowed list"
fi

# Check for too many skills
SKILL_COUNT=$(find .claude/skills -name 'SKILL.md' 2>/dev/null | wc -l)
if [ "$SKILL_COUNT" -gt 15 ]; then
    echo ""
    echo "WARNING: Too many skills ($SKILL_COUNT)"
    echo "ACTION: Run skill consolidation"
fi
```

---

## 8. PROFESSIONAL STRUCTURE ENFORCEMENT

### DIRECTORY STRUCTURE VALIDATION

```bash
#!/bin/bash
# validate-structure.sh

echo "Validating project structure..."

# Expected structure
EXPECTED=(
    ".claude"
    ".claude/skills"
    ".claude/agents"
    ".claude/commands"
    ".claude/rules"
    ".claude/logs"
    ".claude/scripts"
    ".specify"
    ".specify/templates"
    ".specify/validations"
)

# Check for unexpected directories at root
UNEXPECTED=$(find . -maxdepth 1 -type d -not -name "." -not -name ".git" -not -name ".claude" -not -name ".specify" -not -name "node_modules" -not -name "src" -not -name "lib" -not -name "dist" -not -name "build" -not -name "tests" -not -name "docs" | wc -l)

if [ "$UNEXPECTED" -gt 0 ]; then
    echo "WARNING: Unexpected directories found:"
    find . -maxdepth 1 -type d -not -name "." -not -name ".git" -not -name ".claude" -not -name ".specify" -not -name "node_modules" -not -name "src" -not -name "lib" -not -name "dist" -not -name "build" -not -name "tests" -not -name "docs"
fi

echo "✓ Structure validation complete"
```

---

## SUMMARY

### THE RULES (Non-Negotiable)

1. **Directory Creation**: ONLY `.claude/`, `.specify/`, and standard project dirs
2. **Skill Creation**: Max 3 per session, max 15 per project, consolidate first
3. **Skill Usage**: ALWAYS load and apply existing skills before coding
4. **Optimization**: Update existing > Create new
5. **No Bypass**: Use skills/agents/hooks - don't code manually if skill exists

### ENFORCEMENT

- PreToolUse hooks block forbidden actions
- Validation scripts detect violations
- Automatic cleanup of violations
- Phase reset if component bypass detected

### REMEMBER

**Professional projects have:**
- Clean directory structure
- Consolidated, optimized skills
- Reusable patterns consistently applied
- No redundant files or directories

**Amateur projects have:**
- Random directories everywhere
- Too many overlapping skills
- Inconsistent code without patterns
- Technical debt accumulation
