import 'lexer-pos.dart';
import 'token.dart';

sealed class ParserError {
    LexerPosition pos;
    ParserError(this.pos);
}

class UnexpectedEOF extends ParserError {
    UnexpectedEOF(LexerPosition pos) : super(pos);
}

class UnexpectedType extends ParserError {
    final TokenType expected, found;
    UnexpectedType(LexerPosition pos, { required this.expected, required this.found}) : super(pos);
}

class ExpectedName extends ParserError {
    final TokenType type;
    ExpectedName(LexerPosition pos, this.type) : super(pos);
}

class ExpectedValues extends ParserError {
    final TokenType type;
    ExpectedValues(LexerPosition pos, this.type) : super(pos);
}

class UnexpectedToken extends ParserError {
    final TokenType type;
    UnexpectedToken(LexerPosition pos, this.type) : super(pos);
}