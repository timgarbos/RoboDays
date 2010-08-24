package app.GoogleAPI{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.Point;
	import com.google.maps.LatLng;
	import com.google.maps.Map;
	import com.google.maps.MapEvent;
	import com.google.maps.MapType;

	import flash.events.TUIO;// allows to connect to touchlib/tbeta
	import flash.events.TouchEvent;// allows to use TouchEvent Event Listeners

	public class googlemap extends Sprite {
		private var map:Map = new Map();
		private var origPt1:Point;
		private var origPt2:Point;
		private var origZoom:Number;

		public function googlemap() {

			TUIO.init(this,'localhost',3000,'',true);

			map.key="ABQIAAAAuceiCelFJ-CPPKzVT6lXlhT2yXp_ZAY8_ufC3CFXhHIE1NvwkxSzjHxihilxG0CTqSSPNt_F8rwy0Q";
			map.setSize(new Point(1024, 768));
			map.addEventListener(MapEvent.MAP_READY, onMapReady);
			this.addChild(map);

			function onMapReady(event:Event):void {
				map.setCenter(new LatLng(55.869147,11.228027), 7,MapType.SATELLITE_MAP_TYPE);
				map.enableContinuousZoom()
			}

			this.addEventListener(TouchEvent.MOUSE_DOWN, onTouchUpDown);
			this.addEventListener(TouchEvent.MOUSE_UP, onTouchUpDown);
			this.addEventListener(TouchEvent.MOUSE_MOVE, onTouchMove);
		}
		private function onTouchUpDown(evt:TouchEvent):void {
			if (TUIO.returnBlobs().length == 2) {
				var tuioobjOriginal1 = TUIO.returnBlobs()[0];
				var tuioobjOriginal2 = TUIO.returnBlobs()[1];
				origPt1 = new Point(tuioobjOriginal1.getTouchNewPoint().x, tuioobjOriginal1.getTouchNewPoint().y);
				origPt2 = new Point(tuioobjOriginal2.getTouchNewPoint().x, tuioobjOriginal2.getTouchNewPoint().y);
				origZoom = map.getZoom();
			}
		}
		private function onTouchMove(evt:TouchEvent):void {
			if (TUIO.returnBlobs().length == 2) {
				var tuioobj1 = TUIO.returnBlobs()[0];
				var tuioobj2 = TUIO.returnBlobs()[1];

				var curPt1:Point = new Point(tuioobj1.getTouchNewPoint().x, tuioobj1.getTouchNewPoint().y);
				var curPt2:Point = new Point(tuioobj2.getTouchNewPoint().x, tuioobj2.getTouchNewPoint().y);
				
				var len1:Number = Point.distance(origPt1, origPt2);
				var len2:Number = Point.distance(curPt1, curPt2);

				var newscale:Number = len2/len1;

				if (newscale >= 1) {
					map.setZoom(origZoom + (Math.floor(newscale)-1));
				} else {
					newscale = len1/len2;
					map.setZoom(origZoom - (Math.floor(newscale)-1));
				}
			} else {
				var newTouchItem = TUIO.returnBlobs()[0];
				var shiftX = (newTouchItem.getTouchOldPoint().x - newTouchItem.getTouchNewPoint().x);
				var shiftY = (newTouchItem.getTouchOldPoint().y - newTouchItem.getTouchNewPoint().y);
				var movePt:Point = new Point(shiftX * 2, shiftY * 2);
				map.panBy(movePt);
			}
		}
	}
}