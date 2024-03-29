//=============================================================================
// KFWeap_HVStormCannon
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//=============================================================================

class KFWeap_HVStormCannon extends KFWeap_ScopedBase;

var const float TrackingInstanceTimeDelaySeconds;
var const float TrackingRadius;
var const int TrackingDamageValue;
var const array<float> TrackingDamage;

var int WeaponID;

struct HVStormCannon_ProjectileTrackingInstance
{
	var int NumberHits;
	var float TimeNextJump;
	var KFPawn_Monster LastTarget;
	var array<KFPawn_Monster> HitTargets;
	var Controller Instigator; // Instigator that shot the bullet
	var byte IDCounter;

	structdefaultproperties
	{
		NumberHits=0
		TimeNextJump=0
		LastTarget=none
		Instigator=none
	}
};

var array<HVStormCannon_ProjectileTrackingInstance> HVStormCannon_ProjectileTracking;

event PostBeginPlay()
{
	local int Counter;
	local KFPlayerController KFPC;

	Super.PostBeginPlay();
	
	Counter = 0;
	foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
	{
		++Counter;
		if (KFPC == Instigator.Controller)
		{
			WeaponID = Counter * 1000;
			break;
		}
	}
}

simulated function KFProjectile SpawnAllProjectiles(class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir)
{
	local Vector X, Y, Z, POVLoc;
	local Quat R;
	local rotator POVRot;

	if (bUsingSights)
	{
		if (Instigator != None && Instigator.Controller != none)
		{
			Instigator.Controller.GetPlayerViewPoint(POVLoc, POVRot);

			GetAxes(POVRot, X, Y, Z);

			// 0.32 is a value the artists found that was needed to balance the aim in order to match the iron sight with the bullet impact position
			R = QuatFromAxisAndAngle(Y, -0.32f * DegToRad);
			AimDir = QuatRotateVector(R, AimDir);
			return SpawnProjectile(KFProjClass, RealStartLoc, AimDir);
		}
	}

	return super.SpawnAllProjectiles(KFProjClass, RealStartLoc, AimDir);
}

simulated function ProcessInstantHitEx(byte FiringMode, ImpactInfo Impact, optional int NumHits, optional out float out_PenetrationVal, optional int ImpactNum )
{
	local int HitZoneIdx;
	local KFPawn_Monster Target;
	local HVStormCannon_ProjectileTrackingInstance NewTrackingInstance;
	local KFPlayerController KFPC;

  	if (Role == ROLE_Authority)
	{
		Target = KFPawn_Monster(Impact.HitActor);
		if (Target != none && !Target.bIsHeadless)
		{
			HitZoneIdx = Target.HitZones.Find('ZoneName', Impact.HitInfo.BoneName);
			if (HitZoneIdx == HZI_Head && Target.IsAliveAndWell())
			{
				NewTrackingInstance.TimeNextJump = WorldInfo.TimeSeconds + TrackingInstanceTimeDelaySeconds;
				NewTrackingInstance.LastTarget = Target;
				NewTrackingInstance.HitTargets.AddItem(Target);
				NewTrackingInstance.Instigator = Instigator.Controller;

				KFPC = KFPlayerController(Instigator.Controller);
				NewTrackingInstance.IDCounter = KFPC.StormCannonIDCounter;

				if (KFPC.StormCannonIDCounter < 255)
				{
					++KFPC.StormCannonIDCounter;
				}
				else
				{
					KFPC.StormCannonIDCounter = 0;
				}

				// DISABLED PER DESIGN REQUEST, WE DO USE NOW DAMAGE TYPE EMP POWER
				// We simulate EMP affliction on Server, we can't use the affliction itself because it's duration is super hard to control
				// To completely sync with the logic of TrackingInstanceTimeDelaySeconds

				// Simulate start EMP affliction
				//Target.bEmpPanicked = true;
        		//Target.OnStackingAfflictionChanged(AF_EMP);

				HVStormCannon_ProjectileTracking.AddItem(NewTrackingInstance);

				StartBeamVFX(Target, NewTrackingInstance.IDCounter);
			}
		}
	}
	super.ProcessInstantHitEx( FiringMode, Impact, NumHits, out_PenetrationVal, ImpactNum );
}

