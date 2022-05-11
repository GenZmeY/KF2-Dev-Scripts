//=============================================================================
// KFPawn_Human
//=============================================================================
// KF Pawn for human characters
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFPawn_Human extends KFPawn
	nativereplication
	native(Pawn);

`include(KFGame\KFGameAnalytics.uci);
`include(KFGame\KFMatchStats.uci);

/** Current movement speed penalty based on health */
var float LowHealthSpeedPenalty;

/*********************************************************************************************
* @name Animation
********************************************************************************************* */

/** Replicated state of 1st person for 3rd person animations */
var repnotify byte CurrentWeaponState;

/** Replicated 3rd person attachment animation rate value, for matching up to 1st person anims */
var protected byte WeaponAttachmentAnimRateByte;

/** Item Id for 3rd person weapon skin */
var const repnotify int WeaponSkinItemId;

/** Random face expression poses when dead */
var array<name> DeathFaceAnims;

/*********************************************************************************************
* @name Effects
********************************************************************************************* */

/** How long to wait after a pawn is dead before spawning the blood pool */
var globalconfig float BloodPoolDelay;

/** chance to play a pain sound when hit */
var float PainSoundChanceOnHit;
/** how long before another pain sound can be played when hit */
var float PainSoundCoolDown;
/** the last time a pain sound was played */
var float PainSoundLastPlayedTime;

var string PerkFXEmitterPoolClassPath;
var transient EmitterPool PerkFXEmitterPool;

/** Default values for material based damage effects on death */
var const name DefaultDeathMaterialEffectParamName;
var const float DefaultDeathMaterialEffectDuration;

/**
 * Book keeping variables for material based damage effects.
 * Note: Although multiple effects can coexist, only single effect interpolation is supported at any given time.
 * This works as long as the interp time is not too long. Consider making this an array if that does not hold true.
 */
var transient float DeathMaterialEffectDuration;
var transient float DeathMaterialEffectTimeRemaining;
var transient name DeathMaterialEffectParamName;

struct native KFPowerUpFxInfo
{
	/** the power up type the player has */
	var class<KFPowerUp>	PowerUpType;

	var byte Count;
};

struct native KFPowerUpCurrentFxInfo
{
	/** the power up type the player has */
	var class<KFPowerUp>	PowerUpType;

	/** the particle component associated with the effect */
	var ParticleSystemComponent	ParticleEffect;
};

/** replicated information on a powerup effect */
var repnotify KFPowerUpFxInfo 	PowerUpFxInfo;

/** replicated information on a powerup effect */
var repnotify KFPowerUpFxInfo 	PowerUpFxStopInfo;

var KFPowerUpCurrentFxInfo CurrentPowerUpEffect;

/*********************************************************************************************
* @name Flashlight (aka Torch)
********************************************************************************************* */

/** A flashlight flash instance */
var	transient 	KFFlashlightAttachment FlashLight;
/** A reference to the muzzle flash template */
var const 		KFFlashlightAttachment FlashLightTemplate;

/** Toggles a clients flashlight for all other clients */
var repnotify 	bool					bFlashlightOn;

/** Toggles a client iron sight for all other clients */
var repnotify	bool					bUsingIronSights;

/** Toggles a client iron sight for all other clients */
var repnotify	bool					bUsingAltFireMode;

var() float BatteryDrainRate;
var() float BatteryRechargeRate;
var	float	BatteryCharge;

/** Night vision active (local player only) */
var float	NVGBatteryDrainRate;

/*********************************************************************************************
* @name Night Vision
********************************************************************************************* */

var()			PointLightComponent NightVisionLightTemplate;
var transient	PointLightComponent NightVisionLight;

/*********************************************************************************************
* @name HUD
********************************************************************************************* */
/** Needed to render the players health etc **/
var KFGFxMoviePlayer_PlayerInfo		PlayerPartyInfo;

var	byte ActivePerkMessageIdx;

/*********************************************************************************************
* @name Health & Armor
********************************************************************************************* */
var byte	HealthToRegen;
var float	HealthRegenRate;
var float 	HealerRewardScaler;

var	byte 	MaxArmor;
var byte	Armor;
var byte	IntegrityLevel_High;
var byte	IntegrityLevel_Medium;
var byte	IntegrityLevel_Low;
var float	ArmorAbsorbModifier_High;
var float	ArmorAbsorbModifier_Medium;
var float	ArmorAbsorbModifier_Low;

/*********************************************************************************************
* @name Solo Surrounded Difficulty Reduction
********************************************************************************************* */

/** Minimum number of enemies to trigger surrounded difficulty reduction when playing solo */
var byte MinEnemiesToTriggerSurrounded;
/** Health percent threshold that must be reached to trigger surrounded when solo */
var float MinHealthPctToTriggerSurrounded;

/*********************************************************************************************
* @name Perk @ToDo: Move stuff to PRI and combine in a byte/INT
********************************************************************************************* */
var array<string> ActiveSkillIconPaths;

var repnotify private byte HealingSpeedBoost;
var repnotify private byte HealingDamageBoost;
var repnotify private byte HealingShield;

var transient KFExplosion_AirborneAgent AAExplosionActor;

/*********************************************************************************************
* @name Objectives
********************************************************************************************* */
var	bool	bObjectivePlayer;

/*********************************************************************************************
* @name Dialog
********************************************************************************************* */
var transient int						DoshCaughtStreakAmt;
var transient float						LastDoshCaughtTime;
var transient PlayerReplicationInfo		LastDoshCaughtGiver;

var transient int						ZedsKilledStreakAmt;
var transient float						LastZedKilledTime;

var transient int						DamageTakenStreakAmt;
var transient float						LastDamageTakenStreakStartTime;

var transient float						InitialContinousDamageTime;
var transient float						IdleStartTime;
var transient int						EnvironmentDialogEventID;
var transient float						SprintTowardZedStartTime;

var transient float						SprintStartTime;

var protected AkComponent 			    TraderDialogAkComponent;

/** Game info set variable to disable dialog on clients for specific game modes */
var bool                                bDisableTraderDialog;

struct native DialogResponseInfo
{
    var KFPawn  Speaker;
    var KFPawn 	RespondingToPawn;
    var int     EventID;
    var int		RespondingToID;
};

var DialogResponseInfo DlgRespInfo;

replication
{
	// Replicated to ALL
	if(bNetDirty)
		Armor, MaxArmor, bObjectivePlayer, WeaponSkinItemId, HealingSpeedBoost,
		HealingDamageBoost, HealingShield, HealthToRegen, PowerUpFxInfo, PowerUpFxStopInfo;

    // Replicated to owning client
    if (bNetDirty && bNetOwner)
        bDisableTraderDialog;

	// Replicated to all but the owning client
	if(bNetDirty && (!bNetOwner || bDemoRecording))
		CurrentWeaponState, WeaponAttachmentAnimRateByte, bFlashlightOn, bUsingIronSights, bUsingAltFireMode;
}

cpptext
{
	// Actor
	INT* GetOptimizedRepList( BYTE* InDefault, FPropertyRetirement* Retire, INT* Ptr, UPackageMap* Map, UActorChannel* Channel );
	virtual void TickAuthoritative( FLOAT DeltaSeconds );
	virtual FLOAT MaxSpeedModifier();
	virtual UBOOL ShouldTrace(UPrimitiveComponent* Primitive,AActor *SourceActor, DWORD TraceFlags);
}

native function float GetGravityZ();

/*********************************************************************************************
* @name  General
********************************************************************************************* */

simulated event Tick( float DeltaTime )
{
	local float NewSpeedPenalty;

	super.Tick( DeltaTime );

	if ( Role == ROLE_Authority )
	{
		// Update movement speed based on health
		if ( Health < HealthMax )
		{
			// Use 100 instead of HealthMax so that perk health bonuses do not penalize movement
			NewSpeedPenalty = Lerp(0.15f, 0.f, FMin(float(Health) / 100, 1.f));
		}
		else
		{
			NewSpeedPenalty = 0.f;
		}

		if ( NewSpeedPenalty != LowHealthSpeedPenalty )
		{
			LowHealthSpeedPenalty = NewSpeedPenalty;
			UpdateGroundSpeed();
		}
	}

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( DeathMaterialEffectTimeRemaining > 0 )
		{
			UpdateDeathMaterialEffect( DeltaTime );
		}
	}
}

/*********************************************************************************************
* @name  Constructors, Destructors, and Loading
********************************************************************************************* */

// Called immediately after gameplay begins.
simulated event PreBeginPlay()
{
	local class<EmitterPool> PoolClass;

	super.PreBeginPlay();

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if( PerkFXEmitterPoolClassPath != "" )
		{
			PoolClass = class<EmitterPool>(DynamicLoadObject(PerkFXEmitterPoolClassPath, class'Class'));
			if( PoolClass != None )
			{
				PerkFXEmitterPool = Spawn(PoolClass, self,, vect(0,0,0), rot(0,0,0));
			}
		}
	}
}

