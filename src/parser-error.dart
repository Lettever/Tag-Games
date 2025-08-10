import 'token.dart';

sealed class ParserError { }

class UnexpectedEOF extends ParserError { }

class UnexpectedType extends ParserError {
    final TokenType expected, found;
    UnexpectedType({ required this.expected, required this.found});
}

class ExpectedName extends ParserError {
    final TokenType type;
    ExpectedName(this.type);
}

class ExpectedValues extends ParserError {
    final TokenType type;
    ExpectedValues(this.type);   
}

class UnexpectedToken extends ParserError {
    final TokenType type;
    UnexpectedToken(this.type);   
}