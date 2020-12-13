//=============================================================================
// KFWeapAttach_HRG_Vampire
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2020 Tripwire Interactive LLC
//=============================================================================
class KFWeapAttach_HRG_Vampire extends KFWeapAttach_SprayBase;

var transient ParticleSystemComponent ChargingPSC;
var transient ParticleSystemComponent ChargedPSC;
var ParticleSystem ChargingEffect;
var ParticleSystem ChargedEffect;
var ParticleSystem BloodStolenEffect;
var bool bIsCharging;
var bool bIsFullyCharged;
var bool bIsChargeEffectsActive;
var bool bIsBloodParticlesEffectActive;
var bool bIsDisabledSprayVisualAndMesh;

var repnotify float StartFireTime;

var int ChargeLevel;

var float FXScalingFactorByCharge;
var float ChargeRTPC;

var KFPawn_Monster oZedCurrentlyBeingSprayed;
var KFPawn_Monster oZedPreviouslyBeingSprayed;

var KFWeap_HRG_Vampire Weapon;

var KFEmit_DirectionalPath BloodStolenParticles[15];
var int NumBloodStolenParticlesForPool;

var transient float BloodStolenControlTime;

var float RateUpdateDestinationBloodParticles;
var transient float UpdateDestinationBloodParticlesTime;

var class<KFProj_BloodSplash> BloodSplashClass;

var bool bHasToStopDoingFireAnim;
var bool bHasToStopDoingFireAnimB;

/** Blood Particles */
var(BloodParticles) float SpeedBloodParticles;
var(BloodParticles) float SpawnRateBloodParticles;
var(BloodParticles) float SpeedBloodParticles_3P;
var(BloodParticles) float SpawnRateBloodParticles_3P;
var(BloodParticles) float HalfAngleSpawnCone;
var(BloodParticles) float CurveTurnRateUntilDestinationFinal;
var(BloodParticles) float CurveTurnRateUntilDestinationMidPoint;
var(BloodParticles) float LimitDistanceFinalPoint;
var(BloodParticles) float LimitDistanceMidPoint;

simulated function PostBeginPlay()
{
	local int Index;

	super.PostBeginPlay();
	UpdateDestinationBloodParticlesTime = RateUpdateDestinationBloodParticles;

	for( Index = (NumBloodStolenParticlesForPool - 1) ; Index >= 0 ; Index-- )
	{
		BloodStolenParticles[Index] = Spawn(class'KFEmit_DirectionalPath');
		BloodStolenParticles[Index].DeactivateEmitter();
		BloodStolenParticles[Index].SetTemplate(BloodStolenEffect, true);
	}
}

simulated function StartFire()
{
	StartFireTime = WorldInfo.TimeSeconds;
	bIsCharging = false;
	bIsFullyCharged = false;
	bIsDisabledSprayVisualAndMesh = false;
	
	if (ChargingPSC == none)
	{
		ChargingPSC = new(self) class'ParticleSystemComponent';

		if (WeapMesh != none)
		{
			WeapMesh.AttachComponentToSocket(ChargingPSC, 'MuzzleFlash');
		}
		else
		{
			AttachComponent(ChargingPSC);
		}
		ChargingPSC.SetTemplate(ChargingEffect);
	}

	if (ChargedPSC == none)
	{
		ChargedPSC = new(self) class'ParticleSystemComponent';

		if (WeapMesh != none)
		{
			WeapMesh.AttachComponentToSocket(ChargedPSC, 'MuzzleFlash');
		}
		else
		{
			AttachComponent(ChargedPSC);
		}
		ChargedPSC.SetTemplate(ChargedEffect);
	}
	ChargingPSC.SetActive( false );
	ChargedPSC.SetActive( false );
}

