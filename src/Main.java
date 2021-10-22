import java.io.InputStreamReader;
import java.io.FileInputStream;
import java.io.File;
import java.util.ArrayList;
import java.io.IOException;
import java.io.FileNotFoundException;


public class Main {
    public static void main(String[] args) {
        // an arraylist of tokens read in
        ArrayList<Token> tokens = new ArrayList<>();

        try {
            // input file passed in as command line argument
            Lexer l = new Lexer(new InputStreamReader(new FileInputStream(new File(args[0]))));

            try {
                while (true) {
                    Token t = l.yylex(); // gives the next available token
                    if (t == null) { // if run out of tokens
                        // the lexer is done reading input
                        break;
                    } else {
                        // store each token that the lexer produces
                        tokens.add(t);
                    }
                }
            } catch (IOException e) {
                // yylex() requires this exception to be handled
                System.err.println(e.getLocalizedMessage());
            }

        } catch (FileNotFoundException e) { // File() may not exist
            System.err.println(e.getLocalizedMessage());
        }

        // if reached here, no errors; print output
        for (Token item : tokens) {
            System.out.println(item);
        }
    } // main()
} // class

// ant | ant clean | ant fullsubmit
// java -jar lexer.jar file.cl > file.cl-lex (test my lexer)
// cool --lex file.cl > file.cl-lex (use pre-built lexer)
