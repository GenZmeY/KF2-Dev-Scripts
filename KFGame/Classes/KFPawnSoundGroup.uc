//=============================================================================
// KFPawnSoundGroup
//=============================================================================
// Constains static data on sounds that are tied to a specific character
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFPawnSoundGroup extends Object;

/*********************************************************************************************
* Footstep sounds
 ********************************************************************************************* */

struct FootstepSoundInfo
{
	var() EMaterialTypes MaterialType;
	var() AkBaseSoundObject Sound;
};

/** footstep sound effect to play per material type */
var(Footsteps) array<FootstepSoundInfo> FootstepSounds;
/** default footstep sound used when a given material type is not found in the list */
var(Footsteps) AkBaseSoundObject DefaultFootstepSound;

/** sprinting/charging footstep sound effect to play per material type */
var(Footsteps) array<FootstepSoundInfo> SprintingFootstepSounds;
/** default sprinting/charging footstep sound used when a given material type is not found in the list */
var(Footsteps) AkBaseSoundObject DefaultSprintingFootstepSound;

/** "hand-step" sound effect to play per material type */
var(Footsteps) array<FootstepSoundInfo> HandstepSounds;
/** default hand-step sound used when a given material type is not found in the list */
var(Footsteps) AkBaseSoundObject DefaultHandstepSound;

/** Maximum range to allow footstep sounds. X=Maximum range when pawn visible, Y=Maximum range when pawn hidden */
var(Footsteps) vector2D MaxFootstepSoundRanges;

/*********************************************************************************************
* Jumping sounds
 ********************************************************************************************* */

var(Jumping) array<FootstepSoundInfo> JumpingSounds;
var(Jumping) AkBaseSoundObject DefaultJumpingSound;

var(Landing) array<FootstepSoundInfo> LandingSounds;
var(Landing) AkBaseSoundObject DefaultLandingSound;

var(Landing) AkBaseSoundObject FallingDamageLandSound;

/*********************************************************************************************
* Damage / Pain
 ********************************************************************************************* */

var(Misc) AkBaseSoundObject PainSound;
var(Misc) AkBaseSoundObject DyingSound;
var(Misc) AkBaseSoundObject MouthlessDyingSound;
var(Misc) AkBaseSoundObject BleedoutDyingSound;

var(Misc) AkBaseSoundObject GibSound;
var(Misc) AkBaseSoundObject GaspSound;

var(Misc) AkBaseSoundObject EntranceSound;

var(Gore) AkBaseSoundObject DismembermentSound;
var(Gore) AkBaseSoundObject BloodSpraySound;
var(Gore) AkBaseSoundObject DismemberedPartImpactSound;
var(Gore) AkBaseSoundObject VisceraImpactSound;
var(Gore) AkBaseSoundObject HeadPopSound;
var(Gore) AkBaseSoundObject RagdollImpactSound;
var(Gore) AkBaseSoundObject CleaveSound;
var(Gore) AkBaseSoundObject ObliterationSound;

/*********************************************************************************************
* Misc
 ********************************************************************************************* */

/** Special stop event to let the audio system stop certain sounds */
 var(Misc) AKEvent   OnDeathStopEvent;

struct ImpactSoundCoolDownInfo
{
    var EHitZoneBodyPart    Limb;
    var name                BoneName;
    var float               LastImpactSoundTime;

	structdefaultproperties
	{
		LastImpactSoundTime=0.f
	}
};

var transient array< ImpactSoundCoolDownInfo > ImpactSoundCoolDowns;

function PlayJumpSound(Pawn P)
{
    if( DefaultJumpingSound != none )
    {
        P.PlaySoundBase(DefaultJumpingSound, false, true);
    }
}

function PlayLandSound(Pawn P)
{
	if( DefaultLandingSound != none )
	{
		P.PlaySoundBase(DefaultLandingSound, false, true);
	}
}

