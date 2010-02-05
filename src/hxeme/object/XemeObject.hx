/**
 * ...
 * @author Chase Kernan
 */

package hxeme.object;

import hxeme.prims.Api;

class XemeObject extends XemeGeneric {
    
    inline public static var TYPE_NAME = "XemeObject";

	var value : Dynamic;
	
	public function new(value : Dynamic) {
		super();
		
		this.value = value;
	}
	
	override public function getValue() : Dynamic {
		return value;
	}
    
    override public function getTypeName() : String {
        return TYPE_NAME;
    }
    
    public function getField(path : String) : XemeGeneric {
        var fields = path.split(".");
        var obj    = value;
        for (field in fields) obj = Reflect.field(obj, field);
        
        return Api.convertToXeme(obj);
    }
    
    public function setField(path : String, v : XemeGeneric) {
        var fields = path.split(".");
        var last   = fields.pop();
        var obj    = value;
        for (field in fields) obj = Reflect.field(obj, field);
        
        Reflect.setField(obj, last, Api.convertFromXeme(v));
    }
    
    public function callField(path : String, 
                              args : List<XemeGeneric>) 
                                   : XemeGeneric {
        var fields = path.split(".");
        var last   = fields.pop();
        var obj    = value;
        for (field in fields) obj = Reflect.field(obj, field);
        
        var conv = new Array<Dynamic>();
        for (arg in args) conv.push(Api.convertFromXeme(arg));
        
        var method = Reflect.field(obj, last);
        return Api.convertToXeme(Reflect.callMethod(obj, method, conv)); 
    }
	
	override public function toString() {
		return "XemeObject[" + value + "]";
	}
}

/*

(-> obj 'field)               => obj.field
(.= obj 'field value)         => obj.field = value
(-> obj 'field1.field2)       => obj.field1.field2
(.= obj 'field1.field2 value) => obj.field1.field2 = value

({} :name "test" :val 1 :field 'bar)

*/