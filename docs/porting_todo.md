# md Porting and Reimplementation Todo List

## Overview
Port RFC (ReFaCtored Standard M) to D language as "md" (M/MUMPS in D).

## Phase 1: Database Engine
- [ ] Database header structures
- [ ] Block management (data, index, map blocks)
- [ ] Buffer pool management (GBD)
- [ ] B-tree operations (insert, search, delete)
- [ ] Key encoding/decoding
- [ ] Record management
- [ ] Block bitmap (allocation/deallocation)
- [ ] Journal management
- [ ] Database file I/O (create, open, read, write)
- [ ] Database persistence
- [ ] Database recovery
- [ ] Database globals (^GLOBAL support)

## Phase 2: Runtime Interpreter
- [ ] Opcode definitions
- [ ] Stack operations (address stack, string stack)
- [ ] Program counter management
- [ ] Arithmetic operations (+, -, *, /, #, **)
- [ ] Comparison operations (=, '=, <, >, <=, >=)
- [ ] String operations (concatenation, extraction)
- [ ] Pattern matching (?)
- [ ] Control flow (FOR, DO, IF, QUIT, HALT)
- [ ] Variable operations (SET, KILL, MERGE)
- [ ] I/O operations (READ, WRITE, OPEN, CLOSE, USE)
- [ ] Math functions ($RANDOM, etc.)
- [ ] $ functions ($ASCII, $CHAR, $DATA, $EXTRACT, etc.)
- [ ] Special variables ($HOROLOG, $IO, $JOB, etc.)
- [ ] Error handling ($ECODE, $ETRAP)
- [ ] Integrated runtime (connect all components)

## Phase 3: Compiler
- [ ] Lexer (tokenization)
- [ ] Parser (AST generation)
- [ ] Code generator (opcode emission)
- [ ] $ function parser
- [ ] Full MUMPS parser (all 22 commands)
- [ ] Expression evaluator
- [ ] Indirection support
- [ ] Error handling

## Phase 4: Sequential I/O
- [ ] I/O channel management
- [ ] File I/O (open, close, read, write)
- [ ] Device I/O (terminal, printer)
- [ ] Socket I/O (TCP/IP)
- [ ] Pipe I/O (named pipes)
- [ ] Terminal I/O (cursor tracking, modes)
- [ ] Signal handling

## Phase 5: Symbol Table
- [ ] Hash table implementation
- [ ] Variable creation/lookup
- [ ] Data storage
- [ ] Dependent blocks (subscripts)
- [ ] $DATA support
- [ ] $ORDER support
- [ ] NEW command support
- [ ] Variable scoping

## Phase 6: Utilities
- [ ] Key utility functions
- [ ] Error handling (codes, messages)
- [ ] Memory utilities
- [ ] Lock table
- [ ] Routine manager
- [ ] Shared memory/semaphores

## Phase 7: External Calls
- [ ] External call interface
- [ ] Function registration
- [ ] Parameter passing
- [ ] Return value handling

## Phase 8: Init/Startup
- [ ] Environment configuration
- [ ] Database configuration
- [ ] Startup manager
- [ ] Global initialization
- [ ] Run manager

## Phase 9: Thread Safety
- [ ] SpinLock implementation
- [ ] Thread-safe symbol table
- [ ] Thread-safe globals
- [ ] Thread-safe buffer pool
- [ ] Thread-safe lock table
- [ ] Thread-safe journal

## Phase 10: Conformance Testing
- [ ] ANSI/ISO M conformance tests
- [ ] Full conformance test suite
- [ ] Edge case tests
- [ ] Performance tests

## Phase 11: Documentation
- [ ] API documentation
- [ ] User guide
- [ ] Examples
- [ ] Porting guide from RFC

## D-Specific Considerations
- [ ] Use D's built-in garbage collector where appropriate
- [ ] Leverage D's module system
- [ ] Use D's contract programming (in/out/invariant)
- [ ] Use D's scope guards for cleanup
- [ ] Leverage D's metaprogramming capabilities
- [ ] Use D's standard library (std.container, std.algorithm)
- [ ] Consider using D's concurrency features (std.concurrency)

## Estimated Effort
- **Total**: ~20,000 lines of D code
- **Timeline**: 3-6 months (depending on full-time/part-time)
