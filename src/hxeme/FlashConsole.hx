/**
* ...
* @author Chase Kernan
*/

package hxeme;

import hxeme.parsing.Tokenizer;
import hxeme.parsing.Parser;
import hxeme.Interp;

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

class FlashConsole extends Sprite { 
    
    static var display:TextField;
    
    var highlight:Shape;
    var lastCaret:Int;
    
    var interp: Interp;
    var tokenizer: Tokenizer;
    var parser: Parser;
    
    public function new() {
        super();
        
        setupStage();
        setupDisplay();
        setupHighlight();
        
        tokenizer = new Tokenizer();
        parser = new Parser();
        interp = new Interp();
        
        prompt();
    }
    
    function prompt() {
        display.appendText("hXe>");//(defun square (x) (* x x))
        moveCaretToEnd();
        
        lastCaret = display.caretIndex;
        if (lastCaret == -1) lastCaret = 5;
    }
    
    function findMatch(a: String, dir: Int): Int {
        var c:String;
        var count = 0;
        var i = 0;
        if (dir == -1) i = a.length - 1;
        
        while (i >= 0 && i < a.length) {
            var c = a.charAt(i);
            
            if (c == "(") count++;
            else if (c == ")") count--;
            
            if (count == 0) return i;
            
            i += dir;
        }
        
        return -1;
    }
    
    function onKeyUp(evt: KeyboardEvent) {
        if (evt.keyCode == Keyboard.ENTER) {
            var i = display.caretIndex;
            var start = findMatch(display.text.substr(0, i) + ")", -1);
            
            if (start == -1) {
                var command = display.text.substr(lastCaret, i);
                
                highlightChar( -1);
                try {
                    var parsed = parser.parse(tokenizer.tokenizeString(command));
                    var printLine = interp.evalAll(parsed);
                    output(printLine.toString());
                } catch (e: Dynamic) {
                    output("Error: " + e);
                }
                
                prompt();	
            }
            else
            {
                tab(start+2);
            }
        }
        else highlightMatchingParen();
    }
    
    public static function OutputNR(a: String) {
        display.appendText(a);
    }
    
    public static function output(a: String) {
        if (display.text.charAt(display.text.length - 1) != "\n") display.appendText("\n");
        display.appendText(a + "\n");
    }
    
    function tab(a: Int) {
        var rect = display.getCharBoundaries(a);
        var numSpaces = Std.int(rect.x / rect.width);
        for(i in 0...numSpaces) display.appendText(" ");
        moveCaretToEnd();
    }
    
    function moveCaretToEnd() {
        var newCaretIndex = display.text.length;
        display.setSelection(newCaretIndex, newCaretIndex);
    }
    
    function onMouseUp(evt: MouseEvent) {
        highlightMatchingParen();
    }
    
    function highlightMatchingParen() {
        var matchIndex = -1;
        var i = display.caretIndex;
        
        if (display.text.charAt(i - 1) == ")") {
            matchIndex = findMatch(display.text.substr(0, i), -1);
        } else if (display.text.charAt(i) == "(") {
            matchIndex = i + findMatch(display.text.substr(i), 1);
        }
        
        highlightChar(matchIndex);
    }
    
    function highlightChar(a: Int) {
        var rect = display.getCharBoundaries(a);
        
        if (rect != null) {
            highlight.visible = true;
            highlight.x = display.x + rect.x;
            highlight.y = display.y + rect.y;
            highlight.width = rect.width;
            highlight.height = rect.height;
        } else {
            highlight.visible=false;	
        }
    }
    
    function setupHighlight() {	
        highlight = new Shape();
        //highlight.graphics.beginFill(0xff3300, 0.3);
        highlight.graphics.lineStyle(1, 0xff3300, 1);
        highlight.graphics.drawRect(0, 0, 10, 10);
        highlight.visible = false;
        
        addChild(highlight);	
    }
    
    function setupDisplay() {
        display = new TextField();
        display.x = 10;
        display.y = 10;
        resizeHandler();
        
        display.type = TextFieldType.INPUT;
        display.multiline = true;
        display.wordWrap = true;
        display.background = true;
        display.border = true;

        addEventListener(KeyboardEvent.KEY_UP, onKeyUp);
        addEventListener(MouseEvent.MOUSE_UP, onMouseUp);

        var format:TextFormat = new TextFormat();
        format.font = "Courier";
        format.color = 0xFFFFFF;
        format.size = 8;

        display.background = false;
        display.border = false;
        display.defaultTextFormat = format;
        addChild(display);
    }
    
    function setupStage() {
        //stage.scaleMode = StageScaleMode.NO_SCALE;
        //stage.align = StageAlign.TOP_LEFT;
        //stage.addEventListener(Event.RESIZE, resizeHandler);
    }
    
    function resizeHandler() {
        //trace(stage.stageWidth);
        display.width = 780;//Stage.stageWidth-20;
        display.height = 580;//Stage.stageHeight-20;
    }
}