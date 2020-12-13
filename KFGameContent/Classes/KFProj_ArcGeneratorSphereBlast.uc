//=============================================================================
// KFDT_EMP_Blast // FFerrando @ saber3d
//=============================================================================
// Damage caused by the Arc Generator gun alternate fire
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFProj_ArcGeneratorSphereBlast extends KFProjectile;

var int MaxNumberOfZedsZapped;
var int MaxDistanceToBeZapped;
var float ZapInterval;
var int ZapDamage;
var float TimeToZap;

var KFPawn_Monster oZedCurrentlyBeingSprayed;

var ParticleSystem BeamPSCTemplate;
var ParticleSystem oPawnPSCEffect;

var string EmitterPoolClassPath;
var EmitterPool vBeamEffects;

struct BeamZapInfo
{
	var ParticleSystemComponent oBeam;
	var KFPawn_Monster oAttachedZed;
	var Actor oSourceActor;
	var float oControlTime;
};

var array<BeamZapInfo> CurrentZapBeams;

var bool ImpactEffectTriggered;

var AkComponent ZapSFXComponent;
var() AkEvent ZapSFX;

var Controller oOriginalOwnerController;
var Pawn oOriginalInstigator;
var KFWeapon oOriginalOwnerWeapon;

const ALTFIRE_FIREMODE			= 1;

simulated event PreBeginPlay()
{
	local class<EmitterPool> PoolClass;
	
    super.PreBeginPlay();

    bIsAIProjectile = InstigatorController == none || !InstigatorController.bIsPlayer;
	oOriginalOwnerController = InstigatorController;
	oOriginalInstigator = Instigator;
	oOriginalOwnerWeapon = KFWeapon(Weapon(Owner));
	PoolClass = class<EmitterPool>(DynamicLoadObject(EmitterPoolClassPath, class'Class'));
	if (PoolClass != None)
	{
		vBeamEffects = Spawn(PoolClass, self,, vect(0,0,0), rot(0,0,0));
	}

	if(oOriginalOwnerWeapon != None)
	{
		PenetrationPower =  oOriginalOwnerWeapon.GetInitialPenetrationPower(ALTFIRE_FIREMODE);
	}
}

function Init(vector Direction)
{
    if( LifeSpan == default.LifeSpan && WorldInfo.TimeDilation < 1.f )
    {
        LifeSpan /= WorldInfo.TimeDilation;
    }
    super.Init( Direction );
	
}

simulated function bool ZapFunction(Actor _TouchActor)
{
	local vector BeamEndPoint;
	local KFPawn_Monster oMonsterPawn;
	local int iZapped;
	local ParticleSystemComponent BeamPSC;
	foreach WorldInfo.AllPawns( class'KFPawn_Monster', oMonsterPawn )
	{
		if( oMonsterPawn.IsAliveAndWell() && oMonsterPawn != _TouchActor)
		{
			//`Warn("PAWN CHECK IN: "$oMonsterPawn.Location$"");
			//`Warn(VSizeSQ(oMonsterPawn.Location - _TouchActor.Location));
			if( VSizeSQ(oMonsterPawn.Location - _TouchActor.Location) < Square(MaxDistanceToBeZapped) )
			{

				if(FastTrace(_TouchActor.Location, oMonsterPawn.Location, vect(0,0,0)) == false)
				{
					continue;
				}

				if(WorldInfo.NetMode != NM_DedicatedServer)
				{
					BeamPSC = vBeamEffects.SpawnEmitter(BeamPSCTemplate, _TouchActor.Location, _TouchActor.Rotation);

					BeamEndPoint = oMonsterPawn.Mesh.GetBoneLocation('Spine1');
					if(BeamEndPoint == vect(0,0,0)) BeamEndPoint = oMonsterPawn.Location;

					BeamPSC.SetBeamSourcePoint(0, _TouchActor.Location, 0);
					BeamPSC.SetBeamTargetPoint(0, BeamEndPoint, 0);
					
					BeamPSC.SetAbsolute(false, false, false);
					BeamPSC.bUpdateComponentInTick = true;
					BeamPSC.SetActive(true);

					StoreBeam(BeamPSC, oMonsterPawn);
					ZapSFXComponent.PlayEvent(ZapSFX, true);
				}

				if(WorldInfo.NetMode == NM_DedicatedServer || WorldInfo.NetMode == NM_StandAlone ||  WorldInfo.NetMode == NM_ListenServer)
				{
					ChainedZapDamageFunction(oMonsterPawn, _TouchActor);
				}

				++iZapped;
			}
		}

		if(iZapped >= MaxNumberOfZedsZapped) break;
	}
	if(iZapped > 0) 
		return true;
	else
		return false;
}

