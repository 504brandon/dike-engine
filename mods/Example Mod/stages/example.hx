// create your Stage in this lmao
function createStage() {
                        bg = new BGSprite('stageback', -600, -200, 0.9, 0.9);
						PlayState.instance.add(bg);

						stageFront = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
						stageFront.updateHitbox();
						stageFront.antialiasing = true;
						stageFront.scrollFactor.set(0.9, 0.9);
						PlayState.instance.add(stageFront);

						stageCurtains = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
						stageCurtains.updateHitbox();
						stageCurtains.antialiasing = true;
						stageCurtains.scrollFactor.set(1.3, 1.3);
						stageCurtains.active = false;

						PlayState.instance.add(stageCurtains);
}