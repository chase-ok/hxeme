/**
* ...
* @author Chase Kernan
*/

package hxeme.utils;

import hxeme.object.XemeObject;
import hxeme.object.XemeGeneric;
import hxeme.Errors;

class ObjUtils {

    inline public static function checkIsObj(value : XemeGeneric) {
        if (value.getTypeName() != XemeObject.TYPE_NAME) {
            throw TypeError(value, XemeObject.TYPE_NAME);
        }
    }
    
    inline public static function ensureObj(value : XemeGeneric) : XemeObject {
        checkIsObj(value);
        
        return cast(value, XemeObject);
    }
    
}
