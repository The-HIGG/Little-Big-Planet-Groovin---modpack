import lime.graphics.Image;
import funkin.backend.utils.WindowUtils;
import funkin.backend.MusicBeatState;
import funkin.backend.utils.NativeAPI;

window.setIcon(Image.fromBytes(Assets.getBytes(Paths.image('icon'))));

NativeAPI.setWindowBorderColor("Little Big Planet Groovin'", 0xFF2340BD, true, true);
NativeAPI.setWindowTitleColor("Little Big Planet Groovin'", FlxColor.WHITE, true, true);

public static var IN_MENU:Bool = true;
public static var WHITE_FADE:Bool = false;
public static var forceUpdate:Array<(elapsed:Float)-> Void> = [];

if (PlayState.SONG?.meta?.name != "Creatune") {
    if (PlayState.instance != null) {
        PlayState.instace.camGame.visible = false;
        PlayState.instance.camHUD.visible = false;
    }
    MusicBeatState.skipTransOut = true;
    PlayState.loadSong("Creatune");
    FlxG.switchState(new PlayState());
}

function preStateCreate() forceUpdate = [];

function postUpdate(elapsed) {
    for(func in forceUpdate) {
        func(elapsed);
    }
}