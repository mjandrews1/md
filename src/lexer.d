// Package: md
// File:    src/lexer.d
// Summary: MUMPS Lexer (Tokenization)
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module lexer;

import std.stdio;
import std.string;
import std.ascii;

/// Token types
enum TokenType {
    // Literals
    identifier,
    number_literal,
    string_literal,

    // Commands
    cmd_break,
    cmd_close,
    cmd_do,
    cmd_else,
    cmd_for,
    cmd_goto,
    cmd_halt,
    cmd_hang,
    cmd_if,
    cmd_job,
    cmd_kill,
    cmd_lock,
    cmd_merge,
    cmd_new,
    cmd_open,
    cmd_quit,
    cmd_read,
    cmd_set,
    cmd_use,
    cmd_view,
    cmd_write,
    cmd_xecute,

    // Operators
    plus,
    minus,
    star,
    slash,
    backslash,
    hash,
    starstar,
    equal,
    not_equal,
    less_than,
    greater_than,
    less_equal,
    greater_equal,
    rbracket,
    lbracket,
    rbracket2,
    lbracket2,
    bang,
    ampersand,
    squote,
    question,
    at,
    underscore,

    // Delimiters
    lparen,
    rparen,
    comma,
    colon,
    semicolon,
    dollardollar,

    // Special
    space,
    newline,
    eof,
    illegal,
}

/// Token
struct Token {
    TokenType type;
    string literal;
    size_t pos;
    size_t line;
    size_t column;
}

/// Lexer
struct Lexer {
    string source;
    size_t pos;
    size_t line;
    size_t column;

    static Lexer create(string source) {
        Lexer lexer;
        lexer.source = source;
        lexer.pos = 0;
        lexer.line = 1;
        lexer.column = 1;
        return lexer;
    }

    Token nextToken() {
        skipWhitespace();

        if (pos >= source.length) {
            return Token(TokenType.eof, "", pos, line, column);
        }

        auto c = source[pos];

        // Newline
        if (c == '\n') {
            pos++;
            line++;
            column = 1;
            return Token(TokenType.newline, "\n", pos - 1, line - 1, column);
        }

        // Comment
        if (c == ';') {
            while (pos < source.length && source[pos] != '\n') {
                pos++;
            }
            return nextToken();
        }

        // String literal
        if (c == '"') {
            return readString();
        }

        // Number
        if (isDigit(c)) {
            return readNumber();
        }

        // Identifier or command
        if (isAlpha(c) || c == '^' || c == '%') {
            return readIdentifier();
        }

        // Operators and delimiters
        return readOperator();
    }

    private:

    void skipWhitespace() {
        while (pos < source.length && (source[pos] == ' ' || source[pos] == '\t')) {
            pos++;
            column++;
        }
    }

    Token readString() {
        auto start = pos;
        auto startCol = column;
        pos++; // Skip opening quote
        column++;

        while (pos < source.length && source[pos] != '"') {
            pos++;
            column++;
        }

        if (pos < source.length) {
            pos++; // Skip closing quote
            column++;
        }

        return Token(TokenType.string_literal, source[start .. pos], start, line, startCol);
    }

    Token readNumber() {
        auto start = pos;
        auto startCol = column;

        while (pos < source.length && isDigit(source[pos])) {
            pos++;
            column++;
        }

        // Check for decimal point
        if (pos < source.length && source[pos] == '.') {
            pos++;
            column++;
            while (pos < source.length && isDigit(source[pos])) {
                pos++;
                column++;
            }
        }

        return Token(TokenType.number_literal, source[start .. pos], start, line, startCol);
    }

    Token readIdentifier() {
        auto start = pos;
        auto startCol = column;

        while (pos < source.length && (isAlphaNum(source[pos]) || source[pos] == '^' || source[pos] == '%')) {
            pos++;
            column++;
        }

        auto literal = source[start .. pos];
        auto type = lookupKeyword(literal);
        return Token(type, literal, start, line, startCol);
    }

