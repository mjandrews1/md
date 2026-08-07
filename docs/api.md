# md API Documentation

## Overview

md is a MUMPS (M) implementation written in D. It provides a complete MUMPS runtime environment including:

- Database engine with persistence
- Runtime interpreter with all MUMPS opcodes
- Full MUMPS parser supporting all 22 commands
- Symbol table management
- I/O operations
- Thread-safe wrappers

## Core Modules

### Database Engine

#### `database.d`
Main database module providing global variable storage.

```d
import database;

// Create a database
Database db;

// Set data
db.set("GLOBAL", [], "value");
db.set("GLOBAL", ["sub1"], "value1");

// Get data
string value = db.get("GLOBAL", []);
string value1 = db.get("GLOBAL", ["sub1"]);

// Kill data
db.kill("GLOBAL", []);

// $DATA
uint status = db.data("GLOBAL", []); // 0, 1, 10, 11

// $ORDER
string next = db.order("GLOBAL", []);
```

#### `database_persist.d`
Database persistence module.

```d
import database_persist;

// Create persistence manager
DatabasePersistence persist;
persist.init("/path/to/database.dat");

// Create database file
persist.create();

// Save database
persist.saveDatabase(&db);

// Load database
Database db2;
persist.loadDatabase(&db2);
```

#### `database_optimized.d`
Optimized database engine with fast paths.

```d
import database_optimized;

// Create optimized database
OptimizedDatabase db;

// Set/get data (same API as database.d)
db.set("GLOBAL", [], "value");
string value = db.get("GLOBAL", []);
```

### Runtime Interpreter

#### `runtime.d`
Main runtime interpreter with opcode execution.

```d
import runtime;

// Create runtime
MumpsRuntime runtime;
runtime.start();

// Variable operations
runtime.setVar("X", "42");
string value = runtime.getVar("X");
runtime.killVar("X");

// I/O operations
runtime.write("Hello");
runtime.writeNewline();

// Stack operations
runtime.push(StackEntry.makeInteger(42));
auto val = runtime.pop();
```

#### `opcode.d`
MUMPS opcode definitions.

```d
import opcode;

// Get opcode name
string name = opcodeName(Opcode.OPADD);
```

### Compiler

#### `lexer.d`
MUMPS lexer for tokenization.

```d
import lexer;

// Create lexer
auto lexer = Lexer.create("SET X = 42");

// Get tokens
auto token = lexer.nextToken();
```

#### `parser.d`
MUMPS parser for AST generation.

```d
import parser;

// Create parser
auto parser = Parser.create("SET X = 42");

// Parse code
auto ast = parser.parse();
```

#### `parser_full.d`
Full MUMPS parser supporting all 22 commands.

```d
import parser_full;

// Create parser
auto parser = FullParser.create("SET X = 42");

// Parse code
auto ast = parser.parse();
```

### Symbol Table

#### `symbol.d`
Symbol table for local variables.

```d
import symbol;

// Create symbol table
SymbolTable table;

// Set/get variables
table.set("X", "42");
string value = table.get("X");

// Check if variable exists
bool exists = table.exists("X");

// Kill variable
table.kill("X");

// Subscripted variables
table.setSubscript("A", ["sub1"], "value1");
string val = table.getSubscript("A", ["sub1"]);
```

### I/O Operations

#### `io.d`
I/O operations for devices.

```d
import io;

// Create I/O manager
IOManager io;
io.init();

// Open device
io.open(0, "terminal", DeviceType.terminal);

// Use device
io.use(0);

// Write data
io.write("Hello");
io.writeNewline();

// Read data
string input = io.read();

// Close device
io.close(0);
```

### Integrated Runtime

#### `integrated.d`
Integrated runtime connecting all components.

```d
import integrated;

// Create integrated runtime
IntegratedRuntime rt;
rt.init();

// Start execution
rt.start();

// Variable operations
rt.setVar("X", "42");
string value = rt.getVar("X");

// Database operations
rt.setGlobal("TEST", ["sub1"], "value1");
string val = rt.getGlobal("TEST", ["sub1"]);

// I/O operations
rt.write("Hello");
rt.writeNewline();

// Stop execution
rt.stop();
```

### Thread Safety

#### `thread_safe.d`
Thread-safe wrappers for all components.

```d
import thread_safe;

// Thread-safe database
ThreadSafeDatabase db;
db.init();
db.set("TEST", [], "value");

// Thread-safe symbol table
ThreadSafeSymbolTable symtab;
symtab.init();
symtab.set("X", "42");

// Thread-safe runtime
ThreadSafeRuntime rt;
rt.init();
rt.start();
rt.setVar("X", "42");
rt.stop();
```

### Additional Features

#### `mumps_features.d`
MUMPS additional features.

```d
import mumps_features;

// Pattern matching
bool match = PatternMatcher.match("123", "3N");

// Math functions
int rand = MathFunctions.random(100);
double pi = MathFunctions.pi();

// String functions
int ascii = StringFunctions.ascii("A");
string ch = StringFunctions.char_(65);
int len = StringFunctions.length("Hello");
string ext = StringFunctions.extract("ABCDE", 2, 4);
int pos = StringFunctions.find("ABCDE", "CD");
string piece = StringFunctions.piece("A,B,C", ",", 2);
string trans = StringFunctions.translate("ABC", "AC", "XY");
string just = StringFunctions.justify("Hello", 10);

// Special variables
string system = SpecialVars.system();
string io = SpecialVars.io();
int job = SpecialVars.job();
```

## Test Suite

### Running Tests

```bash
dub test --compiler=ldc2
```

### Test Coverage

The test suite includes 14 test categories:

- Arithmetic operations
- Comparison operations
- String operations
- Variable operations
- Database operations
- Symbol table operations
- I/O operations
- Integrated runtime
- Pattern matching
- Math functions
- String functions
- Special variables
- Database persistence
- Thread safety

## Error Handling

All functions that can fail return an error union. Use `try` to propagate errors or `catch` to handle them.

```d
try {
    db.set("TEST", [], "value");
} catch (Exception e) {
    // Handle error
}
```

## Memory Management

All modules use D's garbage collector. No manual memory management required.

## Thread Safety

Use the thread-safe wrappers from `thread_safe.d` for multi-threaded access.

## Platform Support

md supports:

- macOS (via ldc2)
- Linux (via ldc2)
- Windows (via ldc2)

## License

AGPL-3.0-or-later
