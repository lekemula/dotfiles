---
name: rails-service-scaffold
description: Generate a service object for cross-boundary coordination only (DDD)
disable-model-invocation: false
allowed-tools: Read, Grep, Glob, Write
---

Generate a service object for: `$ARGUMENTS`.

IMPORTANT — Follow DDD principles:
- Services should ONLY be used for coordination across system boundaries (external APIs, multi-model orchestration, infrastructure concerns)
- Business logic belongs in models, value objects, or domain objects — NOT in services
- If the logic is about a single model's behavior, it should be a method on that model instead
- Services are thin glue: receive input, delegate to domain objects, return result

Steps:
1. First, evaluate whether a service is even the right pattern. If the logic belongs on a model, suggest that instead
2. Check existing service objects in `app/services/`, `commands/` or `interactor/` to detect the project's conventions
3. Match the detected convention exactly (inheritance, method signatures, return types)
4. If no existing services found, use the Facade pattern:
   - Initialize with dependencies
   - Multiple meaningful public methods that describe the operations (e.g., `create_order`, `cancel_order`) — NOT a single `call` method
   - Minimal orchestration logic — delegate domain rules to models
5. Generate the corresponding spec file matching test conventions
6. Place files in the conventional locations
