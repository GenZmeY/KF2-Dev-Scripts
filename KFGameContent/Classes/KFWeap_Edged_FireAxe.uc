//=============================================================================
// KFWeap_Edged_FireAxe
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================

class KFWeap_Edged_FireAxe extends KFWeap_MeleeBase;

defaultproperties
{
	// Zooming/Position
	PlayerViewOffset=(X=2,Y=0,Z=0)

	// Content
	PackageKey="FireAxe"
	FirstPersonMeshName="wep_1p_fireaxe_mesh.Wep_1stP_FireAxe_Rig"
	FirstPersonAnimSetNames(0)="wep_1p_fireaxe_anim.Wep_1stP_FireAxe_Anim"
	PickupMeshName="wep_3p_fireaxe_mesh.Wep_3rdP_FireAxe_Pickup"
	AttachmentArchetypeName="wep_fireaxe_arch.Wep_FireAxe_3P"

	Begin Object Name=MeleeHelper_0
		MaxHitRange=190
		// Override automatic hitbox creation (advanced)
		HitboxChain.Add((BoneOffset=(X=+3,Z=190)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=170)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=150)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=130)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=110)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=90)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=70)))
		HitboxChain.Add((BoneOffset=(X=-3,Z=50)))
		HitboxChain.Add((BoneOffset=(X=+3,Z=30)))
		HitboxChain.Add((BoneOffset=(Z=10)))
		WorldImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Bladed_melee_impact'
		MeleeImpactCamShakeScale=0.03f //0.3
		// modified combo sequences
		ChainSequence_F=(DIR_Left, DIR_ForwardRight, DIR_ForwardLeft, DIR_ForwardRight, DIR_ForwardLeft)
		ChainSequence_B=(DIR_BackwardRight, DIR_ForwardLeft, DIR_BackwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right, DIR_Left)
		ChainSequence_L=(DIR_Right, DIR_Left, DIR_ForwardRight, DIR_ForwardLeft, DIR_Right, DIR_Left)
		ChainSequence_R=(DIR_Left, DIR_Right, DIR_ForwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right)
	End Object

	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Slashing_FireAxe'
	InstantHitDamage(DEFAULT_FIREMODE)=90 //80

	InstantHitDamageTypes(HEAVY_ATK_FIREMODE)=class'KFDT_Slashing_FireAxeHeavy'
	InstantHitDamage(HEAVY_ATK_FIREMODE)=135 //125  //135

	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_FireAxeBash'
	InstantHitDamage(BASH_FIREMODE)=20

	// Inventory
	GroupPriority=50
	InventorySize=5
	WeaponSelectTexture=Texture2D'WEP_UI_FireAxe_TEX.UI_WeaponSelect_Fireaxe'

	AssociatedPerkClasses(0)=class'KFPerk_Berserker'

	// Block Sounds
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Hammer'
	ParrySound=AkEvent'WW_WEP_Bullet_Impacts.Play_Parry_Wood'

	ParryDamageMitigationPercent=0.50
	BlockDamageMitigation=0.60
	ParryStrength=4

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.2f,IncrementWeight=1)
	//WeaponUpgrades[2]=(IncrementDamage=1.4f,IncrementWeight=2)
	//WeaponUpgrades[3]=(IncrementDamage=1.6f,IncrementWeight=3)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.2f), (Stat=EWUS_Damage1, Scale=1.2f), (Stat=EWUS_Damage2, Scale=1.2f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.4f), (Stat=EWUS_Damage1, Scale=1.4f), (Stat=EWUS_Damage2, Scale=1.4f), (Stat=EWUS_Weight, Add=2)))
	WeaponUpgrades[3]=(Stats=((Stat=EWUS_Damage0, Scale=1.6f), (Stat=EWUS_Damage1, Scale=1.6f), (Stat=EWUS_Damage2, Scale=1.6f), (Stat=EWUS_Weight, Add=3)))
}
