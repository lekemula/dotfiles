---
name: ruby-yard-documenter
description: Add YARD documentation to Ruby classes and methods
disable-model-invocation: false
allowed-tools: Read, Grep, Glob, Edit
---

Add YARD documentation to the file at `$ARGUMENTS`.

Rules:
1. Read the file and identify all undocumented public classes, modules, and methods
2. IMPORTANT: Use Solargraph LSP to inferm return types and exclude inferable private methods.
3. Check existing YARD docs in the project for style conventions (tone, tag usage, examples)
4. Add YARD tags:
   - `@param name [Type]` for each parameter
   - `@return [Type]` for return values
   - `@raise [ExceptionClass]` only when explicitly raised
   - `@yield` / `@yieldparam` for blocks
   - `@example` only for non-obvious usage
5. Keep descriptions concise — one line when possible, skip if the method/paramter name is self-explanatory
6. Do NOT add YARD docs to inferable private methods via LSP.
7. Do NOT document trivial private methods, trivial getters/setters, or framework callbacks (e.g., `before_action`)
8. Do NOT annotate self-inferring methods, when it simply returns an instance of a object/class or Hash with symbol keys.
9. Avoid adding description, unless the method's purpose is not clear from its name or signature. Focus on clarifying the "why" rather than the "what" when necessary.
10. Do NOT modify any code — only add doc comments
11. Try to reveal as much as ruby/rails magic via `@!method` and `@!attribute` as possible for dynamic methods
    - Verify with LSP `documentSymbol` before adding annotations — if the method already appears in the symbol list, skip the `@!method`.

## Guidelines

### Structs

Use the following annotation for ruby Data/Struct classes
   ```
   # @param bar [String]
   # @param baz [Integer]
   Foo = Struct.new(:bar, :baz)
   ```

### Generics

Document generic classes via `@generic` and `@param` tags:
   ```
   # @generic T
   class Box
     # @param items [Array<T>]
     def initialize(items)
       @items = items
     end

     # @return [Array<T>]
     def items
       @items
     end
   end
   ```
