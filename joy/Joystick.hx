package joy;

import flash.display.Shape;
import flash.events.MouseEvent;
import flash.events.TouchEvent;
import flash.geom.Point;
import flash.system.Capabilities;
import flash.ui.Multitouch;
import flash.ui.MultitouchInputMode;
import flash.Lib;
import joy.events.JoystickEvent;

class Joystick extends Point
{

	private static var byId:Map<Int, Joystick>;
	#if debug
	private static var debug:Shape;
	#end
	public static var radius:Float = Capabilities.screenDPI * 0.25;

	private var center:Point;

	public var id(default, null):Int;

	function new(id:Int, x:Float, y:Float)
	{
		super();

		this.center = new Point(x, y);
		this.id = id;
	}

	override public function toString():String
	{
		return "[ Joystick " + id + " (" + x + ", " + y + ") ]";
	}

	public static function start()
	{
		if (Multitouch.supportsTouchEvents)
		{
			Lib.current.stage.addEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			Lib.current.stage.addEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			Lib.current.stage.addEventListener(TouchEvent.TOUCH_END, onTouchEnd);

			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
		}
		else
		{
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			Lib.current.stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		byId = new Map();
		#if debug
		debug = new Shape();
		Lib.current.addChild(debug);
		#end
	}

	public static function stop()
	{
		if (Multitouch.supportsTouchEvents)
		{
			Lib.current.stage.removeEventListener(TouchEvent.TOUCH_BEGIN, onTouchBegin);
			Lib.current.stage.removeEventListener(TouchEvent.TOUCH_MOVE, onTouchMove);
			Lib.current.stage.removeEventListener(TouchEvent.TOUCH_END, onTouchEnd);
		}
		else
		{
			Lib.current.stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
			Lib.current.stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
			Lib.current.stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
		}

		byId = null;
		#if debug
		Lib.current.removeChild(debug);
		debug = null;
		#end
	}

	static function onTouchBegin(e:TouchEvent)
	{
		onBegin(e.touchPointID, e.stageX, e.stageY);
	}

	static function onTouchMove(e:TouchEvent)
	{
		onMove(e.touchPointID, e.stageX, e.stageY);
	}

	static function onTouchEnd(e:TouchEvent)
	{
		onEnd(e.touchPointID, e.stageX, e.stageY);
	}

	static function onMouseDown(e:MouseEvent)
	{
		onBegin(0, e.stageX, e.stageY);
	}

	static function onMouseMove(e:MouseEvent)
	{
		onMove(0, e.stageX, e.stageY);
	}

	static function onMouseUp(e:MouseEvent)
	{
		onEnd(0, e.stageX, e.stageY);
	}

	static inline function onBegin(id:Int, x:Float, y:Float)
	{
		var joystick = new Joystick(id, x, y);

		byId.set(id, joystick);

		if (Lib.current.stage.hasEventListener(JoystickEvent.JOYSTICK_ADDED))
		{
			Lib.current.stage.dispatchEvent(new JoystickEvent(JoystickEvent.JOYSTICK_ADDED, false, false, joystick));
		}

		draw();
	}

	static inline function onMove(id:Int, x:Float, y:Float)
	{
		if (byId.exists(id))
		{
			var joystick = byId.get(id);

			var position = new Point(x, y);
			var difference = position.subtract(joystick.center);

			if (difference.length > radius)
			{
				difference.normalize(radius);

				joystick.center = position.subtract(difference);
			}

			joystick.x = difference.x / radius;
			joystick.y = difference.y / radius;

			if (Lib.current.stage.hasEventListener(JoystickEvent.JOYSTICK_MOVED))
			{
				Lib.current.stage.dispatchEvent(new JoystickEvent(JoystickEvent.JOYSTICK_MOVED, false, false, joystick));
			}

			draw();
		}
	}

	static inline function onEnd(id:Int, x:Float, y:Float)
	{
		if (byId.exists(id))
		{
			var joystick = byId.get(id);
	
			if (Lib.current.stage.hasEventListener(JoystickEvent.JOYSTICK_REMOVED))
			{
				Lib.current.stage.dispatchEvent(new JoystickEvent(JoystickEvent.JOYSTICK_REMOVED, false, false, joystick));
			}

			byId.remove(id);

			draw();
		}
	}

	static inline function draw()
	{
		#if debug
		debug.graphics.clear();
		for (joystick in byId)
		{
			// Draw limits
			debug.graphics.lineStyle(2, 0xFFFFFF, 0.2);
			debug.graphics.drawCircle(joystick.center.x, joystick.center.y, radius + radius * .75);
			debug.graphics.lineStyle();
			// Draw center
			debug.graphics.beginFill(0xFFFFFF, 0.2);
			debug.graphics.drawCircle(joystick.center.x, joystick.center.y, radius * .15);
			debug.graphics.endFill();
			// Draw position
			debug.graphics.beginFill(0xFFFFFF, 0.1);
			debug.graphics.drawCircle(joystick.center.x + joystick.x * radius, joystick.center.y + joystick.y * radius, radius * .75);
			debug.graphics.endFill();
		}
		#end
	}
	
}
