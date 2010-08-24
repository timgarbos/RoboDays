package app.core.action{
	import flash.events.*;

	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.DropShadowFilter;
	import flash.geom.Point;
	import flash.utils.getTimer;
	
	public dynamic class RotatableScalableFixed extends Sprite
	{
		private var minX = 0;
		private var maxX = 1024;
		private var minY = 0;
		private var maxY = 768;
		private var minScale = 0.05;
		private var maxScale = 1;
		
		public var blobs:Array;		// blobs we are currently interacting with
		private var GRAD_PI:Number = 180.0 / 3.14159;
		public var state:String;
		private var curScale:Number;
		private var curAngle:Number;
		private var curPosition:Point = new Point(0,0);

		private var basePos1:Point = new Point(0,0);		
		private var basePos2:Point = new Point(0,0);				
		
		public var blob1:Object;
		public var blob2:Object;		
		public var bringToFront:Boolean = true;
		public var noScale = false;
		public var noRotate = false;		
		public var noMove = false;
		
		public var dX:Number;
		public var dY:Number;		
		public var dAng:Number;
		public var dcoef:Number = 0.9;
		
		//DoubleTap variables
		public var xdist:Number;
		public var ydist:Number;
		public var distance:Number;
		private var oldX:Number = 0;
		private var oldY:Number = 0;		
		public var doubleclickDuration:Number = 500;
		public var clickRadius:Number = 50;		
		public var lastClick:Number = 0;
		
		private var _rp:Point = new Point(0,0);
		
		// Physics
		private var zenosCoeff:Number;
		private var auxRotation:Number;
		private var prevDAngle:Number;
		private var rotCW:Boolean;
		private var firstRotComp:Boolean;
		
		public function RotatableScalableFixed()
		{
			state = "none";

			blobs = new Array();
			this.addEventListener(TouchEvent.MOUSE_MOVE, this.moveHandler, false, 0, true);
			this.addEventListener(TouchEvent.MOUSE_DOWN, this.downEvent, false, 0, true);
			this.addEventListener(TouchEvent.MOUSE_UP, this.upEvent, false, 0, true);
			this.addEventListener(TouchEvent.MOUSE_OVER, this.rollOverHandler, false, 0, true);
			this.addEventListener(TouchEvent.MOUSE_OUT, this.rollOutHandler, false, 0, true);
		
			this.addEventListener(MouseEvent.MOUSE_MOVE, this.mouseMoveHandler);
			this.addEventListener(MouseEvent.MOUSE_DOWN, this.mouseDownEvent);
			this.addEventListener(MouseEvent.MOUSE_UP, this.mouseUpEvent);
			this.addEventListener(MouseEvent.MOUSE_OUT, this.mouseUpEvent);
			
			this.addEventListener(MouseEvent.DOUBLE_CLICK, this.doubleTap);
			
			this.addEventListener(Event.ENTER_FRAME, this.update, false, 0, true);
			
			dX = 0;
			dY = 0;
			dAng = 0;
			
			zenosCoeff = 2;
			auxRotation = rotation;
			prevDAngle = 0;
			firstRotComp = true;
		}
		
		public function setRegistration(x:Number=0, y:Number=0):void{
			_rp = new Point(x, y);
		}
		
		public function setProperty2(prop:String, n:Number):void{
			var a:Point = new Point();
			var b:Point = new Point();
			if(this.parent != null){
				a = this.parent.globalToLocal(this.localToGlobal(_rp));
				this[prop] = n;
				b = this.parent.globalToLocal(this.localToGlobal(_rp));
			}else{
				a = this.localToGlobal(_rp);
				this[prop] = n;
				b = this.localToGlobal(_rp);
			}
			this.x -= b.x - a.x;
			this.y -= b.y - a.y;
		}
		
		public function get x2():Number{
			var p:Point = this.parent.globalToLocal(this.localToGlobal(_rp));
			return p.x;
		}

		public function set x2(value:Number):void{
			var p:Point = this.parent.globalToLocal(this.localToGlobal(_rp));
			this.x += value - p.x;
		}

		public function get y2():Number{
			var p:Point = this.parent.globalToLocal(this.localToGlobal(_rp));
			return p.y;
		}

		public function set y2(value:Number):void{
			var p:Point = this.parent.globalToLocal(this.localToGlobal(_rp));
			this.y += value - p.y;
		}
		
		function addBlob(id:Number, origX:Number, origY:Number):void
		{
			for(var i=0; i<blobs.length; i++)
			{
				if(blobs[i].id == id)
					return;
			}
			
			blobs.push( {id: id, origX: origX, origY: origY, myOrigX: x, myOrigY:y} );
			
			if(blobs.length == 1)
			{				
				state = "dragging";
				curScale = this.scaleX;
				curAngle = this.rotation;					
				curPosition.x = x;
				curPosition.y = y;				
				blob1 = blobs[0];
			}
			else if(blobs.length >= 2)
			{
				state = "rotatescale";
				curScale = this.scaleX;
				curAngle = this.rotation;					
				curPosition.x = x;
				curPosition.y = y;		
				
				blob1 = blobs[0];								
				blob2 = blobs[1];		
				
				var tuioobj1 = TUIO.getObjectById(blob1.id);
				var tuioobj2 = TUIO.getObjectById(blob2.id);
				
				var midPoint:Point = Point.interpolate(this.globalToLocal(new Point(tuioobj1.x, tuioobj1.y)),this.globalToLocal(new Point(tuioobj2.x, tuioobj2.y)),0.5);
				
				setRegistration(midPoint.x,midPoint.y);
				
				// if not found, then it must have died..
				if(tuioobj1)
				{
					var curPt1:Point = parent.globalToLocal(new Point(tuioobj1.x, tuioobj1.y));									
					
					blob1.origX = curPt1.x;
					blob1.origY = curPt1.y;
				}
				// if not found, then it must have died..
				if(tuioobj2)
				{
					var curPt2:Point = parent.globalToLocal(new Point(tuioobj2.x, tuioobj2.y));									
					
					blob2.origX = curPt2.x;
					blob2.origY = curPt2.y;
				}
			}
		}
		
		function removeBlob(id:Number):void
		{
			for(var i=0; i<blobs.length; i++)
			{
				if(blobs[i].id == id) 
				{
					if (i < 2 && blobs.length > 2) {
						
						var tuioobjReset:TUIOObject = TUIO.getObjectById(blobs[2].id);
						if(tuioobjReset) {						
							curPtReset = parent.globalToLocal(new Point(tuioobjReset.x, tuioobjReset.y));
							blobs[2].origX = curPtReset.x;
							blobs[2].origY = curPtReset.y;
						}
					}
					blobs.splice(i, 1);
					
					var curPt1:Point;
					if(blobs.length == 0)
						state = "none";
					if(blobs.length == 1) 
					{
						state = "dragging";					
	
						curScale = this.scaleX;
						curAngle = this.rotation;					
						curPosition.x = x;
						curPosition.y = y;					
						
						blob1 = blobs[0];		
						
						var tuioobj1:TUIOObject = TUIO.getObjectById(blob1.id);
						
						// if not found, then it must have died..
						if(tuioobj1)
						{						
							curPt1 = parent.globalToLocal(new Point(tuioobj1.x, tuioobj1.y));
							
							blob1.origX = curPt1.x;
							blob1.origY = curPt1.y;
						}
						
					}
					if(blobs.length >= 2) {
						state = "rotatescale";
						
						curScale = this.scaleX;
						curAngle = this.rotation;					
						curPosition.x = x;
						curPosition.y = y;				
						
						blob1 = blobs[0];								
						blob2 = blobs[1];		
						
						var tuioobj1 = TUIO.getObjectById(blob1.id);
						var tuioobj2 = TUIO.getObjectById(blob2.id);
						
						var midPoint:Point = Point.interpolate(this.globalToLocal(new Point(tuioobj1.x, tuioobj1.y)),this.globalToLocal(new Point(tuioobj2.x, tuioobj2.y)),0.5);
						setRegistration(midPoint.x,midPoint.y);
						
						// if not found, then it must have died..
						if(tuioobj1)
						{
							curPt1 = parent.globalToLocal(new Point(tuioobj1.x, tuioobj1.y));						
							blob1.origX = curPt1.x;
							blob1.origY = curPt1.y;
						}
						// if not found, then it must have died..
						if(tuioobj2)
						{
							var curPt2:Point = parent.globalToLocal(new Point(tuioobj2.x, tuioobj2.y));									
							
							blob2.origX = curPt2.x;
							blob2.origY = curPt2.y;
						}
					}
					return;					
				}
			}			
		}
		
		public function downEvent(e:TouchEvent):void
		{		
			if(e.stageX == 0 && e.stageY == 0)
				return;			
			
			var curPt:Point = parent.globalToLocal(new Point(e.stageX, e.stageY));

			addBlob(e.ID, curPt.x, curPt.y);
			
			if(bringToFront) {
				this.parent.getChildAt(this.parent.numChildren-1).filters = null;
				this.parent.setChildIndex(this, this.parent.numChildren-1);
				var dropshadow:DropShadowFilter=new DropShadowFilter(0, 45, 0x000000, 0.5, 16, 16);
				this.filters=new Array(dropshadow);
				auxRotation = rotation;
				firstRotComp = true;
			}
			
			e.stopPropagation();
		}
		
		public function upEvent(e:TouchEvent):void {
			removeBlob(e.ID);
			e.stopPropagation();
		}		
		
		public function moveHandler(e:TouchEvent):void
		{
//			e.stopPropagation();			
		}
		
		public function rollOverHandler(e:TouchEvent):void
		{
//			e.stopPropagation();			
		}
		
		public function rollOutHandler(e:TouchEvent):void
		{
//			e.stopPropagation();	
		}
		
		public function mouseDownEvent(e:MouseEvent)
		{
			if(e.stageX == 0 && e.stageY == 0)
			return;			
			
			if(!noMove)
			{	
				this.startDrag();
			}
			
			if(bringToFront)
				this.parent.setChildIndex(this, this.parent.numChildren-1);
			
			e.stopPropagation();
		}
		
		public function mouseUpEvent(e:MouseEvent)
		{	
			if(!noMove)
			{
				this.stopDrag();	
			}
			e.stopPropagation();
		}		

		public function mouseMoveHandler(e:MouseEvent)
		{
		//
		}
		
		public function mouseRollOverHandler(e:MouseEvent)
		{
		//
		}
		
		public function mouseRollOutHandler(e:MouseEvent)
		{
			if(!noMove)
			{
			//this.stopDrag();	
			}		
			//e.stopPropagation();
		}	
		
		function getAngleTrig(X:Number, Y:Number): Number
		{
			if (X == 0.0)
			{
				if(Y < 0.0)
					return 270;
				else
					return 90;
			} else if (Y == 0)
			{
				if(X < 0)
					return 180;
				else
					return 0;
			}

			if ( Y > 0.0)
				if (X > 0.0)
					return Math.atan(Y/X) * GRAD_PI;
				else
					return 180.0-Math.atan(Y/-X) * GRAD_PI;
			else
				if (X > 0.0)
					return 360.0-Math.atan(-Y/X) * GRAD_PI;
				else
					return 180.0+Math.atan(-Y/-X) * GRAD_PI;
		} 		
		
		public function released(dx:Number, dy:Number, dang:Number) {
			
			var destX:Number = x + dx;
			var destY:Number = y + dy;
			
			if (destX < minX) { destX = 0; }
			if (destX > maxX) { destX = 1024; }
			if (destY < minY) { destY = 0; }
			if (destY > maxY) { destY = 768; }
		}

		
		public function doubleTap()
		{
		}		

		private function update(e:Event):void
		{
			var oldX:Number, oldY:Number;
			if(state == "dragging")
			{
				var tuioobj:TUIOObject = TUIO.getObjectById(blob1.id);
				
				// if not found, then it must have died..
				if(!tuioobj)
				{
					removeBlob(blob1.id);
					return;
				}
				
				var curPt:Point = parent.globalToLocal(new Point(tuioobj.x, tuioobj.y));

				oldX = x;
				oldY = y;
				
				if(!noMove)
				{
					var targetX:Number = curPosition.x + (curPt.x - (blob1.origX ));		
					var targetY:Number = curPosition.y + (curPt.y - (blob1.origY ));
					x += (targetX - x) / zenosCoeff;
					y += (targetY - y) / zenosCoeff;
				}
				
				dX *= dcoef;
				dY *= dcoef;						
				dAng *= dcoef;
				dX += x - oldX;
				dY += y - oldY;		
				
			} else if(state == "rotatescale")
			{
				var tuioobj1 = TUIO.getObjectById(blob1.id);
				
				// if not found, then it must have died..
				if(!tuioobj1)
				{
					removeBlob(blob1.id);
					return;
				}				
				
				var curPt1:Point = parent.globalToLocal(new Point(tuioobj1.x, tuioobj1.y));								
				
				var tuioobj2 = TUIO.getObjectById(blob2.id);
				
				// if not found, then it must have died..
				if(!tuioobj2)
				{
					removeBlob(blob2.id);
					return;
				}								
				
				var curPt2:Point = parent.globalToLocal(new Point(tuioobj2.x, tuioobj2.y));				
				var curCenter:Point = Point.interpolate(curPt1, curPt2, 0.5);				

				var origPt1:Point = new Point(blob1.origX, blob1.origY);
				var origPt2:Point = new Point(blob2.origX, blob2.origY);
				var centerOrig:Point = Point.interpolate(origPt1, origPt2, 0.5);
				
				var offs:Point = curCenter.subtract(centerOrig);
				
				var len1:Number = Point.distance(origPt1, origPt2);
				var len2:Number = Point.distance(curPt1, curPt2);					
				var len3:Number = Point.distance(origPt1, new Point(0,0));
				
				var targetScale:Number = curScale * len2 / len1;
				var newScale:Number = scaleX + (targetScale - scaleX)/zenosCoeff;	// scaleX = scaleY
				
				if(!noScale && newScale > minScale && newScale < maxScale)
				{
					setProperty2('scaleX', newScale);
					setProperty2('scaleY', newScale);
				}
	
				var origLine:Point = origPt1;
				origLine = origLine.subtract(origPt2);
				
				var ang1:Number = getAngleTrig(origLine.x, origLine.y);
				
				var curLine:Point = curPt1;
				curLine = curLine.subtract(curPt2);
				
				var ang2:int = getAngleTrig(curLine.x, curLine.y);
				var oldAngle:int = auxRotation;
				
				
				var dAngle:Number = ang2 - ang1;
				var targetAngle:Number = curAngle + dAngle;
				var newAngle:Number = auxRotation + (targetAngle - auxRotation)/zenosCoeff;
				
				if (dAngle < 0 && prevDAngle >= 0) {
					if (Math.abs(dAngle - prevDAngle) > 90) {
						newAngle = targetAngle;
						oldAngle = targetAngle;
					}
				} else if (dAngle >= 0 && prevDAngle < 0) {
					if (Math.abs(dAngle - prevDAngle) > 90) {
						newAngle = targetAngle;
						oldAngle = targetAngle;
					}
				}
				prevDAngle = dAngle;
				auxRotation = newAngle;
				
				if(!noRotate)	
				{
					setProperty2("rotation", newAngle);
				}

				oldX = x;
				oldY = y;
			
				if(!noMove)
				{
					x2 = curCenter.x;
					y2 = curCenter.y;
				}
				
				dX *= dcoef;
				dY *= dcoef;
				dAng *= dcoef;
				dX += x - oldX;
				dY += y - oldY;
				dAng += auxRotation - oldAngle;
				
			} else {
				if(dX != 0 || dY != 0)
				{
					this.released(dX, dY, dAng);
					dX = 0;
					dY = 0;
					dAng = 0;
				}
			}
		}
	}
}
