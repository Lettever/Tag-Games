import 'lexer.pos.dart';

enum LexerErrorType {
    InvalidEscapeCharacter,
    UnclosedString,
    UnclosedComment,
    InvalidToken,
}

class LexerError {
    LexerError(this.type, this.pos, [this.idk]);
    final LexerErrorType type;
    final LexerPosition pos;
    String? idk;
}

/*
Token(TokenType.Error, 'Invalid escape: \\$nextCh');
addError('Unclosed string literal starting at index $start');
addError("Unclosed comment at ${startPos.line} ${startPos.column}");
"Invalid token (${source[pos.index]}) at: line = ${pos.line} column = ${pos.column}"
 */