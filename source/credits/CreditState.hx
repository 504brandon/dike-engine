package credits;

#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import mods.HScript;
import lime.app.Application;

class CreditState extends MusicBeatState
{
	public var script:HScript;
	var menuBG:FlxSprite;
	public var CreditTxt:FlxText;
	var PageTxt:FlxText;


	override function create()
	{
		#if desktop
		DiscordClient.changePresence("In The Credits", null, null, true);
		Application.current.window.title = 'Friday Night Funkin Dike Engine Credits Menu';
		#end

		menuBG = new FlxSprite(null, null, Paths.image('menuDesat'));
		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		CreditTxt = new FlxText("Dike Engine Developers
		\n504 brandon: owning the entire engine and coded moast of it and started it off
		\nInsKal: helped code alot of things also supported me while making this engine
		\n! Neon: codes some extrea stuff for the engine
		\nMeepers: makes art for the engine such as the oof texture
		\nCaper: makes art for the engine (basicly the same as meepers lol)
		\n thing so Caper shows up yea idk why haxe sucks man");
		CreditTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		CreditTxt.x = 208.86;
		CreditTxt.screenCenter(Y);
		CreditTxt.borderSize = 2.17;
		CreditTxt.size = 18;
		add(CreditTxt);

		PageTxt = new FlxText("1/3");
		PageTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		PageTxt.screenCenter(X);
		PageTxt.y = 522;
		//WHY DID I HAVE TO SET THIS SO FUNKIN HIGH
		add(PageTxt);

		if (Assets.exists(Paths.hx('credits'))) {
			{
				script = new HScript(Paths.hx('credits'));
				script.interp.variables.set("credit", this);
				script.callFunction("createCredits");
			}
	}
}

	override function update(elapsed:Float)
	{
		if (controls.BACK)
			FlxG.switchState(new MainMenuState());

		if (FlxG.keys.justPressed.RIGHT)
		{
			FlxG.switchState(new CreditStatep2());
		}

		if (FlxG.keys.justPressed.LEFT)
		{
			FlxG.switchState(new CreditStatep3());
		}
		super.update(elapsed);
	}
}
