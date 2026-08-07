// Package: md
// File:    src/parser.d
// Summary: MUMPS Parser (AST Generation)
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module parser;

import std.stdio;
import std.string;
import lexer;
import opcode;

/// AST Node types
enum NodeType {
    program,
    line,
    tag,
    command,
    expression,
    variable,
    string_literal,
    number_literal,
    binary_op,
    unary_op,
    function_call,
}

/// AST Node
struct ASTNode {
    NodeType type;
    string value;
    ASTNode[] children;
    size_t line;
    size_t column;
}

/// Parser
struct Parser {
    Lexer lexer;
    Token current;
    Token peek;

    static Parser create(string source) {
        Parser parser;
        parser.lexer = Lexer.create(source);
        parser.current = parser.lexer.nextToken();
        parser.peek = parser.lexer.nextToken();
        return parser;
    }

    ASTNode parse() {
        ASTNode program;
        program.type = NodeType.program;

        while (current.type != TokenType.eof) {
            auto line = parseLine();
            if (line.children.length > 0) {
                program.children ~= line;
            }
        }

        return program;
    }

    private:

    void advance() {
        current = peek;
        peek = lexer.nextToken();
    }

    Token expect(TokenType type) {
        if (current.type == type) {
            auto tok = current;
            advance();
            return tok;
        }
        // Error handling
        return Token(TokenType.illegal, "", 0, 0, 0);
    }

    ASTNode parseLine() {
        ASTNode line;
        line.type = NodeType.line;
        line.line = current.line;

        // Skip newlines
        while (current.type == TokenType.newline) {
            advance();
        }

        // Check for tag
        if (current.type == TokenType.identifier && peek.type != TokenType.cmd_set &&
            peek.type != TokenType.cmd_write && peek.type != TokenType.cmd_if &&
            peek.type != TokenType.cmd_do && peek.type != TokenType.cmd_for &&
            peek.type != TokenType.cmd_kill && peek.type != TokenType.cmd_new &&
            peek.type != TokenType.cmd_quit && peek.type != TokenType.cmd_halt &&
            peek.type != TokenType.cmd_read && peek.type != TokenType.cmd_open &&
            peek.type != TokenType.cmd_close && peek.type != TokenType.cmd_use &&
            peek.type != TokenType.cmd_job && peek.type != TokenType.cmd_goto &&
            peek.type != TokenType.cmd_lock && peek.type != TokenType.cmd_merge &&
            peek.type != TokenType.cmd_xecute && peek.type != TokenType.cmd_hang &&
            peek.type != TokenType.cmd_break && peek.type != TokenType.cmd_else &&
            peek.type != TokenType.cmd_view) {
            auto tag = parseTag();
            line.children ~= tag;
        }

        // Parse commands
        while (current.type != TokenType.newline && current.type != TokenType.eof) {
            auto cmd = parseCommand();
            if (cmd.children.length > 0) {
                line.children ~= cmd;
            }

            // Skip whitespace
            if (current.type == TokenType.space) {
                advance();
            }
        }

        // Skip newline
        if (current.type == TokenType.newline) {
            advance();
        }

        return line;
    }

    ASTNode parseTag() {
        ASTNode tag;
        tag.type = NodeType.tag;
        tag.value = current.literal;
        tag.line = current.line;
        tag.column = current.column;
        advance();
        return tag;
    }

    ASTNode parseCommand() {
        ASTNode cmd;
        cmd.type = NodeType.command;
        cmd.line = current.line;
        cmd.column = current.column;

        switch (current.type) {
            case TokenType.cmd_set:
                cmd.value = "SET";
                advance();
                cmd.children ~= parseSetArgs();
                break;
            case TokenType.cmd_write:
                cmd.value = "WRITE";
                advance();
                cmd.children ~= parseWriteArgs();
                break;
            case TokenType.cmd_if:
                cmd.value = "IF";
                advance();
                cmd.children ~= parseExpression();
                break;
            case TokenType.cmd_do:
                cmd.value = "DO";
                advance();
                cmd.children ~= parseDoArgs();
                break;
            case TokenType.cmd_for:
                cmd.value = "FOR";
                advance();
                cmd.children ~= parseForArgs();
                break;
            case TokenType.cmd_kill:
                cmd.value = "KILL";
                advance();
                cmd.children ~= parseKillArgs();
                break;
            case TokenType.cmd_new:
                cmd.value = "NEW";
                advance();
                cmd.children ~= parseNewArgs();
                break;
            case TokenType.cmd_quit:
                cmd.value = "QUIT";
                advance();
                if (current.type != TokenType.newline && current.type != TokenType.eof) {
                    cmd.children ~= parseExpression();
                }
                break;
            case TokenType.cmd_halt:
                cmd.value = "HALT";
                advance();
                break;
            case TokenType.cmd_hang:
                cmd.value = "HANG";
                advance();
                cmd.children ~= parseExpression();
                break;
            case TokenType.cmd_read:
                cmd.value = "READ";
                advance();
                cmd.children ~= parseReadArgs();
                break;
            case TokenType.cmd_open:
                cmd.value = "OPEN";
                advance();
                cmd.children ~= parseOpenArgs();
                break;
            case TokenType.cmd_close:
                cmd.value = "CLOSE";
                advance();
                cmd.children ~= parseCloseArgs();
                break;
            case TokenType.cmd_use:
                cmd.value = "USE";
                advance();
                cmd.children ~= parseUseArgs();
                break;
            case TokenType.cmd_job:
                cmd.value = "JOB";
                advance();
                cmd.children ~= parseJobArgs();
                break;
            case TokenType.cmd_goto:
                cmd.value = "GOTO";
                advance();
                cmd.children ~= parseGotoArgs();
                break;
            case TokenType.cmd_lock:
                cmd.value = "LOCK";
                advance();
                cmd.children ~= parseLockArgs();
                break;
            case TokenType.cmd_merge:
                cmd.value = "MERGE";
                advance();
                cmd.children ~= parseMergeArgs();
                break;
            case TokenType.cmd_xecute:
                cmd.value = "XECUTE";
                advance();
                cmd.children ~= parseExpression();
                break;
            case TokenType.cmd_break:
                cmd.value = "BREAK";
                advance();
                break;
            case TokenType.cmd_else:
                cmd.value = "ELSE";
                advance();
                break;
            case TokenType.cmd_view:
                cmd.value = "VIEW";
                advance();
                cmd.children ~= parseViewArgs();
                break;
            default:
                break;
        }

        return cmd;
    }

