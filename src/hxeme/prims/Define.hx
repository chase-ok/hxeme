/**
 * ...
 * @author Chase Kernan
 */

package hxeme.prims;

import hxeme.Locals;
import hxeme.parsing.Parser;
import hxeme.object.XemeGeneric;
import hxeme.prims.SpecialForms;
import hxeme.object.XemeSpecialForm;
import hxeme.utils.ListUtils;
import hxeme.Errors;

class Define {
    
    public static var DEFINED_FORMS = [
            { name : "define", func : define },
            { name : "set!",   func : set },
            { name : "let*",   func : letStar },
            { name : "let",    func : let },
            { name : "letrec", func : letStar }, //FIXME
        ];
    

    public static function define(locals : Locals, 
                                  eval   : EvalFunc, 
                                  args   : List<Expr>) 
                                         : XemeGeneric {
        var iter  = args.iterator();
        var names = iter.next();
        
        return switch (names) {
            case ERef(name):
                var result = eval(iter.next());
                locals.setLocal(name, result);
                result;
                
            case EList(list):
                var fName = ListUtils.getNames(names).pop();                
                names     = switch (names) {
                    case EList(fArgs): 
                        var fIter = fArgs.iterator();
                        fIter.next(); //pop off func name
                        
                        var fList = new List<Expr>();
                        while (fIter.hasNext()) fList.add(fIter.next());
                        
                        EList(fList);
                        
                    default:
                        throw Unexpected(Std.string(names));
                    
                };
                
                var lambdaArgs = new List<Expr>();
                lambdaArgs.add(names);
                for (arg in iter) lambdaArgs.add(arg);
                
                var result = XemeLambda.lambda(locals, eval, lambdaArgs);
                locals.setLocal(fName, result);
                result;
            
            default:
                throw Unexpected(Std.string(names));
        };
    }
    
    public static function set(locals : Locals, 
                               eval   : EvalFunc, 
                               args   : List<Expr>) 
                                      : XemeGeneric {
        var iter = args.iterator();
        var name = iter.next();
        
        switch (name) {
            case ERef(name):
                var result = eval(iter.next());
                var ret    = locals.getLocal(name);
                
                locals.getLevel(name).set(name, result);
                return ret;
                
            default:
                throw Unexpected(Std.string(name));
        };
    }
    
    public static function letStar(locals : Locals, 
                                   eval   : EvalFunc, 
                                   args   : List<Expr>) 
                                          : XemeGeneric { 
        if (args.length < 2) throw NotEnoughArgs(2, args.length);
        
        var iter         = args.iterator();
        var bindingsExpr = iter.next();
        var bindings     = switch(bindingsExpr) {
            case EList(children): children;
            default:              throw Unexpected(bindingsExpr);
        };
        
        locals.createLevel();
        
        //TODO: make this not like let*?
        for (bind in bindings) {
            switch (bind) {
                case EList(children):
                    if (children.length != 2) throw "Let malformed.";
                    
                    var bindIter = children.iterator();
                    var nameExpr = bindIter.next();
                    var name     = switch(nameExpr) {
                        case ERef(ref): ref;
                        default:        throw Unexpected(nameExpr);
                    };
                    
                    locals.setLocal(name, eval(bindIter.next()));
                    
                default: throw Unexpected(bind);
            }
        }
        
        var value = null;
        for (bodyExpr in iter) value = eval(bodyExpr);
        
        locals.removeLevel();
        
        return value;
    }
    
    public static function let(locals : Locals, 
                               eval   : EvalFunc, 
                               args   : List<Expr>) 
                                      : XemeGeneric { 
        if (args.length < 2) throw NotEnoughArgs(2, args.length);
        
        var iter         = args.iterator();
        var bindingsExpr = iter.next();
        var bindings     = switch(bindingsExpr) {
            case EList(children): children;
            default:              throw Unexpected(bindingsExpr);
        };
        
        locals.createLevel();
        
        var defs = new List <{ name : String, value : XemeGeneric }>();
        
        //TODO: make this not like let*?
        for (bind in bindings) {
            switch (bind) {
                case EList(children):
                    if (children.length != 2) throw "Let malformed.";
                    
                    var bindIter = children.iterator();
                    var nameExpr = bindIter.next();
                    var name     = switch(nameExpr) {
                        case ERef(ref): ref;
                        default:        throw Unexpected(nameExpr);
                    };
                    
                    defs.add({ name : name, value : eval(bindIter.next()) });
                    
                default: throw Unexpected(bind);
            }
        }
        
        for (def in defs) locals.setLocal(def.name, def.value);
        
        var value = null;
        for (bodyExpr in iter) value = eval(bodyExpr);
        
        locals.removeLevel();
        
        return value;
    }
    
}

/**
(define exit
  (let ((exit exit))
    (lambda ()
      (if (not (null? readyList))
          (let ((cont (car readyList)))
            (set! readyList (cdr readyList))
            (cont '()))
          (exit)))))
          
(define (fork fn arg)
  (set! readyList
        (append readyList
		(cons
		 (lambda (x)
		   (fn arg)
		   (exit)) '()))))

(define (yield)
  (call-with-current-continuation
   (lambda (thisCont)
     (set! readyList
           (append readyList
                   (cons thisCont '())))
     (let ((cont (car readyList)))
       (set! readyList (cdr readyList))
       (cont '())))))
       
(define (generate-one-element-at-a-time lst)
  (define (generator)
    (call/cc control-state)) 
  (define (control-state return)
    (for-each 
     (lambda (element)
       (set! return
             (call/cc
              (lambda (resume-here)
                (set! control-state resume-here)
                (return element)))))
     lst)
    (return 'you-fell-off-the-end))
  generator)
 
(define generate-digit
  (generate-one-element-at-a-time '(0 1 2 3 4 5 6 7 8 9)))
 
(generate-digit)
(generate-digit)

(let ((countdown (lambda (i)
                    (if (= i 0) 'liftoff
                       (begin
                          (display i)
                          (countdown (- i 1)))))))
  (countdown 10))
**/
