package app.demo.MyTouchApp{

	import flash.events.TUIO;// allows to connect to touchlib/tbeta
	import flash.events.TouchEvent;// allows to use TouchEvent Event Listeners
	import flash.events.Event;
	import flash.display.Sprite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.filters.*;
	import flash.geom.*;
	import flash.utils.Dictionary;

	public class SimpleDraw extends Sprite {

		private var paintBmpData:BitmapData;
		private var paintBmpData2:BitmapData;
		private var buffer:BitmapData;
		private var paintBmp:Bitmap;
		private var brush:Sprite;
		private var filter:BitmapFilter;
		private var filter2:BitmapFilter;
		public var col:ColorTransform;

		private var colorArray = new Dictionary(true);

		public function SimpleDraw():void {

			//--------connect to TUIO-----------------
			TUIO.init(this,'localhost',3000,'',true);
			trace("TouchArrayInfo Initialized");

			paintBmpData=new BitmapData(1024,768,true,0x00000000);
			brush=new Sprite;
			brush.graphics.beginFill(0xDDDDDD);
			brush.graphics.drawCircle(0,0,25);
			col = new ColorTransform(0,0,0);
			paintBmp=new Bitmap(paintBmpData);
			var cmat:Array=[1,1,1,1,1,1,1,1,1];
			filter=new ConvolutionFilter(50,50,cmat,10,10,true);
			filter2=new BlurFilter(15,15);
			addChild(paintBmp);
			addEventListener(TouchEvent.MOUSE_DOWN,touchDown);
			addEventListener(TouchEvent.MOUSE_UP,touchUp);
			addEventListener(Event.ENTER_FRAME,updateCall, false, 0, true);

		}
		public function updateCall(e:Event):void {
			for (var i=0; i < TUIO.returnBlobs().length; i++) {
				var localPt:Point=new Point(TUIO.returnBlobs()[i].x,TUIO.returnBlobs()[i].y);
				var m:Matrix=new Matrix;
				m.translate(localPt.x,localPt.y);
				paintBmpData.draw(brush,m,colorArray[TUIO.returnBlobs()[i].thisID]);
			}
			paintBmpData.applyFilter(paintBmpData, paintBmpData.rect, new Point(), filter2);
		}
		public function touchDown(e:TouchEvent):void {
			col = new ColorTransform(randomNumber(0,1),randomNumber(0,1),randomNumber(0,1));
			colorArray[e.ID] = col;
		}
		public function touchUp(e:TouchEvent):void {
			colorArray[e.ID] = null;
		}
		function randomNumber(low:Number=NaN,high:Number=NaN):Number {
			var low:Number=low;
			var high:Number=high;
			return Math.round(Math.random() * high - low) + low;
		}
	}
}