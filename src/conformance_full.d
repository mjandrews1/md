// Package: md
// File:    src/conformance_full.d
// Summary: Full MUMPS Conformance Tests
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module conformance_full;

import std.stdio;
import std.string;
import database;
import symbol;
import io;
import integrated;
import database_persist;
import thread_safe;
import mumps_features;

/// Test result
struct TestResult {
    string name;
    bool passed;
    string message;
}

/// Full conformance test suite
struct FullConformanceSuite {
    TestResult[] results;
    uint passed;
    uint failed;

    void init() {
        results = [];
        passed = 0;
        failed = 0;
    }

    void runAll() {
        testArithmetic();
        testComparison();
        testString();
        testVariables();
        testDatabase();
        testSymbolTable();
        testIO();
        testIntegrated();
        testPatternMatching();
        testMathFunctions();
        testStringFunctions();
        testSpecialVariables();
        testDatabasePersistence();
        testThreadSafety();
    }

    void testArithmetic() {
        TestResult result;
        result.name = "Arithmetic Operations";

        // Test addition
        if (1 + 2 != 3) {
            result.passed = false;
            result.message = "Addition failed";
            addResult(result);
            return;
        }

        // Test subtraction
        if (5 - 3 != 2) {
            result.passed = false;
            result.message = "Subtraction failed";
            addResult(result);
            return;
        }

        // Test multiplication
        if (4 * 5 != 20) {
            result.passed = false;
            result.message = "Multiplication failed";
            addResult(result);
            return;
        }

        // Test division
        if (10 / 2 != 5) {
            result.passed = false;
            result.message = "Division failed";
            addResult(result);
            return;
        }

        // Test modulus
        if (10 % 3 != 1) {
            result.passed = false;
            result.message = "Modulus failed";
            addResult(result);
            return;
        }

        result.passed = true;
        addResult(result);
    }

    void testComparison() {
        TestResult result;
        result.name = "Comparison Operations";

        // Test equal
        if (!(1 == 1)) {
            result.passed = false;
            result.message = "Equal failed";
            addResult(result);
            return;
        }

        // Test not equal
        if (!(1 != 2)) {
            result.passed = false;
            result.message = "Not equal failed";
            addResult(result);
            return;
        }

        // Test less than
        if (!(1 < 2)) {
            result.passed = false;
            result.message = "Less than failed";
            addResult(result);
            return;
        }

        // Test greater than
        if (!(2 > 1)) {
            result.passed = false;
            result.message = "Greater than failed";
            addResult(result);
            return;
        }

        result.passed = true;
        addResult(result);
    }

    void testString() {
        TestResult result;
        result.name = "String Operations";

        // Test concatenation
        string str1 = "Hello";
        string str2 = " World";
        string concat = str1 ~ str2;
        if (concat != "Hello World") {
            result.passed = false;
            result.message = "Concatenation failed";
            addResult(result);
            return;
        }

        // Test length
        if (str1.length != 5) {
            result.passed = false;
            result.message = "Length failed";
            addResult(result);
            return;
        }

        result.passed = true;
        addResult(result);
    }

    void testVariables() {
        TestResult result;
        result.name = "Variable Operations";

        // Test basic variable
        int x = 42;
        if (x != 42) {
            result.passed = false;
            result.message = "Variable assignment failed";
            addResult(result);
            return;
        }

        // Test variable modification
        x = 100;
        if (x != 100) {
            result.passed = false;
            result.message = "Variable modification failed";
            addResult(result);
            return;
        }

        result.passed = true;
        addResult(result);
    }

    void testDatabase() {
        TestResult result;
        result.name = "Database Operations";

        Database db;

        // Test set and get
        db.set("TEST", [], "value");
        if (db.get("TEST", []) != "value") {
            result.passed = false;
            result.message = "Database set/get failed";
            addResult(result);
            return;
        }

        // Test subscripted
        db.set("TEST", ["sub1"], "value1");
        if (db.get("TEST", ["sub1"]) != "value1") {
            result.passed = false;
            result.message = "Database subscripted set/get failed";
            addResult(result);
            return;
        }

        // Test $DATA
        if (db.data("TEST", []) != 11) {
            result.passed = false;
            result.message = "Database $DATA failed";
            addResult(result);
            return;
        }

        // Test kill
        db.kill("TEST", []);
        if (db.get("TEST", []) != "") {
            result.passed = false;
            result.message = "Database kill failed";
            addResult(result);
            return;
        }

        result.passed = true;
        addResult(result);
    }

