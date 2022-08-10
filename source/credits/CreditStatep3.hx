package credits;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import mods.HScript;

class CreditStatep3 extends MusicBeatState
{
	public var script:HScript;
	var menuBG:FlxSprite;
	public var CreditTxt:FlxText;
	public var PageTxt:FlxText;


	override function create()
	{

		menuBG = new FlxSprite(null, null, Paths.image('menuDesat'));
		menuBG.color = 0xfff6ff00;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		CreditTxt = new FlxText("Main Game
		\nNinjaMuffin99: The Programmer
		\nPhantomArcade: The Artist
		\nEvilsk8r: The Animator
		\nKawaiSprite: The composer
		\nfunni thing so the funkin creators show up i guess");

		//legonds say that they all worked together to make a rythem game named friday night funkin (also why did i add this Y E S)
		CreditTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		CreditTxt.x = 365.7;
		CreditTxt.screenCenter(Y);
		CreditTxt.borderSize = 2.17;
		CreditTxt.size = 18;
		add(CreditTxt);

		PageTxt = new FlxText("3/3");
		PageTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		PageTxt.screenCenter(X);
		PageTxt.y = 521;
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

		if (FlxG.keys.justPressed.LEFT)
		{
			FlxG.switchState(new CreditStatep2());
		}
		super.update(elapsed);
	}
}
