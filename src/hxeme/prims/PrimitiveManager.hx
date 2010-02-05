/**
 * ...
 * @author Chase Kernan
 */

package hxeme.prims;

import hxeme.object.XemeBool;
import hxeme.object.XemeFunc;
import hxeme.object.XemeGeneric;
import hxeme.prims.boolean.BasicLogic;
import hxeme.prims.lists.BasicLists;
import hxeme.prims.numeric.BasicMath;
import hxeme.prims.string.BasicStrings;
import hxeme.prims.vectors.BasicVectors;
import hxeme.prims.boolean.MathLogic;
import hxeme.prims.func.BasicFunc;
import hxeme.prims.obj.BasicObj;

#if neko
import neko.Sys;
#end

class PrimitiveManager {
    
    public static var PRIMITIVES   : Hash<XemeGeneric>;
    public static var PRIM_CLASSES : Array<Class<Dynamic>> = cast [
            BasicMath, BasicLogic, BasicLists, BasicVectors, MathLogic, 
            BasicFunc, Continuations, BasicObj, BasicStrings, RuntimeErrors,
            Help,
        ];
    
    static var initialized = false;
    
    public static function init() {
        initialized = true;
        PRIMITIVES  = new Hash();
        
        #if neko
            PRIMITIVES.set("exit", new XemeFunc(
                function (args : List<XemeGeneric>) : XemeGeneric {
                    Sys.exit(0);
                    return null;
                },
                0)
            );
        #end
        
        for (c in PRIM_CLASSES) initClass(c);
    }
    
    public static function registerClass(c : Class<Dynamic>) {
        PRIM_CLASSES.push(c);
        initClass(c);
    }
    
    inline public static function isInitialized() : Bool {
        return initialized;
    }
    
    public static function setPrimitive(name : String, value : XemeGeneric) {
        PRIMITIVES.set(name, value);
    }
    
    public static function getPrimitive(name : String) : XemeGeneric {
        return PRIMITIVES.get(name);
    }
    
    static function initClass(c : Class<Dynamic>) {
        if (Reflect.hasField(c, "init")) {
            Reflect.callMethod(c, Reflect.field(c, "init"), []);
        }
        
        var defined : Iterable<Dynamic> = Reflect.field(c, "DEFINED_PRIMS");
        for (prim in defined) {
            PRIMITIVES.set(prim.name, new XemeFunc(prim.func, prim.numArgs));
        }
    }
    
}