// Section one .. user code that is copied verbatim into the top of the generated lexer file

%%

// Section two ... options and declare constants

%class Lexer     // Name of the class to produce with this flex def
%unicode         // Defines the charset to be scanned
%line            // Switch on line counting - helpful for error messages
%type Token      // specify the return type of the tokens


%{
    // Code here gets copied verbatim to the beginning of the Lexer class

    // helper functions to create tokens
    private Token token(Tok type) {
        return new Token(type, yyline+1); // to access line number which starts from 0
    }

    private Token token(Tok type, Object value) { // allows passing in of a lexene
        if (type == Tok.STRING) // because we want to use the line where the string started
            return new Token(type, stringStartLine, value);
        else
            return new Token(type, yyline+1, value);
    }

    int CommentNesting = 0; // to support nested comments

    StringBuffer string = new StringBuffer(); // to build up strings

    int stringStartLine = 0; // for error output - should be the starting line of a string
%}


// macro/constants regex for different token types

Identifier = [a-z][_A-Za-z0-9]*
IntegerLiteral = [0-9]+
Type = [A-Z][_A-Za-z0-9]*

LineTerminator = \r|\n|\r\n
InputCharacter = [^\r\n]
Whitespace = {LineTerminator} | [\u000b\u000c\t ]

/* comments */
// Comment can be the last line of the file, without line terminator.
EndOfLineComment     = "--" {InputCharacter}* {LineTerminator}?
CommentContent       = [^]


%state COMMENT
%state STRING


%%


// Section three ... lexical analysis rules
// (if lexer matches a pattern, return some token type); could specify more states for certain rules
// lexer state: every rule starts from initial state
// regex, then code to execute when lexene matched

// Note: reserved keywords are case insensitive, except for true/false
// if Capitalize first letter of True/False, it becomes a type
// if Capitalize any other letter of tRUE/fALSE, it is still a keyword

<YYINITIAL> {
    "@"                                     { return token(Tok.AT); }
    [Cc][Aa][Ss][Ee]                        { return token(Tok.CASE); }
    [Cc][Ll][Aa][Ss][Ss]                    { return token(Tok.CLASS); }
    ":"                                     { return token(Tok.COLON); }
    ","                                     { return token(Tok.COMMA); }
    "/"                                     { return token(Tok.DIVIDE); }
    "."                                     { return token(Tok.DOT); }
    [Ee][Ll][Ss][Ee]                        { return token(Tok.ELSE); }
    "="                                     { return token(Tok.EQUALS); }
    [Ee][Ss][Aa][Cc]                        { return token(Tok.ESAC); }
    f[Aa][Ll][Ss][Ee]                       { return token(Tok.FALSE); }
    [Ff][Ii]                                { return token(Tok.FI); }
    [Ii][Ff]                                { return token(Tok.IF); }
    [Ii][Nn]                                { return token(Tok.IN); }
    [Ii][Nn][Hh][Ee][Rr][Ii][Tt][Ss]        { return token(Tok.INHERITS); }
    [Ii][Ss][Vv][Oo][Ii][Dd]                { return token(Tok.ISVOID); }
    "<-"                                    { return token(Tok.LARROW); }
    "{"                                     { return token(Tok.LBRACE); }
    "<="                                    { return token(Tok.LE); }
    [Ll][Ee][Tt]                            { return token(Tok.LET); }
    [Ll][Oo][Oo][Pp]                        { return token(Tok.LOOP); }
    "("                                     { return token(Tok.LPAREN); }
    "<"                                     { return token(Tok.LT); }
    "-"                                     { return token(Tok.MINUS); }
    [Nn][Ee][Ww]                            { return token(Tok.NEW); }
    [Nn][Oo][Tt]                            { return token(Tok.NOT); }
    [Oo][Ff]                                { return token(Tok.OF); }
    "+"                                     { return token(Tok.PLUS); }
    [Pp][Oo][Oo][Ll]                        { return token(Tok.POOL); }
    "=>"                                    { return token(Tok.RARROW); }
    "}"                                     { return token(Tok.RBRACE); }
    ")"                                     { return token(Tok.RPAREN); }
    ";"                                     { return token(Tok.SEMI); }
    [Tt][Hh][Ee][Nn]                        { return token(Tok.THEN); }
    "~"                                     { return token(Tok.TILDE); }
    "*"                                     { return token(Tok.TIMES); }
    t[Rr][Uu][Ee]                           { return token(Tok.TRUE); }
    [Ww][Hh][Ii][Ll][Ee]                    { return token(Tok.WHILE); }

    // use macro to match identifier rule; use yytext() to access the actual data

    {Identifier}                            { return token(Tok.IDENTIFIER, yytext()); }

    {IntegerLiteral}                        {
                                                try {
                                                    return token(Tok.INTEGER, Integer.parseInt(yytext())); // use parseInt to remove leading 0's
                                                } catch (NumberFormatException e) {
                                                    System.out.println("ERROR: " + (yyline + 1) + ": Lexer: not a non-negative 32-bit signed integer: " + yytext());
                                                    System.exit(1);
                                                }
                                            }

    {Type}                                  { return token(Tok.TYPE, yytext()); }

    // need to manually decrement yyline, because JFlex considers those escape sequences line terminators
    // \v, \f, \r match these ascii values
    [\u000b\u000c\u000d]                    { yyline--; }

    {Whitespace}                            { /* ignore */ }

    {EndOfLineComment}                      {}

    "(*"                                    { CommentNesting = 1; yybegin(COMMENT); }

    \"                                      { stringStartLine = yyline + 1; string.setLength(0); yybegin(STRING); }
}


<COMMENT> {
    "*)"                                    { CommentNesting--; if (CommentNesting == 0) yybegin(YYINITIAL); }
    "(*"                                    { CommentNesting++; }
    {CommentContent}                        {}

    <<EOF>>                                 { System.out.println("ERROR: " + (yyline + 1) + ": Lexer: EOF in (* comment *)"); System.exit(1); }
}


<STRING> {
    \"                                      {
                                                if (string.length() <= 1024) {
                                                    yybegin(YYINITIAL);
                                                        return token(Tok.STRING,
                                                        string.toString());
                                                } else {
                                                    System.out.println("ERROR: " + stringStartLine + ": Lexer: string constant is too long (" + string.length() + " > 1024)"); System.exit(1);
                                                }
                                            }

    [\\][\u0000]                            { System.out.println("ERROR: " + (yyline + 1) + ": Lexer: invalid character: \""); System.exit(1); }
    [\u0000]                                { System.out.println("ERROR: " + (yyline + 1) + ": Lexer: invalid character: \""); System.exit(1); }
    {LineTerminator}                        { System.out.println("ERROR: " + (yyline + 1) + ": Lexer: invalid character: \""); System.exit(1); }
    [^\\\"]                                 { string.append(yytext()); }
    [\\].                                   { string.append(yytext()); }
    <<EOF>>                                 { System.out.println("ERROR: " + (yyline + 1) + ": Lexer: invalid character: \""); System.exit(1); }
    }


// error fallback
    [^]                                     { System.out.println("ERROR: " + (yyline + 1) + ": Lexer: invalid character: " + yytext()); System.exit(1); }
