//=============================================================================
// KFAfflictionManager
//=============================================================================
// Handles negative status effects that can be applied to a KFPawn
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFAfflictionManager extends Object within KFPawn
	native(Pawn);

const STUN_GUARANTEED_POWER = 10000.f;

/** Abstracted body parts that can be associated with multiple zones */
enum EHitZoneBodyPart
{
	BP_Torso, // default to generic body shot
	BP_Head,
	BP_LeftArm,
	BP_RightArm,
	BP_LeftLeg,
	BP_RightLeg,
	BP_Special,
};

/** Index into IncapSettingsInfo.Vulnerability[] */
enum EAfflictionVulnerabilityType
{
	AV_Default,
	AV_Head,
	AV_Legs,
	AV_Arms,
	AV_Special,
};

/*********************************************************************************************
 * Affliction Classes
 ********************************************************************************************* */

/**
 * Full body incap with stackable IncapPower
 * @todo: this data is now all static and should be moved to an archetype or to KFAffliction
 */
struct native IncapSettingsInfo
{
	/** How long this incap lasts once triggered.  Only applies to non-specialmove entries */
	var() float Duration;
	/** How long this pawn is immune to additional incap of this type.  If > 0, resets strength to zero on activation */
	var() float Cooldown;
	/** How long this pawn is immune to additional incap of children of this type */
	var() float ChildAfflictionCooldown;

	/** Array mapped to EHitZoneBodyPart.  If out of bounds default to body (index 0) */
	var() array<float> Vulnerability;

	structdefaultproperties
	{
        Duration=5.0
	}
};

/* Types of stacking afflictions that are used to index the IncapSettings array */
enum EAfflictionType
{
	/** Place most common afflictions at top because array will resize up to the enum value */

	/** All Pawns */
	AF_EMP,
	AF_FirePanic,

	/** hit reactions (flinch) */
	AF_MeleeHit,
	AF_GunHit,

	/** common  */
	AF_Stumble,
	AF_Stun,
	AF_Poison,
	AF_Snare,

	/** uncommon */
	AF_Knockdown,
	AF_Freeze,
	AF_Microwave,
    AF_Bleed,

	AF_Custom1,
	AF_Custom2,
	AF_Custom3,

	/** Dummy entry to avoid AF_MAX native collision */
	EAfflictionType_Blank
};

/** Assign relevant class to each affliction corresponding to EAfflictionType */
var array< class<KFAfflictionBase> > 	AfflictionClasses;

/** Intanced affliction one per EAfflictionType that remain for the Pawn's lifespawn */
var array<KFAfflictionBase>				Afflictions;
/** Afflictions that need updating each tick (e.g. Fire Panic) */
var array<KFAfflictionBase>				AfflictionTickArray;

/** Debugging */
var bool bDebugLog;

/*********************************************************************************************
 * Specific settings that have not been fully converted to the new system
 ********************************************************************************************* */

/** How long does a pawn have to be burning over the heat threshhold to get to fully charred skin */
var float     FireFullyCharredDuration;
/** When over this % on the FirePanicResist.StackedPower, apply charring to the skin shader. Think of it like how "hot" the character needs to get before its shader gets char applied */
var float     FireCharPercentThreshhold;

cpptext
{
	/** Stacking afflictions must decay Power and check if Duration is over.  This is done
	 * in c++ for speed, but could be done in script for custom afflictions */

	/** SERVER ONLY - Clears or stacked incap effects when they need to be deactivated */
	virtual void TickStackedIncapEffects(FLOAT DeltaTime, AKFPawn* P);
}

/*********************************************************************************************
* @name		Take Damage
********************************************************************************************* */

/** Check, and if needed activate afflictions after being hit (Server only) */
function NotifyTakeHit(Controller DamageInstigator, vector HitDir, class<KFDamageType> DamageType, Actor DamageCauser)
{
	local KFPerk InstigatorPerk;
	
	if( DamageType == none )
	{
		return;
	}
	
	// Allow damage instigator perk to modify reaction
	if ( DamageInstigator != None && DamageInstigator.bIsPlayer )
	{
		InstigatorPerk = KFPlayerController(DamageInstigator).GetPerk();
	}

    // For now all below effects are for Zeds
    if( GetTeamNum() > 254 && !bPlayedDeath )
    {
        ProcessSpecialMoveAfflictions(InstigatorPerk, HitDir, DamageType, DamageCauser);
        ProcessHitReactionAfflictions(InstigatorPerk, DamageType, DamageCauser);
    }

    ProcessEffectBasedAfflictions(InstigatorPerk, DamageType, DamageCauser);
}