simulated event Tick(float DeltaTime)
{
	local int Index;
	local vector MuzzleFlashSocketLocation, BloodParticlesMidPointSocketLocation;
	local KFEmit_DirectionalPath EmitterToRemove;
	local vector VectorParameterParticle;
	local vector ChargePercentageVector;
	local Rotator DestinationRotation, BloodParticlesMidPointSocketRotation;
	local vector BloodSplashVelocity;
	
	if(bIsChargeEffectsActive)
	{
		if(bIsCharging)
		{
			ChargingPSC.SetActive( true, true );
			ChargePercentageVector.X = ChargeRTPC;
			ChargePercentageVector.Y = ChargeRTPC;
			ChargePercentageVector.Z = ChargeRTPC;
			ChargingPSC.SetVectorParameter( name("BlobCharge"), ChargePercentageVector);
		}

		if(bIsFullyCharged)
		{
			ChargedPSC.SetActive( true, true );
			ChargingPSC.SetFloatParameter( name("InflateBlob"), ChargeRTPC);
		}
	}

	if (bIsDisabledSprayVisualAndMesh)
	{
		TurnOffFireSpray();
		ActiveFlameSpray.CleanupEndFire();
	}

	//Spawning blood particles if conditions met
	if (bIsBloodParticlesEffectActive)
	{
		if(oZedCurrentlyBeingSprayed != none && oZedCurrentlyBeingSprayed.IsAliveAndWell())
		{
			CreateBloodParticle(DeltaTime, oZedCurrentlyBeingSprayed);
		}
	}


	// Updating blood stolen particles FX destination position

	UpdateDestinationBloodParticlesTime -= DeltaTime;
	if (UpdateDestinationBloodParticlesTime <= 0)
	{
		UpdateDestinationBloodParticlesTime = RateUpdateDestinationBloodParticles;

		if( WeapMesh != none )
		{
			GetFlameSocketLocAndRot(MuzzleFlashSocketLocation, DestinationRotation);
			WeapMesh.GetSocketWorldLocationAndRotation('BloodParticlesMidPoint', BloodParticlesMidPointSocketLocation, BloodParticlesMidPointSocketRotation);
		}

		for( Index = (NumBloodStolenParticlesForPool - 1) ; Index >= 0 ; Index-- )
		{
			if(!BloodStolenParticles[Index].IsEnabled || BloodStolenParticles[Index] == None)
			{
				continue;
			}

			if( BloodStolenParticles[Index].bReachDestinationFinal )
			{
				EmitterToRemove = BloodStolenParticles[Index];
				//BloodStolenParticles.Remove(Index, 1);
				EmitterToRemove.DeactivateEmitter();
			}
			else
			{
				if (BloodStolenParticles[Index].ParticleSystemComponent != None)
				{
					VectorParameterParticle.X = WorldInfo.TimeDilation;
					VectorParameterParticle.Y = WorldInfo.TimeDilation;
					VectorParameterParticle.Z = WorldInfo.TimeDilation;
					BloodStolenParticles[Index].ParticleSystemComponent.SetVectorParameter( name("ZedtimeScale"), VectorParameterParticle );
				}
				BloodStolenParticles[Index].UpdateDestination( MuzzleFlashSocketLocation, BloodParticlesMidPointSocketLocation );

				if (FRand() > 0.47)
				{
					BloodSplashVelocity.x = 0;
					BloodSplashVelocity.y = RandRange(-100, 100);
					BloodSplashVelocity.z = -200;
					SpawnBloodSplash(BloodSplashClass, BloodStolenParticles[Index].Location, BloodSplashVelocity);
				}
			}
		}
	}

	Super.Tick(DeltaTime);
}

simulated function FirstPersonFireEffects(Weapon W, vector HitLocation)
{
	super.FirstPersonFireEffects(W, HitLocation);
}

simulated function bool ThirdPersonFireEffects(vector HitLocation, KFPawn P, byte ThirdPersonAnimRateByte )
{
	local EAnimSlotStance AnimType;
	local bool bResult;
	bIsChargeEffectsActive = true;
	bIsBloodParticlesEffectActive = true;

	//bResult = Super(KFWeaponAttachment).ThirdPersonFireEffects(HitLocation,P,ThirdPersonAnimRateByte);

 	SpawnTracer(GetMuzzleLocation(), HitLocation);

	// Effects below this point are culled based on visibility and distance
	if ( !ActorEffectIsRelevant(P, false, MaxFireEffectDistance) )
	{
		return false;
	}

	DecodeThirdPersonAnimRate( ThirdPersonAnimRateByte );

	// Weapon shoot anims
	if( !bWeapMeshIsPawnMesh && bHasToStopDoingFireAnim == false )
	{
		PlayWeaponFireAnim();
		bHasToStopDoingFireAnim = true;
	}

	if( P.IsDoingSpecialMove() && P.SpecialMoves[P.SpecialMove].bAllowFireAnims )
	{
		AnimType = EAS_Additive;
	}
	else
	{
		AnimType = EAS_FullBody;
	}

	// Character shoot anims
	if ( !P.IsDoingSpecialMove() || AnimType == EAS_Additive )
	{
		if(!bHasToStopDoingFireAnimB)
		{
			bHasToStopDoingFireAnimB = true;
			PlayPawnFireAnim( P, AnimType );
		}

		// interrupt other weapon action anims (e.g. Reload)
		if( !P.IsDoingSpecialMove() )
		{
			P.StopBodyAnim(P.bIsCrouched ? EAS_CH_UpperBody : EAS_UpperBody, 0.1f);
		}

		if ( OnWeaponStateChanged != None )
		{
			OnWeaponStateChanged(true);
		}
	}

	CauseMuzzleFlash(P.FiringMode);

	// Wider effect distances for fire spray. Called on Instigator to go beyond the weapon mesh cull distance
	if ( P.FiringMode != 1 && P.ActorEffectIsRelevant(P, false, 15000, 2000) && !bIsDisabledSprayVisualAndMesh )
	{
		TurnOnFireSpray();
		bResult = true;
	}

    return bResult;
}

