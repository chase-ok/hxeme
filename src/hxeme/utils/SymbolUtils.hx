/**
* ...
* @author Chase Kernan
*/

package hxeme.utils;

import hxeme.object.XemeSymbol;
import hxeme.object.XemeGeneric;
import hxeme.Errors;

class SymbolUtils {

    inline public static function checkIsSymbol(value : XemeGeneric) {
        if (value.getTypeName() != XemeSymbol.TYPE_NAME) {
            throw TypeError(value, XemeSymbol.TYPE_NAME);
        }
    }
    
    inline public static function ensureSymbol(value : XemeGeneric) : XemeSymbol {
        checkIsSymbol(value);
        
        return untyped value;
    }
    
    inline public static function getName(value : XemeSymbol) : String {
        return untyped value.getValue();
    }
    
}