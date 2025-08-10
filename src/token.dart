import 'lexer-pos.dart';

enum TokenType {
    Equals,
    Dot,
    SemiColon,
    L_Bracket,
    R_Bracket,

    String,    
    Ident,

    EOF,
    Error,

    // ignored by parser
    Comment,
    White,
}

class Token {
    final TokenType type;
    final String span;
    final LexerPosition pos;
    Token(this.type, this.span, this.pos);

    @override
    String toString() => "type: ${type}, span: $span";
    bool shouldLexerSkip() => type == TokenType.Comment || type == TokenType.White || type == TokenType.Error;
    bool canBeAName() => type == TokenType.String || type == TokenType.Ident;
}