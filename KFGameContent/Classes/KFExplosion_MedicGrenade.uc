//=============================================================================
// KFExplosion_MedicGrenade
//=============================================================================
// Used by projectiles and kismet to spawn an explosion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFExplosion_MedicGrenade extends KFExplosionActorLingering;

var() class<KFDamageType> HealingDamageType;
var() float HealingAmount;

var AkEvent SmokeLoopStartEvent;
var AkEvent SmokeLoopStopEvent;

var KFPerk CachedInstigatorPerk;

/*
 * @param Direction     For bDirectionalExplosion=true explosions, this is the forward direction of the blast.
 * Overridden to add the ability to spawn fragments from the explosion
 **/
simulated function Explode(GameExplosion NewExplosionTemplate, optional vector Direction)
{
	local KFPawn KFP;
	super.Explode(NewExplosionTemplate, Direction);

	if( Instigator != none )
	{
		KFP = KFPawn(Instigator);
		if( KFP != none )
		{
			CachedInstigatorPerk = KFP.GetPerk();
		}
	}

	if (Role == Role_Authority)
	{
		//DelayedExplosionDamage();
		SetTimer(Interval, true, nameof(DelayedExplosionDamage), self);
	}
}

/**
  * Deal damage or heal players
  */
protected simulated function AffectsPawn(Pawn Victim, float DamageScale)
{
	local KFPawn_Human HumanVictim;
	local KFPawn_Monster MonsterVictim;
	local KFProj_MedicGrenade OwnerProjectile;
	local bool bCanRepairArmor;
	local Box BBox;	
	local vector	BBoxCenter;
	local Actor		HitActor;
	local bool		bDamageBlocked;

	if( Victim != none && Victim.IsAliveAndWell() )
	{
		MonsterVictim = KFPawn_Monster(Victim);
		if( MonsterVictim != none )
		{
			if( bWasFadedOut|| bDeleteMe || bPendingDelete )
			{
				return;
			}

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
				Victim.TakeRadiusDamage(InstigatorController, ExplosionTemplate.Damage * DamageScale, ExplosionTemplate.DamageRadius,
				ExplosionTemplate.MyDamageType, ExplosionTemplate.MomentumTransferScale, Location, bDoFullDamage,
				(Owner != None) ? Owner : self, ExplosionTemplate.DamageFalloffExponent);
			}
		}
		else 
		{
			HumanVictim = KFPawn_Human(Victim);
			if( HumanVictim != none && HumanVictim.GetExposureTo(Location) > 0 )
			{
				OwnerProjectile = KFProj_MedicGrenade(Owner);

				if( OwnerProjectile != none )
				{
					bCanRepairArmor = OwnerProjectile.HealedPawns.Find( HumanVictim ) == INDEX_NONE;
				}
				
				HumanVictim.HealDamage(HealingAmount, InstigatorController, HealingDamageType, bCanRepairArmor);

				if( bCanRepairArmor )
				{
					OwnerProjectile.HealedPawns.AddItem( HumanVictim );
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
	HealingDamageType=class'KFDT_Healing_MedicGrenade'
	HealingAmount=5
	Interval=1
	MaxTime=8

	bExplodeMoreThanOnce=true
	bDoFullDamage=true
	bSkipLineCheckForPawns=true

	LoopStartEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Play_WEP_EXP_Grenade_Medic_Smoke_Loop'
	LoopStopEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Stop_WEP_EXP_Grenade_Medic_Smoke_Loop'
}
