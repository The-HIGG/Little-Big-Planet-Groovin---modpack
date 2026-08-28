// This code is super old and I hate it, but I'll make it work to push it out for relase on late July! (July 25th | 11:50 pm rn btw)

import funkin.backend.MusicBeatState;
import funkin.backend.system.Flags;
import funkin.game.GameOverSubstate;

import flixel.FlxObject;
import flixel.camera.FlxCameraFollowStyle;

using StringTools;

var poppit:FunkinSprite;
var boyfriend:Character;
var canControl, reverse = false;

CoolUtil.playMusic(Paths.music(gameOverSong), false, 0, true, Flags.DEFAULT_BPM);
var grunt:FlxSound;


function create(e) {
    e.cancel();
    __cancelDefault = true;

    grunt = FlxG.sound.load(Paths.sound("gameover/grunt"), 0);
    grunt.play();

    boyfriend = new Character(PlayState.instance.boyfriend.x, PlayState.instance.boyfriend.y, Flags.DEFAULT_GAMEOVER_CHARACTER, false);
    add(boyfriend);

    poppit = new FunkinSprite(boyfriend.x - boyfriend.width + 200, boyfriend.y - boyfriend.height * 0.5, Paths.image("game/popit"));
    poppit.antialiasing = Options.antialiasing;
    poppit.animation.addByPrefix("intro", "popit popin", 24, false);
    poppit.animation.addByPrefix("loop", "popit loop", 24, true);
    poppit.animation.addByPrefix("pop", "popit popout", 24, false);
    poppit.visible = false;
    add(poppit);

    new FlxTimer().start(0.5, () -> {
        poppit.visible = true;
        poppit.animation.play("intro", true);

        FlxG.sound.play(Paths.sound("gameover/drop"), 1);
    });

    new FlxTimer().start(0.4, () -> {
        FlxG.sound.play(Paths.sound("gameover/poppit_open"), 0.75);
        FlxG.sound.play(Paths.sound("gameover/chud bf noises"), 1);
    });


    poppit.animation.finishCallback = (name:String) -> {
        switch (name) {
            case "intro":
                poppit.animation.play("loop", true);
        }
    }

    camFollowMenu = new FlxObject(0, 0, 2, 2);
	add(camFollowMenu);
    var pos = boyfriend.getCameraPosition();
    camFollowMenu.setPosition(pos.x, pos.y);
    camera.follow(camFollowMenu, FlxCameraFollowStyle.LOCKON, 0.05);



    boyfriend.playAnim("dead-intro");

    boyfriend.animation.finishCallback = (name:String) -> {
        final reversed:Bool = boyfriend.animation.curAnim.reversed;
        switch (name) {
            case "dead-intro":
                boyfriend.playAnim("dead-transition", true);
                new FlxTimer().start(0.8, () -> {
                    CoolUtil.playMusic(Paths.music(gameOverSong), false, 1, true, Flags.DEFAULT_BPM);
                });
            case "dead-transition":
                boyfriend.playAnim("dead-loop", canControl = true);
            case "pop-intro":
                if (reversed)
                    boyfriend.playAnim("dead-loop", true);
                grunt.volume = reversed ? 0 : 1;
                if (!reversed)
                    grunt.play();
            case "pop-transition":
                if (reversed) {
                    boyfriend.playAnim("pop-intro", true);
                    boyfriend.animation.curAnim.curFrame = boyfriend.animation.curAnim.frames.length-1;
                    boyfriend.animation.reverse();
                }
            case "pop":
                boyfriend.visible = false;
                FlxG.sound.music.stop();
                 new FlxTimer().start(0.5, () -> {
                    MusicBeatState.skipTransOut = true;
                    MusicBeatState.skipTransIn = false;
                    FlxG.switchState(new PlayState());
                });
        }
    }
}

function update(elapsed:Float) {
    if (controls.BACK && camera.visible) {
        canControl = false;
        camera.visible = false;
        boyfriend.destroy();
        new FlxTimer().start(0.5, () -> {
            IN_MENU = true;
            if (PlayState.SONG.meta.name != "Creatune")
                PlayState.loadSong("Creatune");
            MusicBeatState.skipTransIn = false;
            FlxG.switchState(new PlayState());
        });
    }
    if(!canControl)
        return;
    if(FlxG.keys.anyPressed([Options.P1_ACCEPT[0], Options.P2_ACCEPT[0]])) {
        FlxG.sound.music.volume -= 0.5 * elapsed;
        if (boyfriend.animation.curAnim.reversed)
            boyfriend.animation.reverse();
        else if(boyfriend.animation.finished || boyfriend.animation.curAnim.looped) {
            var anim:Null<String> = null;
            switch(boyfriend.animation.name) {
                case "dead-loop":
                    anim = "pop-intro";
                case "pop-intro":
                    anim = "pop-transition";
                    grunt.play();
                    grunt.volume = 1;
                case "pop-transition": {
                    anim = "pop";
                }
            }
            if (anim == "pop") {
                canControl = false;
                FlxG.sound.music.volume = 0;
                grunt.stop();
                poppit.animation.play("pop", true);
                FlxG.sound.play(Paths.sound("gameover/poppit_close"), 0.75);
                FlxG.sound.play(Paths.sound("gameover/pop"), 1);
            }
            if(anim != null)
                boyfriend.playAnim(anim, true);
        }
    } else if (boyfriend.animation.curAnim.name == "pop-intro" && boyfriend.animation.curAnim.reversed && boyfriend.animation.curAnim.curFrame > boyfriend.animation.curAnim.frames.length - 9)
        boyfriend.animation.curAnim.curFrame = boyfriend.animation.curAnim.frames.length - 10;
    else if (boyfriend.animation.curAnim.name != "dead-loop" && !boyfriend.animation.curAnim.reversed)
        boyfriend.animation.reverse();

    var anim:Null<String> = boyfriend.animation.curAnim.name;
    if (boyfriend.animation.curAnim.reversed) {
        grunt.volume -= 2 * elapsed;
        FlxG.sound.music.volume += 0.8 * elapsed;
    } else if (FlxG.keys.anyPressed([Options.P1_ACCEPT[0], Options.P2_ACCEPT[0]]) && boyfriend.animation.curAnim.name == "pop-transition") {
        if (!grunt.playing) {
            grunt.play();
            grunt.time += 600;
        }
        grunt.volume += elapsed * 1.5;
    }
}

function onEnd(e) e.cancel();