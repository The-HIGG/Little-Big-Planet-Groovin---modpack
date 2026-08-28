import funkin.savedata.FunkinSave;
import Date;

import flixel.util.FlxStringUtil;
import funkin.backend.system.Flags;

import funkin.game.ComboRating;

import funkin.backend.MusicBeatState;

var lerpScore:Float;
public var ropes:Array<Rope> = [];

public var bubble:FlxSpriteGroup;
public var cloud:FlxSprite;

var countdownSpr:FlxSprite;
var countdownAnims:Array<String> = ["3", "2", "1", "go"];
public var menuDelay = IN_MENU && PlayState.SONG.meta.name == "Creatune";

// the crashes are making me go crazy
public var carefulTweens:Array<FlxTween> = [];

if(!PlayState.chartingMode)
    PauseSubState.script = "data/scripts/pause";
else
    trace('removing the custom pause for debug purposes');

var introSkip:Bool = MusicBeatState.skipTransIn && !IN_MENU;
var started:Bool = false;

function postCreate() {

    if(!introSkip)
        Conductor.songPosition = -10000;

    countdownSpr = new FlxSprite();
    countdownSpr.camera = camHUD;
    countdownSpr.visible = false;
    countdownSpr.scrollFactor.set();
    countdownSpr.scale.set(.7,.7);
    countdownSpr.updateHitbox();
    countdownSpr.antialiasing = Options.antialiasing;
    countdownSpr.frames = Paths.getFrames("game/countdown");
    for(anim in countdownAnims)
        countdownSpr.animation.addByPrefix(anim, "countdown " + anim, 12, false);
    countdownSpr.screenCenter();

    add(countdownSpr);

    var w:Float = healthBarBG.width * 0.6;
    var h:Float = healthBarBG.height * 0.6;

    healthBarBG.setGraphicSize(w,h);
    healthBarBG.updateHitbox();
    healthBarBG.y += 40;
    healthBar.setGraphicSize(w * 0.9,h * 0.25);
    for(i in [healthBar,healthBarBG]) {
        i.y -= 150;
        i.screenCenter(FlxAxes.X);
    }

    if (!Options.downscroll)
        healthBar.y -= 1;

    for(icon in [iconP1, iconP2])
        icon.y -= 50;

    remove(healthBarBG);
    insert(members.indexOf(healthBar) + 1, healthBarBG);

    updateIconPositions = function() {
		var iconOffset = Flags.ICON_OFFSET;
		var healthBarPercent = healthBar.percent;

		var center:Float = healthBarBG.x + (healthBarBG.width) * FlxMath.remapToRange(healthBarPercent, 0, 100, 1, 0);

		iconP1.x = center - iconOffset;
		iconP2.x = center - (iconP2.width - iconOffset);

		iconP1.health = healthBarPercent / 100;
		iconP2.health = 1 - (healthBarPercent / 100);
	}

    remove(accuracyTxt);
    accuracyTxt.destroy();

    missesTxt.setFormat(Paths.font("Cobbler Regular.otf"),28, 0xFF000000);

    scoreTxt.y = 100;    
    scoreTxt.alignment = "center";
    scoreTxt.setFormat(Paths.font("Eigerdals Heavy.OTF"),30, 0xFFFFFFFF);
    if(Options.downscroll)
        scoreTxt.y -= scoreTxt.height * .5;

    for(txt in [scoreTxt, missesTxt]) {
        txt.antialiasing = Options.antialiasing;
        txt.textField.antiAliasType = 1/*ADVANCED*/;
        txt.textField.sharpness = 400/*MAX ON OPENFL*/;
    }

    cloud = new FlxSprite(0, missesTxt.y + (missesTxt.height * .5) - 12.5);
    cloud.scrollFactor.set();
    cloud.cameras = [camHUD];
    cloud.antialiasing = Options.antialiasing;
    cloud.frames = Paths.getFrames("hud/cloud");
    cloud.animation.addByPrefix('idle', "cloud loop", 12, true);
    cloud.animation.play('idle', true);
    cloud.y -= cloud.height * .5;
    cloud.screenCenter(FlxAxes.X);
    insert(members.indexOf(healthBarBG), cloud);

    missesTxt.y -= (missesTxt.height * .5) - 6.25;

    bubble = new FlxSpriteGroup();
    bubble.cameras = [camHUD];
    for (i in ["bubble", "center"]) {
        var spr:FlxSprite = new FlxSprite(0,0).loadGraphic(Paths.image("hud/scorepoints" + i));
        spr.y += spr.height * 0.25;
        spr.antialiasing = Options.antialiasing;
        spr.screenCenter(FlxAxes.X);

        bubble.add(spr);
    }
    insert(0, bubble);
    scoreTxt.y = bubble.y + (bubble.height * (Options.downscroll ? 0.62 : 0.68));

    updateRatingStuff = function() {

        if (curRating == null)
			curRating = new ComboRating(0, "[N/A]", 0xFF888888);

        scoreTxt.text = calculateNum(Math.fround(lerpScore), 4);
        scoreTxt.size = 30 - (scoreTxt.text.length - 4) * 2.5;

        missesTxt.text = "Accuracy: " + (accuracy == -1 ? "-" : CoolUtil.quantize(accuracy * 100, 100)) + "% ";
        missesTxt.text += "Misses: " + misses + " ";
        missesTxt.text += "Rank: " + curRating.rating;
    }

    if(!introSkip) {
        cloud.alpha = 0;
        missesTxt.alpha = 0;
        scoreTxt.scale.set();
        bubble.scale.set();

        iconP1.alpha = 0;
        iconP2.alpha = 0;
        healthBar.alpha = 0;
        healthBarBG.alpha = 0;
    }
}

