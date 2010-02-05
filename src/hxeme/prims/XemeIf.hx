/**
 * ...
 * @author Chase Kernan
 */

package hxeme.prims;

import hxeme.object.XemeGeneric;
import hxeme.object.XemeBool;
import hxeme.Locals;
import hxeme.object.XemePair;
import hxeme.object.XemeSpecialForm;
import hxeme.object.XemeString;
import hxeme.parsing.Parser;
import hxeme.Errors;

class XemeIf {

    public static var DEFINED_FORMS = [
            { name : "if",   func : xemeIf },
            { name : "cond", func : cond },
        ];

    public static function xemeIf(locals : Locals, 
                                  eval   : EvalFunc, 
                                  args   : List<Expr>) 
                                         : XemeGeneric {
        if (args.length > 3) {
            throw "Too many args to if: " + args.length;
        }
        
        var iter  = args.iterator();
        var value = eval(iter.next());
        var first = iter.next();
        
        if (args.length == 3) {
            return eval(if (value != XemeBool.FALSE) first 
                        else                         iter.next());
        } else {
            return if (value != XemeBool.FALSE) eval(first) 
                   else                         XemePair.EMPTY_LIST;
        }
    }
    
    public static function cond(locals : Locals, 
                                eval   : EvalFunc, 
                                args   : List<Expr>) 
                                       : XemeGeneric {
        if (args.length < 1) throw NotEnoughArgs(2, args.length);
        
        for (condCase in args) {
            var condArgs = switch(condCase) {
                case EList(children): children;
                default:              throw Unexpected(condCase);
            };
            
            if (condArgs.length != 2) throw Unexpected(condArgs);
            
            var condIter = condArgs.iterator();
            var condExpr = condIter.next();
            var isMatch  = switch(condExpr) {
                case ERef(name):
                    if (name == "else") true 
                    else                eval(condExpr) != XemeBool.FALSE;
                    
                default: eval(condExpr) != XemeBool.FALSE;
            };
            
            if (isMatch) return eval(condIter.next());
        }
        
        return XemePair.EMPTY_LIST;
    }
}