import 'lexer-pos.dart';
import 'token.dart';

sealed class ParserError {
    LexerPosition pos;
    ParserError(this.pos);
}

class UnexpectedEOF extends ParserError {
    UnexpectedEOF(LexerPosition pos) : super(pos);
    String toString() => "Found EOF when I shouldn't";
}

class UnexpectedType extends ParserError {
    final TokenType expected, found;
    UnexpectedType(LexerPosition pos, { required this.expected, required this.found}) : super(pos);
    String toString() => "Expected $expected, but found $found at line = ${pos.line} column = ${pos.column}";
}

class ExpectedName extends ParserError {
    final TokenType type;
    ExpectedName(LexerPosition pos, this.type) : super(pos);
    String toString() => "Expected string of identifier, but found $type at line = ${pos.line} column = ${pos.column}";
}

class ExpectedValues extends ParserError {
    final TokenType type;
    ExpectedValues(LexerPosition pos, this.type) : super(pos);
    String toString() => "Expected values, but found $type at line = ${pos.line} column = ${pos.column}";
}

class UnexpectedToken extends ParserError {
    final TokenType type;
    UnexpectedToken(LexerPosition pos, this.type) : super(pos);
    String toString() => "Unexpecter $type at line = ${pos.line} column = ${pos.column}";
}