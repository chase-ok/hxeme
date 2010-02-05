/**
 * ...
 * @author Chase Kernan
 */

package hxeme.prims;

import hxeme.Locals;
import hxeme.object.XemeFunc;
import hxeme.parsing.Parser;
import hxeme.object.XemeGeneric;
import hxeme.object.XemeSpecialForm;
import hxeme.prims.SpecialForms;
import hxeme.Errors;
import hxeme.utils.ListUtils;

class XemeLambda {
    
    public static var DEFINED_FORMS = [{name : "lambda", func : lambda}];

    public static function lambda(locals : Locals, 
                           eval   : EvalFunc, 
                           args   : List<Expr>) 
                                  : XemeGeneric {
        var captured = locals.clone();
        var argNames = ListUtils.getNames(args.pop());
        var body     = args;
        
        var f = function(fArgs : List<XemeGeneric>) : XemeGeneric {
            locals.append(captured);
            locals.createLevel();
            
            for (name in argNames) locals.setLocal(name, fArgs.pop());
            
            var v = null;
            for (expr in body) v = eval(expr);
            
            locals.removeLevel();
            locals.restore(captured);
            
            return v;
        };
        
        return new XemeFunc(f, argNames.length);
    }
    
}