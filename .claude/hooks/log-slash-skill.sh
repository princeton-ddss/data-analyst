#!/usr/bin/env bash
# UserPromptSubmit hook: log user-typed skill invocations (/name args) to logs/skills.log,
# matching the format of the PostToolUse Skill hook. Built-in commands are skipped.
log="${SKILLS_LOG:-${CLAUDE_PROJECT_DIR:-.}/logs/skills.log}"

line=$(jq -r '.prompt // empty' | head -n 1)
case "$line" in /*) ;; *) exit 0 ;; esac

name="${line%% *}"
name="${name#/}"
args="${line#/"$name"}"
args="${args# }"
[ -z "$args" ] && args="no args"

# Only log skills: plugin skills (plugin:skill) or project/user skill directories
case "$name" in
  *:*) ;;
  *) [ -d "${CLAUDE_PROJECT_DIR:-.}/.claude/skills/$name" ] || [ -d "$HOME/.claude/skills/$name" ] || exit 0 ;;
esac

echo "$(date '+%Y-%m-%d %H:%M:%S') | $name | $args" >> "$log"
