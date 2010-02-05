/**
* ...
* @author Chase Kernan
*/

package hxeme.prims;

import hxeme.Errors;
import hxeme.Locals;
import hxeme.parsing.Parser;
import hxeme.object.XemeString;
import hxeme.object.XemeSpecialForm;
import hxeme.object.XemeGeneric;
import hxeme.object.XemePair;
import hxeme.object.XemeSymbol;

class Quote {

    public static var DEFINED_FORMS = [{name : "quote", func : quote}];

    public static function quote(locals : Locals, 
                                 eval   : EvalFunc, 
                                 args   : List<Expr>) 
                                        : XemeGeneric {
        if (args.length != 1) {
            throw ArgMismatch(new XemeString("quote"), 1, args.length);
        }
        
        return switch (args.pop()) {
            case ERef(name): new XemeSymbol(name);
            case EXeme(x):   x;
            
            case EList(list):
                var values = new List<XemeGeneric>();
                for (item in list) {
                    values.add(quote(locals, eval, Lambda.list([item])));
                }
                
                return XemePair.makeList(values);
        };
    }    
}