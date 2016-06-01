/**
 * ...
 * @author Chase Kernan
 */

package hxeme;

import hxeme.object.XemeGeneric;
import hxeme.Errors;
import hxeme.prims.PrimitiveManager;
import hxeme.prims.SpecialForms;

typedef LocalsSet = Map<String, XemeGeneric>;

class Locals {

    var sets : List<LocalsSet>;
    
    public function new(?increaseLevel = true) {
        sets = new List<LocalsSet>();
        if (increaseLevel) sets.add(new Map());
    }
    
    public function setLocal(name : String, value : XemeGeneric) {
        sets.first().set(name, value);
    }
    
    public function getLocal(name : String) : XemeGeneric {
        var value : XemeGeneric = SpecialForms.FORMS.get(name);
        if (value != null) return value;
        
        value = PrimitiveManager.PRIMITIVES.get(name);
        if (value != null) return value;
        
        for (set in sets) {
            value = set.get(name);
            if (value != null) return value;
        }
        
        throw UnboundVariable(name);
    }
    
    public function getLevel(name : String) : LocalsSet {
        for (set in sets) {
            if (set.exists(name)) return set;
        }
        
        throw "No such local: " + name;
    }
    
    public function append(otherLocals : Locals) {
        for (set in otherLocals.sets) sets.push(set);
    }
    
    public function restore(from : Locals) {
        //make sure successive restore/append are called in the right order
        for (set in from.sets) sets.pop(); 
    }
    
    public function clone() : Locals {
        var copy = new Locals(false);
        for (set in sets) copy.sets.add(set);
        return copy;
    }
    
    public function createLevel() {
        sets.push(new Map());
    }
    
    public function removeLevel() {
        sets.pop();
    }
    
    public function toString() {
        return "Locals[" + sets.toString() + "]";
    }
}
