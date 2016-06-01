/**
 * ...
 * @author Chase Kernan
 */

package hxeme.utils;

import hxeme.object.XemeBool;
import hxeme.object.XemeGeneric;
import hxeme.object.XemeNum;
import hxeme.Errors;

class MathUtils {

    inline public static function checkIsNum(value : XemeGeneric) {
        if (value.getTypeName() != XemeNum.TYPE_NAME) {
            throw TypeError(value, XemeNum.TYPE_NAME);
        }
    }
    
    inline public static function ensureNum(value : XemeGeneric) : XemeNum {
        checkIsNum(value);
        
        return cast(value, XemeNum);
    }
    
}
