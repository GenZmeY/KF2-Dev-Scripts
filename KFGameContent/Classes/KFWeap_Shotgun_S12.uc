//=============================================================================
// KFWeap_Shotgun_S12
//=============================================================================
// AA12 Auto Shotgun Weapon Class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//=============================================================================

class KFWeap_Shotgun_S12 extends KFWeap_ShotgunBase;

var (Positioning) vector SecondaryFireOffset;

const SecondaryFireAnim = 'Shoot_Secondary';
const SecondaryFireIronAnim = 'Shoot_Secondary_Iron';

const SecondaryReloadAnim = 'Reload_Secondary';
const SecondaryReloadEliteAnim = 'Reload_Secondary_Elite'; 

var() KFMuzzleFlash SecondaryMuzzleFlashTemplate;

// Used on the server to keep track of grenades
var int ServerTotalAltAmmo;

var transient bool bCanceledAltAutoReload;

var GameExplosion ExplosionTemplate;
var transient ParticleSystemComponent ExplosionPSC;
var ParticleSystem ExplosionEffect;

var float ExplosionOriginalDamage;

simulated event PostBeginPlay()
{
	super.PostBeginPlay();

	ExplosionOriginalDamage = ExplosionTemplate.Damage;
}

/** Instead of switch fire mode use as immediate alt fire */
simulated function AltFireMode()
{
	if ( !Instigator.IsLocallyControlled() )
	{
		return;
	}

	if (bCanceledAltAutoReload)
	{
		bCanceledAltAutoReload = false;
		TryToAltReload();
		return;
	}

	StartFire(ALTFIRE_FIREMODE);
}

simulated function BeginFire( Byte FireModeNum )
{
	local bool bStoredAutoReload;

	// We are trying to reload the weapon but the primary ammo in already at full capacity
	if ( FireModeNum == RELOAD_FIREMODE && !CanReload() )
	{
		// Store the cuurent state of bCanceledAltAutoReload in case its not possible to do the reload
		bStoredAutoReload = bCanceledAltAutoReload;
		bCanceledAltAutoReload = false;

		if(CanAltAutoReload())
		{
			TryToAltReload();
			return;
		}

		bCanceledAltAutoReload = bStoredAutoReload;
	}

	super.BeginFire( FireModeNum );
}

/**
 * Initializes ammo counts, when weapon is spawned.
 */
function InitializeAmmo()
{
	Super.InitializeAmmo();

	// Add Secondary ammo to our secondary spare ammo count both of these are important, in order to allow dropping the weapon to function properly.
	SpareAmmoCount[1]	= Min(SpareAmmoCount[1] + InitialSpareMags[1] * default.MagazineCapacity[1], GetMaxAmmoAmount(1) - AmmoCount[1]);
	ServerTotalAltAmmo += SpareAmmoCount[1];

	// Make sure the server doesn't get extra shots on listen servers.
	if(Role == ROLE_Authority && !Instigator.IsLocallyControlled())
	{
		ServerTotalAltAmmo += AmmoCount[1];
	}
}

/**
 * @see Weapon::ConsumeAmmo
 */
simulated function ConsumeAmmo( byte FireModeNum )
{
	local byte AmmoType;
	local bool bNoInfiniteAmmo;
	local int OldAmmoCount;

	if(UsesSecondaryAmmo() && FireModeNum == ALTFIRE_FIREMODE && Role == ROLE_Authority && !Instigator.IsLocallyControlled())
	{
		AmmoType = GetAmmoType(FireModeNum);

		OldAmmoCount = AmmoCount[AmmoType];
		Super.ConsumeAmmo(FireModeNum);

		bNoInfiniteAmmo = (OldAmmoCount - AmmoCount[AmmoType]) > 0 || AmmoCount[AmmoType] == 0;
		if ( bNoInfiniteAmmo )
		{
			ServerTotalAltAmmo--;
		}
	}
	else
	{
		Super.ConsumeAmmo(FireModeNum);
	}
}

simulated function bool HasAnyAmmo()
{
	return HasSpareAmmo() || HasAmmo(DEFAULT_FIREMODE) || SpareAmmoCount[1] > 0 || HasAmmo(ALTFIRE_FIREMODE);
}

/** Make sure user can't fire infinitely if they cheat to get infinite ammo locally. */
simulated event bool HasAmmo( byte FireModeNum, optional int Amount=1 )
{
	local byte AmmoType;

	AmmoType = GetAmmoType(FireModeNum);

	if(AmmoType == 1 && Role == ROLE_Authority && Instigator != none && UsesSecondaryAmmo() && !Instigator.IsLocallyControlled())
	{
		if(ServerTotalAltAmmo <= 0)
		{
			return false;
		}
	}

	return Super.HasAmmo(FireModeNum, Amount );
}

