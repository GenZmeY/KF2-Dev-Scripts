//=============================================================================
// KFMGA_TargetGame
//=============================================================================
// Data storage class for rigged target games to be placed in the world.  Holds
//      all editor-facing data related to the game's animation needs to reduce
//      replication needs.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFMGA_TargetGame extends SkeletalMeshActor
    implements(KFInterface_MinigameActor);

struct sTargetGameData
{
    /** List of possible animations that can be played.  Picks one at random. */
    var() array<name> MinigameAnimations;
};

/** Per difficulty data for the minigame (if difficulty not supported, uses entry 0) */
var() array<sTargetGameData> MinigameAnimData;

/** List of bones to spawn and attach a target to */
var() array<name> TargetBones;

/** Animation to play when the game is turning on */
var() name GameStartAnim;

/** Animation to play when the game is shutting down */
var() name GameEndAnim;

/** Animation to play while idling closed.  If this is none, simply ends at last frame of GameEndAnim */
var() name IdleClosedAnim;

/** Animation to play while idling open (IE: Victory celebration) */
var() name IdleOpenAnim;

/** Amount of time to stay open post-victory */
var() float PostVictoryIdleTime;

/** Amount of time to stay open post-defeat */
var() float PostDefeatIdleTime;

/** Parent game that is linked with this actor */
var() KFMG_TargetGame ParentGame;

//Don't need these implemented for this class
function bool CanBeActivated(KFTrigger_MinigameButton ActivationSource);
function Activated(KFTrigger_MinigameButton ActivationSource);
function Deactivated();

simulated event bool CanPlayAkEvent(Actor inOwner, name BoneName)
{
    if (ParentGame != none)
    {
        return ParentGame.CanPlayAkEvent(inOwner, BoneName);
    }
}

defaultproperties
{
    Begin Object Class=SpriteComponent Name=Sprite
        Sprite = Texture2D'EditorResources.S_Trigger'
        HiddenGame = true
        AlwaysLoadOnClient = False
        AlwaysLoadOnServer = False
        SpriteCategoryName = "Triggers"
    End Object
    Components.Add(Sprite)

    Begin Object Name=SkeletalMeshComponent0
        bUpdateSkelWhenNotRendered=true
    End Object

    GameStartAnim = Open
    GameEndAnim = Close
    IdleOpenAnim = Idle_Open
    PostVictoryIdleTime = 2.f
}