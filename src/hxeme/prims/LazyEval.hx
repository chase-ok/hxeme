/**
* ...
* @author Chase Kernan
*/

package hxeme.prims;

import hxeme.Errors;
import hxeme.object.XemePromise;
import hxeme.object.XemeGeneric;
import hxeme.Locals;
import hxeme.object.XemeSpecialForm;
import hxeme.parsing.Parser;

class LazyEval {

    public static var DEFINED_FORMS = [
            { name : "delay", func : delay },
            { name : "force", func : force },
        ];

    public static function delay(locals : Locals, 
                                  eval   : EvalFunc, 
                                  args   : List<Expr>) 
                                         : XemeGeneric {
        if (args.length != 1) throw ArgMismatch(null, 1, args.length); //FIXME
        
        return new XemePromise(locals.clone(), args.first());
    }
    
    public static function force(locals : Locals, 
                                 eval   : EvalFunc, 
                                 args   : List<Expr>) 
                                        : XemeGeneric {
        if (args.length != 1) throw ArgMismatch(null, 1, args.length); //FIXME
        
        var value = eval(args.first());
        if (value.getTypeName() != XemePromise.TYPE_NAME) {
            throw TypeError(value, XemePromise.TYPE_NAME);
        }
        
        var promise : XemePromise = untyped value;
        
        return promise.force(locals, eval);
    }
        
}