simulated function StopThirdPersonFireEffects(optional bool bForce)
{
	Super.StopThirdPersonFireEffects(bForce);
	bIsChargeEffectsActive = false;
	bIsBloodParticlesEffectActive = false;
	RemoveAllBloodParticles();
	bIsDisabledSprayVisualAndMesh = false;
	if (ChargingPSC != none)
	{
		ChargingPSC.SetActive(false);
	}
	if (ChargedPSC != none)
	{
		ChargedPSC.SetActive(false);
	}
	bHasToStopDoingFireAnim = false;
	bHasToStopDoingFireAnimB = false;
}

simulated function CauseMuzzleFlash(byte FiringMode)
{
	if (MuzzleFlash == None && MuzzleFlashTemplate != None)
	{
		AttachMuzzleFlash();
	}

	Super.CauseMuzzleFlash(FiringMode);
}

simulated protected function TurnOnPilot()
{
	Super.TurnOnPilot();

	if( FlamePool[0] != None && KFSprayActor_HRG_Vampire(FlamePool[0]) != None && KFSprayActor_HRG_Vampire(FlamePool[0]).OwnerWeapon == None)
	{
		KFSprayActor_HRG_Vampire(FlamePool[0]).OwnerWeapon = KFWeap_HRG_Vampire(KFPawn_Human(Instigator).MyKFWeapon);
	}
	if( FlamePool[1] != None && KFSprayActor_HRG_Vampire(FlamePool[1]) != None && KFSprayActor_HRG_Vampire(FlamePool[1]).OwnerWeapon == None)
	{
		KFSprayActor_HRG_Vampire(FlamePool[1]).OwnerWeapon = KFWeap_HRG_Vampire(KFPawn_Human(Instigator).MyKFWeapon);
	}
}

simulated function CreateBloodParticle(float DeltaTime, KFPawn_Monster Monster)
{
	Local KFEmit_DirectionalPath Emitter;
	local vector DestinationLocation, MonsterLocation, BloodParticlesMidPointSocketLocation;
	local Rotator DestinationRotation, BloodParticlesMidPointSocketRotation;
	local vector BloodSplashVelocity;
	local int Index;

	if( BloodStolenControlTime > 0 )
	{
		BloodStolenControlTime -= DeltaTime;
		return;
	}

	Emitter = none;
	for( Index = (NumBloodStolenParticlesForPool - 1) ; Index >= 0 ; Index-- )
	{
		if(BloodStolenParticles[Index].IsEnabled == false)
		{
			//`log("I gave the emitter");
			Emitter = BloodStolenParticles[Index];
			break;
		}		
	}	

	if(Emitter == none)
	{
		//`log("NO EMITTER");
		return;
	}


	if( WeapMesh != none && WeapMesh.SkeletalMesh != none)
	{
		GetFlameSocketLocAndRot(DestinationLocation, DestinationRotation);
		WeapMesh.GetSocketWorldLocationAndRotation('BloodParticlesMidPoint', BloodParticlesMidPointSocketLocation, BloodParticlesMidPointSocketRotation);
	}

	BloodStolenControlTime += SpawnRateBloodParticles_3P;
	MonsterLocation = ActiveFlameSpray.GetLastContactPositionMeshHit();
	if (IsZero(MonsterLocation))
	{
		Monster.Mesh.GetBoneLocation('Spine1');
	}

	if(MonsterLocation == vect(0,0,0))
	{
		MonsterLocation = Monster.Location + vect(0,0,20);
	}
	
	if (FRand() > 0.4)
	{
		BloodSplashVelocity = BloodParticlesMidPointSocketLocation - MonsterLocation;
		BloodSplashVelocity = VRandCone(vect(0,0,-1), PI / 5) * 100;
		SpawnBloodSplash(BloodSplashClass, MonsterLocation, BloodSplashVelocity);
	}

	//Emitter = Spawn(class'KFEmit_DirectionalPath',,, MonsterLocation);
	Emitter.ParticleSpeed = SpeedBloodParticles_3P;
	Emitter.RateTickCheckHasReached = 0.2;
	//BloodStolenParticles.AddItem(Emitter);
	Emitter.SetLocation(MonsterLocation);

	Emitter.SetDestination(DestinationLocation, BloodParticlesMidPointSocketLocation, 20, 20, 50, 50, 0);
	Emitter.ActivateEmitter();
	//Emitter.isEnabled = true;

}