    Token readOperator() {
        auto start = pos;
        auto startCol = column;
        auto c = source[pos];

        switch (c) {
            case '+':
                pos++;
                column++;
                return Token(TokenType.plus, "+", start, line, startCol);
            case '-':
                pos++;
                column++;
                return Token(TokenType.minus, "-", start, line, startCol);
            case '*':
                pos++;
                column++;
                if (pos < source.length && source[pos] == '*') {
                    pos++;
                    column++;
                    return Token(TokenType.starstar, "**", start, line, startCol);
                }
                return Token(TokenType.star, "*", start, line, startCol);
            case '/':
                pos++;
                column++;
                return Token(TokenType.slash, "/", start, line, startCol);
            case '\\':
                pos++;
                column++;
                return Token(TokenType.backslash, "\\", start, line, startCol);
            case '#':
                pos++;
                column++;
                return Token(TokenType.hash, "#", start, line, startCol);
            case '=':
                pos++;
                column++;
                return Token(TokenType.equal, "=", start, line, startCol);
            case '\'':
                pos++;
                column++;
                if (pos < source.length && source[pos] == '=') {
                    pos++;
                    column++;
                    return Token(TokenType.not_equal, "'=", start, line, startCol);
                }
                if (pos < source.length && source[pos] == '<') {
                    pos++;
                    column++;
                    return Token(TokenType.less_equal, "'<", start, line, startCol);
                }
                if (pos < source.length && source[pos] == '>') {
                    pos++;
                    column++;
                    return Token(TokenType.greater_equal, "'>", start, line, startCol);
                }
                return Token(TokenType.squote, "'", start, line, startCol);
            case '<':
                pos++;
                column++;
                if (pos < source.length && source[pos] == '=') {
                    pos++;
                    column++;
                    return Token(TokenType.less_equal, "<=", start, line, startCol);
                }
                return Token(TokenType.less_than, "<", start, line, startCol);
            case '>':
                pos++;
                column++;
                if (pos < source.length && source[pos] == '=') {
                    pos++;
                    column++;
                    return Token(TokenType.greater_equal, ">=", start, line, startCol);
                }
                return Token(TokenType.greater_than, ">", start, line, startCol);
            case ']':
                pos++;
                column++;
                if (pos < source.length && source[pos] == ']') {
                    pos++;
                    column++;
                    return Token(TokenType.rbracket2, "]]", start, line, startCol);
                }
                return Token(TokenType.rbracket, "]", start, line, startCol);
            case '[':
                pos++;
                column++;
                if (pos < source.length && source[pos] == '[') {
                    pos++;
                    column++;
                    return Token(TokenType.lbracket2, "[[", start, line, startCol);
                }
                return Token(TokenType.lbracket, "[", start, line, startCol);
            case '!':
                pos++;
                column++;
                return Token(TokenType.bang, "!", start, line, startCol);
            case '&':
                pos++;
                column++;
                return Token(TokenType.ampersand, "&", start, line, startCol);
            case '?':
                pos++;
                column++;
                return Token(TokenType.question, "?", start, line, startCol);
            case '@':
                pos++;
                column++;
                return Token(TokenType.at, "@", start, line, startCol);
            case '_':
                pos++;
                column++;
                return Token(TokenType.underscore, "_", start, line, startCol);
            case '(':
                pos++;
                column++;
                return Token(TokenType.lparen, "(", start, line, startCol);
            case ')':
                pos++;
                column++;
                return Token(TokenType.rparen, ")", start, line, startCol);
            case ',':
                pos++;
                column++;
                return Token(TokenType.comma, ",", start, line, startCol);
            case ':':
                pos++;
                column++;
                return Token(TokenType.colon, ":", start, line, startCol);
            case ';':
                pos++;
                column++;
                return Token(TokenType.semicolon, ";", start, line, startCol);
            case '$':
                pos++;
                column++;
                if (pos < source.length && source[pos] == '$') {
                    pos++;
                    column++;
                    return Token(TokenType.dollardollar, "$$", start, line, startCol);
                }
                // Fall through to identifier
                return readIdentifier();
            default:
                pos++;
                column++;
                return Token(TokenType.illegal, source[start .. pos], start, line, startCol);
        }
    }

    TokenType lookupKeyword(string word) {
        auto upper = word.toUpper();

        switch (upper) {
            case "BREAK":
            case "B":
                return TokenType.cmd_break;
            case "CLOSE":
            case "C":
                return TokenType.cmd_close;
            case "DO":
            case "D":
                return TokenType.cmd_do;
            case "ELSE":
            case "E":
                return TokenType.cmd_else;
            case "FOR":
            case "F":
                return TokenType.cmd_for;
            case "GOTO":
            case "G":
                return TokenType.cmd_goto;
            case "HALT":
            case "H":
                return TokenType.cmd_halt;
            case "HANG":
                return TokenType.cmd_hang;
            case "IF":
            case "I":
                return TokenType.cmd_if;
            case "JOB":
            case "J":
                return TokenType.cmd_job;
            case "KILL":
            case "K":
                return TokenType.cmd_kill;
            case "LOCK":
            case "L":
                return TokenType.cmd_lock;
            case "MERGE":
            case "M":
                return TokenType.cmd_merge;
            case "NEW":
            case "N":
                return TokenType.cmd_new;
            case "OPEN":
            case "O":
                return TokenType.cmd_open;
            case "QUIT":
            case "Q":
                return TokenType.cmd_quit;
            case "READ":
            case "R":
                return TokenType.cmd_read;
            case "SET":
            case "S":
                return TokenType.cmd_set;
            case "USE":
            case "U":
                return TokenType.cmd_use;
            case "VIEW":
            case "V":
                return TokenType.cmd_view;
            case "WRITE":
            case "W":
                return TokenType.cmd_write;
            case "XECUTE":
            case "X":
                return TokenType.cmd_xecute;
            default:
                return TokenType.identifier;
        }
    }
}

unittest {
    auto lexer = Lexer.create("SET X = 42");
    auto tok = lexer.nextToken();
    assert(tok.type == TokenType.cmd_set);
    assert(tok.literal == "SET");

    tok = lexer.nextToken();
    assert(tok.type == TokenType.identifier);
    assert(tok.literal == "X");

    tok = lexer.nextToken();
    assert(tok.type == TokenType.equal);

    tok = lexer.nextToken();
    assert(tok.type == TokenType.number_literal);
    assert(tok.literal == "42");
}

unittest {
    auto lexer = Lexer.create("WRITE \"Hello, World!\"");
    auto tok = lexer.nextToken();
    assert(tok.type == TokenType.cmd_write);

    tok = lexer.nextToken();
    assert(tok.type == TokenType.string_literal);
    assert(tok.literal == "\"Hello, World!\"");
}

unittest {
    auto lexer = Lexer.create("IF X > 10");
    auto tok = lexer.nextToken();
    assert(tok.type == TokenType.cmd_if);

    tok = lexer.nextToken();
    assert(tok.type == TokenType.identifier);

    tok = lexer.nextToken();
    assert(tok.type == TokenType.greater_than);

    tok = lexer.nextToken();
    assert(tok.type == TokenType.number_literal);
}
