# Changelog

All notable changes to this project will be documented in this file.

## [0.1.0] - 2026-08-07

### Added
- Initial release of md (M/MUMPS in D)
- Full MUMPS parser supporting all 22 commands
- Database engine with persistence
- Symbol table management
- I/O operations
- Pattern matching
- Math functions
- String functions
- Special variables
- Thread-safe wrappers
- Performance benchmarks
- Conformance tests (43 categories)
- API documentation
- Examples (6 MUMPS programs)

### Modules
- `opcode.d` - MUMPS opcode definitions (100+ opcodes)
- `runtime.d` - Runtime interpreter
- `lexer.d` - MUMPS lexer (tokenization)
- `parser.d` - MUMPS parser (AST generation)
- `parser_full.d` - Full MUMPS parser (all 22 commands)
- `database.d` - Database engine
- `database_persist.d` - Database persistence
- `database_optimized.d` - Optimized database engine
- `symbol.d` - Symbol table
- `io.d` - I/O operations
- `integrated.d` - Integrated runtime
- `conformance.d` - Conformance tests
- `conformance_full.d` - Full conformance tests (14 categories)
- `conformance_complete.d` - Complete conformance tests (43 categories)
- `mumps_features.d` - Additional features
- `thread_safe.d` - Thread-safe wrappers
- `benchmark.d` - Performance benchmarks

### Examples
- `hello.mumps` - Hello World example
- `factorial.mumps` - Factorial calculation
- `fibonacci.mumps` - Fibonacci sequence
- `database.mumps` - Database operations
- `sorting.mumps` - Sorting algorithms
- `string_ops.mumps` - String operations
