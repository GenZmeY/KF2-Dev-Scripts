//=============================================================================
// KFPawn_ZedHuskFriendlyTest
//=============================================================================
// Husk Pawn Class that will target zeds not players - for testing
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFPawn_ZedHuskFriendlyTest extends KFPawn_ZedHusk;

/** Can this pawn be grabbed by Zed performing grab special move (clots & Hans's energy drain) */
function bool CanBeGrabbed(KFPawn GrabbingPawn, optional bool bIgnoreFalling, optional bool bAllowSameTeamGrab)
{
    return false;
}

/** Make sure damage to myself is enough to kill me when it's my suicide attack */
function AdjustDamage(out int InDamage, out vector Momentum, Controller InstigatedBy, vector HitLocation, class<DamageType> DamageType, TraceHitInfo HitInfo, Actor DamageCauser)
{
	Super.AdjustDamage( InDamage, Momentum, InstigatedBy, HitLocation, DamageType, HitInfo, DamageCauser );

    // Don't let me damage myself
	if( MyKFAIC != none && !MyKFAIC.IsSuicidal() && InstigatedBy == MyKFAIC )
	{
	   InDamage = 0;
	}
}

DefaultProperties
{

	// ---------------------------------------------
	// Content
	CharacterMonsterArch = KFCharacterInfo_Monster'zed_husk_arch.ZED_Husk_Archetype'
	FireballClass		 = class'KFGameContent.KFProj_Husk_Fireball'

	// ---------------------------------------------
	// AI / Navigation
	ControllerClass=class'KFGameContent.KFAIController_HuskFriendlyTest'

	Health=5000 // KF1=600
	DoshValue=17
	Mass=65.f
 }
