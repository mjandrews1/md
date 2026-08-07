// Package: md
// File:    src/database_optimized.d
// Summary: Optimized Database Engine
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module database_optimized;

import std.stdio;
import std.string;

/// Optimized database entry
struct DbEntry {
    string key;
    string value;
    DbEntry*[string] children;
}

/// Optimized database
struct OptimizedDatabase {
    DbEntry*[string] globals;
    
    // Fast path for common operations
    void set(string global, string[] subscripts, string value) {
        if (subscripts.length == 0) {
            // Fast path for root value
            if (auto ptr = global in globals) {
                (*ptr).value = value;
            } else {
                auto entry = new DbEntry();
                entry.key = global;
                entry.value = value;
                globals[global] = entry;
            }
        } else {
            // Fast path for subscripted value
            if (auto ptr = global in globals) {
                setSubscript(*ptr, subscripts, value);
            } else {
                auto entry = new DbEntry();
                entry.key = global;
                globals[global] = entry;
                setSubscript(entry, subscripts, value);
            }
        }
    }

    private void setSubscript(DbEntry* parent, string[] subscripts, string value) {
        if (subscripts.length == 1) {
            // Fast path for leaf value
            if (auto ptr = subscripts[0] in parent.children) {
                (*ptr).value = value;
            } else {
                auto entry = new DbEntry();
                entry.key = subscripts[0];
                entry.value = value;
                parent.children[subscripts[0]] = entry;
            }
        } else {
            // Traverse
            if (auto ptr = subscripts[0] in parent.children) {
                setSubscript(*ptr, subscripts[1 .. $], value);
            } else {
                auto entry = new DbEntry();
                entry.key = subscripts[0];
                parent.children[subscripts[0]] = entry;
                setSubscript(entry, subscripts[1 .. $], value);
            }
        }
    }

    string get(string global, string[] subscripts) {
        if (auto ptr = global in globals) {
            if (subscripts.length == 0) {
                return (*ptr).value;
            } else {
                return getSubscript(*ptr, subscripts);
            }
        }
        return "";
    }

    private string getSubscript(DbEntry* parent, string[] subscripts) {
        if (subscripts.length == 1) {
            if (auto ptr = subscripts[0] in parent.children) {
                return (*ptr).value;
            }
        } else {
            if (auto ptr = subscripts[0] in parent.children) {
                return getSubscript(*ptr, subscripts[1 .. $]);
            }
        }
        return "";
    }

    void kill(string global, string[] subscripts) {
        if (subscripts.length == 0) {
            // Kill entire global
            globals.remove(global);
        } else {
            // Kill subscripted
            if (auto ptr = global in globals) {
                killSubscript(*ptr, subscripts);
            }
        }
    }

    private void killSubscript(DbEntry* parent, string[] subscripts) {
        if (subscripts.length == 1) {
            parent.children.remove(subscripts[0]);
        } else {
            if (auto ptr = subscripts[0] in parent.children) {
                killSubscript(*ptr, subscripts[1 .. $]);
            }
        }
    }

    uint data(string global, string[] subscripts) {
        if (auto ptr = global in globals) {
            if (subscripts.length == 0) {
                uint result = 0;
                if ((*ptr).value.length > 0) result += 1;
                if ((*ptr).children.length > 0) result += 10;
                return result;
            } else {
                return dataSubscript(*ptr, subscripts);
            }
        }
        return 0;
    }

    private uint dataSubscript(DbEntry* parent, string[] subscripts) {
        if (subscripts.length == 1) {
            if (auto ptr = subscripts[0] in parent.children) {
                uint result = 0;
                if ((*ptr).value.length > 0) result += 1;
                if ((*ptr).children.length > 0) result += 10;
                return result;
            }
        } else {
            if (auto ptr = subscripts[0] in parent.children) {
                return dataSubscript(*ptr, subscripts[1 .. $]);
            }
        }
        return 0;
    }

    string order(string global, string[] subscripts, int direction = 1) {
        if (auto ptr = global in globals) {
            if (subscripts.length == 0) {
                // Order of root
                return orderChildren((*ptr).children, "", direction);
            } else {
                return orderSubscript(*ptr, subscripts, direction);
            }
        }
        return "";
    }

    private string orderSubscript(DbEntry* parent, string[] subscripts, int direction) {
        if (subscripts.length == 1) {
            return orderChildren(parent.children, subscripts[0], direction);
        } else {
            if (auto ptr = subscripts[0] in parent.children) {
                return orderSubscript(*ptr, subscripts[1 .. $], direction);
            }
        }
        return "";
    }

    private string orderChildren(DbEntry*[string] children, string current, int direction) {
        // Simple implementation - return first/next key
        string[] keys;
        foreach (key; children.keys) {
            keys ~= key;
        }
        
        if (keys.length == 0) return "";
        
        // Sort keys
        import std.algorithm : sort;
        keys.sort();
        
        if (current.length == 0) {
            if (direction > 0) {
                return keys[0];
            } else {
                return keys[$ - 1];
            }
        }
        
        // Find current and return next
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
    OptimizedDatabase db;
    
    db.set("TEST", [], "root");
    assert(db.get("TEST", []) == "root");
    
    db.set("TEST", ["sub1"], "value1");
    assert(db.get("TEST", ["sub1"]) == "value1");
    
    db.set("TEST", ["sub1", "sub2"], "value2");
    assert(db.get("TEST", ["sub1", "sub2"]) == "value2");
    
    assert(db.data("TEST", []) == 11); // Has value and children
    assert(db.data("TEST", ["sub1"]) == 11);
    assert(db.data("TEST", ["sub1", "sub2"]) == 1);
    
    db.kill("TEST", ["sub1"]);
    assert(db.get("TEST", ["sub1"]) == "");
    assert(db.data("TEST", []) == 1); // Only root value
}

unittest {
    OptimizedDatabase db;
    
    db.set("TEST", ["a"], "1");
    db.set("TEST", ["b"], "2");
    db.set("TEST", ["c"], "3");
    
    assert(db.order("TEST", []) == "a");
    assert(db.order("TEST", ["a"]) == "b");
    assert(db.order("TEST", ["b"]) == "c");
    assert(db.order("TEST", ["c"]) == "");
}
