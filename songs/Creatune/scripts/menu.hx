///
import funkin.menus.ModSwitchMenu;
import funkin.editors.EditorPicker;
import funkin.backend.system.Flags;

import flixel.camera.FlxCameraFollowStyle;
import funkin.backend.utils.CoolUtil.CoolSfx;
import funkin.game.Stage;
import flixel.FlxObject;

import funkin.options.OptionsMenu;

if (PlayState.chartingMode)
    IN_MENU = false;
if(!IN_MENU)
    disableScript();

var extraCardboard:FlxSprite;
var bfPod:Character;

var buttons:FlxSpriteGroup = new FlxSpriteGroup();

var idleColor:Int = 0xFF73BFBF;
var selectColor:Int = 0xFF9434D7;

var curMenu:Int = 0;
var curSelect(default, set):Int;

//var mainMenuItems:Array<String> = ["story", "moon", "options"];
var mainMenuItems:Array<String> = ["creatune", "yellowhead", "options"];

function set_curSelect(value:Int):Int {
    if (value == curSelect) return;
    curSelect = FlxMath.wrap(value, 0, buttons.length-1);
    return curSelect;
}

var sprites:Array<String> = ["planet-earth", "planet-profile", "moon"];
var menuMusic:FlxSound;

function postCreate() {
    if (!IN_MENU)
        return disableScript();

    menuMusic = FlxG.sound.load(Paths.music(Flags.DEFAULT_MENU_MUSIC));
    menuMusic.play();

    playerStrums.ghostTapping = true;

    camGame.zoom = stage.defaultZoom * 1.5;
    for (spr in sprites) {
        stage.getSprite(spr).scale.x -= 0.2;
        stage.getSprite(spr).scale.y -= 0.2;
        stage.getSprite(spr).y -= 50;
    }

    camFollowMenu = new FlxObject(0, 0, 2, 2);
	add(camFollowMenu);
    camera.scroll.set(stage.startCam.x - camera.width / 2, stage.startCam.y - camera.height);
    camFollowMenu.setPosition(stage.startCam.x - 15, stage.startCam.y - 25);
    camera.follow(camFollowMenu, FlxCameraFollowStyle.LOCKON, 0.05);

    bfPod = new Character(0, 0, 'boysack-controller', false);
    bfPod.y += 30;
    stage.applyCharStuff(bfPod, 'girlfriend', 2);
    remove(bfPod, true);
    insert(members.indexOf(stage.getSprite("gf-detail")) + 1, bfPod);

    gf.alpha = 0.0001;
    gf.debugMode = true;
    //gf.x -= 45;
    //gf.y -= 7;

    bf.alpha = 0.0001;
    bf.debugMode = true;

    dad.alpha = 0.0001;
    dad.debugMode = true;
    dad.playAnim('stare');

    extraCardboard = new FlxSprite().loadGraphic(Paths.image("stages/pod/bg11menu"));
    extraCardboard.antialiasing = Options.antialiasing;
    extraCardboard.setPosition(stage.getSprite("gf-detail").x, stage.getSprite("gf-detail").y);
    insert(members.indexOf(bfPod) + 1, extraCardboard);

    for (i => menuItem in mainMenuItems) {
        menuItem = createButton(menuItem, 525 , 195 + (100 * i) + (i == 2 ? 25 : 0));
        menuItem.ID = i;
        menuItem.alpha = 0;
        switch(i) {
            case 0:
                menuItem.x -= 25;
                menuItem.angle -= 1.5;
            case 1:
                menuItem.x += 35;
                menuItem.y += 10;
                menuItem.angle += 2;
            case 2:
                menuItem.x -= 15;
        }
    }

    add(buttons);

    new FlxTimer().start(0.45, () -> {
        for (i => button in buttons.members) {
            button.y -= 25;
            FlxTween.tween(button, {y: button.y + 25, alpha: 0.5}, 0.5, {ease: FlxEase.cubeOut, startDelay: 0.1 * i});
            new FlxTimer().start(0.51 * buttons.length - 1, () -> {
                curSelect = 0;
                allowInput = true;
            });
        }
    });
}

function createButton(tag:String, ?x:Float = 0, y:Float = 0) {
    trace(tag);
    var s:Float = 0.35; // scale

    var spr:WarppedButton = new WarppedButton(x, y).loadGraphic(Paths.image("menu/" + tag + "Text"));
    spr.antialiasing = Options.antialiasing;
    spr.scale.set(s,s);
    spr.updateHitbox();
    spr.x -= spr.width / 2;
    spr.alpha = 0.5;

    return buttons.add(spr);
}