function PossessedBy(Controller C, bool bVehicleTransition)
{
	Super.PossessedBy(C, bVehicleTransition);

	// Reset perk buffs
	ResetHealingSpeedBoost();
	ResetHealingDamageBoost();
	ResetHealingShield();

	ResetIdleStartTime();

	// See if we should start our surrounded timer
	if( IsAliveAndWell() && WorldInfo.Game != none && WorldInfo.Game.NumPlayers == 1 && KFGameInfo(WorldInfo.Game).bOnePlayerAtStart )
	{
		SetTimer( 1.f, true, nameOf(Timer_CheckSurrounded) );
	}

	KFGameInfo(WorldInfo.Game).OverrideHumanDefaults( self );
	SetTimer(0.5f, false, nameof(ClientOverrideHumanDefaults), self);
}

simulated function NotifyTeamChanged()
{
	local KFPerk InstigatorPerk;

	// Applies Character Info for < ROLE_Authority
	if( PlayerReplicationInfo != None )
	{
		SetCharacterArch(GetCharacterInfo());
	}

	InstigatorPerk = GetPerk();
	if( InstigatorPerk != none )
	{
		InstigatorPerk.NotifyPawnTeamChanged();
	}
}

/**
 * Check on various replicated data and act accordingly.
 */
simulated event ReplicatedEvent(name VarName)
{
	switch( VarName )
	{
	case nameof(CurrentWeaponState):
		WeaponStateChanged(CurrentWeaponState, true);
		break;
	case nameof(WeaponSkinItemId):
		if ( WeaponAttachment != None && WeaponSkinItemId > 0 )
		{
			WeaponAttachment.SetWeaponSkin(WeaponSkinItemId);
		}
		break;
	case nameof(bFlashlightOn):
		SetFlashlight(bFlashlightOn, false);
		break;
	case nameof(bUsingIronSights):
		SetIronSights(bUsingIronSights, false);
		break;
	case nameof(bUsingAltFireMode):
		SetUsingAltFireMode (bUsingAltFireMode, false);
		break;
	case nameof(PowerUpFxInfo):
		PlayPowerUpEffect(PowerUpFxInfo);
		break;
	case nameof(PowerUpFxStopInfo):
		StopPowerUpEffect(PowerUpFxStopInfo);
		break;
	case nameof(HealingSpeedBoost):
		NotifyHealingSpeedBoostBuff(HealingSpeedBoost);
		break;
	case nameof(HealingDamageBoost):
		NotifyHealingDamageBoostBuff(HealingDamageBoost);
		break;
	case nameof(HealingShield):
		NotifyHealingShieldBoostBuff(HealingShield);
		break;
	}

	Super.ReplicatedEvent(VarName);
}

simulated event Destroyed()
{
	if( PlayerPartyInfo != none )
	{
		PlayerPartyInfo.SetVisible( false );
		PlayerPartyInfo.Close();
	}

	if ( Flashlight != None )
	{
		Flashlight.DetachFlashlight();
	}

	if( AAExplosionActor != none )
	{
		AAExplosionActor.Destroy();
	}

	super.Destroyed();
}

/** Don't want to set this in the character arch, will do it later OnCharacterMeshChanged*/
simulated function SetCharacterArchAnimationInfo() {}

/** Set various basic properties for this KFPawn based on the character class metadata */
simulated function SetCharacterArch(KFCharacterInfoBase Info, optional bool bForce )
{
	Super.SetCharacterArch(Info);

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		// Attach/Reattach flashlight components when mesh is set
		if ( Flashlight == None && FlashLightTemplate != None )
		{
			Flashlight = new(self) Class'KFFlashlightAttachment' (FlashLightTemplate);
			Flashlight.AttachFlashlight(Mesh);
		}
		else if ( FlashLight != None )
		{
			Flashlight.Reattach();
		}
	}
}

/** Notify pawn whenever mesh is swapped (e.g. new character or new outfit) */
simulated function OnCharacterMeshChanged()
{
	if ( FlashLight != None )
	{
		Flashlight.Reattach();
	}

	// If the character mesh was async loaded, the call to SetCharacterAnimationInfo in
	// KFPawn::SetCharacterArch will not do what it's supposed to do because it needs a skeletal mesh.
	// So, call it here, once the skeletal mesh is loaded.
	SetCharacterAnimationInfo();
}

/*********************************************************************************************
* @name Inventory
********************************************************************************************* */

/**
 * Overridden to iterate through the DefaultInventory array and
 * give each item to this Pawn.
 *
 * @see			GameInfo.AddDefaultInventory
 */
function AddDefaultInventory()
{
    local KFPerk MyPerk;
	local KFGameInfo GameInfo;

    MyPerk = GetPerk();

	if( MyPerk != none )
	{
        MyPerk.AddDefaultInventory(self);
    }

/** DefaultInventory.AddItem(class<Weapon>(DynamicLoadObject("KFGameContent.KFWeap_Pistol_9mm", class'Class')));
	Loading the secondary weapon in the perk again */

	GameInfo = KFGameInfo(WorldInfo.Game);
	if(GameInfo.OutbreakEvent == none || !GameInfo.OutbreakEvent.ActiveEvent.bCannotBeHealed)
	{
		DefaultInventory.AddItem(class<Weapon>(DynamicLoadObject("KFGameContent.KFWeap_Healer_Syringe", class'Class')));
	}
	
	DefaultInventory.AddItem(class<Weapon>(DynamicLoadObject("KFGameContent.KFWeap_Welder", class'Class')));
	DefaultInventory.AddItem(class<Inventory>(DynamicLoadObject("KFGameContent.KFInventory_Money", class'Class')));

	Super.AddDefaultInventory();
}

/** When switching weapon modify GroundSpeed by encumbrance level */
simulated function PlayWeaponSwitch(Weapon OldWeapon, Weapon NewWeapon)
{
	Super.PlayWeaponSwitch(OldWeapon, NewWeapon);

	if( Role == ROLE_Authority )
	{
		// Update GroundSpeed on weapon switch in case our perk
		// has a weapon specific movement bonus
		UpdateGroundSpeed();
		`DialogManager.PlaySwitchToFavoriteWeaponDialog( self );
	}
}

simulated function bool CanThrowWeapon()
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Controller);
	if (KFPC != none && KFPC.MyGFxManager != none && KFPC.MyGFxManager.TraderMenu != none && KFPC.MyGFxManager.CurrentMenu == KFPC.MyGFxManager.TraderMenu)
	{
		return false;
	}
	return super.CanThrowWeapon();
}

/**
 * Event called from native code when Pawn starts crouching.
 * Called on non owned Pawns through bIsCrouched replication.
 * Network: ALL
 *
 * @param	HeightAdjust	height difference in unreal units between default collision height, and actual crouched cylinder height.
 */
simulated event StartCrouch( float HeightAdjust )
{
	super.StartCrouch( HeightAdjust );
	UpdateGroundSpeed();

	if (WeaponAttachment != none)
	{
		WeaponAttachment.StartPawnCrouch ();
	}
}

/**
 * Event called from native code when Pawn stops crouching.
 * Called on non owned Pawns through bIsCrouched replication.
 * Network: ALL
 *
 * @param	HeightAdjust	height difference in unreal units between default collision height, and actual crouched cylinder height.
 */
simulated event EndCrouch( float HeightAdjust )
{
	Super.EndCrouch( HeightAdjust );
	UpdateGroundSpeed();

	if (WeaponAttachment != none)
	{
		WeaponAttachment.EndPawnCrouch ();
	}
}

/**
 * Reset/update GroundSpeed based on perk/weapon selection.  GroundSpeed is used instead of
 * MaxSpeedModifier() so that other physics code reacts properly (e.g. bLimitFallAccel)
 * Network: Server Only
 */
function UpdateGroundSpeed()
{
	local KFInventoryManager InvM;
	local float WeightMod, HealthMod, WeaponMod;
    local KFGameInfo KFGI;
	local KFWeapon CurrentWeapon;
	local KFPlayerController KFPC;

	if ( Role < ROLE_Authority )
		return;

	CurrentWeapon = KFWeapon(Weapon);
	InvM = KFInventoryManager(InvManager);
	WeightMod = (InvM != None) ? InvM.GetEncumbranceSpeedMod() : 1.f;
	HealthMod = GetHealthMod();
	// some weapons can change a player's movement speed during certain states
	WeaponMod = (CurrentWeapon != None) ? CurrentWeapon.MovementSpeedMod : 1.f;

    //Grab new defaults
	GroundSpeed = default.GroundSpeed;
    SprintSpeed = default.SprintSpeed;

    //Allow game info modifiers
    KFGI = KFGameInfo(WorldInfo.Game);
    if (KFGI != none)
    {
        KFGI.ModifyGroundSpeed(self, GroundSpeed);
        KFGI.ModifySprintSpeed(self, SprintSpeed);
    }

	//Add pawn modifiers
	GroundSpeed = GroundSpeed * WeightMod * HealthMod * WeaponMod;
    SprintSpeed = SprintSpeed * WeightMod * HealthMod * WeaponMod;

	// Ask our perk to set the new ground speed based on weapon type
	if( GetPerk() != none )
	{
		GetPerk().ModifySpeed( GroundSpeed );
		GetPerk().ModifySprintSpeed( SprintSpeed );
        GetPerk().FinalizeSpeedVariables();
	}

	// Ask the current power up to set new ground speed
	KFPC = KFPlayerController(Controller);
	if( KFPC != none && KFPC.GetPowerUp() != none )
	{
		KFPC.GetPowerUp().ModifySpeed( GroundSpeed );
		KFPC.GetPowerUp().ModifySprintSpeed( SprintSpeed );
        KFPC.GetPowerUp().FinalizeSpeedVariables();
	}

	if (CurrentWeapon != None)
	{
		if (CurrentWeapon.OverrideGroundSpeed >= 0.0f)
		{
			GroundSpeed = CurrentWeapon.OverrideGroundSpeed;
		}

		if (CurrentWeapon.OverrideSprintSpeed >= 0.0f)
		{
			SprintSpeed = CurrentWeapon.OverrideSprintSpeed;
		}
	}
}

function float GetHealthMod()
{
    return 1.f - LowHealthSpeedPenalty;
}

/*********************************************************************************************
* @name Animation
********************************************************************************************* */

/** Called when a pawn's weapon changes state. */
simulated function WeaponStateChanged(byte NewState, optional bool bViaReplication)
{
	CurrentWeaponState = NewState;

	// skip if this pawn was recently spawned, so we don't play out-of-date anims when pawns become relevant
	if( `TimeSince(CreationTime) < 1.f )
	{
		return;
	}

	// skip weapon anims while in a special move
	if( IsDoingSpecialMove() && !SpecialMoves[SpecialMove].bAllowThirdPersonWeaponAnims )
	{
		return;
	}

	if( WeaponAttachment != None )
	{
		WeaponAttachment.UpdateThirdPersonWeaponAction( EWeaponState(CurrentWeaponState), self, GetWeaponAttachmentAnimRateByte() );
	}
}


