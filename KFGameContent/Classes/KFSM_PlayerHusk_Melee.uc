//=============================================================================
// KFSM_PlayerHusk_Melee
//=============================================================================
// Player controlled husk attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerHusk_Melee extends KFSM_PlayerMeleeBase;

defaultproperties
{
	Attacks.Add((Type=PZA_Default,  Stance=EAS_UpperBody, Anims=(Player_melee)))
	//Attacks.Add((Type=PZA_Sprinting, Stance=EAS_FullBody, Anims=(Player_Lunge_Light)))
	Attacks.Add((Type=PZA_Jumping,  Stance=EAS_FullBody,  Anims=(Player_Jump_Atk), bForceDisableRootMotion=true))
	Attacks.Add((Type=PZA_Headless, Stance=EAS_UpperBody, Anims=(Player_Headless_Atk_V1, Player_Headless_Atk_V2)))
}