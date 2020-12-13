//=============================================================================
// KFWeap_CommandoKnife
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 4/14/2014
//=============================================================================

class KFWeap_Edged_Knife extends KFWeap_MeleeBase;

simulated static function bool AllowedForAllPerks()
{
    return true;
}

defaultproperties
{
	// Inventory
	bCanThrow=false
	bDropOnDeath=false
	bIsBackupWeapon=true
	GroupPriority=10
	WeaponSelectTexture=Texture2D'ui_weaponselect_tex.UI_WeaponSelect_Knife'

	// Zooming/Position
	PlayerViewOffset=(X=10,Y=10,Z=0)

	// Content

	Begin Object Name=MeleeHelper_0
		MaxHitRange=220
		WorldImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Bladed_melee_impact'
		// Override automatic hitbox creation (advanced)
		HitboxChain.Add((BoneOffset=(Y=+3,Z=125)))
		HitboxChain.Add((BoneOffset=(Y=-3,Z=100)))
		HitboxChain.Add((BoneOffset=(Y=+3,Z=75)))
		HitboxChain.Add((BoneOffset=(Y=-3,Z=50)))
		HitboxChain.Add((BoneOffset=(Y=+3,Z=25)))
		HitboxChain.Add((BoneOffset=(Y=-3,Z=0)))
		HitboxChain.Add((BoneOffset=(Z=-25)))
		MeleeImpactCamShakeScale=0.03f //0.2
		// modified combo sequences
		ChainSequence_F=(DIR_ForwardRight, DIR_ForwardLeft, DIR_ForwardRight, DIR_ForwardLeft)
		ChainSequence_B=(DIR_BackwardLeft, DIR_BackwardRight, DIR_BackwardLeft, DIR_ForwardRight)
		ChainSequence_L=(DIR_Right, DIR_ForwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right)
		ChainSequence_R=(DIR_Left, DIR_ForwardRight, DIR_ForwardLeft, DIR_Right, DIR_Left)
	End Object

	InstantHitDamage(DEFAULT_FIREMODE)=32 // 77% of 19
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Slashing_Knife'

	InstantHitDamage(HEAVY_ATK_FIREMODE)=64
	InstantHitDamageTypes(HEAVY_ATK_FIREMODE)=class'KFDT_Slashing_KnifeHeavy'

	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Piercing_KnifeStab'
	InstantHitDamage(BASH_FIREMODE)=15
	InstantHitMomentum(BASH_FIREMODE)=1000.f   //30000.f

	MaxChainAtkCount=4
	ParryDamageMitigationPercent=0.8
	BlockDamageMitigation=0.8

	//Perks
	AssociatedPerkClasses(0)=class'KFPerk_Commando'

	// Block Sounds
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Katana'
	ParrySound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Katana'

	ParryStrength=1
}
