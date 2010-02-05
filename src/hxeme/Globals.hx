/**
* ...
* @author Chase Kernan
*/

package hxeme;

import hxeme.object.XemeModule;
import hxeme.object.XemeString;
import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;
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
    public static var root      : DisplayObjectContainer;
    public static var newline   = "\n";
    public static var modules   : Hash<XemeModule>;
    
    static var vars             : Hash<Dynamic>;
    
    public static function init(root : DisplayObjectContainer) {
        vars         = new Hash();
        tokenizer    = new Tokenizer();
        parser       = new Parser();
        interp       = new Interp();
        Globals.root = root;
        
        PrimitiveManager.setPrimitive("Globals", new XemeObject(Globals));
        PrimitiveManager.setPrimitive("root",    new XemeObject(root));
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