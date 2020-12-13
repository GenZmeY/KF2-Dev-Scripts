//=============================================================================
// KFAIController_ZedScrake
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAIController_ZedScrake extends KFAIController_Monster;

function bool AmIAllowedToSuicideWhenStuck()
{
	return false;
}

/** Timer function called during latent moves that determines whether NPC should sprint or stop sprinting */
function bool ShouldSprint()
{
	if( MyKFPawn == none || (Enemy == none && DoorEnemy == none) || !MyKFPawn.IsAliveAndWell() || !Enemy.IsAliveAndWell() )
	{
		return false;
	}

	if( MyKFPawn.bIsEnraged )
	{
		return true;
	}

	return false;
}

/** Called from KFPawn_Monster::SetSprinting() */
function bool CanSetSprinting( bool bNewSprintStatus )
{
	return !bNewSprintStatus || MyKFPawn.bIsEnraged;
}

/** Frustration mode should not change sprint settings on Scrake */
function UpdateSprintFrustration( optional byte bForceFrustrationState=255 )
{
}

function bool CanEvadeGrenade()
{
    if(MyKFPawn == none || MyKFPawn.bIsSprinting)
    {
        return false;
    }
    return super.CanEvadeGrenade();
}

function bool CanAttackDestructibles()
{
    return !MyKFPawn.bIsEnraged && super.CanAttackDestructibles();
}

DefaultProperties
{
    bCanTeleportCloser=false
    EvadeGrenadeChance=0.75f
	TeleportCooldown=10.0
	HiddenRelocateTeleportThreshold=7.0
    FrustrationThreshold=0
    FrustrationDelay=5.0
    LowIntensityAttackCooldown=5.0

    // Rage run over warning
    bUseRunOverWarning=true
    MinRunOverSpeed=270.f
    MinRunOverWarningAim=0.85f

    // ---------------------------------------------
    // Danger Evasion Settings
    DangerEvadeSettings.Empty

    //Aim Blocks
    DangerEvadeSettings(0)={(ClassName="KFWeap_Rifle_Winchester1894",
                                Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
                                BlockChances=(0.1, 0.2, 0.7, 0.85))}
    DangerEvadeSettings(1)={(ClassName="KFWeap_Bow_Crossbow",
                                Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
                                BlockChances=(0.1, 0.2, 0.7, 0.85))}
    DangerEvadeSettings(2)={(ClassName="KFWeap_Rifle_M14EBR",
                                Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
                                BlockChances=(0.1, 0.2, 0.7, 0.85))}
    DangerEvadeSettings(3)={(ClassName="KFWeap_Rifle_RailGun",
                                Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
                                BlockChances=(0.1, 0.2, 0.7, 0.85))}
    DangerEvadeSettings(4)={(ClassName="KFWeap_Bow_CompoundBow",
                                Cooldowns=(0.5, 0.4, 0.3, 0.2), // Normal, Hard, Suicidal, HoE
                                BlockChances=(0.1, 0.2, 0.7, 0.85))}
}