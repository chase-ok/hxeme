/**
 * ...
 * @author Chase Kernan
 */

package hxeme.object;

import hxeme.Errors;

typedef XemeFuncType = List<XemeGeneric> -> XemeGeneric;

class XemeFunc extends XemeGeneric {
	
    public static inline var TYPE_NAME    = "XemeFunc";
	public static inline var NO_ARG_COUNT = -1;
	
	var numArgs : Int;
	var func    : XemeFuncType;
	
	public function new(func : XemeFuncType, numArgs : Int) { 
        super();
        
		this.func    = func;
		this.numArgs = numArgs;
	}
    
    public function getNumArgs() : Int {
        return numArgs;
    }
	
	override public function getValue() : Dynamic {
		return this;
	}
	
	override public function call(args : List<XemeGeneric>) : XemeGeneric {
		if (numArgs != NO_ARG_COUNT) {
            var count = 0;
            for (arg in args) count++;
            if(count != numArgs) throw ArgMismatch(this, numArgs, count);
		}
		
		return func(args);
	}
    
    override public function getTypeName() : String {
        return TYPE_NAME;
    }
	
	override public function toString() {
        var args = if (numArgs == NO_ARG_COUNT) "Inf" 
                   else                         Std.string(numArgs);
		return "XemeFunc[(num-args " + args + ")]";
	}
	
}