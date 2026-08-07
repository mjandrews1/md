// Package: md
// File:    src/integrated.d
// Summary: Integrated MUMPS Runtime
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module integrated;

import std.stdio;
import std.string;
import std.conv;
import database;
import symbol;
import io;

/// Integrated MUMPS Runtime
struct IntegratedRuntime {
    // Components
    Database db;
    SymbolTable symtab;
    IOManager iomanager;
    
    // Execution state
    bool running;
    int errorCode;
    string errorMessage;
    
    // Performance counters
    long instructionCount;
    long variableAccessCount;
    long ioOperationCount;

    void init() {
        db = Database.init;
        symtab = SymbolTable.init;
        iomanager.init();
        running = false;
        errorCode = 0;
        errorMessage = "";
        instructionCount = 0;
        variableAccessCount = 0;
        ioOperationCount = 0;
    }

    void start() {
        running = true;
    }

    void stop() {
        running = false;
    }

    bool isRunning() {
        return running;
    }

    // Variable operations

    void setVar(string name, string value) {
        variableAccessCount++;
        symtab.set(name, value);
    }

    string getVar(string name) {
        variableAccessCount++;
        return symtab.get(name);
    }

    void killVar(string name) {
        variableAccessCount++;
        symtab.kill(name);
    }

    bool hasVar(string name) {
        variableAccessCount++;
        return symtab.exists(name);
    }

    // Database operations

    void setGlobal(string name, string[] subscripts, string value) {
        variableAccessCount++;
        db.set(name, subscripts, value);
    }

    string getGlobal(string name, string[] subscripts) {
        variableAccessCount++;
        return db.get(name, subscripts);
    }

    void killGlobal(string name, string[] subscripts) {
        variableAccessCount++;
        db.kill(name, subscripts);
    }

    uint dataGlobal(string name, string[] subscripts) {
        variableAccessCount++;
        return db.data(name, subscripts);
    }

    string orderGlobal(string name, string[] subscripts, int direction = 1) {
        variableAccessCount++;
        return db.order(name, subscripts, direction);
    }

    // I/O operations

    void write(string data) {
        ioOperationCount++;
        iomanager.write(data);
    }

    void writeNewline() {
        ioOperationCount++;
        iomanager.writeNewline();
    }

    void writeFormFeed() {
        ioOperationCount++;
        iomanager.writeFormFeed();
    }

    void writeTab(int col) {
        ioOperationCount++;
        iomanager.writeTab(col);
    }

    void writeStar(char c) {
        ioOperationCount++;
        iomanager.writeStar(c);
    }

    string read(int timeout = 0) {
        ioOperationCount++;
        return iomanager.read(timeout);
    }

    char readStar(int timeout = 0) {
        ioOperationCount++;
        return iomanager.readStar(timeout);
    }

    void addInput(int id, string data) {
        iomanager.addInput(id, data);
    }

    string getOutput(int id) {
        return iomanager.getOutput(id);
    }

    void clearOutput(int id) {
        iomanager.clearOutput(id);
    }

    // Execution control

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

    // Performance counters

    long getInstructionCount() {
        return instructionCount;
    }

    long getVariableAccessCount() {
        return variableAccessCount;
    }

    long getIOOperationCount() {
        return ioOperationCount;
    }

    void incrementInstructionCount() {
        instructionCount++;
    }

    // MUMPS operations

    void executeSet(string name, string value) {
        incrementInstructionCount();
        setVar(name, value);
    }

    void executeWrite(string data) {
        incrementInstructionCount();
        write(data);
    }

    void executeWriteNewline() {
        incrementInstructionCount();
        writeNewline();
    }

    bool executeIf(bool condition) {
        incrementInstructionCount();
        return condition;
    }

    void executeKill(string name) {
        incrementInstructionCount();
        killVar(name);
    }

    void executeQuit() {
        incrementInstructionCount();
        stop();
    }

    void executeHalt() {
        incrementInstructionCount();
        stop();
    }
}

unittest {
    IntegratedRuntime rt;
    rt.init();
    
    rt.start();
    assert(rt.isRunning());
    rt.stop();
    assert(!rt.isRunning());
}

unittest {
    IntegratedRuntime rt;
    rt.init();
    
    rt.setVar("X", "42");
    assert(rt.getVar("X") == "42");
    assert(rt.hasVar("X"));
    
    rt.killVar("X");
    assert(!rt.hasVar("X"));
}

unittest {
    IntegratedRuntime rt;
    rt.init();
    
    rt.setGlobal("TEST", ["sub1"], "value1");
    assert(rt.getGlobal("TEST", ["sub1"]) == "value1");
    assert(rt.dataGlobal("TEST", ["sub1"]) == 1);
    
    rt.killGlobal("TEST", ["sub1"]);
    assert(rt.getGlobal("TEST", ["sub1"]) == "");
}

unittest {
    IntegratedRuntime rt;
    rt.init();
    
    rt.write("Hello");
    rt.writeNewline();
    rt.write("World");
    
    assert(rt.getOutput(0) == "Hello\nWorld");
}

unittest {
    IntegratedRuntime rt;
    rt.init();
    
    rt.start();
    rt.executeSet("X", "42");
    rt.executeWrite("Hello");
    rt.executeWriteNewline();
    rt.executeWrite("World");
    
    assert(rt.getVar("X") == "42");
    assert(rt.getOutput(0) == "Hello\nWorld");
    
    rt.executeHalt();
    assert(!rt.isRunning());
}
