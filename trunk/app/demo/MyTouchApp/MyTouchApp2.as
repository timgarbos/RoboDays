package app.demo.MyTouchApp{
 
    import flash.display.*;
    import flash.events.*;
    import flash.net.*;
    import flash.geom.*;
    import app.core.action.RotatableScalable;
 
    public class MyTouchApp2 extends RotatableScalable {//allows it to be scaled around
        public function MyTouchApp2() {
 
            //--------connect to TUIO-----------------
            TUIO.init(this,'localhost',3000,'',true);
            trace("MyTouchApp Initialized");
            //----------------------------------------        
            addEventListener(TouchEvent.MOUSE_DOWN, touchDown);//run touchdown, when touched
        }
 
        public function touchDown(e:TouchEvent):void {
 
            var curPt:Point=parent.globalToLocal(new Point(e.stageX,e.stageY));//convert touch points to x,y                
            var circle:Sprite = new Sprite();//create a new sprite
 
            circle.graphics.lineStyle(10, 0xff0000);//set line width to 10px and red
            circle.graphics.drawCircle(0,0,40);// draw a 40px circle
            circle.x=curPt.x;//put it where touch is (x cord)
            circle.y=curPt.y;//put it where touch is (y cord)
            addChild(circle);//add the circle where touch happened
 
        }
    }
} 