    ASTNode[] parseSetArgs() {
        ASTNode[] args;

        // Parse variable
        args ~= parseVariable();

        // Skip =
        if (current.type == TokenType.equal) {
            advance();
        }

        // Parse value
        args ~= parseExpression();

        return args;
    }

    ASTNode[] parseWriteArgs() {
        ASTNode[] args;

        while (current.type != TokenType.newline && current.type != TokenType.eof) {
            if (current.type == TokenType.string_literal) {
                args ~= parseStringLiteral();
            } else if (current.type == TokenType.identifier) {
                args ~= parseVariable();
            } else if (current.type == TokenType.bang) {
                // Newline
                args ~= ASTNode(NodeType.string_literal, "\n", [], current.line, current.column);
                advance();
            } else if (current.type == TokenType.hash) {
                // Form feed
                args ~= ASTNode(NodeType.string_literal, "\x0C", [], current.line, current.column);
                advance();
            } else if (current.type == TokenType.question) {
                // Tab
                advance();
                args ~= parseExpression();
            } else {
                break;
            }

            // Skip comma
            if (current.type == TokenType.comma) {
                advance();
            }
        }

        return args;
    }

    ASTNode[] parseDoArgs() {
        ASTNode[] args;

        while (current.type != TokenType.newline && current.type != TokenType.eof) {
            args ~= parseVariable();

            if (current.type == TokenType.comma) {
                advance();
            }
        }

        return args;
    }

    ASTNode[] parseForArgs() {
        ASTNode[] args;

        // Parse variable
        args ~= parseVariable();

        // Skip =
        if (current.type == TokenType.equal) {
            advance();
        }

        // Parse start value
        args ~= parseExpression();

        // Skip colon
        if (current.type == TokenType.colon) {
            advance();
            args ~= parseExpression();
        }

        // Skip colon
        if (current.type == TokenType.colon) {
            advance();
            args ~= parseExpression();
        }

        return args;
    }

    ASTNode[] parseKillArgs() {
        ASTNode[] args;

        while (current.type != TokenType.newline && current.type != TokenType.eof) {
            args ~= parseVariable();

            if (current.type == TokenType.comma) {
                advance();
            }
        }

        return args;
    }

    ASTNode[] parseNewArgs() {
        ASTNode[] args;

        while (current.type != TokenType.newline && current.type != TokenType.eof) {
            args ~= parseVariable();

            if (current.type == TokenType.comma) {
                advance();
            }
        }

        return args;
    }

    ASTNode[] parseReadArgs() {
        ASTNode[] args;

        while (current.type != TokenType.newline && current.type != TokenType.eof) {
            if (current.type == TokenType.string_literal) {
                args ~= parseStringLiteral();
            } else if (current.type == TokenType.identifier) {
                args ~= parseVariable();
            } else {
                break;
            }

            if (current.type == TokenType.comma) {
                advance();
            }
        }

        return args;
    }

    ASTNode[] parseOpenArgs() {
        ASTNode[] args;

        while (current.type != TokenType.newline && current.type != TokenType.eof) {
            args ~= parseExpression();

            if (current.type == TokenType.comma) {
                advance();
            }
        }

        return args;
    }

    ASTNode[] parseCloseArgs() {
        ASTNode[] args;

        while (current.type != TokenType.newline && current.type != TokenType.eof) {
            args ~= parseExpression();

            if (current.type == TokenType.comma) {
                advance();
            }
        }

        return args;
    }

