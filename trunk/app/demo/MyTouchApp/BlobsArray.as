package app.demo.MyTouchApp{
 
    import flash.events.TUIO;// allows to connect to touchlib/tbeta
    import flash.events.TouchEvent;// allows to use TouchEvent Event Listeners
	import flash.events.*;
	import flash.display.*;
 	import flash.geom.Point;
	import flash.utils.getTimer;

    public class BlobsArray extends Sprite {

		public function BlobsArray():void {
 
            //--------connect to TUIO-----------------
            TUIO.init(this,'localhost',3000,'',true);
            trace("TouchArrayInfo Initialized");
			
			this.addEventListener(Event.ENTER_FRAME, this.update, false, 0, true);		
        }
		
		private function update(e:Event):void
		{
			trace(TUIO.returnBlobs());
		}
    }
}