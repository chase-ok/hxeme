/**
 * ...
 * @author Chase Kernan
 */

package hxeme;

import hxeme.object.XemeBool;
import hxeme.object.XemeNum;
import hxeme.object.XemePair;
import hxeme.object.XemeSpecialForm;
import hxeme.parsing.Parser;
import hxeme.object.XemeGeneric;
import hxeme.prims.PrimitiveManager;
import hxeme.prims.SpecialForms;

class Interp {

    public var locals : Locals;
    
    public function new() {
        if (!PrimitiveManager.isInitialized()) PrimitiveManager.init();
        if (!SpecialForms.isInitialized())     SpecialForms.init();
        if (!Modules.isInitialized())          Modules.init();
        
        locals = new Locals();
    }
    
    public function interpAll(exprs : List<Expr>) : Dynamic {
        return evalAll(exprs).getValue();
    }
    
    public function interp(expr : Expr) : Dynamic {
        return eval(expr).getValue();
    }
    
    public function evalAll(exprs : List<Expr>) : XemeGeneric {
        var v = null;
        for (expr in exprs) v = eval(expr);
        
        return v;
    }
    
    public function eval(expr : Expr) : XemeGeneric {
        return switch (expr) {
            case ERef(name):  locals.getLocal(name);
            case EXeme(x):    x;
            case EList(list): handleList(list);
        };
    }
    
    function handleList(list : List<Expr>) : XemeGeneric {
        if (list.length == 0) return XemePair.EMPTY_LIST;
        
        var copy = copyList(list);
        var func = eval(copy.pop());
        
        if (func.getTypeName() == XemeSpecialForm.TYPE_NAME) {
            var form = func.getValue();
            return form(locals, eval, copy);
        }
        
        var args = new List<XemeGeneric>();
        for (argExpr in copy) args.add(eval(argExpr));
        
        return func.call(args);
    }
    
    inline function copyList<T>(list : List<T>) : List<T> {
        var copy = new List<T>();
        for (item in list) copy.add(item);
        return copy;
    }
    
}