//=============================================================================
// KFPawn_ZedClot_AlphaKing
//=============================================================================
// Alpha clot King
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedClot_AlphaKing extends KFPawn_ZedClot_Alpha;

/** Self-rally damage modifiers */
var protected float SelfRallyDealtDamageModifier;
var protected float SelfRallyTakenDamageModifier;

/** If TRUE, this rally was applied to ourselves */
var protected bool bWasSelfRally;

// Sound when Clot King becomes enraged.
var const AkEvent EnragedSoundEvent;

/** Called immediately after gameplay begins */
simulated event PostBeginPlay()
{
	local class<KFDifficulty_ClotAlphaKing> MyDifficultySettings;
	local KFGameReplicationInfo KFGRI;
	local byte GameDifficulty;

	super.PostBeginPlay();

	MyDifficultySettings = class<KFDifficulty_ClotAlphaKing>( DifficultySettings );
	if( MyDifficultySettings != none )
	{
		// Set our (Network: ALL) difficulty-based settings
		KFGRI = KFGameReplicationInfo( WorldInfo.GRI );
		if( KFGRI != none )
		{
			GameDifficulty = Clamp(KFGRI.GetModifiedGameDifficulty(), 0, MyDifficultySettings.default.RallyTriggerSettings.Length - 1);
			SelfRallyDealtDamageModifier = MyDifficultySettings.default.RallyTriggerSettings[GameDifficulty].SelfDealtDamageModifier;
			SelfRallyTakenDamageModifier = MyDifficultySettings.default.RallyTriggerSettings[GameDifficulty].SelfTakenDamageModifier;
		}
	}
}

event PossessedBy( Controller C, bool bVehicleTransition )
{
	local KFAIController_ZedClot_AlphaKing AlphaController;

	super.PossessedBy( C, bVehicleTransition );

	// Initialize our rally settings
	AlphaController = KFAIController_ZedClot_AlphaKing( MyKFAIC );
	if( AlphaController != none )
	{
		AlphaController.InitRallySettings();
	}
}

/** Applies the rally buff and spawns a rally effect */
simulated function bool Rally(
							KFPawn 			RallyInstigator,
							ParticleSystem 	RallyEffect,
							name 			EffectBoneName,
							vector			EffectOffset,
							ParticleSystem	AltRallyEffect,
							name 			AltEffectBoneNames[2],
							vector 			AltEffectOffset,
							optional bool	bSkipEffects=false
						)
{
	if( RallyInstigator == self )
	{
		bWasSelfRally = true;
	}
	else
	{
		bWasSelfRally = false;
	}

    return super.Rally(RallyInstigator, RallyEffect, EffectBoneName, EffectOffset, AltRallyEffect, AltEffectBoneNames, AltEffectOffset, bSkipEffects);
}

/** Applies the rally damage boost if applicable */
simulated function int GetRallyBoostDamage( int NewDamage )
{
	if( bWasSelfRally && SelfRallyDealtDamageModifier > 0.f )
	{
		return NewDamage * ( IsTimerActive(nameOf(Timer_EndRallyBoost)) ? SelfRallyDealtDamageModifier : 1.f );
	}
	else
	{
		return super.GetRallyBoostDamage( NewDamage );
	}
}

/** Applies the rally damage reduction if applicable */
simulated function int GetRallyBoostResistance( int NewDamage )
{
	if( bWasSelfRally && SelfRallyTakenDamageModifier > 0.f )
	{
		return NewDamage * ( IsTimerActive(nameOf(Timer_EndRallyBoost)) ? SelfRallyTakenDamageModifier : 1.f );
	}
	else
	{
		return super.GetRallyBoostDamage( NewDamage );
	}
}

function int GetHitZoneIndex(name BoneName)
{
	if (BoneName == 'KBArmor')
	{
		//Known arbitrary, hacking some things in place
		return OverrideArmorFXIndex;
	}

	return super.GetHitZoneIndex(BoneName);
}

simulated function KFSkinTypeEffects GetHitZoneSkinTypeEffects(int HitZoneIdx)
{
	if (HitZoneIdx == OverrideArmorFXIndex)
	{
		return CharacterArch.ImpactSkins[2];
	}
	return super.GetHitZoneSkinTypeEffects(HitZoneIdx);
}

function ZedExplodeArmor(int ArmorZoneIdx, name ArmorZoneName)
{
	super.ZedExplodeArmor(ArmorZoneIdx, ArmorZoneName);
	KFAIController_ZedClot_AlphaKing(Controller).StartArmorLoss();
}

