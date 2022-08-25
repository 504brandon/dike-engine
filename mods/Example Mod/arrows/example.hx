// create your Stage in this lmao
function createStage() {
	arrow_left = new BGSprite('arrows/Example', -600, -200, 0.9, 0.9, ['arrow static instance 1'], true);
	arrow_left.animation.play('idle', true);
	PlayState.instance.add(arrow_left);
}