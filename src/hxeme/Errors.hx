/**
 * ...
 * @author Chase Kernan
 */

package hxeme;

import hxeme.object.XemeGeneric;
import hxeme.object.XemeVector;

enum InterpError {
	CannotCall(obj : XemeGeneric);
	ArgMismatch(obj : XemeGeneric, expected : Int, got : Int);
    UnboundVariable(name : String);
    FailedBoundsCheck(obj : XemeVector, index : Int);
    TypeError(got : Dynamic, expected : Dynamic);
    DivideByZero;
    NotEnoughArgs(expected : Int, got : Int);
}

enum ParserError {
    UnrecognizedSymbol(value : String);
    Unexpected(value : Dynamic);
    Expected(value : String);
    AssertFailed;
}

class Errors { }