/** Sets the current weapon animation rate to synchronize 3rd person animations with 1st person */
function SetWeaponAttachmentAnimRateByte( float NewAnimRate )
{
	WeaponAttachmentAnimRateByte = FloatToByte( fClamp(NewAnimRate - 1.f, 0.f, 1.f) );
}

/** Returns the animation rate to scale all animations in the WeaponAttachment by */
simulated function byte GetWeaponAttachmentAnimRateByte()
{
	return WeaponAttachmentAnimRateByte;
}

simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	BodyStanceNodes[EAS_CH_UpperBody] = AnimNodeSlot(SkelComp.FindAnimNode('Custom_CH_Upper'));
	BodyStanceNodes[EAS_CH_LowerBody] = AnimNodeSlot(SkelComp.FindAnimNode('Custom_CH_Lower'));

	RecoilNodes[0] = GameSkelCtrl_Recoil(SkelComp.FindSkelControl('SpineRecoil'));
	//RecoilNodes[1] = GameSkelCtrl_Recoil(SkelComp.FindSkelControl('Recoil_Hand'));
}

/** Stops all animations on character */
simulated function StopAllAnimations()
{
	local name FacePose;

	FacePose = DeathFaceAnims[Rand(DeathFaceAnims.Length)];
	PlayBodyAnim(FacePose, EAS_Face,,,, true);

	Super.StopAllAnimations();
}

simulated function CheckAndEndActiveEMoteSpecialMove()
{
	if( IsDoingSpecialMove() && SpecialMove == SM_Emote )
	{
		SpecialMoveHandler.EndSpecialMove( SM_EMote );
	}
}

/*********************************************************************************************
* @name Health
********************************************************************************************* */
simulated function bool CanBeHealed()
{
	return true;
}

`if(`__TW_)
event bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType, optional bool bCanRepairArmor=true, optional bool bMessageHealer=true)
`else
event bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
`endif
{
	local KFPlayerController KFPC;
	local KFPowerUp KFPowerUp;
	local KFGameInfo GameInfo;

	KFPC = KFPlayerController(Controller);
	if ( KFPC != none )
	{
		KFPowerUp = KFPC.GetPowerUp();
		if( KFPowerUp != none && !KFPowerUp.CanBeHealed())
		{
			return false;
		}
	}

	GameInfo = KFGameInfo(WorldInfo.Game);
	if (GameInfo.OutbreakEvent != none && GameInfo.OutbreakEvent.ActiveEvent.bCannotBeHealed)
	{
			return false;
	}

	return HealDamageForce(Amount, Healer, DamageType, bCanRepairArmor, bMessageHealer);
}


event bool HealDamageForce(int Amount, Controller Healer, class<DamageType> DamageType, optional bool bCanRepairArmor=true, optional bool bMessageHealer=true)
{
	local int DoshEarned;
	local float UsedHealAmount;
	local KFPlayerReplicationInfo InstigatorPRI;
	local KFPlayerController InstigatorPC, KFPC;
	local KFPerk InstigatorPerk;
	local class<KFDamageType> KFDT;
    local int i;
    local bool bRepairedArmor;
    local int OldHealth;

    OldHealth = Health;

	InstigatorPC = KFPlayerController(Healer);
	InstigatorPerk = InstigatorPC != None ? InstigatorPC.GetPerk() : None;
	if( InstigatorPerk != None )
	{
		if( bCanRepairArmor )
		{
			// Instigator might be able to repair some armomr
			bRepairedArmor = InstigatorPerk.RepairArmor( self );
		}

		if( InstigatorPerk.GetHealingSpeedBoostActive() )
		{
			UpdateHealingSpeedBoost();
		}

		if( InstigatorPerk.GetHealingDamageBoostActive() )
		{
			UpdateHealingDamageBoost();
		}

		if( InstigatorPerk.GetHealingShieldActive() )
		{
			UpdateHealingShield();
		}
	}

    if( Amount > 0 && IsAliveAndWell() && Health < HealthMax )
    {
		// Play any healing effects attached to this damage type
		KFDT = class<KFDamageType>(DamageType);
		if( KFDT != none && KFDT.default.bNoPain )
		{
			PlayHeal( KFDT );
		}
		else
		{
			`warn("No hit effects et for damagetype:" @DamageType);
		}

    	if( Role == ROLE_Authority )
		{
			if( InstigatorPC == None || InstigatorPC.PlayerReplicationInfo == None )
			{
				return false;
			}

			InstigatorPRI = KFPlayerReplicationInfo(InstigatorPC.PlayerReplicationInfo);
			UsedHealAmount = Amount;
			if( InstigatorPerk != none )
			{
				if( InstigatorPerk.ModifyHealAmount( UsedHealAmount ) )
				{
					if( Controller != Healer && InstigatorPerk.IsHealingSurgeActive() )
					{
						if( InstigatorPC.Pawn != none )
						{
							InstigatorPC.Pawn.HealDamage(InstigatorPC.Pawn.HealthMax * InstigatorPerk.GetSelfHealingSurgePct(), InstigatorPC, class'KFDT_Healing');
						}
					}
				}
			}

			// You can never have a HealthToRegen value that's greater than HealthMax
			if( Health + HealthToRegen + UsedHealAmount > HealthMax )
			{
				UsedHealAmount = HealthMax - (Health + HealthToRegen);
			}

	    	HealthToRegen += UsedHealAmount;
	    	SetTimer(HealthRegenRate, true, nameof( GiveHealthOverTime ));

			// Give the healer money/XP for helping a teammate
		    if( InstigatorPC.Pawn != none && InstigatorPC.Pawn != self )
		    {
			    DoshEarned = ( UsedHealAmount / float(HealthMax) ) * HealerRewardScaler;
				InstigatorPRI.AddDosh(Max(DoshEarned, 0), true);
				InstigatorPC.AddHealPoints( UsedHealAmount );
			}

			if( Healer.bIsPlayer )
			{
				if( Healer != Controller )
		    	{
					InstigatorPC.ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_HealedPlayer, PlayerReplicationInfo );
					KFPC = KFPlayerController(Controller);
					KFPC.ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_HealedBy, Healer.PlayerReplicationInfo );

					`RecordAARIntStat(KFPC, HEAL_RECEIVED, UsedHealAmount);
					`RecordAARIntStat(InstigatorPC, HEAL_GIVEN, UsedHealAmount);
				}
				else
				{
					if( bMessageHealer )
					{
                        InstigatorPC.ReceiveLocalizedMessage( class'KFLocalMessage_Game', GMT_HealedSelf, PlayerReplicationInfo );
                    }
                }
			}

			// don't play dialog for healing done through perk skills (e.g. berserker vampire skill)
			if( bMessageHealer )
			{
			    `DialogManager.PlayHealingDialog( KFPawn(Healer.Pawn), self, float(Health + HealthToRegen) / float(HealthMax) );
			}

            // Reduce burn duration and damage in half if you heal while burning
            for( i = 0; i < DamageOverTimeArray.Length; ++i )
        	{
                if( DamageOverTimeArray[i].DoT_Type == DOT_Fire )
                {
                    DamageOverTimeArray[i].Duration *= 0.5;
                    DamageOverTimeArray[i].Damage *= 0.5;
                    break;
                }
        	}

            if (Health - OldHealth > 0)
            {
                WorldInfo.Game.ScoreHeal(Health - OldHealth, OldHealth, Healer, self, DamageType);
            }

		    return true;
		}
    }

    if (Health - OldHealth > 0)
    {
        WorldInfo.Game.ScoreHeal(Health - OldHealth, OldHealth, Healer, self, DamageType);
    }
	return bRepairedArmor;
}

