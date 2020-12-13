//=============================================================================
// KFWeap_Edged_Zweihander
//=============================================================================
// A two-handed sword primarily of the Renaissance. It is a true two-handed
// sword because it requires two hands to wield, unlike other large swords
// that are wielded with two hands but can also be wielded with one.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFWeap_Edged_Zweihander extends KFWeap_MeleeBase;

defaultproperties
{
	// Zooming/Position
	PlayerViewOffset=(X=2,Y=0,Z=0)

	// Content
	PackageKey="Zweihander"
	FirstPersonMeshName="WEP_1P_Zweihander_MESH.Wep_1stP_Zweihander_Rig"
	FirstPersonAnimSetNames(0)="WEP_1P_Zweihander_ANIM.Wep_1stP_Zweihander_Anim"
	PickupMeshName="WEP_3P_Zweihander_MESH.Wep_Zweihander_Pickup"
	AttachmentArchetypeName="WEP_Zweihander_ARCH.Wep_Zweihander_3P"

	Begin Object Name=MeleeHelper_0
		MaxHitRange=240    //330 //400
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
		MeleeImpactCamShakeScale=0.04f //0.5
		// modified combo sequences
		ChainSequence_F=(DIR_ForwardRight, DIR_ForwardLeft, DIR_ForwardRight, DIR_ForwardLeft)
		ChainSequence_B=(DIR_BackwardLeft, DIR_BackwardRight, DIR_BackwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right, DIR_Left)
		ChainSequence_L=(DIR_Right, DIR_Left, DIR_ForwardRight, DIR_ForwardLeft, DIR_Right, DIR_Left)
		ChainSequence_R=(DIR_Left, DIR_Right, DIR_ForwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right)
	End Object

	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Slashing_Zweihander'
	InstantHitMomentum(DEFAULT_FIREMODE)=30000.f
	InstantHitDamage(DEFAULT_FIREMODE)=85   //70

	InstantHitDamageTypes(HEAVY_ATK_FIREMODE)=class'KFDT_Slashing_ZweihanderHeavy'
	InstantHitMomentum(HEAVY_ATK_FIREMODE)=30000.f
	InstantHitDamage(HEAVY_ATK_FIREMODE)=195     //200

	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Piercing_ZweihanderStab'
	InstantHitDamage(BASH_FIREMODE)=63

	// Inventory
	GroupPriority=75
	InventorySize=7
	WeaponSelectTexture=Texture2D'WEP_UI_Zweihander_TEX.UI_WeaponSelect_Zweihander'
	AssociatedPerkClasses(0)=class'KFPerk_Berserker'

	// Block Sounds
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Katana'
	ParrySound=AkEvent'WW_WEP_Bullet_Impacts.Play_Parry_Metal'

	ParryDamageMitigationPercent=0.4
	BlockDamageMitigation=0.5
	ParryStrength=5

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.05f,IncrementWeight=1)
	//WeaponUpgrades[2]=(IncrementDamage=1.1f,IncrementWeight=2)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.05f), (Stat=EWUS_Damage1, Scale=1.05f), (Stat=EWUS_Damage2, Scale=1.05f), (Stat=EWUS_Weight, Add=1)))
	WeaponUpgrades[2]=(Stats=((Stat=EWUS_Damage0, Scale=1.1f), (Stat=EWUS_Damage1, Scale=1.1f), (Stat=EWUS_Damage2, Scale=1.1f), (Stat=EWUS_Weight, Add=2)))
}


