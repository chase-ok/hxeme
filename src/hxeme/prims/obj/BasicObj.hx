/**
* ...
* @author Chase Kernan
*/

package hxeme.prims.obj;

import hxeme.object.XemeFunc;
import hxeme.object.XemeGeneric;
import hxeme.object.XemeObject;
import hxeme.object.XemeString;
import hxeme.object.XemeSymbol;
import hxeme.object.XemeSpecialForm;
import hxeme.prims.Api;
import hxeme.utils.ObjUtils;
import hxeme.Errors;
import hxeme.Locals;
import hxeme.parsing.Parser;

class BasicObj {
    
    static inline var INF_ARGS = XemeFunc.NO_ARG_COUNT;
    
    public static var DEFINED_PRIMS  = [
            { name : ".",   func : getField,  numArgs : 2 },
            { name : ".=",  func : setField,  numArgs : 3 },
            { name : "new", func : initClass, numArgs : INF_ARGS },
            { name : "=>",  func : callField, numArgs : INF_ARGS },
        ];
        
    public static var DEFINED_FORMS = [
            { name : "{}",     func : createObj },
            { name : "import", func : importClass },
        ];
    

    public static function createObj(locals : Locals, 
                                     eval   : EvalFunc, 
                                     args   : List<Expr>) 
                                            : XemeGeneric {
        if (args.length == 0) return new XemeObject({ });
        
        var obj : Dynamic = { };
        var iter          = args.iterator();
        
        while (true) {
            if (!iter.hasNext()) break;
            
            var nameExpr = iter.next();
            var name     = switch (nameExpr) {
                case ERef(ref): 
                    if (ref.charAt(0) != ":") throw "First char must be :";
                    ref.substr(1);
                    
                default:
                    throw Unexpected(nameExpr);
            };
            
            if (!iter.hasNext()) throw "Missing value for " + name;
            
            Reflect.setField(obj, name, Api.convertFromXeme(eval(iter.next())));
        }
        
        return new XemeObject(obj);
    }
    
    public static function importClass(locals : Locals, 
                                       eval   : EvalFunc, 
                                       args   : List<Expr>) 
                                              : XemeGeneric {
        if (args.length < 1) throw NotEnoughArgs(1, args.length);
        if (args.length > 2) throw "Too many args: " + args.length;
        
        var it        = args.iterator();
        var className = getString(eval(it.next()));
        
        var c         = Type.resolveClass(className);
        if (c == null) throw "Import failed";
        
        var defName = ""; //when combined this was throwing a VerifyError
        if (args.length == 1) defName = className.split(".").pop()
        else                  defName = getRefName(it.next());
        
        locals.setLocal(defName, new XemeObject(c));
        
        return new XemeSymbol(defName); 
        return null;
    }
    
    public static function initClass(args : List<XemeGeneric>) : XemeGeneric {  
        if (args.length < 1) throw NotEnoughArgs(1, args.length);
        
        var c     = ObjUtils.ensureObj(args.pop()).getValue();
        var cArgs = new Array<Dynamic>();
        
        for (arg in args) cArgs.push(Api.convertFromXeme(arg));
        
        return new XemeObject(Type.createInstance(c, cArgs));
    }
    
    public static function getField(args : List<XemeGeneric>) : XemeGeneric {
        var obj = ObjUtils.ensureObj(args.pop());
        return obj.getField(getString(args.pop()));
    }
    
    public static function setField(args : List<XemeGeneric>) : XemeGeneric {
        var obj  = ObjUtils.ensureObj(args.pop());
        var path = getString(args.pop());
        var val  = args.pop();
        obj.setField(path, val);
        
        return val;
    }
    
    public static function callField(args : List<XemeGeneric>) : XemeGeneric {  
        if (args.length < 2) throw NotEnoughArgs(1, args.length);
        
        var obj  = ObjUtils.ensureObj(args.pop());
        var path = getString(args.pop());
        return obj.callField(path, args);
    }
    
    inline static function getRefName(expr : Expr) : String {
        return switch(expr) {
            case ERef(name): name;
            default:         throw Unexpected(expr);
        }
    }
    
    inline static function getString(arg : XemeGeneric) : String {
        return switch (arg.getTypeName()) {
            case XemeSymbol.TYPE_NAME: untyped arg.name;
            case XemeString.TYPE_NAME: untyped arg.value;
            default:                   throw Unexpected(arg);
        };
    }
    
}