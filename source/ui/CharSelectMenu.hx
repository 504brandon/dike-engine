package ui;
import BGSprite;
import flixel.FlxObject;
import flixel.FlxSprite;
#if desktop
import Discord.DiscordClient;
#end
import flixel.FlxG;

var Boyguy:Int = 0;

class CharSelectMenu extends MusicBeatState
{
	var bf:FlxSprite;
    var tankman:FlxSprite;
    var pico:FlxSprite;
    public static var bfver:String = 'bf';

 override function create(){
    var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback', 'shared'));
    bg.antialiasing = true;
    bg.scrollFactor.set(0.9, 0.9);
    bg.active = false;
    add(bg);

    var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront', 'shared'));
    stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
    stageFront.updateHitbox();
    stageFront.antialiasing = true;
    stageFront.scrollFactor.set(0.9, 0.9);
    stageFront.active = false;
    add(stageFront);

    var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains', 'shared'));
    stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
    stageCurtains.updateHitbox();
    stageCurtains.antialiasing = true;
    stageCurtains.scrollFactor.set(1.3, 1.3);
    stageCurtains.active = false;

    add(stageCurtains);

            bf = new FlxSprite(0, 0);
			bf.frames = Paths.getSparrowAtlas('characters/BOYFRIEND', 'shared');
			bf.animation.addByPrefix('idle', 'BF idle dance', 24, false);
			add(bf);
            bf.screenCenter();
            bf.flipX = true;


            pico = new FlxSprite(0, 0);
			pico.frames = Paths.getSparrowAtlas('characters/Pico_FNF_assetss', 'shared');
			pico.animation.addByPrefix('idle', 'Pico Idle Dance', 24, false);
			add(pico);
            pico.screenCenter();
            pico.flipX = true;

            tankman = new FlxSprite(0, 0);
			tankman.frames = Paths.getSparrowAtlas('characters/tankmanCaptain', 'shared');
			tankman.animation.addByPrefix('idle', 'Tankman Idle Dance instance 1', 24, false);
			add(tankman);
            tankman.screenCenter();
            tankman.flipX = false;

            bf.animation.play('idle', true);
            pico.animation.play('idle', true);
            tankman.animation.play('idle', true);
        }

        function select() {
            switch(Boyguy){
    
            case 0:
                bf.alpha = 1;
                pico.alpha = 0;
                tankman.alpha = 0;
                bfver = 'bf';

            case 1:
                pico.alpha = 1;
                bf.alpha = 0;
                tankman.alpha = 0;
                bfver = 'pico';

            case 2:
                tankman.alpha = 1;
                pico.alpha = 0;
                bf.alpha = 0;
                bfver = 'tankman';
    
        }
    }

  override public function update(elapsed:Float){

    if(FlxG.keys.justPressed.RIGHT) {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        Boyguy += 1;
        select();
    }
    if(FlxG.keys.justPressed.LEFT) {
        FlxG.sound.play(Paths.sound('scrollMenu'));
        Boyguy -= 1;
        select();
    }

        if (FlxG.keys.justPressed.ESCAPE)
            {
			FlxG.switchState(new OptionsState());
            trace("left char state");
            }

    super.update(elapsed);
       if(Boyguy > 3)
        Boyguy = 3;

       if(Boyguy < 0)
        Boyguy = 0;
    }
}