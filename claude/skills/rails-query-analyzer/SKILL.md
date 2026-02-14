---
name: rails-query-analyzer
description: Review ActiveRecord queries for performance and suggest optimizations
disable-model-invocation: false
allowed-tools: Read, Grep, Glob, Edit, Bash
---

Analyze ActiveRecord queries in `$ARGUMENTS` for performance issues.

Steps:
1. Read the target file and identify all ActiveRecord query chains
2. Read `db/schema.rb` to check existing indexes and table structure
3. Flag issues:
   - Queries on unindexed columns used in `where`, `order`, `group`, `having`
   - `SELECT *` when only specific columns are needed (suggest `.select` or `.pluck`)
   - `.count` in loops (suggest `counter_cache` or `GROUP BY`)
   - `.all` without pagination on large tables
   - String interpolation in queries (SQL injection risk — suggest parameterized queries)
   - Unnecessary `ORDER BY` on existence checks
4. Suggest missing indexes with migration code
5. Suggest query rewrites with before/after examples
