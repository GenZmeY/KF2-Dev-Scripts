//=============================================================================
// KFProj_BloodBall_HRG_Vampire
//=============================================================================
// Projectile class for Vampire
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================
class KFProj_BloodBall_HRG_Vampire extends KFProjectile;


/** Storing all relative info about Blood Ball charged (in order to help in replication) */
struct BloodBallChargeInfo
{
	var float ChargePercentage;
	var float DamageByChargePercentage;
};

/** Dampen amount for every bounce */
var float DampenFactor;

/** Dampen amount for parallel angle to velocity */
var float DampenFactorParallel;

/** Vector to offset the ground FX particle system by when landing */
var vector LandedFXOffset;

/** Armed mine collision settings */

/** Decal settings */
var MaterialInterface ImpactDecalMaterial;
var float ImpactDecalWidth;
var float ImpactDecalHeight;
var float ImpactDecalThickness;

var float MaxExplodeTriggerHeightPerPercentage;
var float MinExplodeTriggerHeightPerPercentage;

var float MaxDamageRadiusPerPercentage;
var float MinDamageRadiusPerPercentage;

var float MaxCollisionRadius;
var float MinCollisionRadius;
var float MaxCollisionHeight;
var float MinCollisionHeight;

var float MaxDamagePerPercentage;
var float MinDamagePerPercentage;

var repnotify BloodBallChargeInfo BloodBallCharge;

var float fCachedCylinderWidth, fCachedCylinderHeight;

//EXPERIMENTAL FEATURES
var bool bCantBeTouchedByInstigator;
var bool bManuallyDetonated;
var bool bCantDetonateOnFullHP;

replication
{
	if( bNetDirty && Role == Role_Authority)
		BloodBallCharge;
}

simulated event ReplicatedEvent( name VarName )
{
	super.ReplicatedEvent( VarName );

	if( VarName == nameOf(BloodBallCharge))
	{
		ScalingExplosionTemplateByBloodBallCharge();
		ScalingProjEffectsByBloodBallCharge();
	}
}

simulated function SetInheritedScale(float NewChargePercentage, float NewDamageByChargePercentage)
{
	BloodBallCharge.DamageByChargePercentage=NewDamageByChargePercentage;
	BloodBallCharge.ChargePercentage = FMax(0.1, NewChargePercentage);//We want to see at least a bit of the projectile.
	
	ScalingExplosionTemplateByBloodBallCharge();
	ScalingProjEffectsByBloodBallCharge();

	bNetDirty=true;
}

simulated function ScalingExplosionTemplateByBloodBallCharge()
{
	fCachedCylinderWidth = Lerp(MinCollisionRadius, MaxCollisionRadius, BloodBallCharge.ChargePercentage);
	fCachedCylinderHeight = Lerp(MinCollisionHeight, MaxCollisionHeight, BloodBallCharge.ChargePercentage);
	CylinderComponent(CollisionComponent).SetCylinderSize(fCachedCylinderWidth, fCachedCylinderHeight);

	ExplosionTemplate.DamageRadius = FMax(MinDamageRadiusPerPercentage, Lerp(MinDamageRadiusPerPercentage, MaxDamageRadiusPerPercentage, BloodBallCharge.DamageByChargePercentage));
	ExplosionTemplate.Damage = FMax(MinDamagePerPercentage, Lerp(MinDamagePerPercentage, MaxDamagePerPercentage, BloodBallCharge.DamageByChargePercentage));
}

simulated function ScalingProjEffectsByBloodBallCharge()
{
	local vector ChargePercentageVector;
	ChargePercentageVector.X = BloodBallCharge.ChargePercentage;
	ChargePercentageVector.Y = BloodBallCharge.ChargePercentage;
   	ChargePercentageVector.Z = BloodBallCharge.ChargePercentage;

	if(ProjEffects != None)
	{
		ProjEffects.SetVectorParameter( name("BlobCharge"), ChargePercentageVector);
		ProjEffects.SetFloatParameter( name("MineFxControlParam"), BloodBallCharge.ChargePercentage);
	}
}




simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	BloodBallCharge.ChargePercentage=0;
	BloodBallCharge.DamageByChargePercentage=0;
}

simulated function SpawnFlightEffects()
{
	super.SpawnFlightEffects();
}

/** Validates a touch */


simulated protected function PrepareExplosionTemplate()
{

	local Weapon OwnerWeapon;
	local Pawn OwnerPawn;

	super(KFProjectile).PrepareExplosionTemplate();
	OwnerWeapon = Weapon(Owner);
	if (OwnerWeapon != none)
	{
		OwnerPawn = Pawn(OwnerWeapon.Owner);
		if (OwnerPawn != none)
		{
			ExplosionTemplate.DamageRadius *= KFPawn(OwnerPawn).GetPerk().GetAoERadiusModifier();
		}
	}
}

