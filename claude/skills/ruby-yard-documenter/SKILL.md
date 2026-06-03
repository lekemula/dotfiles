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

Disable the `rubocop:disable YARD/MeaninglessTag` if necessary.

If constructor is defined then prefer the following style:
   ```
   Foo = Struct.new(:bar, :baz) do
     # @param bar [String]
     # @param baz [Integer]
     def initialize(bar, baz)
       super(bar, baz)
     end
   end
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

### Hashes

For non-trivial Hash shapes, prefer the hash-specific syntax `Hash{KeyType => ValueType}` over the generic `Hash<K, V>` form. The hash-specific syntax also supports the following (per [yard#1630](https://github.com/lsegal/yard/pull/1630)):

- **Multiple keys for the same value type(s)** — a comma-separated list of keys on the left of `=>` all share the value types on the right:
   ```
   # @param fields [Hash{:name, :title => String}]
   ```
- **Multiple key/value groups** — separate distinct key/value groups with a semicolon (`;`):
   ```
   # @param person [Hash{:name => String; :age => Integer}]
   ```
- **Nested hashes** — a value type can itself be a hash:
   ```
   # @param payload [Hash{:user => Hash{:name => String, :age => Integer}}]
   ```
- **Multiple value types** — comma-separated value types are an "or":
   ```
   # @param opts [Hash{:status => String, Symbol}]   # value is String OR Symbol
   ```

Keys are typically literal symbols (`:key`) or strings (`'key'`), but any type from the [type conventions](https://www.rubydoc.info/gems/yard/file/docs/Tags.md#Types) is allowed.

Still skip annotation when the Hash shape is obvious from the method name/signature or already inferable by Solargraph (per rule 8 above).

### Resources 

- [YARD Cheat sheet](https://gist.github.com/chetan/1827484)
- [YARD Tags documentation](https://www.rubydoc.info/gems/yard/file/docs/Tags.md)
- [Solargraph YARD documentation](https://solargraph.org/guides/yard)