simulated function StoreBeam(ParticleSystemComponent Beam, KFPawn_Monster Monster)
{
	local BeamZapInfo BeamInfo;
	BeamInfo.oBeam = Beam;
	BeamInfo.oAttachedZed = Monster;
	BeamInfo.oSourceActor = self;
	BeamInfo.oControlTime = ZapInterval;
	CurrentZapBeams.AddItem(BeamInfo);
}

function ChainedZapDamageFunction(Actor _TouchActor, Actor _OriginActor)
{
	//local float DistToHitActor;
	local vector Momentum;
	local TraceHitInfo HitInfo;
	local Pawn TouchPawn;
	local int TotalDamage;
 
	if (_OriginActor != none)
	{
		Momentum = _TouchActor.Location - _OriginActor.Location;
	}

	//DistToHitActor = VSize(Momentum);
	//Momentum *= (MomentumScale / DistToHitActor);
	if (ZapDamage > 0)
	{
		TouchPawn = Pawn(_TouchActor);
		// Let script know that we hit something
		if (TouchPawn != none)
		{
			ProcessDirectImpact();
		}
		//`Warn("["$WorldInfo.TimeSeconds$"] Damaging "$_TouchActor.Name$" for "$ZapDamage$", Dist: "$VSize(_TouchActor.Location - _OriginActor.Location));
		
		TotalDamage = ZapDamage * UpgradeDamageMod;
		_TouchActor.TakeDamage(TotalDamage, oOriginalOwnerController, _TouchActor.Location, Momentum, class'KFDT_EMP_ArcGenerator_AltFiremodeZapDamage', HitInfo, self);
	}
}

/** Notification that a direct impact has occurred. */
event ProcessDirectImpact()
{
    local KFPlayerController KFPC;

    KFPC = KFPlayerController(oOriginalOwnerController);

    if( KFPC != none )
    {
        KFPC.AddShotsHit(1);
    }
}

simulated event HitWall( vector HitNormal, actor Wall, PrimitiveComponent WallComp )
{
	if( !bHasExploded )
	{
		Explode(Location - (HitNormal * CylinderComponent.CollisionRadius), HitNormal);
		//DrawDebugSphere(Location, CylinderComponent.CollisionRadius, 10, 255, 255, 0, true );
		//DrawDebugSphere(Location, 2, 10, 0, 0, 255, true );
		//DrawDebugSphere(Location - (HitNormal * CylinderComponent.CollisionRadius), 2, 10, 255, 0, 0, true );
	}
}

