//=============================================================================
// KFWeap_HRG_BlastBrawlers
//=============================================================================
// Power gloves and shotgun, all in one.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
//=============================================================================
class KFWeap_HRG_BlastBrawlers extends KFWeap_Blunt_PowerGloves;

var name ReloadAnimation;
var float ReloadAnimRateModifier;
var float ReloadAnimRateModifierElite;

var protected transient bool bWaitingForSecondShot; 
var protected transient int  NumAttacks;

/** A muzzle flash instance for left weapon */
var KFMuzzleFlash LeftMuzzleFlash;

simulated event PreBeginPlay()
{
	super.PreBeginPlay();
}

simulated function Shoot()
{
	// LocalPlayer Only
	if ( !Instigator.IsLocallyControlled()  )
	{
		return;
	}
	
	if( Role < Role_Authority )
	{
		// if we're a client, synchronize server
		ServerShoot();
	}

	ProcessShoot();
}

/** 
    Each attack shoots twice, once with the right and left fists.
    Ammo is decremented after the second shot.
*/
reliable server function bool ServerShoot()
{
	return ProcessShoot();
}

simulated function bool ProcessShoot()
{
	// Shooting only happens when default firing
	if(CurrentFireMode != DEFAULT_FIREMODE)
		return false;

	CustomFire();

	if (!bWaitingForSecondShot)
	{
		// AmmoCount[DEFAULT_FIREMODE] = Max(AmmoCount[DEFAULT_FIREMODE] - 1, 0);
		DecrementAmmo();
	}

	bWaitingForSecondShot = !bWaitingForSecondShot;
	return true;
}

simulated function DecrementAmmo()
{
	AmmoCount[DEFAULT_FIREMODE] = Max(AmmoCount[DEFAULT_FIREMODE] - 1, 0);
}

simulated state Active
{
	/**
	 * Called from Weapon:Active.BeginState when HasAnyAmmo (which is overridden above) returns false.
	 */
	simulated function WeaponEmpty()
	{
		local int i;

		// Copied from Weapon:Active.BeginState where HasAnyAmmo returns true.
		// Basically, pretend the weapon isn't empty in this case.
		for (i=0; i<GetPendingFireLength(); i++)
		{
			if (PendingFire(i))
			{
				BeginFire(i);
				break;
			}
		}
	}
}

static simulated event bool UsesAmmo()
{
	return true;
}

simulated function CustomFire()
{
	local byte CachedFireMode;

	CachedFireMode = CurrentFireMode;
	CurrentFireMode = CUSTOM_FIREMODE;

	ProjectileFire();

	// Let the accuracy tracking system know that we fired
	HandleWeaponShotTaken(CurrentFireMode);

	NotifyWeaponFired(CurrentFireMode);

	// Play fire effects now (don't wait for WeaponFired to replicate)
	PlayFireEffects(CurrentFireMode, vect(0, 0, 0));

	CurrentFireMode = CachedFireMode;
}

/** Overriden for the Tight Choke perk */
simulated function KFProjectile SpawnAllProjectiles(class<KFProjectile> KFProjClass, vector RealStartLoc, vector AimDir)
{
	local KFPerk InstigatorPerk;

	if (CurrentFireMode == CUSTOM_FIREMODE)
	{
		InstigatorPerk = GetPerk();
		if (InstigatorPerk != none)
		{
			Spread[CurrentFireMode] = default.Spread[CurrentFireMode] * InstigatorPerk.GetTightChokeModifier();
		}
	}

	return super.SpawnAllProjectiles(KFProjClass, RealStartLoc, AimDir);
}

