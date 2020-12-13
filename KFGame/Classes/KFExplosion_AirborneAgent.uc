//=============================================================================
// KFExplosion_AirborneAgent
//=============================================================================
// Used by projectiles and kismet to spawn an explosion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================

class KFExplosion_AirborneAgent extends KFExplosionActorReplicated;

var() class<KFDamageType> HealingDamageType;
var() float HealingAmount;

var AkEvent LoopStartEvent;
var AkEvent LoopStopEvent;

/** How often to do damage */
var() float Interval;
/** How long to do damage for total */
var() float MaxTime;
/** Use an AllPawns check rather than CollidingActors */
var() bool bOnlyDamagePawns;
/** If using bOnlyDamagePawns, controls whether or not to perform a world geometry trace */
var() bool bSkipLineCheckForPawns;
/** if true, damage will ignore fall off */
var() bool bDoFullDamage;

var bool bWasFadedOut;
var KFPerk CachedInstigatorPerk;

var() ParticleSystem					LoopingParticleEffect;
var	transient ParticleSystemComponent	LoopingPSC;

var private const string AAHealingDamageTypePath;

var transient ParticleSystemComponent PSC;

var Pawn MyPawn;

replication
{
	if( bNetInitial )
		MyPawn;
}

simulated event ReplicatedEvent(Name VarName)
{
	if( Instigator == none && MyPawn != none )
	{
		Instigator = MyPawn;
		InstigatorController = MyPawn.Controller;
		Attachee = MyPawn;
		SetPhysics( PHYS_NONE );
		SetBase( MyPawn,, MyPawn.Mesh );
	}

	super.ReplicatedEvent(VarName);
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

	if( HealingDamageType == none )
	{
		HealingDamageType = class<KFDamageType>(DynamicLoadObject(default.AAHealingDamageTypePath, class'Class'));
	}

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
				HumanVictim.HealDamage(HealingAmount, InstigatorController, HealingDamageType);
			}
		}
	}
}

simulated function SpawnExplosionParticleSystem(ParticleSystem Template)
{
	local KFPawn_Human KFPH;

	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	// If the template is none, grab the default
    if( !ExplosionTemplate.bAllowPerMaterialFX && Template == none )
	{
	   Template = KFGameExplosion(ExplosionTemplate).ExplosionEffects.DefaultImpactEffect.ParticleTemplate;
	}

	KFPH = KFPawn_Human(Instigator);

    if( KFPH != none )
    {
	    KFPH.PerkFXEmitterPool.SpawnEmitter(Template, Location, rotator(vect(0,0,0)), Instigator);
	}
}

/*
 * @param Direction     For bDirectionalExplosion=true explosions, this is the forward direction of the blast.
 * Overridden to add the ability to spawn fragments from the explosion
 **/
simulated function Explode(GameExplosion NewExplosionTemplate, optional vector Direction)
{
	local KFPawn KFP;

	super.Explode(NewExplosionTemplate, Direction);

	LifeSpan = MaxTime;

	if( Role == Role_Authority )
	{
		SetTimer( Interval, true, nameof(DelayedExplosionDamage), self );
	}

	if( Instigator != none )
	{
		KFP = KFPawn(Instigator);
		if( KFP != none )
		{
			CachedInstigatorPerk = KFP.GetPerk();
		}
	}

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( LoopStartEvent != none )
		{
			PlaySoundBase( LoopStartEvent, true );
		}

		if( LoopingParticleEffect != none )
		{
			StartLoopingParticleEffect();
		}
	}
}

simulated function StartLoopingParticleEffect()
{
	LoopingPSC = new(self) class'ParticleSystemComponent';
	LoopingPSC.SetTemplate( LoopingParticleEffect );
	AttachComponent(LoopingPSC);

	SetTimer( Max(MaxTime - 0.5f, 0.1f), false, nameof(StopLoopingParticleEffect), self);
}

/** Fades explosion actor out over a couple seconds */
simulated function FadeOut( optional bool bDestroyImmediately )
{
	if( bWasFadedOut )
	{
		return;
	}

	bWasFadedOut = true;

	if( WorldInfo.NetMode != NM_DedicatedServer && LoopStopEvent != none )
	{
		PlaySoundBase( LoopStopEvent, true );
	}

	StopLoopingParticleEffect();

	if( !bDeleteMe && !bPendingDelete )
	{
		SetTimer( 2.f, false, nameOf(Destroy) );
	}
}

simulated event Destroyed()
{
	FadeOut();

	super.Destroyed();
}

simulated function StopLoopingParticleEffect()
{
	if( WorldInfo.NetMode != NM_DedicatedServer && LoopingPSC != none )
	{
        LoopingPSC.DeactivateSystem();
	}
}

/**
  * Does damage modeling and application for explosions
  * @PARAM bCauseDamage if true cause damage to actors within damage radius
  * @PARAM bCauseEffects if true apply other affects to actors within appropriate radii
  * @RETURN TRUE if at least one Pawn victim got hurt. (This is only valid if bCauseDamage == TRUE)
  */
protected simulated function bool DoExplosionDamage(bool bCauseDamage, bool bCauseEffects)
{
	if( bWasFadedOut || bDeleteMe || bPendingDelete )
	{
		return false;
	}

	if( bOnlyDamagePawns )
	{
		return ExplodePawns();
	}

	return super.DoExplosionDamage(bCauseDamage, bCauseEffects);
}

/** Stripped down and optimized version of DoExplosionDamage that only checks for pawns */
protected simulated function bool ExplodePawns()
{
	local Pawn 		Victim;
	local float 	CheckRadius;
	local bool		bDamageBlocked, bHitPawn;
	local Actor		HitActor;
	local vector	BBoxCenter;
	local float 	DamageScale;
	local Box BBox;

	if( bWasFadedOut || bDeleteMe || bPendingDelete )
	{
		return false;
	}

	// determine radius to check
	CheckRadius = GetEffectCheckRadius(true, false, false);
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

DefaultProperties
{
	AAHealingDamageTypePath="KFGameContent.KFDT_Healing_MedicGrenade"
	HealingAmount=5
	Interval=1
	MaxTime=8

	bExplodeMoreThanOnce=true
	bDoFullDamage=true
	bSkipLineCheckForPawns=true

	bOnlyDamagePawns=true

	LoopStartEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Play_WEP_EXP_Grenade_Medic_Smoke_Loop'
	LoopStopEvent=AkEvent'WW_WEP_EXP_Grenade_Medic.Stop_WEP_EXP_Grenade_Medic_Smoke_Loop'
}
