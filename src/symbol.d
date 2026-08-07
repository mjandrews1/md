// Package: md
// File:    src/symbol.d
// Summary: MUMPS Symbol Table
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module symbol;

import std.stdio;
import std.string;

/// Symbol table entry
struct SymbolEntry {
    string name;
    string value;
    SymbolEntry*[string] subscripts;
    int usage;
}

/// Symbol table
struct SymbolTable {
    SymbolEntry*[string] entries;
    
    void set(string name, string value) {
        if (auto ptr = name in entries) {
            (*ptr).value = value;
        } else {
            auto entry = new SymbolEntry();
            entry.name = name;
            entry.value = value;
            entry.usage = 1;
            entries[name] = entry;
        }
    }

    string get(string name) {
        if (auto ptr = name in entries) {
            return (*ptr).value;
        }
        return "";
    }

    bool exists(string name) {
        return (name in entries) !is null;
    }

    void kill(string name) {
        entries.remove(name);
    }

    void setSubscript(string name, string[] subscripts, string value) {
        if (auto ptr = name in entries) {
            setSubscriptEntry(*ptr, subscripts, value);
        } else {
            auto entry = new SymbolEntry();
            entry.name = name;
            entry.usage = 1;
            entries[name] = entry;
            setSubscriptEntry(entry, subscripts, value);
        }
    }

    private void setSubscriptEntry(SymbolEntry* parent, string[] subscripts, string value) {
        if (subscripts.length == 1) {
            if (auto ptr = subscripts[0] in parent.subscripts) {
                (*ptr).value = value;
            } else {
                auto entry = new SymbolEntry();
                entry.name = subscripts[0];
                entry.value = value;
                parent.subscripts[subscripts[0]] = entry;
            }
        } else {
            if (auto ptr = subscripts[0] in parent.subscripts) {
                setSubscriptEntry(*ptr, subscripts[1 .. $], value);
            } else {
                auto entry = new SymbolEntry();
                entry.name = subscripts[0];
                parent.subscripts[subscripts[0]] = entry;
                setSubscriptEntry(entry, subscripts[1 .. $], value);
            }
        }
    }

    string getSubscript(string name, string[] subscripts) {
        if (auto ptr = name in entries) {
            return getSubscriptEntry(*ptr, subscripts);
        }
        return "";
    }

    private string getSubscriptEntry(SymbolEntry* parent, string[] subscripts) {
        if (subscripts.length == 1) {
            if (auto ptr = subscripts[0] in parent.subscripts) {
                return (*ptr).value;
            }
        } else {
            if (auto ptr = subscripts[0] in parent.subscripts) {
                return getSubscriptEntry(*ptr, subscripts[1 .. $]);
            }
        }
        return "";
    }

    void killSubscript(string name, string[] subscripts) {
        if (auto ptr = name in entries) {
            killSubscriptEntry(*ptr, subscripts);
        }
    }

    private void killSubscriptEntry(SymbolEntry* parent, string[] subscripts) {
        if (subscripts.length == 1) {
            parent.subscripts.remove(subscripts[0]);
        } else {
            if (auto ptr = subscripts[0] in parent.subscripts) {
                killSubscriptEntry(*ptr, subscripts[1 .. $]);
            }
        }
    }

    uint data(string name, string[] subscripts) {
        if (auto ptr = name in entries) {
            if (subscripts.length == 0) {
                uint result = 0;
                if ((*ptr).value.length > 0) result += 1;
                if ((*ptr).subscripts.length > 0) result += 10;
                return result;
            } else {
                return dataSubscript(*ptr, subscripts);
            }
        }
        return 0;
    }

    private uint dataSubscript(SymbolEntry* parent, string[] subscripts) {
        if (subscripts.length == 1) {
            if (auto ptr = subscripts[0] in parent.subscripts) {
                uint result = 0;
                if ((*ptr).value.length > 0) result += 1;
                if ((*ptr).subscripts.length > 0) result += 10;
                return result;
            }
        } else {
            if (auto ptr = subscripts[0] in parent.subscripts) {
                return dataSubscript(*ptr, subscripts[1 .. $]);
            }
        }
        return 0;
    }

    string order(string name, string[] subscripts, int direction = 1) {
        if (auto ptr = name in entries) {
            if (subscripts.length == 0) {
                return orderChildren((*ptr).subscripts, "", direction);
            } else {
                return orderSubscript(*ptr, subscripts, direction);
            }
        }
        return "";
    }

    private string orderSubscript(SymbolEntry* parent, string[] subscripts, int direction) {
        if (subscripts.length == 1) {
            return orderChildren(parent.subscripts, subscripts[0], direction);
        } else {
            if (auto ptr = subscripts[0] in parent.subscripts) {
                return orderSubscript(*ptr, subscripts[1 .. $], direction);
            }
        }
        return "";
    }

    private string orderChildren(SymbolEntry*[string] children, string current, int direction) {
        string[] keys;
        foreach (key; children.keys) {
            keys ~= key;
        }
        
        if (keys.length == 0) return "";
        
        import std.algorithm : sort;
        keys.sort();
        
        if (current.length == 0) {
            if (direction > 0) {
                return keys[0];
            } else {
                return keys[$ - 1];
            }
        }
        
        for (uint i = 0; i < keys.length; i++) {
            if (keys[i] == current) {
                if (direction > 0) {
                    if (i + 1 < keys.length) return keys[i + 1];
                } else {
                    if (i > 0) return keys[i - 1];
                }
                return "";
            }
        }
        
        return "";
    }
}

unittest {
    SymbolTable table;
    
    table.set("X", "42");
    assert(table.get("X") == "42");
    assert(table.exists("X"));
    
    table.kill("X");
    assert(!table.exists("X"));
    assert(table.get("X") == "");
}

unittest {
    SymbolTable table;
    
    table.setSubscript("A", ["1"], "value1");
    table.setSubscript("A", ["2"], "value2");
    
    assert(table.getSubscript("A", ["1"]) == "value1");
    assert(table.getSubscript("A", ["2"]) == "value2");
    
    assert(table.data("A", []) == 10); // Has children only
    assert(table.data("A", ["1"]) == 1);
    
    table.killSubscript("A", ["1"]);
    assert(table.getSubscript("A", ["1"]) == "");
    assert(table.data("A", []) == 10); // Still has children
}

unittest {
    SymbolTable table;
    
    table.setSubscript("A", ["a"], "1");
    table.setSubscript("A", ["b"], "2");
    table.setSubscript("A", ["c"], "3");
    
    assert(table.order("A", []) == "a");
    assert(table.order("A", ["a"]) == "b");
    assert(table.order("A", ["b"]) == "c");
    assert(table.order("A", ["c"]) == "");
}
