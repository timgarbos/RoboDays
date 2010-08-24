package app.cyancdesign {
	
	import flash.display.DisplayObject;
	import flash.events.Event;	
	
	public class MainButtonEvent extends Event
	{
		public static const LONG_CLICK:String = "app.cyancdesign.MainButtonEvent.LONG_CLICK";		
		
		var button:MainButton;
		public function MainButtonEvent(type:String,btn:MainButton)
		{
			button = btn;
			super(type);
		}
		
	}
	
}