/**
* ...
* @author Chase Kernan
*/

package hxeme.prims;

import hxeme.Locals;
import hxeme.object.XemeObject;
import hxeme.object.XemeSpecialForm;
import hxeme.object.XemeGeneric;
import hxeme.object.XemeFunc;
import hxeme.object.XemeString;
import hxeme.utils.FuncUtils;
import hxeme.parsing.Parser;
import hxeme.Errors;

class RuntimeErrors {

    static inline var INF_ARGS = XemeFunc.NO_ARG_COUNT;
    
    public static var DEFINED_FORMS  = [ 
            { name : "try", func : xemeTry },
        ];
        
    public static var DEFINED_PRIMS  = [
            { name : "throw", func : xemeThrow, numArgs : 1 },
        ];
        
    public static function xemeThrow(args : List<XemeGeneric>) : XemeGeneric {
        throw new XemeError(args.first());
        
        return null;
    }
    
    public static function xemeTry(locals : Locals,
                                   eval   : EvalFunc,
                                   args   : List<Expr>)
                                          : XemeGeneric {
        if (args.length != 2) {
            throw ArgMismatch(new XemeString("try"), 2, args.length);
        }
        
        var iter = args.iterator();
        
        try {
            return eval(iter.next());
        } catch (e : XemeError) {
            var funcArgs = new List<XemeGeneric>();
            funcArgs.add(e.value);
            return FuncUtils.ensureFunc(eval(iter.next())).call(funcArgs);
        } catch (e : Dynamic) {
            var funcArgs = new List<XemeGeneric>();
            funcArgs.add(new XemeObject(e));
            return FuncUtils.ensureFunc(eval(iter.next())).call(funcArgs);
        }
    }
    
}

class XemeError {
    
    public var value : XemeGeneric;
    
    public function new(value : XemeGeneric) {
        this.value = value;
    }
}