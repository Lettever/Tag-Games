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
    Token(this.type, this.span);

    @override
    String toString() => "type: ${type}, span: $span";

    bool shouldParserSkip() => type == TokenType.Comment || type == TokenType.White;

    bool canBeAName() => type == TokenType.String || type == TokenType.Ident;
}