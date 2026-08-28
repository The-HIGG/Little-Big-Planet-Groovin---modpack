function create() {
    for (spr in stage.stageSprites)
        spr.updateHitbox();
    overlay1.blend = 9;
    overlay2.blend = 0;
}