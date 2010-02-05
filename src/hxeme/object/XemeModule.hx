/**
* ...
* @author Chase Kernan
*/

package hxeme.object;

import hxeme.Interp;
import hxeme.parsing.Parser;
import hxeme.prims.Api;
import hxeme.utils.ListUtils;
import hxeme.utils.StringUtils;
import hxeme.utils.SymbolUtils;

class XemeModule extends XemeObject {
    
	public function new(interp : Interp, prog : List<Expr>) {
        super(null);
        
        value    = { };
        var vars = new List<String>();
        var name = "";
        
        interp.locals.setLocal("export", new XemeFunc(
            function (args : List<XemeGeneric>) : XemeGeneric {
                name = StringUtils.getValue(
                            StringUtils.ensureString(args.pop()));
                
                for (v in ListUtils.ensureList(args.pop())) {
                    vars.push(SymbolUtils.getName(
                                    SymbolUtils.ensureSymbol(v)));
                }
                
                return new XemeSymbol(name);
            },
            2
        ));
        
        interp.evalAll(prog);
        
        for (v in vars) {
            Reflect.setField(value, v, 
                    Api.convertFromXeme(interp.locals.getLocal(v)));
        }
	}
    
    /*
    override public function getField(path : String) : XemeGeneric {
        var fields = path.split(".");
        var obj    = value;
        for (field in fields) obj = Reflect.field(obj, field);
        
        return obj;
    }
    
    override public function setField(path : String, v : XemeGeneric) {
        var fields = path.split(".");
        var last   = fields.pop();
        var obj    = value;
        for (field in fields) obj = Reflect.field(obj, field);
        
        Reflect.setField(obj, last, v);
    }
    
    override public function callField(path : String, 
                                       args : List<XemeGeneric>) 
                                            : XemeGeneric {
        var fields = path.split(".");
        var last   = fields.pop();
        var obj    = value;
        for (field in fields) obj = Reflect.field(obj, field);
        
        var conv = new Array<Dynamic>();
        for (arg in args) conv.push(arg);
        
        var method = Reflect.field(obj, last);
        return Reflect.callMethod(null, method, conv); 
    }
    */
	
	override public function toString() {
		return "XemeModule[" + value + "]";
	}
    
}