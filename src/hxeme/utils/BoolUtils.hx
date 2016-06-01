/**
* ...
* @author Chase Kernan
*/

package hxeme.utils;

import hxeme.object.XemeGeneric;
import hxeme.object.XemeBool;
import hxeme.Errors;
import hxeme.prims.boolean.BasicLogic;

class BoolUtils {

    inline public static function checkIsBool(value : XemeGeneric) {
        if (value != XemeBool.TRUE && value != XemeBool.FALSE ) {
            throw TypeError(value, XemeBool.TYPE_NAME);
        }
    }
    
    inline public static function ensureBool(value : XemeGeneric) : XemeBool {
        checkIsBool(value);
        
        return cast(value, XemeBool);
        //return untyped value;
    }
    
    public static inline function wrapXemeBool(b : Bool) : XemeBool {
        return if (b) XemeBool.TRUE else XemeBool.FALSE;
    }
    
}