    ASTNode[] parseUseArgs() {
        ASTNode[] args;

        while (current.type != TokenType.newline && current.type != TokenType.eof) {
            args ~= parseExpression();

            if (current.type == TokenType.comma) {
                advance();
            }
        }

        return args;
    }

    ASTNode[] parseJobArgs() {
        ASTNode[] args;

        while (current.type != TokenType.newline && current.type != TokenType.eof) {
            args ~= parseVariable();

            if (current.type == TokenType.comma) {
                advance();
            }
        }

        return args;
    }

    ASTNode[] parseGotoArgs() {
        ASTNode[] args;

        while (current.type != TokenType.newline && current.type != TokenType.eof) {
            args ~= parseVariable();

            if (current.type == TokenType.comma) {
                advance();
            }
        }

        return args;
    }

    ASTNode[] parseLockArgs() {
        ASTNode[] args;

        while (current.type != TokenType.newline && current.type != TokenType.eof) {
            args ~= parseVariable();

            if (current.type == TokenType.comma) {
                advance();
            }
        }

        return args;
    }

    ASTNode[] parseMergeArgs() {
        ASTNode[] args;

        while (current.type != TokenType.newline && current.type != TokenType.eof) {
            args ~= parseVariable();

            if (current.type == TokenType.equal) {
                advance();
                args ~= parseVariable();
            }

            if (current.type == TokenType.comma) {
                advance();
            }
        }

        return args;
    }

    ASTNode[] parseViewArgs() {
        ASTNode[] args;

        while (current.type != TokenType.newline && current.type != TokenType.eof) {
            args ~= parseExpression();

            if (current.type == TokenType.colon) {
                advance();
            }
        }

        return args;
    }

    ASTNode parseExpression() {
        return parseAddSub();
    }

    ASTNode parseAddSub() {
        auto left = parseMulDiv();

        while (current.type == TokenType.plus || current.type == TokenType.minus) {
            auto op = current;
            advance();
            auto right = parseMulDiv();

            ASTNode node;
            node.type = NodeType.binary_op;
            node.value = op.literal;
            node.children ~= left;
            node.children ~= right;
            left = node;
        }

        return left;
    }

    ASTNode parseMulDiv() {
        auto left = parseUnary();

        while (current.type == TokenType.star || current.type == TokenType.slash || 
               current.type == TokenType.backslash || current.type == TokenType.hash) {
            auto op = current;
            advance();
            auto right = parseUnary();

            ASTNode node;
            node.type = NodeType.binary_op;
            node.value = op.literal;
            node.children ~= left;
            node.children ~= right;
            left = node;
        }

        return left;
    }

    ASTNode parseUnary() {
        if (current.type == TokenType.plus || current.type == TokenType.minus) {
            auto op = current;
            advance();
            auto operand = parsePrimary();

            ASTNode node;
            node.type = NodeType.unary_op;
            node.value = op.literal;
            node.children ~= operand;
            return node;
        }

        return parsePrimary();
    }

    ASTNode parsePrimary() {
        switch (current.type) {
            case TokenType.number_literal:
                return parseNumberLiteral();
            case TokenType.string_literal:
                return parseStringLiteral();
            case TokenType.identifier:
                return parseVariable();
            case TokenType.lparen:
                advance(); // Skip (
                auto expr = parseExpression();
                if (current.type == TokenType.rparen) {
                    advance(); // Skip )
                }
                return expr;
            default:
                ASTNode node;
                node.type = NodeType.expression;
                node.value = current.literal;
                node.line = current.line;
                node.column = current.column;
                advance();
                return node;
        }
    }

    ASTNode parseNumberLiteral() {
        ASTNode node;
        node.type = NodeType.number_literal;
        node.value = current.literal;
        node.line = current.line;
        node.column = current.column;
        advance();
        return node;
    }

    ASTNode parseStringLiteral() {
        ASTNode node;
        node.type = NodeType.string_literal;
        node.value = current.literal;
        node.line = current.line;
        node.column = current.column;
        advance();
        return node;
    }

    ASTNode parseVariable() {
        ASTNode node;
        node.type = NodeType.variable;
        node.value = current.literal;
        node.line = current.line;
        node.column = current.column;
        advance();

        // Check for subscripts
        if (current.type == TokenType.lparen) {
            advance(); // Skip (
            while (current.type != TokenType.rparen && current.type != TokenType.eof) {
                node.children ~= parseExpression();
                if (current.type == TokenType.comma) {
                    advance();
                }
            }
            if (current.type == TokenType.rparen) {
                advance(); // Skip )
            }
        }

        return node;
    }
}

unittest {
    auto parser = Parser.create("SET X = 42");
    auto ast = parser.parse();
    assert(ast.type == NodeType.program);
    assert(ast.children.length > 0);
}

unittest {
    auto parser = Parser.create("WRITE \"Hello, World!\"");
    auto ast = parser.parse();
    assert(ast.type == NodeType.program);
    assert(ast.children.length > 0);
}

unittest {
    auto parser = Parser.create("IF X > 10");
    auto ast = parser.parse();
    assert(ast.type == NodeType.program);
    assert(ast.children.length > 0);
}
