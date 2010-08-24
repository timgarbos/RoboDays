package app.demo.MyTouchApp {
 
    import flash.display.*;
    import flash.net.*;
    import flash.geom.*;
	import flash.events.Event;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
 
    public class touchVines extends Sprite {
	
		public var start_x;
		public var start_y;
		public var length;
		public var size;
		public var end_x;
		public var end_y;
		public var blurVal;
		public var colorSet;
		public var mainHolder:MovieClip = new MovieClip();
		public var fractHoldler:MovieClip = new MovieClip();
			
        public function touchVines():void {
			mainHolder.addChild(fractHoldler);
			addChild(mainHolder)
			fractHoldler.x = 0;
			fractHoldler.y = 0;
		
			blurVal = 1;
			start_x = 0;
			start_y = 0;
			length = 100;
			size = 10;
			colorSet = (Math.random()*0xFFFFFF);
			this.addEventListener(Event.ENTER_FRAME, drawFractal);
        }
		public function drawFractal(e:Event):void {
			var angle = randomNumber(1, 360);
			var my_line:MovieClip = new MovieClip();
			fractHoldler.addChild(my_line);
			my_line.graphics.lineStyle(size, colorSet, 1.0, false, "normal", null, CapsStyle.ROUND, 3);
			my_line.graphics.moveTo(start_x, start_y);
		
			end_x = start_x+length*Math.cos(angle);
			end_y = start_y+length*Math.sin(angle);
			my_line.graphics.lineTo(end_x, end_y);
			
			start_x = end_x;
			start_y = end_y;
		
			var filter:BitmapFilter = getBitmapFilter(blurVal);
			var myFilters:Array = new Array();
			myFilters.push(filter);
			my_line.filters = myFilters;
			
			length = length*.8;
			size = size-1;
			
			if (size == 0) {
				colorSet = (Math.random()*0xFFFFFF);
				blurVal = randomNumber(1, 5);
				start_x = 0;
				start_y = 0;
				length = 50;
				size = 10;
			}

		}
		
		
		public function getBitmapFilter(thisVal):BitmapFilter {
			var blurX:Number = thisVal;
			var blurY:Number = thisVal;
			return new BlurFilter(blurX,blurY,BitmapFilterQuality.HIGH);
		}
		
		
		public function randomNumber(low:Number=NaN, high:Number=NaN):Number {
			var low:Number = low;
			var high:Number = high;
			if (isNaN(low)) {
				throw new Error("low must be defined");
			}
			if (isNaN(high)) {
				throw new Error("high must be defined");
			}
			return Math.round(Math.random() * high - low) + low;
		}
    }
}