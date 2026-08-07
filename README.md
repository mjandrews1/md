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
dub build
```

## Running

```bash
dub run
```

## Testing

```bash
dub test
```

## Project Structure

```
md/
├── src/
│   ├── main.d          # Main entry point
│   ├── runtime.d       # MUMPS runtime
│   ├── interpreter.d   # MUMPS interpreter
│   ├── compiler.d      # MUMPS compiler
│   ├── database.d      # Database engine
│   ├── symbol.d        # Symbol table
│   ├── io.d            # I/O operations
│   └── util.d          # Utility functions
├── dub.json            # D package manager config
├── README.md           # This file
└── LICENSE             # License file
```

## Goals

- Full MUMPS ANSI/ISO standard compliance
- High performance
- Modern D language features
- Cross-platform support

## Status

Early development. Basic runtime and interpreter implemented.

## References

- [RFC](https://github.com/mjandrews1/rfc) - ReFaCtored Standard M
- [RSM](https://gitlab.com/Reference-Standard-M/rsm) - Reference Standard M
- [MUMPS Language Standard](https://www.iso.org/standard/59508.html)
- [D Programming Language](https://dlang.org/)
