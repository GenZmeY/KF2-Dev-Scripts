//=============================================================================
// KFSM_PlayerScrake_Melee3
//=============================================================================
// Player controlled scrake attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerScrake_Melee3 extends KFSM_PlayerScrake_Melee;

defaultproperties
{
	Attacks.Empty
	Attacks.Add((Type=PZA_Default, Stance=EAS_FullBody, Anims=(Player_360_Spin), bCannotBeParried=true))
	//Attacks.Add((Type=PZA_Sprinting, Stance=EAS_FullBody, Anims=(Player_Lunge_Combo)))

	// Rage attacks
	Attacks.Add((Type=PZA_SpecialDefault, Stance=EAS_FullBody, Anims=(Player_Rage_360_Spin), bCannotBeParried=true))
	Attacks.Add((Type=PZA_SpecialSprinting, Stance=EAS_FullBody, Anims=(Player_Rage_360_Spin), bCannotBeParried=true))

}