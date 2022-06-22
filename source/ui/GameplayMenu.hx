package ui;

import openfl.Lib;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxCamera;
import flixel.util.FlxColor;
import haxe.ds.StringMap;

class GameplayMenu extends Page
{
	public static var gameplay:StringMap<Dynamic> = new StringMap<Dynamic>();

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
		createGameItem('Downscroll', 'downscroll', false);
		createGameItem('Ghost Tapping', 'ghosttapping', true);
        createGameItem('icon colors', 'healthcolors', true);
		camFollow = new FlxObject(FlxG.width / 2, 0, 240, 70);
		if (items != null)
		{
			camFollow.y = items.members[items.selectedIndex].y;
		}
		menuCamera.follow(camFollow, null, 0);
		menuCamera.deadzone.set(0, 160, menuCamera.width, 40);
		//menuCamera.minScrollY = 0;
		items.onChange.add(function(item:TextMenuItem)
		{
			camFollow.y = item.y;
		});
	}

	public static function getGame(game:String)
	{
		return gameplay.get(game);
	}

	public static function initgames()
	{
		gameplayCheck('downscroll', false);
		gameplayCheck('ghosttapping', true);
		gameplayCheck('wm', true);
		gameplayCheck('master-volume', 1);
	}

	public static function gameplayCheck(identifier:String, defaultValue:Dynamic)
	{
		if (gameplay.get(identifier) == null)
		{
			gameplay.set(identifier, defaultValue);
			trace('set gameplay option!');
		}
		else
		{
			trace('found gameplay option: ' + Std.string(gameplay.get(identifier)));
		}
	}

	public function createGameItem(label:String, identifier:String, value:Dynamic)
	{
		items.createItem(120, 120 * items.length + 30, label, Bold, function()
		{
			gameplayCheck(identifier, value);
			if (Type.typeof(value) == TBool)
			{
				gameToggle(identifier);
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
		var box:CheckboxThingie = new CheckboxThingie(0, 120 * (items.length - 1), gameplay.get(identifier));
		checkboxes.push(box);
		add(box);
	}

	public function gameToggle(identifier:String)
	{
		var value:Bool = gameplay.get(identifier);
		value = !value;
		gameplay.set(identifier, value);
		checkboxes[items.selectedIndex].daValue = value;
		trace('toggled? ' + Std.string(gameplay.get(identifier)));
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
}