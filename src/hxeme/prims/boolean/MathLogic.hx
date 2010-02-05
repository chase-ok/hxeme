package hxeme.prims.boolean;

import hxeme.object.XemeBool;
import hxeme.object.XemeFunc;
import hxeme.object.XemeGeneric;
import hxeme.object.XemeNum;
import hxeme.utils.BoolUtils;
import hxeme.utils.MathUtils;

class MathLogic {
    
    static inline var INF_ARGS = XemeFunc.NO_ARG_COUNT;
    
    public static var DEFINED_PRIMS  = [
            { name : "<",     func : lt,       numArgs : INF_ARGS },
            { name : "<=",    func : lte,      numArgs : INF_ARGS },
            { name : ">",     func : gt,       numArgs : INF_ARGS },
            { name : ">=",    func : gte,      numArgs : INF_ARGS },
            { name : "odd?",  func : isOdd,    numArgs : 1 },
            { name : "even?", func : isEven,   numArgs : 1 },
            { name : "zero?", func : isZero,   numArgs : 1 },
        ];
    
    public static function isOdd(args : List<XemeGeneric>) : XemeBool {
        return BoolUtils.wrapXemeBool(getNumValue(args.first()) % 2 == 1);
    }
    
    public static function isEven(args : List<XemeGeneric>) : XemeBool {
        return BoolUtils.wrapXemeBool(getNumValue(args.first()) % 2 == 0);
    }
    
    public static function isZero(args : List<XemeGeneric>) : XemeBool {
        return BoolUtils.wrapXemeBool(getNumValue(args.first()) == 0.0);
    }
        
    public static function lt(args : List<XemeGeneric>) : XemeBool {
        return compareNumList(args,
            function (prev : Float, next : Float) { return prev < next; }
        );
    }
    
    public static function lte(args : List<XemeGeneric>) : XemeBool {
        return compareNumList(args,
            function (prev : Float, next : Float) { return prev <= next; }
        );
    }
    
    public static function gt(args : List<XemeGeneric>) : XemeBool {
        return compareNumList(args,
            function (prev : Float, next : Float) { return prev > next; }
        );
    }
    
    public static function gte(args : List<XemeGeneric>) : XemeBool {
        return compareNumList(args,
            function (prev : Float, next : Float) { return prev >= next; }
        );
    }
    
    inline static function getNumValue(num : XemeGeneric) : Float {
        return untyped MathUtils.ensureNum(num).getValue();
    }
    
    //er for some reason the inline here is broken on flash
    #if neko inline #end 
    static function compareNumList(args    : List<XemeGeneric>,
                                   compare : Float -> Float -> Bool) 
                                           : XemeBool {
        //can only have 1 return call in an inline function so a big 
        //if-clause is needed
        return if (args.length <= 1) XemeBool.TRUE else { 
        
        var value  = getNumValue(args.pop());
        var retVal = XemeBool.TRUE;
        
        for (arg in args) {
            var next = getNumValue(arg);
            
            if (!compare(value, next)) {
                retVal = XemeBool.FALSE;
                break;
            }
            
            value = next;
        }
        
        retVal; //return is from the above if-statement
        
        }; 
    }
    
}