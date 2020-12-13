//=============================================================================
// KFWeap_Blunt_MaceAndShield
//=============================================================================
// A melee club and shield for heavy blunt damage
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFWeap_Blunt_MaceAndShield extends KFWeap_MeleeBase;

var const float MaxMaceHitRange, MaxShieldHitRange;
var const array<MeleeHitBoxInfo> MaceHitboxChain, ShieldHitboxChain;
var const class<KFDamageType> MaceLightDamageType, ShieldLightDamageType;
var const class<KFDamageType> MaceHeavyDamageType, ShieldHeavyDamageType;

simulated function SwapToMaceMeleeSettings()
{
	MeleeAttackHelper.SetMeleeRange( MaxMaceHitRange );
	MeleeAttackHelper.SetHitBoxChain( MaceHitboxChain );
}

simulated function SwapToShieldMeleeSettings()
{
	MeleeAttackHelper.SetMeleeRange( MaxShieldHitRange );
	MeleeAttackHelper.SetHitBoxChain( ShieldHitboxChain );
}

/*********************************************************************************************
 * State MeleeAttackBasic
 * This is a basic melee state that's used as a base for other more advanced states
 *********************************************************************************************/

/**
 * state MeleeAttackBasic
 * State the weapon is in when doing a melee attack
 */
simulated state MeleeAttackBasic
{
	simulated function BeginState(Name PrevStateName)
	{
		if( CurrentFireMode == BASH_FIREMODE )
		{
			SwapToShieldMeleeSettings();
		}
		super.BeginState( PrevStateName );
	}
}

/*********************************************************************************************
 * State MeleeChainAttacking
 * A melee firemode that chains together a sequence of attacks
 *********************************************************************************************/

simulated state MeleeChainAttacking
{
	/** Get name of the animation to play for PlayFireEffects */
	simulated function name GetMeleeAnimName(EPawnOctant AtkDir, EMeleeAttackType AtkType)
	{
		if( AtkType == ATK_Combo )
		{
			if( AtkDir == DIR_Right )
			{
				SwapToShieldMeleeSettings();
				InstantHitDamageTypes[DEFAULT_FIREMODE] = ShieldLightDamageType;
			}
			else
			{
				SwapToMaceMeleeSettings();
				InstantHitDamageTypes[DEFAULT_FIREMODE] = MaceLightDamageType;
			}
		}
		else
		{
			SwapToMaceMeleeSettings();
			InstantHitDamageTypes[DEFAULT_FIREMODE] = MaceLightDamageType;
		}

		return super.GetMeleeAnimName( AtkDir, AtkType );
	}
}

/*********************************************************************************************
 * State MeleeHeavyAttacking
 * This is the alt-fire Melee State.
 *********************************************************************************************/

simulated state MeleeHeavyAttacking
{
	/** heavy damage attack anims */
	simulated function name GetMeleeAnimName(EPawnOctant AtkDir, EMeleeAttackType AtkType)
	{
		// heavy damage attacks
		if( AtkType == ATK_DrawStrike )
		{
			SwapToMaceMeleeSettings();
			InstantHitDamageTypes[HEAVY_ATK_FIREMODE] = MaceHeavyDamageType;
			return MeleeDrawStrikeAnim;
		}

		// Since mace and shield are mixed in heavy attacks, we swap properties depending on which one is used
		if( AtkDir == DIR_Left || AtkDir == DIR_ForwardLeft || AtkDir == DIR_Forward )
		{
			SwapToMaceMeleeSettings();
			InstantHitDamageTypes[HEAVY_ATK_FIREMODE] = MaceHeavyDamageType;
		}
		else
		{
			SwapToShieldMeleeSettings();
			InstantHitDamageTypes[HEAVY_ATK_FIREMODE] = ShieldHeavyDamageType;
		}

		switch (AtkDir)
		{
			case DIR_Forward:		return MeleeHeavyAttackAnim_F;
			case DIR_ForwardLeft:	return MeleeHeavyAttackAnim_F;
			case DIR_ForwardRight:	return MeleeHeavyAttackAnim_F;
			case DIR_Backward:		return MeleeHeavyAttackAnim_B;
			case DIR_BackwardLeft:	return MeleeHeavyAttackAnim_B;
			case DIR_BackwardRight: return MeleeHeavyAttackAnim_B;
			case DIR_Left:			return MeleeHeavyAttackAnim_L;
			case DIR_Right:			return MeleeHeavyAttackAnim_R;
		}
	}
}

