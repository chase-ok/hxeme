/**
 * ...
 * @author Chase Kernan
 */

package hxeme.parsing;

import haxe.Int32;
import hxeme.Errors;
import hxeme.object.XemeGeneric;
import hxeme.object.XemeNum;
import hxeme.object.XemeString;
import hxeme.object.XemeSymbol;
import hxeme.parsing.Tokenizer;

enum Expr {
    ERef(name : String);
    EList(list : List<Expr>);
    EXeme(x : XemeGeneric);
}

class Parser {

    public static var IDENTIFIERS = "abcdefghijklmnopqrstuvwxyz!<>=+-/*_:.{}'#" +
                                    "?\"";
    public static var IDENT_HASH = {
        var hash = new Map<String, Bool>();
        for (i in 0...IDENTIFIERS.length) {
            hash.set(IDENTIFIERS.charAt(i), true);
        }
        hash;
    };

    var tokens : List<Token>;
    
    public function new() { }
    
    public function parse(tokens : List<Token>) : List<Expr> {
        this.tokens = tokens;
        var exprs   = new List<Expr>();
        
        while (!tokens.isEmpty()) exprs.add(parseExpr());
        
        return exprs;
    }
    
    function parseExpr() : Expr {
        switch (tokens.pop()) {
            
            case TData(value):
                return handleData(value);
                
            case TRightParen:
                throw Unexpected("')'");
                
            case TLeftParen:
                var children = new List<Expr>();
                
                while (true) {
                    if (tokens.isEmpty()) throw Expected("')'");
                    
                    var next = tokens.pop();
                    switch (next) { 
                        
                        case TRightParen:  
                            return EList(children);
                            
                        default: 
                            tokens.push(next);
                            children.add(parseExpr());
                    }
                }
                
                throw AssertFailed;
        }
        return null;
    }
    
    function handleData(value : String) : Expr {
        if (value.length == 0) throw Unexpected("(empty data)");
        if (value.length == 1) {
            switch (value) {
                case "'": return handleQuote();
                case "#": return handleVector();
                default:  //nothing special...
            }
        }
        
        var firstChar = value.charAt(0);
        
        if (firstChar == "'") return EXeme(new XemeSymbol(value.substr(1)));
        
        if (firstChar == "-" && value.length != 1) {
            return EXeme(parseNum(value));
        }
        
        if (firstChar == "\"") {
            return EXeme(new XemeString(value.substr(1, value.length - 2)));
        }
        
        if (isIdentifier(firstChar)) return ERef(value);
        
        return EXeme(parseNum(value));
    }
    
    function parseNum(data : String) : XemeNum {
        if (data.substr(0, 2) == "0x") {
            //taken from hscript
            var n   = 0;//Int32.ofInt(0);
            var hex = data.substr(2);
            
			for (i in 0...hex.length) {
                var char = hex.charCodeAt(i);
				switch (char) {
					case 48,49,50,51,52,53,54,55,56,57: // 0-9
						n = n << 4 + cast(char - 48); // haxe.Int32.add(haxe.Int32.shl(n,4), cast (char - 48));
					case 65,66,67,68,69,70: // A-F
						n = n << 4 + cast(char - 55); //haxe.Int32.add(haxe.Int32.shl(n,4), cast (char - 55));
					case 97,98,99,100,101,102: // a-f
						n = n << 4 + cast(char - 87); //haxe.Int32.add(haxe.Int32.shl(n,4), cast (char - 87));
					default:
                        throw Unexpected(char);
                }
            }
            
            return new XemeNum(n);
        }
        
        var parsedNum = Std.parseFloat(data);
        if (parsedNum == Math.NaN) throw UnrecognizedSymbol(data);
        
        return new XemeNum(parsedNum);
    }
    
    function handleSpecialList(name : String) : Expr {
        var list = new List<Expr>();
        list.add(ERef(name));
        
        var top = tokens.pop();
        switch (top) {
            case TLeftParen: //good...
            default:         throw Unexpected(Std.string(top));
        }
        
        while (true) {
            if (tokens.isEmpty()) throw Expected("')'");
            var next = tokens.pop();
            switch (next) { 
                
                case TRightParen: 
                    return EList(list);
                    
                case TLeftParen:  
                    tokens.push(next);
                    list.add(handleSpecialList(name));
                    
                default: 
                    tokens.push(next);
                    
                    list.add(switch(parseExpr()) {
                        case ERef(name):  EXeme(new XemeSymbol(name));
                        case EXeme(x):    EXeme(x);
                        case EList(list): EList(list);
                    });
                    
            }
        }
        
        throw "The world has ended! True is no long true!";
    }
    
    inline function handleQuote() : Expr {
        var list = new List<Expr>();
        list.add(ERef("quote"));
        list.add(parseExpr());
        
        return EList(list);
    }
    
    inline function handleVector() : Expr {
        var list = new List<Expr>();
        list.add(ERef("vector"));
        list.add(handleQuote());
        
        return EList(list);
    }
    
    inline function isIdentifier(char : String) : Bool {
        //implicit null check
        return IDENT_HASH.get(char.toLowerCase()) == true; 
    }
    
}
