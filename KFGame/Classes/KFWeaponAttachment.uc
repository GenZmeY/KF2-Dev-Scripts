//=============================================================================
// KFWeaponAttachment
//=============================================================================
// Base class for third person weapon attachments
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFWeaponAttachment extends Actor
	hidecategories(Object, Movement, Attachment, Collision, Physics, Advanced, Debug, Mobile)
	native;

/*********************************************************************************************
 * @name	Mesh Components
********************************************************************************************* */

/** Editable SkeletalMesh set by the archetype */
var() const SkeletalMesh SkelMesh;

/** Extra pawn anim set when weapon is equipped */
var() AnimSet CharacterAnimSet;
/** Anim set to use for 3rd person weapon anims */
var() AnimSet WeaponAnimSet;

/** Third Person Weapon SkelMesh */
var transient SkeletalMeshComponent WeapMesh;

/** If true this third person weapon is part of the pawn's mesh */
var() bool bWeapMeshIsPawnMesh;

/*********************************************************************************************
 * @name	LaserSight
********************************************************************************************* */

var() bool		bHasLaserSight;
var() const		KFLaserSightAttachment	LaserSightArchetype;
var transient	KFLaserSightAttachment	LaserSight;

/*********************************************************************************************
 * @name	Fire Effects
********************************************************************************************* */

/** A muzzle flash instance */
var KFMuzzleFlash MuzzleFlash;
/** A reference to the muzzle flash template */
var() const KFMuzzleFlash MuzzleFlashTemplate;

var float MaxFireEffectDistance;

/** replicated information on a hit we've taken */
struct native KFTracerInfo
{
	/** Tracer Effect */
    var() ParticleSystem      TracerTemplate;
	/** The velocity the tracer should travel at */
	var() int 				TracerVelocity;
	/** Show the tracer when the weapon is firing in normal time */
	var() bool				bDoTracerDuringNormalTime;
	/** Show the tracer when the weapon is firing in zed time */
	var() bool				bDoTracerDuringZedTime;
	/** How far away the hitlocation has to be to spawn this tracer */
	var int                 MinTracerEffectDistanceSquared;
	/** Actual tracer velocity vector, set at runtime */
	var vector 				VelocityVector;

	structdefaultproperties
	{
		TracerVelocity=7000
		bDoTracerDuringNormalTime=true
        bDoTracerDuringZedTime=false
		MinTracerEffectDistanceSquared=40000
	}
};

/** Tracer effect info per fire mode */
var() array<KFTracerInfo> TracerInfos;

/*********************************************************************************************
 * @name	Material Effects
********************************************************************************************* */

/** MIC for blood effects */
var transient MaterialInstanceConstant	WeaponMIC;
var transient float						BloodParamValue;

const BloodParamName		= 'Scalar_Blood_Contrast';
const MinBloodParamValue	= 0.20f;

/*********************************************************************************************
 * @name	Animation - (using const FNames for 'static' data)
********************************************************************************************* */

/** Replicated state of the 1st person weapon */
enum EWeaponState
{
	WEP_Idle,
	WEP_Reload,
	WEP_ReloadEmpty,
	WEP_Reload_Elite,
	WEP_ReloadEmpty_Elite,
	WEP_ReloadSingle,
	WEP_ReloadSingleEmpty,
	WEP_ReloadSingle_Elite,
	WEP_ReloadSingleEmpty_Elite,
	WEP_ReloadSecondary,
	WEP_ReloadSecondary_Elite,
	WEP_ReloadSecondaryEmpty,
	WEP_ReloadSecondaryEmpty_Elite,
	WEP_ReloadDualsOneEmpty,
	WEP_ReloadDualsOneEmpty_Elite,
	WEP_MeleeBasic,
	WEP_MeleeChain,		// @deprecated
	WEP_MeleeSustained,
	WEP_Melee_L,
	WEP_Melee_R,
	WEP_Melee_F,
	WEP_Melee_B,
	WEP_MeleeHeavy_L,
	WEP_MeleeHeavy_R,
	WEP_MeleeHeavy_F,
	WEP_MeleeHeavy_B,
	WEP_MeleeBlock,
	WEP_Cleaning,
	WEP_Equipping,
	WEP_PutAway,
	WEP_Grenade,
	WEP_Heal,
	WEP_HealQuick,
	WEP_Weld,
	WEP_Custom0,
	WEP_Custom1,
	WEP_Custom2,
	WEP_Custom3,
	WEP_Custom4,
	WEP_Custom5,
	WEP_Custom6,
	WEP_Custom7,
	WEP_Custom8,
	WEP_Custom9,
};

/** Animation rate to scale all of our 3rd person animations by */
var protected transient float ThirdPersonAnimRate;

/** Animation Physics Recoil */
var GameSkelCtrl_Recoil.RecoilDef	Recoil_Hand;
var GameSkelCtrl_Recoil.RecoilDef	Recoil_Spine;

