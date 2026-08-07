// Package: md
// File:    src/io.d
// Summary: MUMPS I/O Operations
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module io;

import std.stdio;
import std.string;
import std.conv;

/// I/O Device types
enum DeviceType {
    terminal,
    file,
    socket,
    pipe,
}

/// I/O Device
struct Device {
    int id;
    string name;
    DeviceType type;
    bool open;
    string inputBuffer;
    string outputBuffer;
    int x;
    int y;
}

/// I/O Manager
struct IOManager {
    Device[64] devices;
    int currentDevice = 0;

    void init() {
        for (int i = 0; i < 64; i++) {
            devices[i].id = -1;
            devices[i].open = false;
        }
    }

    int open(int id, string name, DeviceType type) {
        if (id < 0 || id >= 64) return -1;
        
        devices[id].id = id;
        devices[id].name = name;
        devices[id].type = type;
        devices[id].open = true;
        devices[id].x = 0;
        devices[id].y = 0;
        
        return id;
    }

    void close(int id) {
        if (id < 0 || id >= 64) return;
        devices[id].id = -1;
        devices[id].open = false;
    }

    void use(int id) {
        if (id < 0 || id >= 64) return;
        currentDevice = id;
    }

    void write(string data) {
        if (currentDevice < 0 || currentDevice >= 64) return;
        if (!devices[currentDevice].open) return;
        
        devices[currentDevice].outputBuffer ~= data;
        
        // Update cursor position
        foreach (c; data) {
            if (c == '\n') {
                devices[currentDevice].x = 0;
                devices[currentDevice].y++;
            } else if (c == '\r') {
                devices[currentDevice].x = 0;
            } else {
                devices[currentDevice].x++;
            }
        }
    }

    void writeNewline() {
        write("\n");
    }

    void writeFormFeed() {
        write("\x0C");
    }

    void writeTab(int col) {
        while (devices[currentDevice].x < col) {
            write(" ");
        }
    }

    void writeStar(char c) {
        write([c]);
    }

    string read(int timeout = 0) {
        if (currentDevice < 0 || currentDevice >= 64) return "";
        if (!devices[currentDevice].open) return "";
        
        auto result = devices[currentDevice].inputBuffer;
        devices[currentDevice].inputBuffer = "";
        return result;
    }

    char readStar(int timeout = 0) {
        if (currentDevice < 0 || currentDevice >= 64) return 0;
        if (!devices[currentDevice].open) return 0;
        
        if (devices[currentDevice].inputBuffer.length > 0) {
            auto c = devices[currentDevice].inputBuffer[0];
            devices[currentDevice].inputBuffer = devices[currentDevice].inputBuffer[1 .. $];
            return c;
        }
        
        return 0;
    }

    void addInput(int id, string data) {
        if (id < 0 || id >= 64) return;
        devices[id].inputBuffer ~= data;
    }

    string getOutput(int id) {
        if (id < 0 || id >= 64) return "";
        return devices[id].outputBuffer;
    }

    void clearOutput(int id) {
        if (id < 0 || id >= 64) return;
        devices[id].outputBuffer = "";
    }

    bool isOpen(int id) {
        if (id < 0 || id >= 64) return false;
        return devices[id].open;
    }

    int getCurrentDevice() {
        return currentDevice;
    }

    int getX(int id) {
        if (id < 0 || id >= 64) return 0;
        return devices[id].x;
    }

    int getY(int id) {
        if (id < 0 || id >= 64) return 0;
        return devices[id].y;
    }

    void setPosition(int id, int x, int y) {
        if (id < 0 || id >= 64) return;
        devices[id].x = x;
        devices[id].y = y;
    }

    DeviceType getMode(int id) {
        if (id < 0 || id >= 64) return DeviceType.terminal;
        return devices[id].type;
    }

    void setMode(int id, DeviceType mode) {
        if (id < 0 || id >= 64) return;
        devices[id].type = mode;
    }
}

unittest {
    IOManager io;
    io.init();
    
    io.open(0, "terminal", DeviceType.terminal);
    assert(io.isOpen(0));
    
    io.use(0);
    io.write("Hello");
    io.writeNewline();
    io.write("World");
    
    assert(io.getOutput(0) == "Hello\nWorld");
    
    io.close(0);
    assert(!io.isOpen(0));
}

unittest {
    IOManager io;
    io.init();
    
    io.open(0, "terminal", DeviceType.terminal);
    io.use(0);
    
    io.write("Hello");
    assert(io.getX(0) == 5);
    assert(io.getY(0) == 0);
    
    io.writeNewline();
    assert(io.getX(0) == 0);
    assert(io.getY(0) == 1);
}

unittest {
    IOManager io;
    io.init();
    
    io.open(0, "terminal", DeviceType.terminal);
    io.use(0);
    io.addInput(0, "Hello");
    
    auto result = io.read();
    assert(result == "Hello");
}
