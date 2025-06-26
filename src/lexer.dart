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
        if (shouldLexDelimiters()) return lexDelimiters();
        if (shouldLexIdentifier()) return lexIdentifier();
        pos.advance(1);
        return addError("idk what (${source[pos.index]}) at ${pos.line} ${pos.column}");
    }

    bool shouldLexWhiteSpace() => source[pos.index].isWhiteSpace();

    Token lexWhiteSpace() {
        while (source.canIndex(pos) && shouldLexWhiteSpace()) {
            String ch = source[pos.index];
            pos.advance(1);
            if (ch == "\n") pos.nextLine();
        }
        return Token(TokenType.White, "");
    }

    bool shouldLexDelimiters() => tokenTypeMap.containsKey(source[pos.index]);

    Token lexDelimiters() {
        String ch = source[pos.index];
        pos.advance(ch.length);
        return Token(tokenTypeMap[ch]!, ch);
    }

    bool shouldLexIdentifier() {
        String ch = source[pos.index];
        return ch.isAlpha() || ch == "_";
    }

    Token lexIdentifier() {
        var index = pos.index;
        pos.advance(1);
        while (source.canIndex(pos) && source[pos.index].isAlphaNumericOrUnderscore()) {
            pos.advance(1);
        }
        return Token(TokenType.Ident, source.substring(index, pos.index));
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
        if (level != 0) return addError("Unclosed comment at ${startPos.line} ${startPos.column}");
        return Token(TokenType.Comment, "");
    }

    Token addError(String error) {
        errors.add(error);
        return Token(TokenType.Error, error);
    }

    bool hasErrors() => errors.length > 0;
}


void main() {
    var l = Lexer("123#[    #foo \n{#[  \n]#\r\t{{{..;;}}}");
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

    bool isNewLine() => this == "\n";

    bool isAlpha() {
        int code = this.codeUnitAt(0);
        return (code >= 65 && code <= 90) || // A-Z
            (code >= 97 && code <= 122); // a-z
    }

    bool isDigit() {
        int code = this.codeUnitAt(0);
        return code >= 48 && code <= 57; // ASCII codes for '0' to '9'
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