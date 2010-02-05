/**
 * ...
 * @author Chase Kernan
 */

package hxeme.object;

class XemeSymbol extends XemeGeneric {
    
    inline public static var TYPE_NAME = "XemeSymbol";
	
	var name : String;
	
	public function new(name : String) {
		super();
		
		this.name = name;
	}
	
	override public function getValue() : Dynamic {
		return name;
	}
	
	override public function toString() {
		return name;
	}
    
    override public function getTypeName() : String {
        return TYPE_NAME;
    }
	
}