//=============================================================================
// KFPerk_Survivalist
//=============================================================================
// The survivalist perk class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================
class KFPerk_Survivalist extends KFPerk
	native;

//`include(KFOnlineStats.uci)

/** Passives */
var private const PerkSkill	WeaponDamage;
var private	const PerkSkill	DamageResistance;
var private	const PerkSkill	HeavyBodyArmor;
var	private	const PerkSkill	ZedTimeReload;

/** Selectable skills */
enum ESurvivalistPerkSkills
{
	ESurvivalist_TacticalReload,
	ESurvivalist_HeavyWeaponsReload,
	ESurvivalist_FieldMedic,
	ESurvivalist_MeleeExpert,
	ESurvivalist_AmmoVest,
	ESurvivalist_BigPockets,
	ESurvivalist_Shrapnel,
	ESurvivalist_MakeThingsGoBoom,
	ESurvivalist_MadMan,
	ESurvivalist_IncapMaster
};

var	const 	int						SecondaryNearKillXPModifier[4];

var private const float 			InjectionPotencyModifier;
var private const float 			MeleeExpertAttackSpeedModifier;
var private const GameExplosion		ShrapnelExplosionTemplate;
var private const float 			ShrapnelChance;
var private const float 			SnarePower;
var private const float 			MeleeExpertMovementSpeedModifier;
var private const float				PassiveWeaponSwitchModifier;

var class<KFWeaponDefinition>		HealingGrenadeWeaponDef;
var class<KFWeaponDefinition>		MolotovGrenadeWeaponDef;

var private const array<class<KFWeaponDefinition> > PrimaryWeaponPaths;
var private const array<string>	KnifeWeaponPaths;
var int StartingWeaponClassIndex;

var private const array<name>		TacticalReloadAsReloadRateClassNames;

/** When MakeThingsGoBoom skill is selected the survivalist gets additional explosive resistance */
var private const float				MakeThingsGoBoomExplosiveResistance;

/*********************************************************************************************
* @name	 Perk init and spawning
******************************************************************************************** */

/** On spawn, modify owning pawn based on perk selection */
function SetPlayerDefaults( Pawn PlayerPawn )
{
	local float NewArmor;

	super.SetPlayerDefaults( PlayerPawn );

	if( OwnerPawn.Role == ROLE_Authority )
	{
		NewArmor = OwnerPawn.default.MaxArmor * GetPassiveValue( HeavyBodyArmor, CurrentLevel );
		OwnerPawn.AddArmor( Round( NewArmor ) );
	}
}

/**
 * @brief(Server) Modify Instigator settings based on selected perk
 */
