package app.core.loader{

	import app.core.object.ImageObject;
	import app.core.object.VideoObject;
	import app.core.object.SlideShowObject;
	import flash.display.*;
	import flash.events.*;
	import flash.net.*;
	import caurina.transitions.Tweener;
	import app.core.action.RotatableScalable;
	//import flash.util.trace;
	import app.cyancdesign.MainNav;
	import app.cyancdesign.MainButton;
	import app.cyancdesign.MainButtonEvent;
	import app.cyancdesign.ResetSwitch;

	public class Local extends Sprite {
		// Class properties
		private var thestage:Sprite;
		private var allPics:Array;
		private var _thisScaleDown:Boolean;
		private var filePath="";
		// Misc.
		private var LIcontainer:String;// Images
		private var LVcontainer:String;// Videos
		var loadedElements:int=0;
		var numberOfElements:int=0;
		var organizeButton:MainButton;
		var maximizeButton:MainButton;
		public function Local(d:Sprite,thisScaleDown:Boolean,path:String) {
			thestage=d;
			_thisScaleDown=thisScaleDown;
			filePath=path;
			allPics = new Array();
			clearPics();
			trace("PHTOOOS");
			// Load images

			LocalImageLoader();
			// Load videos
			LocalVideoLoader();

			LocalSlideLoader();

			trace("Add buttons");

			organizeButton = new MainButton();
			organizeButton.btnText.text="Organize";
			
			organizeButton.x = -100;
			organizeButton.y=-100;
			organizeButton.addEventListener(MainButtonEvent.LONG_CLICK, organizeAll);
			organizeButton.addEventListener(TouchEvent.MOUSE_DOWN, buttonDown);
			organizeButton.addEventListener(TouchEvent.MOUSE_OVER, buttonDown);

			organizeButton.addEventListener(TouchEvent.MOUSE_OUT, buttonUp);
			organizeButton.addEventListener(TouchEvent.MOUSE_UP, buttonUp);
			thestage.parent.parent..addChild(organizeButton);
			organizeButton.fitContent();


		}
		public function someParentIs(ob:Object):MainButton {
			if (ob==this) {
				return null;
			} else if (ob is MainButton) {
				return (ob as MainButton);
			} else {
				return someParentIs(ob.parent);
			}
		}
		public function buttonDown(e:TouchEvent) {
			var button=someParentIs(e.target.parent);
			if (button!=null) {


				button.startClick(e.target.name);

			}
		}


		public function buttonUp(e:TouchEvent) {
			var button=someParentIs(e.target.parent);
			if (button!=null) {


				button.stopClick(e.target.name);

			}

		}
		public function LocalSlideLoader() {
			trace("load slides");
			var request:URLRequest=new URLRequest(filePath+"presentations.xml");
			var variables = new URLLoader();
			variables.addEventListener(Event.COMPLETE, this.slideXmlLoaded, false, 0, true);
			try {
				variables.load(request);
			} catch (error:Error) {
				trace("Unable to load (images) file " + error);
			}
		}
		public function slideXmlLoaded(e:Event) {
			trace("xml loaded");


			try {
				var xml:XML=new XML(e.target.data);
				showPresentations(xml);

			} catch (e:TypeError) {
				//Could not convert the data, probably because
				//because is not formated correctly

				trace("!Could not parse the XML");
				trace(e.message);
			}


		}
		public function showPresentations(xml:XML) {
			trace("show pres");
			var count:int=0;
			for each (var slideshow:XML in xml.presentations.slideshow) {
				count++;

				var urls:Array = new Array();

				for each (var s:XML in slideshow.slide) {
					numberOfElements++;
					urls.push(filePath+""+s);
				}

				var presentation:SlideShowObject=new SlideShowObject(urls,slideshow.name,false,false,false,_thisScaleDown);

				




				presentation.addEventListener("loadCompleted",photoLoaded);

			}

		}
		public function LocalImageLoader() {

			var request:URLRequest=new URLRequest(filePath+"images.xml");

			var variables:URLLoader = new URLLoader();
			variables.dataFormat=URLLoaderDataFormat.TEXT;
			variables.addEventListener(Event.COMPLETE, LIcompleteHandler, false, 0, true);
			try {
				variables.load(request);
			} catch (error:Error) {
				trace("Unable to load (images) file " + error);
			}
		}

		private function LIcompleteHandler(event:Event):void {
			var loader:URLLoader=URLLoader(event.target);
			LIcontainer=loader.data;
			showPics();// Show pics when done loading textfile
		}

		public function showPics() {
			trace("show pics");
			var myArray:Array = new Array();
			myArray=LIcontainer.split("\r\n");
			for (var i:int=0; i<myArray.length; i++) {
				numberOfElements++;
				myArray[i]=filePath+""+myArray[i];
			}

			for (i=0; i < myArray.length-1; i++) {
				var photo:ImageObject=new ImageObject(myArray[i],false,false,false,_thisScaleDown);



				photo.addEventListener("loadCompleted",photoLoaded);


			}

		}
		public function photoLoaded(e:Event) {
			var photo = (e.target as RotatableScalable);
			
			photo.scaleX=0;
			photo.scaleY=0;
			photo.x=thestage.stage.stageWidth/2;
			photo.y=thestage.stage.stageHeight/2;
			thestage.addChild(photo);
			allPics.push(photo);
			organizeAll();

		}
		public function LocalVideoLoader() {
			var request:URLRequest=new URLRequest(filePath+"videos.xml");
			var variables:URLLoader = new URLLoader();
			variables.dataFormat=URLLoaderDataFormat.TEXT;
			variables.addEventListener(Event.COMPLETE, LVcompleteHandler);
			try {
				variables.load(request);
			} catch (error:Error) {
				trace("Unable to load (videos) file " + error);
			}
		}

		private function LVcompleteHandler(event:Event):void {
			var loader:URLLoader=URLLoader(event.target);
			LVcontainer=loader.data;
			showVids();// Show videos when done loading textfile
		}

		public function showVids() {
			trace("show vids");
			var myArray:Array = new Array();
			myArray=LVcontainer.split("\r\n");



			for (var i:int=0; i<myArray.length; i++) {
				numberOfElements++;
				myArray[i]=filePath+""+myArray[i];
				//myArray[i] = "http://cache.googlevideo.com/get_video?video_id=0awjPUkBXOU&amp&origin=youtube.com";
			}

			for (i=0; i < myArray.length-1; i++) {
				trace('Trying to load :'+(myArray[i]));
				var flv_video:VideoObject=new VideoObject(myArray[i]);

				
			flv_video.scaleX=0;
			flv_video.scaleY=0;
			flv_video.x=thestage.stage.stageWidth/2;
			flv_video.y=thestage.stage.stageHeight/2;
			thestage.addChild(flv_video);
			allPics.push(flv_video);
			organizeAll();

			}

		}

		public function clearPics() {
			for (var i:int = 0; i<allPics.length; i++) {
				allPics[i].removeEventListener(TouchEvent.DOUBLE_CLICK, doubleClick);
				thestage.removeChild(allPics[i]);
			}

			allPics = new Array();
		}
		public function doubleClick(e:TouchEvent) {
			trace("double click");

			var pic:RotatableScalable=e.target;

			//Hvis den allerede er sådan at den bliver vist.. så gør den mindre og smid den i midten/kør organize all
			var nx=thestage.stage.stageWidth/2;
			var ny=thestage.stage.stageHeight/2;

			var nrotation=0;
			var oldscale=pic.scaleX;
			var oldrot=pic.rotation;
			pic.scaleX=1;
			pic.scaleY=1;
			pic.rotation=0;
			var nscaleX=Math.min((thestage.stage.stageWidth*0.7)/pic.width,(thestage.stage.stageHeight*0.7)/pic.height);

			var nscaleY=nscaleX;
			pic.rotation=oldrot;
			pic.scaleX=oldscale;
			pic.scaleY=oldscale;
			if (pic.width>thestage.stage.stageWidth*0.7||pic.height>thestage.stage.stageHeight*0.7) {
				var oldscale2=pic.scaleX;

				pic.scaleX=1;
				pic.scaleY=1;

				var nscaleX2=Math.min(200/pic.width,200/pic.height);

				var nscaleY2=nscaleX2;
				pic.scaleX=oldscale2;
				pic.scaleY=oldscale2;
				Tweener.addTween(pic, {scaleX:nscaleX2,scaleY:nscaleY2, time:1, transition:"easeinoutquad"});
			} else {
				Tweener.addTween(pic, {x:nx,y:ny,scaleX:nscaleX,scaleY:nscaleY,rotation:nrotation, time:1, transition:"easeinoutquad"});
			}


		}
		public function organizeAll(e:Event = null) {

			if (e!=null) {
				e.target.removeEventListener("loadCompleted",organizeAll);
			}
			var picsPerRow:int=Math.floor(Math.sqrt(allPics.length)*(thestage.stage.stageWidth/thestage.stage.stageHeight));
			var picsPerCol:int=allPics.length/picsPerRow;

			var outerMargin=90;
			var margin=20;
			var picWidth:int=Math.min(thestage.stage.stageWidth*0.7,(thestage.stage.stageWidth-2*outerMargin)/picsPerRow-margin);
			var picHeight:int = Math.min(thestage.stage.stageHeight*0.7,(thestage.stage.stageHeight-2*outerMargin)/picsPerCol-margin);
			var count=0;


			for each (var o:RotatableScalable in allPics) {

				//o.addEventListener(TouchEvent.DOUBLE_CLICK, doubleClick);


				var oldscale=o.scaleX;

				o.scaleX=1;

				var nscaleX=Math.min(picWidth/o.width,picHeight/o.height);
				o.scaleX=oldscale;
				//o.scaleX=0;
				//o.scaleY=0;
				//o.x = thestage.stage.stageWidth/2;
				//o.y = thestage.stage.stageHeight/2;

				var nscaleY=nscaleX;

				var nx = outerMargin+picWidth/2+(count%picsPerRow)*(margin+picWidth);
				var ny = outerMargin+thestage.stage.stageHeight/2/picsPerCol+Math.floor(count/picsPerRow)*(margin+picWidth)-30;
				//trace("pos: "+nx+","+ny+" with width: "+o.width);
				var nrotation=0;



				Tweener.addTween(o, {x:nx,y:ny,scaleX:nscaleX,scaleY:nscaleY,rotation:nrotation, time:1, transition:"easeinoutquad"});
				count++;


			}
			organizeButton.y = thestage.stage.stageHeight-organizeButton.height/2;
			
			organizeButton.x = thestage.stage.stageWidth/2-organizeButton.width/2;
			try{
			thestage.removeChild(organizeButton);
			} catch(e:Error){}
			thestage.parent.parent.addChild(organizeButton);
	

		}

	}
}