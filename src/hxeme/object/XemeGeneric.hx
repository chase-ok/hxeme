/**
 * ...
 * @author Chase Kernan
 */

package hxeme.object;

import hxeme.Errors;

class XemeGeneric {
    
    inline public static var TYPE_NAME = "XemeGeneric";
	
	public static var NIL = new XemeGeneric();
    
	public function new() { }
	
	public function getValue() : Dynamic {
		return null;
	}
	
	public function call(args : List<XemeGeneric>) : XemeGeneric {
		throw CannotCall(this);
        
        return null; //needs this for some reason?
	}
    
    public function getTypeName() : String {
        return TYPE_NAME;
    }
	
	public function toString() {
		return "NIL";
	}
}