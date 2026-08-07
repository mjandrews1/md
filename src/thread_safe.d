// Package: md
// File:    src/thread_safe.d
// Summary: Thread-Safe Wrappers
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module thread_safe;

import std.stdio;
import std.concurrency;
import database;
import symbol;

/// Thread-safe database wrapper
struct ThreadSafeDatabase {
    Database db;
    Tid owner;

    void init() {
        db = Database.init;
        owner = Tid.init;
    }

    void set(string global, string[] subscripts, string value) {
        synchronized {
            db.set(global, subscripts, value);
        }
    }

    string get(string global, string[] subscripts) {
        synchronized {
            return db.get(global, subscripts);
        }
    }

    void kill(string global, string[] subscripts) {
        synchronized {
            db.kill(global, subscripts);
        }
    }

    uint data(string global, string[] subscripts) {
        synchronized {
            return db.data(global, subscripts);
        }
    }

    string order(string global, string[] subscripts, int direction = 1) {
        synchronized {
            return db.order(global, subscripts, direction);
        }
    }
}

/// Thread-safe symbol table wrapper
struct ThreadSafeSymbolTable {
    SymbolTable symtab;

    void init() {
        symtab = SymbolTable.init;
    }

    void set(string name, string value) {
        synchronized {
            symtab.set(name, value);
        }
    }

    string get(string name) {
        synchronized {
            return symtab.get(name);
        }
    }

    bool exists(string name) {
        synchronized {
            return symtab.exists(name);
        }
    }

    void kill(string name) {
        synchronized {
            symtab.kill(name);
        }
    }

    void setSubscript(string name, string[] subscripts, string value) {
        synchronized {
            symtab.setSubscript(name, subscripts, value);
        }
    }

    string getSubscript(string name, string[] subscripts) {
        synchronized {
            return symtab.getSubscript(name, subscripts);
        }
    }

    void killSubscript(string name, string[] subscripts) {
        synchronized {
            symtab.killSubscript(name, subscripts);
        }
    }

    uint data(string name, string[] subscripts) {
        synchronized {
            return symtab.data(name, subscripts);
        }
    }

    string order(string name, string[] subscripts, int direction = 1) {
        synchronized {
            return symtab.order(name, subscripts, direction);
        }
    }
}

/// Thread-safe integrated runtime
struct ThreadSafeRuntime {
    Database db;
    SymbolTable symtab;
    bool running;
    int errorCode;
    string errorMessage;

    void init() {
        db = Database.init;
        symtab = SymbolTable.init;
        running = false;
        errorCode = 0;
        errorMessage = "";
    }

    void start() {
        synchronized {
            running = true;
        }
    }

    void stop() {
        synchronized {
            running = false;
        }
    }

    bool isRunning() {
        synchronized {
            return running;
        }
    }

    void setVar(string name, string value) {
        synchronized {
            symtab.set(name, value);
        }
    }

    string getVar(string name) {
        synchronized {
            return symtab.get(name);
        }
    }

    void killVar(string name) {
        synchronized {
            symtab.kill(name);
        }
    }

    bool hasVar(string name) {
        synchronized {
            return symtab.exists(name);
        }
    }

    void setGlobal(string name, string[] subscripts, string value) {
        synchronized {
            db.set(name, subscripts, value);
        }
    }

    string getGlobal(string name, string[] subscripts) {
        synchronized {
            return db.get(name, subscripts);
        }
    }

    void killGlobal(string name, string[] subscripts) {
        synchronized {
            db.kill(name, subscripts);
        }
    }

    uint dataGlobal(string name, string[] subscripts) {
        synchronized {
            return db.data(name, subscripts);
        }
    }

    string orderGlobal(string name, string[] subscripts, int direction = 1) {
        synchronized {
            return db.order(name, subscripts, direction);
        }
    }

    void setError(int code, string message) {
        synchronized {
            errorCode = code;
            errorMessage = message;
        }
    }

    int getErrorCode() {
        synchronized {
            return errorCode;
        }
    }

    string getErrorMessage() {
        synchronized {
            return errorMessage;
        }
    }

    void clearError() {
        synchronized {
            errorCode = 0;
            errorMessage = "";
        }
    }
}

unittest {
    ThreadSafeDatabase db;
    db.init();
    
    db.set("TEST", [], "value");
    assert(db.get("TEST", []) == "value");
    
    db.set("TEST", ["sub1"], "value1");
    assert(db.get("TEST", ["sub1"]) == "value1");
    
    db.kill("TEST", []);
    assert(db.get("TEST", []) == "");
}

unittest {
    ThreadSafeSymbolTable symtab;
    symtab.init();
    
    symtab.set("X", "42");
    assert(symtab.get("X") == "42");
    assert(symtab.exists("X"));
    
    symtab.kill("X");
    assert(!symtab.exists("X"));
}

unittest {
    ThreadSafeRuntime rt;
    rt.init();
    
    rt.start();
    assert(rt.isRunning());
    
    rt.setVar("X", "42");
    assert(rt.getVar("X") == "42");
    
    rt.setGlobal("TEST", ["sub1"], "value1");
    assert(rt.getGlobal("TEST", ["sub1"]) == "value1");
    
    rt.stop();
    assert(!rt.isRunning());
}