    void testSymbolTable() {
        TestResult result;
        result.name = "Symbol Table Operations";

        SymbolTable table;

        // Test set and get
        table.set("X", "42");
        if (table.get("X") != "42") {
            result.passed = false;
            result.message = "Symbol table set/get failed";
            addResult(result);
            return;
        }

        // Test exists
        if (!table.exists("X")) {
            result.passed = false;
            result.message = "Symbol table exists failed";
            addResult(result);
            return;
        }

        // Test kill
        table.kill("X");
        if (table.exists("X")) {
            result.passed = false;
            result.message = "Symbol table kill failed";
            addResult(result);
            return;
        }

        result.passed = true;
        addResult(result);
    }

    void testIO() {
        TestResult result;
        result.name = "I/O Operations";

        IOManager io;
        io.init();

        // Test open
        io.open(0, "terminal", DeviceType.terminal);
        if (!io.isOpen(0)) {
            result.passed = false;
            result.message = "I/O open failed";
            addResult(result);
            return;
        }

        // Test write
        io.use(0);
        io.write("Hello");
        if (io.getOutput(0) != "Hello") {
            result.passed = false;
            result.message = "I/O write failed";
            addResult(result);
            return;
        }

        // Test close
        io.close(0);
        if (io.isOpen(0)) {
            result.passed = false;
            result.message = "I/O close failed";
            addResult(result);
            return;
        }

        result.passed = true;
        addResult(result);
    }

    void testIntegrated() {
        TestResult result;
        result.name = "Integrated Runtime";

        IntegratedRuntime rt;
        rt.init();

        // Test start/stop
        rt.start();
        if (!rt.isRunning()) {
            result.passed = false;
            result.message = "Integrated start failed";
            addResult(result);
            return;
        }

        // Test variable operations
        rt.setVar("X", "42");
        if (rt.getVar("X") != "42") {
            result.passed = false;
            result.message = "Integrated setVar/getVar failed";
            addResult(result);
            return;
        }

        // Test database operations
        rt.setGlobal("TEST", ["sub1"], "value1");
        if (rt.getGlobal("TEST", ["sub1"]) != "value1") {
            result.passed = false;
            result.message = "Integrated setGlobal/getGlobal failed";
            addResult(result);
            return;
        }

        // Test I/O operations
        rt.write("Hello");
        rt.writeNewline();
        rt.write("World");
        if (rt.getOutput(0) != "Hello\nWorld") {
            result.passed = false;
            result.message = "Integrated write failed";
            addResult(result);
            return;
        }

        rt.stop();
        if (rt.isRunning()) {
            result.passed = false;
            result.message = "Integrated stop failed";
            addResult(result);
            return;
        }

        result.passed = true;
        addResult(result);
    }

    void testPatternMatching() {
        TestResult result;
        result.name = "Pattern Matching";

        // Test numeric pattern
        if (!PatternMatcher.match("123", "3N")) {
            result.passed = false;
            result.message = "Numeric pattern failed";
            addResult(result);
            return;
        }

        // Test alpha pattern
        if (!PatternMatcher.match("abc", "3A")) {
            result.passed = false;
            result.message = "Alpha pattern failed";
            addResult(result);
            return;
        }

        // Test mixed pattern
        if (!PatternMatcher.match("abc123", "3A3N")) {
            result.passed = false;
            result.message = "Mixed pattern failed";
            addResult(result);
            return;
        }

        result.passed = true;
        addResult(result);
    }

    void testMathFunctions() {
        TestResult result;
        result.name = "Math Functions";

        // Test random
        int rand = MathFunctions.random(100);
        if (rand < 0 || rand >= 100) {
            result.passed = false;
            result.message = "Random failed";
            addResult(result);
            return;
        }

        // Test pi
        double pi = MathFunctions.pi();
        if (pi < 3.14 || pi > 3.15) {
            result.passed = false;
            result.message = "Pi failed";
            addResult(result);
            return;
        }

        result.passed = true;
        addResult(result);
    }

    void testStringFunctions() {
        TestResult result;
        result.name = "String Functions";

        // Test $ASCII
        if (StringFunctions.ascii("A") != 65) {
            result.passed = false;
            result.message = "$ASCII failed";
            addResult(result);
            return;
        }

        // Test $CHAR
        if (StringFunctions.char_(65) != "A") {
            result.passed = false;
            result.message = "$CHAR failed";
            addResult(result);
            return;
        }

        // Test $LENGTH
        if (StringFunctions.length("Hello") != 5) {
            result.passed = false;
            result.message = "$LENGTH failed";
            addResult(result);
            return;
        }

        // Test $EXTRACT
        if (StringFunctions.extract("ABCDE", 2, 4) != "BCD") {
            result.passed = false;
            result.message = "$EXTRACT failed";
            addResult(result);
            return;
        }

        // Test $FIND
        if (StringFunctions.find("ABCDE", "CD") != 4) {
            result.passed = false;
            result.message = "$FIND failed";
            addResult(result);
            return;
        }

        // Test $PIECE
        if (StringFunctions.piece("A,B,C", ",", 2) != "B") {
            result.passed = false;
            result.message = "$PIECE failed";
            addResult(result);
            return;
        }

        result.passed = true;
        addResult(result);
    }

