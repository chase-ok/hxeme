/**
 * ...
 * @author Chase Kernan
 */

package hxeme.parsing;

import haxe.io.Input;
import haxe.io.StringInput;
import haxe.io.Eof;

enum Token {
    TLeftParen;
    TRightParen;
    TData(value : String);
}

enum TokenizerError {
    EOF;
}

class Tokenizer {
    
    var tokens        : List<Token>;
    var input         : Input;
    var data          : String;
    var insideString  : Bool;
    
    public function new() { }
    
    public function tokenizeString(input : String) : List<Token> {
        return tokenize(new StringInput(input));
    }
    
    public function tokenize(input : Input) : List<Token> {
        tokens       = new List();
        this.input   = input;
        data         = null;
        insideString = false;
        
        while(true) {
            try readToken()
            catch (e : TokenizerError) {
                switch (e) {
                    
                    case EOF: 
                        if (data != null) {
                            tokens.add(TData(data)); 
                        }
                        break;
                        
                    default:  
                        throw e;
                }
            }
        }
        
        return tokens;
    }
    
    function readToken() {
        var char = readChar();
        if (isWhiteSpace(char)) return;
        
        switch (char) {
            
            case "(": tokens.add(TLeftParen);
            
            case ")": tokens.add(TRightParen);
            
            case "\"": 
                insideString = true;
                var string   = "\"";
                while (true) {
                    char = readChar();
                    
                    if (char == "\"") break;
                    else if (char == "\\") {
                        var next = readChar();
                        
                        if (next == "\"") {
                            string += "\"";
                            continue;
                        }
                        
                        char += next;
                    }
                    
                    string += char;
                }
                insideString = false;
                tokens.add(TData(string + "\""));
            
            default:
                data            = "";
                var foundLeftParen  = false;
                var foundRightParen = false;
                
                while (!isWhiteSpace(char)) {
                    if (char == "(") {
                        foundLeftParen = true;
                        break;
                    }
                    
                    if (char == ")") {
                        foundRightParen = true;
                        break;
                    }
                         
                    data += char;
                    char  = readChar();
                }
                
                tokens.add(TData(data));
                data = null;
                
                if (foundRightParen) tokens.add(TRightParen);
                if (foundLeftParen) tokens.add(TLeftParen);
             
        }
    }
                
    
    function readChar() : String {
        try {
            var c = getChar();
			
			if (!insideString && c == ";") {
				var end = c;
				while (end != "\n" && end != "\r") end = getChar();
				
				return end;
			}
			
			return c;
			
        } catch (e : Eof) {
            throw EOF;
        }
    }
	
	inline function getChar() : String {
		return String.fromCharCode(input.readByte());
	}
    
    inline function isWhiteSpace(char : String) : Bool {
        return char == " " || char == "\t" || char == "\r" || char == "\n";
    }
}