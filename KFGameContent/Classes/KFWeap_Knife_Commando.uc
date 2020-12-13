//=============================================================================
// KFWeap_CommandoKnife
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 4/14/2014
//=============================================================================

class KFWeap_Knife_Commando extends KFWeap_Edged_Knife;

defaultproperties
{
	// Zooming/Position
	PlayerViewOffset=(X=10,Y=10,Z=0)

	// Content
	PackageKey="CommandoKnife"
	FirstPersonMeshName="WEP_1P_CommandoKnife_MESH.Wep_1stP_CommKnife_Rig"
	FirstPersonAnimSetNames(0) = "WEP_1P_CommandoKnife_ANIM.Wep_1stP_CommKnife_Anim"
	PickupMeshName = "WEP_3P_CommandoKnife_MESH.Wep_CommandoKnife_Pickup"
	AttachmentArchetypeName="WEP_CommandoKnife_ARCH.Wep_CommandoKnife_3P"

	Begin Object Name=FirstPersonMesh
		AnimSets(0)=AnimSet'WEP_1P_CommandoKnife_ANIM.Wep_1stP_CommKnife_Anim'
	End Object

	// Inventory
	AssociatedPerkClasses(0)=class'KFPerk_Commando'
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_Knife'
}
