package app.demo.MyTouchApp{
 
    import flash.events.TUIO;// allows to connect to touchlib/tbeta
    import flash.events.TouchEvent;
    import flash.events.Event;// allows to connect to touchlib/tbeta
    import flash.display.*; 
    import flash.net.*;
    import flash.geom.*; 
 
    public class Rings extends Sprite {
 
 
        private var num:Number=5; // number of rings to put
        //var ring:Ringx; //ring class (at bottom)
 
        public function Rings():void {
 
            //--------connect to TUIO-----------------
            TUIO.init(this,'localhost',3000,'',true);
            trace("RINGS APP Initialized");
            //----------------------------------------
 
 
            // put "num" rings randomly on the stage
            for (var i:int = 0; i < num; i++) {
                objectR = new Ringx();
                objectR.x = Math.random() * 1024;
                objectR.y = Math.random() * 768;
                addChild(objectR);
            }
        }
 
    }
}
 
import flash.display.Sprite; // ring class
import app.core.action.RotatableScalable;
 
class Ringx extends RotatableScalable {
 
    public function Ringx(thickness:Number = 10, radius:Number = 40, color:uint = 0xff0000) {
 
        //---RotatableScalable options------------
            //noScale = true;
            noRotate = true;    
            //noMove = true;
        //----------------------------------------
 
        graphics.lineStyle(thickness, color);
        graphics.drawCircle(0,0,radius);
 
        graphics.beginFill(0xffffff);
        graphics.drawCircle(0,0,radius);
        graphics.endFill();
    }
} 