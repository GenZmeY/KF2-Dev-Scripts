//=============================================================================
// KFWeap_Knife_FieldMedic
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 4/14/2014
//=============================================================================

class KFWeap_Knife_FieldMedic extends KFWeap_Edged_Knife;

defaultproperties
{
	// Zooming/Position
	PlayerViewOffset=(X=10,Y=10,Z=0)

	// Content
	PackageKey="Medic_Knife"
	FirstPersonMeshName="Wep_1P_Medic_Knife_MESH.Wep_1stP_Medic_Knife_Rig"
	AttachmentArchetypeName="WEP_Medic_Knife_ARCH.Wep_MedicKnife_3P"

	Begin Object Name=FirstPersonMesh
		AnimSets(0)=AnimSet'WEP_1P_CommandoKnife_ANIM.Wep_1stP_CommKnife_Anim'
	End Object

	// Inventory
	AssociatedPerkClasses(0)=class'KFPerk_FieldMedic'
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_MedicKnife'

	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Slashing_Knife_Medic'
	InstantHitDamageTypes(HEAVY_ATK_FIREMODE)=class'KFDT_Slashing_KnifeHeavy_Medic'
	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Piercing_KnifeStab_FieldMedic'
}
