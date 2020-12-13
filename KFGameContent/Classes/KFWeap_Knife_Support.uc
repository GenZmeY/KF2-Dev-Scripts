//=============================================================================
// KFWeap_Knife_Support
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 4/14/2014
//=============================================================================

class KFWeap_Knife_Support extends KFWeap_Edged_Knife;

defaultproperties
{
	// Zooming/Position
	PlayerViewOffset=(X=10,Y=10,Z=0)

	// Content
	PackageKey="SupportKnife"
	FirstPersonMeshName="WEP_1P_SupportKnife_MESH.Wep_1stP_SupportKnife_Rig"
	AttachmentArchetypeName="WEP_SupportKnife_ARCH.Wep_SupportKnife_3P"

	Begin Object Name=FirstPersonMesh
		AnimSets(0)=AnimSet'WEP_1P_CommandoKnife_ANIM.Wep_1stP_CommKnife_Anim'
	End Object

	// Inventory
	AssociatedPerkClasses(0)=class'KFPerk_Support'
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_SupportKnife'
}
