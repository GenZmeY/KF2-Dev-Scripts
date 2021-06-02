//=============================================================================
// KFMeleeHelperWeaponBlastBrawlers
//=============================================================================
// Manages melee attack related functionality for 1st person weapons
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================
class KFMeleeHelperWeaponBlastBrawlers extends KFMeleeHelperWeapon
	config(Game);

event InitWorldTraceForHitboxCollision()
{
	local KFWeap_HRG_BlastBrawlers BlastBrawlers;

	BlastBrawlers = KFWeap_HRG_BlastBrawlers(Instigator.Weapon);
	if (BlastBrawlers != none)
	{
		BlastBrawlers.Shoot();
	}

	super.InitWorldTraceForHitboxCollision();
}

simulated function InitAttackSequence(EPawnOctant NewAtkDir, EMeleeAttackType NewAtkType)
{
	super.InitAttackSequence(NewAtkDir, NewAtkType);
	NextAttackType = NewAtkType;
}

defaultproperties
{

}