/**
 *	Overridden so any grenades added will go to the spare ammo and no the clip.
 */
function int AddSecondaryAmmo(int Amount)
{
	local int OldAmmo;

	// If we can't accept spare ammo, then abort
	if( !CanRefillSecondaryAmmo() )
	{
		return 0;
	}

	if(Role == ROLE_Authority && !Instigator.IsLocallyControlled())
	{
		OldAmmo = ServerTotalAltAmmo;

		ServerTotalAltAmmo = Min(ServerTotalAltAmmo + Amount, GetMaxAmmoAmount(1));
		ClientGiveSecondaryAmmo(Amount);
		return ServerTotalAltAmmo - OldAmmo;
	}
	else
	{
		OldAmmo = SpareAmmoCount[1];
		ClientGiveSecondaryAmmo(Amount);
		return SpareAmmoCount[1] - OldAmmo;
	}
}

/** Give client specified amount of ammo (used player picks up ammo on the server) */
reliable client function ClientGiveSecondaryAmmo(byte Amount)
{
	SpareAmmoCount[1] = Min(SpareAmmoCount[1] + Amount, GetMaxAmmoAmount(1) - AmmoCount[1]);
	TryToAltReload();
}

function SetOriginalValuesFromPickup( KFWeapon PickedUpWeapon )
{
	local KFWeap_Shotgun_S12 Weap;

	Super.SetOriginalValuesFromPickup(PickedUpWeapon);

	if(Role == ROLE_Authority && !Instigator.IsLocallyControlled())
	{
		Weap = KFWeap_Shotgun_S12(PickedUpWeapon);
		ServerTotalAltAmmo = Weap.ServerTotalAltAmmo;
		SpareAmmoCount[1] = ServerTotalAltAmmo - AmmoCount[1];
	}
	else
	{
		// If we're locally controlled, don't bother using ServerTotalAltAmmo.
		SpareAmmoCount[1] = PickedUpWeapon.SpareAmmoCount[1];
	}
}
	
/*********************************************************************************************
 * State GrenadeFiring
 * Handles firing grenade launcher.
 *********************************************************************************************/

simulated state FiringSecondaryState extends WeaponSingleFiring
{
	// Overriden to not call FireAmmunition right at the start of the state
	simulated event BeginState( Name PreviousStateName )
	{
		Super.BeginState(PreviousStateName);
		NotifyBeginState();
	}

	simulated function EndState(Name NextStateName)
	{
		Super.EndState(NextStateName);
		NotifyEndState();
	}

    /**
     * This function returns the world location for spawning the visual effects
     * Overridden to use a special offset for throwing grenades
     */
	simulated event vector GetMuzzleLoc()
	{
		local vector MuzzleLocation;

		// swap fireoffset temporarily
		FireOffset = SecondaryFireOffset;
		MuzzleLocation = Global.GetMuzzleLoc();
		FireOffset = default.FireOffset;

		return MuzzleLocation;
	}

	/** Get whether we should play the reload anim as well or not */
	simulated function name GetWeaponFireAnim(byte FireModeNum)
	{
		return bUsingSights ? SecondaryFireIronAnim : SecondaryFireAnim;
	}
}

/**
 * Don't allow secondary fire to make a primary fire shell particle come out of the gun.
 */
simulated function CauseMuzzleFlash(byte FireModeNum)
{
	local bool AutoShellEject;

	if(FireModeNum == ALTFIRE_FIREMODE)
	{
		if (MuzzleFlash == None)
		{
			AttachSecondaryMuzzleFlash();
		}

		AutoShellEject = MuzzleFlash.bAutoActivateShellEject;

		MuzzleFlash.bAutoActivateShellEject = false;

		Super.CauseMuzzleFlash(FireModeNum);

		MuzzleFlash.bAutoActivateShellEject = AutoShellEject;
	}
	else
	{
		Super.CauseMuzzleFlash(FireModeNum);
	}
}

simulated function AttachSecondaryMuzzleFlash()
{
	if ( MySkelMesh != none )
	{
		if (MuzzleFlashTemplate != None)
		{
			MuzzleFlash = new(self) Class'KFMuzzleFlash'(SecondaryMuzzleFlashTemplate);
			MuzzleFlash.AttachMuzzleFlash(MySkelMesh, 'MuzzleFlashAlt');
		}
	}
}

/*********************************************************************************************
 * State Reloading
 * This is the default Reloading State.  It's performed on both the client and the server.
 *********************************************************************************************/

