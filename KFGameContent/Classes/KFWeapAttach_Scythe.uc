//=============================================================================
// KFWeapAttach_Scythe
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFWeapAttach_Scythe extends KFWeaponAttachment;

var const float UnfoldBlendingDuration;
var const float UnfoldedAnimRateModifier;
const FoldAnim = 'Clean_NoBlood';

var AnimTree CustomAnimTree;
var AnimNodeBlendPerBone FoldBlendNode;

var transient bool bIsFolded; 

event PreBeginPlay()
{
	Super.PreBeginPlay();
	
	// Override the animtree.  Doing this here (before AttachTo) instead of in defaultprops 
	// avoids an undesired call to our owning Pawn's PostInitAnimTree
	if ( CustomAnimTree != None )
	{
		WeapMesh.SetAnimTreeTemplate(CustomAnimTree);
	
		WeapAnimNode = AnimNodeSequence(WeapMesh.FindAnimNode('WeaponSeq'));
		FoldBlendNode = AnimNodeBlendPerBone(WeapMesh.FindAnimNode('FoldBlendNode'));

		// The special event might have arrived before the attachment is created, but it's updated in the owner, so copy the state here...
		if (KFPawn(Owner) != none && FoldBlendNode != none)
		{
			bIsFolded = KFPawn(Owner).WeaponSpecialAction == 0;
			FoldBlendNode.SetBlendTarget(bIsFolded ? 1.0f : 0.0f, 0.f);
		}
	}
}

simulated function ChangeMode()
{
	bIsFolded = !bIsFolded;

	// FoldControl =  SkelControlSingleBone( WeapMesh.FindSkelControl('FoldControl') );
	if( FoldBlendNode != none )
	{
		FoldBlendNode.SetBlendTarget( bIsFolded ? 1.0f : 0.0f, 0.0f );
	}
}

/** Called from the pawn when our first person weapon changes states */
simulated function UpdateThirdPersonWeaponAction(EWeaponState NewWeaponState, KFPawn P, byte ThirdPersonAnimRateByte )
{
	Super.UpdateThirdPersonWeaponAction(NewWeaponState, P, ThirdPersonAnimRate);
	
	if (NewWeaponState == WEP_Cleaning)
	{
		if (WeapAnimNode  != none)
		{
			if (WeapAnimNode.AnimSeq == none)
			{
				WeapAnimNode.SetAnim(FoldAnim);
			}

			WeapAnimNode.PlayAnim();
		}
	}
}

simulated function ANIMNOTIFY_ShellEject()
{
	ChangeMode();
}

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
	local float AnimRate;
	local float Duration;
	local EAnimSlotStance Stance;
	local string AnimStr;

	// skip weapon anims while in a special move
	if( P.IsDoingSpecialMove() && !P.SpecialMoves[P.SpecialMove].bAllowThirdPersonWeaponAnims )
	{
		return 0.f;
	}

	Stance = (!P.bIsCrouched) ? EAS_UpperBody : EAS_CH_UpperBody;

	AnimRate = ThirdPersonAnimRate;
	AnimStr = Caps(string(AnimName));

  	if (!bIsFolded && (InStr(AnimStr, "ATK") != INDEX_NONE || InStr(AnimName, "COMB") != INDEX_NONE))
	{
		AnimRate *= UnfoldedAnimRateModifier;
	}

	Duration = P.PlayBodyAnim(AnimName, Stance, AnimRate, DefaultBlendInTime, DefaultBlendOutTime, bLooping);

	if ( Duration > 0 && bPlaySynchedWeaponAnim )
	{
		PlayWeaponMeshAnim(AnimName, P.BodyStanceNodes[Stance], bLooping);
	}

	`log(GetFuncName()@"called on:"$P@"Anim:"$AnimName@"Duration:"$Duration, bDebug);

	return Duration;
}

/** Special event added for weap attachments. Free for use */
function OnSpecialEvent(int Arg)
{
	bIsFolded = Arg == 0;

	// FoldControl =  SkelControlSingleBone( WeapMesh.FindSkelControl('FoldControl') );
	if( FoldBlendNode != none )
	{
		FoldBlendNode.SetBlendTarget( bIsFolded ? 1.0f : 0.0f, 0.0f );
	}
}

defaultproperties
{
	CustomAnimTree=AnimTree'WEP_Scythe_ARCH.3P_Scythe_Animtree'
	bIsFolded=true;
	UnfoldBlendingDuration=0.25f
	UnfoldedAnimRateModifier=0.7f;

	// Weapon SkeletalMesh
	Begin Object Name=SkeletalMeshComponent0
		bForceRefPose=0
	End Object
}