/** Override for not playing animations (even if noanimation is set it interrupts the melee ones.) */
simulated function PlayFireEffects( byte FireModeNum, optional vector HitLocation )
{
	// If we have stopped the looping fire sound to play single fire sounds for zed time
	// start the looping sound back up again when the time is back above zed time speed
	if( FireModeNum < bLoopingFireSnd.Length && bLoopingFireSnd[FireModeNum] && !bPlayingLoopingFireSnd )
    {
        StartLoopingFireSound(FireModeNum);
    }

	PlayFiringSound(CurrentFireMode);

	if( Instigator != none )
	{
		if( Instigator.IsLocallyControlled() )
		{
			if( Instigator.IsFirstPerson() )
			{
				// Start muzzle flash effect
				CauseMuzzleFlash(FireModeNum);
			}

			ShakeView();
		}
	}
}

/**
 * @see Weapon::StartFire
 */
simulated function StartFire(byte FireModeNum)
{
	// can't start fire because it's in an uninterruptible state
	if (StartFireDisabled)
	{
		return;
	}

	if (FireModeNum == DEFAULT_FIREMODE)
	{
		if(AmmoCount[DEFAULT_FIREMODE] > 0)
		{
			StartMeleeFire(FireModeNum, DIR_FORWARD, ATK_Normal);
		} 
		else
		{
			super.StartFire(RELOAD_FIREMODE);
			// If not cleared, it will loop the animation.
			ClearPendingFire(RELOAD_FIREMODE);
		}
		return;
	}

	super.StartFire(FireModeNum);
}

/** Avoiding reload anim to interrupt combo */
simulated state MeleeChainAttacking
{
	simulated function BeginState(Name PrevStateName)
	{
		local KFPerk InstigatorPerk;

		if( CurrentFireMode == DEFAULT_FIREMODE )
		{
			StartFireDisabled = true;
			bWaitingForSecondShot = false;
			NumAttacks = 0;
		}
		
		InstigatorPerk = GetPerk();
		if (InstigatorPerk != none)
		{
			SetZedTimeResist( InstigatorPerk.GetZedTimeModifier(self) );
		}

		super.BeginState( PrevStateName );
	}

	simulated function EndState(Name NextStateName)
	{
		super.EndState(NextStateName);
		if( CurrentFireMode == DEFAULT_FIREMODE )
		{
			StartFireDisabled = false;
		}

		ClearZedTimeResist();
	}

	simulated function bool ShouldContinueMelee(optional int ChainCount)
	{
		if ( CurrentFireMode == DEFAULT_FIREMODE )
		{
			return false;
		}	
		return super.ShouldContinueMelee(ChainCount);
	}
}

/**
 * Called on a client, this function Attaches the WeaponAttachment
 * to the Mesh.
 *
 * Overridden to attach LeftMuzzleFlash
 */
simulated function AttachMuzzleFlash()
{
	super.AttachMuzzleFlash();

	if ( MySkelMesh != none )
	{
		if (MuzzleFlashTemplate != None)
		{
			LeftMuzzleFlash = new(self) Class'KFMuzzleFlash'(MuzzleFlashTemplate);
			LeftMuzzleFlash.AttachMuzzleFlash(MySkelMesh, 'MuzzleFlash_L');
		}
	}
}

/**
 * Causes the muzzle flash to turn on and setup a time to
 * turn it back off again.
 *
 * Overridden to cause left weapon flash
 */
simulated function CauseMuzzleFlash(byte FireModeNum)
{
	if( MuzzleFlash == None || LeftMuzzleFlash == None )
	{
		AttachMuzzleFlash();
	}

	if( bWaitingForSecondShot )
	{
		if (MuzzleFlash != None )
		{
			// Not ejecting shells for this weapon.
			MuzzleFlash.CauseMuzzleFlash(FireModeNum);
		}
	}
	else
	{
		if( LeftMuzzleFlash != None )
		{
			// Not ejecting shells for this weapon.
			LeftMuzzleFlash.CauseMuzzleFlash(FireModeNum);
		}
	}
}

/**
 * Remove/Detach the muzzle flash components
 */
simulated function DetachMuzzleFlash()
{
	super.DetachMuzzleFlash();

	if (MySkelMesh != none && LeftMuzzleFlash != None)
	{
		LeftMuzzleFlash.DetachMuzzleFlash(MySkelMesh);
		LeftMuzzleFlash = None;
	}
}

