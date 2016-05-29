/**
 * ...
 * @author Chase Kernan
 */

package hxeme.utils;

import haxe.ds.GenericStack;
//import haxe.FastList;
import hxeme.parsing.Parser;
import hxeme.Errors;
import hxeme.object.XemeGeneric;
import hxeme.object.XemePair;

class ListUtils {
    
    inline public static function getNames(e : Expr) : List<String> {
        var names = new List<String>();
        
        switch(e) {  
            case EList(list):
                for (item in list) {
                    switch (item) {
                        case ERef(name): names.add(name);
                        default:         throw Unexpected(Std.string(item));
                    }
                }
            default: 
                throw Unexpected(Std.string(e));
        }
        
        return names;
    }
    
    inline public static function checkIsList(value : XemeGeneric) {
        if (value.getTypeName() != XemePair.TYPE_NAME) {
            throw TypeError(value, XemePair.TYPE_NAME);
        }
    }
    
    inline public static function ensureList(value : XemeGeneric) : XemePair {
        checkIsList(value);
        
        return cast(value, XemePair);
    }
    
    inline public static function append(tail  : XemePair, 
                                         value : XemeGeneric) 
                                               : XemePair {
        var cell = new XemePair(value, XemePair.EMPTY_LIST);
        tail.cdr = cell;
        return cell;
    }
    
}
