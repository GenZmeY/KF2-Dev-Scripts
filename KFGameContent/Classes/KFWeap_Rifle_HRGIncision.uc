//=============================================================================
// KFWeap_Rifle_HRGIncision
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================

class KFWeap_Rifle_HRGIncision extends KFWeap_Rifle_RailGun;

const ShootDartAnim	= 'Shoot_Dart_HI';
const ShootDartIronAnim = 'Shoot_Dart_Iron_HI';

/** Icon textures for lock on drawing */
var Texture2D LockedTeammateHitZoneIcon;
var Texture2D DefaultTeammateHitZoneIcon;
var LinearColor GreenIconColor;

/** Override for 1st person healing dart anims */
simulated function name GetWeaponFireAnim(byte FireModeNum)
{
	if (FireModeNum == ALTFIRE_FIREMODE)
	{
		return (bUsingSights) ? ShootDartIronAnim : ShootDartAnim;
	}

	return Super.GetWeaponFireAnim(FireModeNum);
}

/** Instead of switch fire mode use as immediate alt fire */
simulated function AltFireMode()
{
	if (!Instigator.IsLocallyControlled())
	{
		return;
	}

	// StartFire - StopFire called from KFPlayerInput
	StartFire(ALTFIRE_FIREMODE);
}

simulated function StartFire(byte FireModeNum)
{
	// Skip KFWeap_Rifle_RailGun::StartFire because of some irrelevant cheat detection there
	super(KFWeap_ScopedBase).StartFire(FireModeNum);
}

simulated function vector GetInstantFireAimLocation()
{
	return TargetingComp.LockedAimLocation[CurrentFireMode];
}

/*********************************************************************************************
 * @name Targeting HUD
 **********************************************************************************************/

/** Handle drawing items on the scope ScriptedTexture */
simulated function OnRender(Canvas C)
{
    local int i;

	super.OnRender(C);

    if (!bUsingSights)
    {
       return;
    }

	// Draw the targeting locations on the scope
	for (i = 0; i < TargetingComp.TargetVulnerableLocations_Player.Length; i++)
    {
        if (!IsZero(TargetingComp.TargetVulnerableLocations_Player[i]))
        {
            DrawTargetingTeammateIcon( C, i );
        }
    }

    CanvasTexture.bNeedsUpdate = true;
}

/**
 * @brief Draws an icon when human players are hidden but in the field of view
 *
 * @param PRI Player's PlayerReplicationInfo
 * @param IconWorldLocation The "player's" location in the world
 */
simulated function DrawTargetingTeammateIcon( Canvas Canvas, int index )
{
    local vector WorldPos;
    local float IconSize, IconScale;
    local vector2d ScreenPos;

    // Project world pos to canvas
	WorldPos = TargetingComp.TargetVulnerableLocations_Player[index];
    ScreenPos = WorldToCanvas(Canvas, WorldPos);

    // calculate scale based on resolution and distance
    IconScale = FMin(float(Canvas.SizeX) / 1024.f, 1.f);
	// Scale down up to 40 meters away, with a clamp at 20% size
    IconScale *= FClamp(1.f - VSize(WorldPos - Instigator.Location) / 4000.f, 0.2f, 1.f);

    // Apply size scale
    IconSize = 300.f * IconScale;
    ScreenPos.X -= IconSize / 2.f;
    ScreenPos.Y -= IconSize / 2.f;

    // Off-screen check
    if (ScreenPos.X < 0 || ScreenPos.X > Canvas.SizeX || ScreenPos.Y < 0 || ScreenPos.Y > Canvas.SizeY)
    {
        return;
    }

    Canvas.SetPos( ScreenPos.X, ScreenPos.Y );

	// Pick the color of the targeting box to draw
	if (TargetingComp.LockedHitZone[1] >= 0 && index == TargetingComp.LockedHitZone[1])
    {
        Canvas.DrawTile(LockedTeammateHitZoneIcon, IconSize, IconSize, 0, 0,
			LockedTeammateHitZoneIcon.SizeX, LockedTeammateHitZoneIcon.SizeY, GreenIconColor);
    }
    else if (TargetingComp.PendingHitZone[1] >= 0 && index == TargetingComp.PendingHitZone[1])
    {
        Canvas.DrawTile(LockedTeammateHitZoneIcon, IconSize, IconSize, 0, 0,
			LockedTeammateHitZoneIcon.SizeX, LockedTeammateHitZoneIcon.SizeY, YellowIconColor);
    }
    else
    {
        Canvas.DrawTile(DefaultTeammateHitZoneIcon, IconSize, IconSize, 0, 0,
			DefaultTeammateHitZoneIcon.SizeX, DefaultTeammateHitZoneIcon.SizeY, BlueIconColor);
    }
}

