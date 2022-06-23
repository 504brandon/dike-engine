package ui;

import openfl.Lib;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import haxe.ds.StringMap;

class ModifiersMenu extends Page
{
	public static var Modifiers:StringMap<Dynamic> = new StringMap<Dynamic>();

	var checkboxes:Array<CheckboxThingie> = [];
	var menuCamera:FlxCamera;
	var items:TextMenuList;
	var camFollow:FlxObject;

	override public function new()
	{
		super();

		menuCamera = new FlxCamera();
		FlxG.cameras.add(menuCamera, false);
		menuCamera.bgColor = FlxColor.TRANSPARENT;
		camera = menuCamera;
		add(items = new TextMenuList());

		createPrefItem('health drain', 'hpd', false);

		createPrefItem('upsidedown', 'upd', false);

		createPrefItem('insane funkin', 'insane', false);

		createPrefItem('opponent play', 'op', false);

		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);
		if (items != null)
		{
			camFollow.y = items.members[items.selectedIndex].y;
		}
		menuCamera.follow(camFollow, null, 0.06);
		menuCamera.deadzone.set(0, 160, menuCamera.width, 40);
		menuCamera.minScrollY = 0;
		items.onChange.add(function(item:TextMenuItem)
		{
			camFollow.y = item.y;
		});
	}

	public static function getPref(pref:String)
	{
		return Modifiers.get(pref);
	}

	public static function initPrefs()
	{
		if(FlxG.save.data.modifiers != null)
			Modifiers = FlxG.save.data.modifiers;
		
		ModifiersCheck('hpd', false);
		ModifiersCheck('upd', false);
		ModifiersCheck('op', false);
		ModifiersCheck('insane', false);
		
		if (!getPref('fps-counter'))
			Lib.current.stage.removeChild(Main.fpsCounter);

		FlxG.autoPause = getPref('auto-pause');
	}

	public static function ModifiersCheck(identifier:String, defaultValue:Dynamic)
	{
		if (Modifiers.get(identifier) == null)
		{
			Modifiers.set(identifier, defaultValue);
			trace('set preference!');

			FlxG.save.data.modifiers = Modifiers;
			FlxG.save.flush();
		}
		else
		{
			trace('found preference: ' + Std.string(Modifiers.get(identifier)));
		}
	}

	public function createPrefItem(label:String, identifier:String, value:Dynamic)
	{
		items.createItem(120, 120 * items.length + 30, label, Bold, function()
		{
			ModifiersCheck(identifier, value);
			
			if (Type.typeof(value) == TBool)
				prefToggle(identifier);
			else
				trace('swag');
		});

		if (Type.typeof(value) == TBool)
			createCheckbox(identifier);
		else
			trace('swag');

		trace(Type.typeof(value));
	}

	public function createCheckbox(identifier:String)
	{
		var box:CheckboxThingie = new CheckboxThingie(0, 120 * (items.length - 1), Modifiers.get(identifier));
		checkboxes.push(box);
		add(box);
	}

	public function prefToggle(identifier:String)
	{
		var value:Bool = Modifiers.get(identifier);
		value = !value;
		Modifiers.set(identifier, value);
		checkboxes[items.selectedIndex].daValue = value;

		trace('toggled? ' + Std.string(Modifiers.get(identifier)));

		switch (identifier)
		{
			case 'auto-pause':
				FlxG.autoPause = getPref('auto-pause');
			case 'fps-counter':
				if (getPref('fps-counter'))
					Lib.current.stage.addChild(Main.fpsCounter);
				else
					Lib.current.stage.removeChild(Main.fpsCounter);
		}

		FlxG.save.data.modifiers = Modifiers;
		FlxG.save.flush();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.keys.justPressed.ESCAPE)
			FlxG.switchState(new OptionsState());

		menuCamera.followLerp = CoolUtil.camLerpShit(0.05);

		items.forEach(function(item:MenuItem)
		{
			if (item == items.members[items.selectedIndex])
				item.x = 150;
			else
				item.x = 120;
		});
	}

	public static function getGame(arg0:String) {
		throw new haxe.exceptions.NotImplementedException();
	}
}