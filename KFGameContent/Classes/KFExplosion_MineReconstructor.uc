//=============================================================================
// KFExplosion_MineReconstructor
//=============================================================================
// Used by projectiles and kismet to spawn an explosion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFExplosion_MineReconstructor extends KFExplosionActorLingering;

var() class<KFDamageType> HealingDamageType;
var() float HealingAmount;

var AkEvent SmokeLoopStartEvent;
var AkEvent SmokeLoopStopEvent;

var KFPerk CachedInstigatorPerk;

var float fChargePercentage;

var float fMinAmmoutHealing;
var float fMaxAmmoutHealing;

var float fAltMinAmmoutHealing;
var float fAltMaxAmmoutHealing;

var bool bHealsInstigator;
var bool bHealsDifferentAmmoutToInstigator;

/* Only used if bOnlyDamagePawns is active to create fractures in walls */
var bool bAllowFractureDamage;

simulated function SpawnExplosionParticleSystem(ParticleSystem Template)
{
	local ParticleSystemComponent PSC;
	local vector vec;

	// If the template is none, grab the default
    if( !ExplosionTemplate.bAllowPerMaterialFX && Template == none )
	{
	   Template = KFGameExplosion(ExplosionTemplate).ExplosionEffects.DefaultImpactEffect.ParticleTemplate;
	}

	// Use custom pool
    PSC = WorldInfo.MyEmitterPool.SpawnEmitter(Template, Location, rotator(ExplosionTemplate.HitNormal), None);
	//fChargePercentage
	vec.X = fChargePercentage;
   	vec.Y = fChargePercentage;
    vec.Z = fChargePercentage;
	PSC.SetVectorParameter( name("BlobCharge"), vec);
	PSC.SetFloatParameter( name("MineFxControlParam"), fChargePercentage);
	

}

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
		SetTimer(Interval, false, nameof(DelayedExplosionDamage), self);
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

			Victim.GetComponentsBoundingBox(BBox);
			BBoxCenter = (BBox.Min + BBox.Max) * 0.5f;
			HitActor = TraceExplosive(BBoxCenter, Location + vect(0, 0, 20));
			bDamageBlocked = (HitActor != None && HitActor != Victim);
			if(bDamageBlocked && HitActor.IsA('KFDoorActor'))
			{
				bDamageBlocked = false;
			}
			if(!bDamageBlocked)
			{
				if(!bHealsInstigator && Victim == Instigator)
				{
					return;
				}
				HumanVictim = KFPawn_Human(Victim);
				if( HumanVictim != none && HumanVictim.GetExposureTo(Location) > 0 )
				{
					OwnerProjectile = KFProj_MedicGrenade(Owner);
					if( OwnerProjectile != none )
					{
						bCanRepairArmor = OwnerProjectile.HealedPawns.Find( HumanVictim ) == INDEX_NONE;
					}
					
					if(bHealsDifferentAmmoutToInstigator && bHealsInstigator && Victim == Instigator)
					{
						HumanVictim.HealDamage(	Lerp(fAltMinAmmoutHealing, fAltMaxAmmoutHealing, fChargePercentage), InstigatorController, HealingDamageType, bCanRepairArmor);
					}
					else
					{
						HumanVictim.HealDamage(	Lerp(fMinAmmoutHealing, fMaxAmmoutHealing, fChargePercentage), InstigatorController, HealingDamageType, bCanRepairArmor);
					}

					if( bCanRepairArmor )
					{
						OwnerProjectile.HealedPawns.AddItem( HumanVictim );
					}
				}
			}
		}
	}
}

protected simulated function bool DoExplosionDamage(bool bCauseDamage, bool bCauseEffects)
{
	if( bWasFadedOut || bDeleteMe || bPendingDelete )
	{
		return false;
	}

	if( bOnlyDamagePawns && bAllowFractureDamage )
	{
		ExplodeFractures();
	}

	if( bOnlyDamagePawns )
	{
		return ExplodePawns();
	}

	return super(KFExplosionActor).DoExplosionDamage(bCauseDamage, bCauseEffects);
}

/** Check fractures only if */
protected simulated function ExplodeFractures()
{
	local Actor		Victim;
	local bool		bCauseFractureEffects;
	local float		CheckRadius, VictimDist;
	local Box BBox;
	local FracturedStaticMeshActor FracActor;
	local byte WantPhysChunksAndParticles;
	local TraceHitInfo HitInfo;

	if( bWasFadedOut || bDeleteMe || bPendingDelete )
	{
		return;
	}

	bCauseFractureEffects = WorldInfo.NetMode != NM_DedicatedServer && ExplosionTemplate.bCausesFracture;

	if( !bCauseFractureEffects )
	{
		return;
	}

	// determine radius to check
	CheckRadius = GetEffectCheckRadius(true, bCauseFractureEffects, WorldInfo.NetMode != NM_Client);
	if ( CheckRadius > 0.0 )
	{
		foreach CollidingActors(class'Actor', Victim, CheckRadius, Location, ExplosionTemplate.bUseOverlapCheck,,HitInfo )
		{
			if ( Victim != Self
				&& (!Victim.bWorldGeometry || Victim.bCanBeDamaged)
				&& (NavigationPoint(Victim) == None)
				&& Victim != ExplosionTemplate.ActorToIgnoreForDamage
				&& (!ExplosionTemplate.bIgnoreInstigator || Victim != Instigator)
				&& !ClassIsChildOf(Victim.Class, ExplosionTemplate.ActorClassToIgnoreForDamage)
				&& !IsBehindExplosion(Victim) )
			{

				// return if this is a pawn
				if(GamePawn(Victim) != none)
				{
					return;
				}

				// check if visible, unless physics object
				// note: using bbox center instead of location, because that's what visiblecollidingactors does
				Victim.GetComponentsBoundingBox(BBox);

				// adjust distance if using overlap check
				VictimDist = ExplosionTemplate.bUseOverlapCheck ? BoxDistanceToPoint(Location, BBox) : VSize(Location - Victim.Location);
				
				FracActor = FracturedStaticMeshActor(Victim);
				if ( (FracActor != None)
					&& (VictimDist < ExplosionTemplate.FractureMeshRadius)
					&& (FracActor.Physics == PHYS_None)
					&& FracActor.IsFracturedByDamageType(ExplosionTemplate.MyDamageType)
					&& FracActor.FractureEffectIsRelevant( false, Instigator, WantPhysChunksAndParticles) )
				{
					// Let kismet know that we were hit by an explosion
					FracActor.NotifyHitByExplosion(InstigatorController, ExplosionTemplate.Damage, ExplosionTemplate.MyDamageType);

					FracActor.BreakOffPartsInRadius(Location, ExplosionTemplate.FractureMeshRadius, ExplosionTemplate.FracturePartVel, WantPhysChunksAndParticles == 1 ? true : false);
				}
			}
		}
	}
}

DefaultProperties
{
	HealingDamageType=class'KFDT_Healing'
	HealingAmount=0;

	fMinAmmoutHealing=5; //4;
	fMaxAmmoutHealing=50; //40
	
	Interval=0
	MaxTime=0.0
	FadeOutTime=0.0

	bExplodeMoreThanOnce=false
	bDoFullDamage=false

	bOnlyDamagePawns=true
	bAllowFractureDamage=true

	bSkipLineCheckForPawns=true

	LoopStartEvent=none
	LoopStopEvent=none

//EXPERIMENTAL FEATURES FOR DESIGN
	bHealsInstigator = false;
	bHealsDifferentAmmoutToInstigator = false;
	fAltMinAmmoutHealing=1;
	fAltMaxAmmoutHealing=5;
}