function PlayFallingDamageLandSound(Pawn P)
{
	if( FallingDamageLandSound != none )
	{
		P.PlaySoundBase(FallingDamageLandSound, false, true);
	}
}

function PlayPainSound( KFPawn P )
{
    if( PainSound != none && !P.IsHeadless() )
    {
        P.PlaySoundBase( PainSound, true );
    }
}

function PlayDyingSound(Pawn P)
{
    if( DyingSound != none )
    {
	   P.PlaySoundBase( DyingSound, true );
    }
}

function PlayMouthlessDyingSound( Pawn P )
{
    if( MouthlessDyingSound != none )
    {
        P.PlaySoundBase( MouthlessDyingSound, true );
    }
}

function PlayBleedoutDyingSound( Pawn P )
{
    if( BleedoutDyingSound != none )
    {
        P.PlaySoundBase( BleedoutDyingSound, true );
    }
}

function PlayGibSound(Pawn P)
{
    if( GibSound != none )
    {
	   P.PlaySoundBase(GibSound, true);
    }
}

function PlayGaspSound(Pawn P)
{
    if( GaspSound != none )
    {
	   P.PlaySoundBase(GaspSound, true);
    }
}

function PlayEntranceSound( Pawn P )
{
    if( EntranceSound != none )
    {
        P.PlaySoundBase(EntranceSound);
    }
}

function AkBaseSoundObject GetFootstepSound(int FootDown, EMaterialTypes MaterialType)
{
	local int i;

	if( FootDown < 2 ) // 0 - left foot, 1 - right foot
	{
		i = FootstepSounds.Find('MaterialType', MaterialType);
		return (i == INDEX_None) ? DefaultFootstepSound : FootstepSounds[i].Sound;
	}
	else if( FootDown < 4 ) // 2 - left hand, 3 - right hand
	{
		i = HandstepSounds.Find('MaterialType', MaterialType);
		return (i == INDEX_None) ? DefaultHandstepSound : HandstepSounds[i].Sound;
	}
	else
	{
		return DefaultFootstepSound;
	}
}

function AkBaseSoundObject GetSprintingFootstepSound(int FootDown, EMaterialTypes MaterialType)
{
	local int i;

	if( FootDown < 2 ) // 0 - left foot, 1 - right foot
	{
	   i = SprintingFootstepSounds.Find('MaterialType', MaterialType);
	   return (i == INDEX_None) ? DefaultSprintingFootstepSound : SprintingFootstepSounds[i].Sound;
	}
	else
	{
	   return DefaultSprintingFootstepSound;
	}
}

function AkBaseSoundObject GetJumpSound(EMaterialTypes MaterialType)
{
	local int i;
	i = default.JumpingSounds.Find('MaterialType', MaterialType);
	return (i == INDEX_None) ? DefaultJumpingSound : JumpingSounds[i].Sound;
}

function AkBaseSoundObject GetLandSound(EMaterialTypes MaterialType)
{
	local int i;
	i = default.LandingSounds.Find('MaterialType', MaterialType);
	return (i == INDEX_None) ? DefaultLandingSound : LandingSounds[i].Sound;
}

function PlayDismembermentSounds( Pawn P, vector DismembermentLoc )
{
    if( DismembermentSound != none )
    {
        P.PlaySoundBase( DismembermentSound, true,,, DismembermentLoc );
    }

    if( BloodSpraySound != none )
    {
        P.PlaySoundBase( BloodSpraySound, true ); // attach to bone?
    }
}

