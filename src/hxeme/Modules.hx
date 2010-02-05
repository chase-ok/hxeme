/**
* ...
* @author Chase Kernan
*/

package hxeme;

import haxe.Resource;
import hxeme.object.XemeModule;
import hxeme.object.XemeSpecialForm;
import hxeme.object.XemeString;
import hxeme.parsing.Parser;
import hxeme.object.XemeGeneric;
import hxeme.Errors;
import hxeme.utils.StringUtils;
import hxeme.object.XemeSymbol;

class Modules {
    
    public static var DEFINED_FORMS = [
            { name : "load-module", func : loadModule },
        ];
    
    static var initialized = false;
    static var modules     : Hash<XemeModule>;
    
    public static function init() {
        initialized = true;
        modules     = new Hash<XemeModule>();
    }
    
    public static function isInitialized() {
        return initialized;
    }
    
    public static function registerModule(name : String, module : XemeModule) {
        modules.set(name, module);
    }
    
    public static function getModule(name : String) : XemeModule {
        var mod = modules.get(name);
        if (mod != null) return mod;
        
        for (match in Resource.listNames()) {
            if (match == name) return createModule(Resource.getString(name));
        }
        
        throw "No such module: " + name;
    }
    
    public static function createModule(code : String) : XemeModule {
        var tokens = Globals.tokenizer.tokenizeString(code);
        
        return new XemeModule(Globals.interp, Globals.parser.parse(tokens));
    }
    
    public static function loadModule(locals : Locals, 
                                      eval   : EvalFunc, 
                                      args   : List<Expr>) 
                                             : XemeGeneric {
        if (args.length < 1) throw NotEnoughArgs(1, args.length);
        if (args.length > 2) throw "Too many args: " + args.length;
        
        var it         = args.iterator();
        var moduleName = StringUtils.getValue(
                            StringUtils.ensureString(eval(it.next())));
        var module     = getModule(moduleName);
        
        var defName = ""; //when combined this was throwing a VerifyError
        if (args.length == 1) defName = moduleName;
        else {
            var defNameVal = it.next();
            defName        = switch (defNameVal) {
                case ERef(name): name;
                default:         throw Unexpected(defNameVal);
            };
        }
        
        locals.setLocal(defName, module);
        
        return new XemeSymbol(defName); 
    }
    
}