/**
 * Client side test to predict whether or not DoPauseAI is called.  May not always
 * be correct but as long as we use split-body anims it will still look okay
 * @note: With the new cumulative system this is completely artificial
 */
function byte GetPredictedHitReaction(class<KFDamageType> DamageType, EHitZoneBodyPart BodyPart)
{
	// This may not always match the server's result, but as long
	// as we avoid playing FullBody anims it should look okay even if DoPauseAI is skipped.
	if ( DamageType.default.MeleeHitPower > 0 )
	{
		return HIT_Heavy;
	}
	else if ( DamageType.default.GunHitPower > 0 )
	{
		return HIT_Medium;
	}

	return HIT_Light;
}

/*********************************************************************************************
* @name		Internal (On Hit)
********************************************************************************************* */

/** Reaction based afflictions only apply to living pawns */
protected function ProcessSpecialMoveAfflictions(KFPerk InstigatorPerk, vector HitDir, class<KFDamageType> DamageType, Actor DamageCauser)
{
	local EHitZoneBodyPart BodyPart;
	local byte HitZoneIdx;
	local float KnockdownPower, StumblePower, StunPower, SnarePower, FreezePower;
    local float KnockdownModifier, StumbleModifier, StunModifier;
    local KFInterface_DamageCauser KFDmgCauser;
	local KFWeapon DamageWeapon;

	// This is for damage over time, DoT shall never have momentum
	if (IsZero(HitDir))
	{
		return;
	}

	// HitZoneIdx = HitFxInfo.HitBoneIndex;
	HitZoneIdx = LastHitZoneIndex;

	BodyPart = (HitZoneIdx != 255 && HitZoneIdx < HitZones.Length) ? HitZones[HitZoneIdx].Limb : BP_Torso;

	// Get upgraded affliction power
	DamageWeapon = class'KFPerk'.static.GetWeaponFromDamageCauser(DamageCauser);
	if (DamageWeapon != none)
	{
		KnockdownPower = DamageWeapon.GetUpgradedAfflictionPower(AF_Knockdown, DamageType.default.KnockdownPower);
		StumblePower = DamageWeapon.GetUpgradedAfflictionPower(AF_Stumble, DamageType.default.StumblePower);
		StunPower = DamageWeapon.GetUpgradedAfflictionPower(AF_Stun, DamageType.default.StunPower);
		SnarePower = DamageWeapon.GetUpgradedAfflictionPower(AF_Snare, DamageType.default.SnarePower);
		FreezePower = DamageWeapon.GetUpgradedAfflictionPower(AF_Freeze, DamageType.default.FreezePower);
	}
	else
	{
		KnockdownPower = DamageType.default.KnockdownPower;
		StumblePower = DamageType.default.StumblePower;
		StunPower = DamageType.default.StunPower;
		SnarePower = DamageType.default.SnarePower;
		FreezePower = DamageType.default.FreezePower;
	}

    KFDmgCauser = KFInterface_DamageCauser(DamageCauser);
    if (KFDmgCauser != None)
    {
        KnockdownPower *= KFDmgCauser.GetIncapMod();
        StumblePower *= KFDmgCauser.GetIncapMod();
        StunPower *= KFDmgCauser.GetIncapMod();
        SnarePower *= KFDmgCauser.GetIncapMod();
    }

    KnockdownModifier = 1.f;
    StumbleModifier = 1.f;
    StunModifier = 1.f;

    // Allow for known afflictions to adjust reaction
    KnockdownModifier += GetAfflictionKnockdownModifier();
    StumbleModifier += GetAfflictionStumbleModifier();
    StunModifier += GetAfflictionStunModifier();

	// Allow damage instigator perk to modify reaction
    if (InstigatorPerk != None)
    {
        KnockdownModifier += InstigatorPerk.GetKnockdownPowerModifier( DamageType, BodyPart, bIsSprinting );
        StumbleModifier += InstigatorPerk.GetStumblePowerModifier( Outer, DamageType,, BodyPart );
        StunModifier += InstigatorPerk.GetStunPowerModifier( DamageType, HitZoneIdx );

        //Snare power doesn't scale DT, it exists on its own (Ex: Gunslinger Skullcracker)
        SnarePower += InstigatorPerk.GetSnarePowerModifier( DamageType, HitZoneIdx );
    }

    KnockdownPower *= KnockdownModifier;
    StumblePower *= StumbleModifier;
    StunPower *= StunModifier;

	// [RMORENO @ SABER3D] //Overriding stun power with a High number so we can assure the stun independently of weapon, Zed resistances, body part hit. This does NOT ignores other factors like cooldowns.
    if (InstigatorPerk != None && InstigatorPerk.IsStunGuaranteed( DamageType, HitZoneIdx ))
    {
        StunPower = STUN_GUARANTEED_POWER;
    }

    // increment affliction power
	if (KnockdownPower > 0 && CanDoSpecialmove(SM_Knockdown))
	{
		AccrueAffliction(AF_Knockdown, KnockdownPower, BodyPart, InstigatorPerk);
	}
	if (StunPower > 0 && CanDoSpecialmove(SM_Stunned))
	{
		AccrueAffliction(AF_Stun, StunPower, BodyPart, InstigatorPerk);
	}
	if (StumblePower > 0 && CanDoSpecialmove(SM_Stumble))
	{
		AccrueAffliction(AF_Stumble, StumblePower, BodyPart, InstigatorPerk);
	}
	if (FreezePower > 0 && CanDoSpecialMove(SM_Frozen))
	{
		AccrueAffliction(AF_Freeze, FreezePower, BodyPart, InstigatorPerk);
	}
	if (SnarePower > 0)
	{
		AccrueAffliction(AF_Snare, SnarePower, BodyPart, InstigatorPerk);
	}
}

