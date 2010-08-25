////////////////////////////////////////////
// Project: Flash 10 Coverflow
// Date: 10/3/09
// Author: Stephen Weber
////////////////////////////////////////////
package weber.flow{
	
	////////////////////////////////////////////
	// IMPORTS
	////////////////////////////////////////////
	import flash.display.Sprite;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.display.Bitmap;
	import flash.display.Stage;
			import flash.events.TUIO;
	import flash.events.TouchEvent;
	import flash.geom.Point;

	//TweenLite - Tweening Engine - SOURCE: http://blog.greensock.com/tweenliteas3/
	import com.greensock.*;
	import com.greensock.easing.*;

	public class Scrollbar extends Sprite {
		
		////////////////////////////////////////////
		// VARIABLES
		////////////////////////////////////////////
		private var _value:int;

		private var _maxValue:int;

		private var _stage:Stage;

		private var _ratio:Number;
		private var scrubberId:Number;
		
		////////////////////////////////////////////
		// CONSTRUCTOR - INITIAL ACTIONS
		////////////////////////////////////////////
		public function Scrollbar(__maxValue:Number, __stage:Stage):void {

			_maxValue=(__maxValue - 1);
			
			_ratio=((track.width) - (scrubber.width))/_maxValue;

			_stage=__stage;

			left.buttonMode=true;
			left.addEventListener(MouseEvent.CLICK, left_Click);
			left.addEventListener(TouchEvent.CLICK, left_Click);

			right.buttonMode=true;
			right.addEventListener(MouseEvent.CLICK, right_Click);
			right.addEventListener(TouchEvent.CLICK, right_Click);
			scrubber.buttonMode=true;
			scrubber.addEventListener(MouseEvent.MOUSE_DOWN, scrubber_Down);
			//scrubber.addEventListener(TouchEvent.MOUSE_DOWN, scrubber_Down);
			this.addEventListener(TouchEvent.MOUSE_MOVE, mouseMove);

		}
		////////////////////////////////////////////
		// GETTERS/SETTERS
		////////////////////////////////////////////
		public function get value():int {

			return _value;

		}
		public function set value(_input:int):void {

			_value=_input;

			update();

		}
		
		////////////////////////////////////////////
		// FUNCTIONS
		////////////////////////////////////////////
		private function update():void {
			trace("tween to : "+(_value*_ratio));
			TweenLite.to(scrubber, 0.25, {x:(_value*_ratio)});

		}
		private function scrubber_Down(e:Event):void {
			
			this.addEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			_stage.addEventListener(MouseEvent.MOUSE_UP, mouseUp);
			scrubber.removeEventListener(MouseEvent.MOUSE_DOWN, scrubber_Down);

			
		}
			
		private function mouseMove(e:Event):void {
			
			var _mouseX:Number;
			
			if(e is TouchEvent)
			{
				
				var p:Point = new Point();
				p.x = this.x;
				p.y = 0;
				
				_mouseX=(e as TouchEvent).stageX-localToGlobal(p).x+this.x;
				trace(_mouseX);
			}
			else
			{
				trace("mouse");
				_mouseX = this.mouseX;
			}

			var _availableTrackLength:Number=track.width-scrubber.width;

			if ((_mouseX<track.width) && (0 < _mouseX)) {

				var _xPos:int = (_mouseX/_ratio);

				if (_mouseX<_availableTrackLength) {

					_value=_xPos;
					scrubber.x=_xPos*_ratio;
					
				} else {
					
					_value = (_maxValue);
					scrubber.x=_availableTrackLength;

				}

				trace("SETTING TO VALUE: "+ _value);
				
				update();

				dispatchEvent(new Event("UPDATE"));
				
			}

		}
		private function mouseUp(e:Event):void {

			_stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUp);
			
			this.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMove);
			
			scrubber.addEventListener(MouseEvent.MOUSE_DOWN, scrubber_Down);
			

		}
		private function left_Click(e:Event):void {

			if (_value>0) {
				_value--;
				update();

			dispatchEvent(new Event("PREVIOUS"));
			}
			

		}
		private function right_Click(e:Event):void {

			if (_value<(_maxValue)) {
				_value++;
				update();

			dispatchEvent(new Event("NEXT"));
			}
			

		}
	}
}