/**
 * ...
 * @author Chase Kernan
 */

package hxeme.object;

class XemeBool extends XemeGeneric {
    
    inline public static var TYPE_NAME = "XemeBool";
	
	public static var TRUE  = new XemeBool(true);
	public static var FALSE = new XemeBool(false);
	
	var value : Bool;
	
	public function new(value : Bool) {
		super();
		
		this.value = value;
	}
	
	override public function getValue() : Dynamic {
		return value;
	}
    
    override public function getTypeName() : String {
        return TYPE_NAME;
    }
	
	override public function toString() {
		return if (value) "#t" else "#f";
	}
	
}