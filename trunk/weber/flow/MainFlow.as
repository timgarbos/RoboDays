////////////////////////////////////////////
// Project: Flash 10 Coverflow
// Date: 10/3/09
// Author: Stephen Weber
////////////////////////////////////////////

package weber.flow{

	////////////////////////////////////////////
	// IMPORTS
	////////////////////////////////////////////
	
	//import flash.utils.*;
	//import flash.media.*;
	import flash.display.*;
	import flash.events.*;
	
	//import flash.net.*;
	//import flash.text.*;
	
	public class MainFlow extends Sprite {

		////////////////////////////////////////////
		// VARIABLES
		////////////////////////////////////////////
		
		public var coverflow:Coverflow;
		
		////////////////////////////////////////////
		// CONSTRUCTOR - INITIAL ACTIONS
		////////////////////////////////////////////
		public function MainFlow() {
			setupStage();
			
			//Resize Listener
		
			addEventListener(Event.ADDED_TO_STAGE, init);
			
			
			
			
		}
		
		////////////////////////////////////////////
		// FUNCTIONS
		////////////////////////////////////////////
		public function setupStage():void {
			
			
			
		}
		
		//Handles Resizing the Image
		private function resizeHandler(event:Event):void {

			resizeMe();

		}
		private function resizeMe():void {
			
			//No Resizing for This
			
		}
		private function init(e:Event):void {
			trace("added to stage");
			this.stage.addEventListener(Event.RESIZE, resizeHandler);
			resizeMe();
			if(parent.parent)
			{
			trace(parent.parent.width);
			trace(this.stage.stageWidth);
			coverflow = new Coverflow(parent.parent.width, parent.parent.height, this.stage,parent.parent as MovieClip);
			addChild(coverflow);
			}
			
	
			
		}
	}
}