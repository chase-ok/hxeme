package hxeme.utils;

import hxeme.object.XemeFunc;
import hxeme.object.XemeGeneric;
import hxeme.Errors;

class FuncUtils {
	
	inline public static function checkIsFunc(value : XemeGeneric) {
        if (value.getTypeName() != XemeFunc.TYPE_NAME) {
            throw TypeError(value, XemeFunc.TYPE_NAME);
        }
    }
    
    inline public static function ensureFunc(value : XemeGeneric) : XemeFunc {
        checkIsFunc(value);
        
        return untyped value;
    }
}