function calculateNum(num:Float, ?dig:Float = 3) {
    var score:String = "" + Math.abs(num) + "";
    var negative:Bool = (num < 0);
    var digits:Int = FlxStringUtil.filterDigits(Math.abs(num)).length;
    if(digits < dig) {
        for(i in 0...(dig-(digits))) {
            score = "0" + score + "";
        }
        if(negative)
            score = "-" + score + "";
    }
    return score;
}

function onStrumCreation(e) {
    e.sprite = 'game/notes/cardboard';
    e.__doAnimation = false;
}

var strums:Int = -1;
function onPostStrumCreation(e) {
    var rope:StrumRope = new StrumRope(e.strum);
    rope.camera = camHUD;
    ropes.push(rope);
    strums++;
    if(!introSkip || menuDelay) {
        rope.updatePos = false;
        e.strum.y -= 175;
        if (!menuDelay) {
            carefulTweens.push(FlxTween.tween(e.strum, {y: rope.pos}, (Conductor.crochet / 1000) * 2 + (0.1 * ((strums % 4) + 4)), {
                ease: FlxEase.bounceOut, onComplete: function(_) {
                    rope.updatePos = true;
                }
            }));
        }
    }
    insert(0, rope);
}

function onNoteCreation(e) {
    e.noteSprite = "game/notes/cardboard";
    e.note.gapFix = 2;
}

if(!introSkip || menuDelay) {
    function onSongStart() {
        if (menuDelay)
            return;
        FlxTween.num(0, 1, (Conductor.crochet / 1000) * 1.4, {ease: FlxEase.cubeOut}, function(num) {
            missesTxt.alpha = num;
            cloud.alpha = num;

            iconP1.alpha = num;
            iconP2.alpha = num;
            healthBar.alpha = num;
            healthBarBG.alpha = num;
        });
    }
}

function onStartCountdown(e) {
    if (menuDelay) {
        e.cancel();
        return;
    }
    else if(health == 0)
        return;
    if(!introSkip && !started) {
        FlxTween.num(0, 1, (Conductor.crochet / 1000) * 1.4, {ease: FlxEase.cubeOut}, function(num) {
            scoreTxt.scale.set(num, num);
            bubble.scale.set(num, num);

            bubble.members[0].angle = -35 + (num * 35);
            bubble.members[1].angle = 35 + (num * -35);
        });
        e.cancelled = true;
        _startCountdownCalled = false;
        var sound:FlxSound = null;

        var sfx:String = "intro/startup";
        if (!Assets.exists(sfx)) sfx = Paths.sound(sfx);
        sound = FlxG.sound.play(sfx, event.volume);
        startTimer = new FlxTimer().start((Conductor.crochet / 1000), (tmr:FlxTimer) -> {
            started = true;
            startCountdown();
		});
    } else {
        startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * (introSkip ? introLength - 1 : ((introLength - 1) * 1.25)) - Conductor.songOffset;

        e.cancelled = true;
        if(introLength > 0) {
			var swagCounter:Int = 0;
			startTimer = new FlxTimer().start((Conductor.crochet / 1000) * (introSkip ? 1 : (swagCounter == 3 ? 1 : 1.5)), (tmr:FlxTimer) -> {
                if(health != 0)
				    countdown(swagCounter++);
			}, 4);
		}
    }

}
var _e;
function onCountdown(e) {
    if (menuDelay || !persistentDraw || !persistentUpdate) {
        e.cancel();
        return;
    }
    else if(health == 0)
        return;
    e.spritePath = null;
    countdownSpr.visible = true;
    countdownSpr.scale.set(.6,.6);
    carefulTweens.push(FlxTween.tween(countdownSpr.scale, {x: .7, y: .7}, (Conductor.crochet / 1000) * .6, {ease: FlxEase.elasticOut}));
    _e = e;
    carefulTweens.push(new FlxTimer().start((Conductor.crochet / 1000) * (!introSkip ? (e.swagCounter != 3 ? 1.3 : 1.6) : (e.swagCounter != 3 ? .75 : 1.1)), (tmr:FlxTimer) -> {
            if(health == 0)
                return;
        carefulTweens.push(FlxTween.tween(countdownSpr.scale, {x: .6, y: .6}, (Conductor.crochet / 1000) * (_e.swagCounter != 3 ? .2 : 1), {ease: FlxEase.quadOut}));
        if(_e.swagCounter == 3)
            carefulTweens.push(FlxTween.tween(countdownSpr, {alpha: 0}, (Conductor.crochet / 1000), {ease: FlxEase.quadOut}));
    }));
    countdownSpr.animation.play(countdownAnims[e.swagCounter], true);
}

