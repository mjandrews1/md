// Package: md
// File:    src/main.d
// Summary: M/MUMPS in D - A port of RFC to D language
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module main;

import std.stdio;
import std.string;
import opcode;
import runtime;

void main() {
    writeln("md - M/MUMPS in D");
    writeln("A port of RFC to D language");
    writeln();

    // Create runtime
    MumpsRuntime runtime;
    runtime.start();

    // Test basic operations
    writeln("Testing MUMPS operations:");
    writeln("========================");

    // SET
    runtime.setVar("X", "42");
    runtime.setVar("NAME", "John");

    // WRITE
    runtime.write("X = ");
    runtime.write(runtime.getVar("X"));
    runtime.writeNewline();

    runtime.write("NAME = ");
    runtime.write(runtime.getVar("NAME"));
    runtime.writeNewline();

    // Test $DATA
    writeln();
    writeln("Variable X exists: ", runtime.hasVar("X"));
    writeln("Variable Y exists: ", runtime.hasVar("Y"));

    // KILL
    runtime.killVar("X");
    writeln("After KILL X: ", runtime.getVar("X"));

    // Stack operations
    writeln();
    writeln("Stack operations:");
    runtime.push(StackEntry.makeInteger(42));
    runtime.push(StackEntry.makeInteger(100));

    auto val1 = runtime.pop();
    writeln("Pop: ", val1.integer);

    auto val2 = runtime.pop();
    writeln("Pop: ", val2.integer);

    // Get output
    writeln();
    writeln("Output:");
    writeln(runtime.getOutput());

    writeln();
    writeln("md is ready for MUMPS development!");
}
