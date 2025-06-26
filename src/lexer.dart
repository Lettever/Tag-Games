import './token.dart';
import './lexer.pos.dart';

// import 'dart:collection';
// import 'dart:io';

class Lexer {
    Lexer(this.source);
    final String source;
    var pos = LexerPosition();
    //int index = 0, line = 1, column = 0;
    List<String> errors = [];

    final Map<String, TokenType> TokenTypeMap = {
        "=": TokenType.Equals,
        ";": TokenType.SemiColon,
        ".": TokenType.Dot,
        "{": TokenType.L_Bracket,
        "}": TokenType.R_Bracket,
    };

    void advance(String span) {
        pos.index += span.length;
        pos.column += span.length;
    }

    Token makeAndAdvance(TokenType type, String span) {
        pos.index += span.length;
        pos.column += span.length;
        return Token(type, span);
    }

    Token next() {
        if (!source.canIndex(pos)) return Token(TokenType.EOF, "");
        if (shouldLexWhiteSpace()) return lexWhiteSpace();
        if (shouldLexMultiLineComment()) return lexMultiLineComment();
        if (shouldLexSingleLineComment()) return lexSingleLineComment();
        if (shouldLexDelimites()) return lexDelimiters();

        return Token(TokenType.Error, "this shouldn't happen");
    }

    bool shouldLexWhiteSpace() => source[pos.index].isWhiteSpace();

    Token lexWhiteSpace() {
        while (source.canIndex(pos) && shouldLexWhiteSpace()) {
            String ch = source[pos.index];
            pos.index += 1;
            pos.column += 1;
            if (ch == '\n') {
                pos.line += 1;
                pos.column = 0;
            }
        }
        return Token(TokenType.White, "");
    }

    bool shouldLexDelimites() => TokenTypeMap.containsKey(source[pos.index]);

    Token lexDelimiters() {
        String ch = source[pos.index];
        return makeAndAdvance(TokenTypeMap[ch]!, ch);
    }

    bool shouldLexSingleLineComment() => source[pos.index] == '#';

    Token lexSingleLineComment() {
        while (source.canIndex(pos) && (source[pos.index] != '\n')) {
            pos.index += 1;
            pos.column += 1;
        }
        pos.index += 1;
        pos.column += 1;
        return Token(TokenType.Comment, "");
    }
    
    bool shouldLexMultiLineComment() {
        if (!source.canIndex(pos)) return false;
        return source.substring(pos.index, pos.index + 2) == "#[";
    }
    
    Token lexMultiLineComment() {
        print("\x1b[1;34m\x1b[1;41mNOT DONE\x1b[1;39m\x1b[1;49m");
        pos.index += 2;
        int level = 1;
        while (source.canIndex(pos, 1) && level != 0) {
            String slice = source.substring(pos.index, pos.index + 2);
            print(slice.length);
            if (slice == "#[") level += 1;
            else if (slice == "]#") level -= 1;
            pos.column += 1;
            if (source[pos.index] == "\n") pos.line += 1;
            pos.index += 1;
        }
        pos.index += 2;
        return Token(TokenType.Comment, "");
    }
}

void main() {
    var l = Lexer("    #foo \n{#[  \n]#\r\t{{{..;;}}}");
    while (l.pos.index < l.source.length) {
        var t = l.next();
        print("Type: ${t.type}");
        print("Span: ${t.span}");
        print("");
    }
}

extension StringUtils on String {
    bool canIndex(LexerPosition pos, [int offset = 0]) => pos.index + offset < this.length;
    bool isWhiteSpace() => this.trim().isEmpty;
    String? safeIndex(int index) {
        final runes = this.runes.toList();
        if (index < 0 || index >= runes.length) return null;
        return String.fromCharCode(runes[index]);
    }
}