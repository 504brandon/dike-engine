package credits;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import mods.HScript;

class CreditStatep2 extends MusicBeatState
{
	public var script:HScript;
	var menuBG:FlxSprite;
	public var CreditTxt:FlxText;
	public var PageTxt:FlxText;


	override function create()
	{

		menuBG = new FlxSprite(null, null, Paths.image('menuDesat'));
		menuBG.color = 0xff15ff00;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = true;
		add(menuBG);

		CreditTxt = new FlxText("Extrea Credits
		\nKadeDev: the extenction for vidios
		\nLeather128: helped code ALOT and made the credits and achevemant art for the menu
		\nfunni thing so leather shows up i guess");
		CreditTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		CreditTxt.x = 434.7;
		CreditTxt.screenCenter(Y);
		CreditTxt.borderSize = 2.17;
		CreditTxt.size = 18;
		add(CreditTxt);

		PageTxt = new FlxText("2/3");
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
			FlxG.switchState(new CreditState());
		}
		if (FlxG.keys.justPressed.RIGHT)
		{
			FlxG.switchState(new CreditStatep3());
		}
		super.update(elapsed);
	}
}
