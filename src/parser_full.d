// Package: md
// File:    src/parser_full.d
// Summary: Full MUMPS Parser (All 22 Commands)
//
// SPDX-FileCopyrightText:  2026 Mark J. Andrews
// SPDX-License-Identifier: AGPL-3.0-or-later

module parser_full;

import std.stdio;
import std.string;
import std.ascii;
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
    postcondition,
}

/// AST Node
struct ASTNode {
    NodeType type;
    string value;
    ASTNode[] children;
    size_t line;
    size_t column;
}

/// Full MUMPS Parser
struct FullParser {
    Lexer lexer;
    Token current;
    Token peek;

    static FullParser create(string source) {
        FullParser parser;
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

    ASTNode parseLine() {
        ASTNode line;
        line.type = NodeType.line;
        line.line = current.line;

        // Skip newlines
        while (current.type == TokenType.newline) {
            advance();
        }

        // Check for tag
        if (current.type == TokenType.identifier && !isCommand(peek.type)) {
            auto tag = parseTag();
            line.children ~= tag;
        }

        // Parse commands
        while (current.type != TokenType.newline && current.type != TokenType.eof) {
            auto cmd = parseCommand();
            if (cmd.children.length > 0 || cmd.value.length > 0) {
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

    bool isCommand(TokenType type) {
        switch (type) {
            case TokenType.cmd_break:
            case TokenType.cmd_close:
            case TokenType.cmd_do:
            case TokenType.cmd_else:
            case TokenType.cmd_for:
            case TokenType.cmd_goto:
            case TokenType.cmd_halt:
            case TokenType.cmd_hang:
            case TokenType.cmd_if:
            case TokenType.cmd_job:
            case TokenType.cmd_kill:
            case TokenType.cmd_lock:
            case TokenType.cmd_merge:
            case TokenType.cmd_new:
            case TokenType.cmd_open:
            case TokenType.cmd_quit:
            case TokenType.cmd_read:
            case TokenType.cmd_set:
            case TokenType.cmd_use:
            case TokenType.cmd_view:
            case TokenType.cmd_write:
            case TokenType.cmd_xecute:
                return true;
            default:
                return false;
        }
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

        // Check for postcondition
        if (current.type == TokenType.colon) {
            advance();
            auto postcond = parseExpression();
            postcond.type = NodeType.postcondition;
            cmd.children ~= postcond;
        }

        switch (current.type) {
            case TokenType.cmd_break:
                cmd.value = "BREAK";
                advance();
                break;
            case TokenType.cmd_close:
                cmd.value = "CLOSE";
                advance();
                cmd.children ~= parseArgList();
                break;
            case TokenType.cmd_do:
                cmd.value = "DO";
                advance();
                cmd.children ~= parseArgList();
                break;
            case TokenType.cmd_else:
                cmd.value = "ELSE";
                advance();
                break;
            case TokenType.cmd_for:
                cmd.value = "FOR";
                advance();
                cmd.children ~= parseForArgs();
                break;
            case TokenType.cmd_goto:
                cmd.value = "GOTO";
                advance();
                cmd.children ~= parseArgList();
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
            case TokenType.cmd_if:
                cmd.value = "IF";
                advance();
                cmd.children ~= parseArgList();
                break;
            case TokenType.cmd_job:
                cmd.value = "JOB";
                advance();
                cmd.children ~= parseArgList();
                break;
            case TokenType.cmd_kill:
                cmd.value = "KILL";
                advance();
                cmd.children ~= parseArgList();
                break;
            case TokenType.cmd_lock:
                cmd.value = "LOCK";
                advance();
                cmd.children ~= parseArgList();
                break;
            case TokenType.cmd_merge:
                cmd.value = "MERGE";
                advance();
                cmd.children ~= parseMergeArgs();
                break;
            case TokenType.cmd_new:
                cmd.value = "NEW";
                advance();
                cmd.children ~= parseArgList();
                break;
            case TokenType.cmd_open:
                cmd.value = "OPEN";
                advance();
                cmd.children ~= parseArgList();
                break;
            case TokenType.cmd_quit:
                cmd.value = "QUIT";
                advance();
                if (current.type != TokenType.newline && current.type != TokenType.eof && current.type != TokenType.space) {
                    cmd.children ~= parseExpression();
                }
                break;
            case TokenType.cmd_read:
                cmd.value = "READ";
                advance();
                cmd.children ~= parseReadArgs();
                break;
            case TokenType.cmd_set:
                cmd.value = "SET";
                advance();
                cmd.children ~= parseSetArgs();
                break;
            case TokenType.cmd_use:
                cmd.value = "USE";
                advance();
                cmd.children ~= parseArgList();
                break;
            case TokenType.cmd_view:
                cmd.value = "VIEW";
                advance();
                cmd.children ~= parseArgList();
                break;
            case TokenType.cmd_write:
                cmd.value = "WRITE";
                advance();
                cmd.children ~= parseWriteArgs();
                break;
            case TokenType.cmd_xecute:
                cmd.value = "XECUTE";
                advance();
                cmd.children ~= parseExpression();
                break;
            default:
                break;
        }

        return cmd;
    }

    ASTNode[] parseArgList() {
        ASTNode[] args;

        while (current.type != TokenType.newline && current.type != TokenType.eof && current.type != TokenType.space) {
            args ~= parseExpression();

            if (current.type == TokenType.comma) {
                advance();
            }
        }

        return args;
    }

    ASTNode[] parseSetArgs() {
        ASTNode[] args;

        // Parse variable = expression pairs
        while (current.type != TokenType.newline && current.type != TokenType.eof && current.type != TokenType.space) {
            // Parse variable
            args ~= parseVariable();

            // Skip =
            if (current.type == TokenType.equal) {
                advance();
            }

            // Parse value
            args ~= parseExpression();

            // Skip comma
            if (current.type == TokenType.comma) {
                advance();
            }
        }

        return args;
    }

    ASTNode[] parseWriteArgs() {
        ASTNode[] args;

        while (current.type != TokenType.newline && current.type != TokenType.eof && current.type != TokenType.space) {
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
            } else if (current.type == TokenType.star) {
                // Write star
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

    ASTNode[] parseReadArgs() {
        ASTNode[] args;

        while (current.type != TokenType.newline && current.type != TokenType.eof && current.type != TokenType.space) {
            if (current.type == TokenType.string_literal) {
                args ~= parseStringLiteral();
            } else if (current.type == TokenType.identifier) {
                args ~= parseVariable();
            } else if (current.type == TokenType.star) {
                // Read star
                advance();
                args ~= parseVariable();
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

    ASTNode[] parseForArgs() {
        ASTNode[] args;

        // Parse variable = start : increment : end
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

    ASTNode[] parseMergeArgs() {
        ASTNode[] args;

        // Parse destination = source
        args ~= parseVariable();

        // Skip =
        if (current.type == TokenType.equal) {
            advance();
        }

        // Parse source
        args ~= parseVariable();

        return args;
    }

    ASTNode parseExpression() {
        return parseComparison();
    }

    ASTNode parseComparison() {
        auto left = parseAddSub();

        while (current.type == TokenType.equal || current.type == TokenType.not_equal ||
               current.type == TokenType.less_than || current.type == TokenType.greater_than ||
               current.type == TokenType.less_equal || current.type == TokenType.greater_equal ||
               current.type == TokenType.lbracket || current.type == TokenType.rbracket ||
               current.type == TokenType.lbracket2 || current.type == TokenType.rbracket2) {
            auto op = current;
            advance();
            auto right = parseAddSub();

            ASTNode node;
            node.type = NodeType.binary_op;
            node.value = op.literal;
            node.children ~= left;
            node.children ~= right;
            left = node;
        }

        return left;
    }

    ASTNode parseAddSub() {
        auto left = parseMulDiv();

        while (current.type == TokenType.plus || current.type == TokenType.minus ||
               current.type == TokenType.underscore) {
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
               current.type == TokenType.backslash || current.type == TokenType.hash ||
               current.type == TokenType.starstar) {
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
            case TokenType.question:
                // Pattern match
                advance();
                auto patternExpr = parseExpression();
                ASTNode node;
                node.type = NodeType.binary_op;
                node.value = "?";
                node.children ~= patternExpr;
                return node;
            default:
                ASTNode emptyNode;
                emptyNode.type = NodeType.expression;
                emptyNode.value = current.literal;
                emptyNode.line = current.line;
                emptyNode.column = current.column;
                advance();
                return emptyNode;
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
    auto parser = FullParser.create("SET X = 42");
    auto ast = parser.parse();
    assert(ast.type == NodeType.program);
    assert(ast.children.length > 0);
}

unittest {
    auto parser = FullParser.create("WRITE \"Hello, World!\"");
    auto ast = parser.parse();
    assert(ast.type == NodeType.program);
    assert(ast.children.length > 0);
}

unittest {
    auto parser = FullParser.create("IF X > 10");
    auto ast = parser.parse();
    assert(ast.type == NodeType.program);
    assert(ast.children.length > 0);
}

unittest {
    auto parser = FullParser.create("FOR I=1:1:10");
    auto ast = parser.parse();
    assert(ast.type == NodeType.program);
    assert(ast.children.length > 0);
}

unittest {
    auto parser = FullParser.create("QUIT");
    auto ast = parser.parse();
    assert(ast.type == NodeType.program);
    assert(ast.children.length > 0);
}

unittest {
    auto parser = FullParser.create("HALT");
    auto ast = parser.parse();
    assert(ast.type == NodeType.program);
    assert(ast.children.length > 0);
}
