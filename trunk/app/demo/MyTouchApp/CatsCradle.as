package app.demo.MyTouchApp{
 
    import flash.events.TUIO;// allows to connect to touchlib/tbeta
    import flash.events.TouchEvent;// allows to use TouchEvent Event Listeners
	import flash.events.*;
	import flash.display.*;
 
    public class CatsCradle extends Sprite {

		private var my_line:MovieClip = new MovieClip();
		
        public function CatsCradle():void {
 
            //--------connect to TUIO-----------------
            TUIO.init(this,'localhost',3000,'',true);
            trace("TouchArrayInfo Initialized");
			
			addEventListener(TouchEvent.MOUSE_DOWN, touchDown);                    //run touchDown, when touching environment
			addEventListener(TouchEvent.MOUSE_UP, touchUp);                        //run touchUp, when un-touching environment
			addEventListener(TouchEvent.MOUSE_MOVE, moveUpdate);                   //run moveUpdate, when any touching point is moved
			
        }
		
		public function updateCall():void{  
			my_line.graphics.clear();
			if(TUIO.returnBlobs().length >= 2){
				for (var i=0; i<TUIO.returnBlobs().length; i++) {
					addChild(my_line);
					my_line.graphics.lineStyle(10, 0xF46000);  
					my_line.graphics.moveTo(TUIO.returnBlobs()[i].x,TUIO.returnBlobs()[i].y);  
					if(TUIO.returnBlobs()[i+1] != undefined){
						my_line.graphics.lineTo(TUIO.returnBlobs()[i+1].x,TUIO.returnBlobs()[i+1].y);  
						//Line.graphics.lineTo(blobs[i+1].e.stageX,blobs[i+1].e.stageY);
					}else{
						my_line.graphics.lineTo(TUIO.returnBlobs()[0].x,TUIO.returnBlobs()[0].y);  
						//Line.graphics.lineTo(blobs[0].e.stageX,blobs[0].e.stageY);
					}
				}
			}
			else if(TUIO.returnBlobs().length == 1){ // Makes new Start Point for lines
				my_line.graphics.moveTo(TUIO.returnBlobs()[0].x,TUIO.returnBlobs()[0].y)
			}
			else{ // Clears Lines
			}
        }
		
		public function touchDown(e:TouchEvent):void{
			updateCall();
        }
		public function touchUp(e:TouchEvent):void{
			updateCall()
		}
		public function moveUpdate(e:TouchEvent):void{
			updateCall()
		}		
    }
}