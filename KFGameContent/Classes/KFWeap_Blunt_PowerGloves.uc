//=============================================================================
// KFWeap_Blunt_PowerGloves
//=============================================================================
// Weapon class for melee power gloves weapon.
// This is the Static Strikers
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFWeap_Blunt_PowerGloves extends KFWeap_MeleeBase;

defaultproperties
{
	// Content
	PackageKey="Static_Strikers"
	FirstPersonMeshName="wep_1p_static_strikers_mesh.Wep_1stP_Static_Strikers_Rig"
	FirstPersonAnimSetNames(0)="wep_1p_static_strikers_anim.wep_1p_static_strikers_anim"
	PickupMeshName="WEP_3P_Static_Strikers_MESH.Wep_3rdP_Static_Strikers_Pickup"
	AttachmentArchetypeName="WEP_Static_Strikers_ARCH.Wep_Static_Strikers_3P"

	Begin Object Name=MeleeHelper_0
		MaxHitRange=230 //150 //190
		// Override automatic hitbox creation (advanced)
		HitboxChain.Add((BoneOffset=(Y=+3,Z=150)))
		HitboxChain.Add((BoneOffset=(Y=-3,Z=130)))
		HitboxChain.Add((BoneOffset=(Y=+3,Z=110)))
		HitboxChain.Add((BoneOffset=(Y=-3,Z=90)))
		HitboxChain.Add((BoneOffset=(Y=+3,Z=70)))
		HitboxChain.Add((BoneOffset=(Y=-3,Z=50)))
		HitboxChain.Add((BoneOffset=(Y=+3,Z=30)))
		HitboxChain.Add((BoneOffset=(Z=10)))
		HitboxChain.Add((BoneOffset=(Z=-10)))
		WorldImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Blunted_melee_impact'
		// modified combo sequences
		MeleeImpactCamShakeScale=0.035f //0.4
		ChainSequence_F=(DIR_Left, DIR_ForwardRight, DIR_ForwardLeft, DIR_ForwardRight, DIR_ForwardLeft)
		ChainSequence_B=(DIR_BackwardLeft, DIR_Left, DIR_Right, DIR_ForwardRight, DIR_Left, DIR_Right, DIR_Left)
		ChainSequence_L=(DIR_Right, DIR_BackwardRight, DIR_ForwardRight, DIR_ForwardLeft, DIR_Right, DIR_Left)
		ChainSequence_R=(DIR_Left, DIR_BackwardLeft, DIR_ForwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right)
	End Object

	// FOV
	//MeshFOV=95


	// Zooming/Position
	PlayerViewOffset=(X=20,Y=0,Z=0)

    // Inventory
	GroupPriority=110
	InventorySize=7
	WeaponSelectTexture=Texture2D'WEP_UI_Static_Strikers_TEX.UI_WeaponSelect_StaticStrikers'

	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BluntMelee'
	InstantHitDamage(DEFAULT_FIREMODE)=95
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Bludgeon_PowerGloves'

	FireModeIconPaths(HEAVY_ATK_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BluntMelee'
	InstantHitDamage(HEAVY_ATK_FIREMODE)=175
	InstantHitDamageTypes(HEAVY_ATK_FIREMODE)=class'KFDT_Bludgeon_PowerGlovesHeavy'

	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_PowerGlovesBash'
	InstantHitDamage(BASH_FIREMODE)=100

	AssociatedPerkClasses(0)=class'KFPerk_Berserker'

	// Block Sounds
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Crovel'
	ParrySound=AkEvent'WW_WEP_Bullet_Impacts.Play_Parry_Metal'

	ParryStrength=5
	ParryDamageMitigationPercent=0.40
	BlockDamageMitigation=0.40

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.1f,IncrementWeight=1)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.1f), (Stat=EWUS_Damage1, Scale=1.1f), (Stat=EWUS_Damage2, Scale=1.1f), (Stat=EWUS_Weight, Add=1)))
}


