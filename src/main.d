// Package: md
// File:    src/main.d
// Summary: M/MUMPS in D - A port of RFC to D language
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module main;

import std.stdio;
import std.string;

/// MUMPS Runtime
struct MumpsRuntime {
    string[string] variables;
    bool running;
    
    void start() {
        running = true;
    }
    
    void stop() {
        running = false;
    }
    
    bool isRunning() const {
        return running;
    }
    
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
    
    void write(string data) {
        write(data);
    }
    
    void writeNewline() {
        writeln();
    }
}

/// MUMPS Interpreter
struct MumpsInterpreter {
    MumpsRuntime* runtime;
    
    void execute(string code) {
        // Parse and execute MUMPS code
        auto parts = code.split(" ");
        if (parts.length == 0) return;
        
        string command = parts[0].toUpper();
        
        switch (command) {
            case "SET":
                executeSet(parts[1..$]);
                break;
            case "WRITE":
                executeWrite(parts[1..$]);
                break;
            case "KILL":
                executeKill(parts[1..$]);
                break;
            case "HALT":
                runtime.stop();
                break;
            default:
                writeln("Unknown command: ", command);
                break;
        }
    }
    
    private void executeSet(string[] args) {
        if (args.length < 2) return;
        string name = args[0];
        string value = args[1];
        runtime.setVar(name, value);
    }
    
    private void executeWrite(string[] args) {
        foreach (arg; args) {
            if (arg[0] == '"') {
                // String literal
                write(arg[1..$-1]);
            } else {
                // Variable
                write(runtime.getVar(arg));
            }
        }
    }
    
    private void executeKill(string[] args) {
        foreach (arg; args) {
            runtime.killVar(arg);
        }
    }
}

void main() {
    writeln("md - M/MUMPS in D");
    writeln("A port of RFC to D language");
    writeln();
    
    // Create runtime
    MumpsRuntime runtime;
    runtime.start();
    
    // Create interpreter
    MumpsInterpreter interpreter = MumpsInterpreter(&runtime);
    
    // Test basic operations
    writeln("Testing MUMPS operations:");
    writeln("========================");
    
    // SET
    interpreter.execute("SET X 42");
    interpreter.execute("SET NAME John");
    
    // WRITE
    interpreter.execute("WRITE X");
    writeln();
    interpreter.execute("WRITE NAME");
    writeln();
    
    // Test $DATA
    writeln();
    writeln("Variable X exists: ", runtime.getVar("X") != "");
    writeln("Variable Y exists: ", runtime.getVar("Y") != "");
    
    // KILL
    interpreter.execute("KILL X");
    writeln("After KILL X: ", runtime.getVar("X"));
    
    writeln();
    writeln("md is ready for MUMPS development!");
}
