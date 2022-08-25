package;

import ui.CharSelectMenu;
import ui.CharSelectMenu.Boyguy;
import haxe.Log;
import flixel.addons.api.FlxGameJolt;
import animate.FlxAnimate;
import shaderslmfao.BuildingShaders;
import ui.PreferencesMenu;
import ui.ModifiersMenu;
import shaderslmfao.ColorSwap;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets as OpenFlAssets;
import mods.HScript;
import lime.app.Application;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var deathCounter:Int = 0;
	public static var practiceMode:Bool = false;
	public static var seenCutscene:Bool = false;
	public static var camshake:Bool = false;

	public var halloweenLevel:Bool = false;

	public var vocals:FlxSound;
	public var vocalsFinished = false;

	public var dad:Character;
	public var gf:Character;
	public var boyfriend:Boyfriend;

	public var notes:FlxTypedGroup<Note>;
	public var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;
	public var curSection:Int = 0;

	public var camFollow:FlxObject;
	public var camPos:FlxPoint;

	public static var prevCamFollow:FlxObject;

	public var strumLineNotes:FlxTypedGroup<FlxSprite>;
	public var playerStrums:FlxTypedGroup<FlxSprite>;
	public var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	public var camZooming:Bool = false;
	public var curSong:String = "";

	public var gfSpeed:Int = 1;
	public var health:Float = 1;
	public var combo:Int = 0;

	public var healthBarBG:FlxSprite;
	public var healthBar:FlxBar;

	public var timeBarBG:FlxSprite;
	public var timeBar:FlxBar;
	public var timeTxt:FlxText;

	public var generatedMusic:Bool = false;
	public var startingSong:Bool = false;

	public var iconP1:HealthIcon;
	public var iconP2:HealthIcon;
	public var camHUD:FlxCamera;
	public var camGame:FlxCamera;

	public var dialogue:Array<String> = ['null'];

	public var halloweenBG:FlxSprite;
	public var isHalloween:Bool = false;

	public var foregroundSprites:FlxTypedGroup<BGSprite>;

	public var phillyCityLights:FlxTypedGroup<FlxSprite>;
	public var phillyTrain:FlxSprite;
	public var streetBehind:FlxSprite;
	public var city:FlxSprite;
	public var trainSound:FlxSound;
	public var lightFadeShader:BuildingShaders;

	public var limo:FlxSprite;
	public var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	public var fastCar:FlxSprite;

	public var upperBoppers:FlxSprite;
	public var bottomBoppers:FlxSprite;
	public var santa:FlxSprite;

	public var bgGirls:BackgroundGirls;
	public var wiggleShit:WiggleEffect = new WiggleEffect();

	public var tankWatchtower:BGSprite;
	public var tankGround:BGSprite;
	public var tankmanRun:FlxTypedGroup<TankmenBG>;

	public var ready:FlxSprite;

	public var gfCutsceneLayer:FlxTypedGroup<FlxAnimate>;
	public var bfTankCutsceneLayer:FlxTypedGroup<FlxAnimate>;

	public var talking:Bool = true;

	public var bca:Bool = true;

	public var songScore:Int = 0;

	// some stuff for the txt lol
	public var misses:Int = 0;
	public var cb:Int = 0;
	public var scoreTxt:FlxText;
	public var SETxt:FlxText;
	public var rateingCounter:FlxText;
	public var debugTxt:FlxText;
	public var dadScore:Int = 0;
	public var sicks:Int = 0;
	public var bads:Int = 0;
	public var goods:Int = 0;
	public var shits:Int = 0;
	public var oofs:Int = 0;
	public var ver = "v" + Application.current.meta.get('version');
	var tweenHealth:FlxTween;

	var time:Float = 0;

	public var script:HScript;

	public static var campaignScore:Int = 0;

	public var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	public var inCutscene:Bool = false;

	public static var storyDifficultyText:String = "";

	// Discord RPC variables
	public var iconRPC:String = "";
	public var songLength = FlxG.sound.music.length;
	public var detailsText:String = "";
	public var detailsPausedText:String = "";

	public static var instance:PlayState;

	public var bg:BGSprite;
	public var stageFront:FlxSprite;
	public var stageCurtains:FlxSprite;

	override public function create()
	{
		instance = this;

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var instPath = Paths.inst(SONG.song.toLowerCase());

		if (OpenFlAssets.exists(instPath, SOUND) || OpenFlAssets.exists(instPath, MUSIC))
			OpenFlAssets.getSound(instPath, true);

		var vocalsPath = Paths.voices(SONG.song.toLowerCase());

		if (OpenFlAssets.exists(vocalsPath, SOUND) || OpenFlAssets.exists(vocalsPath, MUSIC))
			OpenFlAssets.getSound(vocalsPath, true);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.1;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		if (SONG.song.toLowerCase() == 'eggnog')
		{
			bca = false;
		}

		if (SONG.song.toLowerCase() == 'cocoa')
		{
			bca = false;
		}

		if (SONG.song.toLowerCase() == 'winter-horrorland')
		{
			bca = false;
		}

		if (SONG.song.toLowerCase() == 'senpai')
		{
			bca = false;
		}

		if (SONG.song.toLowerCase() == 'roses')
		{
			bca = false;
		}

		if (SONG.song.toLowerCase() == 'thorns')
		{
			bca = false;
		}

		if (SONG.song.toLowerCase() == 'stress')
		{
			bca = false;
		}

		if (bca == true)
		{
			SONG.player1 = CharSelectMenu.bfver;
		}

		// brandon get noob
		// i didnt even see this until i was messing with playstate lol anyway leather if you are seeing this unoreverse card
		if (ModifiersMenu.getPref('op'))
		{
			var oldP1 = SONG.player1;
			var oldP2 = SONG.player2;

			SONG.player2 = oldP1;
			SONG.player1 = oldP2;
		}

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		foregroundSprites = new FlxTypedGroup<BGSprite>();

		if (PreferencesMenu.getPref('cutsenses'))
		{
			switch (SONG.song.toLowerCase())
			{
				case 'tutorial':
					dialogue = ["Hey you're pretty cute.", 'Use the arrow keys to keep up \nwith me singing.'];
				case 'bopeebo':
					dialogue = [
						'HEY!',
						"WHY ARE YOU SO SUS!?!?!?!?!?!?!?!?!?!??!?!",
						"IF YOU WANNA OIKFJVOGKMGKNGHJGFNJKIFGHNKFGJHNGKHJBNFIKJHGBNIKNFVIJKHNGFHJKGVNn/GJKBNJKGBNJKEFGNGJKNGFJKNGJGNJKNJGKVNJGBKHNGJKBNGJNGJKBBNGJKVNFGJBNGJKNGKJBGNJGKNGJKNn/OJOGJMOKGJMGKBMJGKBNJGKNGJKVNGJFKIFNHGJFKGNGDFJXKBNFGKHGKHN",
						"UR GONNA JFOJNFJKN"
					];
				case 'fresh':
					dialogue = ["Not too shabby boy.", ""];
				case 'dadbattle':
					dialogue = [
						"gah you think you're hot stuff?",
						"If you can beat me here...",
						"Only then I will even CONSIDER letting you\ndate my daughter!"
					];
				case 'senpai':
					dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));

				case "roses":
					if (PreferencesMenu.getPref("censor-naughty"))
					{
						dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialoguecensor'));
					}
					else
					{
						dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
					}

				case 'thorns':
					dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
			}
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		DiscordClient.changePresence(detailsText, SONG.song + ' (' + storyDifficultyText + ')', iconRPC);

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		#end

		trace(SONG.song + " has been loaded");

		switch (SONG.song.toLowerCase())
		{
			case 'spookeez' | 'monster' | 'south':
				{
					curStage = 'spooky';
					halloweenLevel = true;

					var hallowTex = Paths.getSparrowAtlas('halloween_bg');

					halloweenBG = new FlxSprite(-200, -100);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					halloweenBG.antialiasing = true;
					add(halloweenBG);

					isHalloween = true;
				}
			case 'pico' | 'blammed' | 'philly':
				{
					curStage = 'philly';

					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
					bg.scrollFactor.set(0.1, 0.1);
					add(bg);

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(city);
					}

					lightFadeShader = new BuildingShaders();
					phillyCityLights = new FlxTypedGroup<FlxSprite>();
					add(phillyCityLights);

					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
						light.scrollFactor.set(0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						light.antialiasing = true;
						light.shader = lightFadeShader.shader;
						phillyCityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(streetBehind);
					}

					phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(phillyTrain);

						trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
						FlxG.sound.list.add(trainSound);
					}

					// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
					add(street);
				}

			case 'milf' | 'satin-panties' | 'high':
				{
					curStage = 'limo';
					defaultCamZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
					skyBG.scrollFactor.set(0.1, 0.1);
					add(skyBG);

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					add(bgLimo);

					grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
					add(grpLimoDancers);

					for (i in 0...5)
					{
						var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
						dancer.scrollFactor.set(0.4, 0.4);
						if (PreferencesMenu.getPref('fpslol') == false)
						{
							grpLimoDancers.add(dancer);
						}
					}

					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
					overlayShit.alpha = 0.5;
					// add(overlayShit);

					// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

					// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

					// overlayShit.shader = shaderBullshit;

					limo = new FlxSprite(-120, 550);
					limo.frames = Paths.getSparrowAtlas('limo/limoDrive');
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = true;

					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
					// add(limo);
				}
			case 'cocoa' | 'eggnog':
				{
					curStage = 'mall';

					defaultCamZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					upperBoppers = new FlxSprite(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
					upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = true;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(upperBoppers);
					}

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
					bgEscalator.antialiasing = true;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					add(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
					tree.antialiasing = true;
					tree.scrollFactor.set(0.40, 0.40);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(tree);
					}

					bottomBoppers = new FlxSprite(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
					bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = true;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(bottomBoppers);
					}

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
					fgSnow.active = false;
					fgSnow.antialiasing = true;
					add(fgSnow);

					santa = new FlxSprite(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = true;
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(santa);
					}
				}
			case 'winter-horrorland':
				{
					curStage = 'mallEvil';
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
					bg.antialiasing = true;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					add(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
					evilTree.antialiasing = true;
					evilTree.scrollFactor.set(0.2, 0.2);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(evilTree);
					}

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
					evilSnow.antialiasing = true;
					add(evilSnow);
				}
			case 'senpai' | 'roses':
				{
					curStage = 'school';

					// defaultCamZoom = 0.9;

					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
					bgSky.scrollFactor.set(0.1, 0.1);
					add(bgSky);

					var repositionShit = -200;

					var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
					bgSchool.scrollFactor.set(0.6, 0.90);
					add(bgSchool);

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
					bgStreet.scrollFactor.set(0.95, 0.95);
					add(bgStreet);

					var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
					fgTrees.scrollFactor.set(0.9, 0.9);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(fgTrees);
					}

					var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
					var treetex = Paths.getPackerAtlas('weeb/weebTrees');
					bgTrees.frames = treetex;
					bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
					bgTrees.animation.play('treeLoop');
					bgTrees.scrollFactor.set(0.85, 0.85);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(bgTrees);
					}

					var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
					treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
					treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
					treeLeaves.animation.play('leaves');
					treeLeaves.scrollFactor.set(0.85, 0.85);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(treeLeaves);
					}

					var widShit = Std.int(bgSky.width * 6);

					bgSky.setGraphicSize(widShit);
					bgSchool.setGraphicSize(widShit);
					bgStreet.setGraphicSize(widShit);
					bgTrees.setGraphicSize(Std.int(widShit * 1.4));
					fgTrees.setGraphicSize(Std.int(widShit * 0.8));
					treeLeaves.setGraphicSize(widShit);

					fgTrees.updateHitbox();
					bgSky.updateHitbox();
					bgSchool.updateHitbox();
					bgStreet.updateHitbox();
					bgTrees.updateHitbox();
					treeLeaves.updateHitbox();

					bgGirls = new BackgroundGirls(-100, 190);
					bgGirls.scrollFactor.set(0.9, 0.9);

					if (SONG.song.toLowerCase() == 'roses')
					{
						bgGirls.getScared();
					}

					bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
					bgGirls.updateHitbox();
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(bgGirls);
					}
				}
			case 'thorns':
				{
					curStage = 'schoolEvil';

					var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
					var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

					var posX = 400;
					var posY = 200;

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					add(bg);
				}
			case 'guns' | 'stress' | 'ugh':
				{
					defaultCamZoom = 0.9;

					curStage = 'tank';

					var sky:BGSprite = new BGSprite('tankSky', -400, -400, 0, 0);
					add(sky);

					var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
					clouds.active = true;
					clouds.velocity.x = FlxG.random.float(5, 15);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(clouds);
					}

					var mountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
					mountains.setGraphicSize(Std.int(mountains.width * 1.2));
					mountains.updateHitbox();
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(mountains);
					}

					var buildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.3, 0.3);
					buildings.setGraphicSize(Std.int(buildings.width * 1.1));
					buildings.updateHitbox();
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(buildings);
					}

					var ruins:BGSprite = new BGSprite('tankRuins', -200, 0, 0.35, 0.35);
					ruins.setGraphicSize(Std.int(ruins.width * 1.1));
					ruins.updateHitbox();
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(ruins);
					}

					var smokeL:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(smokeL);
					}

					var smokeR:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(smokeR);
					}

					tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(tankWatchtower);
					}

					tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5, ['BG tank w lighting'], true);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						add(tankGround);
					}

					tankmanRun = new FlxTypedGroup<TankmenBG>();
					add(tankmanRun);

					var ground:BGSprite = new BGSprite('tankGround', -420, -150);
					ground.setGraphicSize(Std.int(ground.width * 1.15));
					ground.updateHitbox();
					add(ground);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						moveTank();
					}

					var tankdude0:BGSprite = new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						foregroundSprites.add(tankdude0);
					}

					var tankdude1:BGSprite = new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						foregroundSprites.add(tankdude1);
					}

					var tankdude2:BGSprite = new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						foregroundSprites.add(tankdude2);
					}

					var tankdude4:BGSprite = new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						foregroundSprites.add(tankdude4);
					}

					var tankdude5:BGSprite = new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						foregroundSprites.add(tankdude5);
					}

					var tankdude3:BGSprite = new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']);
					if (PreferencesMenu.getPref('fpslol') == false)
					{
						foregroundSprites.add(tankdude3);
					}
				}
			default:
				{
					defaultCamZoom = 0.9;
					if (Assets.exists(Paths.hx('stages/${SONG.song.toLowerCase()}')))
					{
						{
							script = new HScript(Paths.hx('stages/${SONG.song.toLowerCase()}'));
							script.interp.variables.set("stage", this);
							script.callFunction("createStage");
						}
					}
					else
					{
						curStage = 'stage';

						bg = new BGSprite('stageback', -600, -200, 0.9, 0.9);
						add(bg);

						stageFront = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
						stageFront.updateHitbox();
						stageFront.antialiasing = true;
						stageFront.scrollFactor.set(0.9, 0.9);
						stageFront.active = false;
						add(stageFront);

						stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
						stageCurtains.updateHitbox();
						stageCurtains.antialiasing = true;
						stageCurtains.scrollFactor.set(1.3, 1.3);
						stageCurtains.active = false;
						if (PreferencesMenu.getPref('fpslol') == false)
						{
							add(stageCurtains);
						}
					}
				}
		}

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
			case 'tank':
				gfVersion = 'gf-tankmen';
		}

		if (SONG.song.toLowerCase() == 'stress')
			gfVersion = 'pico-speaker';

		if (SONG.player1 == 'bf-holding-gf' && bca == true)
			gfVersion = 'speakers';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);

		if (gfVersion == 'pico-speaker')
		{
			gf.x -= 50;
			gf.y -= 200;
			var tankmen:TankmenBG = new TankmenBG(20, 500, true);
			tankmen.strumTime = 10;
			tankmen.resetShit(20, 600, true);
			tankmanRun.add(tankmen);
			for (i in 0...TankmenBG.animationNotes.length)
			{
				if (FlxG.random.bool(16))
				{
					var man:TankmenBG = tankmanRun.recycle(TankmenBG);
					man.strumTime = TankmenBG.animationNotes[i][0];
					man.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
					tankmanRun.add(man);
				}
			}
		}

		if(gfVersion == 'speakers')
		{
		gf.y = 432;
		}

		dad = new Character(100, 100, SONG.player2);

		camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case "tankman":
				dad.y += 180;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'tank':
				gf.y += 10;
				gf.x -= 30;
				boyfriend.x += 40;
				boyfriend.y += 0;
				dad.y += 60;
				dad.x -= 80;
				if (gfVersion != 'pico-speaker')
				{
					gf.x -= 170;
					gf.y -= 75;
				}
		}

		add(gf);

		gfCutsceneLayer = new FlxTypedGroup<FlxAnimate>();
		add(gfCutsceneLayer);

		bfTankCutsceneLayer = new FlxTypedGroup<FlxAnimate>();
		add(bfTankCutsceneLayer);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);

		add(dad);
		add(boyfriend);

		add(foregroundSprites);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);

		if (PreferencesMenu.getPref('downscroll'))
			strumLine.y = FlxG.height - 150;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

		generateSong();

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

			timeBarBG = new FlxSprite(0, 0).loadGraphic(Paths.image('healthBar'));
			timeBarBG.screenCenter(X);
			timeBarBG.scrollFactor.set();
			timeBarBG.pixelPerfectPosition = true;
			
			if(PreferencesMenu.getPref("downscroll"))
				timeBarBG.y = FlxG.height - 36;
			else
				timeBarBG.y = 10;

		timeBar = new FlxBar(timeBarBG.x + 4, timeBarBG.y + 4, Std.int(timeBarBG.width - 8), Std.int(timeBarBG.height - 8), null,
        'time', 0, FlxG.sound.music.length);
    	timeBar.scrollFactor.set();
    	timeBar.createFilledBar(0xFF000000, 0xFF00FFC3);
    	timeBar.pixelPerfectPosition = true;
		timeBar.numDivisions = 300;

		healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
		healthBarBG.screenCenter(X);
		healthBarBG.scrollFactor.set();

		if (PreferencesMenu.getPref('downscroll'))
			healthBarBG.y = FlxG.height * 0.1;

		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
			'health', 0, 2);
		healthBar.scrollFactor.set();
		healthBar.createFilledBar(0xFFFF0000, 0xFF66FF33);

		if (PreferencesMenu.getPref('hc'))
			{
				// char shits for p2
				switch (SONG.player2)
				{
					case "gf":
						colorP2 = 0xFFA5004D;
					case "bf" | "bf-car" | "bf-christmas" | "bf-holding-gf":
						colorP2 = 0xFF31B0D1;
					case "bf-pixel":
						colorP2 = 0xFF7BD6F6;
					case "dad" | "parents-christmas":
						colorP2 = 0xFFAF66CE;
					case "pico":
						colorP2 = 0xFFB7D855;
					case "spooky":
						colorP2 = 0xFFD57E00;
					case "mom" | "mom-car":
						colorP2 = 0xFFD8558E;
					case "monster" | "monster-christmas":
						colorP2 = 0xFFF9FF70;
					case "senpai" | "senpai-angry":
						colorP2 = 0xFFFFAA6F;
					case "spirit":
						colorP2 = 0xFFFF3C6E;
					case "tankman":
						colorP2 = 0xFF000000;
					default:
						colorP2 = dad.health_color;
				}
	
				// char shits for p1
				switch (SONG.player1)
				{
					case "gf":
						colorP1 = 0xFFA5004D;
					case "bf" | "bf-car" | "bf-christmas" | "bf-holding-gf":
						colorP1 = 0xFF31B0D1;
					case "bf-pixel":
						colorP1 = 0xFF7BD6F6;
					case "dad" | "parents-christmas":
						colorP1 = 0xFFAF66CE;
					case "pico":
						colorP1 = 0xFFB7D855;
					case "spooky":
						colorP1 = 0xFFD57E00;
					case "mom" | "mom-car":
						colorP1 = 0xFFD8558E;
					case "monster" | "monster-christmas":
						colorP1 = 0xFFF9FF70;
					case "senpai" | "senpai-angry":
						colorP1 = 0xFFFFAA6F;
					case "spirit":
						colorP1 = 0xFFFF3C6E;
					case "tankman":
						colorP1 = 0xFF000000;
					default:
						colorP1 = boyfriend.health_color;
				}
	
				healthBar.createFilledBar(colorP2, colorP1);
			}

		if (ModifiersMenu.getPref('upd'))
		{
			camHUD.angle = 180;
			camGame.angle = 180;
		}

		if (PreferencesMenu.getPref('cst'))
		{
			scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 454, healthBarBG.y + 30, 0, "", 20);
			scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreTxt.scrollFactor.set();
			scoreTxt.cameras = [camHUD];
		}

		if (PreferencesMenu.getPref('cst') == false)
		{
			scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width - 387, healthBarBG.y + 30, 0, "", 20);
			scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			scoreTxt.scrollFactor.set();
			scoreTxt.cameras = [camHUD];
		}

		debugTxt = new FlxText(0, 0, 0, '');
		debugTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		debugTxt.scrollFactor.set();
		debugTxt.alpha = 0;
		debugTxt.screenCenter();
		debugTxt.cameras = [camHUD];

		rateingCounter = new FlxText(20, 0, 0, "", 20);
		rateingCounter.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, FlxTextAlign.LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		rateingCounter.scrollFactor.set();
		rateingCounter.cameras = [camHUD];
		rateingCounter.screenCenter(Y);

		SETxt = new FlxText(healthBarBG.x + healthBarBG.width - 920, healthBarBG.y + 30, 0, "", 20);
		SETxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		SETxt.scrollFactor.set();
		SETxt.cameras = [camHUD];

		timeTxt = new FlxText();
		timeTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		timeTxt.size = 23;
		timeTxt.x = 621.96;
		if(PreferencesMenu.getPref("downscroll") && PlayState.instance.strumLine.y != 50)
			timeTxt.y = FlxG.height - 36;
		else
			timeTxt.y = 10;

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);

		if (PreferencesMenu.getPref("ui"))
		{
			add(healthBarBG);
			add(healthBar);
			add(iconP1);
			add(iconP2);
			add(SETxt);
			add(scoreTxt);
			add(timeBarBG);
			add(timeBar);
			add(timeTxt);
			if (PreferencesMenu.getPref("rc"))
			{
				add(rateingCounter);
			}
		}

		grpNoteSplashes.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];

		timeBar.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		timeTxt.cameras = [camHUD];

		doof.cameras = [camHUD];

		startingSong = true;

		if (isStoryMode && !seenCutscene)
		{
			seenCutscene = true;

			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);

					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);

						FlxG.sound.play(Paths.sound('Lights_Turn_On'));

						camFollow.y = -2050;
						camFollow.x += 200;

						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;

							remove(blackScreen);

							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});

				case 'senpai' | 'roses' | 'thorns':
					if (PreferencesMenu.getPref('cutsenses'))
					{
						if (curSong.toLowerCase() == 'roses')
							FlxG.sound.play(Paths.sound('ANGRY'));

						schoolIntro(doof);
					}

			#if windows
				case 'ugh':
					{
						var video:MP4Handler = new MP4Handler();
						video.playMP4(Paths.video('ughCutscene'), null);
						video.is_playstate_cutscene = true;
					}

				case 'guns':
					{
						var video:MP4Handler = new MP4Handler();
						video.playMP4(Paths.video('gunsCutscene'), null);
						video.is_playstate_cutscene = true;
					}

				case 'stress':
					{
						var video:MP4Handler = new MP4Handler();
						video.playMP4(Paths.video('stressCutscene'), null);
						video.is_playstate_cutscene = true;
					}
				#end

				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();

		ready = new FlxSprite(0, 0).loadGraphic(Paths.image('ready'));
		ready.scrollFactor.set();
		ready.updateHitbox();

			if (PreferencesMenu.getPref('vos'))
				{
					ready.screenCenter();
					add(ready);
					FlxG.mouse.enabled = true;
					FlxG.mouse.visible = true;
				}
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * daPixelZoom));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += senpaiEvil.width / 5;

		camFollow.setPosition(camPos.x, camPos.y);

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
				tmr.reset(0.3);
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;

						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;

							if (senpaiEvil.alpha < 1)
								swagTimer.reset();
							else
							{
								senpaiEvil.animation.play('idle');

								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});

								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer = new FlxTimer();

	public function startCountdown():Void
	{
		inCutscene = false;

		camHUD.visible = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		
		if (PreferencesMenu.getPref('vos') == false)
	{
		startedCountdown = true;
	}
		

		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer.start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (swagCounter % gfSpeed == 0)
				gf.dance();

			if (swagCounter % 2 == 0)
			{
				if (!boyfriend.animation.curAnim.name.startsWith('sing'))
					boyfriend.playAnim('idle');
				if (!dad.animation.curAnim.name.startsWith('sing'))
					dad.dance();
			}
			else if (dad.curCharacter == 'spooky' && !dad.animation.curAnim.name.startsWith('sing'))
				dad.dance();

			if (generatedMusic)
			{
				notes.members.sort(function(Obj1:Note, Obj2:Note)
				{
					return sortNotes(FlxSort.DESCENDING, Obj1, Obj2);
				});
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (curStage.startsWith('school'))
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);

					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});

					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();

					if (curStage.startsWith('school'))
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);

					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});

					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();

					if (curStage.startsWith('school'))
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);

					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
		}, 4);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);

		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong():Void
	{
		var songData = SONG;

		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.onComplete = function()
		{
			vocalsFinished = true;
		};

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		for (section in noteData)
		{
			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
					gottaHitNote = !section.mustHitSection;

				var oldNote:Note;

				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.altNote = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength /= Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;
				}

				swagNote.mustPress = gottaHitNote;
			}
		}

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return sortNotes(FlxSort.ASCENDING, Obj1, Obj2);
	}

	function sortNotes(Sort:Int = FlxSort.ASCENDING, Obj1:Note, Obj2:Note):Int
	{
		return Obj1.strumTime < Obj2.strumTime ? Sort : Obj1.strumTime > Obj2.strumTime ? -Sort : 0;
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			var colorSwap:ColorSwap = new ColorSwap();

			babyArrow.shader = colorSwap.shader;
			colorSwap.update(Note.arrowColors[i]);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels', 'week6'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;

							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;

							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;

							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;

							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					if (Assets.exists(Paths.hx('arrows/${SONG.song.toLowerCase()}')))
					{
						{
							script = new HScript(Paths.hx('arrows/${SONG.song.toLowerCase()}'));
							script.interp.variables.set("Arrow", this);
							script.callFunction("createArrows");
						}
					}
					else
					{
						if (PreferencesMenu.getPref('DEA')) // dike engine arrows lol
							babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets_DIKE');
						else
							babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');

						babyArrow.antialiasing = true;
						babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

						switch (Math.abs(i))
						{
							case 0:
								babyArrow.x += Note.swagWidth * 0;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 1');
								babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
							case 1:
								babyArrow.x += Note.swagWidth * 1;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 2');
								babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
							case 2:
								babyArrow.x += Note.swagWidth * 2;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 4');
								babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
							case 3:
								babyArrow.x += Note.swagWidth * 3;
								babyArrow.animation.addByPrefix('static', 'arrow static instance 3');
								babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
								babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
						}
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
			{
				playerStrums.add(babyArrow);
			}

			babyArrow.animation.play('static');
			babyArrow.x += 90;
			babyArrow.x += ((FlxG.width / 2) * player);

			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	#if desktop
	override public function onFocus():Void
	{
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}

		super.onFocus();
	}

	override public function onFocusLost():Void
	{
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}

		super.onFocusLost();
	}
	#end

	function resyncVocals():Void
	{
		if (!_exiting)
		{
			vocals.pause();

			FlxG.sound.music.play();
			Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;

			if (!vocalsFinished)
			{
				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}
	}

	public var paused:Bool = false;

	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var cameraRightSide:Bool = false;

	override public function update(elapsed:Float)
	{
		FlxG.camera.followLerp = CoolUtil.camLerpShit(0.04);

		// googy ahh event stuff
		if (camshake)
		{
			camHUD.shake(0.01);
			camGame.shake(0.01);
		}

		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;

				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
			Conductor.songPosition += FlxG.elapsed * 1000;

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}

				lightFadeShader.update(1.5 * (Conductor.crochet / 1000) * FlxG.elapsed);
			case 'tank':
				moveTank();
		}

		super.update(elapsed);
		if (PreferencesMenu.getPref('vos'))
			{
				if (FlxG.keys.justPressed.ANY)
					{
						ready.alpha = 0;
						startedCountdown = true;
					}
				if (FlxG.mouse.overlaps(ready) && FlxG.mouse.justPressed)
					{
						ready.alpha = 0;
						startedCountdown = true;
					}
			}

		if (ModifiersMenu.getPref('insane'))
		{
			camHUD.angle += 10 * (60.0 / Main.fpsCounter.currentFPS);
			camGame.angle += 10 * (60.0 / Main.fpsCounter.currentFPS);
			camGame.zoom += 1000 * (60.0 / Main.fpsCounter.currentFPS);
			camGame.zoom -= 1000 * (60.0 / Main.fpsCounter.currentFPS);
			camHUD.zoom += 1000 * (60.0 / Main.fpsCounter.currentFPS);
			camHUD.zoom -= 1000 * (60.0 / Main.fpsCounter.currentFPS);
		}



		if (PreferencesMenu.getPref('cst'))
		{
			if (misses == 0)
				scoreTxt.text = 'Score:' + songScore  + ' | Misses:' + misses + ' Combo Breaks:' + cb + ' | FC'; // score misss and combo info
			else if (misses > 0 && misses < 5)
				scoreTxt.text = 'Score:' + songScore + ' | Misses:' + misses + ' Combo Breaks:' + cb + ' | NFC'; // nearly fc
			else if (misses > 4 && misses < 10)
				scoreTxt.text = 'Score:' + songScore + ' | Misses:' + misses + ' Combo Breaks:' + cb + ' | NB';
			else if (misses > 9 && misses < 20)
				scoreTxt.text = 'Score:' + songScore  + ' | Misses:' + misses + ' Combo Breaks:' + cb + ' | PGBNTB'; // PRETTY GOOD BUT NOT THE BEST
			else
				scoreTxt.text = 'Score:' + songScore + ' | Misses:' + misses + ' Combo Breaks:' + cb + ' | F'; // fail

			if (PreferencesMenu.getPref('ops'))
				if (misses == 0)
					scoreTxt.text = 'Score:' + songScore + ' | Misses:' + misses + ' Combo Breaks:' + cb + ' | FC' + ' | ' + SONG.player2 + 's Score:' +
						dadScore; // score and misss info
				else if (misses > 0 && misses < 5)
					scoreTxt.text = 'Score:' + songScore + ' | Misses:' + misses + ' Combo Breaks:' + cb + ' | NFC' + ' | ' + SONG.player2 + 's Score:'
						+ dadScore; // nearly fc
				else if (misses > 4 && misses < 10)
					scoreTxt.text = 'Score:' + songScore + combo + ' | Misses:' + misses + ' Combo Breaks:' + cb + ' | ' + SONG.player2 + 's Score:' + dadScore;
				else if (misses > 9 && misses < 20)
					scoreTxt.text = 'Score:' + songScore + ' | Misses:' + misses + ' Combo Breaks:' + cb + ' | PGBNTB' + ' | ' + SONG.player2 + 's Score:'
						+ dadScore; // PRETTY GOOD BUT NOT THE BEST
				else
					scoreTxt.text = 'Score:' + songScore + ' | Misses:' + misses + ' Combo Breaks:' + cb + ' | F' + ' | ' + SONG.player2 + 's Score:' +
						dadScore; // fail
		}

		if (ModifiersMenu.getPref('pm'))
		{
			if (misses > 0 && misses < 5)
				health -= 10;
		}

		if (!PreferencesMenu.getPref('cst'))
		{
			scoreTxt.text = 'Score:' + songScore + ' | Misses:' + misses;
		}

		rateingCounter.text = 'Combo: '+ combo + '\nSicks: ' + sicks + '\nGoods: ' + goods + '\nBads: ' + bads + '\nShits: ' + shits + '\nso this is basicly so shit shows up';

		if (PreferencesMenu.getPref('censor-naughty'))
		{
			rateingCounter.text = 'Combo: '+ combo + '\nSicks: ' + sicks + '\nGoods: ' + goods + '\nBads: ' + bads + '\nOofs: ' + oofs + '\nso this is basicly so oof shows up';
		}

		if (ModifiersMenu.getPref('pm'))
		{
			if (misses > 0 && misses < 5)
				health -= 10;
		}

		Application.current.window.title = 'Friday Night Funkin Dike Engine ' + SONG.song + ' - ' + storyDifficultyText;

		time = Conductor.songPosition;
		timeBar.value = time;

		if (!PreferencesMenu.getPref('wm'))
			SETxt.text = SONG.song + ' - ' + storyDifficultyText + ' | Week ' + storyWeek + ' ';
		else
			SETxt.text = 'Dike Engine | ' + ver + ' | ' + SONG.song + ' - ' + storyDifficultyText + ' | Week ' + storyWeek;

		timeTxt.text = FlxStringUtil.formatTime((FlxG.sound.music.length - FlxMath.bound(time, 0)) / 1000, false);

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
			{
				var screenPos:FlxPoint = boyfriend.getScreenPosition();
				var pauseMenu:PauseSubState = new PauseSubState(screenPos.x, screenPos.y);
				openSubState(pauseMenu);
				pauseMenu.camera = camHUD;
			}

			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