function onNoteHit(e) {
    checkRope(e.note.strumLine.members[e.note.noteData]).press(e.note.isSustainNote);
}

function checkRope(strum:Strum) {
    for(i in ropes) {
        if(i.strum == strum)
            return i;
    }
    return null;
}

function update(elapsed:Float) {
    lerpScore = FlxMath.lerp(lerpScore, songScore, elapsed * 14);
}

// don't need to switch states since it automatically goes back to playstate
function onSongEnd(_) {
    _.cancel(true);

    for (strumLine in strumLines.members) strumLine.vocals.stop();
    inst.stop();
    vocals.stop();
    FlxG.sound.music.volume = 0;

    if (validScore) {
        #if !switch
        FunkinSave.setSongHighscore(PlayState.SONG.meta.name, PlayState.difficulty, PlayState.variation, {
            score: songScore,
            misses: misses,
            accuracy: accuracy,
            hits: PlayState.instance.hits,
            date: Date.now().toString()
        });
        #end
    }

    WHITE_FADE = true;
    persistentUpdate = false;

    FlxG.sound.play(Paths.sound("song_leave"), 1);

    FlxTween.tween(PlayState.instance.camHUD, {alpha: 0}, 1.1, {ease: FlxEase.circOut});
    FlxTween.tween(PlayState.instance.camGame, {zoom: PlayState.instance.camGame.zoom + 0.2}, 1.4, {ease: FlxEase.quadOut});

    bg2 = new FunkinSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
    bg2.zoomFactor = 0;
    bg2.scrollFactor.set();
    bg2.alpha = 0;
    add(bg2);

    FlxTween.tween(bg2, {alpha: 1}, 0.85, {ease: FlxEase.circOut});

    new FlxTimer().start(1.5, (_) -> {
        if (PlayState.SONG.meta.name != "Creatune")
            PlayState.loadSong("Creatune");
        MusicBeatState.skipTransIn = true;
        MusicBeatState.skipTransOut = true;
        IN_MENU = true;
        FlxG.resetState();
    });
}

function destroy() {
    for (twn in carefulTweens) {
        if (twn != null) {
            twn.cancel();
            twn.destroy();
        }
    }
}

class StrumRope extends FlxSprite {

    public var updatePos:Bool = true;
    public var off:Float = 0;
    var pos:Float = 0;

    public var strum:Strum;

    public function new(str:Strum) {
        strum = str;
        pos = strum.y;
        super(strum.x + (strum.width * .5), strum.y + (strum.height * .5));
        camera = PlayState.instance.camHUD;
        loadGraphic(Paths.image("game/notes/rope"));
        scale.set(0.65, 0.65);
        updateHitbox();
        x -= width * .5;
        y -= height;
        alpha = strum.alpha;
    }

    override public function update(elapsed:Float) {
        alpha = strum.alpha;
        if(updatePos) {
            off = CoolUtil.fpsLerp(off, 0, 0.1);
            strum.y = CoolUtil.fpsLerp(strum.y, pos + off, .065);
        }
        setPosition(
            strum.x + strum.width * .5 - width * .5,
            strum.y + strum.height * .5 - height
        );
    }

    public function press(sustain:Bool) {
        off -= 40 * (sustain ? 0.4 : 1);
        strum.y -= 10 * (sustain ? 0.4 : 1);
    }
}