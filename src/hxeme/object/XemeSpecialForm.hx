/**
 * ...
 * @author Chase Kernan
 */

package hxeme.object;

import hxeme.parsing.Parser;
import hxeme.Locals;

typedef EvalFunc    = Expr -> XemeGeneric;
typedef SpecialForm = Locals -> EvalFunc -> List<Expr> -> XemeGeneric;

class XemeSpecialForm extends XemeGeneric {
	
    public static inline var TYPE_NAME    = "XemeSpecialForm";
	
	var func    : SpecialForm;
	
	public function new(func : SpecialForm) { 
        super();
        
		this.func    = func;
	}
	
	override public function getValue() : Dynamic {
		return func;
	}
    
    override public function getTypeName() : String {
        return TYPE_NAME;
    }
	
	override public function toString() {
		return "XemeSpecialForm";
	}
	
}