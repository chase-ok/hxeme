/**
 * ...
 * @author Chase Kernan
 */

package hxeme.object;

class XemeNum extends XemeGeneric {
    
    inline public static var TYPE_NAME = "XemeNum";

	var value : Float;
	
	public function new(value : Float) {
		super();
		this.value = value;
	}
	
	override public function getValue() : Dynamic {
		return value;
	}
	
	override public function toString() {
		return Std.string(value);
	}
	
    override public function getTypeName() : String {
        return TYPE_NAME;
    }
}