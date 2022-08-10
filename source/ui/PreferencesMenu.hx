package ui;

import lime.utils.Assets;
import openfl.Lib;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import haxe.ds.StringMap;

import mods.HScript;

class PreferencesMenu extends Page
{
	public static var preferences:StringMap<Dynamic> = new StringMap<Dynamic>();
	public var script:HScript;

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

		createPrefItem('optimization', 'fpslol', false);
		createPrefItem('censors', 'censor-naughty', false);
		createPrefItem('events', 'events', true);
		createPrefItem('ghost tapping', 'gt', true);
		createPrefItem('downscroll', 'downscroll', false);
		createPrefItem('winning icons', 'wi', false);
		createPrefItem('vs online style', 'vos', false);
		createPrefItem('Opponent score', 'ops', false);
		createPrefItem('rateing counter', 'rc', false);
		createPrefItem('dike engine arrows', 'DEA', false);
		createPrefItem('Complex Score Text', 'cst', true);
		createPrefItem('ui', 'ui', true);
		createPrefItem('note splashes', 'ns', true);
		createPrefItem('watermarks', 'wm', true);
		createPrefItem('flashing menu', 'flashing-menu', true);
		createPrefItem('Camera Zooming on Beat', 'camera-zoom', true);
		createPrefItem('health colors', 'hc', true);
		createPrefItem('Auto Pause', 'auto-pause', false);
		createPrefItem('Debug Mode', 'dm', false);
		createPrefItem('Mods Load', 'mods', true);

		if (Assets.exists(Paths.hx('data/options'))) {
			{
				script = new HScript(Paths.hx('data/options'));
				script.interp.variables.set("options", this);
				script.callFunction("createOptions");
			}
		}

		camFollow = new FlxObject(FlxG.width / 2, 0, 140, 70);

		if (items != null)
			camFollow.y = items.members[items.selectedIndex].y;

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
		return preferences.get(pref);
	}

	public static function initPrefs()
	{
		if(FlxG.save.data.preferences != null)
			preferences = FlxG.save.data.preferences;
		
		preferenceCheck('fpslol', false);
		preferenceCheck('events', true);
		preferenceCheck('vos', false);
		preferenceCheck('censor-naughty', false);
		preferenceCheck('cutsenses', true);
		preferenceCheck('downscroll', false);
		preferenceCheck('DEA', false);
		preferenceCheck('rc', false);
		preferenceCheck('cst', true);
		preferenceCheck('ops', false);
		preferenceCheck('ns', true);
		preferenceCheck('ui', true);
		preferenceCheck('wm', true);
		preferenceCheck('flashing-menu', true);
		preferenceCheck('camera-zoom', true);
		preferenceCheck('hc', true);
		preferenceCheck('gt', true);
		preferenceCheck('wi', false);
		preferenceCheck('auto-pause', false);
		preferenceCheck('dm', false);
		preferenceCheck('master-volume', 1);
		preferenceCheck('fps', 60);
		preferenceCheck('mods', true);

		if (!getPref('fps-counter'))
			Lib.current.stage.removeChild(Main.fpsCounter);

		FlxG.autoPause = getPref('auto-pause');
	}

	public static function preferenceCheck(identifier:String, defaultValue:Dynamic)
	{
		if (preferences.get(identifier) == null)
		{
			preferences.set(identifier, defaultValue);
			trace('set preference!');

			FlxG.save.data.preferences = preferences;
			FlxG.save.flush();
		}
		else
			trace('found preference: ' + Std.string(preferences.get(identifier)));
	}

	public function createPrefItem(label:String, identifier:String, value:Dynamic)
	{
		items.createItem(120, 120 * items.length + 30, label, Bold, function()
		{
			preferenceCheck(identifier, value);
			if (Type.typeof(value) == TBool)
			{
				prefToggle(identifier);
			}
			else
			{
				trace('swag');
			}
		});
		if (Type.typeof(value) == TBool)
		{
			createCheckbox(identifier);
		}
		else
		{
			trace('swag');
		}
		trace(Type.typeof(value));
	}

	public function createCheckbox(identifier:String)
	{
		var box:CheckboxThingie = new CheckboxThingie(0, 120 * (items.length - 1), preferences.get(identifier));
		checkboxes.push(box);
		add(box);
	}

	public function prefToggle(identifier:String)
	{
		var value:Bool = preferences.get(identifier);
		value = !value;
		preferences.set(identifier, value);
		checkboxes[items.selectedIndex].daValue = value;

		trace('toggled? ' + Std.string(preferences.get(identifier)));

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

		FlxG.save.data.preferences = preferences;
		FlxG.save.flush();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

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