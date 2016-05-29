/**
* ...
* @author Chase Kernan
*/

package hxeme;

import hxeme.object.XemeModule;
import hxeme.object.XemeString;

#if flash9
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
#end
import hxeme.Interp;
import hxeme.object.XemeGeneric;
import hxeme.object.XemeObject;
import hxeme.parsing.Parser;
import hxeme.parsing.Tokenizer;
import hxeme.prims.PrimitiveManager;
import hxeme.object.XemeFunc;

class Globals {

    public static var tokenizer : Tokenizer;
    public static var parser    : Parser;
    public static var interp    : Interp;
#if flash9
    public static var root      : DisplayObjectContainer;
#end
    public static var newline   = "\n";
    public static var modules   : Map<String, XemeModule>;
    
    static var vars             : Map<String, Dynamic>;
    
    public static function init(
#if flash9
root : DisplayObjectContainer
#end
) {
        vars         = new Map();
        tokenizer    = new Tokenizer();
        parser       = new Parser();
        interp       = new Interp();

#if flash9
        Globals.root = root;
#end
        PrimitiveManager.setPrimitive("Globals", new XemeObject(Globals));
#if flash9
        PrimitiveManager.setPrimitive("root",    new XemeObject(root));
#end
        PrimitiveManager.setPrimitive("newline", new XemeString(newline));
        PrimitiveManager.setPrimitive("display", new XemeFunc(
            function(args : List<XemeGeneric>) : XemeGeneric {
                trace(args.first());
                return XemeGeneric.NIL;
            },
            1
        ));
    }
    
    public function get(name : String) : Null<Dynamic> {
        return vars.get(name);
    }
    
    public function set(name : String, value : Dynamic) : Dynamic {
        vars.set(name, value);
        return value;
    }
    
    public static function evalAll(input : String) : XemeGeneric {
        var tokens = tokenizer.tokenizeString(input);
        var prog   = parser.parse(tokens);
        return interp.evalAll(prog);
    }
    
    public static function interpret(input : String) : Dynamic {
        var tokens = tokenizer.tokenizeString(input);
        var prog   = parser.parse(tokens);
        return interp.interpAll(prog);
    }
    
}
