package app.cyancdesign {
	
	import flash.display.*;
	import flash.text.TextField;
	
	public class BackButton extends MainButton {
		
		var parentApps:Array;
		public function BackButton():void{
			btnText.text ="Close";
			btnText.autoSize="center";

				bkg.width=btnText.textWidth+30;
				bkg2.width=btnText.textWidth+30;
				
				
				width=bkg.width;
				height=bkg.height;
		}
		
		
		
	}
	
}