package app.demo.MyTouchApp{
 
    import flash.events.TUIO;// allows to connect to touchlib/tbeta
    import flash.events.TouchEvent;
    import flash.events.Event;// allows to connect to touchlib/tbeta
    import flash.display.*; 
    import flash.net.*;
    import flash.geom.*; 
	import app.CollisionDetection;
 
    public class Squeege extends Sprite {
 
 		private var holder:MovieClip = new MovieClip();
 		private var imageHolder:MovieClip = new MovieClip();
        private var num:Number=5; // number of rings to put
		private var loader:Loader = new Loader();
        var ring:Ring; //ring class (at bottom)
		var bigRing:MainRing;
		var ringArray = new Array();
 		private var blobs:Array = new Array();// blobs we are currently interacting with

        public function Squeege():void {
 
			addChild(imageHolder);
			
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
			loader.load(new URLRequest("squeegee.jpg"));
			
 			addChild(holder);
			
			
            //--------connect to TUIO-----------------
            TUIO.init(this,'localhost',3000,'',true);
            trace("MyTouchApp Initialized");
            //----------------------------------------
			
 
            // put "num" rings randomly on the stage
            for (var j:int = 0; j < 8; j++) {
				for (var i:int = 0; i < 11; i++) {
					ring = new Ring();
					ring.x = i * 100 + 12;
					ring.y = j * 100 + 12;
					ringArray.push(ring);
					holder.addChild(ring);
				}
			}
			
			/*bigRing = new MainRing(0, 60);
			bigRing.x = 300;
			bigRing.y = 200;
			bigRing.alpha = .2;
			addChild(bigRing);*/
			
			addEventListener(TouchEvent.MOUSE_MOVE, moveUpdate);
			addEventListener(Event.ENTER_FRAME, moveInfo);
			
			addEventListener(TouchEvent.MOUSE_DOWN, touchDown);
			addEventListener(TouchEvent.MOUSE_UP, touchUp);
			
			
        }
		
		private function imageLoaded(event:Event):void
		{
			var image:Bitmap = new Bitmap(event.target.content.bitmapData);
			imageHolder.addChild(image);
			imageHolder.mask = holder;
		}


		
		public function touchDown(e:TouchEvent):void{ 
            var curPt:Point = parent.globalToLocal(new Point(e.stageX, e.stageY)); //convert touch points to x,y 
			
			var bigRing = new MainRing(0, 100);
			bigRing.x = curPt.x;
			bigRing.y = curPt.y;
			bigRing.alpha = 0;
			addChild(bigRing);
			bigRing.addEventListener(TouchEvent.MOUSE_UP, touchUp);
			
			addBlob(e.ID, curPt.x, curPt.y, bigRing, e);
			
        }
		
		public function moveInfo(evt:Event):void{ 
			var hitted:Array = new Array();
			for (var bs=0;bs<blobs.length; bs++) {
				
				blobs[bs].bigRing.x = blobs[bs].e.stageX;
				blobs[bs].bigRing.y = blobs[bs].e.stageY;
				
				for (var k:int = 0; k < ringArray.length; k++) {
					if(CollisionDetection.hitTestObject(blobs[bs].bigRing, ringArray[k], true, 255)){
						hitted.push(ringArray[k])
					}
					ringArray[k].width = 10;
					ringArray[k].height = 10;
				}
				
			}
			if(hitted.toString() == ""){
				for (var reset:int = 0; reset < ringArray.length; reset++) {
					ringArray[reset].width = 10;
					ringArray[reset].height = 10;
				}
			}
			else{
				trace("NO HITS")
				for (var z:int = 0; z < hitted.length; z++) {
					for (var r:int = 0; r < blobs.length; r++) {
						if(hitted[z].width <= 200){
							hitted[z].width += 200 - GEN_get2DDistance(blobs[r].bigRing.x, blobs[r].bigRing.y, hitted[z].x, hitted[z].y);
							hitted[z].height += 200 - GEN_get2DDistance(blobs[r].bigRing.x, blobs[r].bigRing.y, hitted[z].x, hitted[z].y);
						}
					}
				}
			}
			

			if(TUIO.returnBlobs().length != blobs.length) { //TEST total number of existing blobs compared to entire array (check for missed removed blobs)
				removeBlob(blobs[0].id) //remove blob in spot 0, mostly likely missed remove blob value
			}
		}
		
		function addBlob(id:Number, origX:Number, origY:Number, bigRing, e) {
			blobs.push( {id: id, origX: origX, origY: origY, myOrigX: x, myOrigY:y, oldX:x, oldY: y, bigRing:bigRing, e:e} );
			for (var i=0; i<blobs.length; i++) {
				if (blobs[i].id == id) {
					//trace(blobs)	
					return;
				}
			}
		}
	    
		public function touchUp(e:TouchEvent):void{  
			removeBlob(e.ID);
		}
	
		function removeBlob(id:Number) {
			for (var i=0; i<blobs.length; i++) {
				if (blobs[i].id == id) {
					//delete(blobs[i].bigRing);
					removeChild(blobs[i].bigRing);
					blobs.splice(i, 1);
					return;
				}
			}
		}

		public function checkHit(e:Event):void{
		}
		
		public function GEN_get2DDistance(ax, ay, bx, by):Number {
			var dx = ax-bx;
			var dy = ay-by;
			var theDistance = Math.sqrt(dx*dx+dy*dy);
			return theDistance;
		}
		
		function moveUpdate(e:TouchEvent):void{
			for (var i=0; i<blobs.length; i++) {
				if(blobs[i].e.ID == e.ID){
					blobs[i].e.stageX = e.stageX;
					blobs[i].e.stageY = e.stageY;
					/*blobs[i].bigRing.x = blobs[i].e.localX;
					blobs[i].bigRing.y = blobs[i].e.localY;*/
				}
			}
		}
 
    }
}
 
import flash.display.Sprite; // ring class
 
class Ring extends Sprite {
    public function Ring(thickness:Number = 0, radius:Number = 5, color:uint = 0xff0000) {
        graphics.drawCircle(0,0,radius);
        graphics.beginFill(0xffffff);
        graphics.drawCircle(0,0,radius);
        graphics.endFill();
    }
} 

import flash.display.Sprite; // ring class
import app.core.action.RotatableScalable;
 
class MainRing extends Sprite {
	
	private var noScale;
	private var noRotate;
 
    public function MainRing(thickness:Number = 0, radius:Number = 5, color:uint = 0xff0000) {
 
        //---RotatableScalable options------------
            noScale = true;
            noRotate = true;    
            //noMove = true;
        //----------------------------------------
 
        //graphics.lineStyle(thickness, color);
        graphics.drawCircle(0,0,radius);
 
        graphics.beginFill(0xffffff);
        graphics.drawCircle(0,0,radius);
        graphics.endFill();
    }
} 