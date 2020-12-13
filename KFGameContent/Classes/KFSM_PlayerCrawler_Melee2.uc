//=============================================================================
// KFSM_PlayerSlasher_Melee2
//=============================================================================
// Player controlled stalker attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerCrawler_Melee2 extends KFSM_PlayerMeleeBase;

defaultproperties
{	
	Attacks.Add((Type=PZA_Default, Stance=EAS_FullBody, Anims=(Player_Medium_Leap)))
	Attacks.Add((Type=PZA_Jumping,	Stance=EAS_FullBody, Anims=(Player_Jump_Atk), bForceDisableRootMotion=true, MomentumPush=400))
	Attacks.Add((Type=PZA_Sprinting, Stance=EAS_FullBody, Anims=(Player_Long_Leap)))
}