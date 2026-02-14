---
name: rails-n-plus-one
description: Scan for N+1 query problems and suggest eager loading fixes
disable-model-invocation: false
allowed-tools: Read, Grep, Glob, Edit
---

Scan `$ARGUMENTS` for N+1 query patterns.

Steps:
1. Read the target file(s) — models, controllers, serializers, views, and service objects
2. Trace the data flow: identify which models are loaded and how associations are accessed
3. Flag N+1 patterns:
   - Iterating over a collection and accessing an association inside the loop
   - Serializers/jbuilder templates accessing associations without prior eager loading
   - Nested `each` blocks across associations
   - `map`, `select`, `any?`, `pluck` on unloaded associations
   - Innocent-looking instance methods that access associations without eager loading or execute raw SQL queries
4. For each issue found, suggest the fix:
   - `includes` for preloading (when filtering in Ruby)
   - `preload` for separate queries
   - `eager_load` for LEFT OUTER JOIN when filtering in SQL
   - `strict_loading` annotations to prevent future regressions
   - Instance methods memoization or refactoring to avoid repeated association access
5. Show before/after code snippets
