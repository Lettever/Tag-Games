import './lexer-pos.dart';

sealed class LexerError {
    final LexerPosition pos;
    LexerError(this.pos);
}

class InvalidEscapeCharacter extends LexerError {
    final String ch;
    InvalidEscapeCharacter(LexerPosition pos, this.ch) : super(pos);
    String toString() => "Invalid escape character ($ch) at line = ${pos.line}, column = ${pos.column}";
}

class UnclosedString extends LexerError {
    UnclosedString(LexerPosition pos) : super(pos);
    String toString() => "Unclosed String starting at line = ${pos.line}, column = ${pos.column}";
}

class UnclosedComment extends LexerError {
    UnclosedComment(LexerPosition pos) : super(pos);
    String toString() => "Unclosed comment starting at line = ${pos.line}, column = ${pos.column}";
}

class InvalidToken extends LexerError {
    final String token;
    InvalidToken(LexerPosition pos, this.token) : super(pos);
    String toString() => "Invalid token ($token) at: line = ${pos.line}, column = ${pos.column}";
}