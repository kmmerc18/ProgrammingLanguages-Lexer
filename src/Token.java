// A class to contain a token type and its associated data
public class Token {
    private Tok tokType; // enum type - what are the valid token types?
    private int line;
    private Object value; // associated lexeme

    // a constructor
    public Token(Tok tokType, int line) {
        this.tokType = tokType;
        this.line = line;
    }

    // another kind of constructor with value initialized
    public Token(Tok tokType, int line, Object value) {
        this(tokType, line);
        this.value = value;
    }

    // toString method so we can print out tokens
    public String toString() {
        String toReturn = this.line + "\n" + this.tokType;
        if (value != null) {
            toReturn = toReturn + "\n" + this.value;
        }
        return toReturn;
    }

    public int getLine() { return this.line; }
}
