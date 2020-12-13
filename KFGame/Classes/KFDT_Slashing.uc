//=============================================================================
// KFDT_Slashing
//=============================================================================
// Melee slashing attacks designed to cut
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFDT_Slashing extends KFDamageType
	abstract;

`include(KFGameDialog.uci)

`define COSINE_0_DEGREES   1
`define COSINE_40_DEGREES  0.76
`define COSINE_70_DEGREES  0.34
`define COSINE_90_DEGREES  0

/** @return The slast type from the HitFxInfo. This returns a 8-way slash info. */
static simulated function EPawnOctant GetLastSlashDirection(KFPawn_Monster InPawn, vector HitDirection)
{
	local vector SlashPlaneNormal;
	local rotator InstigatorRotation;
	local vector InstigatorFaceDir, InstigatorRightDir;
	local float UpDotSlash, RightDotSlash, UpThresholdValue;

	if( InPawn != none && InPawn.HitFxInstigator != none )
	{
		HitDirection = Normal( HitDirection );
		InstigatorRotation = InPawn.HitFxInstigator.GetBaseAimRotation();
		InstigatorFaceDir = GetRotatorAxis(InstigatorRotation, 0);
		InstigatorRightDir = GetRotatorAxis(InstigatorRotation, 1);

		// Cross the face direction of the instigator with the hit direction to find
		// the normal to the "slashing" plane
		SlashPlaneNormal = Normal(InstigatorFaceDir Cross HitDirection);

		// Dot the slash plane normal with the world up direction to figure out
		// the quadrant for the normal of the slash plane
		UpDotSlash = vect(0,0,1) Dot SlashPlaneNormal;
		UpThresholdValue = Abs(UpDotSlash);

		// Dot the slash plane normal with the instigator right to figure out
		// the direction of the slash
		RightDotSlash = InstigatorRightDir Dot SlashPlaneNormal;

		// Threshhold against the preset values to find out the type of slash. The sign (+ or -) of the
		// dot products are used to further classify the direction of the slash
		if( UpThresholdValue <= `COSINE_0_DEGREES && UpThresholdValue >= `COSINE_40_DEGREES )
		{
			if( UpDotSlash > 0 )
				return DIR_Right;
			else
				return DIR_Left;
		}
		else if( UpThresholdValue <= `COSINE_40_DEGREES && UpThresholdValue >= `COSINE_70_DEGREES )
		{
			if( UpDotSlash < 0 && RightDotSlash > 0 )
				return DIR_ForwardLeft;
			else if( UpDotSlash > 0 && RightDotSlash > 0 )
				return DIR_ForwardRight;
			else if( UpDotSlash > 0 && RightDotSlash < 0 )
				return DIR_BackwardRight;
			else if( UpDotSlash < 0 && RightDotSlash < 0 )
				return DIR_BackwardLeft;
		}
		else if( UpThresholdValue <= `COSINE_70_DEGREES && UpThresholdValue >= `COSINE_90_DEGREES )
		{
			if( RightDotSlash > 0 )
				return DIR_Forward;
			else
				return DIR_Backward;
		}
	}

	return DIR_None;
}

/**
 * Take the primary HitDirection and modify it to add more spread.
 * Additional hit directions are added per hit to create a longish blood splat.
 */
static simulated function AddBloodSpread(KFPawn_Monster InPawn, vector HitDirection, out array<vector> HitSpread, bool bIsDismemberingHit, bool bWasObliterated)
{
	local rotator InstigatorRotation;
	local float Angle;
	local Quat Rotation;
	local vector InstigatorFaceDir, SlashPlaneNormal;

	if( InPawn.HitFxInstigator != none )
	{
		InstigatorRotation = InPawn.HitFxInstigator.GetBaseAimRotation();
	}
	else
	{
		// Use inverse of pawn yaw in the event our FX instigator has been destroyed
		InstigatorRotation.Yaw = NormalizeRotAxis( -InPawn.Rotation.Yaw );
	}
	InstigatorFaceDir = GetRotatorAxis(InstigatorRotation, 0);

	// Cross the face direction of the instigator with the hit direction to find
	// the normal to the "slashing" plane
	SlashPlaneNormal = Normal(InstigatorFaceDir Cross HitDirection);

	for( Angle=-Pi/2.f; Angle <= Pi/2.f; Angle += Pi/6.f)
	{
		Rotation = QuatFromAxisAndAngle(SlashPlaneNormal, Angle);
		HitSpread.AddItem(QuatRotateVector(Rotation, HitDirection));
	}
}

/**
 * Modify the "amount of blood" for persistent blood splatters. For slash attacks,
 * we do not take the damage scale into account to keep the (streak) effect more
 * consistent.
 */
static simulated function float GetBloodScale(float HitZoneDamageScale, bool bIsDismemberingHit, bool bWasObliterated)
{
 	return default.BloodScale * (bIsDismemberingHit ? 4.f : 1.f);
}

/** Allows the damage type to customize exactly which hit zones it can dismember */
static simulated function bool CanDismemberHitZone( name InHitZoneName )
{
	switch ( InHitZoneName )
	{
		case 'head':
	 	case 'lhand':
		case 'rhand':
		case 'lfoot':
		case 'rfoot':
		case 'lforearm':
		case 'rforearm':
	 		return true;
	}

	return false;
}

/** Returns ID of dialog event for killer to speak after killing a zed using this damage type */
static function int GetKillerDialogID()
{
	return `KILL_Slashing;
}

defaultproperties
{
	KDamageImpulse=300

	bShouldSpawnPersistentBlood=true
	BloodScale=0.5
	BodyWoundDecalMaterials[0]=MaterialInstanceConstant'FX_Impacts_MAT.FX_Bladed_Impact_Slice_01_MIC'
	CameraLensEffectTemplate=class'KFCameraLensEmit_BloodBase'

	GoreDamageGroup=DGT_MeleeSlash
	EffectGroup=FXG_Slashing
}
