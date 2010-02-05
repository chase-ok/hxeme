/**
 * ...
 * @author Chase Kernan
 */

package hxeme.object;

class XemeString extends XemeGeneric {
    
    inline public static var TYPE_NAME = "XemeString";

	var value : String;
	
	public function new(value : String) {
		super();
		
		this.value = value;
	}
	
	override public function getValue() : Dynamic {
		return value;
	}
	
	override public function toString() {
		return '"' + value + '"';
	}
    
    override public function getTypeName() : String {
        return TYPE_NAME;
    }
	
}