function KFPawn_Monster SearchClosestTarget(HVStormCannon_ProjectileTrackingInstance CurrentTrackingInstance)
{
	local KFPawn_Monster CurrentTarget, BestTarget;
    local TraceHitInfo HitInfo;    

    local float BestDistance;
    local float Distance;

    local vector ReferenceLocation;

	local vector HitLocation, HitNormal;
    local Actor HitActor;
   
	ReferenceLocation = CurrentTrackingInstance.LastTarget.Mesh.GetBoneLocation('head');

	//CurrentTrackingInstance.LastTarget.DrawDebugSphere(ReferenceLocation, CurrentTrackingInstance.LastTarget.GetCollisionRadius() + TrackingRadius, 10, 0, 255, 0, true);

    foreach CollidingActors(class'KFPawn_Monster'
								, CurrentTarget
								, CurrentTrackingInstance.LastTarget.GetCollisionRadius() + TrackingRadius
								, ReferenceLocation
								, true,, HitInfo)
    {
	    if (!CurrentTarget.IsAliveAndWell())
        {
            continue;
        }

		// Check if the target does have map geometry in between..
        HitActor = Trace(HitLocation, HitNormal, CurrentTarget.Mesh.GetBoneLocation('head'), ReferenceLocation,,,,TRACEFLAG_Bullet);

        if (HitActor != none && KFPawn_Monster(HitActor) == none)
        {
            continue;
        }

		// Don't hit again targets..
		if (CurrentTrackingInstance.HitTargets.Find(CurrentTarget) != INDEX_NONE)
		{
			continue;
		}

		// The closest..
		Distance = VSizeSq(ReferenceLocation - CurrentTarget.Mesh.GetBoneLocation('head'));

        if (BestTarget == none)
        {
            BestTarget = CurrentTarget;
            BestDistance = Distance;
        }
        else if (BestDistance > Distance)
        {
            BestTarget = CurrentTarget;
            BestDistance = Distance;
        }
    }

	return BestTarget;
}

function UpdateTracking()
{
	local int i;
	local KFPawn_Monster NextTarget;
	local bool bClear;
	local TraceHitInfo HitInfo;

	HitInfo.BoneName = 'head'; // we force headshot

	for (i = HVStormCannon_ProjectileTracking.Length - 1; i >= 0; i--)
	{	
		bClear = false;

		if (WorldInfo.TimeSeconds >= HVStormCannon_ProjectileTracking[i].TimeNextJump)
		{
			// DISABLED PER DESIGN REQUEST, WE DO USE NOW DAMAGE TYPE EMP POWER
			// Simulate stop EMP affliction
			//HVStormCannon_ProjectileTracking[i].LastTarget.bEmpPanicked = false;
        	//HVStormCannon_ProjectileTracking[i].LastTarget.OnStackingAfflictionChanged(AF_EMP);

			if (HVStormCannon_ProjectileTracking[i].NumberHits < TrackingDamage.length)
			{
				NextTarget = SearchClosestTarget(HVStormCannon_ProjectileTracking[i]);
				if (NextTarget != none)
				{
					HVStormCannon_ProjectileTracking[i].TimeNextJump = WorldInfo.TimeSeconds + TrackingInstanceTimeDelaySeconds;

					// DISABLED PER DESIGN REQUEST, WE DO USE NOW DAMAGE TYPE EMP POWER
					// Simulate start EMP affliction
					//NextTarget.bEmpPanicked = true;
        			//NextTarget.OnStackingAfflictionChanged(AF_EMP);

					StartBeamVFX(NextTarget, HVStormCannon_ProjectileTracking[i].IDCounter);

					HVStormCannon_ProjectileTracking[i].LastTarget = NextTarget;
					HVStormCannon_ProjectileTracking[i].HitTargets.AddItem(NextTarget);				

					NextTarget.TakeDamage(TrackingDamageValue * TrackingDamage[HVStormCannon_ProjectileTracking[i].NumberHits]
											, HVStormCannon_ProjectileTracking[i].Instigator
											, NextTarget.Mesh.GetBoneLocation('head')
											, vect(0,0,0)
											, class'KFDT_HVStormCannonSpread'
											, HitInfo);

					++HVStormCannon_ProjectileTracking[i].NumberHits;
				}
				else
				{
					// If there are no targets we finish early
					bClear = true;
				}
			}
			else
			{
				// Max hits reached
				bClear = true;
			}
		}

		if (bClear)
		{
			StopBeamVFX(HVStormCannon_ProjectileTracking[i].IDCounter);
			HVStormCannon_ProjectileTracking.Remove(i, 1);
		}
	}	
}

simulated event Tick(float DeltaTime)
{
	Super.Tick(DeltaTime);

	if (Role == ROLE_Authority)
  	{
		UpdateTracking();
	}

	if (Role != ROLE_Authority || WorldInfo.NetMode == NM_Standalone) 
	{
		UpdateAmmoCounter();
	}
}

simulated function StartBeamVFX(KFPawn_Monster KFPM, byte ID)
{	
	local KFPlayerController KFPC;

	if (Role == ROLE_Authority)
	{
		// Send RPC to all players
		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
		{
			KFPC.AddStormCannonVFX(KFPM, GetID(ID));
		}
	}
}

