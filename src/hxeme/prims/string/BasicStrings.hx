/**
* ...
* @author Chase Kernan
*/

package hxeme.prims.string;

import hxeme.object.XemeFunc;
import hxeme.object.XemeNum;
import hxeme.object.XemeString;
import hxeme.object.XemeGeneric;
import hxeme.prims.PrimitiveManager;
import hxeme.utils.StringUtils;

class BasicStrings {
    
    public static function init() {
        PrimitiveManager.PRIMITIVES.set("DQUOTE", new XemeString("\""));
        PrimitiveManager.PRIMITIVES.set("SQUOTE", new XemeString("'"));
    }

    static inline var INF_ARGS       = XemeFunc.NO_ARG_COUNT;
    public static var DEFINED_PRIMS  = [
            { name : "string-append", func : stringAppend, numArgs : INF_ARGS },
            { name : "to-string",     func : toString,     numArgs : 1 },
            { name : "string-length", func : stringLength, numArgs : 1 },
        ];
    
    public static function stringAppend(args : List<XemeGeneric>) : XemeGeneric {
        var val = "";
        for (arg in args) val += StringUtils.ensureString(arg).getValue();
        
        return new XemeString(val);
    }
    
    public static function toString(args : List<XemeGeneric>) : XemeGeneric {
        return new XemeString(args.pop().toString()); //TODO: FINISH
    }
    
    public static function stringLength(args : List<XemeGeneric>) : XemeGeneric {  
        return new XemeNum(
                StringUtils.ensureString(args.first()).getValue().length);
    }

    
}