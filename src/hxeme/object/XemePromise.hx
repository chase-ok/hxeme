/**
* ...
* @author Chase Kernan
*/

package hxeme.object;

import hxeme.Locals;
import hxeme.parsing.Parser;
import hxeme.object.XemeSpecialForm;

class XemePromise extends XemeGeneric {

    inline public static var TYPE_NAME = "XemePromise";
	
	var expr   : Expr;
    var locals : Locals;
    var value  : XemeGeneric;
	
	public function new(locals : Locals, expr : Expr) {
		super();
		
        this.locals = locals;
		this.expr   = expr;
        value       = null;
	}
	
	override public function getValue() : Dynamic {
		return this;
	}
	
	override public function toString() {
		return "XemePromise[calc'd? " + (value != null) + "]";
	}
    
    override public function getTypeName() : String {
        return TYPE_NAME;
    }
    
    public function force(outsideLoc : Locals, eval : EvalFunc) : XemeGeneric {
        if (value == null) {
            outsideLoc.append(locals);
            value = eval(expr);
            outsideLoc.restore(locals);
        }
        
        return value;
    }
}