//=============================================================================
// KFSM_PlayerScrake_Melee2
//=============================================================================
// Player controlled scrake attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerScrake_Melee2 extends KFSM_PlayerScrake_Melee;

defaultproperties
{
	Attacks.Empty
	Attacks.Add((Type=PZA_Default, Stance=EAS_FullBody, Anims=(Player_Heavy_Atk)))
	Attacks.Add((Type=PZA_Sprinting, Stance=EAS_FullBody, Anims=(Player_Lunge_Heavy), bCannotBeParried=true))
	Attacks.Add((Type=PZA_Jumping,  Stance=EAS_FullBody,  Anims=(Player_Jump_Atk), bForceDisableRootMotion=true))
	Attacks.Add((Type=PZA_Backwards, Stance=EAS_FullBody, Anims=(Player_Stab_Atk), bIsInputHeld=true))

	// Rage attacks
	Attacks.Add((Type=PZA_SpecialDefault, Stance=EAS_FullBody, Anims=(Player_Rage_Heavy), bCannotBeParried=true))
	Attacks.Add((Type=PZA_SpecialSprinting, Stance=EAS_FullBody, Anims=(Player_RLunge_Heavy)))
	Attacks.Add((Type=PZA_Jumping,  Stance=EAS_FullBody,  Anims=(Player_Jump_Atk), bForceDisableRootMotion=true))
	Attacks.Add((Type=PZA_SpecialBackwards, Stance=EAS_FullBody, Anims=(Player_Stab_Atk), bIsInputHeld=true))
}