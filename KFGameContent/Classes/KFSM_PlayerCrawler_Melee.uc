//=============================================================================
// KFSM_PlayerCrawler_Melee
//=============================================================================
// Player controlled stalker attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerCrawler_Melee extends KFSM_PlayerMeleeBase;

defaultproperties
{
	Attacks.Add((Type=PZA_Default,  Stance=EAS_FullBody, Anims=(Player_Short_Leap)))
	Attacks.Add((Type=PZA_Jumping,	Stance=EAS_FullBody, Anims=(Player_Jump_Atk), bForceDisableRootMotion=true, MomentumPush=400))
    Attacks.Add((Type=PZA_Sprinting, Stance=EAS_FullBody, Anims=(Player_Short_Leap_Combo)))
	Attacks.Add((Type=PZA_Headless, Stance=EAS_UpperBody, Anims=(Player_Headless_Atk_V1, Player_Headless_Atk_V2)))
}