function PlayRigidBodyCollisionSound( Pawn P, vector ImpactLoc )
{
    // play part-specific sound?

    local name CollidingBoneName;
    local int HitZoneIndex, ImpactLimbIndex;

    CollidingBoneName = P.Mesh.FindClosestBone( ImpactLoc );

	HitZoneIndex = KFPawn( P ).HitZones.Find( 'BoneName', CollidingBoneName );
	if( HitZoneIndex != INDEX_NONE )
	{
        ImpactLimbIndex = ImpactSoundCoolDowns.Find('BoneName', CollidingBoneName);
        if( ImpactLimbIndex == INDEX_NONE )
        {
            ImpactLimbIndex = ImpactSoundCoolDowns.Add( 1 );
            ImpactSoundCoolDowns[ ImpactLimbIndex ].BoneName = CollidingBoneName;
            ImpactSoundCoolDowns[ ImpactLimbIndex ].LastImpactSoundTime = P.WorldInfo.TimeSeconds;

            if( DismemberedPartImpactSound != none )
            {
                P.PlaySoundBase( DismemberedPartImpactSound, true,,, ImpactLoc );
            }
        }
        else if( P.WorldInfo.TimeSeconds - ImpactSoundCoolDowns[ImpactLimbIndex].LastImpactSoundTime > 0.5 )
        {
            ImpactSoundCoolDowns[ ImpactLimbIndex ].LastImpactSoundTime = P.WorldInfo.TimeSeconds;

            if( DismemberedPartImpactSound != none )
            {
                P.PlaySoundBase( DismemberedPartImpactSound, true,,, ImpactLoc );
            }
        }
	}
}

simulated function PlayGibletCollisionSound( KFGiblet Gib, vector ImpactLoc )
{
    Gib.PlaySoundBase(DismemberedPartImpactSound, true,,, ImpactLoc);
}

function PlayHeadPopSounds( Pawn P, vector SoundLoc )
{
    if( HeadPopSound != none )
    {
        P.PlaySoundBase( HeadPopSound, true,,, SoundLoc );
    }

    PlayBloodSpraySound( P );
}

function PlayCleaveSound( Pawn P, vector SoundLoc )
{
    if( CleaveSound != none )
    {
        P.PlaySoundBase( CleaveSound, true,,, SoundLoc );
    }

    PlayBloodSpraySound( P );
}

function bool ShouldPlayCleaveSound( name DismemberBoneName )
{
    return  DismemberBoneName == 'Spine1'
            || DismemberBoneName == 'LeftShoulder'
            || DismemberBoneName == 'RightShoulder';
}

function PlayObliterationSound( Pawn P, optional bool bNotReplicated=TRUE )
{
    if( ObliterationSound != none )
    {
        P.PlaySoundBase( ObliterationSound, bNotReplicated,,, P.Location );
    }
}

function PlayBloodSpraySound( Pawn P )
{
    if( BloodSpraySound != none )
    {
        P.PlaySoundBase( BloodSpraySound, true ); // attach to bone?
    }
}

