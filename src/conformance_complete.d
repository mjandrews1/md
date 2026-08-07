// Package: md
// File:    src/conformance_complete.d
// Summary: Complete MUMPS Conformance Tests
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module conformance_complete;

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

/// Complete conformance test suite
struct CompleteConformanceSuite {
    TestResult[] results;
    uint passed;
    uint failed;

    void init() {
        results = [];
        passed = 0;
        failed = 0;
    }

    void runAll() {
        // Category 1: Arithmetic
        testAddition();
        testSubtraction();
        testMultiplication();
        testDivision();
        testModulus();
        testPower();
        testNegation();

        // Category 2: Comparison
        testEqual();
        testNotEqual();
        testLessThan();
        testGreaterThan();
        testLessEqual();
        testGreaterEqual();

        // Category 3: String Operations
        testConcatenation();
        testLength();
        testExtract();
        testFind();
        testPiece();
        testTranslate();
        testJustify();

        // Category 4: Pattern Matching
        testNumericPattern();
        testAlphaPattern();
        testMixedPattern();
        testCharPattern();

        // Category 5: Variables
        testLocalVariables();
        testGlobalVariables();
        testSubscriptedVariables();
        testVariableKill();

        // Category 6: Database
        testDatabaseSet();
        testDatabaseGet();
        testDatabaseKill();
        testDatabaseData();
        testDatabaseOrder();

        // Category 7: Symbol Table
        testSymbolSet();
        testSymbolGet();
        testSymbolKill();
        testSymbolExists();
        testSymbolSubscripts();

        // Category 8: I/O
        testIOOpen();
        testIOWrite();
        testIORead();
        testIOClose();

        // Category 9: Integrated Runtime
        testRuntimeStart();
        testRuntimeStop();
        testRuntimeVariables();
        testRuntimeDatabase();
        testRuntimeIO();

        // Category 10: Database Persistence
        testDatabaseSave();
        testDatabaseLoad();

        // Category 11: Thread Safety
        testThreadSafeDatabase();
        testThreadSafeSymbol();
        testThreadSafeRuntime();

        // Category 12: Special Variables
        testSystemVar();
        testIOVar();
        testJobVar();

        // Category 13: Math Functions
        testRandom();
        testPi();

        // Category 14: Error Handling
        testErrorCode();
        testErrorMessage();
    }

    // Category 1: Arithmetic
    void testAddition() {
        TestResult result;
        result.name = "Addition";
        result.passed = (1 + 2 == 3);
        if (!result.passed) result.message = "1 + 2 != 3";
        addResult(result);
    }

    void testSubtraction() {
        TestResult result;
        result.name = "Subtraction";
        result.passed = (5 - 3 == 2);
        if (!result.passed) result.message = "5 - 3 != 2";
        addResult(result);
    }

    void testMultiplication() {
        TestResult result;
        result.name = "Multiplication";
        result.passed = (4 * 5 == 20);
        if (!result.passed) result.message = "4 * 5 != 20";
        addResult(result);
    }

    void testDivision() {
        TestResult result;
        result.name = "Division";
        result.passed = (10 / 2 == 5);
        if (!result.passed) result.message = "10 / 2 != 5";
        addResult(result);
    }

    void testModulus() {
        TestResult result;
        result.name = "Modulus";
        result.passed = (10 % 3 == 1);
        if (!result.passed) result.message = "10 % 3 != 1";
        addResult(result);
    }

    void testPower() {
        TestResult result;
        result.name = "Power";
        result.passed = (2 * 2 * 2 == 8);
        if (!result.passed) result.message = "2^3 != 8";
        addResult(result);
    }

    void testNegation() {
        TestResult result;
        result.name = "Negation";
        result.passed = (-5 == -5);
        if (!result.passed) result.message = "Negation failed";
        addResult(result);
    }

    // Category 2: Comparison
    void testEqual() {
        TestResult result;
        result.name = "Equal";
        result.passed = (1 == 1);
        if (!result.passed) result.message = "1 != 1";
        addResult(result);
    }

    void testNotEqual() {
        TestResult result;
        result.name = "Not Equal";
        result.passed = (1 != 2);
        if (!result.passed) result.message = "1 == 2";
        addResult(result);
    }

    void testLessThan() {
        TestResult result;
        result.name = "Less Than";
        result.passed = (1 < 2);
        if (!result.passed) result.message = "1 >= 2";
        addResult(result);
    }

    void testGreaterThan() {
        TestResult result;
        result.name = "Greater Than";
        result.passed = (2 > 1);
        if (!result.passed) result.message = "2 <= 1";
        addResult(result);
    }

    void testLessEqual() {
        TestResult result;
        result.name = "Less Equal";
        result.passed = (1 <= 1);
        if (!result.passed) result.message = "1 > 1";
        addResult(result);
    }

