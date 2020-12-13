//=============================================================================
// KFCharacterInfoBase
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 3/18/2014
//=============================================================================

class KFCharacterInfoBase extends Object
	abstract
	native(Pawn)
	dependsOn(KFPawn, KFDamageType);

/** Mesh scaling */
var(ThirdPerson) float DefaultMeshScale;

/************************************************************************/
/*  Animation Info                                                   */
/************************************************************************/

/** Animation tree to use for a character in this 'family' */
var(ThirdPerson) AnimTree			AnimTreeTemplate;

/** Animation sets to use for a character in this 'family' */
var(ThirdPerson) array<AnimSet>	AnimSets;

/** This pawn's anim info class based on character info */
var(ThirdPerson) KFPawnAnimInfo	AnimArchetype;

/** Physics Asset to use  */
var(ThirdPerson) PhysicsAsset		PhysAsset;

/************************************************************************/
/*  Effects					                                    */
/************************************************************************/

var(Effects) KFPawnSoundGroup 	   SoundGroupArch;
//var(Effects) class<KFVoiceInfo>	   		VoiceClass;
//var(Effects) class< KFPawnVoiceGroup >    VoiceGroupArch;
var(Effects) string				 	VoiceGroupArchName;

/** Skin Type definition for impact effects */
var(Effects) array<KFSkinTypeEffects> ImpactSkins;

/** This is the bone from which the the trace for the blood pool effect will originate. The trace is done
	vertically downwards. If not specified, the root bone (index 0) will be used as blood pool origin */
var(Gore) name BloodPoolOriginBoneName;

/** Character MICs index to use for gameplay effects */
var(Effects) int GoreFXMICIdx;

/** List of additional particle systems that require unique effects and logic per-event */
var(Effects) array<ExtraVFXInfo> ExtraVFX;

/************************************************************************/
/* Character Portrait
*************************************************************************/

var(Portrait) Texture DefaultHeadPortrait;
var(Portrait) array<Texture> DefaultTeamHeadPortrait;

/************************************************************************/
/*  Native Functions												    */
/************************************************************************/

cpptext
{
	// Used by KFCharacterInfo_Human
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent);
}

native function KFCharacterInfoBase Duplicate();

/************************************************************************/
/*  Script Functions												    */
/************************************************************************/
/** Return the texture portrait stored for this character */
function Texture GetCharPortrait()
{
	return DefaultHeadPortrait;
}

/** Sets misc. properties from the character info */
simulated function SetCharacterFromArch( KFPawn KFP, optional KFPlayerReplicationInfo KFPRI )
{
	if ( KFPRI == none)
	{
	 	return;
	}

	// Assign fallback portrait.
	KFPRI.CharPortrait = GetCharPortrait();
	KFPRI.bNetDirty = true;
}

/** Sets the pawns character mesh from it's CharacterInfo, and updates instance of player in map if there is one. */
simulated function SetCharacterMeshFromArch( KFPawn KFP, optional KFPlayerReplicationInfo KFPRI );

simulated function SetBodyMesh( byte CurrentOutfitIndex, KFPawn KFP, optional KFPlayerReplicationInfo KFPRI );
simulated function SetBodySkin(byte CurrentSkinIndex, KFPawn KFP, KFPlayerReplicationInfo KFPRI);

/** Assign an arm mesh and material to this pawn */
function SetFirstPersonArmsFromArch( KFPawn KFP, optional KFPlayerReplicationInfo KFPRI );

static function int GetWeaponAnimSetIdx()
{
	return default.AnimSets.length;
}

function SetCharacterAnimFromArch( KFPawn Pawn )
{
	Pawn.Mesh.AnimSets = AnimSets;
	if( Pawn.Mesh.AnimTreeTemplate != AnimTreeTemplate )
	{
		Pawn.Mesh.SetAnimTreeTemplate( AnimTreeTemplate );
	}
}

defaultproperties
{
	AnimArchetype=KFPawnAnimInfo'ZED_Clot_Anim.AlphaClot_AnimGroup'
	SoundGroupArch=KFPawnSoundGroup'FX_Pawn_Sounds_ARCH.DefaultPawnSounds'

	DefaultMeshScale=1.f
    GoreFXMICIdx=0

	ImpactSkins[0]=KFSkinTypeEffects'FX_Impacts_ARCH.SkinTypes.Flesh'
	ImpactSkins[1]=KFSkinTypeEffects'FX_Impacts_ARCH.SkinTypes.Skull'
}
