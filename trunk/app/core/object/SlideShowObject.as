package app.core.object{

	import flash.events.*;
	import flash.system.LoaderContext;
	import flash.net.URLRequest;
	import flash.display.*;
	import app.core.element.*;
	import app.core.action.RotatableScalable;
	import caurina.transitions.Tweener;

	import app.core.loader.nLoader;
	//import app.core.object.TextObject;
	import app.core.action.Physical;

	public class SlideShowObject extends RotatableScalable {
		public var doubleTapEnabled:Boolean;

		public var swfboard:Loader;
		var currentSlideNumber:int=0;
		private var progressBar:Sprite = new Sprite();
		private var clickgrabber:Shape = new Shape();
		private var photoBack:Sprite = new Sprite();
		private var photoLoader:Loader=null;
		private var hasLoaded:Boolean=false;
		private var thisTween:Boolean;
		private var thisSlide:Boolean;
		private var _thisScaleDown:Boolean;

		private var velX:Number=0.0;
		private var velY:Number=0.0;

		private var velAng:Number=0.0;

		private var friction:Number=0.85;
		private var angFriction:Number=0.92;

		private var imageUrls:Array;
		private var border:Shape = new Shape();
		private var border_size:Number=50.0;
		private var next_btn:Sprite = new Sprite();
		private var prev_btn:Sprite = new Sprite();
		//private var TextObject_0:TextObject;
		private var slideName:String;

		public function SlideShowObject(urls:Array,slideName:String, mouseSelect:Boolean, thisTweenX:Boolean, thisSlideX:Boolean, thisScaleDown:Boolean) {
			_thisScaleDown=thisScaleDown;
			mouseSelection=mouseSelect;
			thisTween=thisTweenX;
			thisSlide=thisSlideX;
			this.slideName=slideName;
			scaleBehavior="Discrete";
			this.alpha=0;
			imageUrls=urls;
			doubleTapEnabled=false;
			photoLoader = new Loader();

			photoLoader.contentLoaderInfo.addEventListener( ProgressEvent.PROGRESS, onProgressHandler);
			photoLoader.contentLoaderInfo.addEventListener( Event.COMPLETE, arrange, false, 0, true);
			photoLoader.contentLoaderInfo.addEventListener( IOErrorEvent.IO_ERROR, onIOError);


			progressBar.graphics.beginFill(0xFFFFFF,1);
			progressBar.graphics.drawRect(0, 0, 25, 100);
			progressBar.graphics.endFill();

			photoBack.graphics.beginFill(0x000000,0.75);
			photoBack.graphics.drawRect(0, 0, 1,1);
			photoBack.graphics.endFill();
			//photoBack.blendMode = 'invert';
			clickgrabber.graphics.beginFill(0xFFFFFF, 1);
			clickgrabber.graphics.drawRect(0, 0, 1,1);
			clickgrabber.graphics.endFill();

			trace("slide show object");



			//this.addChild( photoLoader );
			this.addChild( clickgrabber );
			this.addChild( photoBack );
			//this.addChild( progressBar );

			//TextObject_0 = new TextObject(url);
			//TextObject_0.noMove=true;
			//TextObject_0.visible=false;
			//this.addChild(TextObject_0);
			if (thisSlide) {
				//this.addEventListener(Event.ENTER_FRAME, slide);
			}
			loadSlide(currentSlideNumber);

		}
		private function loadSlide(number:int) {
			currentSlideNumber=number;
			var context:LoaderContext = new LoaderContext();
			context.checkPolicyFile=true;
			var request:URLRequest=new URLRequest(imageUrls[number]);
			if (photoLoader.content!=null) {
				photoLoader.content.alpha=0;
			}

			photoLoader.unload();
			photoLoader.load( request , context);
		}
		private function onProgressHandler(mProgress:ProgressEvent) {
			var percent:Number = -100*(mProgress.target.bytesLoaded/mProgress.target.bytesTotal);
			//progressBar.alpha=percent;
			///trace(percent);
		}

		public function nextBtnToucn(e:Event) {
			if (currentSlideNumber+1<imageUrls.length) {
				loadSlide(currentSlideNumber+1);
			}
		}

		public function prevBtnToucn(e:Event) {
			if (currentSlideNumber>0) {
				loadSlide(currentSlideNumber-1);
			}
		}
		private function arrange( event:Event = null ):void {
			var image:Bitmap=Bitmap(photoLoader.content);
			image.smoothing=true;

			image.x=- image.width/2;
			image.y=- image.height/2;

			if (! hasLoaded) {
				firstarrange(image);
				hasLoaded=true;
			}
			this.addChild(image);
			Tweener.addTween(border, {x: image.x-border_size, y: image.y-border_size,width:image.width+(border_size * 2),height:image.height+(border_size * 2)+200, time:0.5, transition:"easeinoutquad"});
		}
		private function firstarrange( image:Bitmap = null ):void {




			Tweener.addTween(clickgrabber, {alpha:0, time:1, transition:"easeinoutquad"});
			//removeChild(progressBar);
			//this.x = 0;
			//this.y = 0;
			//this.scaleX = 0;
			//this.scaleY =0;
			this.alpha=1;
			//this.rotation =  Math.random()*180 - 90;
			//photoLoader.scaleX = 0.01;
			//photoLoader.scaleY = 0.01;
			clickgrabber.scaleX=photoLoader.width;
			clickgrabber.scaleY=photoLoader.height;
			clickgrabber.x=- photoLoader.width/2;
			clickgrabber.y=- photoLoader.height/2;

			photoBack.scaleX=photoLoader.width;
			photoBack.scaleY=photoLoader.height;
			photoBack.x=- photoLoader.width/2;
			photoBack.y=- photoLoader.height/2;
			photoBack.alpha=0.0;




			//TextObject_0.visible=true;
			//TextObject_0.scaleX = 0.20;
			//TextObject_0.scaleY = 0.20;
			//TextObject_0.x=0;
			//TextObject_0.y=photoLoader.height/2+15; 
			if (thisTween) {
				var targetX:int=this.x;
				var targetY:int=this.y;
				var targetRotation:int=Math.random()*180-90;
				var targetScale:Number = (Math.random()*0.4) + 0.4;
				Tweener.addTween(this, {x:targetX, y:targetY,scaleX: targetScale, scaleY: targetScale, delay:0,time:1, transition:"easeinoutquad"});
			} else {
				//random
				//this.scaleX = (Math.random()*0.4) + 0.3;
				//this.scaleY = this.scaleX;
				//this.rotation = Math.random()*180 - 90;
				//this.x = 700 * Math.random() - 350;
				//this.y = 700 * Math.random() - 350;
				this.alpha=1.0;

				//static
				//this.scaleX = 0.5;
				//this.scaleY = 0.5;
				//this.rotation = 0;
				//this.x = 0;
				//this.y = 0;
			}



			border.graphics.beginFill(0xffffff, 0.20);
			border.graphics.lineStyle(1,0xffffff, 0.35);
			border.graphics.drawRect(0, 0, image.width+(border_size * 2), image.height+(border_size * 2)+200);
			border.graphics.endFill();

			
			border.x=image.x-border_size;
			border.y=image.y-border_size;
			addChild(border);

			var wrapper0:Wrapper=new Wrapper(next_btn);
			var wrapper1:Wrapper=new Wrapper(prev_btn);
			wrapper1.addEventListener(MouseEvent.CLICK, nextBtnToucn);
			wrapper0.addEventListener(MouseEvent.CLICK, prevBtnToucn);


			//Tweener.addTween(next_btn, {x:0,y:image.y+image.height+border_size/2});
			//Tweener.addTween(next_btn, {x:0,y:image.y+image.height+border_size/2});
			var startx=0;
			var starty=image.y+image.height+border_size/2;
			next_btn.graphics.lineStyle(0, 0x202020);
			next_btn.graphics.lineStyle(0, 0xabcabc,0.0);
			next_btn.graphics.drawRect(-200, starty, 200, 200);
			next_btn.graphics.endFill();
			next_btn.graphics.lineStyle(0, 0x202020);
			next_btn.graphics.beginFill(0xffffff, 0.7);

			//TODO: add scale
			var scale=5;
			next_btn.graphics.moveTo(startx-8*scale, starty+1*scale);
			next_btn.graphics.lineTo(startx-8*scale, starty+1*scale);
			next_btn.graphics.lineTo(startx-28*scale, starty+11*scale);
			next_btn.graphics.lineTo(startx-8*scale, starty+21*scale);
			next_btn.graphics.lineTo(startx-8*scale, starty+1*scale);
			next_btn.graphics.endFill();


			startx=0;
			starty=image.y+image.height+border_size/2;
			prev_btn.graphics.lineStyle(0, 0xabcabc,0.0);
			prev_btn.graphics.beginFill(0x00CC00, 0);
			prev_btn.graphics.drawRect(startx,starty, 200, 200);
			prev_btn.graphics.endFill();
			prev_btn.graphics.lineStyle(0, 0x202020);
			prev_btn.graphics.beginFill(0xffffff, 0.7);


			//TODO: add scale
			//prev_Btn.rotation = Math.PI;
			scale=5;
			prev_btn.graphics.moveTo(startx+8*scale, starty+1*scale);
			prev_btn.graphics.lineTo(startx+8*scale, starty+1*scale);
			prev_btn.graphics.lineTo(startx+28*scale, starty+11*scale);
			prev_btn.graphics.lineTo(startx+8*scale, starty+21*scale);
			prev_btn.graphics.lineTo(startx+8*scale, starty+1*scale);
			prev_btn.graphics.endFill();

			trace(next_btn.x);
			trace(image.x);
			trace(this.x);
			addChild(wrapper0);
			addChild(wrapper1);

			if (_thisScaleDown) {
				this.x=0;
				this.y=0;
				this.scaleX=0.1;
				this.scaleY=0.1;
			}
			dispatchEvent(new Event("loadCompleted"));
			/*
			nLoad_0 = new Loader();
			nLoad_0.load(new URLRequest("www/swf/stack.swf"));
			//var nLoad_0 = new nLoader("www/swf/stack.swf",0,0);
			 nLoad_0.contentLoaderInfo.addEventListener( Event.COMPLETE, swfLoaded );
			//nLoad_0.x=-250;
			//nLoad_0.y=-190;
			
			nLoad_0.x=clickgrabber.width*0.5-49;
			nLoad_0.y=-clickgrabber.height*0.5-2;
			this.addChild(nLoad_0);      
			//this.addEventListener(MouseEvent.CLICK, MouseDownKey);
			*/
		}

		public function swfLoaded(e:Event) {
			//trace('Sub-Menu Object Created');
			//var mc:MovieClip = nLoad_0.content;
			//mc['stack1'].addEventListener(MouseEvent.CLICK, MouseDownKey);
		}

		public function MouseDownKey(e:Event) {
			trace('target parent :'+e.target.parent.parent.parent.parent.parent.name);
			trace('target :'+e.target.name);
			trace('parent :'+parent);
			trace('parent parent :'+parent.parent);
			trace('root :'+root);
			trace('this :'+this);
			//e.target.parent.parent.parent.parent.parent=null;
			//trace(parent.getChildByName('TextObject_0'));
			//parent.parent.photos.removeChild(getChildByName('ImageObject_0'));
		}

		/*
		public override function released(dx:Number, dy:Number, dang:Number)
		{
		velX = dx;
		velY = dy;
		velAng = dang;
		}
		*/
		function onIOError(e:Event) {
			trace(e);
		}

/*
		public override function doubleTap(e:TouchEvent = null) {
			trace("double tap2");
			dispatchEvent(new TouchEvent(TouchEvent.DOUBLE_CLICK));
		}*/
		/*
		   if(!doubleTapEnabled){
		//Tweener.addTween(this, {scaleX: 1, scaleY: 1,x:0, y:0,rotation: 0, time:0.30, transition:"easeinoutquad"});
		Tweener.addTween(this, { scaleX: 1, scaleY: 1, time:0.45, transition:"easeinoutquad"});
		   Tweener.addTween(photoBack, {alpha:0.0, delay: 0.05, time:0.25,  transition:"easeinoutquad"});
		   doubleTapEnabled = true;
		   }
		   else{
		   //Tweener.addTween(this, {scaleX: 1.0, scaleY: 0,x:this.x+200, y:this.y+200, rotation: Math.random()*180 - 90,  time:0.35,  transition:"easeinoutquad"});
		    
		     Tweener.addTween(this, {scaleX: -1.0, scaleY: 1.0,  delay: 0.0, time:0.45,  transition:"easeinoutquad"});
		      Tweener.addTween(photoBack, {alpha:1.0, delay: 0.05, time:0.25,  transition:"easeinoutquad"});
		     doubleTapEnabled = false;   
		     //Tweener.addTween(this, {scaleX: 1.0, scaleY: 1.0,  time:0.35,  transition:"easeinoutquad"}); 
		    }
		   }*/
		/*
		private function slide(e:Event):void
		{
		if(this.state == "none")
		{
		if(Math.abs(velX) < 0.001)
		velX = 0;
		else {
		x += velX;
		velX *= friction;
		}
		if(Math.abs(velY) < 0.001)
		velY = 0;
		else {
		y += velY;
		velY *= friction;
		}
		if(Math.abs(velAng) < 0.001)
		velAng = 0;
		else {
		velAng *= angFriction;
		this.rotation += velAng;
		}
		}
		}
		*/


	}
}