/** Afflications which pause AI behavior temporarily */
protected function ProcessHitReactionAfflictions(KFPerk InstigatorPerk, class<KFDamageType> DamageType, Actor DamageCauser)
{
	local EHitZoneBodyPart BodyPart;
	local byte HitZoneIdx;
	local float ReactionModifier, MeleeHitPower, GunHitPower;
	local KFWeapon DamageWeapon;
	local KFInterface_DamageCauser KFDmgCauser;

	ReactionModifier = 1.f;
	// Allow damage instigator perk to modify reaction
    if (InstigatorPerk != None)
    {
    	ReactionModifier = InstigatorPerk.GetReactionModifier(DamageType);
    }

	// Finally, 'Pause' the AI if we're going to play a medium or heavy hit reaction anim in TryPlayHitReactionAnim
	if (MyKFAIC != None)
	{
		HitZoneIdx = HitFxInfo.HitBoneIndex;
		BodyPart = (HitZoneIdx != 255 && HitZoneIdx < HitZones.Length) ? HitZones[HitZoneIdx].Limb : BP_Torso;

		// Get upgraded affliction power
		DamageWeapon = class'KFPerk'.static.GetWeaponFromDamageCauser(DamageCauser);
		if (DamageWeapon != none)
		{
			MeleeHitPower = DamageWeapon.GetUpgradedAfflictionPower(AF_MeleeHit, DamageType.default.MeleeHitPower);
			GunHitPower = DamageWeapon.GetUpgradedAfflictionPower(AF_GunHit, DamageType.default.GunHitPower);
		}
		else
		{
			MeleeHitPower = DamageType.default.MeleeHitPower;
			GunHitPower = DamageType.default.GunHitPower;
		}

		KFDmgCauser = KFInterface_DamageCauser(DamageCauser);
		if (KFDmgCauser != None)
		{
			MeleeHitPower *= KFDmgCauser.GetIncapMod();
			GunHitPower *= KFDmgCauser.GetIncapMod();
		}

		// Check hard hit reaction
		if (MeleeHitPower > 0)
		{
			AccrueAffliction(AF_MeleeHit, MeleeHitPower * ReactionModifier, BodyPart, InstigatorPerk);
		}
		// Force recovery time for the headless hit. GetTimerCount() is a dirty way to do this only on the frame of CauseHeadTrauma()
		if (HitZoneIdx == HZI_Head && IsHeadless() && GetTimerCount('BleedOutTimer', Outer) == 0.f)
		{
			AccrueAffliction(AF_MeleeHit, 100.f, BodyPart, InstigatorPerk);
		}
		// Check medium hit reaction
		if (GunHitPower > 0)
		{
			AccrueAffliction(AF_GunHit, GunHitPower * ReactionModifier, BodyPart, InstigatorPerk);
		}
	}
}

