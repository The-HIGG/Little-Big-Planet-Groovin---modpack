import flixel.util.FlxAxes;

import funkin.editors.charter.Charter;
import funkin.backend.utils.CoolUtil.CoolSfx;
import funkin.backend.MusicBeatState;

var bg:FlxSprite;
var camera:FlxCamera;

var hang:FlxSprite;

var playingTxt:FlxText;
var sequence:FlxSprite;

var items:Array<String> = ["resume", "retry", "exit"];
var exiting:Bool = false;

var curSelected(default, set):Int = -1;
function set_curSelected(selected:Int) {
    CoolUtil.playMenuSFX(CoolSfx.SCROLL, .8);
    if(curSelected != selected) {
        buttons.forEachAlive(function(spr:FlxSpriteGroup) {
            spr.members[0].animation.play(spr.ID == selected ? "hover" : "idle", true);
            if(spr.ID != selected) {
                spr.members[1].animation.finish();
                spr.members[1].animation.stop();
            } else
                spr.members[1].animation.play("idle", true);
        });
    }
    return curSelected = selected;
}

var buttons:FlxSpriteGroup;

function create(e) {
    e.cancel();

    FlxG.sound.play(Paths.sound("scroll down"), Options.volumeSFX);

    camera = new FlxCamera();
    camera.bgColor = PlayState.instance.camHUD.bgColor;

    FlxG.cameras.add(camera, false);
	cameras = [camera];

    bg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    bg.alpha = 0;
    add(bg);

    hang = new FlxSprite().loadGraphic(Paths.image("pause/hang-thingy"));
    setup(hang);
    hang.y -= 100;
    add(hang);

    playingTxt = new FlxText(0,200);
    playingTxt.text = "Now playing ~ " + PlayState.SONG.meta.displayName;
    playingTxt.setFormat(Paths.font("Eigerdals Heavy.OTF"),30, 0xFFFFFFFF, 'center');
    playingTxt.screenCenter(FlxAxes.X);
    add(playingTxt);

    sequence = new FlxSprite();
    sequence.frames = Paths.getFrames("pause/musicSequencer");
    sequence.animation.addByPrefix("idle", "musicSequencer " + PlayState.SONG.meta.displayName.toLowerCase(), 12, true);
    sequence.animation.play("idle", true);
    setup(sequence);
    sequence.y += 250;
    add(sequence);

    buttons = new FlxSpriteGroup();
    buttons.antialiasing = Options.antialiasing;

    for (n => i in items) {
        var buttonGrp = new FlxSpriteGroup(0, sequence.y + (sequence.height * .745));
        buttonGrp.antialiasing = Options.antialiasing;
        buttonGrp.ID = n;

        var button = new FlxSprite();
        button.frames = Paths.getFrames("pause/pauseButtons");
        button.animation.addByPrefix("idle", "pauseButtons buttonidle", 12, true);
        button.animation.addByPrefix("hover", "pauseButtons buttonhover", 12, true);
        button.animation.play("idle", true);
        button.antialiasing = Options.antialiasing;

        var txt = new FlxSprite();
        txt.frames = Paths.getFrames("pause/pauseButtons");
        txt.animation.addByPrefix("idle", "pauseButtons " + i, 12, true);
        txt.animation.play("idle", true);
        txt.antialiasing = Options.antialiasing;

        buttonGrp.add(button);
        buttonGrp.add(txt);

        setup(buttonGrp);

        if(n == 0)
            buttonGrp.x -= (buttonGrp.width * .5) + 110;
        if(n == 1)
            buttonGrp.x -= (30);
        if(n == 2) {
            buttonGrp.y += (buttonGrp.height * .8);
            buttonGrp.x -= (buttonGrp.width * .4);
        }

        buttons.add(buttonGrp);
    }

    add(buttons);
    curSelected = 0;

	FlxTween.tween(bg, {alpha: .35}, 0.75, {ease: FlxEase.elasticOut});
    for(spr in [hang, playingTxt, sequence, buttons]) {
        spr.antialiasing = Options.antialiasing;
        spr.y -= 200;
        spr.alpha = 0;
	    FlxTween.tween(spr, {alpha: 1}, 0.7, {ease: FlxEase.quartOut});
	    FlxTween.tween(spr, {y: spr.y + 200}, 0.75, {ease: FlxEase.quartOut});
    }
}

function setup(spr:FlxSprite) {
    spr.scale.set(.785, .785);
    spr.updateHitbox();
    spr.screenCenter(FlxAxes.X);
}

function update(elapsed:Float) {
    if (exiting)
        return;
    else if(controls.RIGHT_P || controls.LEFT_P)
        curSelected = ((curSelected == 2 && controls.LEFT_P) || curSelected == 1) ? 0 : 1;
    else if(controls.DOWN_P || controls.UP_P)
        curSelected = curSelected != 2 ? 2 : 0;
    else if(controls.ACCEPT)
        accept(items[curSelected]);
    else if(controls.BACK)
        resume();
}

function accept(option:String) {
    if(option == "resume")
        resume();
    else if(option == "retry") {
        parentDisabler.reset();
		game.registerSmoothTransition();
		FlxG.resetState();
    }
    else if(option == "exit") {
        if (PlayState.chartingMode && Charter.undos.unsaved)
            game.saveWarn(false);
        else {
            exiting = true;
            WHITE_FADE = true;
            if (Charter.instance != null) Charter.instance.__clearStatics();

            // prevents certain notes to disappear early when exiting  - Nex
            game.strumLines.forEachAlive(function(grp) grp.notes.__forcedSongPos = Conductor.songPosition);

            FlxG.sound.play(Paths.sound("scroll up"), 0.5);
            FlxG.sound.play(Paths.sound("song_leave"), 1);

            FlxTween.tween(PlayState.instance.camHUD, {alpha: 0}, 1.1, {ease: FlxEase.circOut});
            FlxTween.cancelTweensOf(bg);
            FlxTween.tween(PlayState.instance.camGame, {zoom: PlayState.instance.camGame.zoom + 0.2}, 1.4, {ease: FlxEase.quadOut});
            FlxTween.tween(bg, {alpha: 0}, 0.4, {ease: FlxEase.circOut});

            bg2 = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
            bg2.alpha = 0;
            add(bg2);

            FlxTween.tween(bg2, {alpha: 1}, 0.85, {ease: FlxEase.circOut});

            pauseMusic.stop();

            var height:Float = hang.height * 1.1;
            for(spr in [hang, playingTxt, sequence, buttons]) {
                FlxTween.cancelTweensOf(spr);
                FlxTween.tween(spr, {y: spr.y - height}, 0.9, {ease: FlxEase.circOut});
            }

            new FlxTimer().start(1.5, (_) -> {
                IN_MENU = true;
                if (PlayState.SONG.meta.name != "Creatune")
                    PlayState.loadSong("Creatune");
                MusicBeatState.skipTransIn = true;
                MusicBeatState.skipTransOut = true;
                FlxG.switchState(new PlayState());
            });
        }
    }
}

function resume() {
    PlayState.instance.vocals.time = FlxG.sound.music.time;
    close();
}

function destroy() if (FlxG.cameras.list.contains(camera))
	FlxG.cameras.remove(camera);