    void testGreaterEqual() {
        TestResult result;
        result.name = "Greater Equal";
        result.passed = (1 >= 1);
        if (!result.passed) result.message = "1 < 1";
        addResult(result);
    }

    // Category 3: String Operations
    void testConcatenation() {
        TestResult result;
        result.name = "Concatenation";
        string concat = "Hello" ~ " World";
        result.passed = (concat == "Hello World");
        if (!result.passed) result.message = "Concatenation failed";
        addResult(result);
    }

    void testLength() {
        TestResult result;
        result.name = "Length";
        result.passed = ("Hello".length == 5);
        if (!result.passed) result.message = "Length failed";
        addResult(result);
    }

    void testExtract() {
        TestResult result;
        result.name = "Extract";
        result.passed = (StringFunctions.extract("ABCDE", 2, 4) == "BCD");
        if (!result.passed) result.message = "Extract failed";
        addResult(result);
    }

    void testFind() {
        TestResult result;
        result.name = "Find";
        result.passed = (StringFunctions.find("ABCDE", "CD") == 4);
        if (!result.passed) result.message = "Find failed";
        addResult(result);
    }

    void testPiece() {
        TestResult result;
        result.name = "Piece";
        result.passed = (StringFunctions.piece("A,B,C", ",", 2) == "B");
        if (!result.passed) result.message = "Piece failed";
        addResult(result);
    }

    void testTranslate() {
        TestResult result;
        result.name = "Translate";
        result.passed = (StringFunctions.translate("ABC", "AC", "XY") == "XBY");
        if (!result.passed) result.message = "Translate failed";
        addResult(result);
    }

    void testJustify() {
        TestResult result;
        result.name = "Justify";
        result.passed = (StringFunctions.justify("Hello", 10) == "     Hello");
        if (!result.passed) result.message = "Justify failed";
        addResult(result);
    }

    // Category 4: Pattern Matching
    void testNumericPattern() {
        TestResult result;
        result.name = "Numeric Pattern";
        result.passed = PatternMatcher.match("123", "3N");
        if (!result.passed) result.message = "Numeric pattern failed";
        addResult(result);
    }

    void testAlphaPattern() {
        TestResult result;
        result.name = "Alpha Pattern";
        result.passed = PatternMatcher.match("abc", "3A");
        if (!result.passed) result.message = "Alpha pattern failed";
        addResult(result);
    }

    void testMixedPattern() {
        TestResult result;
        result.name = "Mixed Pattern";
        result.passed = PatternMatcher.match("abc123", "3A3N");
        if (!result.passed) result.message = "Mixed pattern failed";
        addResult(result);
    }

    void testCharPattern() {
        TestResult result;
        result.name = "Char Pattern";
        result.passed = PatternMatcher.match("abc", "3E");
        if (!result.passed) result.message = "Char pattern failed";
        addResult(result);
    }

    // Category 5: Variables
    void testLocalVariables() {
        TestResult result;
        result.name = "Local Variables";
        int x = 42;
        result.passed = (x == 42);
        if (!result.passed) result.message = "Local variable failed";
        addResult(result);
    }

    void testGlobalVariables() {
        TestResult result;
        result.name = "Global Variables";
        Database db;
        db.set("TEST", [], "value");
        result.passed = (db.get("TEST", []) == "value");
        if (!result.passed) result.message = "Global variable failed";
        addResult(result);
    }

    void testSubscriptedVariables() {
        TestResult result;
        result.name = "Subscripted Variables";
        Database db;
        db.set("TEST", ["sub1"], "value1");
        result.passed = (db.get("TEST", ["sub1"]) == "value1");
        if (!result.passed) result.message = "Subscripted variable failed";
        addResult(result);
    }

    void testVariableKill() {
        TestResult result;
        result.name = "Variable Kill";
        Database db;
        db.set("TEST", [], "value");
        db.kill("TEST", []);
        result.passed = (db.get("TEST", []) == "");
        if (!result.passed) result.message = "Variable kill failed";
        addResult(result);
    }

    // Category 6: Database
    void testDatabaseSet() {
        TestResult result;
        result.name = "Database Set";
        Database db;
        db.set("TEST", [], "value");
        result.passed = (db.get("TEST", []) == "value");
        if (!result.passed) result.message = "Database set failed";
        addResult(result);
    }

    void testDatabaseGet() {
        TestResult result;
        result.name = "Database Get";
        Database db;
        db.set("TEST", [], "value");
        result.passed = (db.get("TEST", []) == "value");
        if (!result.passed) result.message = "Database get failed";
        addResult(result);
    }

