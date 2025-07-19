import 'lexer.pos.dart';

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
    bool shouldParserSkip() => type == TokenType.Comment || type == TokenType.White;
    bool canBeAName() => type == TokenType.String || type == TokenType.Ident;
}