/** Call ProcessBulletTouch */
simulated function ProcessTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	Local KFPawn_Monster Monster;

	//Super.ProcessTouch(Other, HitLocation, HitNormal);
	
    local KFPawn KFP;
    local bool bPassThrough, bNoPenetrationDmgReduction;
	local KFPerk CurrentPerk;
	local InterpCurveFloat PenetrationCurve;
	local KFWeapon KFW;

	ProcessEffect(HitLocation, HitNormal, Other);

	if(role != role_authority)
	{
		return;
	}

	if (Other != oOriginalOwnerWeapon)
	{
		if(IgnoreTouchActor == Other)
		{
			return;
		}

		if (!Other.bStatic && DamageRadius == 0.0)
		{
			// check/ignore repeat touch events
			if( CheckRepeatingTouch(Other) )
			{
				return;
			}

			KFW = oOriginalOwnerWeapon;

			// Keep going if we need to keep penetrating
			if (KFW == none || KFW.GetInitialPenetrationPower(ALTFIRE_FIREMODE) > 0.0f)
			{
				if (PenetrationPower > 0 || PassThroughDamage(Other))
				{
					if (KFW != none)
					{
						CurrentPerk = KFW.GetPerk();
						if (CurrentPerk != none)
						{
							bNoPenetrationDmgReduction = CurrentPerk.IgnoresPenetrationDmgReduction();
						}

						PenetrationCurve = KFW.PenetrationDamageReductionCurve[ALTFIRE_FIREMODE];
						if (!bNoPenetrationDmgReduction)
						{
							Damage *= EvalInterpCurveFloat(PenetrationCurve, PenetrationPower / KFW.GetInitialPenetrationPower(ALTFIRE_FIREMODE));
						}
					}

					ProcessBulletTouch(Other, HitLocation, HitNormal);

					// Reduce penetration power for every KFPawn penetrated
					KFP = KFPawn(Other);
					if (KFP != none)
					{
						PenetrationPower -= KFP.PenetrationResistance;
						bPassThrough = TRUE;
					}
				}
			}
			else
			{
				ProcessBulletTouch(Other, HitLocation, HitNormal);
			}
		}
        // handle water pass through damage/hitfx
        else if ( DamageRadius == 0.f && !Other.bBlockActors && Other.IsA('KFWaterMeshActor') )
        {
            if ( WorldInfo.NetMode != NM_DedicatedServer )
            {
                `ImpactEffectManager.PlayImpactEffects(HitLocation, oOriginalInstigator,, ImpactEffects);
            }
            bPassThrough = TRUE;
        }

        if ( !bPassThrough )
        {
    		Super.ProcessTouch(Other, HitLocation, HitNormal);
        }
	}

	Monster = KFPawn_Monster(Other);
	// Needed to spawn particles cause of the special behaviour of the projectile
	if( Monster != None && Monster.IsAliveAndWell() && ImpactEffects != None )
	{
		WorldInfo.MyEmitterPool.SpawnEmitter(oPawnPSCEffect, HitLocation, rotator(HitNormal), Other);
	}
}

/** Handle bullet collision and damage */
simulated function ProcessBulletTouch(Actor Other, Vector HitLocation, Vector HitNormal)
{
	local Pawn Victim;
	local Pawn CurrentInstigator;
	local array<ImpactInfo> HitZoneImpactList;
	local vector StartTrace, EndTrace, Direction;
	local TraceHitInfo HitInfo;
    local KFWeapon KFW;

	// Do the impact effects
	ProcessEffect(HitLocation, HitNormal, Other);

    Victim = Pawn( Other );
	if ( Victim == none )
	{
		if ( bDamageDestructiblesOnTouch && Other.bCanBeDamaged )
		{
			HitInfo.HitComponent = LastTouchComponent;
			HitInfo.Item = INDEX_None;	// force TraceComponent on fractured meshes
			Other.TakeDamage(Damage, oOriginalOwnerController, Location, MomentumTransfer * Normal(Velocity), MyDamageType, HitInfo, self);
		}

		// Reduce the penetration power to zero if we hit something other than a pawn or foliage actor
		if( InteractiveFoliageActor(Other) == None )
		{
    		PenetrationPower = 0;
    		return;
		}
	}
    else
    {
		if (bSpawnShrapnel)
		{
			//spawn straight forward through the zed
			SpawnShrapnel(Other, HitLocation, HitNormal, rotator(Velocity), ShrapnelSpreadWidthZed, ShrapnelSpreadHeightZed);
		}

		StartTrace = HitLocation;
		Direction = Normal(Velocity);
		EndTrace = StartTrace + Direction * (Victim.CylinderComponent.CollisionRadius * 6.0);

		TraceProjHitZones(Victim, EndTrace, StartTrace, HitZoneImpactList);

		// Right now we just send the first impact. TODO: Figure out what the
		// most "important" or high damage impact is and send that one! Or,
		// if we need the info on the server send the whole thing - Ramm
		if ( HitZoneImpactList.length > 0 )
		{
            HitZoneImpactList[0].RayDir	= Direction;

			if( bReplicateClientHitsAsFragments )
			{
				if( oOriginalInstigator != none )
				{
                    KFW = oOriginalOwnerWeapon;
                    if( KFW != none )
                    {
                        KFW.HandleGrenadeProjectileImpact(HitZoneImpactList[0], class);
                    }
				}
			}
			// Owner is none on a remote client, or the weapon on the server/local player
			else if( oOriginalOwnerWeapon != none )
			{
                KFW = oOriginalOwnerWeapon;
                if( KFW != none )
                {
					CurrentInstigator = KFW.Instigator;
					KFW.Instigator = oOriginalInstigator;
                    KFW.HandleProjectileImpactSpecial(ALTFIRE_FIREMODE, HitZoneImpactList[0], oOriginalInstigator, PenetrationPower);
					KFW.Instigator = CurrentInstigator;
                }
			}
		}
	}
}


simulated event Tick( float DeltaTime )
{
	Local int i;
	local vector BeamEndPoint;

	/*//cylinders debug
	local vector A, B;
	A = Location + (vect(0.0f,0.0f,20.0f) * 1);
	B = Location + (vect(0.0f,0.0f,-20.0f) * 1);
	DrawDebugCylinder( A, B, 40, 10, 255, 255, 0, true); // SLOW! Use for debugging only!
	*/

	if(CurrentZapBeams.length > 0)
	{
		for(i=0 ; i<CurrentZapBeams.length ; i++)
		{
			CurrentZapBeams[i].oControlTime -= DeltaTime;
			if(CurrentZapBeams[i].oControlTime > 0 && CurrentZapBeams[i].oAttachedZed.IsAliveAndWell())
			{
				BeamEndPoint = CurrentZapBeams[i].oAttachedZed.Mesh.GetBoneLocation('Spine1');
				if(BeamEndPoint == vect(0,0,0)) BeamEndPoint = CurrentZapBeams[i].oAttachedZed.Location;

				CurrentZapBeams[i].oBeam.SetBeamSourcePoint(0, CurrentZapBeams[i].oSourceActor.Location, 0);
				CurrentZapBeams[i].oBeam.SetBeamTargetPoint(0, BeamEndPoint, 0);
			}
			else
			{
				CurrentZapBeams[i].oBeam.DeactivateSystem();
				CurrentZapBeams.RemoveItem(CurrentZapBeams[i]);
				i--;
			}
		}
	}

	TimeToZap += DeltaTime;
	//`Warn(TimeToZap);
	//`Warn(TimeToZap > ZapInterval);
	if(TimeToZap > ZapInterval)
	{
		if(ZapFunction(self))
		{
			TimeToZap = 0;
		}
	}
}
simulated protected function DeferredDestroy(float DelaySec)
{
	Super.DeferredDestroy(DelaySec);
	FinalEffectHandling();
}

simulated function Destroyed()
{	
	FinalEffectHandling();
	Super.Destroyed();
}

simulated function FinalEffectHandling()
{
	Local int i;

	if( ImpactEffects != None)
	{
		ImpactEffectTriggered=True;
		WorldInfo.MyEmitterPool.SpawnEmitter(ImpactEffects.DefaultImpactEffect.ParticleTemplate, Location, Rotation);
	}

	if(CurrentZapBeams.length > 0)
	{
		for(i=0 ; i<CurrentZapBeams.length ; i++)
		{
			CurrentZapBeams[i].oBeam.DeactivateSystem();
		}
	}
}

/**
 * Explode this Projectile
 */
simulated function TriggerExplosion(Vector HitLocation, Vector HitNormal, Actor HitActor)
{
	// If there is an explosion template do the parent version
	if ( ExplosionTemplate != None )
	{
		Super.TriggerExplosion(HitLocation, HitNormal, HitActor);
		return;
	}

	// otherwise use the ImpactEffectManager for material based effects
	ProcessEffect(HitLocation, HitNormal, HitActor);
}

simulated function ProcessEffect(Vector HitLocation, Vector HitNormal, Actor HitActor)
{
	local KFPawn OtherPawn;

	if( ImpactEffectTriggered || WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}
	
	// otherwise use the ImpactEffectManager for material based effects
	if ( Instigator != None )
	{
        `ImpactEffectManager.PlayImpactEffects(HitLocation, Instigator,, ImpactEffects);
	}
	else if( oOriginalInstigator != none )
	{
        `ImpactEffectManager.PlayImpactEffects(HitLocation, oOriginalInstigator,, ImpactEffects);
	}
	else
	{
		WorldInfo.MyEmitterPool.SpawnEmitter(ImpactEffects.DefaultImpactEffect.ParticleTemplate, Location, Rotation);
	}

	if(HitActor != none)
	{
		OtherPawn = KFPawn(HitActor);
		ImpactEffectTriggered = OtherPawn != none ? false : true;
	}
}

/** Damage without stopping the projectile (see also Weapon.PassThroughDamage)*/
simulated function bool PassThroughDamage(Actor HitActor)
{
    // Don't stop this projectile for interactive foliage
	if ( !HitActor.bBlockActors && HitActor.IsA('InteractiveFoliageActor') )
	{
		return true;
	}

	return FALSE;
}

defaultproperties
{
	Physics=PHYS_Projectile
    MaxSpeed=1000.0
	Speed=600//1000.0
	TossZ=0
	GravityScale=0.0
    MomentumTransfer=0
	LifeSpan=10
    bCanBeDamaged=false
	bCanDisintegrate=false
	bIgnoreFoliageTouch=true

    bCollideActors=true
    bCollideComplex=true

	bBlockedByInstigator=false
	bAlwaysReplicateExplosion=true

	bNetTemporary=false
	NetPriority=5
	NetUpdateFrequency=200

	bNoReplicationToInstigator=false
	bUseClientSideHitDetection=true
	bUpdateSimulatedPosition=true
	bSyncToOriginalLocation=true
	bSyncToThirdPersonMuzzleLocation=true

	Begin Object Name=CollisionCylinder
		CollisionRadius=40 //6
		CollisionHeight=40 //2
		BlockNonZeroExtent=true
		// for siren scream
		CollideActors=true
	End Object
	ExtraLineCollisionOffsets.Add((Y = -40))
 	ExtraLineCollisionOffsets.Add((Y = 40))
  	// Since we're still using an extent cylinder, we need a line at 0
  	ExtraLineCollisionOffsets.Add(())

	bWarnAIWhenFired=true

	//ProjFlightTemplate=ParticleSystem'WEP_HuskCannon_EMIT.FX_Huskcannon_Projectile_L1'
	ProjFlightTemplate=ParticleSystem'WEP_HRG_ArcGenerator_EMIT.FX_HRG_ArcGenerator_Projectile_ALT'
    ProjDisintegrateTemplate=ParticleSystem'ZED_Siren_EMIT.FX_Siren_grenade_disable_01'
	ImpactEffects = KFImpactEffectInfo'WEP_HRG_ArcGenerator_ARCH.Wep_HRG_ArcGenerator_Alt_Impact'
	oPawnPSCEffect = ParticleSystem'WEP_HRG_ArcGenerator_EMIT.FX_HRG_ArcGenerator_ALT_Impact_Player_01'
    Begin Object Class=AkComponent name=ZapOneShotSFX
    	BoneName=dummy // need bone name so it doesn't interfere with default PlaySoundBase functionality
    	bStopWhenOwnerDestroyed=true
    End Object
    ZapSFXComponent=ZapOneShotSFX
    Components.Add(ZapOneShotSFX)
	
    ZapSFX=AkEvent'WW_WEP_Bleeder.Play_WEP_Bleeder_Tube_Blood'

	AmbientSoundPlayEvent=AkEvent'WW_WEP_HRG_ArcGenerator.Play_HRG_ArcGenerator_AltFire_Loop'
  	AmbientSoundStopEvent=None

	bAutoStartAmbientSound=True
	bAmbientSoundZedTimeOnly=False
	bImportantAmbientSound=True
	bStopAmbientSoundOnExplode=True

    BeamPSCTemplate = ParticleSystem'WEP_HRG_ArcGenerator_EMIT.FX_Beam_Test_2'
	EmitterPoolClassPath="Engine.EmitterPool"

	MaxNumberOfZedsZapped=3
	MaxDistanceToBeZapped=250 //200 //2500
	ZapInterval=0.4 //1
	ZapDamage=25 //20 //12 //10
	TimeToZap=100

	ImpactEffectTriggered=false;

	DamageRadius=0
}
