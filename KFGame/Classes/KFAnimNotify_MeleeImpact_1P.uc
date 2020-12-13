//=============================================================================
// KFAnimNotify_MeleeImpact_1P
//=============================================================================
// (FIrst Person) Triggers an event for melee collision and damage
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFAnimNotify_MeleeImpact_1P extends AnimNotify
	native(Anim);

/** If set, use hit box collision detection for this weapon */
var() bool bAdvancedCollisionDetection;

cpptext
{
	virtual void Notify( class UAnimNodeSequence* NodeSeq );
	virtual void NotifyTick( class UAnimNodeSequence* NodeSeq, FLOAT AnimCurrentTime, FLOAT AnimTimeStep, FLOAT InTotalDuration );

	UKFMeleeHelperBase* GetMeleeHelper(USkeletalMeshComponent* SkelComp);
}

event NotifyFirstPerson(KFPawn P, AnimNodeSequence AnimSeqInstigator)
{
	if ( P.MyKFWeapon != None && P.MyKFWeapon.IsMeleeing() )
	{
		P.MyKFWeapon.MeleeAttackHelper.MeleeImpactNotify(self);
	}
}

event NotifyThirdPerson(KFPawn P, AnimNodeSequence AnimSeqInstigator)
{
	// do nothing
}

defaultproperties
{
	NotifyColor=(R=255,G=0,B=0)
}