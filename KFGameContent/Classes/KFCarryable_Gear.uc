//=============================================================================
// KFCarryable_Gear
//=============================================================================
// A steampunk gear that can be carried by players
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFCarryable_Gear extends KFCarryableObject_Collectible;

defaultproperties
{
	PlayerViewOffset=(X=0,Y=6,Z=0)

	// Content
	PackageKey="Steampunk_Gear"
	FirstPersonMeshName="wep_1p_steampunk_gear_mesh.Wep_1stP_Steampunk_Gear_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Steampunk_Gear_ANIM.Wep_1stP_Steampunk_Gear_anim"
	PickupMeshName="WEP_3P_Steampunk_Gear_MESH.Wep_3rdP_Steampunk_Gear_Pickup"
	AttachmentArchetypeName="WEP_Steampunk_Gear_ARCH.Wep_Steampunk_Gear_3P"

	WeaponSelectTexture=Texture2D'WEP_UI_Steampunk_Gear_TEX.UI_WeaponSelect_SteampunkGear'
}