/** MELEE */
const MeleeBasic	= 'Melee';
const CH_MeleeBasic = 'Melee_CH';
/** directional attack anims */
const MeleeAnim_F = 'Atk_F';
const MeleeAnim_B = 'Atk_B';
const MeleeAnim_L = 'Atk_L';
const MeleeAnim_R = 'Atk_R';
const CH_MeleeAnim_F = 'Atk_F_CH';
const CH_MeleeAnim_B = 'Atk_B_CH';
const CH_MeleeAnim_L = 'Atk_L_CH';
const CH_MeleeAnim_R = 'Atk_R_CH';
/** heavy attack anims */
const MeleeHeavy_F = 'Atk_H_F';
const MeleeHeavy_B = 'Atk_H_B';
const MeleeHeavy_L = 'Atk_H_L';
const MeleeHeavy_R = 'Atk_H_R';
const CH_MeleeHeavy_F = 'Atk_H_F_CH';
const CH_MeleeHeavy_B = 'Atk_H_B_CH';
const CH_MeleeHeavy_L = 'Atk_H_L_CH';
const CH_MeleeHeavy_R = 'Atk_H_R_CH';
/** Continious (aka chainsaw) melee */
const MeleeLoopAnim		= 'Atk_F_Loop';
const MeleeStartAnim	= 'Atk_F_In';
const MeleeEndAnim		= 'Atk_F_Out';
const CH_MeleeLoopAnim	= 'Atk_F_Loop_CH';
const CH_MeleeStartAnim	= 'Atk_F_In_CH';
const CH_MeleeEndAnim	= 'Atk_F_Out_CH';
/** blocking/parry anims */
const BlockLoopAnim		= 'Brace_Loop';
const BlockStartAnim	= 'Brace_In';
const BlockEndAnim		= 'Brace_Out';
const CH_BlockLoopAnim	= 'Brace_Loop_CH';
const CH_BlockStartAnim = 'Brace_In_CH';
const CH_BlockEndAnim	= 'Brace_Out_CH';
/** melee misc */
const CleanWeaponAnim	  = 'Clean_NoBlood';
const CH_CleanWeaponAnim  = 'Clean_NoBlood_CH';

/** General, all inventory items anims */
const GrenadeAnim		= 'Nade_Throw';
const EquipAnim			= 'Equip';
const PutAwayAnim		= 'PutAway';
const CH_GrenadeAnim	= 'Nade_Throw_CH';
const CH_EquipAnim		= 'Equip_CH';
const CH_PutAwayAnim	= 'PutAway_CH';

/** Reload (magazine) anims */
const ReloadEmptyAnim			= 'Reload_Empty';
const ReloadHalfAnim			= 'Reload_Half';
const ReloadEmptyEliteAnim		= 'Reload_Empty_Elite';
const ReloadHalfEliteAnim		= 'Reload_Half_Elite';
const ReloadDualsOneEmptyAnim 	= 'Reload_Empty_Half';
const ReloadDualsOneEmptyEliteAnim 	= 'Reload_Empty_Half_Elite';
const CH_ReloadEmptyAnim	  		= 'Reload_Empty_CH';
const CH_ReloadHalfAnim		  		= 'Reload_Half_CH';
const CH_ReloadEmptyEliteAnim 		= 'Reload_Empty_Elite_CH';
const CH_ReloadHalfEliteAnim  		= 'Reload_Half_Elite_CH';
const CH_ReloadDualsOneEmptyAnim 		= 'Reload_Empty_Half_CH';
const CH_ReloadDualsOneEmptyEliteAnim 	= 'Reload_Empty_Half_Elite_CH';
/** Reload (single) anims */
const ReloadOpenAnim			= 'Reload_Open';
const ReloadInsertAnim			= 'Reload_Insert';
const ReloadCloseAnim			= 'Reload_Close';
const ReloadOpenEliteAnim		= 'Reload_Open_Elite';
const ReloadInsertEliteAnim		= 'Reload_Insert_Elite';
const ReloadCloseEliteAnim		= 'Reload_Close_Elite';
const ReloadOpenEmptyAnim		= 'Reload_Open_Shell';
const ReloadOpenEmptyEliteAnim	= 'Reload_Open_Shell_Elite';
const CH_ReloadOpenAnim				= 'Reload_Open_CH';
const CH_ReloadInsertAnim			= 'Reload_Insert_CH';
const CH_ReloadCloseAnim			= 'Reload_Close_CH';
const CH_ReloadOpenEliteAnim		= 'Reload_Open_Elite_CH';
const CH_ReloadInsertEliteAnim		= 'Reload_Insert_Elite_CH';
const CH_ReloadCloseEliteAnim		= 'Reload_Close_Elite_CH';
const CH_ReloadOpenEmptyAnim		= 'Reload_Open_Shell_CH';
const CH_ReloadOpenEmptyEliteAnim	= 'Reload_Open_Shell_Elite_CH';

/** Used only by the healing syringe */
const HealSelfAnim		= 'Healer_Self';
const HealOtherAnim		= 'Healer_F';
const QuickHealAnim		= 'Heal_Quick';
const CH_HealSelfAnim	= 'Healer_Self_CH';
const CH_HealOtherAnim	= 'Healer_F_CH';
const CH_QuickHealAnim	= 'Heal_Quick_CH';
/** Used only by the welder */
const WeldStartAnim		= 'Welder_Start';
const WeldLoopAnim		= 'Welder_Loop';
const WeldEndAnim		= 'Welder_End';
const CH_WeldStartAnim	= 'Welder_Start_CH';
const CH_WeldLoopAnim	= 'Welder_Loop_CH';
const CH_WeldEndAnim	= 'Welder_End_CH';

/** Additive shoot anims */
const ShootAnim			= 'ADD_Shoot';
const CrouchShootAnim	= 'ADD_CH_Shoot';
const IronShootAnim		= 'ADD_Iron_Shoot';
/** Weapon shoots */
const WeaponFireAnim	 = 'Shoot';
const WeaponAltFireAnim	 = 'Shoot';
const WeaponIronFireAnim = 'Iron_Shoot';

/** (TEMP) blend settings */
var(Anims) float DefaultBlendInTime;
var(Anims) float DefaultBlendOutTime;
var(Anims) float ShootBlendInTime;
var(Anims) float ShootBlendOutTime;

/** Enable recoile skeletal controls */
var(Anims) bool bPlayIKRecoil;

/** Save the last random index so we can choose a different one */
var transient byte LastMeleeAnimIdx;

/** If set, check a character AnimNodeSlot and attempt to synchronize the weapon */
var transient bool bSynchronizeWeaponAnim;
var transient AnimNodeSlot	SyncPawnNode;
var transient name			SyncAnimName;
var transient bool			bSyncAnimCheckRelevance;

