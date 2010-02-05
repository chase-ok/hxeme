package hxeme.prims.boolean;

import hxeme.Errors;
import hxeme.object.XemeBool;
import hxeme.object.XemeNum;
import hxeme.object.XemePair;
import hxeme.object.XemeSpecialForm;
import hxeme.object.XemeString;
import hxeme.prims.PrimitiveManager;
import hxeme.object.XemeGeneric;
import hxeme.object.XemeFunc;
import hxeme.utils.BoolUtils;
import hxeme.utils.ListUtils;
import hxeme.utils.MathUtils;
import hxeme.Locals;
import hxeme.parsing.Parser;

class BasicLogic {
    
    static inline var INF_ARGS = XemeFunc.NO_ARG_COUNT;
    
    public static var DEFINED_FORMS  = [ { name : "and", func : and },
                                         { name : "or",  func : or }];
    public static var DEFINED_PRIMS  = [
            { name : "=",          func : equals,      numArgs : INF_ARGS },
            { name : "eq?",        func : equals,      numArgs : INF_ARGS },
            { name : "null?",      func : isNull,      numArgs : 1 },
            { name : "empty?",     func : isEmpty,     numArgs : 1 },
            { name : "number?",    func : isNumber,    numArgs : 1 },
            { name : "pair?",      func : isPair,      numArgs : 1 },
            { name : "list?",      func : isList,      numArgs : 1 },
            { name : "procedure?", func : isProcedure, numArgs : 1 },
            { name : "atom?",      func : isAtom,      numArgs : 1 },
            { name : "not",        func : not,         numArgs : 1 },
            { name : "type",       func : getType,     numArgs : 1 },
            
        ];
    
    public static function init() {
        PrimitiveManager.setPrimitive("#t",   XemeBool.TRUE);
        PrimitiveManager.setPrimitive("#f",   XemeBool.FALSE);
        PrimitiveManager.setPrimitive("nil",  XemeGeneric.NIL);
        PrimitiveManager.setPrimitive("null", XemeGeneric.NIL);
    }
    
    public static function equals(args : List<XemeGeneric>) : XemeBool {
        if (args.length <= 1) return XemeBool.TRUE;
        
        var first    = args.pop();
        var typeName = first.getTypeName();
        var value    = first.getValue();
        
        for (arg in args) {
            if (arg.getTypeName() != typeName || arg.getValue() != value) {
                return XemeBool.FALSE;
            }
        }
        
        return XemeBool.TRUE;
    }
    
    public static function not(args : List<XemeGeneric>) : XemeBool {
        return if (BoolUtils.ensureBool(args.first()) == XemeBool.TRUE) 
                    XemeBool.FALSE
               else XemeBool.TRUE;
    }
    
    public static function isNull(args : List < XemeGeneric > ) : XemeBool {
        var arg = args.first();
        return BoolUtils.wrapXemeBool(arg == XemeGeneric.NIL ||
                                      arg == XemePair.EMPTY_LIST);
    }
    
    public static function isEmpty(args : List<XemeGeneric>) : XemeBool {
        return BoolUtils.wrapXemeBool(
                ListUtils.ensureList(args.first()).isEmptyList());
    }
    
    public static function isNumber(args : List<XemeGeneric>) : XemeBool {
        return BoolUtils.wrapXemeBool(
                args.first().getTypeName() == XemeNum.TYPE_NAME);
    }
    
    public static function isPair(args : List<XemeGeneric>) : XemeBool {
        return BoolUtils.wrapXemeBool(
                args.first().getTypeName() == XemePair.TYPE_NAME);
    }
    
    public static function isProcedure(args : List < XemeGeneric > ) : XemeBool {
        var typeName = args.first().getTypeName();
        return BoolUtils.wrapXemeBool(typeName == XemeFunc.TYPE_NAME || 
                                      typeName == XemeSpecialForm.TYPE_NAME);
    }
    
    public static function isList(args : List<XemeGeneric>) : XemeBool {
        var arg = args.first();
        if (arg.getTypeName() != XemePair.TYPE_NAME) return XemeBool.FALSE;
        
        var head : XemePair = untyped arg;
        return BoolUtils.wrapXemeBool(
                head.cdr.getTypeName() == XemePair.TYPE_NAME);
    }
    
    public static function isAtom(args : List<XemeGeneric>) : XemeBool {
        return BoolUtils.wrapXemeBool(
                args.first().getTypeName() != XemePair.TYPE_NAME);
    }
    
    public static function getType(args : List<XemeGeneric>) : XemeGeneric {  
        return new XemeString(args.first().getTypeName());
    }
    
    public static function and(locals : Locals, 
                               eval   : EvalFunc, 
                               args   : List<Expr>) 
                                      : XemeGeneric {
        var retValue : XemeGeneric = XemeBool.FALSE;
        var last                   = args.last();
        
        for (arg in args) {
            if (arg == last) return eval(arg);
            
            var value = eval(arg);
            if (value == XemeBool.FALSE) return retValue;
            
            retValue = value;
        }
        
        throw "Uh oh.";
    }
    
    public static function or(locals : Locals, 
                              eval   : EvalFunc, 
                              args   : List<Expr>) 
                                     : XemeGeneric {
        for (arg in args) {
            var value = eval(arg);
            if (value != XemeBool.FALSE) return value;
        }
        
        return XemeBool.FALSE;
    }
}