/** Effect based afflictions can apply even on dead bodies */
protected function ProcessEffectBasedAfflictions(KFPerk InstigatorPerk, class<KFDamageType> DamageType, Actor DamageCauser)
{
	local KFWeapon DamageWeapon;
	local float BurnPower, EMPPower, PoisonPower, MicrowavePower, BleedPower;
	local KFInterface_DamageCauser KFDmgCauser;

	// Get upgraded affliction power
	DamageWeapon = class'KFPerk'.static.GetWeaponFromDamageCauser(DamageCauser);
	if (DamageWeapon != none)
	{
		BurnPower = DamageWeapon.GetUpgradedAfflictionPower(AF_FirePanic, DamageType.default.BurnPower);
		EMPPower = DamageWeapon.GetUpgradedAfflictionPower(AF_EMP, DamageType.default.EMPPower);
		PoisonPower = DamageWeapon.GetUpgradedAfflictionPower(AF_Poison, DamageType.default.PoisonPower);
		MicrowavePower = DamageWeapon.GetUpgradedAfflictionPower(AF_Microwave, DamageType.default.MicrowavePower);
		BleedPower = DamageWeapon.GetUpgradedAfflictionPower(AF_Bleed, DamageType.default.BleedPower);
	}
	else
	{
		BurnPower = DamageType.default.BurnPower;
		EMPPower = DamageType.default.EMPPower;
		PoisonPower = DamageType.default.PoisonPower;
		MicrowavePower = DamageType.default.MicrowavePower;
		BleedPower = DamageType.default.BleedPower;
	}

	KFDmgCauser = KFInterface_DamageCauser(DamageCauser);
	if (KFDmgCauser != None)
	{
		BurnPower *= KFDmgCauser.GetIncapMod();
		EMPPower *= KFDmgCauser.GetIncapMod();
		PoisonPower *= KFDmgCauser.GetIncapMod();
		MicrowavePower *= KFDmgCauser.GetIncapMod();
		BleedPower *= KFDmgCauser.GetIncapMod();
	}

	// these afflictions can apply on killing blow, but fire can apply after death
	if (bPlayedDeath && WorldInfo.TimeSeconds > TimeOfDeath)
	{
	    // If we're already dead, go ahead and apply burn stacking power, just
	    // so we can do the burn effects
	    if (BurnPower > 0)
		{
	        AccrueAffliction(AF_FirePanic, BurnPower);
		}
	}
	else
	{
		if (EMPPower > 0)
		{
			AccrueAffliction(AF_EMP, EMPPower);
		}
		else if (InstigatorPerk != none && InstigatorPerk.ShouldGetDaZeD(DamageType))
		{
			AccrueAffliction(AF_EMP, InstigatorPerk.GetDaZedEMPPower());
		}

		if (BurnPower > 0)
		{
			AccrueAffliction(AF_FirePanic, BurnPower);
		}
		if (PoisonPower > 0 || DamageType.static.AlwaysPoisons())
		{
			AccrueAffliction(AF_Poison, PoisonPower);
		}
		if (MicrowavePower > 0)
		{
			AccrueAfflictionMicrowave(AF_Microwave, MicrowavePower, DamageType.default.bHasToSpawnMicrowaveFire);
		}
        if (BleedPower > 0)
        {
            AccrueAffliction(AF_Bleed, BleedPower);
        }
	}
}

/*********************************************************************************************
* @name		Stacked / Accumulated Afflications
********************************************************************************************* */

/**
 * Adds StackedPower
 * @return true if the affliction effect should be applied
 */
function AccrueAffliction(EAfflictionType Type, float InPower, optional EHitZoneBodyPart BodyPart, optional KFPerk InstigatorPerk)
{
	if ( InPower <= 0 || Type >= IncapSettings.Length )
	{
		return; // immune
	}

	if ( !VerifyAfflictionInstance(Type, InstigatorPerk) )
	{
		return; // cannot create instance
	}

	// for radius damage apply falloff using most recent HitFxInfo
	if ( HitFxInfo.bRadialDamage && HitFxRadialInfo.RadiusDamageScale != 255 )
	{
		InPower *= ByteToFloat(HitFxRadialInfo.RadiusDamageScale);
		`log(Type@"Applied damage falloff modifier of"@ByteToFloat(HitFxRadialInfo.RadiusDamageScale), bDebugLog);
	}

	// scale by character vulnerability
	if ( IncapSettings[Type].Vulnerability.Length > 0 )
	{
		InPower *= GetAfflictionVulnerability(Type, BodyPart);
		`log(Type@"Applied hit zone vulnerability modifier of"@GetAfflictionVulnerability(Type, BodyPart)@"for"@BodyPart, bDebugLog);
	}

	// allow owning pawn final adjustment
	AdjustAffliction(InPower);

	if ( InPower > 0 )
	{
		Afflictions[Type].Accrue(InPower);
	}
}


