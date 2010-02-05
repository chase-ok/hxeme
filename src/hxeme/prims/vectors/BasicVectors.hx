package hxeme.prims.vectors;

import hxeme.object.XemeGeneric;
import hxeme.object.XemePair;
import hxeme.object.XemeVector;
import hxeme.object.XemeFunc;
import hxeme.utils.MathUtils;
import hxeme.Errors;

class BasicVectors {

    static inline var INF_ARGS       = XemeFunc.NO_ARG_COUNT;
    public static var DEFINED_PRIMS  = [
            { name : "vector",      func : vector,    numArgs : 1 },
            { name : "vector-ref",  func : vectorRef, numArgs : 2 },
            { name : "vector-set!", func : vectorSet, numArgs : 3 },
        ];
    
    public static function vector(args : List < XemeGeneric > ) : XemeGeneric {
        var arg = args.pop();
        
        return new XemeVector(switch (arg.getTypeName()) {
            case XemePair.TYPE_NAME:
                var a               = new Array<XemeGeneric>();
                var pair : XemePair = untyped arg;
                
                for (item in pair) a.push(item);
                a;
            
            default: [arg];
        });
    }
    
    public static function vectorRef(args : List<XemeGeneric>) : XemeGeneric {
        var vec   = ensureVec(args.pop());
        var index = MathUtils.ensureNum(args.pop());
        
        //TODO: allow floats in vector-ref?
        return vec.getValueAt(Std.int(index.getValue())); 
    }
    
    public static function vectorSet(args : List<XemeGeneric>) : XemeGeneric {
        var vec   = ensureVec(args.pop());
        var index = MathUtils.ensureNum(args.pop());
        var value = args.pop();
        
        vec.setValueAt(Std.int(index.getValue()), value);
        
        return XemePair.EMPTY_LIST;
    }
    
    inline static function ensureVec(value : XemeGeneric) : XemeVector {
        if (value.getTypeName() != XemeVector.TYPE_NAME) {
            throw TypeError(value.getTypeName(), XemeVector.TYPE_NAME);
        }
        
        return untyped value;
    }
    
}