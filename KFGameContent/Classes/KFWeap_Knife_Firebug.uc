//=============================================================================
// KFWeap_Knife_Firebug
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 4/14/2014
//=============================================================================

class KFWeap_Knife_Firebug extends KFWeap_Edged_Knife;

defaultproperties
{
	// Zooming/Position
	PlayerViewOffset=(X=10,Y=10,Z=0)

	// Content
	PackageKey="FireBug_Knife"
	FirstPersonMeshName="WEP_1P_FireBug_Knife_MESH.Wep_1stP_FirebugKnife_Rig"
	AttachmentArchetypeName="WEP_FireBug_Knife_ARCH.Wep_FirebugKnife_3P"

	Begin Object Name=FirstPersonMesh
		AnimSets(0)=AnimSet'WEP_1P_CommandoKnife_ANIM.Wep_1stP_CommKnife_Anim'
	End Object

	// Inventory
	AssociatedPerkClasses(0)=class'KFPerk_Firebug'
	WeaponSelectTexture=Texture2D'WEP_UI_Firebug_Knife_TEX.UI_WeaponSelect_FirebugKnife'
}