/**
 * Adjust the FOV for the first person weapon and arms.
 */
simulated event SetFOV( float NewFOV )
{
	super.SetFOV( NewFOV );

	if( LeftMuzzleFlash != none )
	{
		LeftMuzzleFlash.SetFOV( NewFOV );
	}
}

simulated function StopFireEffects(byte FireModeNum)
{
	super.StopFireEffects( FireModeNum );

	if (LeftMuzzleFlash != None)
	{
        LeftMuzzleFlash.StopMuzzleFlash();
	}
}

/** Returns true if weapon can potentially be reloaded */
simulated function bool CanReload(optional byte FireModeNum)
{
	if ( FiringStatesArray[RELOAD_FIREMODE] == 'WeaponUpkeep' )
	{
		return true;
	}

	if ( FireModeNum == CUSTOM_FIREMODE)
	{
		FireModeNum = DEFAULT_FIREMODE;
	}

	return Super.CanReload(FireModeNum);
}

simulated function name GetReloadAnimName( bool bTacticalReload )
{
	return ReloadAnimation;
}

/** No diferent states */
simulated function EReloadStatus GetNextReloadStatus(optional byte FireModeNum)
{
	switch ( ReloadStatus )
	{
		case RS_None: //drop
		case RS_Reloading:
			if ( HasSpareAmmo(FiremodeNum) && ReloadAmountLeft > 0 )
			{
				return RS_Reloading;
			}
	}

	return RS_Complete;
}

/** Returns an anim rate scale for reloading */
simulated function float GetReloadRateScale()
{
	local float Modifier;

	Modifier = UseTacticalReload() ? ReloadAnimRateModifierElite : ReloadAnimRateModifier;

	return super.GetReloadRateScale() * Modifier;
}

simulated function bool HasAnyAmmo()
{
	return AmmoCount[0] > 0 || SpareAmmoCount[0] > 0;
}

simulated function int GetMeleeDamage(byte FireModeNum, optional vector RayDir)
{
	local int Damage;

	Damage = GetModifiedDamage(FireModeNum, RayDir);
	// decode damage scale (see GetDamageScaleByAngle) from the RayDir
	if ( !IsZero(RayDir) )
	{
		Damage = Round(float(Damage) * FMin(VSize(RayDir), 1.f));
	}

	return Damage;
}

