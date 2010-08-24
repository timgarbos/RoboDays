package app.demo.MyTouchApp {
 
    import flash.events.TUIO;
    import flash.events.TouchEvent;
    import flash.events.Event;
	import app.demo.MyTouchApp.touchVines;
    import flash.display.*;
    import flash.net.*;
    import flash.geom.*;
	//import flash.system.*;
	import fl.transitions.Tween;
	import fl.transitions.easing.*;
 
    public class touchVinesBase extends Sprite {
	
        public function touchVinesBase():void {
 
            //--------connect to TUIO-----------------
            TUIO.init(this,'localhost',3000,'',true);
            trace("MyTouchApp Initialized");
            //----------------------------------------        
			
			addEventListener(TouchEvent.MOUSE_MOVE, onTouchMove);
			addEventListener(TouchEvent.MOUSE_DOWN, onTouchDown);
			//addEventListener(Event.ENTER_FRAME, testMemory)
        }
		
		public function onTouchDown(e:TouchEvent):void {
			var dynamicObj:touchVines = new touchVines();
			dynamicObj.name = e.ID.toString();
			dynamicObj.x = e.stageX;
			dynamicObj.y = e.stageY;
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
				removeChild(e.target as touchVines);
			}
		}
		/*public function testMemory(e:Event):void{
			trace("System memory used by this program: " + System.totalMemory);// i finally found something to track memory in tracing
			//on my computer, garbage collecting seems to keep the flash around 7-10Megs of memory usage.
			//without garbage collecting, memmory usage would just keep increasing till the flash halted the computer.

		}*/
    }
} 