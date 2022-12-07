//=============================================================================
// KFWeap_Knife_Demolitionist
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 4/14/2014
//=============================================================================

class KFWeap_Knife_Demolitionist extends KFWeap_Edged_Knife;

defaultproperties
{
	// Zooming/Position
	PlayerViewOffset=(X=10,Y=10,Z=0)
	
	// Content
	PackageKey="Demo_Knife"
	FirstPersonMeshName="WEP_1P_Demo_Knife_MESH.Wep_1stP_Demo_Knife_Rig"
	AttachmentArchetypeName="WEP_Demo_Knife_ARCH.Wep_Demo_Knife_3P"

	Begin Object Name=FirstPersonMesh
		AnimSets(0)=AnimSet'WEP_1P_CommandoKnife_ANIM.Wep_1stP_CommKnife_Anim'
	End Object

	// Inventory
	AssociatedPerkClasses(0)=class'KFPerk_Demolitionist'
	WeaponSelectTexture=Texture2D'WEP_UI_Demo_Knife_TEX.UI_WeaponSelect_DemoKnife'
}
