//=============================================================================
// KFAIController_ZedGorefast
//=============================================================================
// Base controller for the Gorefast
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFAIController_ZedGorefast extends KFAIController_Monster;

var bool	bExecutedSprint;

/*********************************************************************************************
* Movement Methods
********************************************************************************************* */

/** Timer function called during latent moves that determines whether NPC should sprint or stop sprinting */
function bool ShouldSprint()
{
	if( Enemy != none && MyKFPawn != none && MyKFPawn.IsCombatCapable() && (bExecutedSprint ||
		MyKFPawn.Health < MyKFPawn.HealthMax || (VSizeSq(Enemy.Location - Pawn.Location) <= (SprintWithinEnemyRange.Y * SprintWithinEnemyRange.Y))) )
	{
		bExecutedSprint = true;
		return true;
	}
	else
	{
		return false;
	}
}

/** Called from KFPawn_Monster::SetSprinting() */
function bool CanSetSprinting( bool bNewSprintStatus )
{
	return bExecutedSprint;
}

/** Turn off sprinting if we've lost sight of our enemy */
event EnemyNotVisible()
{
	if( MyKFPawn.bIsSprinting && !bForceFrustration && MyKFGameInfo.MyKFGRI.AIRemaining > FrustrationThreshold )  // don't stop sprinting if we're in frustration mode
	{
		bExecutedSprint = false;
		MyKFPawn.SetSprinting( false );
	}
	bEnemyIsVisible = false;
	DisableEnemyNotVisible();
	EnableSeePlayer();
}

/** Update sprint settings based on Frustration */
function UpdateSprintFrustration( optional byte bForceFrustrationState=255 )
{
	if( bForceFrustration )
	{
		bExecutedSprint = true;
		bCanSprint = true;
	}
}

function bool IsFrustrated()
{
	if( bForceFrustration )
	{
		return true;
	}

	return false;
}

DefaultProperties
{
	// ---------------------------------------------
	// AI / Navigation
	MeleeCommandClass=class'AICommand_Base_Zed'
	DefaultCommandClass=class'AICommand_Base_Zed'
	SprintWithinEnemyRange=(X=0,Y=800.f)
	EvadeGrenadeChance=0.75f
	bEvadeOnRunOverWarning=true
	RunOverEvadeDelayScale=0.5f

	// ---------------------------------------------
	// Combat
	bIsProbingMeleeRangeEvents=true
	StrikeRangePercentage=0.75f
	MaxMeleeHeightAngle=0.68f
	LowIntensityAttackCooldown=3.0

    // ---------------------------------------------
	// Danger Evasion Settings
	DangerEvadeSettings.Empty

	//Grenades
	DangerEvadeSettings(2)={(ClassName="KFProj_FragGrenade",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.2, 0.5, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}	
	DangerEvadeSettings(3)={(ClassName="KFProj_MolotovGrenade",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.2, 0.5, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}	
	DangerEvadeSettings(4)={(ClassName="KFProj_DynamiteGrenade",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.2, 0.5, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}	
	DangerEvadeSettings(5)={(ClassName="KFProj_NailBombGrenade",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.2, 0.5, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},
								SoloChanceMultiplier=1.0)}	
	DangerEvadeSettings(6)={(ClassName="KFProj_HEGrenade",
								Cooldowns=(3.0, 1.0, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.2, 0.5, 0.8),
								ForcedEvadeChances={((FL=0.0, FR=0.0), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5), (FL=0.5, FR=0.5))},
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.05))},	
								SoloChanceMultiplier=1.0)}
	DangerEvadeSettings(7)={(ClassName="KFWeap_Beam_Microwave",
							    Cooldowns=(3.0, 3.0, 2.5,  1.5), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 0.3, 0.5, 0.8),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}

	// Ground Fire
	DangerEvadeSettings(8)={(ClassName="KFProj_Flame_HRGIncendiaryRifle",
								Cooldowns=(3.0, 0.3, 0.1,  0.0), // Normal, Hard, Suicidal, HoE
								EvadeChances=(0.0, 1.0, 1.0, 1.0),
								ReactionDelayRanges={((X=0.0, Y=0.2), (X=0.0, Y=0.0), (X=0.0, Y=0.15), (X=0.0, Y=0.00))},
								SoloChanceMultiplier=1.0)}
}