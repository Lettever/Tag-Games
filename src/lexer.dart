import './token.dart';
import 'dart:collection';
import 'dart:io';

class Lexer {
    Lexer(this.source);
    final String source;
    int index = 0, line = 1, column = 0;
    List<String> errors = [];

    final Map<String, TokenType> TokenTypeMap = {
        "=": TokenType.Equals,
        ";": TokenType.SemiColon,
        ".": TokenType.Dot,
        "{": TokenType.L_Bracket,
        "}": TokenType.R_Bracket,
    };

    Token makeAndAdvance(TokenType type, String span) {
        index += span.length;
        column += span.length;
        return Token(type, span);
    }

    Token? next() {
        if (index >= source.length) return null;
        
        if (shouldLexWhiteSpace()) return lexWhiteSpace();
        if (shouldLexMultiLineComment()) return lexMultiLineComment();
        if (shouldLexSingleLineComment()) return lexSingleLineComment();
        
        if (shouldLexDelimites()) return lexDelimiters();
        return null;
    }

    bool shouldLexWhiteSpace() {
        if (index >= source.length) return false;
        return source[index].isWhiteSpace();
    }

    Token lexWhiteSpace() {
        while (shouldLexWhiteSpace()) {
            String ch = source[index];
            index += 1;
            column += 1;
            if (ch == '\n') {
                line += 1;
                column = 0;
            }
        }
        return Token(TokenType.White, "");
    }

    bool shouldLexDelimites() => TokenTypeMap.containsKey(source[index]);

    Token lexDelimiters() {
        String ch = source[index];
        return makeAndAdvance(TokenTypeMap[ch]!, ch);
    }

    bool shouldLexSingleLineComment() => source[index] == '#';

    Token lexSingleLineComment() {
        while ((index < source.length) && (source[index] != '\n')) {
            index += 1;
            column += 1;
        }
        index += 1;
        column += 1;
        return Token(TokenType.Comment, "");
    }
    
    bool shouldLexMultiLineComment() {
        if (index + 1 >= source.length) return false;
        return source.substring(index, index + 2) == "#[";
    }
    
    Token lexMultiLineComment() {
        print("\x1b[1;34m\x1b[1;41mNOT DONE\x1b[1;39m\x1b[1;49m");
        index += 2;
        return Token(TokenType.Comment, "");
    }
}

void main() {
    var l = Lexer("    #foo \n{#[  \n\r\t{{{..;;}}}");
    while (l.index < l.source.length) {
        var t = l.next();
        print("Type: ${t?.type}");
        print("Span: ${t?.span}");
        print("");
    }
}

extension StringUtils on String {
    bool isWhiteSpace() => trim().isEmpty;
    String? safeIndex(int index) {
        final runes = this.runes.toList();
        if (index < 0 || index >= runes.length) return null;
        return String.fromCharCode(runes[index]);
    }
}