/** Network: Server only */
function GiveHealthOverTime()
{
	local KFPlayerReplicationInfo KFPRI;

	if( HealthToRegen > 0 && Health < HealthMax )
	{
		Health++;
		HealthToRegen--;

        WorldInfo.Game.ScoreHeal(1, Health - 1, Controller, self, none);

		KFPRI = KFPlayerReplicationInfo( PlayerReplicationInfo );
		if( KFPRI != none )
		{
			KFPRI.PlayerHealth = Health;
			KFPRI.PlayerHealthPercent = FloatToByte( float(Health) / float(HealthMax) );
		}
	}
	else
	{
		HealthToRegen = 0;
	 	ClearTimer( nameof( GiveHealthOverTime ) );
	}
}

/*********************************************************************************************
* @name Armor
********************************************************************************************* */
function AddArmor( int Amount )
{
	Armor = Min( Armor + Amount, GetMaxArmor() );
}

function GiveMaxArmor()
{
	Armor = GetMaxArmor();
}

function int GetMaxArmor()
{
	return MaxArmor; //Perk might adjust that later
}

function ShieldAbsorb( out int InDamage )
{
	local float AbsorbedPct;
	local int AbsorbedDmg;
	local KFPerk MyPerk;

	MyPerk = GetPerk();
	if( MyPerk != none && MyPerk.HasHeavyArmor() )
	{
		AbsorbedDmg = Min(InDamage, Armor);
		Armor -= MyPerk.GetArmorDamageAmount( AbsorbedDmg );
		InDamage -= AbsorbedDmg;
		return;
	}

	// Three levels of armor integrity
	if( Armor >= IntegrityLevel_High )
	{
		AbsorbedPct = ArmorAbsorbModifier_High;
	}
	else if( Armor >= IntegrityLevel_Medium )
	{
		AbsorbedPct = ArmorAbsorbModifier_Medium;
	}
	else
	{
		AbsorbedPct = ArmorAbsorbModifier_Low;
	}

	AbsorbedDmg = Min(Round(AbsorbedPct * InDamage), Armor);
	// reduce damage and armor
	Armor -= AbsorbedDmg;
	InDamage -= AbsorbedDmg;
}

/*********************************************************************************************
* @name Effects / Gore
********************************************************************************************* */
/**
 * Spawn a blood pool decal effect using the GoreManager
 */
simulated function LeaveBloodPool()
{
	local KFGoreManager GoreManager;

	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);

	if( GoreManager != none )
	{
		// Spawn a blood pool
		GoreManager.LeaveABloodPoolDecal(self);
	}
}

simulated function PlayTakeHitEffects( vector HitDirection, vector HitLocation, optional bool bUseHitImpulse = true)
{
	local class<KFDamageType> DmgType;
	local name HitBoneName, RBBoneName;
	local int HitZoneIndex;

	DmgType = HitFxInfo.DamageType;

	if( WorldInfo.TimeSeconds > PainSoundLastPlayedTime + PainSoundCoolDown )
	{
		if( PainSoundChanceOnHit >= (1.f - FRand()) )
		{
			SoundGroupArch.PlayPainSound( self );
			PainSoundLastPlayedTime = WorldInfo.TimeSeconds;
		}
	}

	Super.PlayTakeHitEffects( HitDirection, HitLocation, bUseHitImpulse );

	// @TODO Move to PlayDying()
	// Add some death ragdoll velocity
	if( DmgType != none )
	{
		// If TornOff hasn't been called yet on client, PlayDying now before hit reactions
		if ( bTearOff && !bPlayedDeath )
		{
			PlayDying(HitDamageType,TakeHitLocation);
		}

		if( bPlayedDeath )
		{
			HitZoneIndex = HitFxInfo.HitBoneIndex;
			if ( HitZoneIndex != 255 )	// INDEX_None -> 255 after byte conversion
			{
				HitBoneName = HitZones[HitZoneIndex].BoneName;
			}

			if( HitBoneName != '' )
			{
				RBBoneName = GetRBBoneFromBoneName( HitBoneName );
			}

            if (bUseHitImpulse)
            {
                ApplyRagdollImpulse(DmgType, HitLocation, HitDirection, RBBoneName, 1.f);
            }
		}
	}
}

/** Makes an impact sound and leaves a blood splat upon body impact */
simulated event RigidBodyCollision( PrimitiveComponent HitComponent, PrimitiveComponent OtherComponent,
					const out CollisionImpactData RigidCollisionData, int ContactIndex )
{
	local int i;
	local KFGoreManager GoreManager;
	local RigidBodyContactInfo ContactInfo;

	GoreManager = KFGoreManager(WorldInfo.MyGoreEffectManager);

	if( GoreManager != none && `TimeSince(LastGibCollisionTime) > GoreManager.GetTimeBetweenGibBloodSplats() )
	{
		LastGibCollisionTime = WorldInfo.TimeSeconds;

		if ( OtherComponent != none && OtherComponent.Owner != none && !OtherComponent.Owner.IsA('KFPawn') ) // Skip pawn-on-pawn collisions
	    {
		    SoundGroupArch.PlayRigidBodyCollisionSound( self, RigidCollisionData.ContactInfos[ContactIndex].ContactPosition );

		    for( i=0; i<RigidCollisionData.ContactInfos.length; i++ )
			{
				ContactInfo = RigidCollisionData.ContactInfos[i];
				GoreManager.LeaveAPersistentBloodSplat(ContactInfo.ContactPosition, -ContactInfo.ContactNormal);
				//DrawDebugCoordinateSystem(ContactInfo.ContactPosition, rotator(-ContactInfo.ContactNormal), 10, true);
			}
	    }
	}
}

/** Called clientside by PlayTakeHitEffects on the Instigating Pawn */
simulated function PlayDamageInstigatorHitEffects(KFPawn Victim)
{
	local float BloodParamIncrementValue;

	Super.PlayDamageInstigatorHitEffects(Victim);

	if ( WeaponAttachment != None )
	{
		if ( WorldInfo.NetMode != NM_DedicatedServer &&
			VSizeSq(Victim.Location - Location) < BattleBloodRangeSq )
		{
			BloodParamIncrementValue = RandRange(0.01, 0.05);

			// Amplify blood for killing blows
			if ( WorldInfo.TimeSeconds == Victim.TimeOfDeath )
			{
				BloodParamIncrementValue *= 2.f;
			}

			// Apply blood to body and face
			AddBattleBlood(BloodParamIncrementValue);

			// Apply blood to weapon attachment
			WeaponAttachment.AddBattleBlood(BloodParamIncrementValue);
		}
	}
}

/** Ambient battle blood added to chracter body and face as they kill Zeds */
simulated function AddBattleBlood(float InBattleBloodIncrementvalue)
{
	local MaterialInstanceConstant MIC;
	// Accumulate the blood param value of the pawn
	BattleBloodParamValue = FMax(BattleBloodParamValue + InBattleBloodIncrementvalue, MinBattleBloodValue);

    foreach CharacterMICs(MIC)
    {
		MIC.SetScalarParameterValue(BattleBloodParamName, BattleBloodParamValue);
    }
}

simulated function SetNightVisionLight(bool bEnabled)
{
}

/** Clean up function to terminate any effects on death */
simulated function TerminateEffectsOnDeath()
{
	Super.TerminateEffectsOnDeath();

	if ( Flashlight != None )
	{
		Flashlight.OwnerDied();
	}
}

function PlayPowerUp( class<KFPowerUp> PowerUpType )
{
	PowerUpFxInfo.PowerUpType = PowerUpType;
	PowerUpFxInfo.Count++;
	
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		PlayPowerUpEffect(PowerUpFxInfo);
	}
}

simulated function PlayPowerUpEffect( KFPowerUpFxInfo PUpFxInfo )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Controller);
	if( KFPC != none && PUpFxInfo.PowerUpType != none )
	{
		KFPC.PlayPowerUpEffect(PUpFxInfo.PowerUpType);
	}

	if ( PUpFxInfo.PowerUpType != None )
	{
		PUpFxInfo.PowerUpType.static.PlayEffects(self);
	}
}

function StopPowerUp( class<KFPowerUp> PowerUpType )
{
	PowerUpFxStopInfo.PowerUpType = PowerUpType;
	PowerUpFxStopInfo.Count++;

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		StopPowerUpEffect(PowerUpFxStopInfo);
	}
}

simulated function StopPowerUpEffect( KFPowerUpFxInfo PUpFxInfo )
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(Controller);
	if( KFPC != none )
	{
		KFPC.StopPowerUpEffect(PUpFxInfo.PowerUpType);
	}

	if ( PUpFxInfo.PowerUpType != None && PUpFxInfo.PowerUpType == CurrentPowerUpEffect.PowerUpType && CurrentPowerUpEffect.ParticleEffect != none )
	{
		CurrentPowerUpEffect.ParticleEffect.DeactivateSystem();
		CurrentPowerUpEffect.ParticleEffect = none;
	}
}

/*********************************************************************************************
* @name Damage/Death Methods
********************************************************************************************* */

/* PlayDying() is called on server/standalone game when killed
and also on net client when pawn gets bTearOff set to true (and bPlayedDeath is false)
*/
simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	local class<KFDamageType> KFDT;

	super.PlayDying(DamageType, HitLoc);

	if( AAExplosionActor != none )
	{
		AAExplosionActor.Destroy();
	}

	// If ragdoll was successful
	if ( Physics == PHYS_RigidBody && !Mesh.HiddenGame )
	{
		KFDT = class<KFDamageType>(DamageType);

		// Spawn a blood pool
		SetTimer(BloodPoolDelay,false,nameof(LeaveBloodPool));

		// Death material effect (damage type based)
		PlayDeathMaterialEffects(
			(KFDT != None && KFDT.default.DeathMaterialEffectParamName != '') ? KFDT.default.DeathMaterialEffectParamName : DefaultDeathMaterialEffectParamName,
			(KFDT != None && KFDT.default.DeathMaterialEffectDuration != 0.f) ? KFDT.default.DeathMaterialEffectDuration : DefaultDeathMaterialEffectDuration
			);
	}

	// Kill our world health indicator when we die
	if( PlayerPartyInfo != none )
	{
		PlayerPartyInfo.Close(true);
		PlayerPartyInfo = none;
	}
}

function bool Died(Controller Killer, class<DamageType> damageType, vector HitLocation)
{
	// Don't check if we're surrounded when we're dead
	ClearTimer( nameOf(Timer_CheckSurrounded) );

	if( Super.Died( Killer, DamageType, HitLocation ) )
	{
		`DialogManager.PlayPlayerDeathDialog( self );
		//ProTip: No, you do not have a PRI anymore.
		return true;
	}

	return false;
}

