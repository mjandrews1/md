// Package: md
// File:    src/mumps_features.d
// Summary: MUMPS Additional Features
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module mumps_features;

import std.stdio;
import std.string;
import std.ascii;
import std.conv;

/// Pattern matching
struct PatternMatcher {
    static bool match(string str, string pattern) {
        return matchPattern(str, 0, pattern, 0);
    }

    private static bool matchPattern(string str, size_t si, string pattern, size_t pi) {
        // Base cases
        if (pi >= pattern.length) {
            return si >= str.length;
        }

        if (si >= str.length) {
            // Check if remaining pattern is optional
            while (pi < pattern.length) {
                if (pattern[pi] == '.' || pattern[pi] == '*') {
                    pi++;
                } else {
                    return false;
                }
            }
            return true;
        }

        // Get count
        int minCount = 0;
        int maxCount = int.max;
        size_t newPi = pi;

        if (pattern[pi] >= '0' && pattern[pi] <= '9') {
            minCount = pattern[pi] - '0';
            maxCount = minCount;
            newPi++;
        }

        if (newPi < pattern.length && pattern[newPi] == '.') {
            newPi++;
            maxCount = int.max;
        }

        if (newPi < pattern.length && pattern[newPi] >= '0' && pattern[newPi] <= '9') {
            maxCount = pattern[newPi] - '0';
            newPi++;
        }

        // Get pattern code
        if (newPi >= pattern.length) return false;
        char code = pattern[newPi];
        newPi++;

        // Match characters
        int matched = 0;
        while (si < str.length && matched < maxCount) {
            if (matchesCode(str[si], code)) {
                si++;
                matched++;
            } else {
                break;
            }
        }

        if (matched < minCount) return false;

        // Try to match remaining
        return matchPattern(str, si, pattern, newPi);
    }

    private static bool matchesCode(char c, char code) {
        switch (code) {
            case 'A':
            case 'a':
                return isAlpha(c);
            case 'N':
            case 'n':
                return isDigit(c);
            case 'E':
            case 'e':
                return true;
            case 'U':
            case 'u':
                return isUpper(c);
            case 'L':
            case 'l':
                return isLower(c);
            case 'P':
            case 'p':
                return isPunctuation(c);
            case 'C':
            case 'c':
                return !isPrintable(c);
            default:
                return false;
        }
    }
}

/// Math functions
struct MathFunctions {
    static int random(int max) {
        if (max <= 0) return 0;
        // Simple pseudo-random number generator
        static int seed = 12345;
        seed = (seed * 1103515245 + 12345) & 0x7fffffff;
        return seed % max;
    }

    static double pi() {
        return 3.141592653589793;
    }
}

/// Special variables
struct SpecialVars {
    static string horolog() {
        // Simplified - return placeholder
        return "0,0";
    }

    static string io() {
        return "0";
    }

    static int job() {
        return 1;
    }

    static string system() {
        return "MD";
    }

    static int storage() {
        return 1000000;
    }
}

/// String functions
struct StringFunctions {
    static int ascii(string str, int pos = 1) {
        if (pos < 1 || pos > str.length) return -1;
        return cast(int)str[pos - 1];
    }

    static string char_(int code) {
        if (code < 0 || code > 255) return "";
        return [cast(char)code];
    }

    static int length(string str) {
        return cast(int)str.length;
    }

    static string extract(string str, int start, int end = -1) {
        if (start < 1 || start > str.length) return "";
        if (end == -1) end = start;
        if (end < start || end > str.length) return "";
        return str[start - 1 .. end];
    }

    static int find(string str, string substr, int start = 1) {
        if (start < 1 || start > str.length) return 0;
        auto pos = str[start - 1 .. $].indexOf(substr);
        if (pos == -1) return 0;
        return cast(int)(start + pos + substr.length);
    }

    static string piece(string str, string delim, int piece, int endPiece = -1) {
        if (endPiece == -1) endPiece = piece;
        
        auto parts = str.split(delim);
        if (piece < 1 || piece > parts.length) return "";
        if (endPiece > parts.length) endPiece = cast(int)parts.length;
        
        string result = "";
        for (int i = piece - 1; i < endPiece; i++) {
            if (result.length > 0) result ~= delim;
            result ~= parts[i];
        }
        return result;
    }

    static string translate(string str, string from, string to = "") {
        string result = "";
        foreach (c; str) {
            auto pos = from.indexOf(c);
            if (pos == -1) {
                result ~= c;
            } else if (pos < to.length) {
                result ~= to[pos];
            }
        }
        return result;
    }

    static string justify(string str, int width) {
        if (width <= 0) return "";
        if (str.length >= width) return str;
        string result = "";
        for (size_t i = 0; i < width - str.length; i++) {
            result ~= " ";
        }
        result ~= str;
        return result;
    }
}

unittest {
    assert(PatternMatcher.match("123", "3N"));
    assert(PatternMatcher.match("abc", "3A"));
    assert(!PatternMatche.match("abc", "3N"));
    assert(PatternMatche.match("abc123", "3A3N"));
}

unittest {
    assert(StringFunctions.ascii("A") == 65);
    assert(StringFunctions.ascii("ABC", 2) == 66);
    assert(StringFunctions.char_(65) == "A");
    assert(StringFunctions.length("Hello") == 5);
    assert(StringFunctions.extract("ABCDE", 2, 4) == "BCD");
    assert(StringFunctions.find("ABCDE", "CD") == 4);
    assert(StringFunctions.piece("A,B,C", ",", 2) == "B");
    assert(StringFunctions.translate("ABC", "AC", "XY") == "XBY");
    assert(StringFunctions.justify("Hello", 10) == "     Hello");
}

unittest {
    assert(SpecialVars.system() == "MD");
    assert(SpecialVars.io() == "0");
    assert(SpecialVars.job() == 1);
}
