//=============================================================================
// KFSM_PlayerAlpha_Melee
//=============================================================================
// Player controlled alpha clot attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerAlpha_Melee extends KFSM_PlayerMeleeBase;

defaultproperties
{
	Attacks.Add((Type=PZA_Default,  Stance=EAS_UpperBody, Anims=(Player_Light_Atk_V1, Player_Light_Atk_V1, Player_Light_Atk_V3)))
    Attacks.Add((Type=PZA_Sprinting, Stance=EAS_FullBody, Anims=(Player_Lunge_Atk, Player_Lunge_Atk_v2, Player_Lunge_Atk_v2)))
	Attacks.Add((Type=PZA_Jumping,  Stance=EAS_FullBody,  Anims=(Player_Jump_Atk_V1)))
	Attacks.Add((Type=PZA_Headless, Stance=EAS_UpperBody, Anims=(Player_Headless_Atk_V1, Player_Headless_Atk_V2)))
}