simulated function StopBeamVFX(byte ID)
{
	local KFPlayerController KFPC;
	
	if (Role == ROLE_Authority)
	{
		// Send RPC to all players
		foreach WorldInfo.AllControllers(class'KFPlayerController', KFPC)
		{
			KFPC.RemoveStormCannonVFX(GetID(ID));
		}
	}
}

function int GetID(byte ID)
{
	return WeaponID + ID;
}

simulated function UpdateAmmoCounter()
{
	local float PercentageAmmo;

	PercentageAmmo = float((AmmoCount[0] - 1)) / float(MagazineCapacity[0]);

	WeaponMICs[3].SetScalarParameterValue('opacity', PercentageAmmo);
}

/** Returns trader filter index based on weapon type (copied from riflebase) */
static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Rifle;
}

defaultproperties
{
    // FOV
	MeshFOV=70
	MeshIronSightFOV=52
    PlayerIronSightFOV=70

	// Depth of field
	DOF_FG_FocalRadius=0
	DOF_FG_MaxNearBlurSize=2.5

	// Content
	PackageKey="HVStormCannon"
	FirstPersonMeshName="WEP_1P_HVStormCannon_MESH.Wep_1stP_HVStormCannon_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_HVStormCannon_ANIM.Wep_1p_HVStormCannon_Anim"
	PickupMeshName="WEP_3P_HVStormCannon_MESH.Wep_HRG_HVStormCannon_Pickup"
	AttachmentArchetypeName = "WEP_HVStormCannon_ARCH.HVStormCannon_3P"
	MuzzleFlashTemplateName="WEP_HVStormCannon_ARCH.Wep_HVStormCannon_MuzzleFlash"

	// Ammo
	MagazineCapacity[0]=8
	SpareAmmoCapacity[0]=96
	InitialSpareMags[0]=2
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Zooming/Position
	PlayerViewOffset=(X=12.0,Y=13,Z=-2) //x7
	IronSightPosition=(X=-5,Y=-0.01,Z=0.30) //X=-5,Y=-0.019,Z=0.22

	// AI warning system
	bWarnAIWhenAiming=true
	AimWarningDelay=(X=0.4f, Y=0.8f)
	AimWarningCooldown=0.0f

// Recoil
	maxRecoilPitch=200 //185
	minRecoilPitch=165 //150
	maxRecoilYaw=190 //175
	minRecoilYaw=-165 //-150
	RecoilRate=0.09
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=65035
	RecoilISMaxYawLimit=150
	RecoilISMinYawLimit=65385
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	RecoilViewRotationScale=0.6
	HippedRecoilModifier=1.5 //1.25
	IronSightMeshFOVCompensationScale=1.5

	// Inventory
	InventorySize=8
	GroupPriority=125
	WeaponSelectTexture=Texture2D'wep_ui_hvstormcannon_tex.UI_WeaponSelect_HVStormCannon'

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_HVStormCannon'
	InstantHitDamage(DEFAULT_FIREMODE)=150
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_EMP_HVStormCannon'
	
    // ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_None

    FireInterval(DEFAULT_FIREMODE)=0.4 // 150 RPM // 0.8 // 75 RPM
	Spread(DEFAULT_FIREMODE)=0.005
	PenetrationPower(DEFAULT_FIREMODE)=0
	//FireOffset=(X=30,Y=16,Z=-8)

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HVStormCannon'
	InstantHitDamage(BASH_FIREMODE)=27

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HVStormCannon.Play_WEP_HVStormCannon_Shoot_3P', FirstPersonCue=AkEvent'WW_WEP_HVStormCannon.Play_WEP_HVStormCannon_Shoot_1P')
	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_Winchester.Play_WEP_SA_Winchester_Handling_DryFire'

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	AssociatedPerkClasses(0)=class'KFPerk_Sharpshooter'

	TrackingInstanceTimeDelaySeconds=0.15
	TrackingRadius=200.0 // in cm, this is added to the Radius of the Zed that's spreading
	TrackingDamageValue=150
	
	TrackingDamage = (0.75f, 0.5f, 0.25f)
	
	WeaponID=0

	// Scope Render
  	// 2D scene capture
	Begin Object Name=SceneCapture2DComponent0
	   //TextureTarget=TextureRenderTarget2D'Wep_Mat_Lib.WEP_ScopeLense_Target'
	   FieldOfView=12.5 //23.0 // "1.5X" = 35.0(our real world FOV determinant)/1.5
	End Object

    ScopedSensitivityMod=8.0 //16.0
	ScopeLenseMICTemplate=MaterialInstanceConstant'WEP_1P_HVStormCannon_MAT.Wep_1stP_HVStormCannon_Lens_MIC'
	ScopeMICIndex = 2

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Damage1, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))

	NumBloodMapMaterials=4
}