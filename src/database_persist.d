// Package: md
// File:    src/database_persist.d
// Summary: Database Persistence
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module database_persist;

import std.stdio;
import std.file;
import std.path;
import database;

/// Database file header
struct DatabaseHeader {
    uint magic;      // Magic number (0x4D444246 = "MDBF")
    uint fileVersion;    // File version
    uint blockSize;  // Block size
    uint maxBlocks;  // Maximum blocks
    uint freeBlocks; // Free blocks
    uint rootBlock;  // Root block number
    long created;    // Creation time
    long modified;   // Modification time

    void init() {
        magic = 0x4D444246; // "MDBF"
        fileVersion = 1;
        blockSize = 4096;
        maxBlocks = 1000;
        freeBlocks = 999;
        rootBlock = 1;
        created = 0;
        modified = 0;
    }
}

/// Database persistence manager
struct DatabasePersistence {
    DatabaseHeader header;
    string path;

    void init(string dbPath) {
        path = dbPath;
        header.init();
    }

    bool create() {
        try {
            // Create file
            auto file = File(path, "wb");
            
            // Write header
            ubyte[48] headerBytes;
            headerBytes[0..4] = cast(ubyte[])((&header.magic)[0..1]);
            headerBytes[4..8] = cast(ubyte[])((&header.fileVersion)[0..1]);
            headerBytes[8..12] = cast(ubyte[])((&header.blockSize)[0..1]);
            headerBytes[12..16] = cast(ubyte[])((&header.maxBlocks)[0..1]);
            headerBytes[16..20] = cast(ubyte[])((&header.freeBlocks)[0..1]);
            headerBytes[20..24] = cast(ubyte[])((&header.rootBlock)[0..1]);
            headerBytes[24..32] = cast(ubyte[])((&header.created)[0..1]);
            headerBytes[32..40] = cast(ubyte[])((&header.modified)[0..1]);
            file.rawWrite(headerBytes);
            
            // Write bitmap
            ubyte[128] bitmap;
            bitmap[] = 0;
            file.rawWrite(bitmap);
            
            file.close();
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    bool open() {
        try {
            auto file = File(path, "rb");
            
            // Read header
            ubyte[48] headerBytes;
            file.rawRead(headerBytes);
            
            header.magic = *(cast(uint*)&headerBytes[0]);
            header.fileVersion = *(cast(uint*)&headerBytes[4]);
            header.blockSize = *(cast(uint*)&headerBytes[8]);
            header.maxBlocks = *(cast(uint*)&headerBytes[12]);
            header.freeBlocks = *(cast(uint*)&headerBytes[16]);
            header.rootBlock = *(cast(uint*)&headerBytes[20]);
            header.created = *(cast(long*)&headerBytes[24]);
            header.modified = *(cast(long*)&headerBytes[32]);
            
            // Validate magic
            if (header.magic != 0x4D444246) {
                return false;
            }
            
            file.close();
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    bool saveDatabase(Database* db) {
        try {
            auto file = File(path, "wb");
            
            // Write header
            ubyte[48] headerBytes;
            headerBytes[0..4] = cast(ubyte[])((&header.magic)[0..1]);
            headerBytes[4..8] = cast(ubyte[])((&header.fileVersion)[0..1]);
            headerBytes[8..12] = cast(ubyte[])((&header.blockSize)[0..1]);
            headerBytes[12..16] = cast(ubyte[])((&header.maxBlocks)[0..1]);
            headerBytes[16..20] = cast(ubyte[])((&header.freeBlocks)[0..1]);
            headerBytes[20..24] = cast(ubyte[])((&header.rootBlock)[0..1]);
            headerBytes[24..32] = cast(ubyte[])((&header.created)[0..1]);
            headerBytes[32..40] = cast(ubyte[])((&header.modified)[0..1]);
            file.rawWrite(headerBytes);
            
            // Write globals
            foreach (name, entry; db.globals) {
                writeEntry(file, name, entry, []);
            }
            
            file.close();
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    private void writeEntry(File file, string name, DbEntry* entry, string[] path) {
        // Write entry type
        ubyte[1] type = [0]; // Global
        file.rawWrite(type);
        
        // Write name length
        ubyte[1] nameLen = [cast(ubyte)name.length];
        file.rawWrite(nameLen);
        
        // Write name
        ubyte[] nameBytes = cast(ubyte[])name;
        file.rawWrite(nameBytes);
        
        // Write value length
        ubyte[2] valueLen;
        valueLen[0] = cast(ubyte)(entry.value.length & 0xFF);
        valueLen[1] = cast(ubyte)((entry.value.length >> 8) & 0xFF);
        file.rawWrite(valueLen);
        
        // Write value
        if (entry.value.length > 0) {
            ubyte[] valueBytes = cast(ubyte[])entry.value;
            file.rawWrite(valueBytes);
        }
        
        // Write children
        foreach (childName, child; entry.children) {
            writeEntry(file, childName, child, path ~ name);
        }
    }

    bool loadDatabase(Database* db) {
        try {
            auto file = File(path, "rb");
            
            // Read header
            ubyte[48] headerBytes;
            file.rawRead(headerBytes);
            
            header.magic = *(cast(uint*)&headerBytes[0]);
            header.fileVersion = *(cast(uint*)&headerBytes[4]);
            header.blockSize = *(cast(uint*)&headerBytes[8]);
            header.maxBlocks = *(cast(uint*)&headerBytes[12]);
            header.freeBlocks = *(cast(uint*)&headerBytes[16]);
            header.rootBlock = *(cast(uint*)&headerBytes[20]);
            header.created = *(cast(long*)&headerBytes[24]);
            header.modified = *(cast(long*)&headerBytes[32]);
            
            // Validate magic
            if (header.magic != 0x4D444246) {
                return false;
            }
            
            // Read entries
            while (!file.eof()) {
                ubyte[1] type;
                if (file.rawRead(type).length == 0) break;
                
                ubyte[1] nameLen;
                file.rawRead(nameLen);
                
                ubyte[] nameBytes = new ubyte[nameLen[0]];
                file.rawRead(nameBytes);
                string name = cast(string)nameBytes;
                
                ubyte[2] valueLen;
                file.rawRead(valueLen);
                uint vLen = valueLen[0] | (valueLen[1] << 8);
                
                string value = "";
                if (vLen > 0) {
                    ubyte[] valueBytes = new ubyte[vLen];
                    file.rawRead(valueBytes);
                    value = cast(string)valueBytes;
                }
                
                // Set in database
                db.set(name, [], value);
            }
            
            file.close();
            return true;
        } catch (Exception e) {
            return false;
        }
    }

    bool exists() {
        return std.file.exists(path);
    }

    bool remove() {
        try {
            std.file.remove(path);
            return true;
        } catch (Exception e) {
            return false;
        }
    }
}

unittest {
    DatabasePersistence persist;
    persist.init("/tmp/test_md_db.dat");
    
    // Create database
    assert(persist.create());
    assert(persist.exists());
    
    // Clean up
    persist.remove();
    assert(!persist.exists());
}

unittest {
    Database db;
    db.set("TEST", [], "value1");
    db.set("TEST", ["sub1"], "value2");
    
    DatabasePersistence persist;
    persist.init("/tmp/test_md_db2.dat");
    
    // Save database
    assert(persist.saveDatabase(&db));
    
    // Load database
    Database db2;
    assert(persist.loadDatabase(&db2));
    
    assert(db2.get("TEST", []) == "value1");
    assert(db2.get("TEST", ["sub1"]) == "value2");
    
    // Clean up
    persist.remove();
}
