var keys:Array<Dynamic> = [];

function create() {
    coloredBG.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    coloredBG.alpha = .85;
    for(i in members) {
        if(i.text != null && i.textField == null) {
            var txt = new FunkinText(i.x, i.y, i.width, i.text, 36, false);
            txt.setFormat(Paths.font("Cobbler Medium.otf"),78, FlxColor.WHITE, 'center');
            txt.antialiasing = Options.antialiasing;
            i.destroy();
            add(txt);
        }
    }
    for(i in alphabets) {
        for(spr in [i.title, i.bind1, i.bind2]) {
            var txt = new FunkinText(spr.x - i.x, spr.y - i.y, 0, spr.text, 24, false);
            if(spr != i.title)
                keys.push([txt, spr]);
            else spr.scale.set();
            txt.setFormat(Paths.font("Cobbler Medium.otf"), 68, FlxColor.WHITE, 'left');
			txt.antialiasing = Options.antialiasing;
            spr.visible = false;
            i.add(txt);
        }
    }

    for (key in keys) {
        var isArrow = arrowCheck(key[1].text);
        key[0].visible = !isArrow;
        key[1].visible = isArrow;
    }
}

function postUpdate() {
    if (!FlxG.keys.pressed.ANY) return;
    for (key in keys) {
        var e = key[0];
        var spr = key[1];
        var isArrow = arrowCheck(spr.text);
        e.visible = !isArrow;
        spr.visible = isArrow;
        spr.scale.x = isArrow ? spr.scale.y : 0;
        if (!isArrow && spr.text != e.text) e.text = spr.text;
    }
    for (key in keys) key[0].alpha = key[1].alpha;
    //}
    //if(controls.LEFT_P || controls.RIGHT_P || controls.UP_P || controls.DOWN_P)
}

function arrowCheck(str:String) {
    return (str == "←" || str == "↓" || str == "↑" || str == "→");
}