simulated protected function PrepareExplosionActor(GameExplosionActor GEA)
{
	KFExplosion_HRG_Vampire_BloodBall(GEA).ChargePercentage = BloodBallCharge.ChargePercentage;
	KFExplosion_HRG_Vampire_BloodBall(GEA).DamageByChargePercentage = BloodBallCharge.DamageByChargePercentage;
	super.PrepareExplosionActor(GEA);
}

/** Call ProcessBulletTouch */
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	if (Other == Instigator || CheckRepeatingTouch(Other))
	{
		return;
	}

	if (IgnoreTouchActor != Other)
	{
		ProcessBulletTouch(Other, HitLocation, HitNormal);
	}
	super.ProcessTouch(Other, HitLocation, HitNormal);
}

defaultproperties
{
    Speed=2000
    MaxSpeed=2000
    TerminalVelocity=2000
    TossZ=150
    GravityScale=0.5
    MomentumTransfer=50000.0

	LifeSpan=300
	PostExplosionLifetime=1
	Physics=PHYS_Falling
	bBounce=true

	ProjFlightTemplate=	ParticleSystem'WEP_HRG_Vampire_EMIT.FX_HRG_Vampire_BlobProjectile_01'
	ExplosionActorClass=class'KFExplosion_HRG_Vampire_BloodBall'

	bSuppressSounds=false
	bAmbientSoundZedTimeOnly=false
    bAutoStartAmbientSound=false
	bStopAmbientSoundOnExplode=true

    AmbientSoundPlayEvent=None
    AmbientSoundStopEvent=None

    Begin Object Class=AkComponent name=AmbientAkSoundComponent
    	bStopWhenOwnerDestroyed=true
    	bForceOcclusionUpdateInterval=true
        OcclusionUpdateInterval=0.25f
    End Object
    AmbientComponent=AmbientAkSoundComponent
    Components.Add(AmbientAkSoundComponent)

    //ImpactDecalMaterial=DecalMaterial'FX_Mat_Lib.FX_Puke_Mine_Splatter_DM'
    ImpactDecalWidth=178.f
    ImpactDecalHeight=178.f
    ImpactDecalThickness=28.f

	Begin Object Name=CollisionCylinder
		CollisionRadius=10.f
		CollisionHeight=10.f
		CollideActors=true
		//PhysMaterialOverride=PhysicalMaterial'WEP_Mine_Reconstructor_EMIT.BloatPukeMine_PM'
	End Object

	bCollideActors=true
	bProjTarget=true
	bCanBeDamaged=false
	bCollideComplex=true
	bNoEncroachCheck=true
    bPushedByEncroachers=false
    DampenFactor=0.125f
    DampenFactorParallel=0.175f

	LandedFXOffset=(X=0,Y=0,Z=2)

	// Since we're still using an extent cylinder, we need a line at 0
	ExtraLineCollisionOffsets.Add(())

	// Explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=200
		DamageRadius=200
		DamageFalloffExponent=0.5f
		DamageDelay=0.f
		MyDamageType=class'KFDT_Toxic_HRG_Vampire_BloodBall'
		//bIgnoreInstigator is set to true in PrepareExplosionTemplate

		//Impulse applied to Zeds
		MomentumTransferScale=45000

		// Damage Effects
		KnockDownStrength=0
		KnockDownRadius=0
		FractureMeshRadius=0
		FracturePartVel=0
		ExplosionEffects=KFImpactEffectInfo'WEP_HRG_Vampire_Arch.HRG_Vampire_BlobFireImpacts'
		ExplosionSound=None
		bAllowPerMaterialFX=true
		//MomentumTransferScale=0

        // Dynamic Light
        ExploLight=none

		// Camera Shake
		CamShake=CameraShake'WEP_Mine_Reconstructor_Arch.Camera_Shake'
		CamShakeInnerRadius=200
		CamShakeOuterRadius=400
		CamShakeFalloff=1.f
		bOrientCameraShakeTowardsEpicenter=true
		
	End Object
	ExplosionTemplate=ExploTemplate0

	GlassShatterType=FMGS_ShatterAll


	MaxExplodeTriggerHeightPerPercentage=22
	MinExplodeTriggerHeightPerPercentage=11

	MaxDamageRadiusPerPercentage=280 //340
	MinDamageRadiusPerPercentage=130 //160

	MaxDamagePerPercentage=200 //150
	MinDamagePerPercentage=20 //15

	MaxCollisionRadius=20
	MinCollisionRadius=10
	MaxCollisionHeight=20
	MinCollisionHeight=10
	
	bBlockedByInstigator=true
	bNetTemporary=false

	bSyncToOriginalLocation=true
	bSyncToThirdPersonMuzzleLocation=true
	bUseClientSideHitDetection=true
	bUpdateSimulatedPosition=false

	TouchTimeThreshhold=0.05

	//EXPERIMENTAL FEATURES FOR DESING
	bManuallyDetonated=false
	bCantBeTouchedByInstigator=true
	bCantDetonateOnFullHP=true

	AssociatedPerkClass=class'KFPerk_FieldMedic'
}