//=============================================================================
// KFExplosion_HRG_Vampire_BloodBall
//=============================================================================
// Used by projectiles and kismet to spawn an explosion
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================

class KFExplosion_HRG_Vampire_BloodBall extends KFExplosionActorLingering;

var() class<KFDamageType> HealingDamageType;
var() float HealingAmount;

var AkEvent SmokeLoopStartEvent;
var AkEvent SmokeLoopStopEvent;

var KFPerk CachedInstigatorPerk;

var float ChargePercentage;

var float DamageByChargePercentage;

var float fMinAmmoutHealing;
var float fMaxAmmoutHealing;

var float fAltMinAmmoutHealing;
var float fAltMaxAmmoutHealing;

var bool bHealsInstigator;
var bool bHealsDifferentAmmoutToInstigator;

var float ImpactDecalSizeMax;
var float ImpactDecalSizeMin;

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
	//ChargePercentage
	vec.X = ChargePercentage;
   	vec.Y = ChargePercentage;
    vec.Z = ChargePercentage;
	PSC.SetVectorParameter( name("BlobCharge"), vec);
	PSC.SetFloatParameter( name("MineFxControlParam"), ChargePercentage);
	

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
	local float AmountToHeal;


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
						AmountToHeal = FMax(fAltMinAmmoutHealing, Lerp(fAltMinAmmoutHealing, fAltMaxAmmoutHealing, DamageByChargePercentage));
						HumanVictim.HealDamage( AmountToHeal, InstigatorController, HealingDamageType, bCanRepairArmor);
					}
					else
					{
						AmountToHeal = FMax(fMinAmmoutHealing, Lerp(fMinAmmoutHealing, fMaxAmmoutHealing, DamageByChargePercentage));
						HumanVictim.HealDamage(	AmountToHeal, InstigatorController, HealingDamageType, bCanRepairArmor);
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

simulated protected function UpdateExplosionTemplateWithPerMaterialFX(PhysicalMaterial PhysMaterial)
{
	super.UpdateExplosionTemplateWithPerMaterialFX(PhysMaterial);
	
	// Set a default impact effect if there isn't a physical material
    if( PhysMaterial == none )
	{
        MyImpactEffect = KFGameExplosion(ExplosionTemplate).ExplosionEffects.DefaultImpactEffect;
	}
    else if( WorldInfo.MyImpactEffectManager != none ) // none on dedicated server
    {
        `ImpactEffectManager.GetImpactEffect(PhysMaterial, MyImpactEffect,KFGameExplosion(ExplosionTemplate).ExplosionEffects);
    }

    if( MyImpactEffect.ParticleTemplate != none )
    {
		ExplosionTemplate.ExplosionSound = MyImpactEffect.Sound;

    }
}

//Copied from KFExplosionActor -> SpawnExplosionDecal
//Added support to variable DecalSize depending on blood ball charge.
simulated function SpawnExplosionDecal()
{
	local MaterialInterface MI;
	local MaterialInstanceTimeVarying MITV_Decal;
	local int DecalMaterialsLength;
	local float DecalSize, DecalThickness;
	local KFGameExplosion KFExplosionTemplate;

	if( WorldInfo.bDropDetail )
	{
		return;
	}

	// If the template is none, grab the default
    if( !ExplosionTemplate.bAllowPerMaterialFX )
	{
		KFExplosionTemplate = KFGameExplosion(ExplosionTemplate);
		if( KFExplosionTemplate == none || KFExplosionTemplate.ExplosionEffects == none )
		{
			return;
		}
		
	   	MyImpactEffect = KFExplosionTemplate.ExplosionEffects.DefaultImpactEffect;
	}

	// if we have a decal to spawn on impact
	DecalMaterialsLength = MyImpactEffect.DecalMaterials.length;
	if( DecalMaterialsLength > 0 )
	{
		MI = MyImpactEffect.DecalMaterials[Rand(DecalMaterialsLength)];
		if( MI != None )
		{
            DecalSize = Lerp(ImpactDecalSizeMin, ImpactDecalSizeMax, ChargePercentage);

            //Always extend decal thickness for explosions
            DecalThickness = DecalSize * 2.f;

			if( MaterialInstanceTimeVarying(MI) != none )
			{
					MITV_Decal = new(self) class'MaterialInstanceTimeVarying';
					MITV_Decal.SetParent( MI );

            		WorldInfo.ExplosionDecalManager.SpawnDecal(MITV_Decal, ExplosionTemplate.HitLocation, rotator(-ExplosionTemplate.HitNormal), DecalSize, DecalSize, DecalThickness, FALSE,(MyImpactEffect.bNoDecalRotation) ? 0.f : (FRand() * 360.0) );
            		//here we need to see if we are an MITV and then set the burn out times to occur
            		MITV_Decal.SetScalarStartTime( MyImpactEffect.DecalDissolveParamName, MyImpactEffect.DecalDuration );
			}
			else
			{
				WorldInfo.ExplosionDecalManager.SpawnDecal( MI, ExplosionTemplate.HitLocation, rotator(-ExplosionTemplate.HitNormal), DecalSize, DecalSize, DecalThickness, true,
                    (MyImpactEffect.bNoDecalRotation) ? 0.f : (FRand() * 360.0),,,,,,, MyImpactEffect.DecalDuration );
			}
		}
	}
}

DefaultProperties
{
	HealingDamageType=class'KFDT_Healing'
	HealingAmount=0;

	fMinAmmoutHealing=12; //10;
	fMaxAmmoutHealing=60; //50;
	
	ImpactDecalSizeMax=425.f
    ImpactDecalSizeMin=178.f

	Interval=0
	MaxTime=0.0
	FadeOutTime=0.0

	bExplodeMoreThanOnce=false
	bDoFullDamage=false

	bOnlyDamagePawns=true

	bSkipLineCheckForPawns=true

	LoopStartEvent=none
	LoopStopEvent=none

//EXPERIMENTAL FEATURES FOR DESIGN
	bHealsInstigator = false;
	bHealsDifferentAmmoutToInstigator = false;
	fAltMinAmmoutHealing=1;
	fAltMaxAmmoutHealing=5;
}