/* AdjustDamage()
adjust damage based on inventory, other attributes
*/
function AdjustDamage(out int InDamage, out vector Momentum, Controller InstigatedBy, vector HitLocation, class<DamageType> DamageType, TraceHitInfo HitInfo, Actor DamageCauser)
{
	local KFPerk MyKFPerk;
	local float TempDamage;
	local bool bHasSacrificeSkill;

	`log(self @ GetFuncName()@"Adjusted Damage BEFORE =" @ InDamage, bLogTakeDamage);
	super.AdjustDamage(InDamage, Momentum, InstigatedBy, HitLocation, DamageType, HitInfo, DamageCauser);

	// nullify damage during trader time
	if (KFGameReplicationInfo(KFGameInfo(WorldInfo.Game).GameReplicationInfo).bTraderIsOpen)
	{
		InDamage = 0;
		return;
	}

	MyKFPerk = GetPerk();
	if( MyKFPerk != none )
	{
		MyKFPerk.ModifyDamageTaken( InDamage, DamageType, InstigatedBy );
		bHasSacrificeSkill = MyKFPerk.ShouldSacrifice();
	}

	TempDamage = InDamage;

	if( TempDamage > 0 && class'KFPerk_Demolitionist'.static.IsDmgTypeExplosiveResistable( DamageType ) && HasExplosiveResistance() )
	{
		class'KFPerk_Demolitionist'.static.ModifyExplosiveDamage( TempDamage );
		TempDamage = TempDamage < 1.f ? 1.f : TempDamage;
	}

	TempDamage *= GetHealingShieldModifier();
	InDamage = Round( TempDamage );

	// Reduce damage based on you current armor integrity
	if( InDamage > 0 && Armor > 0 && DamageType.default.bArmorStops )
	{
		ShieldAbsorb( InDamage );

		//Shield has taken all the damage.  Setup the HitFXInfo for replication so we can
		//		respond to hit through the normal hit FX chain.
		if (InDamage <= 0)
		{
			AddHitFX(InDamage, InstigatedBy, GetHitZoneIndex(HitInfo.BoneName), HitLocation, Momentum, class<KFDamageType>(DamageType));
		}
	}

	if( bHasSacrificeSkill && Health >= 5 && Health - InDamage < 5 )
	{
		Health = InDamage + 5;
		SacrificeExplode();
	}

	// register damage to divide up score
	if( InstigatedBy != none )
	{
		AddTakenDamage( InstigatedBy, FMin(Health, InDamage), DamageCauser, class<KFDamageType>(DamageType) );
	}

	`log(self @ GetFuncName()@"Adjusted Damage AFTER =" @ InDamage, bLogTakeDamage);

	// (Cheats) Dont allow dying if demigod mode is enabled
`if(`__TW_SDK_)
	if ( Controller != none &&  Controller.bDemiGodMode && InDamage >= Health )
	{
		// Increase your health when you are going to get killed... so the amount of damage in semigod is not always just 1...
		// Some ais do different reactions depending on the amount of damaged caused in the last x seconds...
		if ( Health == 1 )
		{
			Health = HealthMax * 0.25f;
		}
		if( InDamage >= Health )
		{
			InDamage = Health - 1;
		}
	}