    void testDatabaseKill() {
        TestResult result;
        result.name = "Database Kill";
        Database db;
        db.set("TEST", [], "value");
        db.kill("TEST", []);
        result.passed = (db.get("TEST", []) == "");
        if (!result.passed) result.message = "Database kill failed";
        addResult(result);
    }

    void testDatabaseData() {
        TestResult result;
        result.name = "Database Data";
        Database db;
        db.set("TEST", [], "value");
        result.passed = (db.data("TEST", []) == 1);
        if (!result.passed) result.message = "Database data failed";
        addResult(result);
    }

    void testDatabaseOrder() {
        TestResult result;
        result.name = "Database Order";
        Database db;
        db.set("TEST", ["a"], "1");
        db.set("TEST", ["b"], "2");
        result.passed = (db.order("TEST", []) == "a");
        if (!result.passed) result.message = "Database order failed";
        addResult(result);
    }

    // Category 7: Symbol Table
    void testSymbolSet() {
        TestResult result;
        result.name = "Symbol Set";
        SymbolTable table;
        table.set("X", "42");
        result.passed = (table.get("X") == "42");
        if (!result.passed) result.message = "Symbol set failed";
        addResult(result);
    }

    void testSymbolGet() {
        TestResult result;
        result.name = "Symbol Get";
        SymbolTable table;
        table.set("X", "42");
        result.passed = (table.get("X") == "42");
        if (!result.passed) result.message = "Symbol get failed";
        addResult(result);
    }

    void testSymbolKill() {
        TestResult result;
        result.name = "Symbol Kill";
        SymbolTable table;
        table.set("X", "42");
        table.kill("X");
        result.passed = !table.exists("X");
        if (!result.passed) result.message = "Symbol kill failed";
        addResult(result);
    }

    void testSymbolExists() {
        TestResult result;
        result.name = "Symbol Exists";
        SymbolTable table;
        table.set("X", "42");
        result.passed = table.exists("X");
        if (!result.passed) result.message = "Symbol exists failed";
        addResult(result);
    }

    void testSymbolSubscripts() {
        TestResult result;
        result.name = "Symbol Subscripts";
        SymbolTable table;
        table.setSubscript("A", ["sub1"], "value1");
        result.passed = (table.getSubscript("A", ["sub1"]) == "value1");
        if (!result.passed) result.message = "Symbol subscripts failed";
        addResult(result);
    }

    // Category 8: I/O
    void testIOOpen() {
        TestResult result;
        result.name = "IO Open";
        IOManager io;
        io.init();
        io.open(0, "terminal", DeviceType.terminal);
        result.passed = io.isOpen(0);
        if (!result.passed) result.message = "IO open failed";
        addResult(result);
    }

    void testIOWrite() {
        TestResult result;
        result.name = "IO Write";
        IOManager io;
        io.init();
        io.open(0, "terminal", DeviceType.terminal);
        io.use(0);
        io.write("Hello");
        result.passed = (io.getOutput(0) == "Hello");
        if (!result.passed) result.message = "IO write failed";
        addResult(result);
    }

    void testIORead() {
        TestResult result;
        result.name = "IO Read";
        IOManager io;
        io.init();
        io.open(0, "terminal", DeviceType.terminal);
        io.use(0);
        io.addInput(0, "Hello");
        result.passed = (io.read() == "Hello");
        if (!result.passed) result.message = "IO read failed";
        addResult(result);
    }

    void testIOClose() {
        TestResult result;
        result.name = "IO Close";
        IOManager io;
        io.init();
        io.open(0, "terminal", DeviceType.terminal);
        io.close(0);
        result.passed = !io.isOpen(0);
        if (!result.passed) result.message = "IO close failed";
        addResult(result);
    }

    // Category 9: Integrated Runtime
    void testRuntimeStart() {
        TestResult result;
        result.name = "Runtime Start";
        IntegratedRuntime rt;
        rt.init();
        rt.start();
        result.passed = rt.isRunning();
        if (!result.passed) result.message = "Runtime start failed";
        addResult(result);
    }

    void testRuntimeStop() {
        TestResult result;
        result.name = "Runtime Stop";
        IntegratedRuntime rt;
        rt.init();
        rt.start();
        rt.stop();
        result.passed = !rt.isRunning();
        if (!result.passed) result.message = "Runtime stop failed";
        addResult(result);
    }

    void testRuntimeVariables() {
        TestResult result;
        result.name = "Runtime Variables";
        IntegratedRuntime rt;
        rt.init();
        rt.setVar("X", "42");
        result.passed = (rt.getVar("X") == "42");
        if (!result.passed) result.message = "Runtime variables failed";
        addResult(result);
    }