/** Info for state LoopingWeaponAction */
var transient name LoopingAnim;
var transient name LoopIntroAnim;
var transient name LoopOutroAnim;
var transient bool bLoopSynchedWeaponAnim;

/** Cached AnimNodeSequence for the 3rd person weapon mesh */
var transient AnimNodeSequence WeapAnimNode;

/** Profile name for this weapon */
var(Anims) name AimOffsetProfileName;

/** Used by AimOffset node when bTurnOffWhenReloadingWeapon==TRUE */
var transient bool bIsReloading;

var transient int WeaponSkinId;
var bool bWaitingForWeaponSkinLoad;

/*********************************************************************************************
 * @name	Attach / Detach
********************************************************************************************* */

/** Weapon Mesh Attachment */
native event ChangeVisibility(bool bIsVisible);

/*********************************************************************************************
 * @name	Skins
********************************************************************************************* */

native function bool StartLoadWeaponSkin(int SkinId);

event PreBeginPlay()
{
	local int i;

	if ( WeapMesh != None && !bWeapMeshIsPawnMesh )
	{
		if ( WeaponAnimSet != None )
		{
			WeapMesh.AnimSets[0] = WeaponAnimSet;
		}

		if ( SkelMesh != none )
		{
			// set the skeletal mesh from our archetype to the WeaponAttachment
			WeapMesh.SkeletalMesh = SkelMesh;
		}

		WeapAnimNode = AnimNodeSequence(WeapMesh.Animations);
	}

	for( i = 0; i < TracerInfos.Length; ++i )
	{
		TracerInfos[i].VelocityVector = vect(1,0,0) * TracerInfos[i].TracerVelocity;
	}

 	super.PreBeginPlay();
}

/** Attach weapon to owner's skeletal mesh */
simulated function AttachTo(KFPawn P)
{
	local byte WeaponAnimSetIdx;

    if ( bWeapMeshIsPawnMesh )
	{
		WeapMesh = P.Mesh;
	}
	else if ( WeapMesh != None )
	{
		// Attach Weapon mesh to player skel mesh
		WeapMesh.SetShadowParent(P.Mesh);
		P.Mesh.AttachComponent(WeapMesh, P.WeaponAttachmentSocket);
	}

	// Additional attachments
	if( bHasLaserSight && !P.IsFirstPerson() )
	{
		AttachLaserSight();
	}

	// Animation
	if ( CharacterAnimSet != None )
	{
		WeaponAnimSetIdx = P.CharacterArch.GetWeaponAnimSetIdx();
		P.Mesh.AnimSets[WeaponAnimSetIdx] = CharacterAnimSet;
		// update animations will reload all AnimSeqs with the new AnimSet
		P.Mesh.UpdateAnimations();
	}

	// update aim offset nodes with new profile for this weapon
	P.SetAimOffsetNodesProfile(AimOffsetProfileName);

    //Do a first chance weapon skin switch (EX: changed weapon w/o ID changing by throwing a dualie)
    if (KFPawn_Human(P) != None && KFPawn_Human(P).WeaponSkinItemId > 0)
    {
        SetWeaponSkin(KFPawn_Human(P).WeaponSkinItemId);
    }
}

/** Detach weapon from owner's skeletal mesh */
simulated function DetachFrom(KFPawn P)
{
	// detach effects
	if (MuzzleFlash != None)
	{
		MuzzleFlash.DetachMuzzleFlash(WeapMesh);
	}

	// Finally, detach weapon mesh
	if ( bWeapMeshIsPawnMesh )
	{
		WeapMesh = None;
	}
	else if ( WeapMesh != None )
	{
		WeapMesh.SetShadowParent(None);
		P.Mesh.DetachComponent( WeapMesh );
	}
}

simulated function AttachMuzzleFlash()
{
	if ( WeapMesh != none && MuzzleFlash == None )
	{
		MuzzleFlash = new(self) Class'KFMuzzleFlash'(MuzzleFlashTemplate);
		MuzzleFlash.AttachMuzzleFlash(WeapMesh);
	}
}

simulated function AttachLaserSight()
{
	if ( WeapMesh != none && LaserSight == None && LaserSightArchetype != None )
	{
		LaserSight = new(self) Class'KFLaserSightAttachment' (LaserSightArchetype);
		LaserSight.AttachLaserSight(WeapMesh, false);
	}
}

/**
 * Assign weapon skin to 3rd person mesh
 */
event SetWeaponSkin(int ItemId, optional bool bFinishedLoading = false)
{
	local array<MaterialInterface> SkinMICs;

	if ( ItemId > 0 && WorldInfo.NetMode != NM_DedicatedServer && !bWaitingForWeaponSkinLoad)
	{
		if (!bFinishedLoading && StartLoadWeaponSkin(ItemId))
		{
			return;
		}

		SkinMICs = class'KFWeaponSkinList'.static.GetWeaponSkin(ItemId, WST_ThirdPerson);
		if ( SkinMICs.Length > 0 )
		{
			WeapMesh.SetMaterial(0, SkinMICs[0]);
		}
	}
}

/*********************************************************************************************
 * @name	Fire Effect Methods
********************************************************************************************* */

/**
 * Need to either call Instigator.ActorEffectIsRelevant(), or determine our
 * own Location and LastRenderTime before calling Super.ActorEffectIsRelevant().
 */
simulated function bool ActorEffectIsRelevant(Pawn EffectInstigator, bool bForceDedicated, optional float VisibleCullDistance=5000.0, optional float HiddenCullDistance=350.0 )
{
	if ( Instigator != None )
	{
		return Instigator.ActorEffectIsRelevant(EffectInstigator, bForceDedicated, VisibleCullDistance, HiddenCullDistance);
	}

	return FALSE;
}

/**
 * The Weapon attachment, though hidden, is also responsible for controlling
 * the first person effects for a weapon.
 */
