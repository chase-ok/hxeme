/**
 * ...
 * @author Chase Kernan
 */

package hxeme.object;

//import haxe.FastList;
import hxeme.utils.ListUtils;

class XemePair extends XemeGeneric {
	
    inline public static var TYPE_NAME = "XemePair";
    
	public static var EMPTY_LIST        = new XemePair(XemeGeneric.NIL, 
                                                       XemeGeneric.NIL);
    public static var MAX_LIST_LENGTH   = 100;
	
	public var car : XemeGeneric;
	public var cdr : XemeGeneric;
	
	public function new(car : XemeGeneric, cdr : XemeGeneric) {
		super();
		
		this.car = car;
		this.cdr = cdr;
	}
	
	override public function getValue() : Dynamic {
		return this;
	}
    
    inline public function isEmptyList() : Bool {
        return car == XemeGeneric.NIL && cdr == XemeGeneric.NIL;
    }
	
	public static function makeList(args : List<XemeGeneric>) : XemePair {
        if (args.isEmpty()) return EMPTY_LIST;
		
		var cur  = new XemePair(args.pop(), EMPTY_LIST);
        var head = cur;
        
		for (arg in args) {
            var next = new XemePair(arg, EMPTY_LIST);
            cur.cdr  = next;
            cur      = next;
        }
		
		return head;
	}
	
	public function getTail() : XemePair {
		var tail = this;
		
		while (true) {
			var tailCdr = tail.cdr;
			
			if (tailCdr == EMPTY_LIST || tailCdr.getTypeName() != TYPE_NAME) {
				return tail;
			}
			
			tail = cast( tailCdr, XemePair);
		}
		
		throw "Uh oh";
	}
    
    public function copy() : XemePair {
        if (this == EMPTY_LIST) return EMPTY_LIST;
        
        var newCar = if (car.getTypeName() == TYPE_NAME) untyped car.copy()
                     else                                        car;
        var newCdr = if (cdr.getTypeName() == TYPE_NAME) untyped cdr.copy()
                     else                                        cdr;
        return new XemePair(newCar, newCdr);
    }
    
    override public function getTypeName() {
        return TYPE_NAME;
    }
	
	override public function toString() : String {
		if (this == EMPTY_LIST) return "()";
		
		var cdrType = cdr.getTypeName();
		var result  = "(" + car.toString();
		
		if (cdrType != TYPE_NAME) return result + " . " + cdr.toString() + ")";
		
		//its a list...
        
        var cell : XemePair = untyped cdr;
        var count           = 0;
        
        while (count++ < MAX_LIST_LENGTH) {
            if (cell == EMPTY_LIST) return result + ")";
            
            result += " " + cell.car.toString();
            
            if (cell.cdr.getTypeName() != TYPE_NAME) {
                return result + " . " + cell.cdr.toString() + ")";
            }
            
            cell = cast cell.cdr;
        }
        
        return result + "...)";
	}
    
    public function iterator() : Iterator <XemeGeneric> {
        var pair = this;
        
		return {
			next: 
                function() {
                    var item = pair.car;
                    pair     = untyped pair.cdr;
                    return item;
                }
            ,
			hasNext: 
                function() {
                    return pair.getTypeName() == TYPE_NAME && pair != null
                           && pair != EMPTY_LIST;
                }
            ,
		};
    }
}
