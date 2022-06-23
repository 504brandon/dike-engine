// create your character in this lmao
function createCharacter() {
    character.frames = Paths.getSparrowAtlas("characters/DADDY_DEAREST");
    
    character.quickAnimAdd('idle', 'Dad idle dance');
    character.quickAnimAdd('singUP', 'Dad Sing Note UP');
    character.quickAnimAdd('singRIGHT', 'Dad Sing Note RIGHT');
    character.quickAnimAdd('singDOWN', 'Dad Sing Note DOWN');
    character.quickAnimAdd('singLEFT', 'Dad Sing Note LEFT');

    character.loadOffsetFile('dad');

    character.playAnim('idle');

    character.health_color = 0xFF838383;
}

// cool little alpha effect, can disable if you want :D
var alpha_timer = 0.0;

function update(elapsed) {
    alpha_timer += elapsed;

    character.alpha = (Math.sin(alpha_timer * 2.5) * 0.5) + 0.5;
}