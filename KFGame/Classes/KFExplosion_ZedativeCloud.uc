//=============================================================================
// KFExplosion_ZedativeCloud
//=============================================================================
// Used by projectiles and kismet to spawn an explosion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFExplosion_ZedativeCloud extends KFExplosionActorLingering;

var transient private repnotify GameExplosion ReplicatedExploTemplate;

var() class<KFDamageType> HealingDamageType;
var() float HealingAmount;

var AkEvent SmokeLoopStartEvent;
var AkEvent SmokeLoopStopEvent;

var KFPerk CachedInstigatorPerk;

var float ExplosionDelay;
var int ZedativeHealth;
var int ZedativeDamage;
var class<KFDamageType> ZedativeDamageType;
var class<KFDamageType> ZedativeHealingType;
var int ZedativeEffectRadius;

var array<KFPawn_Human> AffectedHumans;

replication
{
	if(bNetInitial)
		ReplicatedExploTemplate;
}

simulated event ReplicatedEvent(name VarName)
{
	if (VarName == 'ReplicatedExploTemplate')
	{
		Explode(ReplicatedExploTemplate, ExplosionDirection);
	}
	else
	{
		super.ReplicatedEvent(VarName);
	}
}

/*
 * @param Direction     For bDirectionalExplosion=true explosions, this is the forward direction of the blast.
 * Overridden to add the ability to spawn fragments from the explosion
 **/
simulated function Explode(GameExplosion NewExplosionTemplate, optional vector Direction)
{
	if (Role == Role_Authority)
	{
		ExplosionDelay = class'KFPerk_FieldMedic'.static.GetZedativeExplosionDelay();
		ZedativeHealth = class'KFPerk_FieldMedic'.static.GetZedativeHealth();
		ZedativeDamage = class'KFPerk_FieldMedic'.static.GetZedativeDamage();
		ZedativeDamageType = class'KFPerk_FieldMedic'.static.GetZedativeDamageType();
		ZedativeHealingType = class'KFPerk_FieldMedic'.static.GetZedativeHealingType();
		ZedativeEffectRadius = class'KFPerk_FieldMedic'.static.GetZedativeEffectRadius();

		SetTimer(ExplosionDelay, false, nameof(DelayedExplosionDamage), self);

		ReplicatedExploTemplate = NewExplosionTemplate;
	}

	Super.Explode( NewExplosionTemplate, Direction );
}

/**
  * Deal damage or heal players
  */
protected simulated function AffectsPawn(Pawn Victim, float DamageScale)
{
	local KFPawn_Human HumanVictim;
	local KFPawn_Monster MonsterVictim;
	local Box BBox;	
	local vector	BBoxCenter;
	local Actor		HitActor;
	local bool		bDamageBlocked;
	
	if( bWasFadedOut|| bDeleteMe || bPendingDelete )
	{
		return;
	}

	if( Victim != none && Victim.IsAliveAndWell() )
	{
		MonsterVictim = KFPawn_Monster(Victim);
		if( MonsterVictim != none )
		{			
			Victim.GetComponentsBoundingBox(BBox);
			BBoxCenter = (BBox.Min + BBox.Max) * 0.5f;
			HitActor = TraceExplosive(BBoxCenter, Location + vect(0, 0, 20));
			bDamageBlocked = (HitActor != None && HitActor != Victim);
			if(bDamageBlocked && HitActor.IsA('KFDoorActor'))
			{
				bDamageBlocked = false;
			}
			if( !bDamageBlocked )
			{	
				Victim.TakeRadiusDamage(InstigatorController, ZedativeDamage * DamageScale, ZedativeEffectRadius,
				ZedativeDamageType, ExplosionTemplate.MomentumTransferScale, Location, bDoFullDamage,
				(Owner != None) ? Owner : self, ExplosionTemplate.DamageFalloffExponent);
			}
		}
		else 
		{
			HumanVictim = KFPawn_Human(Victim);
			if( HumanVictim != none && HumanVictim.GetExposureTo(Location) > 0 )
			{
				if (AffectedHumans.Find(HumanVictim) == INDEX_NONE)
				{
					AffectedHumans.AddItem(HumanVictim);

					HumanVictim.HealDamage(ZedativeHealth, InstigatorController, ZedativeHealingType, false);
				}
			}
		}
	}
}

simulated function SpawnExplosionParticleSystem(ParticleSystem Template)
{
	// If the template is none, grab the default
    if( !ExplosionTemplate.bAllowPerMaterialFX && Template == none )
	{
	   Template = KFGameExplosion(ExplosionTemplate).ExplosionEffects.DefaultImpactEffect.ParticleTemplate;
	}

    WorldInfo.MyEmitterPool.SpawnEmitter(Template, Location, rotator(ExplosionTemplate.HitNormal));
}

DefaultProperties
{
	bExplodeMoreThanOnce=true
	bDoFullDamage=false
	bSkipLineCheckForPawns=true

	LoopStartEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Play_WEP_EXP_Grenade_Medic_Smoke_Loop'
	LoopStopEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Stop_WEP_EXP_Grenade_Medic_Smoke_Loop'

	bNetTemporary=true
	bAlwaysRelevant=true
	RemoteRole=ROLE_SimulatedProxy
	bNetInitialRotation=TRUE
}
