//=============================================================================
// KFWeap_AssetTest
//=============================================================================
// A debug weapon for viewing new assets
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFWeap_AssetDummy extends KFWeapon;

defaultproperties
{
	// Content
	PackageKey="AssetTest"
	FirstPersonMeshName="WEP_1P_AssetTest_MESH.Wep_1stP_AssetTest_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_AssetTest_ANIM.Wep_1st_AssetTest_Anim"
	PickupMeshName="WEP_3P_L85A2_MESH.Wep_L85A2_Pickup"
	AttachmentArchetypeName="WEP_L85A2_ARCH.Wep_L85A2_3P"

	// Don't actually fire
	WeaponFireTypes(DEFAULT_FIREMODE)=EWFT_Custom
	WeaponFireTypes(ALTFIRE_FIREMODE)=EWFT_Custom

	// Ammo
	MagazineCapacity[0]=30
	SpareAmmoCapacity[0]=390
	InitialSpareMags[0]=4
	bCanBeReloaded=true
	bReloadFromMagazine=true

	// Attachments
	bHasIronSights=true
	bHasFlashlight=false
}


