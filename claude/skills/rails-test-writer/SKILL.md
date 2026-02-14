---
name: rails-test-writer
description: Generate tests for a Rails class (RSpec or Minitest)
disable-model-invocation: false
allowed-tools: Read, Grep, Glob, Write
---

Generate comprehensive tests for the class at `$ARGUMENTS`.

Steps:
1. Read the target file to understand the class, its public interface, and dependencies
2. Detect the test framework by checking for `spec/` (RSpec) or `test/` (Minitest) directories and existing test files
3. Check existing tests in the project for style conventions (let vs instance variables, shared examples, factory usage, subject style)
4. Generate tests covering:
   - Happy path for each public method
   - Edge cases (nil, empty, boundary values)
   - Error/exception handling paths
   - Associations and validations (for models)
   - Authorization and param handling (for controllers)
5. Use factories (FactoryBot) if the project uses them, otherwise use fixtures
    - For large and complex `let` variables, consider using non-record factories for better readability and reusability (e.g., `build(:3rd_party_response)` instead of inline hashes)
6. Place the test file in the conventional mirror path (e.g., `app/models/user.rb` → `spec/models/user_spec.rb`)