simulated function FirstPersonFireEffects(Weapon W, vector HitLocation)	// Should be subclassed
{
	if ( W != None )
	{
		SpawnTracer(W.GetMuzzleLoc(), HitLocation);
	}
}

simulated function StopFirstPersonFireEffects(Weapon W)	// Should be subclassed
{
	if ( W != None )
	{
		// Tell the weapon to cause the muzzle flash, etc.
		W.StopFireEffects( Pawn(Owner).FiringMode );
	}
}

simulated function StartFire()
{

}

simulated function StartPawnCrouch ()
{

}

simulated function EndPawnCrouch ()
{

}

simulated function SetWeaponUsingIronSights (bool bUsingIronSights)
{
}

simulated function SetWeaponAltFireMode (bool bUsingAltFireMode)
{

}

/**
 * Spawn all of the effects that will be seen in behindview/remote clients.  This
 * function is called from the pawn, and should only be called when on a remote client or
 * if the local client is in a 3rd person mode.
 * @return TRUE if the effect culling check passes
*/
simulated function bool ThirdPersonFireEffects( vector HitLocation, KFPawn P, byte ThirdPersonAnimRateByte )
{
	local EAnimSlotStance AnimType;

    SpawnTracer(GetMuzzleLocation(), HitLocation);

	// Effects below this point are culled based on visibility and distance
	if ( !ActorEffectIsRelevant(P, false, MaxFireEffectDistance) )
	{
		return false;
	}

	DecodeThirdPersonAnimRate( ThirdPersonAnimRateByte );

	// Weapon shoot anims
	if( !bWeapMeshIsPawnMesh )
	{
		PlayWeaponFireAnim();
	}

	if( P.IsDoingSpecialMove() && P.SpecialMoves[P.SpecialMove].bAllowFireAnims )
	{
		AnimType = EAS_Additive;
	}
	else
	{
		AnimType = EAS_FullBody;
	}

	// Character shoot anims
	if ( !P.IsDoingSpecialMove() || AnimType == EAS_Additive )
	{
		PlayPawnFireAnim( P, AnimType );

		// interrupt other weapon action anims (e.g. Reload)
		if( !P.IsDoingSpecialMove() )
		{
			P.StopBodyAnim(P.bIsCrouched ? EAS_CH_UpperBody : EAS_UpperBody, 0.1f);
		}

		if ( OnWeaponStateChanged != None )
		{
			OnWeaponStateChanged(true);
		}
	}

	CauseMuzzleFlash(P.FiringMode);
	return true;
}

/** Plays fire animation on weapon mesh */
simulated function PlayWeaponFireAnim()
{
	local float Duration;

	if ( Instigator.bIsWalking )
	{
		Duration = WeapMesh.GetAnimLength( WeaponIronFireAnim );
		WeapMesh.PlayAnim( WeaponIronFireAnim, Duration / ThirdPersonAnimRate,, true );
	}
	else
	{
		Duration = WeapMesh.GetAnimLength( WeaponFireAnim );
		WeapMesh.PlayAnim( WeaponFireAnim, Duration / ThirdPersonAnimRate,, true );
	}
}