/*********************************************************************************************
 @name Reload / recharge
********************************************************************************************* */

/** Healing charge doesn't count as ammo for purposes of inventory management (e.g. switching) */
simulated function bool HasAnyAmmo()
{
	if (HasSpareAmmo() || HasAmmo(DEFAULT_FIREMODE))
	{
		return true;
	}

	return false;
}

defaultproperties
{
	// Content
	PackageKey="HRG_Incision"
	FirstPersonMeshName="WEP_1P_HRG_Incision_MESH.WEP_1stP_HRG_Incision"
	FirstPersonAnimSetNames(0)="wep_1p_hrg_incision_anim.wep_1p_hrg_incision_anim"
	PickupMeshName="wep_3p_HRG_Incision_MESH.Wep_3rdP_HRG_Incision_Pickup"
	AttachmentArchetypeName="wep_hrg_incision_arch.Wep_HRG_Incision_3P_Updated"
	MuzzleFlashTemplateName="wep_hrg_incision_arch.Wep_HRG_Incision_MuzzleFlash"

	// Inventory / Grouping
	InventorySize=8
	WeaponSelectTexture=Texture2D'WEP_UI_HRG_Incision_Item_TEX.UI_WeaponSelect_HRG_Incision'
	SecondaryAmmoTexture=Texture2D'UI_SecondaryAmmo_TEX.MedicDarts'

	//Perk
	AssociatedPerkClasses.Empty()
	AssociatedPerkClasses(0)=class'KFPerk_FieldMedic'

	// Ammo
	MagazineCapacity[0]=1
	SpareAmmoCapacity[0]=39
	InitialSpareMags[0]=12
	bCanBeReloaded=true
	bReloadFromMagazine=true
	AmmoPickupScale[0]=3.0
	MagazineCapacity[1]=100
	bCanRefillSecondaryAmmo=false
	bNoMagazine=true

	// DEFAULT_FIREMODE
	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'UI_SecondaryAmmo_TEX.UI_FireModeSelect_AutoTarget'
	FiringStatesArray(DEFAULT_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(DEFAULT_FIREMODE)=class'KFProj_Bullet_HRGIncisionHurt'
	InstantHitDamage(DEFAULT_FIREMODE)=400
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Ballistic_HRGIncisionHurt'
	FireInterval(DEFAULT_FIREMODE)=0.1 //0.4
	PenetrationPower(DEFAULT_FIREMODE)=10.0
	Spread(DEFAULT_FIREMODE)=0.005

	// ALT_FIREMODE
	FireModeIconPaths(ALTFIRE_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_MedicDart'
	FiringStatesArray(ALTFIRE_FIREMODE)=WeaponSingleFiring
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_InstantHit
	WeaponProjectiles(ALTFIRE_FIREMODE)=class'KFProj_Bullet_HRGIncisionHeal'
	FireInterval(ALTFIRE_FIREMODE)=+0.175
	InstantHitDamage(ALTFIRE_FIREMODE)=75
	InstantHitDamageTypes(ALTFIRE_FIREMODE)=class'KFDT_Ballistic_HRGIncisionHeal'
	InstantHitMomentum(ALTFIRE_FIREMODE)=50000.f
	Spread(ALTFIRE_FIREMODE)=0.005
	PenetrationPower(ALTFIRE_FIREMODE)=10.0
	AmmoCost(ALTFIRE_FIREMODE)=50

	// BASH_FIREMODE
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_HRGIncision'
	InstantHitDamage(BASH_FIREMODE)=30

	// Lock-on
	TargetingCompClass=class'KFTargetingWeaponComponent_HRGIncision'
	MedicCompClass=class'KFMedicWeaponComponent_HRGIncision'

	LockedTeammateHitZoneIcon=Texture2D'Wep_Scope_TEX.Wep_1stP_Yellow_Red_Target'
    DefaultTeammateHitZoneIcon=Texture2D'Wep_Scope_TEX.Wep_1stP_Blue_Target'
    GreenIconColor=(R=1, G=255, B=1)

	// Weapon Upgrade stat boosts
	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.2f), (Stat=EWUS_Damage1, Scale=1.2f), (Stat=EWUS_Weight, Add=1), (Stat=EWUS_HealFullRecharge, Scale=0.9f)))
}
