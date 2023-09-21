//=============================================================================
// KFWeap_AssaultRifle_HRGIncendiaryRifle
//=============================================================================
// An M16 M203 Incendiary Assault Rifle
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFWeap_AssaultRifle_HRGIncendiaryRifle extends KFWeap_AssaultRifle_M16M203;

static simulated event EFilterTypeUI GetTraderFilter()
{
	return FT_Assault;
}

static simulated event EFilterTypeUI GetAltTraderFilter()
{
	return FT_Flame;
}

simulated function ModifyMagSizeAndNumber(out int InMagazineCapacity, optional int FireMode = DEFAULT_FIREMODE, optional int UpgradeIndex = INDEX_NONE, optional KFPerk CurrentPerk)
{
	local KFPerk_Firebug FirebugPerk;

	if (CurrentPerk == none)
	{
		CurrentPerk = GetPerk();
	}

	if (FireMode == ALTFIRE_FIREMODE)
	{
		FirebugPerk = KFPerk_Firebug (CurrentPerk);

		/* KFII-48630: Do not apply the High Capacity Fuel Tank Perk Skill on the Grenade Launcher */
		if (FirebugPerk != none && FirebugPerk.IsHighCapFuelTankActive ())
		{
			return;
		}
	}

	super.ModifyMagSizeAndNumber (InMagazineCapacity, FireMode, UpgradeIndex, CurrentPerk);
}

/**
* @see Weapon::ConsumeAmmo
*/
simulated function ConsumeAmmo(byte FireModeNum)
{
	local KFPerk_Firebug FirebugPerk;

`if(`notdefined(ShippingPC))
    if (bInfiniteAmmo)
    {
        return;
    }
`endif

    FirebugPerk = KFPerk_Firebug(GetPerk());
    if (FirebugPerk != none && FirebugPerk.GetIsUberAmmoActive(self)) //check for pyro maniac
    {
        return;
    }
	
	super.ConsumeAmmo(FireModeNum);
}

defaultproperties
{
	
	//grenades
	InitialSpareMags[1]	= 2
	MagazineCapacity[1]	= 1
	SpareAmmoCapacity[1]= 9 

	// Content
	PackageKey="HRG_IncendiaryRifle"
	FirstPersonMeshName="WEP_1P_HRG_IncendiaryRifle_MESH.WEP_1stP_HRG_IncendiaryRifle_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_HRG_IncendiaryRifle_ANIM.Wep_1stP_HRG_IncendiaryRifle_Anim"
	PickupMeshName="WEP_3P_HRG_IncendiaryRifle_MESH.Wep_HRG_IncendiaryRifle_Pickup"
	AttachmentArchetypeName="WEP_HRG_IncendiaryRifle_ARCH.Wep_HRG_IncendiaryRifle_3P_new"
	MuzzleFlashTemplateName="WEP_HRG_IncendiaryRifle_ARCH.Wep_HRG_IncendiaryRifle_MuzzleFlash"
	WeaponSelectTexture=Texture2D'WEP_UI_HRG_IncendiaryRifle_TEX.UI_WeaponSelect_HRG_IncendiaryRifle'

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletAuto'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_HRGIncendiaryRifle'
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_HRGIncendiaryRifle'
	PenetrationPower(DEFAULT_FIREMODE)=0
	FireInterval(DEFAULT_FIREMODE)=+0.0896 // 700 RPM
	Spread(DEFAULT_FIREMODE)=0.0085
	InstantHitDamage(DEFAULT_FIREMODE)=30.0
	FireOffset=(X=30,Y=4.5,Z=-5)
	SecondaryFireOffset=(X=20.f,Y=4.5,Z=-7.f)

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BulletSingle'
	FiringStatesArray(ALTFIRE_FIREMODE)=FiringSecondaryState
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Projectile
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Grenade_HRGIncendiaryRifle'
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_HRGIncendiaryRifleGrenadeImpact'
	PenetrationPower(ALTFIRE_FIREMODE)=0
	FireInterval(ALTFIRE_FIREMODE)=+0.25f
	InstantHitDamage(ALTFIRE_FIREMODE)=230.0
	Spread(ALTFIRE_FIREMODE)=0.0085

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRGIncendiaryRifle'
	InstantHitDamage(BASH_FIREMODE)=26

	// Fire Effects
	WeaponFireSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HRG_IncendiaryRifle.Play_M16_Fire_3P_Loop', FirstPersonCue=AkEvent'WW_WEP_HRG_IncendiaryRifle.Play_M16_Fire_1P_Loop')
	WeaponFireLoopEndSnd(DEFAULT_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_HRG_IncendiaryRifle.Play_M16_Fire_3P_EndLoop', FirstPersonCue=AkEvent'WW_WEP_HRG_IncendiaryRifle.Play_M16_Fire_1P_EndLoop')
	WeaponFireSnd(ALTFIRE_FIREMODE)=(DefaultCue=AkEvent'WW_WEP_SA_M79.Play_WEP_SA_M79_Fire_M', FirstPersonCue=AkEvent'WW_WEP_SA_M79.Play_WEP_SA_M79_Fire_S')

	WeaponDryFireSnd(DEFAULT_FIREMODE)=AkEvent'WW_WEP_SA_L85A2.Play_WEP_SA_L85A2_Handling_DryFire'
	WeaponDryFireSnd(ALTFIRE_FIREMODE)=AkEvent'WW_WEP_SA_L85A2.Play_WEP_SA_L85A2_Handling_DryFire'

	// Advanced (High RPM) Fire Effects
	bLoopingFireAnim(DEFAULT_FIREMODE)=true
	bLoopingFireSnd(DEFAULT_FIREMODE)=true
	WeaponFireSnd(2)=(DefaultCue=AkEvent'WW_WEP_HRG_IncendiaryRifle.Play_M16_Fire_3P_Single', FirstPersonCue=AkEvent'WW_WEP_HRG_IncendiaryRifle.Play_M16_Fire_1P_Single')
	SingleFireSoundIndex=2

	// Perk
	AssociatedPerkClasses.Empty()
	AssociatedPerkClasses(0)=class'KFPerk_Firebug'

	// Weapon Upgrade
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.2f), (Stat=EWUS_Damage1, Scale=1.2f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f), (Stat=EWUS_Damage1, Scale=1.4f), (Stat=EWUS_Weight, Add=2)))
}