/** Plays fire animation on pawn */
simulated function PlayPawnFireAnim( KFPawn P, EAnimSlotStance AnimType )
{
	if ( P.bIsCrouched )
	{
		P.PlayBodyAnim(CrouchShootAnim, AnimType, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
	}
	else if ( P.bIsWalking )
	{
		P.PlayBodyAnim(IronShootAnim, AnimType, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
	}
	else
	{
		P.PlayBodyAnim(ShootAnim, AnimType, ThirdPersonAnimRate, ShootBlendInTime, ShootBlendOutTime);
	}
}

simulated function StopThirdPersonFireEffects(optional bool bForce)
{
	if (MuzzleFlash != None)
	{
        MuzzleFlash.StopMuzzleFlash(bForce);
	}
}

/** @return the starting location for effects (e.g. tracers) */
simulated function vector GetMuzzleLocation(optional byte MuzzleID)
{
	local vector SocketLocation;

	if ( MuzzleFlashTemplate != none )
	{
		WeapMesh.GetSocketWorldLocationAndRotation(MuzzleFlashTemplate.GetSocketName(), SocketLocation);
		return SocketLocation;
	}
	else
	{
		`log("Missing 3rd person muzzle socket for"@SkelMesh);
		return WeapMesh.Bounds.Origin + (vect(45,0,0) >> Instigator.Rotation);
	}
}

/** Spawn tracer effects for this weapon */
simulated function SpawnTracer(vector EffectLocation, vector HitLocation)
{
	local ParticleSystemComponent E;
	local vector Dir;
	local float DistSQ;
	local float TracerDuration;
	local KFTracerInfo TracerInfo;

	if ( Instigator == None || Instigator.FiringMode >= TracerInfos.Length )
	{
		return;
	}

	TracerInfo = TracerInfos[Instigator.FiringMode];
    if( ((`NotInZedTime(self) && TracerInfo.bDoTracerDuringNormalTime)
        || (`IsInZedTime(self) && TracerInfo.bDoTracerDuringZedTime))
        && TracerInfo.TracerTemplate != none )
    {
        Dir = HitLocation - EffectLocation;
		DistSQ = VSizeSq(Dir);
    	if ( DistSQ > TracerInfo.MinTracerEffectDistanceSquared )
    	{
    		// Lifetime scales based on the distance from the impact point. Subtract a frame so it doesn't clip.
			TracerDuration = fMin( (Sqrt(DistSQ) - 100.f) / TracerInfo.TracerVelocity, 1.f );
			if( TracerDuration > 0.f )
			{
	    		E = WorldInfo.MyEmitterPool.SpawnEmitter( TracerInfo.TracerTemplate, EffectLocation, rotator(Dir) );
	 			E.SetVectorParameter( 'Tracer_Velocity', TracerInfo.VelocityVector );
	 			E.SetFloatParameter( 'Tracer_Lifetime', TracerDuration );
	 		}
    	}
	}
}

/** Attach if needed, trigger muzzle flash, trigger shell eject */
simulated function CauseMuzzleFlash(byte FiringMode)
{
	if (MuzzleFlash == None && MuzzleFlashTemplate != None)
	{
		AttachMuzzleFlash();
	}

	if (MuzzleFlash != None )
	{
		MuzzleFlash.CauseMuzzleFlash(FiringMode);
		if ( MuzzleFlash.bAutoActivateShellEject )
		{
			MuzzleFlash.CauseShellEject();
		}
	}
}

/** notify to spawn a shell eject from the muzzle flash component */
simulated function ANIMNOTIFY_ShellEject()
{
	if (MuzzleFlash == None && MuzzleFlashTemplate != None)
	{
		MuzzleFlash = new(self) Class'KFMuzzleFlash'(MuzzleFlashTemplate);
		MuzzleFlash.AttachMuzzleFlash(WeapMesh);
	}

	if (MuzzleFlash != None )
	{
		MuzzleFlash.CauseShellEject();
	}
}

/** Adds some value to this weapon's blood material parameter */
simulated function AddBattleBlood(float InBloodParamIncrementValue)
{
	// Weapon shoot anims
	if( !bWeapMeshIsPawnMesh )
	{
		if ( WeaponMIC == None && WeapMesh != None )
		{
			WeaponMIC = WeapMesh.CreateAndSetMaterialInstanceConstant(0);
		}

		if ( WeaponMIC != None )
		{
			BloodParamValue = FMax(BloodParamValue + InBloodParamIncrementValue, MinBloodParamValue);
			WeaponMIC.SetScalarParameterValue(BloodParamName, BloodParamValue);
		}
	}
}

/*********************************************************************************************
 * @name	Character Animation
********************************************************************************************* */

delegate OnWeaponStateChanged(optional bool bInterrupted);

/**
 * Plays a split (upper and lower body) animation on the owning pawn
 * Network: All but dedicated
 *
 * @param P								Owning pawn to play animation on
 * @param AnimName						Anim to play
 * @param bPlaySynchronizedWeaponAnim	If true, try to play the same animation on the weapon mesh
 */
simulated function float PlayCharacterMeshAnim(KFPawn P, name AnimName, optional bool bPlaySynchedWeaponAnim, optional bool bLooping)
{
	local float Duration;
	local EAnimSlotStance Stance;

	// skip weapon anims while in a special move
	if( P.IsDoingSpecialMove() && !P.SpecialMoves[P.SpecialMove].bAllowThirdPersonWeaponAnims )
	{
		return 0.f;
	}

	Stance = (!P.bIsCrouched) ? EAS_UpperBody : EAS_CH_UpperBody;
	Duration = P.PlayBodyAnim(AnimName, Stance, ThirdPersonAnimRate, DefaultBlendInTime, DefaultBlendOutTime, bLooping);

	if ( Duration > 0 && bPlaySynchedWeaponAnim )
	{
		PlayWeaponMeshAnim(AnimName, P.BodyStanceNodes[Stance], bLooping);
	}

	`log(GetFuncName()@"called on:"$P@"Anim:"$AnimName@"Duration:"$Duration, bDebug);

	return Duration;
}

function DecodeThirdPersonAnimRate( byte ThirdPersonAnimRateByte )
{
	ThirdPersonAnimRate = 1.f + ByteToFloat( ThirdPersonAnimRateByte );
}

/** Called from the pawn when our first person weapon changes states */
simulated function UpdateThirdPersonWeaponAction(EWeaponState NewWeaponState, KFPawn P, byte ThirdPersonAnimRateByte )
{
	ClearTimer(nameof(LoopWeaponMeleeAnim));
	bIsReloading = false;

	// We need our anim rate scale before doing anything
	DecodeThirdPersonAnimRate( ThirdPersonAnimRateByte );

	if ( OnWeaponStateChanged != None )
	{
		OnWeaponStateChanged();
	}

	`log(GetFuncName()@"called on"@self@"State:"@EWeaponState(NewWeaponState), bDebug);

	switch (NewWeaponState)
	{
	case WEP_Equipping:
		PlayCharacterMeshAnim(P, P.bIsCrouched ? CH_EquipAnim : EquipAnim);
		break;
	case WEP_PutAway:
		PlayCharacterMeshAnim(P, P.bIsCrouched ? CH_PutAwayAnim : PutAwayAnim);
		break;
	case WEP_Grenade:
		PlayCharacterMeshAnim(P, P.bIsCrouched ? CH_GrenadeAnim : GrenadeAnim);
		break;
	case WEP_Heal:
		PlayHealAnim(P);
		break;
	case WEP_HealQuick:
		PlayCharacterMeshAnim(P, P.bIsCrouched ? CH_QuickHealAnim : QuickHealAnim);
		break;
	case WEP_Weld:
		PlayWeldAnim(P);
		break;
	case WEP_Cleaning:
		PlayCharacterMeshAnim(P, P.bIsCrouched ? CH_CleanWeaponAnim : CleanWeaponAnim);
		break;
	case WEP_MeleeBasic:
	//case WEP_MeleeChain:
	case WEP_Melee_B:
	case WEP_Melee_F:
	case WEP_Melee_L:
	case WEP_Melee_R:
	case WEP_MeleeHeavy_B:
	case WEP_MeleeHeavy_F:
	case WEP_MeleeHeavy_L:
	case WEP_MeleeHeavy_R:
		PlayMeleeAtkAnim(NewWeaponState, P);
		break;
	case WEP_MeleeSustained:
		PlayMeleeSustainedAnim(P);
		break;
	case WEP_MeleeBlock:
		PlayMeleeBlockAnim(P);
		break;
	case WEP_Reload:
	case WEP_ReloadEmpty:
	case WEP_Reload_Elite:
	case WEP_ReloadEmpty_Elite:
	case WEP_ReloadSecondary:
	case WEP_ReloadSecondary_Elite:
	case WEP_ReloadDualsOneEmpty:
	case WEP_ReloadDualsOneEmpty_Elite:
	case WEP_ReloadSecondaryEmpty:
	case WEP_ReloadSecondaryEmpty_Elite:
		bIsReloading = true;
		PlayReloadMagazineAnim(NewWeaponState, P);
		break;
	case WEP_ReloadSingle:
	case WEP_ReloadSingle_Elite:
	case WEP_ReloadSingleEmpty:
	case WEP_ReloadSingleEmpty_Elite:
		bIsReloading = true;
		PlayReloadSingleAnim(NewWeaponState, P);
		break;
	}
}

/** Play a melee attack animation */
simulated function float PlayMeleeAtkAnim(EWeaponState NewWeaponState, KFPawn P)
{
	local name AnimName;
	local float Duration;

	// third-person melee notifies don't properly handle the bIgnoreIfActorHidden setting because their owning actor isn't ever hidden (because it's the pawn),
	// so just don't play third-person melee anims on first-person pawns (there's no need to anyway)
	if( P.IsFirstPerson() )
	{
		return Duration;
	}

	switch (NewWeaponState)
	{
	case WEP_MeleeBasic:
		AnimName = P.bIsCrouched ? CH_MeleeBasic : MeleeBasic;
		break;
	case WEP_MeleeHeavy_B:
		AnimName = P.bIsCrouched ? CH_MeleeHeavy_B : MeleeHeavy_B;
		break;
	case WEP_MeleeHeavy_F:
		AnimName = P.bIsCrouched ? CH_MeleeHeavy_F : MeleeHeavy_F;
		break;
	case WEP_MeleeHeavy_L:
		AnimName = P.bIsCrouched ? CH_MeleeHeavy_L : MeleeHeavy_L;
		break;
	case WEP_MeleeHeavy_R:
		AnimName = P.bIsCrouched ? CH_MeleeHeavy_R : MeleeHeavy_R;
		break;
	case WEP_Melee_B:
		AnimName = P.bIsCrouched ? CH_MeleeAnim_B : MeleeAnim_B;
		break;
	case WEP_Melee_F:
		AnimName = P.bIsCrouched ? CH_MeleeAnim_F : MeleeAnim_F;
		break;
	case WEP_Melee_L:
		AnimName = P.bIsCrouched ? CH_MeleeAnim_L : MeleeAnim_L;
		break;
	case WEP_Melee_R:
		AnimName = P.bIsCrouched ? CH_MeleeAnim_R : MeleeAnim_R;
		break;
	//case WEP_MeleeChain:
	//	AnimName = GetRandomDirectionalMeleeAnim(P);
	//	break;
	}

	if ( AnimName != '' )
	{
		Duration = PlayCharacterMeshAnim(P, AnimName);

		//if ( WeaponState == WEP_MeleeChain && Duration > 0 )
		//{
		//	SetTimer(FMax(0.01, Duration - MeleeLoopAtkTimeFromEnd), false, nameof(LoopWeaponMeleeAnim));
		//}
	}

	return Duration;
}

/** Helper for PlayMeleeAtkAnim */
simulated function name GetRandomDirectionalMeleeAnim(Pawn P)
{
	local byte AnimIdx, NumTries;

	do
	{
		// pick a random animation, different than the last
		AnimIdx = Rand(4);
		NumTries++;
	} until ( LastMeleeAnimIdx != AnimIdx || NumTries >= 4 );

	LastMeleeAnimIdx = AnimIdx;

	switch (AnimIdx)
	{
	case 0:
		return P.bIsCrouched ? CH_MeleeAnim_F : MeleeAnim_F;
	case 1:
		return P.bIsCrouched ? CH_MeleeAnim_B : MeleeAnim_B;
	case 2:
		return P.bIsCrouched ? CH_MeleeAnim_L : MeleeAnim_L;
	case 3:
		return P.bIsCrouched ? CH_MeleeAnim_R : MeleeAnim_R;
	}
}

/** Restart (aka Loop) this weapon state animation */
simulated function LoopWeaponMeleeAnim()
{
	local KFPawn P;

	P = KFPawn(Owner);
	if ( P != None && !P.IsDoingSpecialMove() )
	{
		UpdateThirdPersonWeaponAction( WEP_MeleeChain, P, P.GetWeaponAttachmentAnimRateByte() );
	}
}

/** Play a 3rd person weapon action anim */
simulated function PlayMeleeBlockAnim(KFPawn P)
{
	if ( P.bIsCrouched )
	{
		StartLoopingAnim(P, CH_BlockLoopAnim, CH_BlockStartAnim, CH_BlockEndAnim);
	}
	else
	{
		StartLoopingAnim(P, BlockLoopAnim, BlockStartAnim, BlockEndAnim);
	}
}

/** Play a 3rd person weapon action anim */
simulated function PlayMeleeSustainedAnim(KFPawn P)
{
	if ( P.bIsCrouched )
	{
		StartLoopingAnim(P, CH_MeleeLoopAnim, CH_MeleeStartAnim, CH_MeleeEndAnim);
	}
	else
	{
		StartLoopingAnim(P, MeleeLoopAnim, MeleeStartAnim, MeleeEndAnim);
	}
}

/** Play a 3rd person reload animation */
simulated function PlayReloadMagazineAnim(EWeaponState NewWeaponState, KFPawn P)
{
	local name AnimName;

	switch (NewWeaponState)
	{
	case WEP_Reload:
		AnimName = (!P.bIsCrouched) ? ReloadHalfAnim : CH_ReloadHalfAnim;
		break;
	case WEP_ReloadEmpty:
		AnimName = (!P.bIsCrouched) ? ReloadEmptyAnim : CH_ReloadEmptyAnim;
		break;
	case WEP_ReloadDualsOneEmpty:
		AnimName = (!P.bIsCrouched) ? ReloadDualsOneEmptyAnim : CH_ReloadDualsOneEmptyAnim;
		break;
	case WEP_Reload_Elite:
		AnimName = (!P.bIsCrouched) ? ReloadHalfEliteAnim : CH_ReloadHalfEliteAnim;
		break;
	case WEP_ReloadEmpty_Elite:
		AnimName = (!P.bIsCrouched) ? ReloadEmptyEliteAnim : CH_ReloadEmptyEliteAnim;
		break;
	case WEP_ReloadDualsOneEmpty_Elite:
		AnimName = (!P.bIsCrouched) ? ReloadDualsOneEmptyEliteAnim : CH_ReloadDualsOneEmptyEliteAnim;
		break;
	}

	PlayCharacterMeshAnim(P, AnimName, true);
}

/** Play a 3rd person reload animation */
simulated function PlayReloadSingleAnim(EWeaponState NewWeaponState, KFPawn P)
{
	switch (NewWeaponState)
	{
	case WEP_ReloadSingle:
		if ( P.bIsCrouched )
			StartLoopingAnim(P, CH_ReloadInsertAnim, CH_ReloadOpenAnim, CH_ReloadCloseAnim, true);
		else
			StartLoopingAnim(P, ReloadInsertAnim, ReloadOpenAnim, ReloadCloseAnim, true);
		break;
	case WEP_ReloadSingle_Elite:
		if ( P.bIsCrouched )
			StartLoopingAnim(P, CH_ReloadInsertEliteAnim, CH_ReloadOpenEliteAnim, CH_ReloadCloseEliteAnim, true);
		else
			StartLoopingAnim(P, ReloadInsertEliteAnim, ReloadOpenEliteAnim, ReloadCloseEliteAnim, true);
		break;
	case WEP_ReloadSingleEmpty:
		if ( P.bIsCrouched )
			StartLoopingAnim(P, CH_ReloadInsertAnim, CH_ReloadOpenEmptyAnim, CH_ReloadCloseAnim, true);
		else
			StartLoopingAnim(P, ReloadInsertAnim, ReloadOpenEmptyAnim, ReloadCloseAnim, true);
		break;
	case WEP_ReloadSingleEmpty_Elite:
		if ( P.bIsCrouched )
			StartLoopingAnim(P, CH_ReloadInsertEliteAnim, CH_ReloadOpenEmptyEliteAnim, CH_ReloadCloseEliteAnim, true);
		else
			StartLoopingAnim(P, ReloadInsertEliteAnim, ReloadOpenEmptyEliteAnim, ReloadCloseEliteAnim, true);
		break;
	}
}

/** Play a 3rd person heal animation */
simulated function PlayHealAnim(KFPawn P)
{
	if ( P.bIsCrouched )
	{
		PlayCharacterMeshAnim(P, (P.FiringMode == 0) ?  CH_HealOtherAnim : CH_HealSelfAnim);
	}
	else
	{
		PlayCharacterMeshAnim(P, (P.FiringMode == 0) ?  HealOtherAnim : HealSelfAnim);
	}
}

/* Plays a 3rd person weld animation */
simulated function PlayWeldAnim(KFPawn P)
{
	if ( P.bIsCrouched )
	{
		StartLoopingAnim(P, CH_WeldLoopAnim, CH_WeldStartAnim, CH_WeldEndAnim);
	}
	else
	{
		StartLoopingAnim(P, WeldLoopAnim, WeldStartAnim, WeldEndAnim);
	}
}

/*********************************************************************************************
 * @name	Weapon Animation
********************************************************************************************* */

simulated function PlayWeaponMeshAnim(name AnimName, AnimNodeSlot SyncNode, bool bLoop)
{
	local float Duration;

	// Weapon shoot anims
	if( !bWeapMeshIsPawnMesh )
	{
		Duration = WeapMesh.GetAnimLength(AnimName);
		WeapMesh.PlayAnim(AnimName, Duration / ThirdPersonAnimRate, bLoop);

		// syncronize this with the character anim
		if ( SyncNode != None )
		{
			bSynchronizeWeaponAnim = true;
			SyncPawnNode = SyncNode;
			SyncAnimName = AnimName;
			bSyncAnimCheckRelevance = false;
		}
	}
}

/** Tick is used by bSynchronizeWeaponAnim */
simulated event Tick( float DeltaTime )
{
	// If we're playing a a syncronzied weapon action, check the owner pawn's animation
	if ( !bWeapMeshIsPawnMesh && bSynchronizeWeaponAnim && SyncPawnNode != None && WeapMesh.bForceRefpose == 0 )
	{
		// check to see if the character anim is still playing
		if ( !SyncPawnNode.bIsPlayingCustomAnim
			|| (!SyncPawnNode.bRelevant && bSyncAnimCheckRelevance)
			|| SyncPawnNode.GetPlayedAnimation() != SyncAnimName )
		{
			if ( WeapAnimNode.bPlaying && WeapAnimNode.AnimSeqName == SyncAnimName )
			{
				InterruptWeaponAnim();
			}
			bSynchronizeWeaponAnim = false;
		}

		// After character mesh has been ticked once start checking node relevance
		bSyncAnimCheckRelevance = true;
	}
}

/** Stops a currently playing 3rd person weapon animation */
simulated function InterruptWeaponAnim()
{
	// Weapon shoot anims
	if( !bWeapMeshIsPawnMesh )
	{
		WeapAnimNode.StopAnim();

		// Return to RefPos, because StopAnim doesn't call OnAnimEnd
		if ( WeapAnimNode.bForceRefposeWhenNotPlaying )
		{
			WeapMesh.SetForceRefPose(TRUE);
		}
	}
}

/*********************************************************************************************
 * @name	Rendering/Lighting
********************************************************************************************* */

/** Set the lighting channels on all the appropriate weapon attachment mesh(es) */
simulated function SetMeshLightingChannels(LightingChannelContainer NewLightingChannels)
{
	if( !bWeapMeshIsPawnMesh )
	{
		WeapMesh.SetLightingChannels(NewLightingChannels);
	}

	if( LaserSight != none )
	{
	   LaserSight.SetMeshLightingChannels(NewLightingChannels);
	}
}

/** Debug */
simulated function bool HasIndoorLighting()
{
	return WeapMesh.LightingChannels.Indoor;
}

/** Debug */
simulated function bool HasOutdoorLighting()
{
	return WeapMesh.LightingChannels.Outdoor;
}

/*********************************************************************************************
 * State LoopingWeaponAction
 * Plays a looping character animation with optional intro/outro anims.  Most weapon
 * actions don't use state logic, but looping is complex enough that states are useful.
*********************************************************************************************/

simulated function StartLoopingAnim(KFPawn P, name InLoopAnim, optional name InIntroAnim, optional name InOutroAnim, optional bool bPlaySynchedWeaponAnim)
{
	if ( !P.IsDoingSpecialMove() )
	{
		LoopingAnim = InLoopAnim;
		LoopIntroAnim = InIntroAnim;
		LoopOutroAnim = InOutroAnim;
		bLoopSynchedWeaponAnim = bPlaySynchedWeaponAnim;

		GotoState('LoopingWeaponAction');
	}
}

// Global declarations for LoopingWeaponAction
simulated function PlayLoopAnim();

simulated State LoopingWeaponAction
{
	/** Play intro anim and start timer */
	simulated function BeginState(name PreviousStateName)
    {
		local KFPawn P;
		local float Duration;

		P = KFPawn(Owner);
		if ( LoopIntroAnim != '' )
		{
			Duration = PlayCharacterMeshAnim(P, LoopIntroAnim, bLoopSynchedWeaponAnim);
			if ( Duration > 0 )
			{
				// 0.2f should match the blend in time of the loop anim
				SetTimer(Duration - 0.2f, false, nameof(PlayLoopAnim));
				return;
			}
		}

		// no intro, start immediately
		PlayLoopAnim();
	}

	/** Make sure looping anim is stopped */
	simulated function EndState(Name NextStateName)
	{
		local KFPawn P;

		P = KFPawn(Owner);
		if ( P != None )
		{
			P.StopBodyAnim(EAS_UpperBody, 0.1f);
			P.StopBodyAnim(EAS_CH_UpperBody, 0.1f);
		}

		if ( bLoopSynchedWeaponAnim && bSynchronizeWeaponAnim )
		{
			InterruptWeaponAnim();
		}
	}

	/** Play main looping anim */
	simulated function PlayLoopAnim()
	{
		local KFPawn P;
		P = KFPawn(Owner);
		if ( P != None )
		{
			PlayCharacterMeshAnim(P, LoopingAnim, bLoopSynchedWeaponAnim, true);
		}
	}

	/** Stop looping state and play outro anim */
	simulated function UpdateThirdPersonWeaponAction( EWeaponState NewWeaponState, KFPawn P, byte ThirdPersonAnimRateByte )
	{
		GotoState('');

		if( LoopOutroAnim != '' )
		{
			DecodeThirdPersonAnimRate( ThirdPersonAnimRateByte );
			PlayCharacterMeshAnim(P, LoopOutroAnim, bLoopSynchedWeaponAnim);
		}

		Global.UpdateThirdPersonWeaponAction( NewWeaponState, P, ThirdPersonAnimRateByte );
	}

	/** Stop looping state */
	simulated function bool ThirdPersonFireEffects( vector HitLocation, KFPawn P, byte ThirdPersonAnimRateByte )
	{
		GotoState('');
		return Global.ThirdPersonFireEffects( HitLocation, P, ThirdPersonAnimRateByte );
	}

	/** Stop looping state */
	simulated function DetachFrom(KFPawn P)
	{
		GotoState('');
		Global.DetachFrom(P);
	}
}

/** Special event added for weap attachments. Free for use */
function OnSpecialEvent(int Arg);

defaultproperties
{
	Begin Object class=AnimNodeSequence Name=MeshSequenceA
		bForceRefposeWhenNotPlaying=true
	End Object

	// Weapon SkeletalMesh
	Begin Object Class=SkeletalMeshComponent Name=SkeletalMeshComponent0
		bOwnerNoSee=true
		bOnlyOwnerSee=false
		CollideActors=false
		AlwaysLoadOnClient=true
		AlwaysLoadOnServer=true
		MaxDrawDistance=4000
		bUpdateSkelWhenNotRendered=false
		bIgnoreControllersWhenNotRendered=true
		bOverrideAttachmentOwnerVisibility=true
		bAcceptsDynamicDecals=FALSE
		Animations=MeshSequenceA
		CastShadow=true
		bCastDynamicShadow=true
		bPerBoneMotionBlur=true
		bForceRefPose=1
		// Default to outdoor. If indoor, this will be set when TWIndoorLightingVolume::Touch() event is received at spawn.
		LightingChannels=(Outdoor=TRUE,bInitialized=TRUE)
	End Object
	WeapMesh=SkeletalMeshComponent0

	LaserSightArchetype=KFLaserSightAttachment'FX_LaserSight_ARCH.Default_LaserSight_3P'

	TickGroup=TG_DuringAsyncWork
	NetUpdateFrequency=10
	RemoteRole=ROLE_None
	bReplicateInstigator=true

	MaxFireEffectDistance=5000.0
	AimOffsetProfileName=Default

	// temp
	DefaultBlendInTime=0.2f
	DefaultBlendOutTime=0.2f
	ShootBlendInTime=0.1
	ShootBlendOutTime=0.1

	ThirdPersonAnimRate=1.0f
	LastMeleeAnimIdx=255
	bWaitingForWeaponSkinLoad=false
}
