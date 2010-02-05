/**
 * ...
 * @author Chase Kernan
 */

package hxeme.prims;

import hxeme.object.XemeGeneric;
import hxeme.object.XemeString;

class Help {

    public static function init() {
        //PrimitiveManager.PRIMITIVES.set("DQUOTE", new XemeString("\""));
        //PrimitiveManager.PRIMITIVES.set("SQUOTE", new XemeString("'"));
    }

    public static var DEFINED_PRIMS  = [
            { name : "built-in", func : builtIn, numArgs : 0 },
        ];
    
    public static function builtIn(args: List<XemeGeneric>): XemeGeneric {
        var str = "-----BUILT-IN FUNCTIONS-----\n\nSPECIAL FORMS:\n";
        var total = 0;
        
        for (formName in sort(SpecialForms.FORMS)) {
            total++;
            str += "  " + StringTools.rpad(formName, " ", 15) + " " + SpecialForms.FORMS.get(formName) + "\n";
        }
        
        str += "\nPRIMATIVES:\n";
        for (primName in sort(PrimitiveManager.PRIMITIVES)) {
            total++;
            if (primName == "newline") {
                str += "  " + StringTools.rpad(primName, " ", 15) + " \"\\n\"\n";
                continue;
            }
            str += "  " + StringTools.rpad(primName, " ", 15) + " " + PrimitiveManager.PRIMITIVES.get(primName) + "\n";
        }
        
        str += "\nTOTAL: " + total;
        
        return new XemeString(str);
    }
    
    static function sort<T>(h: Hash<T>): Array<String> {
        var arr = new Array<String>();
        for (item in h.keys()) arr.push(item);
        
        arr.sort(function (str1: String, str2: String): Int {
            var l1 = str1.length;
            var l2 = str2.length;
            var min = if (l1 < l2) l1 else l2;
            for (i in 0...min) {
                var c1 = str1.charCodeAt(i);
                var c2 = str2.charCodeAt(i);
                
                if (c1 < c2) return -1 else if (c1 > c2) return 1;
            }
            
            return l2 - l1;
        });
        
        return arr;
    }
    
}