`endif
}

event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local int ActualDamageTaken, OldHealth, OldArmor;
	//local KFGameInfo KFGI;
	local KFGameReplicationInfo KFGRI;
	local KFPlayerReplicationInfo KFPRI;
	local KFAIController_ZedBoss InstigatedByBoss;

	OldHealth = Health;
	OldArmor  = Armor;
    `log(GetFuncName()@"Damage BEFORE ="$Damage$" DamageType: "$DamageType$" DamageCauser: "$DamageCauser, bLogTakeDamage);

	Super.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser);
	ActualDamageTaken = OldHealth - Health;

	`log(GetFuncName()@"Damage AFTER ="$ActualDamageTaken$" DamageType: "$DamageType$" DamageCauser: "$DamageCauser, bLogTakeDamage);

	KFGRI = KFGameReplicationInfo(KFGameInfo(WorldInfo.Game).GameReplicationInfo);

	if( (ActualDamageTaken > 0 || OldArmor - Armor > 0) && IsAliveAndWell() && !KFGRI.bTraderIsOpen )
	{
		KFPlayerController(Controller).NotifyHitTaken();
	}

	if( ActualDamageTaken > 0 && IsAliveAndWell() )
	{
		CheckAndEndActiveEMoteSpecialMove();

		`DialogManager.PlayPlayerDamageDialog( self, DamageType, ActualDamageTaken );

		InstigatedByBoss = KFAIController_ZedBoss( InstigatedBy );
		if( InstigatedByBoss != none )
		{
			InstigatedByBoss.PlayDamagePlayerDialog( DamageType );
		}
		`RecordAARIntStat(KFPlayerController(Controller), DAMAGE_TAKEN, ActualDamageTaken);
	}

	KFPRI = KFPlayerReplicationInfo( PlayerReplicationInfo );
	if( KFPRI != none )
	{
		KFPRI.PlayerHealth = Health;
		KFPRI.PlayerHealthPercent = FloatToByte( float(Health) / float(HealthMax) );
	}

	ResetIdleStartTime();
}

/** Plays damagetype-specific material effects upon death */
simulated function PlayDeathMaterialEffects(name DamageMICParamName, float Duration)
{
	DeathMaterialEffectTimeRemaining = Duration;
	DeathMaterialEffectDuration = Duration;
	DeathMaterialEffectParamName = DamageMICParamName;
}

/** Update any material effects */
function UpdateDeathMaterialEffect(float DeltaTime)
{
	local float Intensity;
	local MaterialInstanceConstant MIC;

	if( DeathMaterialEffectTimeRemaining > 0.f )
	{
		if( DeathMaterialEffectTimeRemaining > DeltaTime )
		{
			DeathMaterialEffectTimeRemaining -= DeltaTime;
			Intensity = 1.f - fClamp( DeathMaterialEffectTimeRemaining/DeathMaterialEffectDuration, 0.f, 1.f );
		}
		else
		{
			DeathMaterialEffectTimeRemaining = 0.f;
			Intensity = 1.f;
		}

		// Update the materials
		foreach CharacterMICs( MIC )
		{
   			MIC.SetScalarParameterValue( DeathMaterialEffectParamName, Intensity );
   		}
	}
}

/*********************************************************************************************
* @name Perks
********************************************************************************************* */

function SacrificeExplode()
{
	local KFExplosionActorReplicated ExploActor;
	local GameExplosion	ExplosionTemplate;
	local KFPerk_Demolitionist DemoPerk;

	if ( Role < ROLE_Authority )
	{
		return;
	}

	DemoPerk = KFPerk_Demolitionist(GetPerk());

	// explode using the given template
	ExploActor = Spawn(class'KFExplosionActorReplicated', self,, Location,,, true);
	if( ExploActor != None )
	{
		ExploActor.InstigatorController = Controller;
		ExploActor.Instigator = self;

		ExplosionTemplate = class'KFPerk_Demolitionist'.static.GetSacrificeExplosionTemplate();
		ExplosionTemplate.bIgnoreInstigator = true;
		ExploActor.Explode( ExplosionTemplate );

		if( DemoPerk != none )
		{
			DemoPerk.NotifyPerkSacrificeExploded();
		}
	}
}

function StartAirBorneAgentEvent()
{
	local KFGameExplosion AAExplosionTemplate;
	local class<KFExplosion_AirborneAgent> AAExplosionActorClass;

	if( AAExplosionActor != none )
	{
		AAExplosionActor.Destroy();
	}

	AAExplosionTemplate = class'KFPerk_FieldMedic'.static.GetAAExplosionTemplate();
	AAExplosionTemplate.MyDamageType = class'KFPerk_FieldMedic'.static.GetAADamageTypeClass();
	AAExplosionActorClass = class'KFPerk_FieldMedic'.static.GetAAExplosionActorClass();

	AAExplosionActor = Spawn( AAExplosionActorClass, Self,, Location );
	if( AAExplosionActor != None )
	{
		AAExplosionActor.Instigator = self;
		AAExplosionActor.InstigatorController = Controller;
		AAExplosionActor.MyPawn = self;
		AAExplosionActor.SetPhysics( PHYS_NONE );
		AAExplosionActor.SetBase( self,, Mesh );
		AAExplosionActor.Explode( AAExplosionTemplate );
	}
}

simulated function UpdateHealingSpeedBoost()
{
	HealingSpeedBoost = Min( HealingSpeedBoost + class'KFPerk_FieldMedic'.static.GetHealingSpeedBoost(), class'KFPerk_FieldMedic'.static.GetMaxHealingSpeedBoost() );
	SetTimer( class'KFPerk_FieldMedic'.static.GetHealingSpeedBoostDuration(),, nameOf(ResetHealingSpeedBoost) );

	if ( WorldInfo.NetMode == NM_STANDALONE)
	{
		NotifyHealingSpeedBoostBuff(HealingSpeedBoost);
	}
}

simulated function ResetHealingSpeedBoost()
{
	HealingSpeedBoost = 0;

	if( IsTimerActive( nameOf( ResetHealingSpeedBoost ) ) )
	{
		ClearTimer( nameOf( ResetHealingSpeedBoost ) );
	}

	if ( WorldInfo.NetMode == NM_STANDALONE)
	{
		NotifyHealingSpeedBoostBuff(HealingSpeedBoost);
	}
}

simulated function float GetHealingDamageBoostModifier()
{
	return 1 + (float(HealingDamageBoost) / 100);
}

simulated function UpdateHealingDamageBoost()
{
	HealingDamageBoost = Min( HealingDamageBoost + class'KFPerk_FieldMedic'.static.GetHealingDamageBoost(), class'KFPerk_FieldMedic'.static.GetMaxHealingDamageBoost() );
	SetTimer( class'KFPerk_FieldMedic'.static.GetHealingDamageBoostDuration(),, nameOf(ResetHealingDamageBoost) );

	if ( WorldInfo.NetMode == NM_STANDALONE)
	{
		NotifyHealingDamageBoostBuff(HealingDamageBoost);
	}
}

simulated function ResetHealingDamageBoost()
{
	HealingDamageBoost = 0;

	if( IsTimerActive( nameOf( ResetHealingDamageBoost ) ) )
	{
		ClearTimer( nameOf( ResetHealingDamageBoost ) );
	}

	if ( WorldInfo.NetMode == NM_STANDALONE)
	{
		NotifyHealingDamageBoostBuff(HealingDamageBoost);
	}
}

simulated function float GetHealingShieldModifier()
{
	return 1 - (float(HealingShield) / 100);
}

simulated function UpdateHealingShield()
{
	HealingShield = Min( HealingShield + class'KFPerk_FieldMedic'.static.GetHealingShield(), class'KFPerk_FieldMedic'.static.GetMaxHealingShield() );
	SetTimer( class'KFPerk_FieldMedic'.static.GetHealingShieldDuration(),, nameOf(ResetHealingShield) );

	if ( WorldInfo.NetMode == NM_STANDALONE)
	{
		NotifyHealingShieldBoostBuff(HealingShield);
	}
}

simulated function ResetHealingShield()
{
	HealingShield = 0;

	if( IsTimerActive( nameOf( ResetHealingShield ) ) )
	{
		ClearTimer( nameOf( ResetHealingShield ) );
	}

	if ( WorldInfo.NetMode == NM_STANDALONE)
	{
		NotifyHealingShieldBoostBuff(HealingShield);
	}
}

/**
 * @brief Checks if we are close to a demo player with explosivbe resistance skill enabled
 *
 * @return true if close and enabled
 */
protected function bool HasExplosiveResistance()
{
	local KFPawn_Human TestPawn;
	local KFPerk TestPawnPerk;

	foreach WorldInfo.Allpawns( class'KFPawn_Human', TestPawn, Location, class'KFPerk_Demolitionist'.static.GetExplosiveResistanceRadius() )
	{
		TestPawnPerk = TestPawn.GetPerk();
		if( TestPawnPerk != none && TestPawnPerk.IsSharedExplosiveResistaneActive() )
		{
			return true;
		}
	}

	return false;
}

function float GetPerkDoTScaler( optional Controller InstigatedBy, optional class<KFDamageType> KFDT )
{
	local KFPerk MyPerk;
	local float DoTScaler;

	DoTScaler = 1.f;

	MyPerk = GetPerk();
	if( MyPerk != none )
	{
		MyPerk.ModifyBloatBileDoT( DoTScaler );
	}

	return DoTScaler;
}

function array<string> GetUpdatedSkillIndicators()
{
	return ActiveSkillIconPaths;
}

/*********************************************************************************************
* @name Dialog
********************************************************************************************* */
delegate OnFinishedDialog( const out DialogResponseInfo ResponseInfo );

// tip: HandleDialogResponse gets called whenever a dialog AkEvent is stopped, even if it's stopped early (interrupted)
function HandleDialogResponse()
{
	if( Role == ROLE_Authority )
	{
		if( OnFinishedDialog != none )
		{
			if( DlgRespInfo.RespondingToID < 0 || DlgRespInfo.RespondingToID == CurrDialogEventID )
			{
				OnFinishedDialog( DlgRespInfo );
			}
			OnFinishedDialog = none;
		}
	}
}

function SetDialogResponseDelegate( KFPawn Responder, delegate<OnFinishedDialog> ResponseDelegate, optional int ResponseID = -1, optional int RespondingToID = -1 )
{
	DlgRespInfo.Speaker = Responder;
	DlgRespInfo.RespondingToPawn = self;
	DlgRespInfo.EventID = ResponseID;
	DlgRespInfo.RespondingToID = RespondingToID;
	OnFinishedDialog = ResponseDelegate;
}

function UpdateDoshCaught( int Amount, PlayerReplicationInfo Tosser )
{
	if( `TimeSince(LastDoshCaughtTime) < 0.75 && LastDoshCaughtGiver == Tosser ) // @todo: make interval editable
    {
        DoshCaughtStreakAmt += Amount;
    }
    else
    {
        DoshCaughtStreakAmt = Amount;
        LastDoshCaughtGiver = Tosser;
    }

    LastDoshCaughtTime = WorldInfo.TimeSeconds;

    SetTimer( 0.75, false, nameof(CaughtDoshDialogTimer) ); // @todo: make interval editable
}

function CaughtDoshDialogTimer()
{
	`DialogManager.PlayDoshCaughtDialog( self );
	ClearTimer( nameof(CaughtDoshDialogTimer) );
}

function UpdateKillStreak()
{
	if( LastPainTime < LastZedKilledTime )
	{
		ZedsKilledStreakAmt++;
	}
	else
	{
		ZedsKilledStreakAmt = 1;
	}

	LastZedKilledTime = WorldInfo.TimeSeconds;
}

function UpdateDamageTakenStreak( int Amount, float Interval )
{
	if( `TimeSince(LastDamageTakenStreakStartTime) < Interval )
	{
		DamageTakenStreakAmt += Amount;
	}
	else
	{
		DamageTakenStreakAmt = Amount;
		LastDamageTakenStreakStartTime = WorldInfo.TimeSeconds;
	}
}

