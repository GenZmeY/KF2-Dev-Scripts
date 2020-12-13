//=============================================================================
// KFWeap_Edged_AbominationAxe
//=============================================================================
// Smash axe!
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
// - Zane Gholson
//=============================================================================

class KFWeap_Edged_AbominationAxe extends KFWeap_MeleeBase;

defaultproperties
{
	// Zooming/Position
	PlayerViewOffset=(X=2,Y=0,Z=0)

	// Content
	PackageKey="KrampusAxe"
	FirstPersonMeshName="WEP_1P_KrampusAxe_MESH.Wep_1stP_KrampusAxe_Rig"
	FirstPersonAnimSetNames(0)="wep_1p_krampusaxe_anim.Wep_1stP_KrampusAxe_Anim"
	PickupMeshName="wep_3p_krampusaxe_mesh.Wep_3rdP_KrampusAxe_Pickup"
	AttachmentArchetypeName="WEP_KrampusAxe_ARCH.Wep_KrampusAxe_3P"


	Begin Object Name=MeleeHelper_0
		MaxHitRange=220    //330 //400
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

	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Slashing_AbominationAxe'
	InstantHitMomentum(DEFAULT_FIREMODE)=30000.f
	InstantHitDamage(DEFAULT_FIREMODE)=120   //70

	InstantHitDamageTypes(HEAVY_ATK_FIREMODE)=class'KFDT_Slashing_AbominationAxeHeavy'
	InstantHitMomentum(HEAVY_ATK_FIREMODE)=30000.f
	InstantHitDamage(HEAVY_ATK_FIREMODE)=250     //200

	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Piercing_AbominationAxeStab'
	InstantHitMomentum(BASH_FIREMODE)=100000.f
	InstantHitDamage(BASH_FIREMODE)=101

	// Inventory
	GroupPriority=125
	InventorySize=10
	WeaponSelectTexture=Texture2D'WEP_UI_KrampusAxe_TEX.UI_WeaponSelect_KrampusAxe'
	

	AssociatedPerkClasses(0)=class'KFPerk_Berserker'

	// Block Sounds
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Katana'
	ParrySound=AkEvent'WW_WEP_Bullet_Impacts.Play_Parry_Metal'

	ParryDamageMitigationPercent=0.4
	BlockDamageMitigation=0.5
	ParryStrength=5
}


