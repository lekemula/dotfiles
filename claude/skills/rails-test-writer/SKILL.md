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
5. Be thorough in unit tests, covering all possible inputs and outputs, but avoid over-testing internal implementation details
    - Test private methods indirectly through public methods, unless they contain complex logic that warrants direct testing
6. Ensure to add integration tests for critical flows that span multiple models or controllers, especially for service objects and complex domain logic
    - Prefer immediate caller to the class/method, or highest level possible, to cover the full behavior without being too brittle to implementation changes
    - The higher the level of the test, the more important it is to focus on realistic scenarios and avoid mocking
5. Use factories (FactoryBot) if the project uses them, otherwise use fixtures
    - For large and complex `let` variables, consider using non-record factories for better readability and reusability (e.g., `build(:3rd_party_response)` instead of inline hashes)
6. Place the test file in the conventional mirror path (e.g., `app/models/user.rb` → `spec/models/user_spec.rb`)


### Guidelines

## Mocking

- Avoid mocking/stubbing unless necessary to isolate external dependencies or avoid side effects (e.g., external API calls, complex services)
- Prefer VCR whenever available
    - Use explicit cassette names that reflect the scenario being tested (e.g., `vcr.use_cassette('github_api_user_fetch')` instead of `vcr.use_cassette('github_api')`)
    - Ensure secrets are filtered out of cassettes and that recorded interactions are realistic and cover edge cases