function UpdateContinuousDamage( KFPawn_Monster DamagedZed, float MaxHitInterval )
{
	if( DamagedZed.LastHitBy != Controller || `TimeSince(DamagedZed.LastPainTime) > MaxHitInterval )
	{
		InitialContinousDamageTime = WorldInfo.TimeSeconds;
	}
}

function ResetIdleStartTime()
{
	local PlayerController PC;
	local KFPawn_Human KFPH;
	local float DistanceToTeammateSq, MaxResetDistanceSq;

	IdleStartTime = WorldInfo.TimeSeconds;

	// reset idle start time for nearby teammates
	// (i.e. consider them no longer idle if they are close enough to you to need to pay attention and not ramble on about the weather)
	MaxResetDistanceSq = 3000 * 3000;
	foreach WorldInfo.AllControllers(Class'PlayerController', PC)
	{
		if( PC == Controller )
		{
			continue;
		}

		KFPH = KFPawn_Human( PC.Pawn );
		if( KFPH == none || !KFPH.IsAliveAndWell() )
		{
			continue;
		}

		DistanceToTeammateSq = VSizeSq( KFPH.Location - Location );
		if( DistanceToTeammateSq <= MaxResetDistanceSq )
		{
			KFPH.IdleStartTime = WorldInfo.TimeSeconds;
		}
	}
}

function float TimeSpentIdling()
{
	return `TimeSince(IdleStartTime);
}

function PlayTraderDialog( AkEvent DialogEvent )
{
    if (bDisableTraderDialog)
    {
        return;
    }

	TraderDialogAkComponent.PlayEvent( DialogEvent );
}

function StopTraderDialog()
{
	if( TraderDialogAkComponent == none )
	{
		return;
	}

	TraderDialogAkComponent.StopEvents();
}

/*********************************************************************************************
* @name Movement Methods
********************************************************************************************* */

function SetSprinting(bool bNewSprintStatus)
{
	if( bIsSprinting || bNewSprintStatus )
	{
		`DialogManager.PlaySprintPantingDialog( self, bNewSprintStatus );
	}

	super.SetSprinting( bNewSprintStatus );
}

function bool DoJump( bool bUpdating )
{
	if( super.DoJump(bUpdating) )
	{
		`DialogManager.PlayJumpDialog( self );
		return true;
	}

	return false;
}

simulated event Bump( Actor Other, PrimitiveComponent OtherComp, Vector HitNormal )
{
	local KFPerk MyPerk;

	if( WorldInfo.TimeDilation < 1.f && !IsZero(Velocity) && Other.GetTeamNum() != GetTeamNum() )
	{
		MyPerk = GetPerk();
		if (MyPerk != none)
		{
			MyPerk.OnBump(Other, self, Velocity, Rotation);
		}
	}
}

/** Checks if we are surrounded and notifies the game conductor */
function Timer_CheckSurrounded()
{
	local KFGameInfo KFGI;

	// Only check surrounded if we still have only one player and if we are below the health threshold
	if( WorldInfo.Game.NumPlayers == 1 && GetHealthPercentage() < MinHealthPctToTriggerSurrounded && IsSurrounded(true, MinEnemiesToTriggerSurrounded, 250.f) )
	{
		KFGI = KFGameInfo( WorldInfo.Game );
		if( KFGI != none && KFGI.GameConductor != none )
		{
			KFGI.GameConductor.NotifySoloPlayerSurrounded();
		}
	}
}

/*********************************************************************************************
* @name Torch (aka Flashlight)
********************************************************************************************* */

/**
* Toggle the flashlight on and off
*/
simulated function ToggleEquipment()
{
	if( IsLocallyControlled() && !bPlayedDeath )
	{
		SetFlashlight(!bFlashlightOn, true);
	}
}

/**
 * Called when there is a need to change the weapon attachment (either via
 * replication or locally if controlled.
 */
simulated function SetFlashlight(bool bEnabled, optional bool bReplicate)
{
	bFlashlightOn = bEnabled;

	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	// So that we don't have to handle viewmode switching just
	// always use the 1st person flashlight for the local player
	if ( !bPlayedDeath )
	{
		Flashlight.UpdateFlashlightFor(self);
	}

	// replicate for third person flashlight
	if( bReplicate && Role == ROLE_AutonomousProxy )
	{
		ServerSetFlashlight(bFlashlightOn);
	}
}

/**
 * Communicates the stage of the third person flashlight is on for clients
 * and servers
 *
 * @param bFlashlightOn whether the flashlight is on or off
 */
reliable server private function ServerSetFlashlight(bool bEnabled)
{
	bFlashlightOn = bEnabled;

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		SetFlashlight(bEnabled, false);
	}
}

simulated function SetIronSights (bool bEnabled, optional bool bReplicate)
{
	bUsingIronSights = bEnabled;

	if (WeaponAttachment != none)
	{
		WeaponAttachment.SetWeaponUsingIronSights (bEnabled);
	}

	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	// replicate for third person Iron Sight
	if( bReplicate && Role == ROLE_AutonomousProxy)
	{
		ServerSetIronSights(bUsingIronSights);
	}
}

reliable server private function ServerSetIronSights(bool bEnabled)
{
	bUsingIronSights = bEnabled;

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		SetIronSights(bEnabled, false);
	}
}

simulated function SetUsingAltFireMode(bool bEnabled, optional bool bReplicate)
{
	bUsingAltFireMode = bEnabled;

	if (WeaponAttachment != none)
	{
		WeaponAttachment.SetWeaponAltFireMode (bEnabled);
	}

	if( WorldInfo.NetMode == NM_DedicatedServer )
	{
		return;
	}

	// replicate for third person Iron Sight
	if( bReplicate && Role == ROLE_AutonomousProxy)
	{
		ServerSetUsingAltFireMode(bUsingAltFireMode);
	}
}

reliable server private function ServerSetUsingAltFireMode(bool bEnabled)
{
	bUsingAltFireMode = bEnabled;

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		SetUsingAltFireMode(bEnabled, false);
	}
}


/** Called when BatteryCharge hits zero */
simulated event NotifyOutOfBattery()
{
	local KFPlayerController KFPC;

	if( IsLocallyControlled() )
	{
		KFPC = KFPlayerController(Controller);
		if( KFPC.bNightVisionActive )
		{
			KFPC.SetNightVision(false);
		}
		if( bFlashlightOn )
		{
			SetFlashlight(false, true);
		}
	}
}

/** First person weapon visility */
simulated function SetFirstPersonVisibility(bool bWeaponVisible)
{
	Super.SetFirstPersonVisibility(bWeaponVisible);

	if ( Flashlight != None )
	{
		Flashlight.SetFirstPersonVisibility(bWeaponVisible);
	}
}

/** Set the lighting channels on all the appropriate pawn meshes */
simulated function SetMeshLightingChannels(LightingChannelContainer NewLightingChannels)
{
	Super.SetMeshLightingChannels(NewLightingChannels);

	if ( Flashlight != None )
	{
		Flashlight.SetLightingChannels(NewLightingChannels);
	}
}

/*********************************************************************************************
 * @state Dying
********************************************************************************************* */

State Dying
{
	simulated function bool CalcCamera( float fDeltaTime, out vector out_CamLoc, out rotator out_CamRot, out float out_FOV )
	{
		local PlayerController PC;
		local matrix HeadMatrix;
		local vector HeadLoc;
		local rotator HeadRot;

		PC = GetALocalPlayerController();

		if( PC.UsingFirstPersonCamera() && !PC.IsSpectating() && PC.ViewTarget == self )
		{
			HeadMatrix = Mesh.GetBoneMatrix( Mesh.MatchRefBone('head') );
			HeadLoc = MatrixGetOrigin( HeadMatrix );
			HeadMatrix = MakeRotationMatrix( rot(0, -16383, 16383) ) * HeadMatrix;
			HeadRot = MatrixGetRotator( HeadMatrix );
			//DrawDebugLine(HeadLoc, HeadLoc + 100*vector(HeadRot), 0, 255, 0);

			out_CamLoc = VInterpTo( out_CamLoc, HeadLoc, fDeltaTime, 10.0 );
			out_CamRot = RInterpTo( out_CamRot, HeadRot, fDeltaTime, 10.0 );

			return true;
		}

		return Global.CalcCamera( fDeltaTime, out_CamLoc, out_CamRot, out_FOV );
	}
}

/*********************************************************************************************
 AEWESOMEHUD(TM)
********************************************************************************************* */
native simulated function		DrawDoors(Canvas Canvas);

/** Hook called from HUD actor. Gives access to HUD and Canvas */
simulated function DrawHUD( HUD H )
{
	local Canvas Canvas;
	local KFPlayerController KFPC;

	Super.DrawHUD(H);

	KFPC = KFPlayerController(Controller);

	if( !H.bShowHUD )
	{
		return;
	}

	if( KFPC != none && KFPC.IsBossCameraMode())
	{
		return;
	}

	// Slightly AWESOMEHUD(TM)
	Canvas = H.Canvas;
	if( Canvas != none )
	{
		DrawDoors(Canvas);
		Canvas.EnableStencilTest(true);
		DrawPerkHUD(Canvas);
		Canvas.EnableStencilTest(false);
	}
}

function DrawPerkHUD(Canvas C)
{
	local KFPerk Perk;

	Perk = GetPerk();
	if( Perk != None )
	{
		Perk.DrawSpecialPerkHUD(C);
	}
}

/**
 * list important Pawn variables on canvas.	 HUD will call DisplayDebug() on the current ViewTarget when
 * the ShowDebug exec is used
 *
 * @param	HUD		- HUD with canvas to draw on
 * @input	out_YL		- Height of the current font
 * @input	out_YPos	- Y position on Canvas. out_YPos += out_YL, gives position to draw text for next debug line.
 */