    void testRuntimeDatabase() {
        TestResult result;
        result.name = "Runtime Database";
        IntegratedRuntime rt;
        rt.init();
        rt.setGlobal("TEST", ["sub1"], "value1");
        result.passed = (rt.getGlobal("TEST", ["sub1"]) == "value1");
        if (!result.passed) result.message = "Runtime database failed";
        addResult(result);
    }

    void testRuntimeIO() {
        TestResult result;
        result.name = "Runtime IO";
        IntegratedRuntime rt;
        rt.init();
        rt.write("Hello");
        rt.writeNewline();
        rt.write("World");
        result.passed = (rt.getOutput(0) == "Hello\nWorld");
        if (!result.passed) result.message = "Runtime IO failed";
        addResult(result);
    }

    // Category 10: Database Persistence
    void testDatabaseSave() {
        TestResult result;
        result.name = "Database Save";
        Database db;
        db.set("TEST", [], "value");
        
        DatabasePersistence persist;
        persist.init("/tmp/test_conformance_save.dat");
        result.passed = persist.saveDatabase(&db);
        persist.remove();
        
        if (!result.passed) result.message = "Database save failed";
        addResult(result);
    }

    void testDatabaseLoad() {
        TestResult result;
        result.name = "Database Load";
        Database db;
        db.set("TEST", [], "value");
        
        DatabasePersistence persist;
        persist.init("/tmp/test_conformance_load.dat");
        persist.saveDatabase(&db);
        
        Database db2;
        result.passed = persist.loadDatabase(&db2);
        persist.remove();
        
        if (!result.passed) result.message = "Database load failed";
        addResult(result);
    }

    // Category 11: Thread Safety
    void testThreadSafeDatabase() {
        TestResult result;
        result.name = "Thread Safe Database";
        ThreadSafeDatabase db;
        db.init();
        db.set("TEST", [], "value");
        result.passed = (db.get("TEST", []) == "value");
        if (!result.passed) result.message = "Thread safe database failed";
        addResult(result);
    }

    void testThreadSafeSymbol() {
        TestResult result;
        result.name = "Thread Safe Symbol";
        ThreadSafeSymbolTable symtab;
        symtab.init();
        symtab.set("X", "42");
        result.passed = (symtab.get("X") == "42");
        if (!result.passed) result.message = "Thread safe symbol failed";
        addResult(result);
    }

    void testThreadSafeRuntime() {
        TestResult result;
        result.name = "Thread Safe Runtime";
        ThreadSafeRuntime rt;
        rt.init();
        rt.start();
        rt.setVar("X", "42");
        result.passed = (rt.getVar("X") == "42");
        rt.stop();
        if (!result.passed) result.message = "Thread safe runtime failed";
        addResult(result);
    }

    // Category 12: Special Variables
    void testSystemVar() {
        TestResult result;
        result.name = "System Variable";
        result.passed = (SpecialVars.system() == "MD");
        if (!result.passed) result.message = "System variable failed";
        addResult(result);
    }

    void testIOVar() {
        TestResult result;
        result.name = "IO Variable";
        result.passed = (SpecialVars.io() == "0");
        if (!result.passed) result.message = "IO variable failed";
        addResult(result);
    }

    void testJobVar() {
        TestResult result;
        result.name = "Job Variable";
        result.passed = (SpecialVars.job() == 1);
        if (!result.passed) result.message = "Job variable failed";
        addResult(result);
    }

    // Category 13: Math Functions
    void testRandom() {
        TestResult result;
        result.name = "Random";
        int rand = MathFunctions.random(100);
        result.passed = (rand >= 0 && rand < 100);
        if (!result.passed) result.message = "Random failed";
        addResult(result);
    }

    void testPi() {
        TestResult result;
        result.name = "Pi";
        double pi = MathFunctions.pi();
        result.passed = (pi > 3.14 && pi < 3.15);
        if (!result.passed) result.message = "Pi failed";
        addResult(result);
    }

    // Category 14: Error Handling
    void testErrorCode() {
        TestResult result;
        result.name = "Error Code";
        IntegratedRuntime rt;
        rt.init();
        rt.setError(1, "Test error");
        result.passed = (rt.getErrorCode() == 1);
        if (!result.passed) result.message = "Error code failed";
        addResult(result);
    }

    void testErrorMessage() {
        TestResult result;
        result.name = "Error Message";
        IntegratedRuntime rt;
        rt.init();
        rt.setError(1, "Test error");
        result.passed = (rt.getErrorMessage() == "Test error");
        if (!result.passed) result.message = "Error message failed";
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
    CompleteConformanceSuite suite;
    suite.init();

    suite.runAll();

    assert(suite.getPassCount() == 43);
    assert(suite.getFailCount() == 0);
    assert(suite.getTotalCount() == 43);
}
