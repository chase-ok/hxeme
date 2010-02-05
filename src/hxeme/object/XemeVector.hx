/**
 * ...
 * @author Chase Kernan
 */

package hxeme.object;

import hxeme.Errors;

class XemeVector extends XemeGeneric {
    
    inline public static var TYPE_NAME = "XemeVector";

	var values : Array<XemeGeneric>;
	
	public function new(values : Array<XemeGeneric>) {
		super();
		
		this.values = values;
	}
	
	override public function getValue() : Dynamic {
		return values;
	}
    
    public function getValueAt(index : Int) : XemeGeneric {
        if (index < 0 || index >= values.length) {
            throw FailedBoundsCheck(this, index);
        }
        
        return values[index];
    }
    
    public function setValueAt(index : Int, value : XemeGeneric) {
        if (index < 0 || index >= values.length) {
            throw FailedBoundsCheck(this, index);
        }
        
        values[index] = value;
    }
	
	override public function toString() {
        var result = "#(";
        for (value in values) result += Std.string(value) + " ";
        
		return result + ")";
	}
    
    override public function getTypeName() : String {
        return TYPE_NAME;
    }
    
    inline public static function makeVector(args : List<XemeGeneric>) 
                                                  : XemeVector {
        return new XemeVector(Lambda.array(args));
	}
	
}