simulated function DisplayDebug(HUD HUD, out float out_YL, out float out_YPos)
{
	local Canvas	Canvas;

	Super.DisplayDebug(HUD, out_YL, out_YPos);
	Canvas = HUD.Canvas;

	if (HUD.ShouldDisplayDebug('movement'))
	{
		Canvas.SetDrawColor(0,255,255);

		Canvas.DrawText("EncumbranceMod:" @ KFInventoryManager(InvManager).GetEncumbranceSpeedMod());
		out_YPos += out_YL;
		Canvas.SetPos(4,out_YPos);

		Canvas.DrawText("HealthSpeedMod:" @ 1.f - LowHealthSpeedPenalty, FALSE);
		out_YPos += out_YL;
		Canvas.SetPos(4,out_YPos);
	}
}

simulated function NotifyHealingSpeedBoostBuff(byte Speed)
{
	if( Role == ROLE_Authority )
	{
		HealingSpeedBoost = Speed;
		bForceNetUpdate   = true;
	}

	if( IsLocallyControlled() )
	{
		UpdateActiveSkillsPath(class'KFPerk_FieldMedic'.default.PerkSkills[EMedicHealingSpeedBoost].IconPath, Speed > 0.0f);
	}
}

simulated function NotifyHealingDamageBoostBuff(byte Damage)
{
	if( Role == ROLE_Authority )
	{
		HealingSpeedBoost = Damage;
		bForceNetUpdate   = true;
	}

	if( IsLocallyControlled() )
	{
		UpdateActiveSkillsPath(class'KFPerk_FieldMedic'.default.PerkSkills[EMedicHealingDamageBoost].IconPath, Damage > 0.0f);
	}
}

simulated function NotifyHealingShieldBoostBuff(byte Shield)
{
	if( Role == ROLE_Authority )
	{
		HealingSpeedBoost = Shield;
		bForceNetUpdate   = true;
	}

	if( IsLocallyControlled() )
	{
		UpdateActiveSkillsPath(class'KFPerk_FieldMedic'.default.PerkSkills[EMedicHealingShield].IconPath, Shield > 0.0f);
	}
}

function UpdateActiveSkillsPath(string IconPath, bool Active)
{
	local KFPlayerController KFPC;

	if(Active)
	{
		if (ActiveSkillIconPaths.Find(IconPath) == INDEX_NONE)
		{
			ActiveSkillIconPaths.AddItem(IconPath);
		}
	}
	else
	{
		ActiveSkillIconPaths.RemoveItem(IconPath);
	}

	KFPC = KFPlayerController(Controller);
	KFPC.MyGFxHUD.PlayerStatusContainer.ShowActiveIndicators(ActiveSkillIconPaths);
}

event Landed(vector HitNormal, actor FloorActor)
{
	local KFPlayerController_WeeklySurvival KFPC;

	super.Landed(HitNormal, FloorActor);

	if (KFPawn_Monster(FloorActor) == none)
	{
		KFPC = KFPlayerController_WeeklySurvival(Controller);
		if (KFPC != none)
		{
			KFPC.ResetGoompaStreak();
		}
	}
}

// Used for override aesthetics
client reliable function ClientOverrideHumanDefaults()
{
	local KFPlayerController_WeeklySurvival KFPC_WS;
    local KFPlayerReplicationInfo KFPRI;
	local KFGameReplicationInfo KFGRI;
	local KFCharacterInfo_Human KFCIH;
    local int CowboyHatIndex;

	KFPC_WS = KFPlayerController_WeeklySurvival(Controller);
	if (KFPC_WS == none)
	{
		return;
	}

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);
	
	if (KFGRI != none && KFGRI.CurrentWeeklyIndex == 12)		
    {
		KFPRI = KFPlayerReplicationInfo(KFPC_WS.PlayerReplicationInfo);
		if (KFPRI != none)
		{
			KFCIH = KFPRI.CharacterArchetypes[KFPRI.RepCustomizationInfo.CharacterIndex];
			CowboyHatIndex = class'KFGFxMenu_Gear'.static.FindCowboyHatAttachmentIndex(KFCIH);
			if (CowboyHatIndex >= 0)
			{
				KFCIH.DetachConflictingAttachments(CowboyHatIndex, self, KFPRI);
				KFPRI.SetWeeklyCharacterAttachment(CowboyHatIndex, 0);
			}
		}
    }
}

defaultproperties
{
	Begin Object Class=KFFlashlightAttachment name=Flashlight_0
        LightConeMesh=StaticMesh'wep_flashlights_mesh.WEP_3P_Lightcone'
       	AttachmentMesh=StaticMesh'wep_flashlights_mesh.PlayerLight_MESH'
    End Object
	FlashLightTemplate=Flashlight_0

	// ---------------------------------------------
	// Hit Zones
	HitZones.Add((ZoneName=head,BoneName=Head))
	HitZones.Add((ZoneName=neck,BoneName=Neck))
	HitZones.Add((ZoneName=chest,BoneName=Spine2))
	HitZones.Add((ZoneName=heart,BoneName=Spine2))
	HitZones.Add((ZoneName=lupperarm,BoneName=LeftArm))
	HitZones.Add((ZoneName=lforearm,BoneName=LeftForearm))
	HitZones.Add((ZoneName=lhand,BoneName=LeftForearm))
	HitZones.Add((ZoneName=rupperarm,BoneName=RightArm))
	HitZones.Add((ZoneName=rforearm,BoneName=RightForearm))
	HitZones.Add((ZoneName=rhand,BoneName=RightForearm))
	HitZones.Add((ZoneName=stomach,BoneName=Spine1))
	HitZones.Add((ZoneName=abdomen,BoneName=Hips))
	HitZones.Add((ZoneName=lthigh,BoneName=LeftUpLeg))
	HitZones.Add((ZoneName=lcalf,BoneName=LeftLeg))
	HitZones.Add((ZoneName=lfoot,BoneName=LeftLeg))
	HitZones.Add((ZoneName=rthigh,BoneName=RightUpLeg))
	HitZones.Add((ZoneName=rcalf,BoneName=RightLeg))
	HitZones.Add((ZoneName=rfoot,BoneName=RightLeg))

	Begin Object Name=KFPawnSkeletalMeshComponent
		bPerBoneMotionBlur=false
	End Object

	// Gore
	BattleBloodParamName=Scalar_Blood_Contrast
	MinBattleBloodValue=0.20f
	BattleBloodRangeSq=40000.f	/* 2 sq. m */
	DeathMaterialEffectDuration=0.1f
	DeathMaterialEffectParamName=scalar_dead

	// ---------------------------------------------
	// Movement / Physics
	GroundSpeed=383.f
	SprintSpeed=460.f
	bCanCrouch=true
	// PHYS_Falling
	JumpZ=650.f
	AirControl=+0.15

	bEnableAimOffset=true

	CrouchRadius=+40.0
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0040.000000
	End Object

	TeammateCollisionRadiusPercent=0.50

    // ---------------------------------------------
	// Sounds
	Begin Object Class=AkComponent name=TraderDialogAkSoundComponent
        BoneName=Root
        bForceOcclusionUpdateInterval=true
		OcclusionUpdateInterval=0.f // never update occlusion for trader dialog
    End Object
    TraderDialogAkComponent=TraderDialogAkSoundComponent
    Components.Add(TraderDialogAkSoundComponent)

	PainSoundChanceOnHit=1.f
	PainSoundCoolDown=1.f

	// ---------------------------------------------
	// Health
	HealthRegenRate=0.1
	HealerRewardScaler=60.0f

	// ---------------------------------------------
	// Solo Surrounded Difficulty Reduction
	MinEnemiesToTriggerSurrounded=2
	MinHealthPctToTriggerSurrounded=0.95

	// ---------------------------------------------
	// Armor
	IntegrityLevel_High=75
	IntegrityLevel_Medium=50
	IntegrityLevel_Low=25

	MaxArmor=100
	ArmorAbsorbModifier_High=0.75
	ArmorAbsorbModifier_Medium=0.65
	ArmorAbsorbModifier_Low=0.55

	bCanPickupInventory=true

	// Flashlight Battery
	BatteryCharge=100
	BatteryDrainRate=0.8f //2.
	BatteryRechargeRate=6.f
	NVGBatteryDrainRate=0.8f

	IncapSettings(AF_FirePanic)=(Vulnerability=(50.f), Cooldown=0.0, Duration=1.0)

	DeathFaceAnims=(Death_V1, Death_V2, Death_V3)

	PerkFXEmitterPoolClassPath="KFGame.KFPerkFXEmitterPool"

	// ---------------------------------------------
	// Special moves
	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_GrappleVictim)=class'KFGame.KFSM_GrappleVictim'
        SpecialMoveClasses(SM_DisabledGrappleVictim)=class'KFGame.KFSM_DisabledGrappleVictim'
		SpecialMoveClasses(SM_HansGrappleVictim)=class'KFGame.KFSM_HansGrappleVictim'
		SpecialMoveClasses(SM_Emote)=class'KFGame.KFSM_Player_Emote'
		SpecialMoveClasses(SM_DARGrappleVictim)=class'KFGame.KFSM_EvilDAR_EMPGrapple'
		SpecialMoveClasses(SM_BloatKingGorgeVictim)=class'KFGame.KFSM_BloatKingGorgeVictim'
	End Object
}
