import './token.dart';
import './lexer.pos.dart';

class Lexer {
    Lexer(this.source);
    final String source;
    final pos = LexerPosition();
    List<String> errors = [];

    final Map<String, TokenType> tokenTypeMap = {
        "=": TokenType.Equals,
        ";": TokenType.SemiColon,
        ".": TokenType.Dot,
        "{": TokenType.L_Bracket,
        "}": TokenType.R_Bracket,
    };

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
            pos.advance(1);
            if (ch == "\n") pos.nextLine();
        }
        
        return Token(TokenType.White, "" /*source.substring(i, pos.index)*/);
    }

    bool shouldLexDelimites() => tokenTypeMap.containsKey(source[pos.index]);

    Token lexDelimiters() {
        String ch = source[pos.index];
        pos.advance(ch.length);
        return Token(tokenTypeMap[ch]!, ch);
    }

    bool shouldLexSingleLineComment() => source[pos.index] == '#';

    Token lexSingleLineComment() {
        while (source.canIndex(pos) && !source[pos.index].isNewLine()) pos.advance(1);
        pos.advance(1);
        pos.nextLine();
        return Token(TokenType.Comment, "");
    }
    
    bool shouldLexMultiLineComment() {
        if (!source.canIndex(pos, 1)) return false;
        return source.substring(pos.index, pos.index + 2) == "#[";
    }
    
    Token lexMultiLineComment() {
        //print("\x1b[1;34m\x1b[1;41mNOT DONE\x1b[1;39m\x1b[1;49m");
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
        if (level != 0) return Token(TokenType.Error, "unclosed comment here");
        return Token(TokenType.Comment, "1");
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
    bool isNewLine() => this == "\n";
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