import funkin.backend.MusicBeatState;

var bg:FlxSprite;

function create() {
    if (WHITE_FADE) {
        bg = new FunkinSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
        bg.zoomFactor = 0;
        bg.scrollFactor.set();
        bg.alpha = 1;
        add(bg);

        FlxTween.tween(bg, {alpha: 0}, 0.35, {ease: FlxEase.cineOut});
    }
}

function destroy() {
    if (bg != null)
        FlxTween.cancelTweensOf(bg);
}