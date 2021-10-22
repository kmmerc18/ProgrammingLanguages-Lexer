    In main, we made use of an ArrayList to store Token objects which are read in by our lexer. Since our input file
is accepted as a command-line argument, we created a File object which might throw a FileNotFoundException; hence,
we wrapped it around a try-catch block. To read in our tokens, we used a while loop to add in those Token objects
into the ArrayList, and we only printed all tokens at the very end if no errors are encountered. Note that yylex(),
the function to read in tokens, requires an IOException to be handled; therefore, we made use of another try-catch block.

    In order to identify the possible tokens the lexer accepts, we declared an enumeration type and defined all valid
tokens allowed. We then used this enumeration type within another class called Token that represents a token type
and its associated data such as line number and the actual value if any. Because some types of tokens might not have
an associated value, such as the keyword "while", we also made two types of constructors to support this feature.
Finally, we wrote a custom toString() method based on the format of the COOL reference compiler, so that our program
can give a descriptive output.



    In Lexer.flex, we specify the mechanics of the lexer. The first section, for user code that is copied verbatim into 
the top of the generated lexer file, is empty because there is no information we thought crucial to the generated file.

    The second section contains declared constants. The first is the name of the class that we want to produce, the next is
the character set in use. The third option is a line counter that we made extensive use of in printing accurate and informative
error messages. The final option declares our tokens' return types. The next part is code to copy verbatim into the beginning of
the Lexer class, including helper functions for Token creation and global variables to help keep track of nested comments and
strings being read in. After this, we wrote constant regexes for different token types, including identifiers, integer literals,
types, line terminating characters, input characters, white space, and line comments. In the next part we found it useful to
write two additional states more than just the initial state for our lexer. These were a COMMENT and STRING state. Because both
block comments and strings begin and end with specific characters, and are not allowed to end with EOF before returning to the
initial state, it was important to establish these state-specific rules in the new states.

    The third section contains the lexical analysis rules we applied. This is a long list of regex that are valid in our lexer.
One of the most important factors is that all reserved keywords are case insensitive aside from true/false, which results in
strange looking, but very valid, regex such as [Cc][Aa][Ss][Ee]. These each return tokens based on the regex they match. The next
part of this section no longer matches regex with specific tokens attached, but categories with variable lexemes, such as
IntegerLiteral and Whitespace. In the associated rule to Identifier, for example, we are matching a number of options from the
macro regex written in section 2. The sections of note here include a try-catch in the IntegerLiteral option. In the try section,
we use parseInt to remove any leading zeros from integers. If the number being parsed is too large, it falls into the catch clause,
and prints out an error before exiting. "(*" will send the lexer to the COMMENT state to deal with potential comment nesting, and
\" will send the lexer to the STRING state to deal with potential invalidities in Strings.

    In addition, we added a separate rule for three special white space characters, namely, \v, \f, and \r, which correspond to
\u000b, \u000c, and \u000d in the unicode representation recognized by JFlex. Now, since JFlex regards these as line terminators
besides the new line character, the variable yyline is incremented automatically on these cases. This is undesirable, as it would
incorrectly alter the line count and produce a false output. Hence, we needed to explicitly decrement yyline each time one such
character is scanned.

    The COMMENT state keeps a tally of how many 'begin comment' symbols the lexer has seen, "(*". This variable was declared
globally in section 2. The CommentNesting variable is decremented at any closing comment symbol, "*)" until the counter reaches 0,
at which point the lexer will return to its initial state. However, if the number of opening and closing comment symbols does
not match, and thus the CommentNesting variable does not reach 0 by the end of the file, the COMMENT state reaches the <<EOF>>
rule and prints an error.

    The STRING state uses a string buffer to keep track of the string being processed, appending to it as each new symbol is
recognized. Strings cannot include a number of characters, including NUL, EOF, or any character that terminates lines, such as \r
or \n. Thus, if any of these occur, an error message is printed noting the line of the open quote preceeding any such character
or error.

    Finally, we included one final clause for if all else fails. This regex, [^], matches anything, so if no other regex matches
a lexeme, this rule matches and prints an error before exiting.



    For our good test cases, we included a string with escape sequences such as "\n"; the lexer should read it as it is,
since COOL does not interpret escape sequences. We also tested a few reserved keywords such as while, loop, and true
with arbitrary capitalizations, because COOL is case-insensitive regarding these except for true and false.
Note that if the first letter of true/false is capitalized, it is recognized as a type by the lexer; however,
if any other letter is capitalized, it is read in as a regular keyword instead. For the last test case, we included a
nested block comment with a few extra asterisks, since COOL supports nested comments and should ignore their content.

    In our bad test cases, we included invalid symbols such as question marks. We then tried a very large number that exceeds
the upper bound of an integer in COOL which is 2147483647. Similarly, strings in COOL also have upper bounds (1024 characters),
and COOL does not support multi-line strings. Finally, we included an unterminated comment to test its end-of-file response,
and our lexer should print out an error for all these bad test cases listed above.
