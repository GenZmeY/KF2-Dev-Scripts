//=============================================================================
// KFSM_PlayerSlasher_Melee
//=============================================================================
// Player controlled stalker attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerStalker_Melee extends KFSM_PlayerMeleeBase;

defaultproperties
{
	Attacks.Add((Type=PZA_Default,  Stance=EAS_UpperBody, Anims=(Player_Light_Atk)))
	Attacks.Add((Type=PZA_Sprinting,  Stance=EAS_FullBody,  Anims=(Player_Sprint_Light)))
	Attacks.Add((Type=PZA_Cloaked,  Stance=EAS_UpperBody, Anims=(Player_Light_Atk)))
	Attacks.Add((Type=PZA_SprintCloaked,  Stance=EAS_FullBody,  Anims=(Player_Sprint_Light)))
	Attacks.Add((Type=PZA_Jumping,  Stance=EAS_FullBody,  Anims=(Player_Jump_Atk), bForceDisableRootMotion=true))
	Attacks.Add((Type=PZA_Headless, Stance=EAS_UpperBody, Anims=(Player_Headless_Atk_V1, Player_Headless_Atk_V2)))
}