/**
 * Adds StackedPower
 * @return true if the affliction effect should be applied
 */
function AccrueAfflictionMicrowave(EAfflictionType Type, float InPower, bool bHasToSpawnFire, optional EHitZoneBodyPart BodyPart, optional KFPerk InstigatorPerk)
{
	if ( InPower <= 0 || Type >= IncapSettings.Length )
	{
		return; // immune
	}

	if ( !VerifyAfflictionInstance(Type, InstigatorPerk) )
	{
		return; // cannot create instance
	}

	// for radius damage apply falloff using most recent HitFxInfo
	if ( HitFxInfo.bRadialDamage && HitFxRadialInfo.RadiusDamageScale != 255 )
	{
		InPower *= ByteToFloat(HitFxRadialInfo.RadiusDamageScale);
		`log(Type@"Applied damage falloff modifier of"@ByteToFloat(HitFxRadialInfo.RadiusDamageScale), bDebugLog);
	}

	// scale by character vulnerability
	if ( IncapSettings[Type].Vulnerability.Length > 0 )
	{
		InPower *= GetAfflictionVulnerability(Type, BodyPart);
		`log(Type@"Applied hit zone vulnerability modifier of"@GetAfflictionVulnerability(Type, BodyPart)@"for"@BodyPart, bDebugLog);
	}

	// allow owning pawn final adjustment
	AdjustAffliction(InPower);

	if ( InPower > 0 )
	{
		KFAffliction_Microwave(Afflictions[Type]).bHasToSpawnFire = bHasToSpawnFire;
		Afflictions[Type].Accrue(InPower);
	}
}

/** Returns an index into the vulnerabilities array based on what part of the body was hit */
simulated function float GetAfflictionVulnerability(EAfflictionType i, EHitZoneBodyPart BodyPart)
{
	local EAfflictionVulnerabilityType j;

	switch(BodyPart)
	{
		case BP_Head:
			j = AV_Head;
			break;
		case BP_LeftArm:
		case BP_RightArm:
			j = AV_Arms;
			break;
		case BP_LeftLeg:
		case BP_RightLeg:
			j = AV_Legs;
			break;
		case BP_Special:
			j = AV_Special;
			break;
	}

	if ( j > AV_Default && j < IncapSettings[i].Vulnerability.Length )
	{
		return IncapSettings[i].Vulnerability[j];
	}

	return IncapSettings[i].Vulnerability[AV_Default];
}

