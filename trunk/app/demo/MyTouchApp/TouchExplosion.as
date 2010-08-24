package app.demo.MyTouchApp{
 
	import flash.events.TUIO;// allows to connect to touchlib/tbeta
	import flash.events.TouchEvent;
	import flash.events.Event;// allows to connect to touchlib/tbeta
	import flash.display.*;
	import flash.net.*;
	import flash.geom.*;
	import flash.filters.BitmapFilter;
	import flash.filters.BitmapFilterQuality;
	import flash.filters.BlurFilter;
	import flash.system.*;
 
	public class TouchExplosion extends Sprite {
 
		private var particleMaxSpeed:Number = 5;
		private var particleFadeSpeed:Number = 5;
		private var particleTotal:Number = 20;
		private var particleRange:Number = 100;
 
		public function TouchExplosion():void {
 
			//--------connect to TUIO-----------------
			TUIO.init(this,'localhost',3000,'',true);
			trace("TouchExplosion Initialized");
			//----------------------------------------
 
			addEventListener(TouchEvent.MOUSE_DOWN, touchDown);
 
		}
		public function touchDown(e:TouchEvent):void {
			createExplosion(e.localX, e.localY);
		}
		private function getBitmapFilter():BitmapFilter {
			var blurX:Number = 5;
			var blurY:Number = 5;
			return new BlurFilter(blurX,blurY,BitmapFilterQuality.HIGH);
		}
		public function createExplosion(targetX:Number, targetY:Number):void {
 
			trace("new at: "+targetX+" : "+targetY);
			//run for loop based on particleTotal
			for (var i:Number = 0; i < particleTotal; i++) {
 
				var myBmp:MovieClip = new MovieClip();// holds particle for animation, fading and scaling
 
				var bmd:BitmapData = new BitmapData(40, 40, false, 0xFF0000);
				var rect:Rectangle = new Rectangle(0, 0, 40, 40);
				bmd.fillRect(rect, 0xFF0000);
 
				var bm:Bitmap = new Bitmap(bmd);
				myBmp.addChild(bm);//this is the particle in the end myBmp
 
				var particle_mc = new MovieClip();//create the 'main holder' movieclip that will hold our particle
				addChild(particle_mc);//adds it to stage
 
				var filter:BitmapFilter = getBitmapFilter();
				var myFilters:Array = new Array();
				myFilters.push(filter);
				particle_mc.filters = myFilters;//this only applies a blur filter to softed the rectangles (optional)
				particle_mc.x = -myBmp.width/2;//set particle x and y position in center of the touch point based on size
				particle_mc.y = -myBmp.height/2;
 
				particle_mc.addChild(myBmp);//finally, attach the bitmapData "myBmp" to the movieclip "particle_mc" which is already on the stage
 
				//set position & rotation, alpha. targetX and targetY come from the touch points data.
				particle_mc.x = targetX;
				particle_mc.y = targetY;
				particle_mc.rotation = Math.random()*360;
				particle_mc.alpha = Math.random()*1;
 
				//set speed/direction of fragment - speed randomizer
				particle_mc.speedX = Math.random()*particleMaxSpeed-Math.random()*particleMaxSpeed;
				particle_mc.speedY = Math.random()*particleMaxSpeed-Math.random()*particleMaxSpeed;
				particle_mc.speedX *= particleMaxSpeed;
				particle_mc.speedY *= particleMaxSpeed
				;
				particle_mc.addEventListener(Event.ENTER_FRAME, moveFragment);
 
			}
			trace("System memory used by this program: " + System.totalMemory);// i finally found something to track memory in tracing
			//on my computer, garbage collecting seems to keep the flash around 7-10Megs of memory usage.
			//without garbage collecting, memmory usage would just keep increasing till the flash halted the computer.
		}
		public function moveFragment(e:Event):void {
			//e.target means that item is using the listener code, in this case it's particle_mc.
			e.target.alpha -= .05;
			e.target.x += e.target.speedX;
			e.target.y += e.target.speedY;
			e.target.scaleX -= .1;
			e.target.scaleY -= .1;
			if (e.target.alpha <= 0) {
				e.target.removeEventListener(Event.ENTER_FRAME, moveFragment);
				removeChild(e.target as DisplayObject);//removeChild makes sure this MovieClip can be garbage collected, e.target as DisplayObject is particle_mc
			}
		}
	}
}