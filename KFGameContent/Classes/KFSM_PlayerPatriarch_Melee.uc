//=============================================================================
// KFSM_PlayerPatriarch_Melee
//=============================================================================
// Player controlled patriarch attacks
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerPatriarch_Melee extends KFSM_PlayerMeleeBase;

defaultproperties
{
	Attacks.Add((Type=PZA_Default,  Stance=EAS_UpperBody, Anims=(Player_Claw_Atk_V1, Player_Claw_Atk_V2, Player_Heavy_Atk_V1)))
	Attacks.Add((Type=PZA_Jumping,	Stance=EAS_FullBody, Anims=(Player_Jump_Atk), bForceDisableRootMotion=true))
    Attacks.Add((Type=PZA_Sprinting, Stance=EAS_FullBody, Anims=(Player_Heavy_Lunge_V1, Player_Heavy_Lunge_V2, Player_Heavy_Lunge_V3, Player_Heavy_Lunge_V4)))
	Attacks.Add((Type=PZA_Backwards,  Stance=EAS_FullBody, Anims=(Player_Kick)))
	Attacks.Add((Type=PZA_Left,  Stance=EAS_FullBody, Anims=(Player_Spin_Atk), bCannotBeParried=true))
	Attacks.Add((Type=PZA_Right,  Stance=EAS_FullBody, Anims=(Player_Spin_Atk), bCannotBeParried=true))
	Attacks.Add((Type=PZA_Cloaked,  Stance=EAS_FullBody, Anims=(Player_Shoulder_Light), bCannotBeParried=true))
	Attacks.Add((Type=PZA_SprintCloaked,  Stance=EAS_FullBody, Anims=(Player_Shoulder_Heavy), bCannotBeParried=true))
}