package app.demo.MyTouchApp{

	import flash.events.TUIO;// allows to connect to touchlib/tbeta
	import flash.events.TouchEvent;// allows to use TouchEvent Event Listeners
	import flash.display.*;

	public class SimpleDrag extends Sprite {

		public function SimpleDrag():void {
			//--------connect to TUIO-----------------
			TUIO.init(this,'localhost',3000,'',true);
			addEventListener(TouchEvent.MOUSE_MOVE, moveUpdate);//run moveUpdate, when any touching point is moved

		}
		public function moveUpdate(e:TouchEvent):void {
			trace("moved: "+e.ID+" related to: "+e.relatedObject.name);
			e.relatedObject.x = e.localX;
			e.relatedObject.y = e.localY;
		}
	}
}