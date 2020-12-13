//=============================================================================
// KFWeap_Knife_Berserker
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 4/14/2014
//=============================================================================

class KFWeap_Knife_Berserker extends KFWeap_Edged_Knife;

defaultproperties
{
	// Content
	PackageKey="BerserkerKnife"
	FirstPersonMeshName="WEP_1P_BerserkerKnife_MESH.Wep_1stP_BerserkerKnife_Rig"
	AttachmentArchetypeName="WEP_BerserkerKnife_ARCH.Wep_Knife_3P"

	Begin Object Name=FirstPersonMesh
		AnimSets(0)=AnimSet'WEP_1P_CommandoKnife_ANIM.Wep_1stP_CommKnife_Anim'
	End Object
	
	// Inventory
	AssociatedPerkClasses(0)=class'KFPerk_Berserker'
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_BerserkerKnife'

	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Slashing_Knife_Berserker'
	InstantHitDamageTypes(HEAVY_ATK_FIREMODE)=class'KFDT_Slashing_KnifeHeavy_Berserker'
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Piercing_KnifeStab_Berserker'
}