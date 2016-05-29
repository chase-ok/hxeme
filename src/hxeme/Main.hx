package hxeme;

#if flash9
import flash.Lib;
import flash.text.TextField;
import haxe.Log;
#end

import haxe.Resource;
import haxe.Timer;
import hxeme.prims.SpecialForms;
import hxeme.object.XemeBool;
import hxeme.object.XemeFunc;
import hxeme.object.XemeGeneric;
import hxeme.object.XemeNum;
import hxeme.object.XemeObject;
import hxeme.object.XemePair;
import hxeme.object.XemeString;
import hxeme.object.XemeSymbol;
import hxeme.Locals;
import hxeme.object.XemeVector;
import hxeme.parsing.Parser;
import hxeme.parsing.Tokenizer;
import haxe.ds.GenericStack;
//import haxe.FastList;
import hxeme.prims.PrimitiveManager;

/**
* ...
* @author Chase Kernan
*/

class Main {

    static function main() {
        #if flash9
	    Log.setColor(0xFFFFFF);
            Globals.init(Lib.current);
            Lib.current.addChild(new Console());
        #elseif neko
            new Console();
        #end
    }

}