simulated function SetChargePercentage(float ChargePercentage)
{
	ChargeRTPC = ChargePercentage;
	bIsCharging = false;
	bIsFullyCharged = false;

	if (ChargeRTPC >= 0.0)
	{
		bIsCharging = true;
	}

	if (ChargeRTPC >= 1.0)
	{
		bIsFullyCharged = true;
	}
}

simulated function SetZedCurrentlyBeingSprayed(KFPawn_Monster ZedCurrentlyBeingSprayed)
{
	oZedPreviouslyBeingSprayed = oZedCurrentlyBeingSprayed;
	oZedCurrentlyBeingSprayed = ZedCurrentlyBeingSprayed;
}

simulated function DisableSprayVisualAndMesh()
{
	bIsDisabledSprayVisualAndMesh = true;
}

function SpawnBloodSplash( class<KFProj_BloodSplash> SpawnClass, vector SpawnLoc, vector SpawnVel )
{
	local TraceHitInfo HitInfo;
	local vector HitLocation, HitRotation;
	local KFGoreManager GoreManager;

	// Grab the gore manager
	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);

	if (GoreManager == none || oZedCurrentlyBeingSprayed == none)
	{
		return;
	}

	//EffectStartTrace = Location + vect(0,0,1) * 4.f;
	//EffectEndTrace = EffectStartTrace - vect(0,0,1) * 32.f;

    // Find where to put the decal
	Trace(HitLocation, HitRotation, SpawnLoc + SpawnVel * 32.f, SpawnLoc, false,, HitInfo, TRACEFLAG_Bullet);
	//DrawDebugLine(SpawnLoc,SpawnLoc + SpawnVel * 32.f,0,255,0,TRUE);

	// If the locations are zero (probably because this exploded in the air) set defaults
    if( IsZero(HitLocation) )
    {
        HitLocation = Location;
    }

	if( IsZero(HitRotation) )
    {
        HitRotation = vect(0,0,1);
    }


	//Put the decals
	GoreManager.LeaveABloodSplatterDecal(oZedCurrentlyBeingSprayed, HitLocation, HitRotation);

	//GoreManager. LeaveAPersistentBloodSplat(HitLocation, HitNormal, 1.0);

	if (oZedCurrentlyBeingSprayed != none)
	{
		GoreManager.CausePersistentBlood(oZedCurrentlyBeingSprayed, class'KFDamageType', HitLocation, vect(0,0,-1), 0, false, false);
	}
}

simulated function RemoveAllBloodParticles()
{
	local int Index;
	local KFEmit_DirectionalPath EmitterToRemove;

	for( Index = (NumBloodStolenParticlesForPool - 1) ; Index >= 0 ; Index-- )
	{
		EmitterToRemove = BloodStolenParticles[Index];
		//BloodStolenParticles.Remove(Index, 1);
		EmitterToRemove.DeactivateEmitter();
	}	
}

defaultproperties
{
	ChargeRTPC=0
	bIsChargeEffectsActive=false
	bIsBloodParticlesEffectActive=false
	bIsDisabledSprayVisualAndMesh=false
	MuzzleFlashTemplate=KFMuzzleFlash'WEP_HRG_Vampire_Arch.Wep_HRG_Vampire_MuzzleFlash_3P'

	ChargingEffect=ParticleSystem'WEP_HRG_Vampire_EMIT.FX_HRG_Vampire_BlobCharge_3P_01'
	ChargedEffect=ParticleSystem'WEP_HRG_Vampire_EMIT.FX_HRG_Vampire_FullCharge'

	BloodStolenEffect=ParticleSystem'WEP_HRG_Vampire_EMIT.FX_HRG_Vampire_BloodStolen_3P'

	BloodSplashClass=KFProj_BloodSplash

	RateUpdateDestinationBloodParticles = 0.7

	NumBloodStolenParticlesForPool = 15;
}
