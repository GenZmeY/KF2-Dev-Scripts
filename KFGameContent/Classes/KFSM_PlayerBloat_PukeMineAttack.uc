//=============================================================================
// KFSM_PlayerBloat_PukeMineAttack
//=============================================================================
// Player controlled bloat puke mine attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerBloat_PukeMineAttack extends KFSM_PlayerMeleeBase;

protected function bool InternalCanDoSpecialMove()
{
	if( KFPOwner == none || KFPOwner.IsHeadless() )
	{
		return false;
	}

	return super.InternalCanDoSpecialMove();
}

defaultproperties
{
	Attacks.Add((Type=PZA_Default, Stance=EAS_UpperBody, Anims=(Player_Special_Atk)))
}