simulated function bool SetEnraged(bool bNewEnraged)
{
	local bool bSuccess;

	bSuccess = super.SetEnraged(bNewEnraged);
	if (bSuccess && Role == ROLE_Authority && bNewEnraged)
	{
		PlaySoundBase(EnragedSoundEvent);
	}

	return bSuccess;
}

function SetSprinting(bool bNewSprintStatus)
{
	if (bNewSprintStatus == false || (MyKFAIC != none && MyKFAIC.bCanSprint))
	{
		super.SetSprinting(bNewSprintStatus);
	}
}

defaultproperties
{
	ArmorZoneStatus=3
	PreviousArmorZoneStatus=3

	LocalizationKey=KFPawn_ZedClot_AlphaKing
	MonsterArchPath="ZED_ARCH.ZED_Clot_AlphaKing_Archetype"
	ControllerClass=class'KFAIController_ZedClot_AlphaKing'
	DifficultySettings=class'KFDifficulty_ClotAlphaKing'

	Health=300 //100
	OverrideArmorFXIndex=200

	HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=125, DmgScale=1.1, SkinID=1)

	// Spawning
    MinSpawnSquadSizeType=EST_Medium

    // Movement Physics
	GroundSpeed=180.f //210.f
	SprintSpeed=450.f //500.f

	//Gameplay
	Begin Object Name=MeleeHelper_0
		BaseDamage=8.f //6.f
		MaxHitRange=172.f
		MomentumTransfer=25000.f
		MyDamageType=class'KFDT_Slashing_ZedWeak'
	End Object

	// Incap Settings
	// for reference: Vulnerability=(default, head, legs, arms, special)
	IncapSettings(AF_Stun)=		(Vulnerability=(2.0, 2.0, 1.0, 1.0, 1.0), Cooldown=3.0,  Duration=3.0)
	IncapSettings(AF_Knockdown)=(Vulnerability=(1.f),                     Cooldown=1.0)
	IncapSettings(AF_Stumble)=	(Vulnerability=(1.3f),                    Cooldown=0.2)
	IncapSettings(AF_GunHit)=	(Vulnerability=(2.5),                     Cooldown=0.2)
	IncapSettings(AF_MeleeHit)= (Vulnerability=(2.0),                     Cooldown=0.0)
	IncapSettings(AF_Poison)=	(Vulnerability=(3),	                      Cooldown=6.0,  Duration=3.0)
	IncapSettings(AF_Microwave)=(Vulnerability=(0.5),	                  Cooldown=10.0, Duration=2.0)
	IncapSettings(AF_FirePanic)=(Vulnerability=(1.5),                     Cooldown=7.0,  Duration=5)
	IncapSettings(AF_EMP)=		(Vulnerability=(2.5),                     Cooldown=5.0,  Duration=5.0)
	IncapSettings(AF_Freeze)=	(Vulnerability=(2.5),                     Cooldown=1.5,  Duration=4.0)
	IncapSettings(AF_Snare)=	(Vulnerability=(10.0, 10.0, 10.0, 10.0),  Cooldown=5.5,  Duration=4.0)
    IncapSettings(AF_Bleed)=    (Vulnerability=(2.0))
    IncapSettings(AF_Shrink)=   (Vulnerability=(1.0))
	
	ShrinkEffectModifier = 0.4f

	ParryResistance=0

	// ---------------------------------------------
	// Resistance & Vulnerability
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(1.5)))  //3.0
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(1.01)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(1.0)))  //0.76
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.85))) //0.75
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.9))) //0.75
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(3.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.25)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(1.0))) //0.88
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bleeding', 	                DamageScale=(1.0)))

	//special case
	DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGenerator_Beam',       				DamageScale=(3.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGeneratorSphereImpact',       		DamageScale=(1.2)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGenerator_DefaultFiremodeZapDamage', 	DamageScale=(3.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGenerator_AltFiremodeZapDamage',		DamageScale=(3.5)))

	ArmorInfoClass=class'KFZedArmorInfo_ClotKing'
	RepArmorPct[0] = 255
	RepArmorPct[1] = 255

	bCanRage=true
	EnragedSoundEvent=AkEvent'WW_ZED_Clot_Alpha.Play_Alpha_Clot_Special_Enrage'

	ElitePawnClass.Empty
}