defaultproperties
{
    FootstepSounds(0)=(MaterialType=EMT_None, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Dirt')
    FootstepSounds(1)=(MaterialType=EMT_Rock, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Brick')
    FootstepSounds(2)=(MaterialType=EMT_Dust, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Dirt')
    FootstepSounds(3)=(MaterialType=EMT_Mud, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Mud')
    FootstepSounds(4)=(MaterialType=EMT_Grass, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Grass')
    FootstepSounds(5)=(MaterialType=EMT_Water, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Water')
    FootstepSounds(6)=(MaterialType=EMT_WaterShallow, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Water')
    FootstepSounds(7)=(MaterialType=EMT_Snow, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Snow')
    FootstepSounds(8)=(MaterialType=EMT_Ice, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Snow')
    FootstepSounds(9)=(MaterialType=EMT_Concrete, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Stone')
    FootstepSounds(10)=(MaterialType=EMT_Gravel, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Stone')
    FootstepSounds(11)=(MaterialType=EMT_Rubber, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Flesh')
    FootstepSounds(12)=(MaterialType=EMT_Asphalt, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Brick')
    MaxFootstepSoundRanges=(X=1500.f,Y=1500.f)

    DefaultFootstepSound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Dirt'
    DefaultSprintingFootstepSound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Dirt'
    DefaultHandstepSound=AkEvent'WW_ZED_Crawler.Play_ZED_Crawler_Sfx_Footstep'

    JumpingSounds(0)=(MaterialType=EMT_None, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Dirt')
    JumpingSounds(1)=(MaterialType=EMT_Rock, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Brick')
    JumpingSounds(2)=(MaterialType=EMT_Dust, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Dirt')
    JumpingSounds(3)=(MaterialType=EMT_Mud, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Mud')
    JumpingSounds(4)=(MaterialType=EMT_Grass, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Grass')
    JumpingSounds(5)=(MaterialType=EMT_Water, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Water')
    JumpingSounds(6)=(MaterialType=EMT_WaterShallow, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Water')
    JumpingSounds(7)=(MaterialType=EMT_Snow, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Snow')
    JumpingSounds(8)=(MaterialType=EMT_Ice, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Snow')
    JumpingSounds(9)=(MaterialType=EMT_Concrete, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Stone')
    JumpingSounds(10)=(MaterialType=EMT_Gravel, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Stone')
    JumpingSounds(11)=(MaterialType=EMT_Rubber, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Flesh')
    JumpingSounds(12)=(MaterialType=EMT_Asphalt, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Brick')

    DefaultJumpingSound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Dirt'

    LandingSounds(0)=(MaterialType=EMT_None, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Dirt')
    LandingSounds(1)=(MaterialType=EMT_Rock, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Brick')
    LandingSounds(2)=(MaterialType=EMT_Dust, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Dirt')
    LandingSounds(3)=(MaterialType=EMT_Mud, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Mud')
    LandingSounds(4)=(MaterialType=EMT_Grass, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Grass')
    LandingSounds(5)=(MaterialType=EMT_Water, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Water')
    LandingSounds(6)=(MaterialType=EMT_WaterShallow, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Water')
    LandingSounds(7)=(MaterialType=EMT_Snow, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Snow')
    LandingSounds(8)=(MaterialType=EMT_Ice, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Snow')
    LandingSounds(9)=(MaterialType=EMT_Concrete, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Stone')
    LandingSounds(10)=(MaterialType=EMT_Gravel, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Stone')
    LandingSounds(11)=(MaterialType=EMT_Rubber, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Flesh')
    LandingSounds(12)=(MaterialType=EMT_Asphalt, Sound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Brick')

    DefaultLandingSound=AkEvent'WW_MVT_Footstep.Play_Boot_Walk_Dirt'

    DyingSound=AkEvent'WW_ZED_Clot_Alpha.ZED_Clot_Alpha_SFX_Death'
    MouthlessDyingSound=AkEvent'WW_ZED_Clot_Alpha.ZED_Clot_Alpha_SFX_Death_Headless'
    BleedoutDyingSound=AkEvent'WW_ZED_Clot_Alpha.ZED_Clot_Alpha_SFX_Bleeding'

    GibSound=AkEvent'WW_ZED_Clot_Alpha.ZED_Clot_Alpha_SFX_Melee_Impact'

    GaspSound=none
    EntranceSound=none

    DismembermentSound=AkEvent'WW_ZED_Gore.Gore_Dismemberment_Hit'
    BloodSpraySound=AkEvent'WW_ZED_Gore.Gore_Blood_Spray'
    DismemberedPartImpactSound=AkEvent'WW_ZED_Gore.Gore_Body_Part_Solid_Impact'
    VisceraImpactSound=AkEvent'WW_ZED_Gore.Gore_Body_Part_Squish_Impact'
    HeadPopSound=AkEvent'WW_ZED_Gore.Gore_Head_Explode'
    RagdollImpactSound=AkEvent'WW_ZED_Gore.Gore_Body_Full_Impact'
    CleaveSound=AkEvent'WW_ZED_Gore.Gore_Blood_Guts_Heavy'
    ObliterationSound=None
}