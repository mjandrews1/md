// Package: md
// File:    src/benchmark.d
// Summary: Performance Benchmarks
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module benchmark;

import std.stdio;
import std.string;
import std.datetime;
import database;
import database_optimized;
import symbol;
import io;
import integrated;

/// Benchmark result
struct BenchmarkResult {
    string name;
    long iterations;
    long elapsed_ms;
    double ops_per_second;
}

/// Performance benchmark suite
struct BenchmarkSuite {
    BenchmarkResult[] results;

    void init() {
        results = [];
    }

    void runAll() {
        benchmarkDatabaseSet();
        benchmarkDatabaseGet();
        benchmarkDatabaseKill();
        benchmarkDatabaseOrder();
        benchmarkSymbolSet();
        benchmarkSymbolGet();
        benchmarkIO();
        benchmarkIntegrated();
    }

    void benchmarkDatabaseSet() {
        BenchmarkResult result;
        result.name = "Database SET";
        result.iterations = 100000;

        Database db;
        auto start = Clock.currTime();

        for (long i = 0; i < result.iterations; i++) {
            db.set("TEST", ["sub1"], "value");
        }

        auto end = Clock.currTime();
        result.elapsed_ms = (end - start).total!"msecs";
        result.ops_per_second = cast(double)result.iterations / (cast(double)result.elapsed_ms / 1000.0);

        results ~= result;
    }

    void benchmarkDatabaseGet() {
        BenchmarkResult result;
        result.name = "Database GET";
        result.iterations = 100000;

        Database db;
        db.set("TEST", ["sub1"], "value");

        auto start = Clock.currTime();

        for (long i = 0; i < result.iterations; i++) {
            auto val = db.get("TEST", ["sub1"]);
            assert(val == "value");
        }

        auto end = Clock.currTime();
        result.elapsed_ms = (end - start).total!"msecs";
        result.ops_per_second = cast(double)result.iterations / (cast(double)result.elapsed_ms / 1000.0);

        results ~= result;
    }

    void benchmarkDatabaseKill() {
        BenchmarkResult result;
        result.name = "Database KILL";
        result.iterations = 100000;

        auto start = Clock.currTime();

        for (long i = 0; i < result.iterations; i++) {
            Database db;
            db.set("TEST", [], "value");
            db.kill("TEST", []);
        }

        auto end = Clock.currTime();
        result.elapsed_ms = (end - start).total!"msecs";
        result.ops_per_second = cast(double)result.iterations / (cast(double)result.elapsed_ms / 1000.0);

        results ~= result;
    }

    void benchmarkDatabaseOrder() {
        BenchmarkResult result;
        result.name = "Database ORDER";
        result.iterations = 100000;

        Database db;
        db.set("TEST", ["a"], "1");
        db.set("TEST", ["b"], "2");
        db.set("TEST", ["c"], "3");

        auto start = Clock.currTime();

        for (long i = 0; i < result.iterations; i++) {
            auto val = db.order("TEST", []);
            assert(val == "a");
        }

        auto end = Clock.currTime();
        result.elapsed_ms = (end - start).total!"msecs";
        result.ops_per_second = cast(double)result.iterations / (cast(double)result.elapsed_ms / 1000.0);

        results ~= result;
    }

    void benchmarkSymbolSet() {
        BenchmarkResult result;
        result.name = "Symbol SET";
        result.iterations = 100000;

        SymbolTable table;

        auto start = Clock.currTime();

        for (long i = 0; i < result.iterations; i++) {
            table.set("X", "value");
        }

        auto end = Clock.currTime();
        result.elapsed_ms = (end - start).total!"msecs";
        result.ops_per_second = cast(double)result.iterations / (cast(double)result.elapsed_ms / 1000.0);

        results ~= result;
    }

    void benchmarkSymbolGet() {
        BenchmarkResult result;
        result.name = "Symbol GET";
        result.iterations = 100000;

        SymbolTable table;
        table.set("X", "value");

        auto start = Clock.currTime();

        for (long i = 0; i < result.iterations; i++) {
            auto val = table.get("X");
            assert(val == "value");
        }

        auto end = Clock.currTime();
        result.elapsed_ms = (end - start).total!"msecs";
        result.ops_per_second = cast(double)result.iterations / (cast(double)result.elapsed_ms / 1000.0);

        results ~= result;
    }

    void benchmarkIO() {
        BenchmarkResult result;
        result.name = "IO Write";
        result.iterations = 100000;

        IOManager io;
        io.init();
        io.open(0, "terminal", DeviceType.terminal);
        io.use(0);

        auto start = Clock.currTime();

        for (long i = 0; i < result.iterations; i++) {
            io.write("Hello");
        }

        auto end = Clock.currTime();
        result.elapsed_ms = (end - start).total!"msecs";
        result.ops_per_second = cast(double)result.iterations / (cast(double)result.elapsed_ms / 1000.0);

        results ~= result;
    }

    void benchmarkIntegrated() {
        BenchmarkResult result;
        result.name = "Integrated Runtime";
        result.iterations = 100000;

        IntegratedRuntime rt;
        rt.init();
        rt.start();

        auto start = Clock.currTime();

        for (long i = 0; i < result.iterations; i++) {
            rt.setVar("X", "value");
            auto val = rt.getVar("X");
            assert(val == "value");
        }

        auto end = Clock.currTime();
        result.elapsed_ms = (end - start).total!"msecs";
        result.ops_per_second = cast(double)result.iterations / (cast(double)result.elapsed_ms / 1000.0);

        rt.stop();
        results ~= result;
    }

    void printResults() {
        writeln("Performance Benchmark Results:");
        writeln("=============================");
        writeln();
        writeln("Benchmark            | Iterations | Time (ms) | Ops/sec");
        writeln("---------------------|------------|-----------|--------");
        
        foreach (ref result; results) {
            writefln("%-20s | %10d | %9d | %10.0f", 
                result.name, result.iterations, result.elapsed_ms, result.ops_per_second);
        }
    }

    BenchmarkResult[] getResults() {
        return results;
    }
}

unittest {
    BenchmarkSuite suite;
    suite.init();
    
    suite.benchmarkDatabaseSet();
    assert(suite.getResults().length == 1);
    assert(suite.getResults()[0].iterations == 100000);
}

unittest {
    BenchmarkSuite suite;
    suite.init();
    
    suite.benchmarkSymbolSet();
    assert(suite.getResults().length == 1);
    assert(suite.getResults()[0].iterations == 100000);
}
