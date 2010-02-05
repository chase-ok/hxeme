package hxeme.prims.lists;

import hxeme.object.XemeBool;
import hxeme.object.XemeGeneric;
import hxeme.object.XemeFunc;
import hxeme.object.XemeNum;
import hxeme.object.XemePair;
import hxeme.Errors;
import hxeme.utils.FuncUtils;
import hxeme.utils.ListUtils;

class BasicLists {

    static inline var INF_ARGS       = XemeFunc.NO_ARG_COUNT;
    public static var DEFINED_PRIMS  = [
            { name : "car",      func : car,        numArgs : 1 },
            { name : "set-car",  func : setCar,     numArgs : 2 },
            { name : "cdr",      func : cdr,        numArgs : 1 },
            { name : "set-cdr",  func : setCdr,     numArgs : 2 },
            { name : "caar",     func : caar,       numArgs : 1 },
            { name : "cadr",     func : cadr,       numArgs : 1 },
            { name : "cddr",     func : cddr,       numArgs : 1 },
            { name : "cdar",     func : cdar,       numArgs : 1 },
            { name : "cons",     func : cons,       numArgs : 2 },
            { name : "length",   func : length,     numArgs : 1 },
            { name : "copy",     func : copy,       numArgs : 1 },
            { name : "list",     func : list,       numArgs : INF_ARGS },
            { name : "list*",    func : listStar,   numArgs : INF_ARGS },
            { name : "append!",  func : appendMod,  numArgs : INF_ARGS },
            { name : "append",   func : append,     numArgs : INF_ARGS },
            { name : "reverse",  func : reverse,    numArgs : 1 },
            { name : "reverse!", func : reverseMod, numArgs : 1 },
            { name : "filter",   func : filter,     numArgs : 2 },
        ];
    
    public static function car(args : List<XemeGeneric>) : XemeGeneric {
        return ensurePair(args.pop()).car;
    }
    
    public static function caar(args : List<XemeGeneric>) : XemeGeneric {  
        var v = ensurePair(args.pop()).car;
        return ensurePair(v).car;
    }
    
    public static function cadr(args : List<XemeGeneric>) : XemeGeneric {  
        var v = ensurePair(args.pop()).cdr;
        return ensurePair(v).car;
    }
    
    public static function cddr(args : List<XemeGeneric>) : XemeGeneric {  
        var v = ensurePair(args.pop()).cdr;
        return ensurePair(v).cdr;
    }
    
    public static function cdar(args : List<XemeGeneric>) : XemeGeneric {  
        var v = ensurePair(args.pop()).car;
        return ensurePair(v).cdr;
    }
    
    public static function cdr(args : List<XemeGeneric>) : XemeGeneric {
        return ensurePair(args.pop()).cdr;
    }
    
    public static function setCar(args : List<XemeGeneric>) : XemeGeneric {  
        var pair = ensurePair(args.pop());
        var val  = args.pop();
        pair.car = val;
        
        return val;
    }
    
    public static function setCdr(args : List<XemeGeneric>) : XemeGeneric {  
        var pair = ensurePair(args.pop());
        var val  = args.pop();
        pair.cdr = val;
        
        return val;
    }
    
    public static function cons(args : List<XemeGeneric>) : XemePair {
        return new XemePair(args.pop(), args.pop());
    }
    
    public static function appendMod(args : List<XemeGeneric>) : XemeGeneric {
        var list    = ListUtils.ensureList(args.pop());
        var lastArg = args.last();
        var tail    = list.getTail();
        
        if (tail.cdr != XemePair.EMPTY_LIST) {
        	throw TypeError(tail.cdr, XemePair.TYPE_NAME);
        }
        
        for (arg in args) {
            if (arg == lastArg && arg.getTypeName() != XemePair.TYPE_NAME) {
            	tail.cdr = arg;
            	break;
            }
            
            var toAppend = ListUtils.ensureList(arg);
            var empty    = XemePair.EMPTY_LIST; //faster access
            
            for (item in toAppend) {
            	var newTail = new XemePair(item, empty);
            	tail.cdr    = newTail;
            	tail        = newTail;
            }
        }
        
        return list;
    }
    
    public static function append(args : List<XemeGeneric>) : XemeGeneric {
        var list = ListUtils.ensureList(args.pop());
        args.push(list.copy());
        return appendMod(args);
    }
    
    public static function list(args : List<XemeGeneric>) : XemeGeneric {
        if (args.length == 0) return XemePair.EMPTY_LIST;
        
        return XemePair.makeList(args);
    }
    
    public static function reverse(args : List<XemeGeneric>) : XemeGeneric {
        var list = ListUtils.ensureList(args.pop());
        args.push(list.copy());
        return reverseMod(args);
    }
    
    public static function reverseMod(args : List<XemeGeneric>) : XemeGeneric {
        var cur = ListUtils.ensureList(args.pop());
        var r   = XemePair.EMPTY_LIST;
        
        while (cur != XemePair.EMPTY_LIST) {
            var tmp = cur.cdr;
            cur.cdr = r;
            r       = cur;
            cur     = ListUtils.ensureList(tmp);
        }
        
        return r; 
    }
    
    public static function listStar(args : List<XemeGeneric>) : XemeGeneric {
        if (args.length == 0) return XemePair.EMPTY_LIST;
        if (args.length == 1) return new XemePair(args.pop(), 
                                                  XemePair.EMPTY_LIST);
        
        var last  = args.last();
        var head  = new XemePair(args.pop(), XemePair.EMPTY_LIST);
        var tail  = head;
        var empty = XemePair.EMPTY_LIST; //faster access
        
        for (arg in args) {
            if (arg == last) {
                tail.cdr = arg;
                return head;
            }
            
            var cell = new XemePair(arg, XemePair.EMPTY_LIST);
            tail.cdr = cell;
            tail     = cell;
        }
        
        throw "Uh oh.";
    }
    
    public static function copy(args : List < XemeGeneric > ) : XemeGeneric {
        return ListUtils.ensureList(args.pop()).copy();
    }
    
    public static function length(args : List<XemeGeneric>) : XemeGeneric {
        var count = 0;
        for (item in ensurePair(args.pop())) count++;
        return new XemeNum(count);
    }
    
    public static function filter(args : List<XemeGeneric>) : XemeGeneric {  
        var func           = FuncUtils.ensureFunc(args.pop());
        var list           = ListUtils.ensureList(args.pop());
        var empty          = XemePair.EMPTY_LIST; //faster access
        var results        = empty;
        var cur : XemePair = null;
        
        for (elem in list) {
            var funcArgs = new List<XemeGeneric>();
            funcArgs.add(elem);
            if (func.call(funcArgs) == XemeBool.FALSE) continue;
            
            cur = if (cur == null) (results = new XemePair(elem, empty))
                  else             ListUtils.append(cur, elem);
        }
        
        return results;
    }
    
    inline static function ensurePair(value : XemeGeneric) : XemePair {
        if (value.getTypeName() != XemePair.TYPE_NAME) {
            throw TypeError(value.getTypeName(), XemePair.TYPE_NAME);
        }
        
        return untyped value;
    }
    
}