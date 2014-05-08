package joy.events;

import flash.events.Event;
import flash.Lib;
import joy.Joystick;

class JoystickEvent extends Event
{

	public var joystick(default, null):Joystick;
	
	public function new(type:String, bubbles:Bool = false, cancelable:Bool = false, ?joystick:Joystick)
	{
		super(type, bubbles, cancelable);

		this.joystick = joystick;
	}

	override public function clone():Event
	{
		return new JoystickEvent(type, bubbles, cancelable, joystick);
	}

	public static inline var JOYSTICK_ADDED:String = "joystickAdded";
	public static inline var JOYSTICK_MOVED:String = "joystickMoved";
	public static inline var JOYSTICK_REMOVED:String = "joystickRemoved";

}
