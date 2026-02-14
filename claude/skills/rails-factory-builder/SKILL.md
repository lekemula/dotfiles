---
name: rails-factory-builder
description: Generate FactoryBot factories from models or schema
disable-model-invocation: false
allowed-tools: Read, Grep, Glob, Write
---

Generate a FactoryBot factory for `$ARGUMENTS`.

Steps:
1. Read the model file and `db/schema.rb` (or `db/schema.sql`) to understand columns, types, and constraints
2. Check existing factories in `spec/factories/` or `test/factories/` for style conventions
3. Generate a factory with the **minimal set of attributes** needed to make the model valid:
   - Only include attributes required by validations (`presence`, `uniqueness`, `format`, etc.) and NOT NULL constraints
   - Do NOT set optional columns — let them default to nil
   - Use Faker if the project uses it, otherwise use simple static values
   - Associations: only include those required for validity, using `association` or inline blocks matching project style
   - Sequences only for fields with uniqueness validations
   - Traits for additional states beyond the minimal valid factory (e.g., `:with_avatar`, `:admin`, `:inactive`)
4. Skip columns that are auto-managed (id, timestamps)
5. Place in the conventional factory directory