// scrapped function
/*
function createButtonOLD(tag:String, ?x:Float = 0, y:Float = 0) {
    var s:Float = 0.68; // scale
    var button:FlxSpriteGroup = new FlxSpriteGroup();

    button.add(new FlxSprite(x, y).loadGraphic(Paths.image("menu/buttonhover"))).color = idleColor;

    var text:FlxSprite = new FlxSprite(x, y).loadGraphic(Paths.image("menu/" + tag + "text"));
    text.scale.set(s, s);
    text.updateHitbox();

    var bg = button.members[0];
    bg.alpha = 0.7;
    bg.blend = 0;
    bg.scale.set(s, s);
    bg.updateHitbox();

    text.x += (bg.width - text.width) / 2;
    text.y += (bg.height - text.height) / 2;
    button.add(text);
    button.add(new FlxSprite(x, y).loadGraphic(Paths.image("menu/buttonback")));
    button.members[2].scale.set(s, s);
    button.members[2].updateHitbox();

    for(spr in button.members) {
        spr.antialiasing = Options.antialiasing;
    }
    buttons.add(button);
    return button;
}
*/

var allowInput:Bool = false;
function update(elapsed:Float) {
    if (#if !(CUSTOM_BUILD) controls.SWITCHMOD || #end FlxG.keys.justPressed.SEVEN) {
        persistentUpdate = false; 
        persistentDraw = true;
        openSubState(#if !(CUSTOM_BUILD) controls.SWITCHMOD ? new ModSwitchMenu() :#end new EditorPicker());
    }

    if(allowInput) {
        buttons.forEachAlive((button:FlxSprite) -> {
            var activate = button.ID == curSelect;
            button.selected = activate;
            button.alpha = lerp(button.alpha, activate ? 1 : 0.5, 0.35);
        });
        if(controls.BACK) {
            bfPod.playAnim("joystick-cancel", true);
            exit();
        } else if(controls.ACCEPT) {
            FlxTween.tween(menuMusic, {volume: 0}, 1.55, {ease: FlxEase.sineIn});
            CoolUtil.playMenuSFX(CoolSfx.CONFIRM);
            bfPod.playAnim("confirm", true);
            if (curMenu == 0) {
                switch(mainMenuItems[curSelect]) {
                    case "creatune":
                        allowInput = false;
                        FlxTween.tween(buttons, {alpha: 0}, 0.5, {ease: FlxEase.sineOut});
                        FlxTween.tween(dad, {alpha: 1}, 1.5, {ease: FlxEase.cubeInOut});
                        new FlxTimer().start(0.6, () -> {
                            bfPod.visible = false;
                            bf.alpha = 1;
                            bf.playAnim("intro", true);
                            FlxG.sound.play(Paths.sound("sackboy-intro/jump"));
                            gf.alpha = 1;
                            gf.playAnim("empty", true);
                            gf.debugMode = false;
                            if (FlxG.random.bool(80)) {
                                new FlxTimer().start(0.35, () -> {
                                    dad.playAnim("blink", true);
                                    FlxG.sound.play(Paths.sound("sackboy-intro/blink"));
                                });
                            }


                            new FlxTimer().start(0.25, () -> {
                                gf.playAnim("intro", true);
                                FlxG.sound.play(Paths.sound("sackboy-intro/spawn_mid"), Options.volumeSFX);
                                new FlxTimer().start(0.7, () -> {
                                    var pos = gf.getCameraPosition();
                                    FlxTween.tween(camFollowMenu, {x: pos.x, y: pos.y}, 1.5, {ease: FlxEase.cubeInOut});
                                    new FlxTimer().start(0.05, () -> {
                                        new FlxTimer().start((1/24) * 2, () -> {
                                            FlxG.sound.play(Paths.sound("sackboy-intro/sacknoises/ha-" + FlxG.random.int(1,6)), 0.6);
                                        });

                                        dad.playAnim("wave", true);
                                        boyfriend.debugMode = false;
                                        new FlxTimer().start(0.65, () -> {
                                            IN_MENU = false;
                                            dad.debugMode = false;
                                            trace('tweening in notes');
                                            for (strumLineID => strumLine in strumLines.members) {
                                                for (strumID => strum in strumLine.members) {
                                                    var rope:Rope;
                                                    for (_rope in ropes) {
                                                        if (_rope.strum == strum) {
                                                            rope = _rope;
                                                            break;
                                                        }
                                                    }
                                                    if (rope == null)
                                                        continue;
                                                    FlxTween.tween(strum, {y: rope.pos}, (Conductor.crochet / 1000) * 2 + (0.1 * ((strumID % 4) + 4)), {
                                                        ease: FlxEase.bounceOut, onComplete: function(_) {
                                                            rope.updatePos = true;
                                                        }
                                                    });
                                                }
                                            }
                                            new FlxTimer().start(0.8, () -> {
                                                menuDelay = false;
                                                _startCountdownCalled = false;
                                                startCountdown();
                                                for (spr in buttons) {
                                                    spr.destroy();
                                                    spr = null;
                                                }
                                            });
                                        });
                                    });
                                });
                            });
                        });
                        FlxTween.tween(camGame, {zoom: stage.defaultZoom}, 1.8, {ease: FlxEase.cubeInOut});
                        var pos = dad.getCameraPosition();
                        FlxTween.tween(camFollowMenu, {x: pos.x + 200, y: pos.y - 100}, 1.5, {ease: FlxEase.cubeInOut});
                        
                        for (spr in sprites) {
                        FlxTween.tween(stage.getSprite(spr), {
                                "scale.x": stage.getSprite(spr).scale.x + 0.2,
                                "scale.y": stage.getSprite(spr).scale.y + 0.2,
                                y: stage.getSprite(spr).y + 50
                            }, 1.5, {ease: FlxEase.cubeInOut});
                        }
                    case "yellowhead":
                        allowInput = false;
                        IN_MENU = true;
                        new FlxTimer().start(0.25, () -> {
                            PlayState.loadSong("yellowhead");
                            FlxG.switchState(new PlayState());
                        });
                    case "options":
                        FlxG.switchState(new OptionsMenu((_) -> FlxG.switchState(new PlayState())));
                }
            }
        } else if(controls.UP_P) {
            bfPod.playAnim("joystick-up", true);
            CoolUtil.playMenuSFX(CoolSfx.SCROLL);
            curSelect -= 1;
        }
        else if(controls.DOWN_P) {
            bfPod.playAnim("joystick-down", true);
            CoolUtil.playMenuSFX(CoolSfx.SCROLL);
            curSelect += 1;
        }
    }
}

function exit() {
    allowInput = false;
    FlxG.switchState(new MainMenuState());
}

function onSongStart() {
    camera.follow(camFollow, FlxCameraFollowStyle.LOCKON, 0.035);
    disableScript();
}

class WarppedButton extends FunkinSprite {

    private var _init:Bool = false;
    private var _timer:Float = 0;
    private var _angle:Float = 0;
    public var selected:Bool = false;

    override public function update(elapsed:Float) {
        super.update(elapsed);
        if (_init != (_init = true)) {
            _angle = angle;
            randomizeSkew();
            onDraw = (spr) -> {
                var _scale = spr.scale.x;
                if (selected) {
                    spr.colorTransform.redOffset = 255;
                    spr.colorTransform.greenOffset = 255;
                    spr.colorTransform.blueOffset = 255;
                    spr.scale.set(_scale * 1.025, _scale * 1.05);
                    spr.draw();
                } else {
                    var _prevAlpha = spr.alpha;
                    spr.color = FlxColor.BLACK;
                    spr.blend = 9;
                    spr.alpha = _prevAlpha * 0.5;
                    spr.draw();
                    spr.alpha = _prevAlpha;
                    spr.color = FlxColor.WHITE;
                    spr.blend = 10;
                }

                spr.colorTransform.redOffset = 0;
                spr.colorTransform.greenOffset = 0;
                spr.colorTransform.blueOffset = 0;
                spr.scale.set(_scale, _scale);
                spr.draw();
            }
        }
        _timer += elapsed;
        if (_timer >= 0.25) {
            _timer = 0;
            randomizeSkew();
        }
    }

    public function randomizeSkew() {
        skew.x = FlxG.random.float(1.5, -1.5);
        skew.y = FlxG.random.float(1.5, -1.5);
        if (skew.x < 0 && skew.y < 0)
            skew.y *= -1;
        else if (skew.x > 0 && skew.y > 0)
            skew.y *= -1;
        angle = FlxG.random.float(skew.x * 0.035, skew.y * 0.035);
        angle += _angle;
    }
}