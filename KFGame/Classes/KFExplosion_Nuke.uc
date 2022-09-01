//=============================================================================
// KFExplosion_Nuke
//=============================================================================
// Used by projectiles and kismet to spawn an explosion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Christian "schneidzekk" Schneider
//=============================================================================

class KFExplosion_Nuke extends KFExplosionActorLingering;

var float NukeEffectRadius;

/**
  * Deal damage
  */
protected simulated function AffectsPawn(Pawn Victim, float DamageScale)
{
	local KFPawn_Monster MonsterVictim;

	if( Victim != none && Victim.IsAliveAndWell() )
	{
		MonsterVictim = KFPawn_Monster(Victim);
		if( MonsterVictim != none )
		{
			super.AffectsPawn(Victim, DamageScale);
		}
	}
}

simulated function Explode(GameExplosion NewExplosionTemplate, optional vector Direction)
{
	NewExplosionTemplate.MyDamageType = NewExplosionTemplate.default.MyDamageType;
	super.Explode(NewExplosionTemplate, Direction);

	ExplosionTemplate.Damage = class'KFPerk_Demolitionist'.static.GetLingeringPoisonDamage();
	ExplosionTemplate.MyDamageType = class'KFPerk_Demolitionist'.static.GetLingeringDamageType();
}

protected simulated function bool ExplodePawns(bool bCauseDamage)
{
	local Pawn 		Victim;
	local float 	CheckRadius;
	local bool		bDamageBlocked, bHitPawn;
	local Actor		HitActor;
	local vector	BBoxCenter;
	local float 	DamageScale;
	local Box BBox;	

	// determine radius to check
	CheckRadius = GetNukeEffectCheckRadius();
	if ( CheckRadius > 0.0 )
	{
		foreach WorldInfo.AllPawns(class'Pawn', Victim, Location, CheckRadius)
		{
			if ( (!Victim.bWorldGeometry || Victim.bCanBeDamaged)
				&& Victim != ExplosionTemplate.ActorToIgnoreForDamage
				&& (!ExplosionTemplate.bIgnoreInstigator || Victim != Instigator)
				&& !ClassIsChildOf(Victim.Class, ExplosionTemplate.ActorClassToIgnoreForDamage) )
			{
				if ( bSkipLineCheckForPawns )
				{
					bDamageBlocked = false;
				}
				else
				{
					Victim.GetComponentsBoundingBox(BBox);
					BBoxCenter = (BBox.Min + BBox.Max) * 0.5f;
					HitActor = TraceExplosive(BBoxCenter, Location + vect(0, 0, 20));
					bDamageBlocked = (HitActor != None && HitActor != Victim);
				}

				if( !bDamageBlocked )
				{
					DamageScale = (DamageScalePerStack < 1.f) ? CalcStackingDamageScale(KFPawn(Victim), Interval) : 1.f;
					if ( DamageScale > 0.f )
					{
						AffectsPawn(Victim, DamageScale);
						bHitPawn = true;
					}
				}
			}
		}
	}

	return bHitPawn;
}

protected simulated function float GetNukeEffectCheckRadius()
{
	return default.NukeEffectRadius;
}

DefaultProperties
{
	Interval=1
	MaxTime=8

	bExplodeMoreThanOnce=true
	bDoFullDamage=true
	bSkipLineCheckForPawns=true

	LoopStartEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Play_WEP_EXP_Grenade_Medic_Smoke_Loop'
	LoopStopEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Stop_WEP_EXP_Grenade_Medic_Smoke_Loop'

	NukeEffectRadius=300
}
