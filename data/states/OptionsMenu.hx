//
import sys.FileSystem;
import funkin.options.type.TextOption;
import funkin.options.type.Checkbox;
import funkin.options.type.NumOption;
import funkin.options.keybinds.KeybindsOptions;
import funkin.options.TreeMenuScreen;
import funkin.savedata.FunkinSave;
import funkin.backend.assets.ModsFolder;
import funkin.backend.system.framerate.Framerate;

import flixel.text.FlxText.FlxTextFormat;
import flixel.text.FlxText.FlxTextFormatMarkerPair;

using StringTools;

var menuLength:Int = -1;

function create() {
    forceUpdate.push(globalUpdate);
}

function postCreate() {
    bg.loadGraphic(Paths.image("stages/pod/bg1"));
	bg.scale.set(0.4, 0.4);
	bg.updateHitbox();
	bg.colorTransform.blueMultiplier = 1.25;
	bg.colorTransform.greenMultiplier = 0.8;
	bg.colorTransform.alphaMultiplier = 0.5;
	bg.screenCenter(FlxAxes.X);

    titleLabel.font = Paths.font("Cobbler Medium.otf");
    descLabel.font = Paths.font("Cobbler Medium.otf");

    titleLabel.size = 48;
    descLabel.size = 32;

    titleLabel.x += 10;
    descLabel.x += 10;

}

function update(elapsed:Float) {

    if(menuLength != treeLength) {
        menuLength = treeLength;
        for (menu in tree) {
            if (menu.health != -1) {
                menu.health = -1;
                for(member in menu.members) {
                    if(member.__text != null) {
                        var txt = new FunkinText(0, 0, 0, member.__text.text, 24, false);
                        txt.setFormat(Paths.font("Cobbler Medium.otf"), 68, member.__text.color, 'left');
						txt.antialiasing = Options.antialiasing;

                        if(member.checkbox != null) {
                            member.checkbox.x = member.__text.x + txt.width + 20;
                            member.checkbox.y -= txt.height * .25;
                        }

                        if(member.__number != null) {
                            member.__number.visible = false;
                            var numTxt = new FunkinText(txt.width + 15, 0, 0, member.__number.text, 24, false);
							numTxt.antialiasing = Options.antialiasing;
                            numTxt.setFormat(Paths.font("Cobbler Medium.otf"), 68, member.__text.color, 'left');
                            member.changedCallback = (num) -> {
                                numTxt.text = ": " + num;
                            }
                            member.add(numTxt);
                        }

                        if(member.slider != null) {
                            member.slider.x = member.__text.x + txt.width;
                            //member.slider.y -= txt.height * .25;
                        }

                        if(member.__selectionText != null) {
                            member.__selectionText.visible = false;
                            var selTxt = new FunkinText(txt.width + 15, 0, 0, member.__selectionText.text, 24, false);
							selTxt.antialiasing = Options.antialiasing;
                            selTxt.setFormat(Paths.font("Cobbler Medium.otf"), 68, member.color, 'left');
                            switch(member.rawText) {
                                case "AppearanceOptions.Advanced.quality-name":
                                    member.changedCallback = (val:String) -> {
                                        var qualitly:Int = Std.parseInt(val);

                                        if (qualitly <= 1) Options.antialiasing = true;
                                        menu.members[1].checked = Options.antialiasing;
                                        menu.members[2].checked = Options.gameplayShaders;

                                        for (member in 0...menu.members.length) 
                                            menu.members[member].locked = false;
                                        
                                        menu.members[3].locked = qualitly <= 1;
                                        menu.members[2].locked = qualitly <= 1;

                                        var antialiasing = qualitly == 0 ? false : (qualitly == 1 ? true : Options.antialiasing);
                                        FlxG.game.stage.quality = (FlxG.enableAntialiasing = antialiasing) ? 0/*BEST*/ : 2/*LOW*/;
                                        selTxt.text = member.formatTextOption();
                                    };
                                default:
                                    member.changedCallback = (str) -> {
                                        selTxt.text = member.formatTextOption();
                                    }
                            }
                            member.add(selTxt);
                        }
                        member.remove(member.__text);
                        member.add(txt);
                    }
                }
            }
        }
    }
}

function globalUpdate(elapsed:Float) {
    if(KeybindsOptions.instance != null) {
        if(KeybindsOptions.instance.scriptName == "optionsTree.controls-desc") {
            KeybindsOptions.instance.scriptName = "KeybindsOptions";
            KeybindsOptions.instance.scriptsAllowed = true;
            KeybindsOptions.instance.loadScript();
            KeybindsOptions.instance.stateScripts.call("create");
        }
    }
}

function destroy() {
    FlxG.save.flush(); // I am tired of the variables reseting sometimes
}