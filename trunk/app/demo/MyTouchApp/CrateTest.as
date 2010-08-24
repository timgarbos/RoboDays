package app.demo.MyTouchApp{
	import flash.display.Sprite;
    import flash.display.*;        
    import flash.events.*;
    import flash.net.*;
    import flash.geom.*; 
	import flash.events.MouseEvent;
	import app.core.action.RotatableScalable;
	import flash.utils.getTimer;

	import Box2D.Dynamics.*;
	import Box2D.Collision.*;
	import Box2D.Collision.Shapes.*;
	import Box2D.Common.Math.*;
	import Box2D.Dynamics.Joints.*;
	public class CrateTest extends MovieClip {
		
		public var m_world:b2World;
		public var m_iterations:int = 10;
		public var m_timeStep:Number = 1/30;
		public var mousePVec:b2Vec2 = new b2Vec2();
		public var real_x_mouse:Number;
		public var real_y_mouse:Number;
		public var pixels_in_a_meter = 30;
		public var worldAABB:b2AABB = new b2AABB();
		public var gravity:b2Vec2 = new b2Vec2(0.0, 0.0);
		public var mouseJoint:b2MouseJoint;
		public var blobs:Array = new Array();// blobs we are currently interacting with
		public var mouseJointArray:Array = new Array();// blobs we are currently interacting with
		public var xdist:Number;
		public var ydist:Number;
		public var distance:Number;
		private var oldX:Number = 0;
		private var oldY:Number = 0;		
		public var doubleclickDuration:Number = 10;
		public var clickRadius:Number = 50;		
		public var lastClick:Number = 0;
	
		public function CrateTest() {
			TUIO.init( this, 'localhost', 3000, '', true );
			addEventListener(Event.ENTER_FRAME, Update, false, 0, true);
			addEventListener(TouchEvent.MOUSE_MOVE, moveUpdate); //update values, when touch dragged
			addEventListener(TouchEvent.MOUSE_DOWN, on_mouse_down);
			//stage.addEventListener(TouchEvent.DOUBLE_CLICK, on_doubleClick);
			addEventListener(TouchEvent.MOUSE_UP, on_mouse_up);
			worldAABB.lowerBound.Set(-100.0, -100.0);
			worldAABB.upperBound.Set(100.0, 100.0);
			m_world = new b2World(worldAABB, gravity, true);
			var body:b2Body;
			var bodyDef:b2BodyDef;
			var boxDef:b2PolygonDef;
			
			bodyDef = new b2BodyDef();
			bodyDef.position.Set(10.5, 0);
			boxDef = new b2PolygonDef();
			var ground_width = 34.13;
			var ground_height = 0.5;
			boxDef.SetAsBox(ground_width, ground_height);
			boxDef.friction = 0;
			boxDef.density = 0;
			bodyDef.userData = new floor();
			bodyDef.userData.width = ground_width * 2 * pixels_in_a_meter;
			bodyDef.userData.height = ground_height * 2 * pixels_in_a_meter;
			addChild(bodyDef.userData);
			body = m_world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
	
			bodyDef = new b2BodyDef();
			bodyDef.position.Set(10.5, 25.6);
			boxDef = new b2PolygonDef();
			boxDef.SetAsBox(ground_width, ground_height);
			boxDef.friction = 0;
			boxDef.density = 0;
			bodyDef.userData = new floor();
			bodyDef.userData.width = ground_width * 2 * pixels_in_a_meter;
			bodyDef.userData.height = ground_height * 2 * pixels_in_a_meter;
			addChild(bodyDef.userData);
			body = m_world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
	
			bodyDef = new b2BodyDef();
			bodyDef.position.Set(0, 0);
			boxDef = new b2PolygonDef();
			ground_width = 0.5;
			ground_height = 25.5;
			boxDef.SetAsBox(ground_width, ground_height);
			boxDef.friction = 0;
			boxDef.density = 0;
			bodyDef.userData = new floor();
			bodyDef.userData.width = ground_width * 2 * pixels_in_a_meter;
			bodyDef.userData.height = ground_height * 2 * pixels_in_a_meter;
			addChild(bodyDef.userData);
			body = m_world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
	
			bodyDef = new b2BodyDef();
			bodyDef.position.Set(34, 0);
			boxDef = new b2PolygonDef();
			ground_width = 0.5;
			ground_height = 25.5;
			boxDef.SetAsBox(ground_width, ground_height);
			boxDef.friction = 0;
			boxDef.density = 0;
			bodyDef.userData = new floor();
			bodyDef.userData.width = ground_width * 2 * pixels_in_a_meter;
			bodyDef.userData.height = ground_height * 2 * pixels_in_a_meter;
			addChild(bodyDef.userData);
			body = m_world.CreateBody(bodyDef);
			body.CreateShape(boxDef);
			
			body.SetMassFromShapes();
			
			/*for (var i:int = 1; i <=3; i++) {
				bodyDef = new b2BodyDef();
				bodyDef.position.x = Math.random() * 15;
				bodyDef.position.y = 8;
				var crate_width:Number = 1.5;
				var crate_height:Number = 1.5;
				var circleDef = new b2CircleDef();
				circleDef.radius = 1.5;
				circleDef.density = .50;
				circleDef.friction = 0.1;
				circleDef.restitution = .85;
				bodyDef.userData = new crate();
				bodyDef.userData.width = crate_width * 2 * pixels_in_a_meter;
				bodyDef.userData.height = crate_height * 2* pixels_in_a_meter;
				body = m_world.CreateBody(bodyDef);
				body.CreateShape(circleDef);
				body.SetMassFromShapes();
				addChild(bodyDef.userData);
			}*/
			
		}
		public function Update(e:Event):void {
			m_world.Step(m_timeStep, m_iterations);
			//trace(blobs[0].mouseJoint)
			for(var step:Number = 0; step < blobs.length; ++step){
			//trace(blobs[step].id)
				
				if (blobs[step].mouseJoint) {
					//trace(blobs[0].e.stageX)
					var mouseXWorldPhys = blobs[step].e.stageX/pixels_in_a_meter;
					var mouseYWorldPhys = blobs[step].e.stageY/pixels_in_a_meter;
					//trace(step +" : "+blobs[step].e.stageX +" : "+blobs[step].e.stageY)
					var p2:b2Vec2 = new b2Vec2(mouseXWorldPhys, mouseYWorldPhys);
					blobs[step].mouseJoint.SetTarget(p2);
				}
			}
			for (var bb:b2Body = m_world.m_bodyList; bb; bb = bb.m_next) {
				if (bb.m_userData is Sprite) {
					bb.m_userData.x = bb.GetPosition().x * pixels_in_a_meter;
					bb.m_userData.y = bb.GetPosition().y * pixels_in_a_meter;
					bb.m_userData.rotation = bb.GetAngle() * (180/Math.PI);
				}
			}
		}
        public function touchUp(e:TouchEvent):void{        
			removeBlob(e.ID);
		}
		public function on_mouse_down(evt:TouchEvent):void {
			//trace(evt.stageX)
			//trace("Do Something Please: "+evt.ID)
			//DoubleTap Gesture
			
				
			
			var body:b2Body = GetBodyAtMouse(evt);
			if (body) { //drags whatever is clicked on
				//trace("click on object -- create Mouse Joint "+body)
				addBlobWithJoint(evt.ID, evt, body);
				evt.target.addEventListener(TouchEvent.MOUSE_UP, touchUp);
				evt.target.addEventListener(TouchEvent.DOUBLE_CLICK, touchUp);
				//trace(blobs)
				//createMouseJoint(evt.ID, evt, body);
				/*var mouse_joint:b2MouseJointDef = new b2MouseJointDef;
				mouse_joint.body1 = m_world.GetGroundBody();
				mouse_joint.body2 = body;
				mouse_joint.target.Set(evt.stageX/pixels_in_a_meter, evt.stageY/pixels_in_a_meter);
				mouse_joint.maxForce = 10000;
				mouse_joint.timeStep = m_timeStep;
				mouseJoint = m_world.CreateJoint(mouse_joint) as b2MouseJoint;*/
			}
			else { // else makes a new disk
				addBlob(evt.ID, evt);
				evt.target.addEventListener(TouchEvent.MOUSE_UP, touchUp);
				evt.target.addEventListener(TouchEvent.DOUBLE_CLICK, on_doubleClick);
				//trace(blobs)
				var bodyDef:b2BodyDef;
				var boxDef:b2PolygonDef;
				bodyDef = new b2BodyDef();
				bodyDef.position.x = evt.stageX/pixels_in_a_meter;
				bodyDef.position.y = evt.stageY/pixels_in_a_meter;
				var crate_width:Number = 1.5;
				var crate_height:Number = 1.5;
				var circleDef = new b2CircleDef();
				circleDef.radius = 1.5;
				circleDef.density = .50;
				circleDef.friction = 0.1;
				circleDef.restitution = .85;
				bodyDef.userData = new crate();
				bodyDef.userData.width = crate_width * 2 * pixels_in_a_meter;
				bodyDef.userData.height = crate_height * 2* pixels_in_a_meter;
				body = m_world.CreateBody(bodyDef);
				body.CreateShape(circleDef);
				body.SetMassFromShapes();
				addChild(bodyDef.userData);
				
			}
			
			var tuioobj:TUIOObject = TUIO.getObjectById(evt.ID);
			var localPt:Point = globalToLocal(new Point(tuioobj.x, tuioobj.y));
			
			xdist = localPt.x - oldX;
			ydist = localPt.y - oldY;			
			distance = Math.sqrt(xdist*xdist+ydist*ydist);
			oldX = localPt.x;
			oldY = localPt.y;		
			
			//trace(distance);
			if (parent.hitTestPoint(localPt.x,localPt.y) && distance <= clickRadius) {

				if (lastClick == 0) {
					lastClick = getTimer();
				} else {
					lastClick = 0;
					on_doubleClick(body);
					//doubleTap();//perform doubleTap Function
				}
			}//end DoubleTap
			
			if(TUIO.OBJECT_ARRAY.length != blobs.length) { //TEST total number of existing blobs compared to entire array (check for missed removed blobs)
				removeBlob(blobs[0].id) //remove blob in spot 0, mostly likely missed remove blob value
			}
			
		}
		
		public function createMouseJoint(ID, evt, body):void {
			//trace("Making Link")
			var mouse_joint:b2MouseJointDef = new b2MouseJointDef;
			mouse_joint.body1 = m_world.GetGroundBody();
			mouse_joint.body2 = body;
			mouse_joint.target.Set(evt.stageX/pixels_in_a_meter, evt.stageY/pixels_in_a_meter);
			mouse_joint.maxForce = 10000;
			mouse_joint.timeStep = m_timeStep;
			//mouse_joint.touchPoint = evt;
			mouseJoint = m_world.CreateJoint(mouse_joint) as b2MouseJoint;
			//mouseJointArray.push(mouseJoint)
		}
		
		public function on_mouse_up(evt:TouchEvent):void {
			/*if (mouseJoint) {
				m_world.DestroyJoint(mouseJoint);
				mouseJoint = null;
			}*/
		}
		public function on_doubleClick(body):void {
			trace("Remove Disk: "+body);
			
		}
		public function GetBodyAtMouse(evt, includeStatic:Boolean=false):b2Body {
			//trace(evt)
			real_x_mouse = (evt.stageX)/pixels_in_a_meter;
			real_y_mouse = (evt.stageY)/pixels_in_a_meter;
			mousePVec.Set(real_x_mouse, real_y_mouse);
			var aabb:b2AABB = new b2AABB();
			aabb.lowerBound.Set(real_x_mouse - 0.001, real_y_mouse - 0.001);
			aabb.upperBound.Set(real_x_mouse + 0.001, real_y_mouse + 0.001);
			var k_maxCount:int = 10;
			var shapes:Array = new Array();
			var count:int = m_world.Query(aabb, shapes, k_maxCount);
			var body:b2Body = null;
			for (var i:int = 0; i < count; ++i) {
				if (shapes[i].m_body.IsStatic() == false || includeStatic) {
					var tShape:b2Shape = shapes[i] as b2Shape;
					var inside:Boolean = tShape.TestPoint(tShape.m_body.GetXForm(), mousePVec);
					if (inside) {
						body = tShape.m_body;
						break;
					}
				}
			}
			return body;
		}
		
		function addBlobWithJoint(id:Number, e, body) {
			//trace("Add Blob: "+id)
			var mouse_joint:b2MouseJointDef = new b2MouseJointDef;
			mouse_joint.body1 = m_world.GetGroundBody();
			mouse_joint.body2 = body;
			mouse_joint.target.Set(e.stageX/pixels_in_a_meter, e.stageY/pixels_in_a_meter);
			mouse_joint.maxForce = 10000;
			mouse_joint.timeStep = m_timeStep;
			mouseJoint = m_world.CreateJoint(mouse_joint) as b2MouseJoint;
			blobs.push( {id: id, e: e, mouseJoint:mouseJoint} );
			for (var i=0; i<blobs.length; i++) {
				if (blobs[i].id == id) {
					return;
				}
			}
			//trace("After Add Blob: "+blobs)
		}
		function addBlob(id:Number, e) {
			//trace("Add Blob: "+id)
			blobs.push( {id: id, e: e} );
			for (var i=0; i<blobs.length; i++) {
				if (blobs[i].id == id) {
					return;
				}
			}
			//trace("After Add Blob: "+blobs)
		}

		function removeBlob(id:Number) {
			//trace("Remove Blob: "+id)
			for (var i=0; i<blobs.length; i++) {
				if (blobs[i].id == id) {
					if (blobs[i].mouseJoint) {
						m_world.DestroyJoint(blobs[i].mouseJoint);
						blobs[i].mouseJoint = null;
					}
					blobs.splice(i, 1);
					return;
				}
			}
		}
		function moveUpdate(e:TouchEvent):void{
			for (var i=0; i<blobs.length; i++) {
				if(blobs[i].e.ID == e.ID){
					blobs[i].e.stageX = e.stageX;
					blobs[i].e.stageY = e.stageY;
				}
			}
			//my_line.graphics.clear(); // Clears lines for animation purposes
		}
	}
}

