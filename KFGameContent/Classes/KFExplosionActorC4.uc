//=============================================================================
// KFExplosionActorC4
//=============================================================================
// Explosion actor class that potentially does less damage each subsequent hit
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Jeff Robinson
//=============================================================================

class KFExplosionActorC4 extends KFExplosionActor;

simulated function float GetDamageFor( Actor Victim )
{
	return ExplosionTemplate.Damage * CalcStackingDamageScale(KFPawn(Victim), default.LifeSpan);
}

defaultproperties
{
	LifeSpan=3.f
	DamageScalePerStack=0.75
}
