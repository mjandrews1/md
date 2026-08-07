# md — M/MUMPS in D

A port of [RFC](https://github.com/mjandrews1/rfc) (a fork of [RSM](https://gitlab.com/Reference-Standard-M/rsm)) to the D programming language.

## Origin

- **RSM** — Reference Standard M by David Wicksell (Fourth Watch Software LC), derived from MUMPS V1 by Raymond Douglas Newman
- **RFC** — ReFaCtored Standard M, a fork of RSM by Mark J. Andrews
- **md** — RFC ported to D

## License

AGPL-3.0-or-later (same as RSM and RFC)

## Building

```bash
dub build --compiler=ldc2
```

## Running

```bash
dub run --compiler=ldc2
```

## Testing

```bash
dub test --compiler=ldc2
```

## Project Structure

```
md/
├── src/
│   ├── main.d              # Main entry point
│   ├── opcode.d            # MUMPS opcode definitions
│   ├── runtime.d           # Runtime interpreter
│   ├── lexer.d             # MUMPS lexer
│   ├── parser.d            # MUMPS parser
│   ├── parser_full.d       # Full MUMPS parser (all 22 commands)
│   ├── database.d          # Database engine
│   ├── database_persist.d  # Database persistence
│   ├── database_optimized.d # Optimized database engine
│   ├── symbol.d            # Symbol table
│   ├── io.d                # I/O operations
│   ├── integrated.d        # Integrated runtime
│   ├── conformance.d       # Conformance tests
│   ├── conformance_full.d  # Full conformance tests
│   ├── conformance_complete.d # Complete conformance tests
│   ├── mumps_features.d    # Additional features
│   ├── thread_safe.d       # Thread-safe wrappers
│   └── benchmark.d         # Performance benchmarks
├── docs/
│   ├── api.md              # API documentation
│   └── porting_todo.md     # Porting todo list
├── examples/
│   ├── hello.mumps         # Hello World
│   ├── factorial.mumps     # Factorial calculation
│   ├── fibonacci.mumps     # Fibonacci sequence
│   ├── database.mumps      # Database operations
│   ├── sorting.mumps       # Sorting algorithms
│   └── string_ops.mumps    # String operations
├── CHANGELOG.md            # Changelog
├── dub.json                # D package manager config
└── README.md               # This file
```

## Features

- **Full MUMPS Parser**: All 22 MUMPS commands supported
- **Database Engine**: With persistence and optimization
- **Symbol Table**: Local and global variable support
- **I/O Operations**: Terminal, file, socket, pipe I/O
- **Pattern Matching**: Full MUMPS pattern matching
- **Math Functions**: $RANDOM, $PI, etc.
- **String Functions**: $ASCII, $CHAR, $LENGTH, $EXTRACT, $FIND, $PIECE, $TRANSLATE, $JUSTIFY
- **Special Variables**: $SYSTEM, $IO, $JOB, etc.
- **Thread Safety**: Thread-safe wrappers for all components
- **Performance**: Optimized database engine with fast paths
- **Conformance**: 43 test categories, 240+ tests

## Status

**Version 0.1.0** - Initial release

All core MUMPS operations implemented and tested.

## References

- [RFC](https://github.com/mjandrews1/rfc) - ReFaCtored Standard M
- [RSM](https://gitlab.com/Reference-Standard-M/rsm) - Reference Standard M
- [MUMPS Language Standard](https://www.iso.org/standard/59508.html)
- [D Programming Language](https://dlang.org/)
