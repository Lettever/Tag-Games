/*
    name := ident | string
    assignment := name '=' value ';'
    block := '{' value* '}'
    typed_block := name '.' block
    member_access := name ('.' name)+
    value = typed_block | member_access | block | name
 */

import './ast.dart';
import './lexer.dart';
import './token.dart';
import '../utils/resultType.dart';
import './parser-error.dart';

import 'dart:io';

class Parser {
    final List<Token> tokens;
    int i = 0;

    Parser(this.tokens);

    Token get _current => tokens[i];
    bool get _atEnd => i >= tokens.length || _current.type == TokenType.EOF;

    Token? peek(int offset) {
        if (i + offset >= tokens.length) return null;
        return tokens[i + offset];
    }

    Result<Token, ParserError> consume([TokenType? type]) {
        if (_atEnd) return Result.err(UnexpectedEOF(tokens.last.pos.clone()));
        final token = tokens[i];
        if (type != null && token.type != type) {
            return Result.err(UnexpectedType(token.pos.clone(), expected:  type, found: token.type));
        }
        i += 1;
        return Result.ok(token);
    }

    Result<Assignment, ParserError> parseAssignment() {
        var nameResult = parseName();
        if (nameResult.isErr()) return Result.err(nameResult.error);
        
        var equalsResult = consume(TokenType.Equals);
        if (equalsResult.isErr()) return Result.err(equalsResult.error);

        var valueResult = parseValueSequence();
        if (valueResult.isErr()) return Result.err(valueResult.error);

        final semiResult = consume(TokenType.SemiColon);
        if (semiResult.isErr()) return Result.err(semiResult.error);

        return Result.ok(Assignment(nameResult.value, valueResult.value));
    }

    Result<Name, ParserError> parseName() {
        if (!_atEnd && _current.canBeAName()) {
            Token token = consume().value;
            return Result.ok(Name(token.span));
        }
        return Result.err(ExpectedName(_current.pos.clone(), _current.type));
    }

    bool shouldParseTypedBlock() => !_atEnd && _current.canBeAName() &&
        peek(1)?.type == TokenType.Dot &&
        peek(2)?.type == TokenType.L_Bracket;

    Result<TypedBlock, ParserError> parseTypedBlock() {
        final nameResult = parseName();
        if (nameResult.isErr()) return Result.err(nameResult.error);

        final dotResult = consume(TokenType.Dot);
        if (dotResult.isErr()) return Result.err(dotResult.error);

        final blockResult = parseBlock();
        if (blockResult.isErr()) return Result.err(blockResult.error);
        //print(blockResult.value);

        return Result.ok(TypedBlock(nameResult.value, blockResult.value));
    }

    bool shouldParseMemberAccess() => !_atEnd && _current.canBeAName() &&
        peek(1)?.type == TokenType.Dot &&
        (peek(2)?.canBeAName() ?? false);
        //a.b.c.d.e.f

    Result<MemberAccess, ParserError> parseMemberAccess() {
        final rootResult = parseName();
        if (rootResult.isErr()) return Result.err(rootResult.error);
        final members = <Name>[];
        while (!_atEnd && _current.type == TokenType.Dot) {
            consume();
            
            final memberResult = parseName();
            if (memberResult.isErr()) return Result.err(memberResult.error);

            members.add(memberResult.value);
        }
        return Result.ok(MemberAccess(rootResult.value, members));
    }

    bool shouldParseBlock() => !_atEnd &&  _current.type == TokenType.L_Bracket;

    Result<Block, ParserError> parseBlock() {
        final lbrace = consume(TokenType.L_Bracket);
        if (lbrace.isErr()) return Result.err(lbrace.error);

        final values = <Value>[];
        while (!_atEnd && _current.type != TokenType.R_Bracket) {
            final valueResult = parseValue();
            if (valueResult.isErr()) return Result.err(valueResult.error);
            values.add(valueResult.value);
        }

        final rbrace = consume(TokenType.R_Bracket);
        if (rbrace.isErr()) return Result.err(rbrace.error);

        return Result.ok(Block(values));
    }

    bool shouldParseName() => !_atEnd && _current.canBeAName();

    Result<Value, ParserError> parseValue() {
        if (shouldParseTypedBlock()) return parseTypedBlock();
        if (shouldParseMemberAccess()) return parseMemberAccess();
        if (shouldParseBlock()) return parseBlock();
        if (shouldParseName()) return parseName();

        return Result.err(UnexpectedToken(_current.pos.clone(), _current.type));
    }

    Result<Value, ParserError> parseValueSequence({Set<TokenType> endTokens = const {TokenType.SemiColon, TokenType.R_Bracket}}) {
        final values = <Value>[];
        while (!_atEnd && !endTokens.contains(_current.type)) {
            final valueResult = parseValue();
            if (valueResult.isErr()) return Result.err(valueResult.error);
            values.add(valueResult.value);
        }
        if (values.isEmpty) {
            return Result.err(ExpectedValues(_current.pos.clone(), _current.type));
        }
        if (values.length == 1) {
            return Result.ok(values[0]);
        }
        return Result.ok(Block(values));
    }

    Result<List<Assignment>, List<ParserError>> parseProgram() {
        final assignments = <Assignment>[];
        final errors = <ParserError>[];
        
        while (!_atEnd) {
            final assignmentResult = parseAssignment();
            if (assignmentResult.isErr()) errors.add(assignmentResult.error);
            else assignments.add(assignmentResult.value);
        }

        if (errors.length > 0) return Result.err(errors);
        return Result.ok(assignments);
    }
}

void main() {
    String src = File("../examples/simple.tg").readAsStringSync();
    var tokens = Lexer(src).collect();
    //print(tokens);
    if (tokens.isErr()) {
        print("Error");
        print(tokens.error);
        return;
    }
    var po = Parser(tokens.value).parseProgram();
    if (po.isOk()) for (var elem in po.value) printAst(elem);
    else print(po.error);
    
}

void printAst(AstNode node, [int indent = 0]) {
    final space = '  ' * indent;
    if (node is Assignment) {
        print('${space}Assignment:');
        print('${space}  Name: ${node.name}');
        print('${space}  Value:');
        printAst(node.value, indent + 2);
    } else if (node is TypedBlock) {
        print('${space}TypedBlock:');
        print('${space}  Name: ${node.name}');
        print('${space}  Block:');
        printAst(node.block, indent + 2);
    } else if (node is Block) {
        print('${space}Block:');
        for (var v in node.values) {
            printAst(v, indent + 1);
        }
    } else if (node is MemberAccess) {
        print('${space}MemberAccess:');
        print('${space}  Root: ${node.root}');
    if (node.members.isNotEmpty) {
        print('${space}  Members:');
        for (var m in node.members) {
            print('${space}    $m');
        }
    }
    } else if (node is Name) {
        print('${space}Name: ${node.name}');
    } else {
        print('${space}Unknown AST node');
    }
}