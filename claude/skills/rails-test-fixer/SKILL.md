---
name: rails-test-fixer
description: Diagnose and fix failing Rails tests
disable-model-invocation: false
allowed-tools: Read, Grep, Glob, Edit, Bash
---

Diagnose and fix failing tests. If an argument is provided, focus on `$ARGUMENTS`. Otherwise, run the full test suite.

Steps:
1. Run the failing test(s) and capture the output
2. Analyze each failure:
   - Read the test file and the implementation file
   - Identify root cause: stale fixtures/factories, missing setup, changed API, flaky ordering, database state leaks
3. Fix the issue in the most appropriate place:
   - If the test is wrong (outdated expectation), update the test
   - If the implementation has a bug, fix the implementation
   - If it's a setup issue, fix factories/fixtures/let blocks
4. Re-run the tests to confirm the fix
5. Report what was wrong and what was changed
