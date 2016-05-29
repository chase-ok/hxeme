/**
* ...
* @author Chase Kernan
*/

package hxeme.utils;

import hxeme.object.XemeString;
import hxeme.object.XemeGeneric;
import hxeme.Errors;

class StringUtils {

    inline public static function checkIsString(value : XemeGeneric) {
        if (value.getTypeName() != XemeString.TYPE_NAME) {
            throw TypeError(value, XemeString.TYPE_NAME);
        }
    }
    
    inline public static function ensureString(value : XemeGeneric) : XemeString {
        checkIsString(value);
        
        return cast(value, XemeString);
    }
    
    inline public static function getValue(string : XemeString) : String {
        return  cast(string.getValue(), String);
    }
    
}
