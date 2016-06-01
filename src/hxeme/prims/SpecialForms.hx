/**
 * ...
 * @author Chase Kernan
 */

package hxeme.prims;

import hxeme.Locals;
import hxeme.Modules;
import hxeme.object.XemeGeneric;
import hxeme.object.XemeSpecialForm;
import hxeme.parsing.Parser;
import hxeme.prims.boolean.BasicLogic;
import hxeme.prims.func.BasicFunc;
import hxeme.prims.LazyEval;
import hxeme.prims.obj.BasicObj;

class SpecialForms {
    
    public static var FORMS         : Map<String, XemeSpecialForm>;
    public static var FORMS_CLASSES : Array<Dynamic> = [
            Define, XemeLambda, XemeIf, Quote, BasicLogic, BasicFunc, LazyEval,
            BasicObj, RuntimeErrors, Modules,
        ];
    
    static var initialized = false;
    
    public static function init() {
        initialized = true;
        FORMS       = new Map();
        
        for (c in FORMS_CLASSES) initClass(c);
    }
    
    public static function registerClass(c : Class<Dynamic>) {
        FORMS_CLASSES.push(c);
        initClass(c);
    }
    
    inline public static function isInitialized() : Bool {
        return initialized;
    }
    
    static function initClass(c : Class<Dynamic>) {
        var defined : Iterable<Dynamic> = Reflect.field(c, "DEFINED_FORMS");
        for (form in defined) {
            FORMS.set(form.name, new XemeSpecialForm(form.func));
        }
    }
    
}
