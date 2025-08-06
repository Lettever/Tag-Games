import 'lexer.pos.dart';

enum LexerErrorType {
    InvalidEscapeCharacter,
    UnclosedString,
    UnclosedComment,
    InvalidToken,
}

class LexerError {
    LexerError(this.type, this.pos, [this.extraInfo]);
    final LexerErrorType type;
    final LexerPosition pos;
    String? extraInfo;

    @override
    String toString() {
        return switch (type) {
            LexerErrorType.InvalidEscapeCharacter => "Invalid escape character (${extraInfo!})",
            LexerErrorType.UnclosedString => "Unclosed String starting at line = ${pos.line} column = ${pos.column}",
            LexerErrorType.UnclosedComment => "Unclosed comment starting at line = ${pos.line} column = ${pos.column}",
            LexerErrorType.InvalidToken => "Invalid token ($extraInfo!) at: line = ${pos.line} column = ${pos.column}",
        };
    }
}