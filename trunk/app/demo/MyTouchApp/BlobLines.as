package app.demo.MyTouchApp{
 
    import flash.events.TUIO;// allows to connect to touchlib/tbeta
    import flash.events.TouchEvent;// allows to use TouchEvent Event Listeners
	import flash.events.*;
	import flash.display.*;
 
    public class BlobLines extends Sprite {

		private var my_line:Shape = new Shape();
		
        public function BlobLines():void {
 
            //--------connect to TUIO-----------------
            TUIO.init(this,'localhost',3000,'',true);
            trace("TouchArrayInfo Initialized");
			
			addEventListener(TouchEvent.MOUSE_DOWN, touchDown);                    //run touchDown, when touching environment
			addEventListener(TouchEvent.MOUSE_UP, touchUp);                        //run touchUp, when un-touching environment
			addEventListener(TouchEvent.MOUSE_MOVE, moveUpdate);                   //run moveUpdate, when any touching point is moved
			
			addEventListener(Event.ENTER_FRAME, extraClear);
        }
		
		public function updateCall():void{  
			my_line.graphics.clear();
			for (var i=0; i<TUIO.returnBlobs().length; i++) {
				addChild(my_line);
				my_line.graphics.lineStyle(10, 0xF46000);  
				my_line.graphics.moveTo(20+100*i, 20);  
				my_line.graphics.lineTo(TUIO.returnBlobs()[i].x,TUIO.returnBlobs()[i].y);  
			}
        }
		
		public function extraClear(e:Event):void{
			if(TUIO.returnBlobs().length == 0){
				my_line.graphics.clear();
			}
        }
		public function touchDown(e:TouchEvent):void{
			updateCall();
        }
		public function touchUp(e:TouchEvent):void{
			updateCall();
		}
		public function moveUpdate(e:TouchEvent):void{
			updateCall();
		}		
    }
}