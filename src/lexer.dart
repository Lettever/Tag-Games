import '../utils/resultType.dart';
import './token.dart';
import './lexer-pos.dart';
import './lexer-error.dart';

import 'dart:io';

class Lexer {
    Lexer(this.source);
    final String source;
    final pos = LexerPosition();

    final Map<String, TokenType> tokenTypeMap = {
        "=": TokenType.Equals,
        ";": TokenType.SemiColon,
        ".": TokenType.Dot,
        "{": TokenType.L_Bracket,
        "}": TokenType.R_Bracket,
    };

    Result<List<Token>, List<LexerError>> collect() {
        var
            tokens = <Token>[],
            errors = <LexerError>[]
        ;

        for (
            Result<Token, LexerError> t = next();
            t.isErr() || t.value.type != TokenType.EOF;
            t = next()
        ) {
            if (t.isErr()) {
                errors.add(t.error);
                continue;
            }
            if (t.value.shouldLexerSkip()) continue;
            tokens.add(t.value);
        }

        if (errors.length > 0) return Result.err(errors);
        return Result.ok(tokens);
    }

    Result<Token, LexerError> next() {
        if (!source.canIndex(pos)) return Result.ok(Token(TokenType.EOF, "", pos.clone()));

        if (shouldLexWhiteSpace()) return Result.ok(lexWhiteSpace());
        if (shouldLexMultiLineComment()) return lexMultiLineComment();
        if (shouldLexSingleLineComment()) return Result.ok(lexSingleLineComment());
        if (shouldLexDelimiters()) return Result.ok(lexDelimiters());
        if (shouldLexIdentifier()) return Result.ok(lexIdentifier());
        if (shouldLexString()) return lexString();
        
        var errorPos = pos.clone();
        pos.advance(1);
        return Result.err(InvalidToken(errorPos, source[errorPos.index]));
    }

    bool shouldLexString() {
        String ch = source[pos.index];
        return ch == '"' || ch == "'";
    }

    Result<Token, LexerError> lexString() {
        var startPos = pos.clone();
        String quote = source[pos.index];
        StringBuffer buffer = StringBuffer();
        Map<String, String> escapes = {
            'n': '\n',
            't': '\t',
            '"': '"',
            "'": "'",
            '\\': '\\',
        };
        pos.advance(1);
        
        while (source.canIndex(pos)) {
            String ch = source[pos.index];
            if (ch == '\\') {
                if (!source.canIndex(pos, 1)) break;
                String nextCh = source[pos.index + 1];
                if (escapes.containsKey(nextCh)) buffer.write(escapes[nextCh]!);
                else return Result.err(InvalidEscapeCharacter(pos.clone(), nextCh));
                pos.advance(2);
                continue;
            }
            if (ch == quote) break;
            buffer.write(ch);
            pos.advance(1);
        }
        if (pos.index >= source.length) return Result.err(UnclosedString(startPos));
        pos.advance(1);
        return Result.ok(Token(TokenType.String, buffer.toString(), startPos));
    }

    bool shouldLexWhiteSpace() => source[pos.index].isWhiteSpace();

    Token lexWhiteSpace() {
        while (source.canIndex(pos) && shouldLexWhiteSpace()) {
            String ch = source[pos.index];
            pos.advance(1);
            if (ch.isNewLine()) pos.nextLine();
        }
        return Token(TokenType.White, "", pos.clone());
    }

    bool shouldLexDelimiters() => tokenTypeMap.containsKey(source[pos.index]);

    Token lexDelimiters() {
        var startPos = pos.clone();
        String ch = source[pos.index];
        pos.advance(ch.length);
        return Token(tokenTypeMap[ch]!, ch, startPos);
    }

    bool shouldLexIdentifier() {
        String ch = source[pos.index];
        return ch.isAlpha() || ch == "_";
    }

    Token lexIdentifier() {
        var startPos = pos.clone();
        pos.advance(1);
        while (source.canIndex(pos) && source[pos.index].isAlphaNumericOrUnderscore()) {
            pos.advance(1);
        }

        return Token(TokenType.Ident, source.substring(startPos.index, pos.index), startPos);
    }

    bool shouldLexSingleLineComment() => source[pos.index] == '#';

    Token lexSingleLineComment() {
        var startPos = pos.clone();
        while (source.canIndex(pos) && !source[pos.index].isNewLine()) pos.advance(1);
        pos.advance(1);
        pos.nextLine();
        return Token(TokenType.Comment, "", startPos);
    }
    
    bool shouldLexMultiLineComment() {
        if (!source.canIndex(pos, 1)) return false;
        return source.substring(pos.index, pos.index + 2) == "#[";
    }
    
    Result<Token, LexerError> lexMultiLineComment() {
        var startPos = pos.clone();
        pos.advance(2);
        int level = 1;
        while (source.canIndex(pos, 1) && level != 0) {
            String slice = source.substring(pos.index, pos.index + 2);
            String ch = source[pos.index];
            if (slice == "#[") level += 1;
            else if (slice == "]#") level -= 1;
            pos.advance(1);
            if (ch.isNewLine()) pos.nextLine();
        }
        pos.advance(2);
        if (level != 0) return Result.err(UnclosedComment(startPos));
        return Result.ok(Token(TokenType.Comment, "", startPos));
    }

    //bool hasErrors() => errors.length > 0;
}

void main() {
    String str = File("../examples/ex1.tg").readAsStringSync();
    var l = Lexer(str);
    
    while (l.pos.index < l.source.length) {
        var t2 = l.next();
        if (t2.isErr()) print(t2.error);
        var t = t2.value;
        if (t.type == TokenType.Comment || t.type == TokenType.White) continue;
        print("Type: ${t.type}");
        print("Span: ${t.span}");
        print(">> ");
        stdin.readLineSync();
    }
    
}

extension StringUtils on String {
    bool canIndex(LexerPosition pos, [int offset = 0]) => pos.index + offset < this.length;

    bool isWhiteSpace() => this.trim().isEmpty;

    bool isNewLine() => this == "\n";

    bool isAlpha() {
        int code = this.codeUnitAt(0);
        return (code >= 65 && code <= 90) || // A-Z
            (code >= 97 && code <= 122); // a-z
    }

    bool isDigit() {
        int code = this.codeUnitAt(0);
        return code >= 48 && code <= 57; // 0-9
    }

    bool isAlphaNumericOrUnderscore() => this.isAlpha() || this.isDigit() || this == "_";
}

/*
    // Lambda assigned to a variable
    var add = (int a, int b) => a + b;
    print(add(2, 3)); // 5

    // Equivalent to:
    var addVerbose = (int a, int b) {
    return a + b;
    };

    int Function(int, int) multiply = (int a, int b) => a * b;
    print(multiply(4, 5)); // 20
 */