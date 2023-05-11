//=============================================================================
// KFExplosion_HRG_Warthog
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//=============================================================================

class KFExplosion_HRG_Warthog extends KFExplosionActor;

var private int HealingValue;

// Disable Knockdown for friendlies
protected function bool KnockdownPawn(BaseAiPawn Victim, float DistFromExplosion)
{
	if (Victim.GetTeamNum() != Instigator.GetTeamNum())
	{
		return Super.KnockdownPawn(Victim, DistFromExplosion);
	}

	return false;
}

// Disable Stumble for friendlies
protected function bool StumblePawn(BaseAiPawn Victim, float DistFromExplosion)
{
	if (Victim.GetTeamNum() != Instigator.GetTeamNum())
	{
		return Super.StumblePawn(Victim, DistFromExplosion);
	}

	return false;
}

DefaultProperties
{
}