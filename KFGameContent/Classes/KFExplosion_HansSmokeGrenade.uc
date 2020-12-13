//=============================================================================
// KFExplosion_HansSmokeGrenade
//=============================================================================
// Explosion info for Hans' Smoke Grenade
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - John "Ramm-Jaeger" Gibson
//=============================================================================

class KFExplosion_HansSmokeGrenade extends KFExplosionActor;

var() float MaxSmokeTime;

var AkEvent SmokeLoopStartEvent;
var AkEvent SmokeLoopStopEvent;

/*
 * @param Direction     For bDirectionalExplosion=true explosions, this is the forward direction of the blast.
 * Overridden to add the ability to spawn fragments from the explosion
 **/
simulated function Explode(GameExplosion NewExplosionTemplate, optional vector Direction)
{
	super.Explode(NewExplosionTemplate, Direction);

	LifeSpan = MaxSmokeTime;

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		PlaySoundBase( SmokeLoopStartEvent, true );
	}
}

event Destroyed()
{
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		PlaySoundBase( SmokeLoopStopEvent, true );
	}

	super.Destroyed();
}

/** Overridden to only do damage as a special pawn effect */
protected simulated function bool DoExplosionDamage(bool bCauseDamage, bool bCauseEffects)
{
	return false;
}

/**  Return the desired radius to check for actors which get effects from explosion  */
function float GetEffectCheckRadius(bool bCauseDamage, bool bCauseFractureEffects, bool bCauseEffects)
{
	local float CheckRadius;

	CheckRadius = super.GetEffectCheckRadius(bCauseDamage, bCauseFractureEffects, bCauseEffects);
	if ( bCauseEffects )
	{
		CheckRadius = FMax(CheckRadius, ExplosionTemplate.DamageRadius);
	}

	return CheckRadius;
}

DefaultProperties
{
	MaxSmokeTime=8

	bExplodeMoreThanOnce=true

	SmokeLoopStartEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Play_WEP_EXP_Grenade_Medic_Smoke_Loop'
	SmokeLoopStopEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Stop_WEP_EXP_Grenade_Medic_Smoke_Loop'
}
