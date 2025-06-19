enum TokenType {
    Equals,
    Dot,
    SemiColon,
    L_Bracket,
    R_Bracket,

    String,    
    Ident,

    Error,

    // ignored by parser
    Comment,
    White,
}

class Token {
    final TokenType type;
    final String span;
    Token(this.type, this.span);

    String getSpan() {
        if (type == TokenType.String) return span.substring(1, span.length - 1);
        return span; 
    }
}