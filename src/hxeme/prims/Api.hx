/**
* ...
* @author Chase Kernan
*/

package hxeme.prims;

import hxeme.object.XemeBool;
import hxeme.object.XemeFunc;
import hxeme.object.XemeGeneric;
import hxeme.object.XemeNum;
import hxeme.object.XemeObject;
import hxeme.object.XemePair;
import hxeme.object.XemePromise;
import hxeme.object.XemeSpecialForm;
import hxeme.object.XemeString;
import hxeme.object.XemeSymbol;
import hxeme.object.XemeVector;

class Api {

    public static function convertToXeme(value : Dynamic) : XemeGeneric {
        return untyped switch (Type.typeof(value)) {
            case TObject: cast(new XemeObject(value), XemeGeneric);
            
            case TClass(c):
                untyped switch(c) {
                    case String: new XemeString(value);
                    
                    case Array: 
                        var conv = new Array<XemeGeneric>();
                        for (i in 0...value.length) {
                            conv[i] = convertToXeme(value[i]);
                        }
                        new XemeVector(conv);
                        
                    case List:
                        var conv = new List<XemeGeneric>();
                        var iter : Iterator<Dynamic> = value.iterator();
                        for (elem in iter) conv.add(convertToXeme(elem));
                        XemePair.makeList(conv);
                        
                    default: new XemeObject(value);
                };
            
            case TNull:        XemePair.EMPTY_LIST;
            case TInt, TFloat: new XemeNum(value);
            case TBool:        if (value) XemeBool.TRUE else XemeBool.FALSE;
            
            case TFunction:    
                var func = function(args : List<XemeGeneric>) : XemeGeneric {
                    var conv = new Array<Dynamic>();
                    for (arg in args) conv.push(convertFromXeme(arg));
                    
                    return convertToXeme(Reflect.callMethod(null, value, conv));
                };
                
                new XemeFunc(func, XemeFunc.NO_ARG_COUNT);
                
            default: new XemeObject(value);
        };
    }
    
    public static function convertFromXeme(value : XemeGeneric) : Dynamic {
        return untyped switch (value.getTypeName()) {
            case XemeBool.TYPE_NAME: value.getValue();
            
            case XemeFunc.TYPE_NAME:
                var func = function(args : Array<Dynamic>) : Dynamic {
                    var conv = new List<XemeGeneric>();
                    for (arg in args) conv.add(convertToXeme(arg));
                    
                    return convertFromXeme(value.call(conv));
                };
                
                Reflect.makeVarArgs(func);
                
            case XemeGeneric.TYPE_NAME: value.getValue();
            case XemeNum.TYPE_NAME:     value.getValue();
            
            case XemePair.TYPE_NAME:
                if (value == XemePair.EMPTY_LIST) null;
                else {
                    var list = new List<Dynamic>();
                    var it : Iterator<XemeGeneric> = untyped value.iterator();
                    for (elem in it) list.add(convertFromXeme(elem));
                    list;
                }
                
            case XemeObject.TYPE_NAME:  value.getValue();
            case XemePromise.TYPE_NAME: untyped value.value; //should force?
            case XemeSpecialForm.TYPE_NAME: 
                throw "Can't convert special forms.";
            case XemeString.TYPE_NAME:  value.getValue();
            case XemeSymbol.TYPE_NAME:  value.getValue();
            
            case XemeVector.TYPE_NAME:  
                var a                          = new Array<Dynamic>();
                var it : Iterator<XemeGeneric> = value.getValue().iterator();
                for (elem in it) a.push(convertFromXeme(elem));
                a;
        }
    }
    
}