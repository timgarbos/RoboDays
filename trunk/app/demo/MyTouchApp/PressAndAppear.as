package app.demo.MyTouchApp{
 
	import flash.events.TUIO;
	import flash.events.TouchEvent;
	import flash.events.Event;
	import flash.display.*;
 
	public class PressAndAppear extends Sprite {
 
		public function PressAndAppear():void {
			//--------connect to TUIO-----------------
			TUIO.init(this,'localhost',3000,'',true);
			addEventListener(TouchEvent.MOUSE_MOVE, onTouchMove);
			addEventListener(TouchEvent.MOUSE_DOWN, onTouchDown);
		}
		public function onTouchDown(e:TouchEvent):void {
			var dynamicObj:MovieClip = new libraryItem();
			dynamicObj.name = e.ID.toString();
			dynamicObj.x = e.localX;
			dynamicObj.y = e.localY;
			addChild(dynamicObj);
			dynamicObj.addEventListener(Event.ENTER_FRAME, checkForRemoval);
		}
		public function onTouchMove(e:TouchEvent):void {
			var target:DisplayObject = getChildByName(e.ID.toString());
			target.x = e.stageX;
			target.y = e.stageY;
		}
		public function checkForRemoval(e:Event):void {
			if (!TUIO.getObjectById(e.target.name)) {
				e.target.removeEventListener(Event.ENTER_FRAME, checkForRemoval);
				removeChild(e.target as MovieClip);
			}
		}
	}
}