defaultproperties
{
	// Content
	PackageKey="Shield_Melee"
	FirstPersonMeshName="wep_1p_shield_melee_mesh.Wep_1stP_Shield_Melee_Rig"
	FirstPersonAnimSetNames(0)="wep_1p_shield_melee_anim.Wep_1stP_Shield_Melee_Anim"
	PickupMeshName="WEP_3P_Shield_Melee_MESH.Wep_Shield_Melee_Pickup"
	AttachmentArchetypeName="WEP_Shield_Melee_ARCH.Wep_MaceAndShield_3P"

	Begin Object Name=MeleeHelper_0
		// Override automatic hitbox creation (advanced)
		WorldImpactEffects=KFImpactEffectInfo'FX_Impacts_ARCH.Blunted_melee_impact'
		// modified combo sequences
		MeleeImpactCamShakeScale=0.04f //0.5
		HitboxChain.Add((BoneOffset=(Y=0,Z=0)))
		ChainSequence_F=(DIR_ForwardRight, DIR_ForwardLeft, DIR_ForwardRight, DIR_ForwardLeft)
		ChainSequence_B=(DIR_BackwardRight, DIR_ForwardLeft, DIR_BackwardLeft, DIR_ForwardRight)
		ChainSequence_L=(DIR_Right, DIR_ForwardLeft, DIR_ForwardRight, DIR_Left, DIR_Right)
		ChainSequence_R=(DIR_Left, DIR_ForwardRight, DIR_ForwardLeft, DIR_Right, DIR_Left)
	End Object

	// Mace melee properties
	MaxMaceHitRange=185
	MaceHitboxChain.Add((BoneOffset=(Y=-3,Z=165)))
	MaceHitboxChain.Add((BoneOffset=(Y=+3,Z=150)))
	MaceHitboxChain.Add((BoneOffset=(Y=-3,Z=130)))
	MaceHitboxChain.Add((BoneOffset=(Y=+3,Z=110)))
	MaceHitboxChain.Add((BoneOffset=(Y=-3,Z=90)))
	MaceHitboxChain.Add((BoneOffset=(Y=+3,Z=70)))
	MaceHitboxChain.Add((BoneOffset=(Y=-3,Z=50)))
	MaceHitboxChain.Add((BoneOffset=(Y=+3,Z=30)))
	MaceHitboxChain.Add((BoneOffset=(Y=-3,Z=10)))

	// Shield melee properties
	MaxShieldHitRange=170 //160
	ShieldHitboxChain.Add((BoneOffset=(Y=+10,Z=145)))
	ShieldHitboxChain.Add((BoneOffset=(Y=-10,Z=130)))
	ShieldHitboxChain.Add((BoneOffset=(Y=+10,Z=110)))
	ShieldHitboxChain.Add((BoneOffset=(Y=-10,Z=90)))
	ShieldHitboxChain.Add((BoneOffset=(Y=+10,Z=70)))
	ShieldHitboxChain.Add((BoneOffset=(Y=-10,Z=50)))
	ShieldHitboxChain.Add((BoneOffset=(Y=+8,Z=30)))
	ShieldHitboxChain.Add((BoneOffset=(Y=-8,Z=10)))

    // Inventory
	GroupPriority=110
	InventorySize=8
	WeaponSelectTexture=Texture2D'WEP_UI_Shield_Melee_TEX.UI_WeaponSelect_MaceShield'

	// For procedural weapon hiding
	QuickWeaponDownRotation=(Pitch=-8192,Yaw=0,Roll=0)

	FireModeIconPaths(DEFAULT_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BluntMelee'
	InstantHitDamage(DEFAULT_FIREMODE)=80 //70
	InstantHitDamageTypes(DEFAULT_FIREMODE)=class'KFDT_Bludgeon_MaceAndShield'
	MaceLightDamageType=class'KFDT_Bludgeon_MaceAndShield'
	ShieldLightDamageType=class'KFDT_Bludgeon_MaceAndShield_ShieldLight'

	FireModeIconPaths(HEAVY_ATK_FIREMODE)=Texture2D'ui_firemodes_tex.UI_FireModeSelect_BluntMelee'
	InstantHitDamage(HEAVY_ATK_FIREMODE)=175 //200
	InstantHitDamageTypes(HEAVY_ATK_FIREMODE)=class'KFDT_Bludgeon_MaceAndShield_MaceHeavy'
	MaceHeavyDamageType=class'KFDT_Bludgeon_MaceAndShield_MaceHeavy'
	ShieldHeavyDamageType=class'KFDT_Bludgeon_MaceAndShield_ShieldHeavy'

	InstantHitDamageTypes(BASH_FIREMODE)=class'KFDT_Bludgeon_MaceAndShield_Bash'
	InstantHitDamage(BASH_FIREMODE)=165 //250

	AssociatedPerkClasses(0)=class'KFPerk_Berserker'

 	// Grenade
	GrenadeFireOffset=(X=25,Y=15) 	

	// Block Sounds
	BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Block_MEL_Hammer'
	ParrySound=AkEvent'WW_WEP_Bullet_Impacts.Play_Parry_Wood'

	// Blocking
	BlockTypes.Add((DmgType=class'KFDT_Fire_HuskFireball', BlockSound=None, ParrySound=None, BlockParticleSys=None, ParryParticleSys=None))
	BlockTypes.Add((DmgType=class'KFDT_Fire_HuskFlamethrower'))
	BlockTypes.Add((DmgType=class'KFDT_EvilDAR_Rocket', BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Bullet_Impact_Metal'))
	BlockTypes.Add((DmgType=class'KFDT_EvilDAR_Laser', BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Bullet_Impact_Metal'))
	BlockTypes.Add((DmgType=class'KFDT_DAR_EMPBlast', BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Bullet_Impact_Metal'))
	BlockTypes.Add((DmgType=class'KFDT_Ballistic_PatMinigun', BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Bullet_Impact_Metal'))
	BlockTypes.Add((DmgType=class'KFDT_Explosive_PatMissile'))
	BlockTypes.Add((DmgType=class'KFDT_Ballistic_HansAK12', BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Bullet_Impact_Metal'))
	BlockTypes.Add((DmgType=class'KFDT_EMP_MatriarchTeslaBlast', BlockSound=AkEvent'WW_WEP_Bullet_Impacts.Play_Bullet_Impact_Metal'))
	ParryDamageMitigationPercent=0.3
	BlockDamageMitigation=0.3//0.5
	ParryStrength=6

	NumBloodMapMaterials=2

	// Weapon Upgrade stat boosts
	//WeaponUpgrades[1]=(IncrementDamage=1.135f,IncrementWeight=1)

	WeaponUpgrades[1]=(Stats=((Stat=EWUS_Damage0, Scale=1.135f), (Stat=EWUS_Damage1, Scale=1.135f), (Stat=EWUS_Damage2, Scale=1.135f), (Stat=EWUS_Weight, Add=1)))
}