//=============================================================================
// KFWeap_Knife_Gunslinger
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================

class KFWeap_Knife_Gunslinger extends KFWeap_Edged_Knife;

defaultproperties
{
	// Zooming/Position
	PlayerViewOffset=(X=10,Y=10,Z=0)

	// Content
	PackageKey="Gunslinger_Knife"
	FirstPersonMeshName="WEP_1P_Gunslinger_Knife_MESH.Wep_1stP_GunslingerKnife_Rig"
	AttachmentArchetypeName="WEP_Gunslinger_Knife_ARCH.Wep_Gunslinger_Knife_3P"

	Begin Object Name=FirstPersonMesh
		AnimSets(0)=AnimSet'WEP_1P_CommandoKnife_ANIM.Wep_1stP_CommKnife_Anim'
	End Object

	// Inventory
	AssociatedPerkClasses(0)=class'KFPerk_Gunslinger'
	WeaponSelectTexture=Texture2D'WEP_UI_Gunslinger_Knife_TEX.UI_WeaponSelect_GunslingerKnife'
}