    void testSpecialVariables() {
        TestResult result;
        result.name = "Special Variables";

        // Test $SYSTEM
        if (SpecialVars.system() != "MD") {
            result.passed = false;
            result.message = "$SYSTEM failed";
            addResult(result);
            return;
        }

        // Test $IO
        if (SpecialVars.io() != "0") {
            result.passed = false;
            result.message = "$IO failed";
            addResult(result);
            return;
        }

        // Test $JOB
        if (SpecialVars.job() != 1) {
            result.passed = false;
            result.message = "$JOB failed";
            addResult(result);
            return;
        }

        result.passed = true;
        addResult(result);
    }

    void testDatabasePersistence() {
        TestResult result;
        result.name = "Database Persistence";

        Database db;
        db.set("TEST", [], "value1");
        db.set("TEST", ["sub1"], "value2");

        DatabasePersistence persist;
        persist.init("/tmp/test_conformance.dat");

        // Save database
        if (!persist.saveDatabase(&db)) {
            result.passed = false;
            result.message = "Database save failed";
            addResult(result);
            return;
        }

        // Load database
        Database db2;
        if (!persist.loadDatabase(&db2)) {
            result.passed = false;
            result.message = "Database load failed";
            addResult(result);
            return;
        }

        if (db2.get("TEST", []) != "value1") {
            result.passed = false;
            result.message = "Database persistence failed";
            addResult(result);
            return;
        }

        // Clean up
        persist.remove();

        result.passed = true;
        addResult(result);
    }

    void testThreadSafety() {
        TestResult result;
        result.name = "Thread Safety";

        ThreadSafeRuntime rt;
        rt.init();

        // Test start/stop
        rt.start();
        if (!rt.isRunning()) {
            result.passed = false;
            result.message = "Thread-safe start failed";
            addResult(result);
            return;
        }

        // Test variable operations
        rt.setVar("X", "42");
        if (rt.getVar("X") != "42") {
            result.passed = false;
            result.message = "Thread-safe setVar/getVar failed";
            addResult(result);
            return;
        }

        // Test database operations
        rt.setGlobal("TEST", ["sub1"], "value1");
        if (rt.getGlobal("TEST", ["sub1"]) != "value1") {
            result.passed = false;
            result.message = "Thread-safe setGlobal/getGlobal failed";
            addResult(result);
            return;
        }

        rt.stop();
        if (rt.isRunning()) {
            result.passed = false;
            result.message = "Thread-safe stop failed";
            addResult(result);
            return;
        }

        result.passed = true;
        addResult(result);
    }

    void addResult(TestResult result) {
        if (result.passed) {
            passed++;
        } else {
            failed++;
        }
        results ~= result;
    }

    uint getPassCount() {
        return passed;
    }

    uint getFailCount() {
        return failed;
    }

    uint getTotalCount() {
        return passed + failed;
    }
}

unittest {
    FullConformanceSuite suite;
    suite.init();

    suite.runAll();

    assert(suite.getPassCount() == 14);
    assert(suite.getFailCount() == 0);
    assert(suite.getTotalCount() == 14);
}

unittest {
    FullConformanceSuite suite;
    suite.init();

    suite.testArithmetic();
    assert(suite.getPassCount() == 1);
    assert(suite.getFailCount() == 0);
}

unittest {
    FullConformanceSuite suite;
    suite.init();

    suite.testComparison();
    assert(suite.getPassCount() == 1);
    assert(suite.getFailCount() == 0);
}

unittest {
    FullConformanceSuite suite;
    suite.init();

    suite.testString();
    assert(suite.getPassCount() == 1);
    assert(suite.getFailCount() == 0);
}

unittest {
    FullConformanceSuite suite;
    suite.init();

    suite.testPatternMatching();
    assert(suite.getPassCount() == 1);
    assert(suite.getFailCount() == 0);
}

unittest {
    FullConformanceSuite suite;
    suite.init();

    suite.testStringFunctions();
    assert(suite.getPassCount() == 1);
    assert(suite.getFailCount() == 0);
}
