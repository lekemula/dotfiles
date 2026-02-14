---
name: ruby-code-smeller
description: Detect code smells and suggest refactorings in Ruby/Rails code
disable-model-invocation: false
allowed-tools: Read, Grep, Glob
---

Analyze `$ARGUMENTS` for code smells and suggest targeted refactorings.

Detect these smells:

1. **Long Method** — methods over ~15 lines, suggest Extract Method
2. **Large Class** — classes with too many responsibilities, suggest Extract Class or module extraction
3. **Feature Envy** — method that uses another object's data more than its own, suggest Move Method
4. **Data Clump** — same group of parameters passed together repeatedly, suggest Parameter Object or Value Object
5. **Primitive Obsession** — raw strings/integers used where a Value Object would clarify intent (e.g., money, email, status)
6. **Shotgun Surgery** — a single change requires edits across many files, suggest consolidation
7. **Divergent Change** — one class changes for multiple unrelated reasons, suggest splitting
8. **Law of Demeter violations** — long chains like `user.account.subscription.plan.name`, suggest delegation or wrapping
9. **God Controller** — controller actions with business logic that belongs in models or domain objects
10. **Callback Hell** — excessive ActiveRecord callbacks that hide side effects, suggest explicit service calls or domain events
11. **Mystery Guest** — tests relying on implicit shared state or fixtures without clear setup
12. **Boolean Parameters** — `def process(skip_validation: false)` — suggest splitting into separate methods
13. **Obscure dependencies** — lots of class/module dependencies that aren't clear from the interface, suggest Dependency Injection or explicit parameters in constructors/methods
14. **Inconsistent Naming** — methods or variables that don't follow project conventions or aren't descriptive, suggest renaming
15. **Dead Code** — unused methods (especially private), classes, or variables, suggest removal
16. **Private method abuse** — private methods that are too complex or have side effects, suggest making them public or moving logic to a more appropriate class, especially when the share the same prefix.
17. **Hash abuse** — using Hashes to pass around data instead of proper objects, suggest creating classes or data/structs for clarity and type safety.

For each smell found, report:
- Location (file:line)
- Smell name
- Why it's a problem
- Suggested refactoring with a brief code sketch