if (PreferencesMenu.getPref('dm'))
	{
		if (FlxG.keys.justPressed.F7)
		{
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		if (FlxG.keys.justPressed.F5)
		{
			FlxG.switchState(new AnimationDebug(SONG.player2));

			#if desktop
			DiscordClient.changePresence("Animation Debug", SONG.player2, null, true);
			#end
		}

		if (FlxG.keys.justPressed.F6)
		{
			FlxG.switchState(new AnimationDebug(SONG.player1));

			#if desktop
			DiscordClient.changePresence("Animation Debug", SONG.player1, null, true);
			#end
		}
		if (FlxG.keys.justPressed.F8)
		{
			debugTxt.alpha = 1;
		}
	}

		iconP1.scale.set(CoolUtil.coolLerp(iconP1.scale.x, 1, 0.15), CoolUtil.coolLerp(iconP1.scale.y, 1, 0.15));
		iconP2.scale.set(CoolUtil.coolLerp(iconP2.scale.x, 1, 0.15), CoolUtil.coolLerp(iconP2.scale.y, 1, 0.15));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		if (health > 2)
			health = 2;

		if (healthBar.percent < 20)
			iconP1.animation.curAnim.curFrame = 1;
		else
			iconP1.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			iconP2.animation.curAnim.curFrame = 1;
		else
			iconP2.animation.curAnim.curFrame = 0;

		
		//winning icon stuff lol this took like two mins tbh
	if (PreferencesMenu.getPref('wi'))
		{
			if (healthBar.percent < 20){
				iconP1.animation.curAnim.curFrame = 1;
				iconP2.animation.curAnim.curFrame = 2;
			}
			else if (healthBar.percent > 80){
				iconP1.animation.curAnim.curFrame = 2;
				iconP2.animation.curAnim.curFrame = 1;
			}
			else{
				iconP1.animation.curAnim.curFrame = 0;
				iconP2.animation.curAnim.curFrame = 0;
		}
	}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			cameraRightSide = PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection;
			cameraMovement();
		}

		if (camZooming)
		{
			FlxG.camera.zoom = CoolUtil.coolLerp(FlxG.camera.zoom, defaultCamZoom, 0.05);
			camHUD.zoom = CoolUtil.coolLerp(camHUD.zoom, 1, 0.05);
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		switch (curSong.toLowerCase())
		{
			case "fresh":
				switch (curBeat)
				{
					case 16:
						camZooming = true;
						gfSpeed = 2;
					case 48:
						gfSpeed = 1;
					case 80:
						gfSpeed = 2;
					case 112:
						gfSpeed = 1;
				}
			case "bopeebo":
				switch (curBeat)
				{
					case 128, 129, 130:
						vocals.volume = 0;
				}
		}

		// better streaming of shit

		if (!inCutscene && !_exiting)
		{
			// RESET = Quick Game Over Screen
			if (controls.RESET)
				health = 0;

			if (health <= 0 && !practiceMode)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				deathCounter += 1;

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if desktop
				// Game Over doesn't get its own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
				#end
			}
		}

		while (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1800 / SONG.speed)
			{
				var dunceNote:Note = unspawnNotes[0];
				notes.add(dunceNote);

				unspawnNotes.shift();
			}
			else
				break;
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				var center = strumLine.y + (Note.swagWidth / 2);
				var strum:FlxSprite;

				if (daNote.mustPress)
					strum = playerStrums.members[daNote.noteData % playerStrums.length];
				else
					strum = strumLineNotes.members[daNote.noteData % Std.int(strumLineNotes.length / 2)];

				daNote.x = strum.x;

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width;

					if (curStage.startsWith('school'))
						daNote.x -= 15;
				}

				// i am so fucking sorry for these if conditions
				if (PreferencesMenu.getPref('downscroll'))
				{
					daNote.y = strumLine.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);

					if (daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
							daNote.y += daNote.prevNote.height;
						else
							daNote.y += daNote.height / 2;

						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;

							daNote.clipRect = swagRect;
						}
					}
				}
				else
				{
					daNote.y = strumLine.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);

					if (daNote.isSustainNote
						&& daNote.y + daNote.offset.y * daNote.scale.y <= center
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
						swagRect.y = (center - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song.toLowerCase() != 'tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim)
							altAnim = '-alt';
					}

					if (daNote.altNote)
						altAnim = '-alt';

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							dad.playAnim('singLEFT' + altAnim, true);
						case 1:
							dad.playAnim('singDOWN' + altAnim, true);
						case 2:
							dad.playAnim('singUP' + altAnim, true);
						case 3:
							dad.playAnim('singRIGHT' + altAnim, true);
					}

					dad.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
					dadScore += 100;

					if (ModifiersMenu.getPref('hpd'))
						health -= 0.01;

					if (health < 0.02)
						health = 0.01;

		if (PreferencesMenu.getPref('events'))
			{
				if (SONG.player2 == 'tankman')
				{
					if (daNote.altNote)
					{
						camshake = true;
						if (SONG.song.toLowerCase() == 'stress')
						trace('UGH PRETTY GOOD');

						var ugh_timer = new haxe.Timer(12);
						ugh_timer.run = function()
						camshake = false;

						if (SONG.song.toLowerCase() == 'ugh')
						trace('UGH');

						var ugh_timer = new haxe.Timer(12);
						ugh_timer.run = function()
						camshake = false;
					}
				}
			}
		}

				var doKill = Conductor.songPosition > daNote.strumTime + Conductor.safeZoneOffset;

				if (doKill)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
					if(combo > 9){
						cb += 1;
					}
						
					if (PreferencesMenu.getPref('smoothie')){
						smoothHealth(-0.0475);
					}
					else {
						health -= 0.0475;
					}
						combo = 0;
						misses += 1;
						songScore -= 10;
						vocals.volume = 0;

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
			}
		});

			if (!inCutscene)
				keyShit();

		if (PreferencesMenu.getPref('dm'))
			if (FlxG.keys.justPressed.F1)
				endSong();
		}
	}

	var endingSong:Bool = false;

	function endSong():Void
	{
		bca = true;
		seenCutscene = false;
		deathCounter = 0;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;

		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficultyText);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				if (storyWeek == 7)
					FlxG.switchState(new VideoState());
				else
					FlxG.switchState(new StoryMenuState());

				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficultyText);

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else if (SONG.song.toLowerCase() == 'stress')
			{
				var video:MP4Handler = new MP4Handler();
				video.playMP4(Paths.video('kickstarterTrailer'), new PlayState());
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficultyText.toLowerCase() != "normal")
					difficulty += '-${storyDifficultyText.toLowerCase()}';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				FlxG.sound.music.stop();
				vocals.stop();

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'), 1, false, null, true, function()
					{
						PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
						LoadingState.loadAndSwitchState(new PlayState());
					});
				}
				else
				{
					prevCamFollow = camFollow;

					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);

					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	private function popUpScore(strumtime:Float, daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";
		var doSplash:Bool = true;

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			if (PreferencesMenu.getPref('censor-naughty'))
			{
				daRating = 'oof';
				oofs += 1;
			}
			else
				daRating = 'shit';
			shits += 1;
			score = 50;
			doSplash = false;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';

			bads += 1;
			score = 100;
			doSplash = false;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			goods += 1;
			score = 200;
			doSplash = false;
		}

		if (Assets.exists(Paths.hx('rateings/${SONG.song.toLowerCase()}')))
		{
			{
				script = new HScript(Paths.hx('rateings/${SONG.song.toLowerCase()}'));
				script.interp.variables.set("rate", this);
				script.callFunction("createRateings");
			}
		}

		if (doSplash)
		{
			sicks += 1;
		}
		if (PreferencesMenu.getPref('ns'))
			if (doSplash)
			{
				var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
				splash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
				grpNoteSplashes.add(splash);
			}

		if (!practiceMode)
			songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			pixelShitPart1 = 'weeb/pixelUI/';
			pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		if (combo > 10)
			{
				add(comboSpr);
			}

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function cameraMovement():Void
	{
		if (camFollow.x != dad.getMidpoint().x + 150 && !cameraRightSide)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

			switch (dad.curCharacter)
			{
				case 'mom':
					camFollow.y = dad.getMidpoint().y;
				case 'senpai' | 'senpai-angry':
					camFollow.y = dad.getMidpoint().y - 430;
					camFollow.x = dad.getMidpoint().x - 100;
			}

			if (dad.curCharacter == 'mom')
				vocals.volume = 1;

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				tweenCamIn();
			}
		}

		if (cameraRightSide && camFollow.x != boyfriend.getMidpoint().x - 100)
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
			}
		}
	}

	private function keyShit():Void
	{
		var holdingArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		var controlArray:Array<Bool> = [
			controls.NOTE_LEFT_P,
			controls.NOTE_DOWN_P,
			controls.NOTE_UP_P,
			controls.NOTE_RIGHT_P
		];
		var releaseArray:Array<Bool> = [
			controls.NOTE_LEFT_R,
			controls.NOTE_DOWN_R,
			controls.NOTE_UP_R,
			controls.NOTE_RIGHT_R
		];

		// FlxG.watch.addQuick('asdfa', upP);
		if (holdingArray.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdingArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}
		if (controlArray.contains(true) && generatedMusic)
		{
			boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			var removeList:Array<Note> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					if (ignoreList.contains(daNote.noteData))
					{
						for (possibleNote in possibleNotes)
						{
							if (possibleNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - possibleNote.strumTime) < 10)
							{
								removeList.push(daNote);
							}
							else if (possibleNote.noteData == daNote.noteData && daNote.strumTime < possibleNote.strumTime)
							{
								possibleNotes.remove(possibleNote);
								possibleNotes.push(daNote);
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						ignoreList.push(daNote.noteData);
					}
				}
			});

			for (badNote in removeList)
			{
				badNote.kill();
				notes.remove(badNote, true);
				badNote.destroy();
			}

			possibleNotes.sort(function(note1:Note, note2:Note)
			{
				return Std.int(note1.strumTime - note2.strumTime);
			});

			if (possibleNotes.length > 0)
			{
				for (i in 0...controlArray.length)
				{
					if (controlArray[i] && !ignoreList.contains(i))
					{
						badNoteHit();
					}
				}
				for (possibleNote in possibleNotes)
				{
					if (controlArray[possibleNote.noteData])
					{
						goodNoteHit(possibleNote);
					}
				}
			}
			else
				badNoteHit();
		}

		if (boyfriend.holdTimer > 0.004 * Conductor.stepCrochet
			&& !holdingArray.contains(true)
			&& boyfriend.animation.curAnim.name.startsWith('sing')
			&& !boyfriend.animation.curAnim.name.endsWith('miss'))
		{
			boyfriend.playAnim('idle');
		}

		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (!holdingArray[spr.ID])
				spr.animation.play('static');

			if ((spr.animation.curAnim == null || spr.animation.curAnim.name != 'confirm') || curStage.startsWith('school'))
				spr.centerOffsets();
			else
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
		});
	}
					
	function smoothHealth(amount:Float) {
		tweenHealth.cancel();
		tweenHealth = FlxTween.num(health, health + amount, 0.1, {ease: FlxEase.cubeInOut}, function(v:Float)
			{
				health = v;
			});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;

			if (!practiceMode)
				songScore -= 10;

			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');

			boyfriend.stunned = true;

			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			switch (direction)
			{
				case 0:
					boyfriend.playAnim('singLEFTmiss', true);
				case 1:
					boyfriend.playAnim('singDOWNmiss', true);
				case 2:
					boyfriend.playAnim('singUPmiss', true);
				case 3:
					boyfriend.playAnim('singRIGHTmiss', true);
			}
		}
	}

	function badNoteHit()
	{
		var leftP = controls.NOTE_LEFT_P;
		var downP = controls.NOTE_DOWN_P;
		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;

		if (PreferencesMenu.getPref('gt') == false) // ghost tapping
			// if (PreferencesMenu.getPref('bp') == false)
		{
			if (leftP)
				noteMiss(0);
			boyfriend.playAnim('singLEFTmiss', true);
			if (downP)
				noteMiss(1);
			boyfriend.playAnim('singDOWNmiss', true);
			if (upP)
				noteMiss(2);
			boyfriend.playAnim('singUPmiss', true);
			if (rightP)
				noteMiss(3);
			boyfriend.playAnim('singRIGHTmiss', true);

			if(combo > 9){
				cb += 1;
			}
			misses += 1;
			combo = 0;
			songScore -= 20;
		}
	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note);
				combo += 1;
			}

			if (note.noteData >= 0) {
				
				if (PreferencesMenu.getPref('smoothie')) {
					smoothHealth(0.023);
				}
				else {
					health += 0.023;
			     	}
				else(!note.noteData == 0) {
					health += 0.004;
				}


			switch (note.noteData)
			{
				case 0:
					boyfriend.playAnim('singLEFT', true);
				case 1:
					boyfriend.playAnim('singDOWN', true);
				case 2:
					boyfriend.playAnim('singUP', true);
				case 3:
					boyfriend.playAnim('singRIGHT', true);
			}

			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var tankResetShit:Bool = false;
	var tankMoving:Bool = false;
	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankX:Float = 400;

	function moveTank():Void
	{
		if (!inCutscene)
		{
			tankAngle += tankSpeed * FlxG.elapsed;
			tankGround.angle = (tankAngle - 90 + 15);
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (PreferencesMenu.getPref('fpslol') == false)
		{
			if (trainSound.time >= 4700)
			{
				startedMoving = true;
				gf.playAnim('hairBlow');
			}
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
		if (PreferencesMenu.getPref('fpslol') == false)
		{
			{
				gf.playAnim('hairFall');
				phillyTrain.x = FlxG.width + 200;
				trainMoving = false;
				// trainSound.stop();
				// trainSound.time = 0;
				trainCars = 8;
				trainFinishing = false;
				startedMoving = false;
			}
		}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
	if (PreferencesMenu.getPref('events'))
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
		if (Assets.exists(Paths.hx('events/${SONG.song.toLowerCase()}')))
		{
			{
				script = new HScript(Paths.hx('events/${SONG.song.toLowerCase()}'));
				script.interp.variables.set("events", this);
				script.callFunction("createEvent");
			}
			if (Assets.exists(Paths.hx('events/${SONG.song.toLowerCase()}, - ${storyDifficultyText}')))
			{
				{
					script = new HScript(Paths.hx('events/${SONG.song.toLowerCase()}, - ${storyDifficultyText}'));
					script.interp.variables.set("events", this);
					script.callFunction("createEvent");
				}
			}
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

		if (generatedMusic)
		{
			notes.members.sort(function(note1:Note, note2:Note)
			{
				return sortNotes(FlxSort.DESCENDING, note1, note2);
			});
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			// if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
			// 	dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (PreferencesMenu.getPref('camera-zoom'))
		{
			// HARDCODING FOR MILF ZOOMS!
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (curBeat % 2 == 0)
		{
			if (!boyfriend.animation.curAnim.name.startsWith("sing"))
			{
				boyfriend.playAnim('idle');
			}

			if (!dad.animation.curAnim.name.startsWith("sing"))
			{
				dad.dance();
			}
		}
		else if (dad.curCharacter == 'spooky')
		{
			if (!dad.animation.curAnim.name.startsWith("sing"))
			{
				dad.dance();
			}
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		foregroundSprites.forEach(function(spr:BGSprite)
		{
			spr.dance();
		});

		switch (curStage)
		{
			case 'tank':
				tankWatchtower.dance();
			case 'school':
				bgGirls.dance();

			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();

			case "philly":
				if (PreferencesMenu.getPref('fpslol') == false)
				{
					if (!trainMoving)
						trainCooldown += 1;

					if (curBeat % 4 == 0)
					{
						lightFadeShader.reset();

						phillyCityLights.forEach(function(light:FlxSprite)
						{
							light.visible = false;
						});

						curLight = FlxG.random.int(0, phillyCityLights.length - 1);

						phillyCityLights.members[curLight].visible = true;
						// phillyCityLights.members[curLight].alpha = 1;
					}

					if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
					{
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;

	var colorP2:Int;

	var colorP1:Int;
}
