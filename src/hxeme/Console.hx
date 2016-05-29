/**
 * ...
 * @author Chase Kernan
 */

package hxeme;

import hxeme.object.XemeFunc;
import hxeme.object.XemeGeneric;
import hxeme.object.XemeObject;
import hxeme.parsing.Parser;
import hxeme.parsing.Tokenizer;
import hxeme.prims.PrimitiveManager;

//#if neko
//import neko.Lib;
//import neko.Sys;
import sys.io.File;
import sys.io.FileInput;
import sys.io.FileOutput;

class Console {
    
    public static var LINE_START = "hXe> ";
    
    public var interp    : Interp;
    public var tokenizer : Tokenizer;
    public var parser    : Parser;

	public function new() {
        interp    = new Interp();
        tokenizer = new Tokenizer();
        parser    = new Parser();
        
        var me    = this;
        PrimitiveManager.setPrimitive("display", new XemeFunc(
            function(args : List<XemeGeneric>) : XemeGeneric {
                me.print(args.first());
                return XemeGeneric.NIL;
            },
            1
        ));
        
	//	start();
	}
    
    public function readLine() : String {
        return Sys.stdin().readLine();
        //return File.stdin().readLine();
    }
    
    public function write(data : String) {
        //File.stdout().writeString(data);
        Sys.stdout().writeString(data);
    }
    
    public function start() {
        write("Welcome to the hXeme scheme interpreter!\n (C) Chase Kernan 2009\n");
        read();
    }
    
    public function print(x : XemeGeneric) {
        if (x == null) read(); //its a comment
        
        write(";" + x.toString() + "\n"); //TODO: do switch
    }
    
    public function eval(data : String) {
        try {
            var prog = parser.parse(tokenizer.tokenizeString(data));
            print(interp.evalAll(prog));
            
            read();
        } catch (e : Dynamic) {
            handleError(e);
        }
    }
    
    public function handleError(e : Dynamic) {
        write("\n;  ERROR: " + e + "\n\n");
        read();
    }
    
    public function read() {
        write("\n" + LINE_START);
        
        var count    = 0;
        var data     = "";
        var inString = false;
        
        while(true) {
            var line     = readLine();
            data        += line;
            
            for (i in 0...line.length) {
                switch (line.charAt(i)) {
                    case "\"": inString = !inString;
                    case "(":  if (!inString) count++;
                    case ")":  if (!inString) count--;
                }
            }
            
            if (count <= 0) break;
            
            var nextLine = "";
            for (tab in 0...(count * 4 + LINE_START.length)) {
                nextLine += " ";
            }
            write(nextLine);
        }
        
        if (count < 0) {
            write(";Unexpected ')'\n");
            read();
        }
        
        write("\n");
        eval(data);
    }
	
}

//#else
#if flash9

import flash.display.Sprite;
import flash.display.Graphics;
import flash.display.Shape;
import flash.geom.Rectangle;
import flash.display.Stage;
import flash.display.StageAlign;
import flash.display.StageScaleMode;
import flash.text.TextField;
import flash.text.TextFieldAutoSize;
import flash.text.TextFormat;
import flash.text.TextFieldType;
import flash.events.Event;
import flash.events.TextEvent;
import flash.events.KeyboardEvent;
import flash.events.MouseEvent;
import flash.ui.Keyboard;

class Console extends Sprite { 
    
    var textBox     : TextField;
    var highlight   : Sprite;
    var lastCaret   : Int;
    var interp      : Interp;
    var tokenizer   : Tokenizer;
    var parser      : Parser;
    
    public function new() {
        super();
        
        tokenizer   = new Tokenizer();
        parser      = new Parser();
        interp      = new Interp();
        
        var me = this;
        PrimitiveManager.setPrimitive("display", new XemeFunc(
            function(args : List<XemeGeneric>) : XemeGeneric {
                me.write(args.first().toString());
                return XemeGeneric.NIL;
            },
            1
        ));
        
        setupText();
        setupHighlight();
        
        read();
    }
    
    function read() {
        textBox.appendText("hXe>");
        moveCaretToEnd();
        
        lastCaret = textBox.caretIndex;
        if (lastCaret == -1) lastCaret = 5;
    }
    
    function findMatch(str : String, dir : Int) : Int {
        var count = 0;
        var i     = if (dir == -1) str.length - 1 else 0;
        
        while (i >= 0 && i < str.length) {
            var c = str.charAt(i);
            
            if (c == "(") count++ else if (c == ")") count--;
            if (count == 0) return i;
            
            i += dir;
        }
        
        return -1;
    }
    
    function onKeyUp(e : KeyboardEvent) {
        if (e.keyCode != Keyboard.ENTER) {
            highlightMatchingParen();
            return;
        }
        
        var index = textBox.caretIndex;
        var start = findMatch(textBox.text.substr(0, index) + ")", -1);
        
        if (start == -1) {
            var command = textBox.text.substr(lastCaret, index);
            
            highlightChar(-1);
            
            try {
                var parsed = parser.parse(tokenizer.tokenizeString(command));
                var printLine = interp.evalAll(parsed);
                write(printLine.toString());
            } catch (e: Dynamic) {
                write("Error: " + e);
            }
            
            read();	
        } else {
            tab(start + 2);
        }
    }
    
    function write(str : String) {
        if (textBox.text.charAt(textBox.text.length - 1) != "\n") textBox.appendText("\n");
        textBox.appendText(str + "\n");
    }
    
    function tab(char : Int) {
        var rect      = textBox.getCharBoundaries(char);
        var numSpaces = Std.int(rect.x / rect.width);
        
        for(i in 0...numSpaces) textBox.appendText(" ");
        moveCaretToEnd();
    }
    
    function moveCaretToEnd() {
        var newIndex = textBox.text.length;
        textBox.setSelection(newIndex, newIndex);
    }
    
    function onMouseUp(e : MouseEvent) {
        highlightMatchingParen();
    }
    
    function highlightMatchingParen() {
        var matchIndex = -1;
        var index      = textBox.caretIndex;
        
        if (textBox.text.charAt(index - 1) == ")") {
            matchIndex = findMatch(textBox.text.substr(0, index), -1);
        } else if (textBox.text.charAt(index) == "(") {
            matchIndex = index + findMatch(textBox.text.substr(index), 1);
        }
        
        highlightChar(matchIndex);
    }
    
    function highlightChar(char : Int) {
        var rect = textBox.getCharBoundaries(char);
        
        if (rect != null) {
            highlight.visible   = true;
            highlight.x         = textBox.x + rect.x;
            highlight.y         = textBox.y + rect.y;
            highlight.width     = rect.width;
            highlight.height    = rect.height;
        } else {
            highlight.visible   = false;	
        }
    }
    
    function setupHighlight() {	
        addChild(highlight = new Sprite());
        
        highlight.graphics.lineStyle(1, 0xff3300, 1);
        highlight.graphics.drawRect(0, 0, 10, 10);
        highlight.visible = false;
    }
    
    function setupText() {
        addChild(textBox = new TextField());
        textBox.x      = 10;
        textBox.y      = 10;
        textBox.width  = 700 - 10;
        textBox.height = 500 - 10;
        
        textBox.type        = TextFieldType.INPUT;
        textBox.multiline   = true;
        textBox.wordWrap    = true;
        textBox.background  = true;
        textBox.border      = true;

        addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

        var format      = new TextFormat();
        format.font     = "Courier";
        format.color    = 0xFFFFFF;
        format.size     = 8;

        textBox.background        = false;
        textBox.border            = false;
        textBox.defaultTextFormat = format;
    }    
}

#end
