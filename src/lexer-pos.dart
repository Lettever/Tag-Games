class LexerPosition {
    int index = 0;
    int line = 1;
    int column = 0;

    void advance(int len) {
        index += len;
        column += len;
    }

    void nextLine() {
        column = 0;
        line += 1;
    }

    LexerPosition clone() {
        var l = LexerPosition();
        l.index = this.index;
        l.column = this.column;
        l.line = this.line;
        return l;
    }
}