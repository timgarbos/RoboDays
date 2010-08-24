package app.cyancdesign{

	import flash.display.*;
	import flash.text.TextField;
	import flash.events.*;
	import flash.net.*;
	import app.cyancdesign.MainButtonEvent;
	import flash.system.fscommand;
	public class MainButton extends MovieClip {

		var defaultX;
		var defaultY;
		var clickdelay:int=2;
		var clickerID:Array;
		var clickLoading:Boolean=false;
		var resetLoader:Boolean=false;
		var _SWFurl:String;
		var imageLoader:Loader;
		var isImage = false;
		public var parameter:String="";

		var appButtons:Array = new Array();
		public function MainButton():void {
			clickerID = new Array();

		}
		public function fitContent() {
			btnText.autoSize="center";

			bkg.width=btnText.textWidth+30;
			bkg2.width=btnText.textWidth+30;




		}
		public function set SWFurl(b:String):void {
			trace("set MainButton Value To: "+ b);
			_SWFurl=b;
		}
		public function get SWFurl():String {
			return _SWFurl;
		}
		

		public function loadImage(url:String):void {
			imageLoader = new Loader();
			imageLoader.load(new URLRequest(url));
			imageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, imageLoaded);
		}

		public function imageLoaded(e:Event):void {
			// Load Image
			imageLoader.x = -imageLoader.content.width/2;
			//imageLoader.y = -imageLoader.content.height/2;
			this.addChild(imageLoader);
			btnText.alpha = 0;
			bkg.alpha = 0;
			bkg2.alpha = 0;
			isImage = true;
		}

		public function startClick(id:int) {

			//add only if it's not there

			clickerID.push(id);
			trace("add "+id);

			if (! clickLoading) {
				trace("stat loading");
				if (currentLabel=="normal") {
					trace("goto start");

					gotoAndStop("startClick");
					resetLoader=true;
				}




				this.addEventListener(Event.ENTER_FRAME, checkForFinish);

			}

			clickLoading=true;

		}

		public function stopClick(id:int) {

			if (clickerID.indexOf(id)!=-1) {
				trace("rem "+id);
				clickerID.splice(clickerID.indexOf(id),1);
				CheckForStop();
			}


		}
		public function CheckForStop() {

			if (currentLabel=="finish") {
				trace(SWFurl);
				if (SWFurl=="%fscommand%") {

					if (parameter=="%restart%") {
						fscommand("exec","RoboDays_MT.exe");
						fscommand("quit");

					}


					var pars=parameter.split(";");
					trace(pars);

					if (pars.length>1) {
						trace("fscommand("+pars[0]+","+pars[1]+");");
						fscommand(pars[0],pars[1]);
					} else {
						trace("fscommand("+pars[0]+");");
						fscommand(pars[0]);


					}

				} else {
					dispatchEvent(new MainButtonEvent(MainButtonEvent.LONG_CLICK,this));
				}
				clickerID = new Array();


				this.removeEventListener(Event.ENTER_FRAME, checkForFinish);
				gotoAndStop("normal");

				//loader.gotoAndStop(1);
				clickLoading=false;

			}
			if (currentLabel=="stopClick") {

				clickerID = new Array();
				this.removeEventListener(Event.ENTER_FRAME, checkForFinish);
				gotoAndStop("normal");

				//loader.gotoAndStop(1);
				clickLoading=false;
			}


		}
		public function checkForFinish(e:Event):void {

			try {


				/*if (loader.currentFrame<2) {
				loader.gotoAndStop(1);
				}*/
				if (resetLoader) {
					//loader.gotoAndStop(1);

					resetLoader=false;
				}
			} catch (e:TypeError) {
			}

			CheckForStop();


			if (clickerID.length==0) {


				prevFrame();
				/*try {
				loader.prevFrame();
				
				} catch (e:TypeError) {
				}*/


			} else {
				nextFrame();
				/*try {
				loader.nextFrame();
				} catch (e:TypeError) {
				}*/
			}



		}
	}

}