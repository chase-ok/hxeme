package hxeme.prims.numeric;

import hxeme.object.XemeBool;
import hxeme.object.XemeNum;
import hxeme.object.XemeFunc;
import hxeme.object.XemeGeneric;
import hxeme.Errors;
import hxeme.utils.MathUtils;

class BasicMath {
    
    static inline var INF_ARGS       = XemeFunc.NO_ARG_COUNT;
    public static var DEFINED_PRIMS  = [
            { name : "+",      func : add,    numArgs : INF_ARGS },
            { name : "-",      func : sub,    numArgs : INF_ARGS },
            { name : "*",      func : mult,   numArgs : INF_ARGS },
            { name : "/",      func : div,    numArgs : INF_ARGS },
            { name : "random", func : random, numArgs : 0 },
            { name : "abs",    func : abs,    numArgs : 1 },
        ];
    
    public static function add(args : List<XemeGeneric>) : XemeGeneric {
        var sum = 0.0;
        for (arg in args) sum += MathUtils.ensureNum(arg).getValue();
        return new XemeNum(sum);
    }
    
    public static function sub(args : List<XemeGeneric>) : XemeGeneric {
        if (args.length == 0) throw NotEnoughArgs(1, 0);
        
        var sum = MathUtils.ensureNum(args.pop()).getValue();
        if (args.length == 0) return new XemeNum(-1 * sum);
        
        for (arg in args) untyped sum -= MathUtils.ensureNum(arg).getValue();
        return new XemeNum(sum);
    }
    
    public static function mult(args : List<XemeGeneric>) : XemeGeneric {
        var prod = 1.0;
        for (arg in args) prod *= MathUtils.ensureNum(arg).getValue();
        return new XemeNum(prod);
    }
    
    public static function div(args : List<XemeGeneric>) : XemeGeneric {
        if (args.length == 0) throw NotEnoughArgs(1, 0);
        
        var prod = MathUtils.ensureNum(args.pop()).getValue();
        if (args.length == 0) return new XemeNum(1 / prod);
        
        for (arg in args) {
            var value = MathUtils.ensureNum(arg).getValue();
            if (value == 0) throw DivideByZero;
            
            untyped prod /= value;
        }
        
        return new XemeNum(prod);
    }
    
    public static function random(args : List<XemeGeneric>) : XemeGeneric {
        return new XemeNum(Math.random());
    }
    
    public static function abs(args : List<XemeGeneric>) : XemeGeneric {
        return new XemeNum(
                Math.abs(MathUtils.ensureNum(args.first()).getValue()));
    }
    
    inline static function checkNumber(value : XemeGeneric) {
        if (value.getTypeName() != XemeNum.TYPE_NAME) {
            throw TypeError(XemeNum.TYPE_NAME, value.getTypeName());
        }
    }
    
}