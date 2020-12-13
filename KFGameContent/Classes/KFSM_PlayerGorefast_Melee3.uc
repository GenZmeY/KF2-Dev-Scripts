//=============================================================================
// KFSM_PlayerGorefast_Melee3
//=============================================================================
// Player controlled stalker attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerGorefast_Melee3 extends KFSM_PlayerMeleeBase;

defaultproperties
{
	Attacks.Add((Type=PZA_Default, Stance=EAS_FullBody, Anims=(Player_Special), bIsInputHeld=true))
	Attacks.Add((Type=PZA_Sprinting, Stance=EAS_FullBody, Anims=(Player_Special_Sprint)))
}