/** Do not allow alternate fire to tell the weapon to reload. Alt reload occurs in a separate codepath */
simulated function bool ShouldAutoReload(byte FireModeNum)
{
	if(FireModeNum == ALTFIRE_FIREMODE)
	{
		return false;
	}

	return Super.ShouldAutoReload(FireModeNum);
}

/** Called on local player when reload starts and replicated to server */
simulated function SendToAltReload()
{
	ReloadAmountLeft	= MagazineCapacity[1];
	GotoState('AltReloading');
	if ( Role < ROLE_Authority )
	{
		ServerSendToAltReload();
	}
}

/** Called from client when reload starts */
reliable server function ServerSendToAltReload()
{
	ReloadAmountLeft	= MagazineCapacity[1];
	GotoState('AltReloading');
}

/**
 * State Reloading
 * State the weapon is in when it is being reloaded (current magazine replaced with a new one, related animations and effects played).
 */
simulated state AltReloading extends Reloading
{
	ignores ForceReload, ShouldAutoReload, AllowSprinting;

	simulated function byte GetWeaponStateId()
	{
		local KFPerk Perk;
		local bool bTacticalReload;

		Perk = GetPerk();
		bTacticalReload = (Perk != None && Perk.GetUsingTactialReload(self));

		return (bTacticalReload ? WEP_ReloadSecondary_Elite : WEP_ReloadSecondary);
	}

	simulated event BeginState(Name PreviousStateName)
	{
		super.BeginState(PreviousStateName);
		bCanceledAltAutoReload = true;
	}

	// Overridding super so we don't call functions we don't want to call.
	simulated function EndState(Name NextStateName)
	{
		ClearZedTimeResist();
		ClearTimer(nameof(ReloadStatusTimer));
		ClearTimer(nameof(ReloadAmmoTimer));

		CheckBoltLockPostReload();
		NotifyEndState();

		`DialogManager.PlayAmmoDialog( KFPawn(Instigator), float(SpareAmmoCount[1]) / float(GetMaxAmmoAmount(1)) );
	}

	// Overridding super so when this reload is called directly after normal reload state there
	// are not complications resulting from back to back reloads.
	simulated event ReplicatedEvent(name VarName)
	{
		Global.ReplicatedEvent(Varname);
	}

	/** Make sure we can inturrupt secondary reload with anything. */
	simulated function bool CanOverrideMagReload(byte FireModeNum)
	{
		return true;
	}

	/** Returns animation to play based on reload type and status */
	simulated function name GetReloadAnimName( bool bTacticalReload )
	{
		return (bTacticalReload) ? SecondaryReloadEliteAnim : SecondaryReloadAnim;
	}

	simulated function PerformReload(optional byte FireModeNum)
	{
		Global.PerformReload(ALTFIRE_FIREMODE);

		if(Instigator.IsLocallyControlled() && Role < ROLE_Authority)
		{
			ServerSetAltAmmoCount(AmmoCount[1]);
		}

		bCanceledAltAutoReload = false;
	}

	simulated function EReloadStatus GetNextReloadStatus(optional byte FireModeNum)
	{
		return Global.GetNextReloadStatus(ALTFIRE_FIREMODE);
	}
}

reliable server function ServerSetAltAmmoCount(byte Amount)
{
	AmmoCount[1] = min(Amount, MagazineCapacity[1]);
}

/** Allow reloads for primary weapon to be interupted by firing secondary weapon. */
simulated function bool CanOverrideMagReload(byte FireModeNum)
{
	if(FireModeNum == ALTFIRE_FIREMODE)
	{
		return true;
	}

	return Super.CanOverrideMagReload(FireModeNum);
}

/*********************************************************************************************
 * State Active
 * Try to get weapon to automatically reload secondary fire types when it can.
 *********************************************************************************************/

simulated state Active
{
	/** Initialize the weapon as being active and ready to go. */
	simulated event BeginState(Name PreviousStateName)
	{
		// do this last so the above code happens before any state changes
		Super.BeginState(PreviousStateName);

		// If nothing happened, try to reload
		TryToAltReload();
	}
}

/** Network: Local Player */
simulated function bool CanAltAutoReload()
{
	if ( !Instigator.IsLocallyControlled() )
	{
		return false;
	}

	if(!UsesSecondaryAmmo())
	{
		return false;
	}
	
	// If the weapon wants to fire its primary weapon, and it can fire, do not allow weapon to automatically alt reload
	if(PendingFire(DEFAULT_FIREMODE) && HasAmmo(DEFAULT_FIREMODE))
	{
		return false;
	}
	
	if(!CanReload(ALTFIRE_FIREMODE))
	{
		return false;
	}
	
	if (bCanceledAltAutoReload)
	{
		return false;
	}

	return true;
}

simulated function TryToAltReload()
{
	if ((IsInState('Active') || IsInState('WeaponSprinting')) && CanAltAutoReload())
	{
		SendToAltReload();
	}
}

simulated function TriggerAltExplosion()
{
	local vector MuzzleLocation, HitLocation, HitNormal;
	local KFExplosionActorReplicated ExploActor;

	// TriggerExplosion
	if (Role == ROLE_Authority)
	{
		MuzzleLocation = GetMuzzleLoc();
		Trace( HitLocation, HitNormal, MuzzleLocation + vect(0, 0, -1) * 250000, MuzzleLocation);
		// Move a bit from hit location
		HitLocation = HitLocation + (vect(0,0,1) * 128.f);

		// Explode using the given template
		ExploActor = Spawn(class'KFExplosionActorReplicated', self,, HitLocation, rotator(vect(0,0,1)),, true);
		if (ExploActor != None)
		{
			ExploActor.InstigatorController = Instigator.Controller;
			ExploActor.Instigator = Instigator;
			ExploActor.bIgnoreInstigator = true;
			ExplosionTemplate.Damage = ExplosionOriginalDamage * GetUpgradeDamageMod(ALTFIRE_FIREMODE);

			ExploActor.Explode(ExplosionTemplate);
		}
	}

	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		// Trigger VFX ?

		if (HitLocation == vect(0,0,0))
		{
			MySkelMesh.GetSocketWorldLocationAndRotation('MuzzleFlashAlt', MuzzleLocation);
			Trace( HitLocation, HitNormal, MuzzleLocation + vect(0, 0, -1) * 250000, MuzzleLocation);
			// Move a bit from hit location
			HitLocation = HitLocation + (vect(0,0,1) * 128.f);
		}

		if (ExplosionEffect != None)
		{
			ExplosionPSC = WorldInfo.MyEmitterPool.SpawnEmitter(ExplosionEffect, HitLocation, rotator(vect(0,0,1)));
			ExplosionPSC.ActivateSystem();
		}
	}
}

simulated function CustomFire()
{	
	// Alt-fire blast only (server authoritative)
	if ( CurrentFireMode != ALTFIRE_FIREMODE )
	{
		Super.CustomFire();
		return;
	}

	TriggerAltExplosion();
	IncrementFlashCount();
}

simulated event Tick(float DeltaTime)
{
	local vector SocketLocation;
	Super.Tick(DeltaTime);

    // Client only
	if (WorldInfo.NetMode != NM_DedicatedServer)
	{
		KFSkeletalMeshComponent(Mesh).GetSocketWorldLocationAndRotation('MuzzleFlashAlt', SocketLocation);

		if (ExplosionPSC != None && ExplosionPSC.bIsActive)
		{
			ExplosionPSC.SetVectorParameter('WeaponEndpoint', SocketLocation);
		}
	}

}

defaultproperties
{
	bCanRefillSecondaryAmmo = true;

	// Shooting Animations
	FireSightedAnims[0]=Shoot_Iron
	FireSightedAnims[1]=Shoot_Iron2
	FireSightedAnims[2]=Shoot_Iron3

	// FOV
 	MeshFOV=86
	MeshIronSightFOV=35
    PlayerIronSightFOV=70

	// Depth of field
	DOF_FG_FocalRadius=85
	DOF_FG_MaxNearBlurSize=3.5

	// Content
	PackageKey="Saiga12"
	FirstPersonMeshName="Wep_1P_Saiga12_MESH.Wep_1stP_Saiga12_Rig"
	FirstPersonAnimSetNames(0)="Wep_1P_Saiga12_ANIM.Wep_1stP_Saiga12_Anim_New"
	PickupMeshName="WEP_3P_Saiga12_MESH.Wep_Saiga12_Pickup"
	AttachmentArchetypeName="WEP_Saiga12_ARCH.Wep_Saiga12_3P"
	MuzzleFlashTemplateName="WEP_Saiga12_ARCH.Wep_Saiga12_MuzzleFlash"
	SecondaryMuzzleFlashTemplate=KFMuzzleFlash'WEP_Saiga12_ARCH.Wep_Saiga12_MuzzleFlashAlt'

	// Zooming/Position
	PlayerViewOffset=(X=0,Y=12.5,Z=-18)//
	IronSightPosition=(X=12,Y=0,Z=-10.6)

	// Pickup
	AmmoPickupScale[0]=2.0
    AmmoPickupScale[1]=1.0

	// Ammo
	MagazineCapacity[0]=10
	SpareAmmoCapacity[0]=130
	InitialSpareMags[0]=4

    //grenades
	MagazineCapacity[1]=1
	SpareAmmoCapacity[1]=5
	InitialSpareMags[1]=2

	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Recoil
	maxRecoilPitch=250
	minRecoilPitch=225
	maxRecoilYaw=125
	minRecoilYaw=-125
	RecoilRate=0.075
	RecoilBlendOutRatio=0.25
	RecoilMaxYawLimit=500
	RecoilMinYawLimit=65035
	RecoilMaxPitchLimit=900
	RecoilMinPitchLimit=64785
	RecoilISMaxYawLimit=75
	RecoilISMinYawLimit=65460
	RecoilISMaxPitchLimit=375
	RecoilISMinPitchLimit=65460
	RecoilViewRotationScale=0.7
	FallingRecoilModifier=1.5
	HippedRecoilModifier=1.25

    SecondaryAmmoTexture=Texture2D'ui_firemodes_tex.UI_FireModeSelect_Electricity'
	bUseGrenadeAsSecondaryAmmo=true

    // Inventory / Grouping
	InventorySize=8
	GroupPriority=100
	WeaponSelectTexture=Texture2D'WEP_UI_Saiga12_TEX.UI_WeaponSelect_Saiga12'

	AssociatedPerkClasses(0)=class'KFPerk_Support'

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_ShotgunSingle'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_Pellet'
	InstantHitDamage(DEFAULT_FIREMODE)=24.0 //25 //20
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_Shotgun_S12'
	PenetrationPower(DEFAULT_FIREMODE)=2.0
	FireInterval(DEFAULT_FIREMODE)=0.2 // 300 RPM
	Spread(DEFAULT_FIREMODE)=0.08
	FireOffset=(X=30,Y=5,Z=-4)
	NumPellets(DEFAULT_FIREMODE)=7

	// ALT_FIREMODE
	FiringStatesArray(ALTFIRE_FIREMODE)=FiringSecondaryState
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Custom
	AmmoCost(ALTFIRE_FIREMODE)=1
	FireInterval(ALTFIRE_FIREMODE)=+0.25 // 300 RPM
	SecondaryFireOffset=(X=20.f,Y=4.5,Z=-7.f)

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_Shotgun_S12'
	InstantHitDamage(BASH_FIREMODE)=30

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Saiga12.Play_WEP_Saiga12_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_Saiga12.Play_WEP_Saiga12_Fire_1P')
    WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_Saiga12.Play_WEP_Saiga12_Alt_Fire_3P', FirstPersonCue=AkEvent'WW_WEP_Saiga12.Play_WEP_Saiga12_Alt_Fire_1P')

	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_Saiga12.Play_WEP_Saiga12_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_Saiga12.Play_WEP_Saiga12_Handling_DryFire'

	WeaponFireWaveForm=ForceFeedbackWaveform'FX_ForceFeedback_ARCH.Gunfire.Heavy_Recoil'

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false

	// Weapon Upgrade stat boosts
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.15f), (Stat=EWUS_Damage1, Scale=1.15f), (Stat=EWUS_Weight, Add=1)))

	// Grenade explosion light
	Begin Object Class=PointLightComponent Name=ExplosionPointLight
	    LightColor=(R=252,G=218,B=171,A=255)
		Brightness=0.5f
		Radius=400.f
		FalloffExponent=10.f
		CastShadows=False
		CastStaticShadows=FALSE
		CastDynamicShadows=False
		bCastPerObjectShadows=false
		bEnabled=FALSE
		LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
	End Object

	// explosion
	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=200
        DamageRadius=800
		DamageFalloffExponent=0.f
		DamageDelay=0.f
		MomentumTransferScale=10000
		bAlwaysFullDamage=true
		bDoCylinderCheck=true

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_Shotgun_S12'
		KnockDownStrength=150
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		
		ExplosionSound=AkEvent'WW_WEP_Saiga12.Play_WEP_Saiga12_Alt_Fire_3P'
		ExplosionEffects=KFImpactEffectInfo'WEP_Saiga12_ARCH.WEP_Saiga12_Impacts'

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.3

		bIgnoreInstigator=true
		ActorClassToIgnoreForDamage = class'KFPawn_Human'

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=0
		CamShakeOuterRadius=300
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ExplosionTemplate=ExploTemplate0

	ExplosionEffect=ParticleSystem'WEP_1P_Saiga12_EMIT.FX_Saiga12_Explosion'

}
