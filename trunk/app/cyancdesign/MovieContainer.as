package app.cyancdesign{

	import flash.events.*;
	import flash.display.*;

	import flash.net.*;
	import flash.events.TouchEvent;
	import app.cyancdesign.MainNav;
	import app.cyancdesign.MainButton;
	import app.cyancdesign.ResetSwitch;
	import fl.transitions.Tween;
	import fl.transitions.TweenEvent;
	import fl.transitions.easing.*;
	import com.exanimo.transitions.GCSafeTween;
	import app.demo.MyTouchApp.ShowFinger;
	import flash.system.fscommand;

	public class MovieContainer extends MovieClip {

		var xmlLoader:URLLoader;
		var appButtons = new Array();
		var parentAppButtons:Array = new Array();
		public var currentButton:MainButton;



		var resetSwitches:Array = new Array();


		var loaderAnim:MovieClip = new LoaderAnim();
		var movieMC:MovieClip = new MovieClip();
		var ldr:Loader = new Loader();
		var centerX=500;
		var centerY=400;




		public function MovieContainer():void {
			parent.stage.addEventListener("connected",connectedToTUIO);
			TUIO.init(this,'localhost',3000,'',false);

			(parent as ShowFinger).showCursor();

			movieMC.alpha=1;



			addNavElements();


			resetSwitches.push(new ExitButton());
			resetSwitches.push(new ExitButton());
			resetSwitches.push(new ExitButton());
			resetSwitches.push(new ExitButton());


			ldr.contentLoaderInfo.addEventListener(ProgressEvent.PROGRESS, loadProgress);
			ldr.contentLoaderInfo.addEventListener(Event.COMPLETE, loadComplete);

			
			loaderAnim.x=stage.stageWidth/2;
			loaderAnim.y=stage.stageHeight/2;
			

		}

		public function loadAppButtons(xml:XML):Array {

			var buttons:Array = new Array();



			var buttonsWithApps:Array = new Array();
			var count=0;

			for each (var a:XML in xml.apps.app) {
				count++;

				var appButton = new MainButton();
				appButton.SWFurl=a.url;
				appButton.parameter=a.parameter;
				appButton.btnText.text=a.name;
				trace("image: "+a.image);
				if(a.image != "")
				{
					appButton.loadImage(a.image);
				}
				if(int(a.defaultX) != 0 && int(a.defaultY) != 0 )
				{
					trace();
				appButton.defaultX = int(a.defaultX);
				appButton.defaultY = int(a.defaultY);
				}
				
				
				appButton.btnText.autoSize="center";

				appButton.bkg.width=appButton.btnText.textWidth+30;
				appButton.bkg2.width=appButton.btnText.textWidth+30;
				appButton.x=centerX;
				appButton.y=centerY;
				appButton.alpha=0;
				appButton.width=appButton.bkg.width;
				appButton.height=appButton.bkg.height;
				buttons.push(appButton);


				//if it has a sub app :D
				if (a.apps.app[0]) {
					buttonsWithApps.push(appButton);
					appButton.appButtons=loadAppButtons(a);
				}


			}
			for each (var app:MainButton in buttonsWithApps) {

				var backBtn = new BackButton();



				backBtn.btnText.text="Go Back";

				backBtn.btnText.autoSize="center";

				backBtn.bkg.width=backBtn.btnText.textWidth+30;
				backBtn.x=centerX;
				backBtn.y=centerY;
				backBtn.alpha=0;


				backBtn.parentApps=buttons;
				//Insert first
				app.appButtons.reverse();
				app.appButtons.push(backBtn);
				app.appButtons.reverse();
			}

			return buttons;




		}
		public function xmlLoaded(e:Event) {



			try {
				var xml:XML=new XML(e.target.data);
				appButtons=loadAppButtons(xml);

			} catch (e:TypeError) {
				//Could not convert the data, probably because
				//because is not formated correctly

				trace("Could not parse the XML");
				trace(e.message);
			}
			for each (var app:MainButton in appButtons) {
				addChild(app);
			}
			spreadButtons(appButtons);


		}

		public function spreadButtons(buttons:Array) {
			
			try{
				
				removeChild(loaderAnim);
			}
			catch(e:Error){}
			
			
			var isNotStartingApp = (currentButton == null || currentButton.appButtons.length>0 || currentButton is BackButton ||parentAppButtons == resetSwitches);
			for each (var app:MainButton in buttons) {
				addChild(app);
			}
			var maxWidthCount=Math.round(Math.sqrt(buttons.length));

			var count=0;
			var startX =centerX -(maxWidthCount*170)/2;
			var nextX=startX;
			var nextY = centerY-(maxWidthCount*60)/2;

			for each (var appButton:MainButton in buttons) {
				appButton.alpha=1;
				count++;
				var x:int;
				var y:int;
				if (isNotStartingApp) {
					y=nextY-appButton.height/2;
					x=nextX+appButton.width/2;
					if(appButton.defaultX != null && appButton.defaultY != null)
					{
						count--;
						y = appButton.defaultY;
						x = appButton.defaultX;
					}
				} else {
					//Get the buttons current pos..
					x=appButton.x;
					y=appButton.y;
					appButton.x=centerX;
					appButton.y=centerY;

					//Could add scale and rotation too ;).. but not right now
				}
				
				
				
				var buttonTween:GCSafeTween=new GCSafeTween(appButton,"x",Strong.easeOut,appButton.x,x,1,true);
				var buttonTween2:GCSafeTween=new GCSafeTween(appButton,"y",Strong.easeOut,appButton.y,y,1,true);

if(appButton.defaultX == null && appButton.defaultY == null)
					{
				if (count%maxWidthCount==0) {
					nextY+=appButton.height+50;
					nextX=startX;
				} else {
					nextX+=appButton.width+50;
				}
					}
			}
			if (isNotStartingApp) {
				attachListeners(buttons);
			}
		}
		public function getcloseFinished(e:TweenEvent) {

			trace("getclose finished");
			for each (var b:MainButton in parentAppButtons) {

				b.alpha=0;
				removeChild(b);
			}
			spreadButtons(appButtons);
		}
		public function getcloseButtons(buttons:Array,notimplemented:Boolean = false) {
			var isNotStartingApp = (currentButton.appButtons.length>0 || currentButton is BackButton || buttons == resetSwitches);

			removeListeners(buttons);


			var maxWidthCount=Math.round(Math.sqrt(buttons.length));

			//default x,y
			var x=centerX;
			var y=centerY;


			var count=0;
			var someTween:GCSafeTween;//Just a reference to add a listener
			for each (var appButton:MainButton in buttons) {
				removeChild(appButton);
				addChild(appButton);
				count++;
				var buttonTween:GCSafeTween=new GCSafeTween(appButton,"x",Strong.easeIn,appButton.x,x,1,true);
				var buttonTween2:GCSafeTween=new GCSafeTween(appButton,"y",Strong.easeIn,appButton.y,y,1,true);
				someTween=buttonTween;

			}
			removeChild(currentButton);
			addChild(currentButton);
			if (! isNotStartingApp) {
				trace("Starting app");
				saveCurrentMenuState();
				parentAppButtons=appButtons;
				appButtons=resetSwitches;



			}

			someTween.addEventListener(TweenEvent.MOTION_FINISH, getcloseFinished);



		}

		public function addNavElements():void {

			xmlLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, this.xmlLoaded, false, 0, true);
			xmlLoader.load(new URLRequest("local/applist.xml"));




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
				button.addEventListener(MainButtonEvent.LONG_CLICK, selectItem);
			}
		}


		public function buttonUp(e:TouchEvent) {
			var button=someParentIs(e.target.parent);
			if (button!=null) {


				button.stopClick(e.target.name);
				button.removeEventListener(MainButtonEvent.LONG_CLICK, selectItem);
			}

		}

		public function attachListeners(buttons:Array) {
			//parent as ShowFinger.showCursor();
			for each (var appButton:MainButton in buttons) {
				appButton.addEventListener(TouchEvent.MOUSE_DOWN, buttonDown);
				appButton.addEventListener(TouchEvent.MOUSE_OVER, buttonDown);

				appButton.addEventListener(TouchEvent.MOUSE_OUT, buttonUp);
				appButton.addEventListener(TouchEvent.MOUSE_UP, buttonUp);
			}




		}
		public function removeListeners(buttons:Array) {

			//parent as ShowFinger.hideCursor();
			for each (var appButton:MainButton in buttons) {

				appButton.removeEventListener(TouchEvent.MOUSE_DOWN, buttonDown);
				appButton.removeEventListener(TouchEvent.MOUSE_OVER, buttonDown);

				appButton.removeEventListener(TouchEvent.MOUSE_OUT, buttonUp);
				appButton.removeEventListener(TouchEvent.MOUSE_UP, buttonUp);
			}



		}
		public function saveCurrentMenuState() {

			for each (var homeBtn:MainButton in resetSwitches) {

				homeBtn.appButtons = new Array();
				for each (var btn:MainButton in appButtons) {
					homeBtn.appButtons.push(btn);
				}

			}
		}

		function swfLoaded( event : Event ):void {
			var loader:Loader=(event.target as Loader);//this is actually the same loader instance as below
			var mySwf:* =loader.content;
			mySwf.data=currentButton.parameter;
			trace("p:"+currentButton.parameter);

		}

		public function selectItem(eo:MainButtonEvent):void {



			if (eo.button is MainButton && !(eo.button is ExitButton) ) {
			} else {

				return;
			}
			currentButton=eo.button;

			currentButton.removeEventListener(MainButtonEvent.LONG_CLICK, selectItem);




			if (currentButton is BackButton) {
				getcloseButtons(appButtons);
				parentAppButtons=appButtons;
				appButtons = (currentButton as BackButton).parentApps;
				return;
			}
			if (currentButton.appButtons.length>0) {
				getcloseButtons(appButtons);
				parentAppButtons=appButtons;
				appButtons=currentButton.appButtons;
				return;
			}


			//If not load the file normally
			//Weird error fix
			trace("check for undefined url");




			ldr = new Loader();
			trace("LOADING:"+currentButton.SWFurl);
			

			addChild(loaderAnim);

			var url:String=currentButton.SWFurl;

			//kan være at de som standard ikke tester UNF systemer
			var urlReq:URLRequest=new URLRequest(url);

			//ldr.contentLoaderInfo.paramters["path","local/UNF/"];

			//LoaderInfo(ldr.loaderInfo).parameters["test"]=42;

			ldr.addEventListener( Event.COMPLETE, swfLoaded );
			ldr.load(urlReq);
			movieMC.alpha=0;
			movieMC.addChild(ldr);
			addChild(movieMC);
			var myTweenReturnNav:GCSafeTween=new GCSafeTween(movieMC,"alpha",Strong.easeIn,movieMC.alpha,1,3,true);

			for each (var a:MainButton in appButtons) {
				//var myTween:GCSafeTween=new GCSafeTween(a,"alpha",Strong.easeIn,a.alpha,0,1,true);
			}

			var i=0;
			for each (var resetSwitch:MainButton in resetSwitches) {


				trace(i);
				resetSwitch.alpha=0;

				if (i==0) {
					resetSwitch.x=parent.stage.stageWidth-resetSwitch.width*1.5;
					resetSwitch.y=parent.stage.stageHeight-resetSwitch.height/2;
				}
				if (i==1) {
					resetSwitch.x=resetSwitch.width/2;
					resetSwitch.y=parent.stage.stageHeight-resetSwitch.height/2;
				}
				if (i==2) {
					resetSwitch.x=parent.stage.stageWidth-resetSwitch.width*1.5;
					resetSwitch.y=resetSwitch.height;
				}
				if (i==3) {
					resetSwitch.x=resetSwitch.width/2;
					resetSwitch.y=resetSwitch.height;
				}

				trace("add");
				addChild(resetSwitch);
				trace("down events");
				resetSwitch.addEventListener(TouchEvent.MOUSE_DOWN, homeBtnDown);
				//Is this one too anoying?
				resetSwitch.addEventListener(TouchEvent.MOUSE_OVER, buttonDown);
				trace("up events");
				resetSwitch.addEventListener(TouchEvent.MOUSE_OUT, homeBtnUp);
				resetSwitch.addEventListener(TouchEvent.MOUSE_UP, homeBtnUp);
				trace("done");
				i++;
			}
			trace("getclose");
			getcloseButtons(appButtons);
			trace("tween");

		}
		/*
		public function fadeInReset(eo:TouchEvent):void {
		trace("Touched Reset DOWN");
		for(var i = 0;i<resetSwitches.length;i++);
		{
		var resetSwitch=resetSwitches[i];
		
		resetSwitch.fadeTween=new GCSafeTween(resetSwitch,"alpha",null,resetSwitch.alpha,1,3,true);
		resetSwitch.scaleXTween=new GCSafeTween(resetSwitch,"scaleX",null,resetSwitch.scaleX,1,3,true);
		resetSwitch.scaleYTween=new GCSafeTween(resetSwitch,"scaleY",null,resetSwitch.scaleY,1,3,true);
		
		resetSwitch.fadeTween.addEventListener(TweenEvent.MOTION_FINISH, checkResetFinish);
		}
		}
		*/
		public function connectedToTUIO(eo:Event):void {
			
			try {
				removeChild(loaderAnim);
			} catch (e:Error) {
			}
		}
		public function closeApp(eo:MainButtonEvent):void {

			/*this.width=parent.stage.width;
			this.height=parent.stage.height;
			trace("Tracing container:!!!");
			trace(this.x);
			trace(this.y);
			trace(this.width);
			trace(this.height);
			trace("load wait finished!!!");
			//var myTweenReturnNav:GCSafeTween = new GCSafeTween(navigation, "x", Strong.easeIn, navigation.x, 0, 1.5, true);
			*/
			var oldButtons=eo.button.appButtons;
			for each (var resetSwitch:MainButton in resetSwitches) {


				resetSwitch.appButtons = new Array();
				resetSwitch.removeEventListener(TouchEvent.MOUSE_DOWN, homeBtnDown);
				//Is this one too anoying? .. nah
				resetSwitch.addEventListener(TouchEvent.MOUSE_OVER, buttonDown);

				resetSwitch.removeEventListener(TouchEvent.MOUSE_OUT, homeBtnUp);
				resetSwitch.removeEventListener(TouchEvent.MOUSE_UP, homeBtnUp);
				//removeChild(resetSwitch);

			}


			trace("closeApp2");
			var myTweenReturnNavBack:GCSafeTween=new GCSafeTween(movieMC,"alpha",Strong.easeIn,movieMC.alpha,0,2,true);
			myTweenReturnNavBack.addEventListener(TweenEvent.MOTION_FINISH, removeLoader);
			//parent as ShowFinger.showCursor();


			parentAppButtons=resetSwitches;

			//Need to set buttons first.

			appButtons=oldButtons;



			currentButton=eo.button;
			getcloseButtons(parentAppButtons);
			//They have to spread from here.




			//renmove app... as good as i know how to do.. (Hint: It doesn't work correctly);
			//It probably still listening on some TUIO events and therefore can't be garbage collected




		}
		public function removeLoader(e:TweenEvent) {
			trace("remove loader");
			try {
				movieMC.removeChild(ldr);

			} catch (e:Error) {
			}
			try {

				removeChild(movieMC);
			} catch (e:Error) {
			}
			movieMC = new MovieClip();
			ldr.unload();

			ldr=null;
		}

		/*
		public function fadeOutReset(eo:TouchEvent):void {
		trace("Touched Reset UP");
		for(var i = 0;i<resetSwitches.length;i++);
		{
		var resetSwitch=resetSwitches[i];
		resetSwitch.fadeTween.removeEventListener(TweenEvent.MOTION_FINISH, checkResetFinish);
		
		resetSwitch.fadeTween.continueTo(.5, 1);
		resetSwitch.scaleXTween.continueTo(.25, 1);
		resetSwitch.scaleYTween.continueTo(.25, 1);
		}
		}
		*/

		public function homeBtnDown(e:TouchEvent) {
			var button=someParentIs(e.target.parent);
			if (button!=null) {


				button.startClick(e.target.name);
				button.addEventListener(MainButtonEvent.LONG_CLICK, closeApp);
			}
		}


		public function homeBtnUp(e:TouchEvent) {
			var button=someParentIs(e.target.parent);
			if (button!=null) {


				button.stopClick(e.target.name);
				button.removeEventListener(MainButtonEvent.LONG_CLICK, closeApp);
			}

		}

		function loadProgress(event:ProgressEvent):void {
			var percentLoaded:Number=event.bytesLoaded/event.bytesTotal;
			percentLoaded=Math.round(percentLoaded*100);
			trace("Loading: "+percentLoaded+"%");
		}
		function loadComplete(event:Event):void {
			trace("Complete");
		}

	}

}