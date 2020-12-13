//=============================================================================
// KFWeap_Knife_SWAT
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================

class KFWeap_Knife_SWAT extends KFWeap_Edged_Knife;

defaultproperties
{
	// Zooming/Position
	PlayerViewOffset=(X=10,Y=10,Z=0)

	// Content
	PackageKey="Swat_Knife"
	FirstPersonMeshName="wep_1p_swat_knife_mesh.Wep_1stP_SWAT_Knife_Rig"
	AttachmentArchetypeName="WEP_SWAT_Knife_ARCH.Wep_SWAT_Knife_3P"

	Begin Object Name=FirstPersonMesh
		AnimSets(0)=AnimSet'WEP_1P_CommandoKnife_ANIM.Wep_1stP_CommKnife_Anim'
	End Object

	// Inventory
	AssociatedPerkClasses(0)=class'KFPerk_SWAT'
	WeaponSelectTexture=Texture2D'wep_ui_swat_knife_tex.UI_WeaponSelect_SWATKnife'

	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Slashing_Knife_SWAT'
	InstantHitDamageTypes(HEAVY_ATK_FIREMODE)=class'KFDT_Slashing_KnifeHeavy_SWAT'
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Piercing_KnifeStab_SWAT'
}
