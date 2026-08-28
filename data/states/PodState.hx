/// it was originally a standalone state. Have fun looking at older code ig

import flixel.camera.FlxCameraFollowStyle;
import funkin.backend.utils.CoolUtil.CoolSfx;
import funkin.game.Stage;
import flixel.FlxObject;


var camFollow:FlxObject;

var extraCardboard:FlxSprite;
var pod:Stage;
var bf:Character;
var gf:Character;
var sackboy:Character;
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
    buttons.members[curSelect].alpha = 0.5;
    curSelect = FlxMath.wrap(value, 0, buttons.length-1);
    buttons.members[curSelect].alpha = 1;
    return curSelect;
}

var sprites:Array<String> = ["planet-earth", "planet-profile", "moon"];

function postCreate() {
    camera.zoom = add(pod = new Stage('pod')).defaultZoom * 1.5;
    for (spr in sprites) {
        pod.getSprite(spr).scale.x -= 0.2;
        pod.getSprite(spr).scale.y -= 0.2;
        pod.getSprite(spr).y -= 50;
    }
    camFollow = new FlxObject(0, 0, 2, 2);
	add(camFollow);
    camera.scroll.set(pod.startCam.x - camera.width / 2, pod.startCam.y - camera.height);
    camFollow.setPosition(pod.startCam.x - 15, pod.startCam.y - 25);
    camera.follow(camFollow, FlxCameraFollowStyle.LOCKON, 0.05);

    bfPod = new Character(0, 0, 'boysack-controller', false);
    bfPod.y += 30;
    pod.applyCharStuff(bfPod, 'girlfriend', 2);
    remove(bfPod, true);
    insert(members.indexOf(pod.getSprite("gf-detail")) + 1, bfPod);

    gf = new Character(0, 0, 'girlsack', false);
    gf.alpha = 0.0001;
    gf.debugMode = true;
    pod.applyCharStuff(gf, 'girlfriend', 2);
    gf.x -= 45;
    gf.y -= 7;
    remove(gf, true);
    insert(members.indexOf(pod.getSprite("gf-detail")) + 1, gf);

    bf = new Character(0, 0, 'boysack', true);
    bf.alpha = 0.0001;
    bf.debugMode = true;
    pod.applyCharStuff(bf, 'boyfriend', 1);

    sackboy = new Character(0, 0, 'sackboy', false);
    sackboy.alpha = 0.0001;
    sackboy.debugMode = true;
    sackboy.playAnim('stare');
    pod.applyCharStuff(sackboy, 'dad', 0);

    extraCardboard = new FlxSprite().loadGraphic(Paths.image("stages/pod/bg11menu"));
    extraCardboard.antialiasing = Options.antialiasing;
    extraCardboard.setPosition(pod.getSprite("gf-detail").x, pod.getSprite("gf-detail").y);
    insert(members.indexOf(bfPod) + 1, extraCardboard);

    for (i => menuItem in mainMenuItems) {
        createButton(menuItem, 500 , 195 + (100 * i) + (i == 2 ? 25 : 0));
    }

    add(buttons);
    curSelect = 0;
}

function createButton(tag:String, ?x:Float = 0, y:Float = 0) {
    trace(tag);
    var s:Float = 0.35; // scale

    var spr:FlxSprite = new FlxSprite(x, y).loadGraphic(Paths.image("menu/" + tag + "Text"));
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

var allowInput:Bool = true;
function update(elapsed:Float) {
    if(allowInput) {
        if(controls.BACK) {
            bfPod.playAnim("joystick-cancel");
            exit();
        } else if(controls.ACCEPT) {
            CoolUtil.playMenuSFX(CoolSfx.CONFIRM);
            bfPod.playAnim("confirm");
            if (curMenu == 0) {
                switch(mainMenuItems[curSelect]) {
                    case "creatune":
                        FlxTween.tween(buttons, {alpha: 0}, 0.5, {ease: FlxEase.sineOut});
                        FlxTween.tween(sackboy, {alpha: 1}, 1.5, {ease: FlxEase.cubeInOut});
                        new FlxTimer().start(0.6, () -> {
                            bfPod.visible = false;
                            bf.alpha = 1;
                            bf.playAnim("intro", true);
                            gf.alpha = 1;
                            gf.playAnim("empty", true);
                            gf.debugMode = false;

                            new FlxTimer().start(0.25, () -> {
                                gf.playAnim("intro", true);
                                new FlxTimer().start(0.75, () -> {
                                    sackboy.playAnim("wave", true);
                                        new FlxTimer().start(0.25, () -> {
                                        var pos = bf.getCameraPosition();
                                        FlxTween.tween(camFollow, {x: pos.x, y: pos.y}, 1.5, {ease: FlxEase.cubeInOut});
                                    });
                                });
                            });
                        });
                        FlxTween.tween(camera, {zoom: pod.defaultZoom}, 1.5, {ease: FlxEase.cubeInOut});
                        var pos = sackboy.getCameraPosition();
                        FlxTween.tween(camFollow, {x: pos.x + 200, y: pos.y - 100}, 1.5, {ease: FlxEase.cubeInOut});
                        
                        for (spr in sprites) {
                        FlxTween.tween(pod.getSprite(spr), {
                                "scale.x": pod.getSprite(spr).scale.x + 0.2,
                                "scale.y": pod.getSprite(spr).scale.y + 0.2,
                                y: pod.getSprite(spr).y + 50
                            }, 1.5, {ease: FlxEase.cubeInOut});
                        }
                }
            }
        } else if(controls.UP_P) {
            bfPod.playAnim("joystick-up");
            CoolUtil.playMenuSFX(CoolSfx.SCROLL);
            curSelect -= 1;
        }
        else if(controls.DOWN_P) {
            bfPod.playAnim("joystick-down");
            CoolUtil.playMenuSFX(CoolSfx.SCROLL);
            curSelect += 1;
        }
    }
}

function exit() {
    allowInput = false;
    FlxG.switchState(new MainMenuState());
}