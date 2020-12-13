//=============================================================================
// KFSM_PlayerSlasher_Melee2
//=============================================================================
// Player controlled stalker attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerStalker_Melee2 extends KFSM_PlayerMeleeBase;

defaultproperties
{
	Attacks.Add((Type=PZA_Default, Stance=EAS_FullBody, Anims=(Player_Heavy_Atk)))
	Attacks.Add((Type=PZA_Sprinting, Stance=EAS_FullBody, Anims=(Player_Sprint_Heavy)))
	Attacks.Add((Type=PZA_Cloaked, Stance=EAS_FullBody, Anims=(Player_Heavy_Atk)))
	Attacks.Add((Type=PZA_SprintCloaked, Stance=EAS_FullBody, Anims=(Player_Sprint_Heavy)))
	Attacks.Add((Type=PZA_Jumping,  Stance=EAS_FullBody,  Anims=(Player_Jump_Atk), bForceDisableRootMotion=true))
	Attacks.Add((Type=PZA_Backwards, Stance=EAS_FullBody, Anims=(Player_Kick_Atk)))
}