defaultproperties
{
	// Content
	PackageKey="HRG_BlastBrawlers"
	FirstPersonMeshName="WEP_1P_HRG_BlastBrawlers_MESH.WEP_1stP_HRG_Blast_Brawlers_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_HRG_BlastBrawlers_ANIM.WEP_1P_HRG_BlastBrawlers_ANIM"
	PickupMeshName="WEP_3P_HRG_BlastBrawlers_MESH.Wep_HRG_Blast_Brawlers_Pickup"
	AttachmentArchetypeName="WEP_HRG_BlastBrawlers_ARCH.Wep_HRG_BlastBrawlers_3P"
	MuzzleFlashTemplateName="WEP_HRG_BlastBrawlers_ARCH.Wep_HRG_BlastBrawler_MuzzleFlash"

	Begin Object Class=KFMeleeHelperWeaponBlastBrawlers Name=MeleeHelper_0
		MaxHitRange=230 //150 //190
		// Override automatic hitbox creation (advanced)
		HitboxChain.Add((BoneOffset=(Y=+3,Z=150)))
		HitboxChain.Add((BoneOffset=(Y=-3,Z=130)))
		HitboxChain.Add((BoneOffset=(Y=+3,Z=110)))
		HitboxChain.Add((BoneOffset=(Y=-3,Z=90)))
		HitboxChain.Add((BoneOffset=(Y=+3,Z=70)))
		HitboxChain.Add((BoneOffset=(Y=-3,Z=50)))
		HitboxChain.Add((BoneOffset=(Y=+3,Z=30)))
		HitboxChain.Add((BoneOffset=(Z=10)))
		HitboxChain.Add((BoneOffset=(Z=-10)))
		WorldImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Blunted_melee_impact'
		// modified combo sequences
		bAllowMeleeToFracture=false
		bUseDirectionalMelee=true
		bHasChainAttacks=false
		MeleeImpactCamShakeScale=0.035f //0.4
		ChainSequence_F=()
		ChainSequence_B=()
		ChainSequence_L=()
		ChainSequence_R=()
	End Object
	MeleeAttackHelper=MeleeHelper_0

	// FOV
	//MeshFOV=95

    // Shotgun Ammo
	MagazineCapacity[0]=4 //3
	SpareAmmoCapacity[0]=40 //36 //28
	InitialSpareMags[0]=2
	AmmoPickupScale[0]=1.5 //2.0

	bCanBeReloaded=true
	bReloadFromMagazine=true
	bNoMagazine=false
	
	// Zooming/Position
	PlayerViewOffset=(X=20,Y=0,Z=0)

    // Inventory
	GroupPriority=110
	InventorySize=9 //7
	WeaponSelectTexture=Texture2D'WEP_UI_HRG_BlastBrawlers_TEX.UI_WeaponSelect_HRG_BlastBrawlers'
	
	FireModeIconPaths(CUSTOM_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_ShotgunSingle'
	FiringStatesArray(CUSTOM_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(CUSTOM_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(CUSTOM_FIREMODE)=class'KFProj_Bullet_BlastBrawlers'
    FireInterval(CUSTOM_FIREMODE)=0.1f
	InstantHitDamageTypes(CUSTOM_FIREMODE)=class'KFDT_Ballistic_BlastBrawlersShotgun'
    InstantHitDamage(CUSTOM_FIREMODE)=39.0 //36.0 //30.0
	AmmoCost(CUSTOM_FIREMODE)=0
	NumPellets(CUSTOM_FIREMODE)=5
	Spread(CUSTOM_FIREMODE)=0.12 //0.1 //0.15
	WeaponFireSnd(CUSTOM_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HRG_BlastBrawlers.Play_WEP_HRG_BlastBrawlers_Shoot_3P', FirstPersonCue=AkEvent'WW_WEP_HRG_BlastBrawlers.Play_WEP_HRG_BlastBrawlers_Shoot_1P')
	InstantHitMomentum(CUSTOM_FIREMODE)=1.0
	PenetrationPower(CUSTOM_FIREMODE)=2.0
	PenetrationDamageReductionCurve(CUSTOM_FIREMODE)=(Points=((InVal=0.f,OutVal=0.f),(InVal=1.f, OutVal=1.f)))

	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_ShotgunSingle'
	InstantHitDamage(DEFAULT_FIREMODE)=50
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Bludgeon_BlastBrawlers'

	FireModeIconPaths(HEAVY_ATK_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BluntMelee'
	InstantHitDamage(HEAVY_ATK_FIREMODE)=200 //175
	InstantHitDamageTypes(HEAVY_ATK_FIREMODE)=class'KFDT_Bludgeon_BlastBrawlersHeavy'

	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_BlastBrawlersBash'
	InstantHitDamage(BASH_FIREMODE)=100

	FiringStatesArray(RELOAD_FIREMODE)=Reloading

	AssociatedPerkClasses(0)=class'KFPerk_Support'

	// Block Sounds
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Crovel'
	ParrySound=AkEvent'WW_WEP_Bullet_Impacts.Play_Parry_Metal'

	ParryStrength=5
	ParryDamageMitigationPercent=0.40
	BlockDamageMitigation=0.50 //0.40

	bWaitingForSecondShot = false
	NumAttacks = 0

	bAllowClientAmmoTracking=false

	ReloadAnimation = "Atk_B"
	ReloadAnimRateModifier = 1.6f
	ReloadAnimRateModifierElite = 1.0f; //0.5f;

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.125f), (Stat=EWUS_Damage1, Scale=1.125f), (Stat=EWUS_Damage2, Scale=1.125f), (Stat=EWUS_Weight, Add=1)))
}
