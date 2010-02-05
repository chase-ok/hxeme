/**
* ...
* @author Chase Kernan
*/

package hxeme.prims;

import hxeme.object.XemeFunc;
import hxeme.object.XemeGeneric;
import hxeme.utils.FuncUtils;

class Continuations {
    
    public static var ID_COUNT       = 0;
    public static var DEFINED_PRIMS  = [
    //        { name : "call-with-current-continuation", 
    //                            func : callCC, numArgs : 1 },
    //        { name : "call/cc", func : callCC, numArgs : 1 },
        ];

    public static function callCC(args : List<XemeGeneric>) : XemeGeneric {  
        var func = FuncUtils.ensureFunc(args.pop());
        var id   = ID_COUNT++;
        
        try {
            var escapeFunc    =
                function(escapeArgs : List<XemeGeneric>) : XemeGeneric {
                    throw new ContinuationReturn(id, escapeArgs.first());
                    
                    return null; //compiler really shouldn't require this
                };
                
            var list = new List<XemeGeneric>();
            list.add(new XemeFunc(escapeFunc, 1));
            return func.call(list);
        } catch (e : ContinuationReturn) {
            if (e.id == id) return e.value;
            else {
                #if neko
                    neko.Lib.rethrow(e);
                #end
                throw e;
            }
        }
    }
    
}

class ContinuationReturn {
    
    public var id    : Int;
    public var value : XemeGeneric;
    
    public function new(id : Int, value : XemeGeneric) {
        this.id    = id;
        this.value = value;
    }
    
}