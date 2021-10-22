// An enumeration type
public enum Tok {
    // the valid types allowed
    AT("at"), // a call to the internal constructor to return a string
    CASE("case"),
    CLASS("class"),
    COLON("colon"),
    COMMA("comma"),
    DIVIDE("divide"),
    DOT("dot"),
    ELSE("else"),
    EQUALS("equals"),
    ESAC("esac"),
    FALSE("false"),
    FI("fi"),
    IDENTIFIER("identifier"),
    IF("if"),
    IN("in"),
    INHERITS("inherits"),
    INTEGER("integer"),
    ISVOID("isvoid"),
    LARROW("larrow"),
    LBRACE("lbrace"),
    LE("le"),
    LET("let"),
    LOOP("loop"),
    LPAREN("lparen"),
    LT("lt"),
    MINUS("minus"),
    NEW("new"),
    NOT("not"),
    OF("of"),
    PLUS("plus"),
    POOL("pool"),
    RARROW("rarrow"),
    RBRACE("rbrace"),
    RPAREN("rparen"),
    SEMI("semi"),
    STRING("string"),
    THEN("then"),
    TILDE("tilde"),
    TIMES("times"),
    TRUE("true"),
    TYPE("type"),
    WHILE("while");

    // a mechanism to convert an enum to a string
    private final String name;

    private Tok(String s) {
        name = s;
    }

    public String toString() {
        return name;
    }
}
