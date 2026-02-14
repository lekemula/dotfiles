---
name: rails-migration-review
description: Review a migration for safety and best practices
disable-model-invocation: false
allowed-tools: Read, Grep, Glob
---

Review the migration at `$ARGUMENTS` for production safety.

Check for:
1. **Lock safety**: Will this lock a large table? (adding columns, indexes, changing column types)
   - Suggest `algorithm: :concurrently` for index creation
   - Suggest `safety_assured` blocks if using strong_migrations gem
   - Flag `rename_column`, `change_column`, `remove_column` on high-traffic tables
2. **Reversibility**: Is `change` method used? Does it support automatic rollback? Suggest `up`/`down` when needed
3. **Data backfills**: Backfills should be in separate migrations or rake tasks, not mixed with schema changes
4. **Default values**: Adding a column with a default on a large table — suggest adding column first, then default
5. **NOT NULL constraints**: Adding NOT NULL on existing column — suggest a multi-step approach
6. **Foreign keys**: Missing foreign key constraints for `_id` columns
7. **Index coverage**: New columns used in queries should have indexes
8. Check if `strong_migrations` gem is present and whether the migration follows its rules
