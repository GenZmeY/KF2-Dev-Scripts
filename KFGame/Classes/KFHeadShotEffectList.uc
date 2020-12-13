//=============================================================================
// KFHeadShotEffectList
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFHeadShotEffectList extends Object
	abstract
    native;

struct native HeadshotEffect
{
	var int Id;
	var string ItemName;
	var edithide transient ParticleSystem EffectPS;
	var string EffectPSName;
	var string IconPath;
	var AkEvent HeadshotSoundEffect;
	StructDefaultProperties
	{
		IconPath=""
		Id=INDEX_NONE
	}
};

var private const array<HeadshotEffect> HeadShotEffects;

/** Cached Emote ID */
var private const int EquippedHeadshotId;

/** Debugging */
var private const bool bDebugEffects;

/** Helper functions for UI and special move */
static native final function HeadshotEffect GetUnlockedHeadshotEffect( int ItemId );
static native final function byte GetHeadShotEffectIndex( int ItemId );
static native final function HeadshotEffect GetHeadShotEffectFromIndex( byte HeadShotIndex );
static native final function bool IsHeadShotEffectEquipped( int ItemId );
static native final function int GetEquippedHeadShotEffectId();

/** Save equipped emote using profile */
static native final function SaveEquippedHeadShotEffect( int ItemId );

/** Refreshes the equipped emote from profile data */
static native final function RefreshCachedHeadShotEffectId();

defaultproperties
{
	HeadShotEffects.Add((Id=INDEX_NONE, ItemName = "Dummy")
	HeadShotEffects.Add((Id=6260, ItemName="LetsGetCrazy", 	EffectPSName="FX_Headshot_Alt_EMIT.FX_Headshot_Alt_Dosh_01", 						IconPath="EMOTE_TEX.Emote_LetsGoCrazy_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Dosh_Headshot')
	HeadShotEffects.Add((Id=6261, ItemName="LetsGetCrazy", 	EffectPSName="FX_Headshot_Alt_EMIT.FX_Headshot_Alt_Confetti_01",					IconPath="EMOTE_TEX.Emote_LetsGoCrazy_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Confetti_Headshot')
	HeadShotEffects.Add((Id=6262, ItemName="LetsGetCrazy", 	EffectPSName="FX_Headshot_Alt_EMIT.FX_Headshot_Alt_Ghost_01",						IconPath="EMOTE_TEX.Emote_LetsGoCrazy_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Ghost_Headshot')
	HeadShotEffects.Add((Id=6263, ItemName="LetsGetCrazy", 	EffectPSName="FX_Headshot_Alt_EMIT.FX_Headshot_Alt_Hearts_01",						IconPath="EMOTE_TEX.Emote_LetsGoCrazy_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Hearts_Headshot')
	HeadShotEffects.Add((Id=6264, ItemName="LetsGetCrazy", 	EffectPSName="FX_Headshot_Alt_EMIT.FX_Headshot_Alt_Comic_01",						IconPath="EMOTE_TEX.Emote_LetsGoCrazy_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Pixel_Headshot')
	HeadShotEffects.Add((Id=7042, ItemName="LetsGetCrazy", 	EffectPSName="FX_Headshot_Alt_EMIT.HeadShot_Pack_2.FX_Headshot_Alt2_Flower_01", 	IconPath="EMOTE_TEX.Emote_LetsGoCrazy_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Flower_Headshot')
	HeadShotEffects.Add((Id=7043, ItemName="LetsGetCrazy", 	EffectPSName="FX_Headshot_Alt_EMIT.HeadShot_Pack_2.FX_Headshot_Alt2_Splatter_01",	IconPath="EMOTE_TEX.Emote_LetsGoCrazy_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Splatter_A_Headshot')
	HeadShotEffects.Add((Id=7044, ItemName="LetsGetCrazy", 	EffectPSName="FX_Headshot_Alt_EMIT.HeadShot_Pack_2.FX_Headshot_Alt2_Gameover_01",	IconPath="EMOTE_TEX.Emote_LetsGoCrazy_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Gameover_Headshot')
	HeadShotEffects.Add((Id=7045, ItemName="LetsGetCrazy", 	EffectPSName="FX_Headshot_Alt_EMIT.HeadShot_Pack_2.FX_Headshot_Alt2_Glitch_01",		IconPath="EMOTE_TEX.Emote_LetsGoCrazy_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Glitch_Headshot')
	HeadShotEffects.Add((Id=7046, ItemName="LetsGetCrazy", 	EffectPSName="FX_Headshot_Alt_EMIT.HeadShot_Pack_2.FX_Headshot_Alt2_Headscan_01",	IconPath="EMOTE_TEX.Emote_LetsGoCrazy_512", HeadshotSoundEffect=AkEvent'WW_Headshot_Packs.Play_WEP_Headscan_Headshot')

	EquippedHeadshotId=-1
}