function ApplyWeightLimits()
{
	local KFInventoryManager KFIM;

	KFIM = KFInventoryManager(OwnerPawn.InvManager);
	if( KFIM != none )
	{
		if( IsBigPocketsActive() )
		{
			`QALog( "Big Pockets Mod" @ GetPercentage(KFIM.MaxCarryBlocks, KFIM.default.MaxCarryBlocks + PerkSkills[ESurvivalist_BigPockets].StartingValue), bLogPerk );
			KFIM.MaxCarryBlocks = KFIM.default.MaxCarryBlocks + GetSkillValue( PerkSkills[ESurvivalist_BigPockets] );
			CheckForOverWeight( KFIM );
		}
		else
		{
			super.ApplyWeightLimits();
		}
	}
}

function bool ShouldGetAllTheXP()
{
	return true;
}


/* Returns the primary weapon's class path for this perk */
simulated function string GetPrimaryWeaponClassPath()
{
	StartingWeaponClassIndex = Rand(PrimaryWeaponPaths.length);
	AutoBuyLoadOutPath.InsertItem(0,PrimaryWeaponPaths[StartingWeaponClassIndex]);
    return PrimaryWeaponPaths[StartingWeaponClassIndex].default.WeaponClassPath;
}

function bool ShouldAutosellWeapon(class<KFWeaponDefinition> DefClass)
{
    //Because survivalists get a random first weapon in their auto buy load out, if they ever swap
    //      to another valid on-perk T1 then attempt to autobuy, they could be left in situations where
    //      they sell the new valid T1, but don't have enough money to buy any other weapons.  In this
    //      case, we shouldn't sell the weapon if it's also part of the primary weapons that they could
    //      start with in a valid match.
    if (super.ShouldAutosellWeapon(DefClass))
    {
        return PrimaryWeaponPaths.Find(DefClass) == INDEX_NONE;
    }

    return false;
}

/*********************************************************************************************
* @name	 Passives
******************************************************************************************** */
/**
 * @brief Modifies the damage dealt
  *
 * @param InDamage damage
 * @param DamageCauser weapon or projectile (optional)
 * @param MyKFPM the zed damaged (optional)
 * @param DamageInstigator responsible controller (optional)
 * @param class DamageType the damage type used (optional)
 */
simulated function ModifyDamageGiven( out int InDamage, optional Actor DamageCauser, optional KFPawn_Monster MyKFPM, optional KFPlayerController DamageInstigator, optional class<KFDamageType> DamageType, optional int HitZoneIdx )
{
	local KFWeapon KFW;
	local float TempDamage;

	TempDamage = InDamage;
	TempDamage += InDamage * GetPassiveValue( WeaponDamage, CurrentLevel );

	if( DamageCauser != none )
	{
		KFW = GetWeaponFromDamageCauser( DamageCauser );
	}

	if( KFW != none )
	{
		if( KFW.IsMeleeWeapon() && IsMeleeExpertActive() )
		{
			TempDamage +=  InDamage * GetSkillValue( PerkSkills[ESurvivalist_MeleeExpert] );
		}
	}

	`QALog( "Total Damage Given" @ DamageType @ KFW @ GetPercentage( InDamage, Round(TempDamage) ), bLogPerk );
	InDamage = Round(TempDamage);
}

/**
 * @brief Modifies the damage taken
 *
 * @param InDamage damage
 * @param DamageType the damage type used (optional)
 */
function ModifyDamageTaken( out int InDamage, optional class<DamageType> DamageType, optional Controller InstigatedBy )
{
	local float TempDamage;

	if( InDamage <= 0 )
	{
		return;
	}

	TempDamage = InDamage;
	TempDamage -= InDamage * GetPassiveValue( DamageResistance, CurrentLevel );
	if (IsMakeThingsGoBoomActive())
	{
		// only for explosive damage
		if (ClassIsChildOf(DamageType, class'KFDT_Explosive'))
		{
			TempDamage = FMax(TempDamage - InDamage * MakeThingsGoBoomExplosiveResistance, 0.0f);
		}
	}

	`QALog( "Total DamageResistance" @ DamageType @ GetPercentage( InDamage, Round( TempDamage ) ) @ "Start/End" @ InDamage @ Round( TempDamage ), bLogPerk );
	InDamage = Round( TempDamage );
}

/**
 * @brief Some perk skills modify the melee attack speed
 *
 * @param InDuration delay in between attacks
 */
simulated function ModifyMeleeAttackSpeed( out float InDuration, KFWeapon KFW )
{
	local float TempDuration;

	if( KFW == none || !KFW.IsMeleeWeapon() )
	{
		return;
	}

	TempDuration = InDuration;

	if( IsMeleeExpertActive() )
	{
		TempDuration -= TempDuration * static.GetMeleeExpertAttackSpeedModifier();
	}

	`QALog( "Total, Melee Attack Speed" @ GetPercentage( InDuration, TempDuration ) @ "Start/End" @ InDuration @ TempDuration, bLogPerk );
	InDuration = TempDuration;
}

/**
 * @brief Weapons and perk skills can affect the jog/sprint speed
 *
 * @param Speed jog/sprint speed
  */
simulated function ModifySpeed( out float Speed )
{
	local float TempSpeed;
	local KFWeapon KFW;


	if( IsMeleeExpertActive() )
	{
		KFW = GetOwnerWeapon();
		if( KFW != none && KFW.IsMeleeWeapon() )
		{
			TempSpeed = Speed + Speed * static.GetMeleeExpertMovementSpeedModifier();
			Speed = TempSpeed;
		}
	}
}

simulated private static function float GetMeleeExpertMovementSpeedModifier()
{
	return default.MeleeExpertMovementSpeedModifier;
}

simulated private static function float GetMeleeExpertAttackSpeedModifier()
{
	return default.MeleeExpertAttackSpeedModifier;
}

simulated function bool HasHeavyArmor()
{
	return true;
}

/**
 * @brief Modifies the reload speed for commando weapons
 *
 * @param ReloadDuration Length of the reload animation
 * @param GiveAmmoTime Time after the weapon actually gets some ammo
 */
simulated function float GetReloadRateScale( KFWeapon KFW )
{
	if( WorldInfo.TimeDilation < 1.f && IsZedTimeReloadAllowed() )
	{
		return 1.f -  GetPassiveValue( ZedTimeReload, GetLevel() );
	}

	if (((IsTacticalReloadActive() && IsWeaponOnPerkLight(KFW)) ||
		(IsHeavyReloadActive() && IsWeaponOnPerkHeavy(KFW)))
		&& TacticalReloadAsReloadRateClassNames.Find(KFW.class.Name) != INDEX_NONE)
	{
		return 0.8f;
	}

	return 1.f;
}

/**
* @brief For modes that disable zed time skill tiers, also disable zed time reload
*/
simulated function bool IsZedTimeReloadAllowed()
{
    return MyKFGRI != none ? (MyKFGRI.MaxPerkLevel == MyKFGRI.default.MaxPerkLevel) : false;
}

/**
 * @brief Modifies the pawn's MaxArmor
 *
 * @param MaxArmor the maximum armor value
 */
function ModifyArmor( out byte MaxArmor )
{
	local float TempArmor;

	if( HasHeavyArmor() )
	{
		TempArmor = MaxArmor;
		TempArmor += MaxArmor * GetPassiveValue( HeavyBodyArmor, CurrentLevel );
		MaxArmor = Round( TempArmor );
	}
}

/**
 * @brief The passive skill of the survivalist modifies the weapon switch speed
 *
 * @param ModifiedSwitchTime Duration of putting down or equipping the weapon
 */
simulated function ModifyWeaponSwitchTime( out float ModifiedSwitchTime )
{
	`QALog( "(Passive Weapon Switch) Increase:" @ GetPercentage( ModifiedSwitchTime,  ModifiedSwitchTime * (1.f - static.GetPassiveWeaponSwitchModifier()) ), bLogPerk );
	ModifiedSwitchTime *= 1.f - static.GetPassiveWeaponSwitchModifier();
}

simulated final static function float GetPassiveWeaponSwitchModifier()
{
	return default.PassiveWeaponSwitchModifier;
}

/*********************************************************************************************
* @name	 Selectable skills functions
********************************************************************************************* */

/**
 * @brief Should the tactical reload skill adjust the reload speed
 *
 * @param KFW weapon in use
 * @return true/false
 */
simulated function bool GetUsingTactialReload( KFWeapon KFW )
{
	return (((IsTacticalReloadActive() && IsWeaponOnPerkLight(KFW)) ||
			(IsHeavyReloadActive() && IsWeaponOnPerkHeavy(KFW))) &&
		    TacticalReloadAsReloadRateClassNames.Find(KFW.class.Name) == INDEX_NONE);
}

simulated function bool IsWeaponOnPerkLight( KFWeapon KFW )
{
	if( KFW != none )
	{
		return (class'KFPerk_Commando'.static.IsWeaponOnPerk( KFW,, class'KFPerk_Commando' ) ||
				class'KFPerk_Gunslinger'.static.IsWeaponOnPerk( KFW,, class'KFPerk_Gunslinger' ) ||
				class'KFPerk_SWAT'.static.IsWeaponOnPerk( KFW,, class'KFPerk_SWAT' ));
	}

	return false;
}

simulated function bool IsWeaponOnPerkHeavy( KFWeapon KFW )
{
	if( KFW != none )
	{
		return (class'KFPerk_Demolitionist'.static.IsWeaponOnPerk( KFW,, class'KFPerk_Demolitionist' ) ||
				class'KFPerk_Support'.static.IsWeaponOnPerk( KFW,, class'KFPerk_Support' ) ||
				class'KFPerk_Sharpshooter'.static.IsWeaponOnPerk( KFW,, class'KFPerk_Sharpshooter' ) ||
				KFW.IsA('KFPerk_Survivalist') ||
				(KFW.IsHeavyWeapon() && IsWeaponOnPerk(KFW)) );
	}


	return false;
}

/**
 * @brief Modifies how long one recharge cycle takes
 *
 * @param RechargeRate charging rate per sec
  */
simulated function ModifyHealerRechargeTime( out float RechargeRate )
{
    if( IsFieldMedicActive() )
    {
    	RechargeRate -= RechargeRate * GetSkillValue(  PerkSkills[ESurvivalist_FieldMedic] );
    }
}

/**
 * @brief Modifies how potent one healing shot is
 *
 * @param HealAmount health repaired
 * @return true if Armament is active to repair armor if possible
 */
function bool ModifyHealAmount( out float HealAmount )
{
	 if( IsFieldMedicActive() )
    {
		HealAmount *= static.GetInjectionPotencyModifier();
	}

	return IsFieldMedicActive();
}

static private function float GetInjectionPotencyModifier()
{
	return default.InjectionPotencyModifier;
}

/**
 * @brief Modifies the max spare ammo
 *
 * @param KFW The weapon
 * @param MaxSpareAmmo ammo amount
 * @param TraderItem the weapon's associated trader item info
 */
simulated function ModifyMaxSpareAmmoAmount( KFWeapon KFW, out int MaxSpareAmmo, optional const out STraderItem TraderItem, optional bool bSecondary=false )
{
	local bool bUsesAmmo;
	local float TempMaxSpareAmmoAmount;

	bUsesAmmo = (KFW == none) ? TraderItem.WeaponDef.static.UsesAmmo() : KFW.UsesAmmo();
	if( IsAmmoVestActive() && bUsesAmmo )
	{
		TempMaxSpareAmmoAmount = MaxSpareAmmo;
		TempMaxSpareAmmoAmount += MaxSpareAmmo * GetSkillValue( PerkSkills[ESurvivalist_AmmoVest] );
		MaxSpareAmmo = Round( TempMaxSpareAmmoAmount );
	}
}

/**
 * @brief Checks if a zed could potentially explode later
 *
 * @param KFDT damage type used to deal damage
 * @return if the zed could explode when dying
 */
function bool CouldBeZedShrapnel( class<KFDamageType> KFDT )
{
	return IsZedShrapnelActive();
}

/**
 * @brief The Zed shrapnel skill can spawn an explosion, this function delivers the template
 *
 * @return A game explosion template
 */
function GameExplosion GetExplosionTemplate()
{
	return default.ShrapnelExplosionTemplate;
}

/**
 * @brief Checks if a Zed should explode
 *
 * @return explode or not
 */
simulated function bool ShouldShrapnel()
{
	return IsZedShrapnelActive() && fRand() <= default.ShrapnelChance;
}

simulated function float GetAoERadiusModifier()
{
	return IsMakeThingsGoBoomActive() ? GetSkillValue( PerkSkills[ESurvivalist_MakeThingsGoBoom] ) : 1.f;
}

/**
 * @brief Skills can modify the zed time time delation
 *
 * @param W used weapon
 * @return time dilation modifier
 */
simulated function float GetZedTimeModifier( KFWeapon W )
{
	local name StateName;
	if( GetMadManActive() && (!W.IsMeleeWeapon() || KFWeap_MeleeBase(W).default.bHasToBeConsideredAsRangedWeaponForPerks || IsBlastBrawlers(W) ))
	{
		StateName = W.GetStateName();
		`Warn(StateName);
		
		// Blast Brawlers use a different state for shooting (combining melee + firing). Needs a special case for this
		// FAMAS uses alt fire as common firing. Another special case added 
		if( ZedTimeModifyingStates.Find( StateName ) != INDEX_NONE ||
			 (StateName == 'MeleeChainAttacking' && IsBlastBrawlers(W)) ||
			 (StateName == 'FiringSecondaryState' && IsFAMAS(W)))
		{
			return GetSkillValue( PerkSkills[ESurvivalist_MadMan] );
		}
	}

	return 0.f;
}

/**
 * @brief Specific modifier for the Minigun Windup rotation
 *
 * @return time dilation modifier
 */
simulated function float GetZedTimeModifierForWindUp()
{
	if( GetMadManActive() )
	{
		return GetSkillValue( PerkSkills[ESurvivalist_MadMan] );
	}

	return 0.f;
}

/**
 * @brief Skills can can change the knock down power
 * @return knock down power in %
 */
function float GetKnockdownPowerModifier( optional class<DamageType> DamageType, optional byte BodyPart, optional bool bIsSprinting=false )
{
	if( GetIncapMasterActive() )
	{
		`QALog( "LimbShots knockdown, Hit" @ BodyPart @ GetSkillValue( PerkSkills[ESurvivalist_IncapMaster] ), bLogPerk );
		//[FFERRANDO @ SABER3D] INCAP MASTER NOW ONLY MODIFIES STUN POWER
		return 0;
		//return GetSkillValue( PerkSkills[ESurvivalist_IncapMaster] );
	}

	return 0.f;
}

/**
 * @brief skills and weapons can modify the stumbling power
 * @return stumpling power modifier
 */
function float GetStumblePowerModifier( optional KFPawn KFP, optional class<KFDamageType> DamageType, optional out float CooldownModifier, optional byte BodyPart )
{
	if( GetIncapMasterActive() )
	{
		`QALog( "CenterMass Stumble, Hit" @ BodyPart @ GetSkillValue( PerkSkills[ESurvivalist_IncapMaster] ), bLogPerk );
		//[FFERRANDO @ SABER3D] INCAP MASTER NOW ONLY MODIFIES STUN POWER
		return 0;
        //return GetSkillValue( PerkSkills[ESurvivalist_IncapMaster] );
	}

	return 0.f;
}

/**
 * @brief skills and weapons can guarantee a stun
 * @return true/false
 */
function bool IsStunGuaranteed( optional class<DamageType> DamageType, optional byte HitZoneIdx )
{
	if( GetIncapMasterActive() )
	{
		return true;
	}

    return false;
}

simulated function float GetSnarePowerModifier( optional class<DamageType> DamageType, optional byte HitZoneIdx )
{
	if( GetIncapMasterActive() )
	{
		return default.SnarePower;
	}

	return 0.f;
}

/* Returns the grenade class for this perk */
simulated function class< KFProj_Grenade > GetGrenadeClass()
{
    if( IsAmmoVestActive() )
    {
    	return class<KFProj_Grenade>(DynamicLoadObject(HealingGrenadeWeaponDef.default.WeaponClassPath, class'Class'));
    }
    else if( IsBigPocketsActive() )
    {
		return class<KFProj_Grenade>(DynamicLoadObject(MolotovGrenadeWeaponDef.default.WeaponClassPath, class'Class'));
    }

    return GrenadeClass;
}

/**
 * @brief Gets the small radius kill xp based on the difficulty
 *
 * @param Difficulty game difficulty
 * @return XP
 */
static function int GetSmallRadiusKillXP( byte Difficulty )
{
	return default.SecondaryNearKillXPModifier[Difficulty];
}

/**
 * @brief can the perk earn small radius kill xp
 * @return DT is on berserker perk
 */
function bool CanEarnSmallRadiusKillXP(class<DamageType> DT)
{
	return class'KFPerk_Berserker'.static.IsDamageTypeOnPerk(class<KFDamageType>(DT)) ||
		   class'KFPerk_Berserker'.static.IsBackupDamageTypeOnPerk(DT);
}

/*********************************************************************************************
* @name	 Getters etc
********************************************************************************************* */
/**
 * @brief Checks if tactical reload skill is active (client & server)
 *
 * @return true/false
 */
simulated private function bool IsTacticalReloadActive()
{
	return PerkSkills[ESurvivalist_TacticalReload].bActive && IsPerkLevelAllowed(ESurvivalist_TacticalReload);
}

/**
 * @brief Checks if the heavy weapons reload skill is active (client & server)
 *
 * @return true/false
 */
simulated private function bool IsHeavyReloadActive()
{
	return PerkSkills[ESurvivalist_HeavyWeaponsReload].bActive && IsPerkLevelAllowed(ESurvivalist_HeavyWeaponsReload);
}

/**
 * @brief Checks if Field Medic skill is active
 *
 * @return true/false
 */
simulated private function bool IsFieldMedicActive()
{
	return PerkSkills[ESurvivalist_FieldMedic].bActive && IsPerkLevelAllowed(ESurvivalist_FieldMedic);
}

/**
 * @brief Checks if Melee Expert skill is active
 *
 * @return true/false
 */
simulated private function bool IsMeleeExpertActive()
{
	return PerkSkills[ESurvivalist_MeleeExpert].bActive && IsPerkLevelAllowed(ESurvivalist_MeleeExpert);
}

/**
 * @brief Checks if Big Pockets skill is active
 *
 * @return true/false
 */
simulated private function bool IsAmmoVestActive()
{
	return PerkSkills[ESurvivalist_AmmoVest].bActive && IsPerkLevelAllowed(ESurvivalist_AmmoVest);
}

/**
 * @brief Checks if Big Pockets skill is active
 *
 * @return true/false
 */
simulated private function bool IsBigPocketsActive()
{
	return PerkSkills[ESurvivalist_BigPockets].bActive && IsPerkLevelAllowed(ESurvivalist_BigPockets);
}

/**
 * @brief Checks if Big Pockets skill is active
 *
 * @return true/false
 */
simulated private function bool IsZedShrapnelActive()
{
	return PerkSkills[ESurvivalist_Shrapnel].bActive && IsPerkLevelAllowed(ESurvivalist_Shrapnel);
}

/**
 * @brief Checks if Big Pockets skill is active
 *
 * @return true/false
 */
simulated private function bool IsMakeThingsGoBoomActive()
{
	return PerkSkills[ESurvivalist_MakeThingsGoBoom].bActive && IsPerkLevelAllowed(ESurvivalist_MakeThingsGoBoom);
}

/**
 * @brief Checks if the Madman skill is active and if we are in zed time
 *
 * @return true/false
 */
simulated function bool GetMadManActive()
{
	return IsMadManActive() && WorldInfo.TimeDilation < 1.f;
}

/**
 * @brief Checks if Big Pockets skill is active
 *
 * @return true/false
 */
simulated private function bool IsMadManActive()
{
	return PerkSkills[ESurvivalist_MadMan].bActive && IsPerkLevelAllowed(ESurvivalist_MadMan);
}

/**
 * @brief Checks if the Incap Master skill is active and if we are in zed time
 *
 * @return true/false
 */
simulated function bool GetIncapMasterActive()
{
	return IsIncapMasterActive() && WorldInfo.TimeDilation < 1.f;
}

/**
 * @brief Checks if Incap Master skill is active
 *
 * @return true/false
 */
simulated private function bool IsIncapMasterActive()
{
	return PerkSkills[ESurvivalist_IncapMaster].bActive && IsPerkLevelAllowed(ESurvivalist_IncapMaster);
}

/*********************************************************************************************
* @name	 Hud/UI/Stats/Exp
********************************************************************************************* */

/**
 * @brief how much XP is earned by a clot kill depending on the game's difficulty
 *
 * @param Difficulty current game difficulty
 * @return XP earned
 */
simulated static function int GetClotKillXP( byte Difficulty )
{
	return default.SecondaryXPModifier[Difficulty];
}

simulated static function GetPassiveStrings( out array<string> PassiveValues, out array<string> Increments, byte Level )
{
	PassiveValues[0] = Left( string(GetPassiveValue( default.WeaponDamage, Level ) * 100 ), InStr(string(GetPassiveValue( default.WeaponDamage, Level ) * 100 ), ".") + 2 ) $ "%";
	PassiveValues[1] = Round( GetPassiveValue( default.DamageResistance, Level ) * 100 ) $ "%";
	PassiveValues[2] = Round( GetPassiveValue( default.HeavyBodyArmor, Level ) * 100 ) $ "%";
	PassiveValues[3] = Round( GetPassiveValue( default.ZedTimeReload, Level ) * 100 ) $ "%";
	PassiveValues[4] = "";

	Increments[0] = "[" @ Left( string( default.WeaponDamage.Increment * 100 ), 	InStr(string(default.WeaponDamage.Increment * 100), ".") + 2 ) 		$ "% /" @ default.LevelString @ "]";
	Increments[1] = "[" @ Left( string( default.DamageResistance.Increment * 100 ), InStr(string(default.DamageResistance.Increment * 100), ".") + 2 ) 	$ "% /" @ default.LevelString @ "]";
	Increments[2] = "[" @ Left( string( default.HeavyBodyArmor.Increment * 100 ),	InStr(string(default.HeavyBodyArmor.Increment * 100), ".") + 2 ) 	$ "% /" @ default.LevelString @ "]";
	Increments[3] = "[" @ Left( string( default.ZedTimeReload.Increment * 100 ),	InStr(string(default.ZedTimeReload.Increment * 100), ".") + 2 ) 	$ "% /" @ default.LevelString @ "]";
	Increments[4] = "";
}

simulated function string GetGrenadeImagePath()
{
	if( IsAmmoVestActive() )
    {
		return default.HealingGrenadeWeaponDef.Static.GetImagePath();
    }
    else if( IsBigPocketsActive() )
    {
		return default.MolotovGrenadeWeaponDef.Static.GetImagePath();
	}

	return default.GrenadeWeaponDef.Static.GetImagePath();
}


simulated function class<KFWeaponDefinition> GetGrenadeWeaponDef()
{
	if( IsAmmoVestActive() )
    {
		return default.HealingGrenadeWeaponDef;
    }
    else if( IsBigPocketsActive() )
    {
		return default.MolotovGrenadeWeaponDef;
	}

	return default.GrenadeWeaponDef;
}

DefaultProperties
{
	StartingWeaponClassIndex=Index_None
	PerkIcon=Texture2D'UI_PerkIcons_TEX.UI_PerkIcon_Survivalist'

	PrimaryWeaponDef=class'KFWeapDef_Random'
	KnifeWeaponDef=class'KFweapDef_Knife_Survivalist'
	GrenadeWeaponDef=class'KFWeapDef_Grenade_Commando'
	HealingGrenadeWeaponDef=class'KFWeapDef_Grenade_Medic'
	MolotovGrenadeWeaponDef=class'KFWeapDef_Grenade_Firebug'

	ProgressStatID=STATID_Surv_Progress
   	PerkBuildStatID=STATID_Surv_Build

	WeaponDamage=(Name="Weapon Damage",Increment=0.006f,Rank=0,StartingValue=0.f,MaxValue=0.15f)
	DamageResistance=(Name="Damage Resistance",Increment=0.01,Rank=0,StartingValue=0.f,MaxValue=0.25)
	HeavyBodyArmor=(Name="Heavy Body Armor",Increment=0.01,Rank=0,StartingValue=0.f,MaxValue=0.25)
   	ZedTimeReload=(Name="Zed Time Reload",Increment=0.03f,Rank=0,StartingValue=0.f,MaxValue=0.75f)

   	PassiveWeaponSwitchModifier=0.35f

 	PerkSkills(ESurvivalist_TacticalReload)=(Name="TacticalReload",IconPath="UI_PerkTalent_TEX.Survivalist.UI_Talents_Survivalist_TacticalReload", Increment=0.f,Rank=0,StartingValue=0.25,MaxValue=0.25)
	PerkSkills(ESurvivalist_HeavyWeaponsReload)=(Name="HeavyWeaponsReload",IconPath="UI_PerkTalent_TEX.Survivalist.UI_Talents_Survivalist_HeavyWeapons", Increment=0.f,Rank=0,StartingValue=2.5f,MaxValue=2.5f)
	PerkSkills(ESurvivalist_FieldMedic)=(Name="FieldMedic",IconPath="UI_PerkTalent_TEX.Survivalist.UI_Talents_Survivalist_FieldMedic", Increment=0.f,Rank=0,StartingValue=0.5f,MaxValue=0.5f)
	PerkSkills(ESurvivalist_MeleeExpert)=(Name="MeleeExpert",IconPath="UI_PerkTalent_TEX.Survivalist.UI_Talents_Survivalist_MeleeExpert", Increment=0.f,Rank=0,StartingValue=0.75f,MaxValue=0.75f) //0.5f
	PerkSkills(ESurvivalist_AmmoVest)=(Name="AmmoVest",IconPath="UI_PerkTalent_TEX.Survivalist.UI_Talents_Survivalist_AmmoVest", Increment=0.f,Rank=0,StartingValue=0.15f,MaxValue=0.15f)
	PerkSkills(ESurvivalist_BigPockets)=(Name="BigPockets",IconPath="UI_PerkTalent_TEX.Survivalist.UI_Talents_Survivalist_BigPockets", Increment=0.f,Rank=0,StartingValue=5.f,MaxValue=5.f)
	PerkSkills(ESurvivalist_Shrapnel)=(Name="ZedShrapnel",IconPath="UI_PerkTalent_TEX.Survivalist.UI_Talents_Survivalist_Shrapnel", Increment=0.f,Rank=0,StartingValue=2.f,MaxValue=2.f)
	PerkSkills(ESurvivalist_MakeThingsGoBoom)=(Name="MakeThingsGoBoom",IconPath="UI_PerkTalent_TEX.Survivalist.UI_Talents_Survivalist_Boom", Increment=0.f,Rank=0,StartingValue=1.5f,MaxValue=1.5f) //1.4f
	PerkSkills(ESurvivalist_MadMan)=(Name="MadMan",IconPath="UI_PerkTalent_TEX.Survivalist.UI_Talents_Survivalist_Madman", Increment=0.f,Rank=0,StartingValue=0.5f,MaxValue=0.5f)
	PerkSkills(ESurvivalist_IncapMaster)=(Name="IncapMaster",IconPath="UI_PerkTalent_TEX.Survivalist.UI_Talents_Survivalist_IncapMaster", Increment=0.f,Rank=0,StartingValue=5000.0f,MaxValue=5000.0f)
	
	SecondaryXPModifier(0)=2
	SecondaryXPModifier(1)=3
	SecondaryXPModifier(2)=4
	SecondaryXPModifier(3)=7

	SecondaryNearKillXPModifier(0)=6
	SecondaryNearKillXPModifier(1)=8
	SecondaryNearKillXPModifier(2)=10
	SecondaryNearKillXPModifier(3)=14

	InjectionPotencyModifier=1.3f
	MeleeExpertAttackSpeedModifier=0.2f
	ShrapnelChance=0.3f
	SnarePower=20
	MeleeExpertMovementSpeedModifier=0.25

	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=50  //231  //120
		DamageRadius=250   //840  //600
		DamageFalloffExponent=1
		DamageDelay=0.f
		MyDamageType=class'KFDT_Explosive_Shrapnel'

		// Damage Effects
		//KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'FX_Explosions_ARCH.FX_Combustion_Explosion'
		ExplosionSound=AkEvent'WW_WEP_EXP_Grenade_Frag.Play_WEP_EXP_Grenade_Frag_Explosion'

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Misc_Explosions.Light_Explosion_Rumble'
		CamShakeInnerRadius=450
		CamShakeOuterRadius=900
		CamShakeFalloff=1.f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	ShrapnelExplosionTemplate=ExploTemplate0

   	ZedTimeModifyingStates(0)="WeaponFiring"
   	ZedTimeModifyingStates(1)="WeaponBurstFiring"
   	ZedTimeModifyingStates(2)="WeaponSingleFiring"
   	ZedTimeModifyingStates(3)="WeaponSingleFireAndReload"
   	ZedTimeModifyingStates(4)="SprayingFire"
    ZedTimeModifyingStates(5)="WeaponAltFiring"
	ZedTimeModifyingStates(6)="HuskCannonCharge"
	ZedTimeModifyingStates(7)="CompoundBowCharge"
	ZedTimeModifyingStates(8)="BlunderbussDeployAndDetonate"
	ZedTimeModifyingStates(9)="WeaponWindingUp"
	ZedTimeModifyingStates(10)="MineReconstructorCharge"
	ZedTimeModifyingStates(11)="WeaponSonicGunSingleFiring"
	ZedTimeModifyingStates(12)="WeaponSonicGunCharging"

   	PrimaryWeaponPaths(0)=class'KFWeapDef_AR15'
   	PrimaryWeaponPaths(1)=class'KFWeapDef_MB500'
   	PrimaryWeaponPaths(2)=class'KFWeapDef_Crovel'
   	PrimaryWeaponPaths(3)=class'KFWeapDef_HX25'
   	PrimaryWeaponPaths(4)=class'KFWeapDef_MedicPistol'
   	PrimaryWeaponPaths(5)=class'KFWeapDef_CaulkBurn'
   	PrimaryWeaponPaths(6)=class'KFWeapDef_Remington1858Dual'
   	PrimaryWeaponPaths(7)=class'KFWeapDef_Winchester1894'
   	PrimaryWeaponPaths(8)=class'KFWeapDef_MP7'
   	AutoBuyLoadOutPath=(class'KFWeapDef_DragonsBreath', class'KFWeapDef_FreezeThrower', class'KFWeapDef_MedicRifle', class'KFWeapDef_LazerCutter')

   	// Prestige Rewards
	PrestigeRewardItemIconPaths[0]="WEP_SkinSet_Prestige01_Item_TEX.knives.SurvivalistKnife_PrestigePrecious_Mint_large"
	PrestigeRewardItemIconPaths[1]="WEP_SkinSet_Prestige02_Item_TEX.tier01.FreezeThrower_PrestigePrecious_Mint_large"
	PrestigeRewardItemIconPaths[2]="WEP_skinset_prestige03_itemtex.tier02.TommyGun_PrestigePrecious_Mint_large"
	PrestigeRewardItemIconPaths[3]="wep_skinset_prestige04_itemtex.tier03.VLAD-1000Nailgun_PrestigePrecious_Mint_large"
	PrestigeRewardItemIconPaths[4]="WEP_SkinSet_Prestige05_Item_TEX.tier04.Killerwatt_PrestigePrecious_Mint_large"

	TacticalReloadAsReloadRateClassNames(0)="KFWeap_GrenadeLauncher_M32"

	MakeThingsGoBoomExplosiveResistance=0.5f //0.4f
}
