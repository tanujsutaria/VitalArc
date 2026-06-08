# Agent Instructions

The authoritative guide for working in this repo is **`CLAUDE.md`** (build commands, architecture, git workflow, session skills). Read it first. This file only adds the session-completion discipline that applies to every agent.

Issue/feature tracking lives in **`FEATURE_BACKLOG.md`** and the project's GitHub issues/PRs — there is no external issue-tracker CLI to run.

## Landing the Plane (Session Completion)

**When ending a work session**, you MUST complete ALL steps below. Work is NOT complete until `git push` succeeds.

**MANDATORY WORKFLOW:**

1. **Capture remaining work** - Add follow-ups to `FEATURE_BACKLOG.md` or open a GitHub issue.
2. **Run quality gates** (if code changed) - Tests, linters, builds (see `CLAUDE.md` → Build Commands; CI is the authoritative gate).
3. **Commit** - Conventional Commits format (see `CLAUDE.md` → Git Workflow).
4. **PUSH TO REMOTE** - This is MANDATORY:
   ```bash
   git pull --rebase
   git push
   git status  # MUST show "up to date with origin"
   ```
5. **Clean up** - Clear stashes, prune merged remote branches.
6. **Verify** - All changes committed AND pushed.
7. **Hand off** - Provide context for the next session (update `SESSION_LOG.md`).

**CRITICAL RULES:**
- Work is NOT complete until `git push` succeeds.
- NEVER stop before pushing - that leaves work stranded locally.
- NEVER say "ready to push when you are" - YOU must push.
- If push fails, resolve and retry until it succeeds.
