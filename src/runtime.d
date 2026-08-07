// Package: md
// File:    src/runtime.d
// Summary: MUMPS Runtime Interpreter
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module runtime;

import std.stdio;
import std.string;
import std.conv;
import opcode;

/// Stack entry
struct StackEntry {
    union {
        long integer;
        double floating;
        char[256] str;
    }
    enum Type { integer, floating, str, nil }
    Type type;

    static StackEntry makeInteger(long val) {
        StackEntry entry;
        entry.type = Type.integer;
        entry.integer = val;
        return entry;
    }

    static StackEntry makeFloat(double val) {
        StackEntry entry;
        entry.type = Type.floating;
        entry.floating = val;
        return entry;
    }

    static StackEntry makeString(string val) {
        StackEntry entry;
        entry.type = Type.str;
        auto len = val.length < 256 ? val.length : 255;
        entry.str[0 .. len] = val[0 .. len];
        return entry;
    }

    static StackEntry makeNull() {
        StackEntry entry;
        entry.type = Type.nil;
        return entry;
    }

    string toString() const {
        final switch (type) {
            case Type.integer:
                return .to!string(integer);
            case Type.floating:
                return .to!string(floating);
            case Type.str:
                return .to!string(str[]);
            case Type.nil:
                return "";
        }
    }
}

/// MUMPS Runtime
struct MumpsRuntime {
    // Variable storage
    string[string] variables;

    // Stack
    StackEntry[256] stack;
    int stackPointer = 0;

    // Program counter
    size_t pc = 0;

    // Execution state
    bool running = false;
    int errorCode = 0;
    string errorMessage = "";

    // I/O state
    string inputBuffer = "";
    string outputBuffer = "";

    void start() {
        running = true;
        pc = 0;
    }

    void stop() {
        running = false;
    }

    bool isRunning() const {
        return running;
    }

    // Variable operations

    void setVar(string name, string value) {
        variables[name] = value;
    }

    string getVar(string name) {
        if (auto ptr = name in variables) {
            return *ptr;
        }
        return "";
    }

    void killVar(string name) {
        variables.remove(name);
    }

    bool hasVar(string name) {
        return (name in variables) !is null;
    }

    // Stack operations

    void push(StackEntry entry) {
        if (stackPointer < 256) {
            stack[stackPointer] = entry;
            stackPointer++;
        }
    }

    StackEntry pop() {
        if (stackPointer > 0) {
            stackPointer--;
            return stack[stackPointer];
        }
        return StackEntry.makeNull();
    }

    StackEntry peek() {
        if (stackPointer > 0) {
            return stack[stackPointer - 1];
        }
        return StackEntry.makeNull();
    }

    // I/O operations

    void write(string data) {
        outputBuffer ~= data;
    }

    void writeNewline() {
        outputBuffer ~= "\n";
    }

    void writeFormFeed() {
        outputBuffer ~= "\x0C";
    }

    string read() {
        auto result = inputBuffer;
        inputBuffer = "";
        return result;
    }

    void addInput(string data) {
        inputBuffer ~= data;
    }

    string getOutput() {
        return outputBuffer;
    }

    void clearOutput() {
        outputBuffer = "";
    }

    // Error handling

    void setError(int code, string message) {
        errorCode = code;
        errorMessage = message;
    }

    int getErrorCode() {
        return errorCode;
    }

    string getErrorMessage() {
        return errorMessage;
    }

    void clearError() {
        errorCode = 0;
        errorMessage = "";
    }

    // Execution

    void execute(Opcode[] code) {
        while (running && pc < code.length) {
            auto op = code[pc];
            pc++;

            switch (op) {
                case Opcode.OPHALT:
                    stop();
                    break;

                case Opcode.CMWRTEX:
                    auto val = pop();
                    write(val.toString());
                    break;

                case Opcode.CMWRTNL:
                    writeNewline();
                    break;

                case Opcode.CMWRTFF:
                    writeFormFeed();
                    break;

                case Opcode.CMSET:
                    // Simplified SET
                    break;

                case Opcode.CMKILL:
                    // Simplified KILL
                    break;

                case Opcode.CMQUIT:
                    stop();
                    break;

                default:
                    // Unknown opcode
                    break;
            }
        }
    }
}

unittest {
    MumpsRuntime runtime;
    runtime.start();
    assert(runtime.isRunning());

    runtime.setVar("X", "42");
    assert(runtime.getVar("X") == "42");
    assert(runtime.hasVar("X"));

    runtime.killVar("X");
    assert(!runtime.hasVar("X"));

    runtime.stop();
    assert(!runtime.isRunning());
}

unittest {
    MumpsRuntime runtime;

    runtime.push(StackEntry.makeInteger(42));
    runtime.push(StackEntry.makeInteger(100));

    auto val1 = runtime.pop();
    assert(val1.integer == 100);

    auto val2 = runtime.pop();
    assert(val2.integer == 42);
}

unittest {
    MumpsRuntime runtime;

    runtime.write("Hello");
    runtime.writeNewline();
    runtime.write("World");

    assert(runtime.getOutput() == "Hello\nWorld");

    runtime.clearOutput();
    assert(runtime.getOutput() == "");
}
