package hxeme.prims.func;

import hxeme.object.XemeBool;
import hxeme.object.XemeGeneric;
import hxeme.object.XemeFunc;
import hxeme.object.XemeNum;
import hxeme.object.XemePair;
import hxeme.object.XemeSpecialForm;
import hxeme.Errors;
import hxeme.utils.ListUtils;
import hxeme.utils.FuncUtils;
import hxeme.prims.Quote;
import hxeme.prims.boolean.BasicLogic;
import hxeme.Locals;
import hxeme.parsing.Parser;

class BasicFunc {
	
    public static var DEFINED_FORMS = [{name : "case", func : xemeCase}];
    
	static inline var INF_ARGS       = XemeFunc.NO_ARG_COUNT;
    public static var DEFINED_PRIMS  = [
            { name : "apply",      func : apply,     numArgs : 2 },
            { name : "begin",      func : begin,     numArgs : INF_ARGS },
            { name : "map",        func : map,       numArgs : INF_ARGS },
            { name : "for-each",   func : forEach,   numArgs : INF_ARGS },
            { name : "fold-left",  func : foldLeft,  numArgs : INF_ARGS },
            { name : "fold-right", func : foldRight, numArgs : INF_ARGS },
            { name : "fold",       func : foldLeft,  numArgs : INF_ARGS },
            { name : "compose",    func : compose,   numArgs : INF_ARGS },
        ];
        
    public static function apply(args : List<XemeGeneric>) : XemeGeneric {
    	var func = FuncUtils.ensureFunc(args.pop());
    	return cast(func.call(Lambda.list(ListUtils.ensureList(args.first()))), XemeGeneric);
    }
    
    public static function begin(args : List<XemeGeneric>) : XemeGeneric {
    	if (args.length == 0) return XemePair.EMPTY_LIST;
    	
    	return args.last();
    }
    
    public static function map(args : List<XemeGeneric>) : XemeGeneric {  
        if (args.length <= 1) throw NotEnoughArgs(2,  args.length);
        
        var empty          = XemePair.EMPTY_LIST; //faster access
        var func           = FuncUtils.ensureFunc(args.pop());
        var results        = new XemePair(empty, empty);
        var cur : XemePair = null;
        var iters          = new List<Iterator<XemeGeneric>>();
        
        for (arg in args) iters.add(ListUtils.ensureList(arg).iterator());
        
        while (true) {
            var funcArgs = new List<XemeGeneric>();
            
            var done = false;
            for (iter in iters) {
                if (!iter.hasNext()) {
                    done = true;
                    break;
                }
                
                funcArgs.add(iter.next());
            }
            if (done) break;
            
            var result = func.call(funcArgs);
            
            if (cur == null) {
                results.car = result;
                cur         = results;
            } else cur  = ListUtils.append(cur, result);
        }
        
        return results;
    }
    
    public static function forEach(args : List<XemeGeneric>) : XemeGeneric {  
        map(args); //discard return
        return XemePair.EMPTY_LIST;
    }
    
    public static function foldLeft(args : List<XemeGeneric>) : XemeGeneric { 
        if (args.length < 3) throw NotEnoughArgs(3, args.length);
        
        var func  = FuncUtils.ensureFunc(args.pop());
        var val   = args.pop();
        var iters = new List<Iterator<XemeGeneric>>();
        
        for (arg in args) iters.add(ListUtils.ensureList(arg).iterator());
        
        while (true) {
            var funcArgs = new List<XemeGeneric>();
            funcArgs.add(val);
            
            var done = false;
            for (iter in iters) {
                if (!iter.hasNext()) {
                    done = true;
                    break;
                }
                
                funcArgs.add(iter.next());
            }
            if (done) break;
            
            val = func.call(funcArgs);
        }
        
        return val;
    }
    
    public static function foldRight(args : List<XemeGeneric>) : XemeGeneric { 
        if (args.length < 3) throw NotEnoughArgs(3, args.length);
        
        var func  = FuncUtils.ensureFunc(args.pop());
        var val   = args.pop();
        var iters = new List<Iterator<XemeGeneric>>();
        
        for (arg in args) iters.add(ListUtils.ensureList(arg).iterator());
        
        return foldRightRec(func, iters, val);
    }
    
    static function foldRightRec(func  : XemeFunc, 
                                 iters : List<Iterator<XemeGeneric>>, 
                                 init  : XemeGeneric) 
                                       : XemeGeneric {
        var funcArgs = new List<XemeGeneric>();
        var done = false;
        for (iter in iters) {
            if (!iter.hasNext()) {
                done = true;
                break;
            }
                
            funcArgs.add(iter.next());
        }
            
        if (done) return init;
        
        funcArgs.add(foldRightRec(func, iters, init));
        return func.call(funcArgs);
    }
    
    public static function xemeCase(locals : Locals, 
                                    eval   : EvalFunc, 
                                    args   : List<Expr>) 
                                           : XemeGeneric {
        if (args.length < 2) throw NotEnoughArgs(2, args.length);
        
        //directly access the iterator as we can't destroy the args list by 
        //calling pop() and etc
        var iter = args.iterator();
        var key  = eval(iter.next());
        
        for (caseVal in iter) {
            var caseArgs = switch(caseVal) {
                case EList(children): children;
                default:              throw Unexpected(caseVal);
            };
            
            if (caseArgs.length != 2) throw Unexpected(caseArgs);
            
            var caseIter = caseArgs.iterator();
            var caseExpr = caseIter.next();
            var isMatch  = switch(caseExpr) {
                case ERef(name):
                    if (name == "else") true else throw Unexpected(name);
                    
                case EList(children):
                    var found   = false;
                    var matches = ListUtils.ensureList(
                            Quote.quote(locals, eval, Lambda.list([caseExpr])));
                            
                    for (match in matches) {
                        var eqArgs = Lambda.list([match, key]);
                        if (BasicLogic.equals(eqArgs).getValue()) {
                            found = true;
                            break;
                        }
                    }
                    
                    found;
                
                default: throw Unexpected(caseExpr);
            };
            
            if (isMatch) return eval(caseIter.next());
        }
        
        return XemePair.EMPTY_LIST;
    }
    
    public static function compose(args : List<XemeGeneric>) : XemeGeneric { 
        var funcs = new List<XemeFunc>();
        for (arg in args) funcs.push(FuncUtils.ensureFunc(arg)); //reverse list
        
        var comp = function (funcArgs : List<XemeGeneric>) : XemeGeneric {
            var val = new List<XemeGeneric>();
            val.add(funcArgs.first());
            
            for (func in funcs) {
                var tmp = func.call(val);
                val.pop();
                val.add(tmp);
            }
            
            return val.pop();
        };
        
        return new XemeFunc(comp, 1);
    }
}