/** Called whenever we need may need to initiatize the affliction class instance */
simulated function bool VerifyAfflictionInstance(EAfflictionType Type, optional KFPerk InstigatorPerk)
{
	if( Type >= Afflictions.Length || Afflictions[Type] == None )
	{
		if( Type < AfflictionClasses.Length && AfflictionClasses[Type] != None )
		{
			Afflictions[Type] = new(Outer) AfflictionClasses[Type];

			// Cache a reference to the owner to avoid passing parameters around.
			Afflictions[Type].Init(Outer, Type, InstigatorPerk);
		}
		else
		{
			`log(GetFuncName() @ "Failed with afflication:" @ Type @ "class:" @ AfflictionClasses[Type] @ Self);
			Afflictions[Type] = None;
			return FALSE;
		}
	}

	return true;
}

/** Accessor to get affliction duration for attack cooldowns in verus*/
function float GetAfflictionDuration( EAfflictionType Type )
{
	if( Type < IncapSettings.Length )
	{
		return IncapSettings[Type].Duration;
	}
}

/** Accessor to get known affliction knockdown modifier */
function float GetAfflictionKnockdownModifier()
{
    local float KnockdownModifier;
    local int i;

    KnockdownModifier = 0.f;
    for (i = 0; i < Afflictions.Length; ++i)
    {
        if (Afflictions[i] != none)
        {
            KnockdownModifier += Afflictions[i].GetKnockdownModifier();
        }
    }

    return KnockdownModifier;
}

/** Accessor to get known affliction Stumble modifier */
function float GetAfflictionStumbleModifier()
{
    local float StumbleModifier;
    local int i;

    StumbleModifier = 0.f;
    for (i = 0; i < Afflictions.Length; ++i)
    {
        if (Afflictions[i] != none)
        {
            StumbleModifier += Afflictions[i].GetStumbleModifier();
        }
    }

    return StumbleModifier;
}

/** Accessor to get known affliction Stun modifier */
function float GetAfflictionStunModifier()
{
    local float StunModifier;
    local int i;

    StunModifier = 0.f;
    for (i = 0; i < Afflictions.Length; ++i)
    {
        if (Afflictions[i] != none)
        {
            StunModifier += Afflictions[i].GetStunModifier();
        }
    }

    return StunModifier;
}

/** Accessor to get known affliction Damage modifier */
function float GetAfflictionDamageModifier()
{
    local float DamageModifier;
    local int i;

    DamageModifier = 1.f;
    for (i = 0; i < Afflictions.Length; ++i)
    {
        if (Afflictions[i] != none)
        {
            DamageModifier += Afflictions[i].GetDamageModifier();
        }
    }

    return DamageModifier;
}

/** Accessor to get known affliction speed modifier - Multiplicative from all mods */
function float GetAfflictionSpeedModifier()
{
    local float SpeedModifier;
    local int i;

    SpeedModifier = 1.f;
    for (i = 0; i < Afflictions.Length; ++i)
    {
        if (Afflictions[i] != none)
        {
            SpeedModifier *= Afflictions[i].GetSpeedModifier();
        }
    }

    return SpeedModifier;
}

function float GetAfflictionAttackSpeedModifier()
{
	local float SpeedModifier;
	local int i;

	SpeedModifier = 1.f;
	for (i = 0; i < Afflictions.Length; ++i)
	{
		if (Afflictions[i] != none)
		{
			SpeedModifier *= Afflictions[i].GetAttackSpeedModifier();
		}
	}

	return SpeedModifier;
}

/** Turns off all affliction sounds / effects */
simulated function Shutdown()
{
	local int i;

	// Call deactivate, but let the strength decay naturally before removing from array
	for (i = Afflictions.Length - 1; i >= 0; --i)
	{
		if ( Afflictions[i] != None )
		{
			Afflictions[i].Shutdown();
		}
	}
}

/*********************************************************************************************
* @name		Functions that are needed clientside for VFX.
********************************************************************************************* */

/** Called from the pawn when we need to update FX outside of the affliction class (e.g. client repnotify) */
function ToggleEffects(EAfflictionType Type, bool bPrimary, optional bool bSecondary)
{
    if ( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	// After death FX are soley owned by the affliction class (simplifies TearOff/Replication issues)
	if ( bPlayedDeath )
	{
		return;
	}
	// If the value is zero no need to create an instance
	if( Type >= Afflictions.Length || Afflictions[Type] == None )
	{
		if ( (!bPrimary && !bSecondary) || !VerifyAfflictionInstance(Type) )
		{
			return; // cannot create instance
		}
	}

	Afflictions[Type].ToggleEffects(bPrimary, bSecondary);
}

function UpdateMaterialParameter(EAfflictionType Type, float Value)
{
    if ( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	// If the value is zero no need to create an instance
	if( Type >= Afflictions.Length || Afflictions[Type] == None )
	{
		if ( Value == 0 || !VerifyAfflictionInstance(Type) )
		{
			return; // cannot create instance
		}
	}

	Afflictions[Type].SetMaterialParameter(Value);
}

defaultproperties
{
	AfflictionClasses(AF_EMP)=class'KFAffliction_EMP'
	AfflictionClasses(AF_FirePanic)=class'KFAffliction_Fire'
	AfflictionClasses(AF_Poison)=class'KFAffliction_Poison'
	AfflictionClasses(AF_Microwave)=class'KFAffliction_Microwave'
	AfflictionClasses(AF_Freeze)=class'KFAffliction_Freeze'
	AfflictionClasses(AF_GunHit)=class'KFAffliction_MediumRecovery'
	AfflictionClasses(AF_MeleeHit)=class'KFAffliction_HeavyRecovery'
	AfflictionClasses(AF_Stun)=class'KFAffliction_Stun'
	AfflictionClasses(AF_Stumble)=class'KFAffliction_Stumble'
	AfflictionClasses(AF_Knockdown)=class'KFAffliction_Knockdown'
	AfflictionClasses(AF_Snare)=class'KFAffliction_Snare'
    AfflictionClasses(AF_Bleed)=class'KFAffliction_Bleed'
}
