package app.demo.MyTouchApp{
 
	import flash.events.TUIO;
	import flash.events.TouchEvent;
	import flash.events.Event;
	import flash.display.*;
	import flash.display.Sprite;
 import flash.display.StageScaleMode;
 	import flash.system.fscommand;
	public class ShowFinger extends Sprite {
 		var isShowing:Boolean = false;
 
		public function ShowFinger():void {
			
			
			stage.scaleMode = StageScaleMode.NO_SCALE;
			
			//--------connect to TUIO-----------------
			trace("Finger connecting to TUIO");
			TUIO.init(this,'localhost',3000,'',true);
			
		}
		public function showCursor()
		{
			if(!isShowing)
			{
		
			addEventListener(TouchEvent.MOUSE_MOVE, onTouchMove);
			addEventListener(TouchEvent.MOUSE_DOWN, onTouchDown);
			}
		}
		
		public function hideCursor()
		{
			if(isShowing)
			{
			removeEventListener(TouchEvent.MOUSE_MOVE, onTouchMove);
			removeEventListener(TouchEvent.MOUSE_DOWN, onTouchDown);
			}
		}
		public function onTouchDown(e:TouchEvent):void {
			var dynamicObj:MovieClip = new Finger();
			dynamicObj.name = e.ID.toString();
			dynamicObj.x = e.localX;
			dynamicObj.y = e.localY;
			addChild(dynamicObj);
			dynamicObj.addEventListener(Event.ENTER_FRAME, checkForRemoval);
		}
		public function onTouchMove(e:TouchEvent):void {
			if (getChildByName(e.ID.toString())) {
			var target:DisplayObject = getChildByName(e.ID.toString());
			target.x = e.stageX;
			target.y = e.stageY;
			}
			
		}
		public function checkForRemoval(e:Event):void {
			if (!TUIO.getObjectById(e.target.name)) {
				e.target.removeEventListener(Event.ENTER_FRAME, checkForRemoval);
				removeChild(e.target as MovieClip);
			}
		}
	}
}