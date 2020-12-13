//=============================================================================
// KFSM_PlayerScrake_Melee
//=============================================================================
// Player controlled scrake attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerScrake_Melee extends KFSM_PlayerMeleeBase;

/** Can be overridden in subclasses to determine if special attacks are used over defaults */
static function bool IsInSpecialMode( KFPawn P )
{
	local KFPawn_ZedScrake_Versus MySCPawn;

	MySCPawn = KFPawn_ZedScrake_Versus( P );
	if( MySCPawn != none )
	{
		return MySCPawn.bIsEnraged;
	}

	return false;
}


defaultproperties
{
	Attacks.Add((Type=PZA_Default,  Stance=EAS_FullBody, Anims=(Player_Light_Atk)))
	Attacks.Add((Type=PZA_Sprinting, Stance=EAS_FullBody, Anims=(Player_Lunge_Light)))
	Attacks.Add((Type=PZA_Jumping,  Stance=EAS_FullBody,  Anims=(Player_Jump_Atk), bForceDisableRootMotion=true))
	Attacks.Add((Type=PZA_Headless, Stance=EAS_UpperBody, Anims=(Player_Headless_Atk_V1, Player_Headless_Atk_V2)))

	// Rage attacks
	Attacks.Add((Type=PZA_SpecialDefault,  Stance=EAS_FullBody, Anims=(Player_Rage_Light, Player_RLunge_Light)))
	Attacks.Add((Type=PZA_SpecialSprinting, Stance=EAS_FullBody, Anims=(Player_RLunge_Light, Player_Rage_Light)))
	Attacks.Add((Type=PZA_Jumping,  Stance=EAS_FullBody,  Anims=(Player_Jump_Atk), bForceDisableRootMotion=true))
}