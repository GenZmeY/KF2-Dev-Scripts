//=============================================================================
// KFPawnAnimInfo
//=============================================================================
// Contains information on using a character specific AnimSet. Since UObjects
// don't support static members, we can use abstract/archetype.
// Relates to KFPawnSoundGroup, but uses archetype for editability
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFPawnAnimInfo extends Object
	hidecategories(Object)
	editinlinenew;

/*********************************************************************************************
 * @name	 Attack Animations
 *********************************************************************************************/

enum EAttackRating
{
	AR_Weak,
	AR_Medium,
	AR_Strong
};

struct AttackAnimInfo
{
	/** Optional attack name for quick reference */
	var() const name Tag;
	/** Animation names/variants */
	var() const array<Name> Anims;

	/** If set, enable root motion for this attack */
	var() const bool bUseRootMotion;
	/** If set, play on the upper body (note: UpperBody and RootMotion are exclusive) */
	var() const bool bPlayUpperBodyOnly;
	/** If set, can be canceled by other actions (e.g. stumble).  Use with caution if RootMotion is enabled! */
	var() const bool bIsInterruptible;
	/** If Interruptible, is this attack affected by parry stumble */
	var() const bool bCannotBeParried<EditCondition=bIsInterruptible>;
	/** If set, this attack will not be able to be pushed around by damage impulses */
	var() const bool bNoDamageImpulses;
	/** If set, only perform this attack while sprinting */
	var() const bool bOnlyWhileSprinting;
	/** If set, only perform this attack while not sprinting */
	var() const bool bOnlyWhileNotSprinting;
	/** If set, only perform this attack when enemy is moving */
	var() const bool bOnlyWhileEnemyMoving;
	/** If set, only perform this attack when enemy is stationary */
	var() const bool bOnlyWhileEnemyNotMoving;
	/** If set, only perform this attack when surrounded */
	var() const bool bOnlyWhileSurrounded;
	/** If set, this pawn has cloaking */
	var() const bool bHasCloaking;
	/** If set, only performs this attack when cloaked */
	var() const bool bOnlyWhileCloaked<EditCondition=bHasCloaking>;
	/** If set, only perform this attack when uncloaked */
	var() const bool bOnlyWhileDeCloaked<EditCondition=bHasCloaking>;
	/** The radius around the AI pawn to determine if surrounded */
	var() const float SurroundedRadius<EditCondition=bOnlyWhileSurrounded | ClampMin=1>;
	/** The minimum number of players that need to surround AI pawn for this attack to be considered */
	var() const int MinSurroundedBy<EditCondition=bOnlyWhileSurrounded | ClampMin=2>;
	/** If set, attack only usable when AI using custom mode/ability ("e.g, FleshPound rage, siren cloak, etc.") */
	var() const bool bOnlyWhileInSpecializedMode;
	/** If set, attack only usable when AI NOT using custom mode/ability ("e.g, FleshPound rage, siren cloak, etc.") */
	var() const bool bOnlyWhileNotInSpecializedMode;
	/** If set, use this EXCLUSIVELY when headless */
	var() const bool bOnlyWhileHeadless;
	/** If set, attack requires a clear path to enemy (no leg obstructions) to perform this anim */
	var() const bool bOnlyWhilePathClear;
	/** If set along with BattlePhaseMinimum, determines the battle phases this attack is allowed in (Bosses only) */
	var() const bool bIsBattlePhaseAttack;
	/** The minimum battle phase a boss must be at for this attack to be allowed */
	var() const int BattlePhaseMinimum<EditCondition=bIsBattlePhaseAttack | ClampMin=1>;
	/** The maximum battle phase a boss can be at to use this attack */
	var() const int BattlePhaseMaximum<EditCondition=bIsBattlePhaseAttack>;

	/** Chance this attack will be considered */
	var() const float Chance<ClampMin=0.0>;
	/** If > 0, will not target distance enemies */
	var() const float MaxDistance<ClampMin=0.0>;
	/** If > 0 and bUseRootMotion, will not target nearby enemies */
	var() const float MinDistance<ClampMin=0.0>;
	/** If > 0, no characters of this type can perform this attack */
	var() const float GlobalCooldown<ClampMin=0.0>;
	/** Create and manage an instanced (per zed) cooldown timer */
	var const float InstancedCooldown<ClampMin=0.0>;

	/** Attack rating that can be filtered by difficulty */
	var() const EAttackRating DifficultyRating;
	/** example: If DiffultyRating is weak and GameDifficulty allows medium attacks then ignore */
	var() const bool bSkipIfDifficultyIsExceeded;

	/** Global (any character of this type) picked this animation */
	var transient float LastTimePlayed;

	structdefaultproperties
	{
		//Priority=1.f
		Chance=1.f
		SurroundedRadius=200.f
		BattlePhaseMinimum=1
		BattlePhaseMaximum=4
		MinSurroundedBy=3
	}
};

struct sTheatricAnimInfo
{
	var() const Name AnimationName;
	var() const CameraAnim CameraAnimation;
	var() const vector CameraAnimOffset;
};

var(Attacks) array<AttackAnimInfo> Attacks<DisplayName=MeleeAttacks>;

/** list of attack anim variants used on doors */
var(Attacks) array<Name> DoorAttacks;

/** If checked, allow game difficulty to modify attack selection */
var(Attacks) bool bEnableDifficultyScaling;
/** Chance of allowing this type of attack for a given difficulty */
var	transient float	WeakAttackChance;
var	transient float	MediumAttackChance;
var	transient float	HardAttackChance;

var(Debug) bool		bDebugLog;

/*********************************************************************************************
 * @name	 Hit Reaction Animation
 *********************************************************************************************/

enum EHitReactionAnimType
{
	HIT_Light,	// AdditiveHitReaction
	HIT_Medium,
	HIT_Heavy, // CauseStumble, HighKickDeathAnimation, FullBodyHitReaction
};

struct native AnimVariants
{
	var() array<Name> Anims;
};

/** array entry for each HitZoneGruop */
var(HitReaction) const array<AnimVariants> LightHitAnims;
var(HitReaction) const array<AnimVariants> MediumHitAnims<DisplayName=GunHitAnims>;
var(HitReaction) const array<AnimVariants> HeavyHitAnims<DisplayName=MeleeHitAnims>;

var(HitReaction) const array<name> DmgOverTimeHitAnims;

var(HitReaction) bool bCanPlayAnimHitReactions;

/** Anims for stumble special move
	0: Body_Forward,
	1: Body_Backward,
	2: Body_Left,
	3: Body_Right,
	4: Leg_L_Forward,
	5: Leg_L_Backward,
	6: Leg_L_Left,
	7: Leg_L_Right,
	8: Leg_R_Forward,
	9: Leg_R_Backward,
	10: Leg_R_Left,
	11: Leg_R_Right,
	12: Parry
*/
var(HitReaction) editfixedsize array<AnimVariants> StumbleAnims;

/*********************************************************************************************
 * @name	 Physics Hit Reactions
 *********************************************************************************************/

/** If Pawn can or cannot play physics hit reactions. */
var(HitReaction) editconst bool bCanPlayPhysicsHitReactions;

/*********************************************************************************************
 * @name	 Death Animations
 *********************************************************************************************/

struct native DeathAnimInfo
{
	/** Bone name to use these anims with */
	var() const name BoneName;

	/** Animation names/variants */
	var() const array<Name> Anims_F;
	var() const array<Name> Anims_B;
	var() const array<Name> Anims_L;
	var() const array<Name> Anims_R;
	var() const array<Name> DismemberedAnims;

	/** Chance no death animation will be selected */
	var() const float RagdollChance<ClampMin=0.0>;
	/** (Body Part Death) Chance the generic death will be selected */
	var() const float IgnoreChance<ClampMin=0.0>;

	structdefaultproperties
	{
		IgnoreChance=0.1f
	}
};

/** Default death animation list */
var(Death) const DeathAnimInfo DefaultDeathAnims;

/** Death animas used by weapons with high kickback (explosives) */
var(Death) const DeathAnimInfo ExplosiveDeathAnims;

/** Death anims used when shot in specific location */
var(Death) const array<DeathAnimInfo> BodyPartDeathAnims;

/** Random chance that this death with play a hit zone specific animation */
//var(Death) const float BodyPartDeathChance;

/** If set, this actor can play death animations */
var(Death) const bool bCanPlayDeathAnimations;

/** Global (for this character) tracking of previous animation */
var transient byte LastDeathAnimIndex;

/** temp */
var(Death) const Vector2D DeathPhysMotorStrength;

/*********************************************************************************************
 * @name	 Taunt Animations
 *********************************************************************************************/

/** List of randomly selected taunt anims */
var(Taunt)	array<name>	TauntAnims;
var(Taunt)	array<name>	TauntKillAnims;
var(Taunt)	array<name>	TauntEnragedAnims;

/*********************************************************************************************
 * @name	 Theatric Boss Animations
 *********************************************************************************************/
var(BossTheatrics)	array<sTheatricAnimInfo>	TheatricBossEntranceAnimInfos;
var(BossTheatrics)	array<sTheatricAnimInfo>	TheatricBossVictoryAnimInfos;

/*********************************************************************************************
 * @name	 Melee attack anim helpers
 *********************************************************************************************/

/** Finds a attack info by index. */
function name InitMeleeSpecialMove(KFSM_MeleeAttack InSpecialMove, int Index, int Variant)
{
	local name AnimName;

	AnimName = Attacks[Index].Anims[Variant];

	if ( AnimName == '' )
	{
		`log(self@GetFuncName()@"failed to find a valid attack");
	}

	// if a special move is passed in set up the flags based on this attack.  This is a little bit reverse
	// logic, but it gets around having to pass the AttackAnimInfo structs by value all over script
	if ( InSpecialMove != None )
	{
		InSpecialMove.bUseRootMotion = Attacks[Index].bUseRootMotion;
		InSpecialMove.bCanBeInterrupted = Attacks[Index].bIsInterruptible;
		InSpecialMove.bCannotBeParried = Attacks[Index].bCannotBeParried;
		InSpecialMove.bAllowMomentumPush = !Attacks[Index].bNoDamageImpulses;
	}

	return AnimName;
}

/** Finds a attack animation by name */
function Name ChooseAttackByName(name AttackName, optional KFPawn_Monster Instigator, optional Actor Target, optional out byte outFlags)
{
	local int idx, variant;

	idx = Attacks.Find('Tag', AttackName);

	if ( idx != INDEX_NONE )
	{
		// if there is an instigator, check to see if this is a valid attack
		if ( Instigator != None && !CanDoAttackAnim(idx, Instigator, Target) )
		{
			return '';
		}

		variant = Rand(Attacks[idx].Anims.Length);

		// update the global cooldown
		if ( Attacks[idx].GlobalCooldown > 0 )
		{
			Attacks[idx].LastTimePlayed = class'Engine'.static.GetCurrentWorldInfo().TimeSeconds;
		}

		outFlags = (idx + (variant << 4));
		return Attacks[idx].Anims[variant];
	}

	`log(self@GetFuncName()@"failed to find a valid attack");
	return '';
}

/** Chooses a valid (random) attack animation */
function int ChooseNextStrike(KFPawn Instigator, optional Actor Target)
{
	local int i;
	local array<int> IndexList;

	// Add up the total weight for all valid attacks
	for(i = 0; i < Attacks.Length; i++)
	{
		if ( CanDoAttackAnim(i, Instigator, Target) )
		{
			IndexList.AddItem(i);
		}
	}

	// If we have valid animations to choose from
	if ( IndexList.Length > 0 )
	{
		// return one of the possible attacks
		return IndexList[Rand(IndexList.Length)];
	}
	return 255;
}

function UpdateAttackCooldown( KFAIController KFAIC, byte DesiredStrikeIndex )
{
	// update the global cooldown
	if( Attacks[DesiredStrikeIndex].GlobalCooldown > 0 )
	{
		Attacks[DesiredStrikeIndex].LastTimePlayed = class'Engine'.static.GetCurrentWorldInfo().TimeSeconds;
	}

	// Assume attack is going to play, if a cooldown is set handle it here
	if( Attacks[DesiredStrikeIndex].InstancedCooldown > 0 )
	{
		/** Once attack has been selected activate a cooldown time on the owning pawn */
		KFAIC.AddCooldownTimer(Attacks[DesiredStrikeIndex].Tag, Attacks[DesiredStrikeIndex].InstancedCooldown);
	}

	// Let the Game Conductor know an attack happened
	if( KFAIC != none && KFGameInfo(KFAIC.WorldInfo.Game) != none && KFGameInfo(KFAIC.WorldInfo.Game).GameConductor != none )
	{
	   KFGameInfo(KFAIC.WorldInfo.Game).GameConductor.UpdateOverallAttackCoolDowns(KFAIC);
	}
}

/** Find the min/max range of each Tag (attack category) defined in my KFPawn_AnimGroup. Used to determine when
	a zed should consider attacking */
function float GetAttackRange( KFAIController KFAIC )
{
	local int TagIdx;
	local float MaxAttackRange;

	for( TagIdx = 0; TagIdx < Attacks.Length; TagIdx++ )
	{
		if( Attacks[TagIdx].Tag == '' )
		{
			continue;
		}

		if( MaxAttackRange == 0 || (Attacks[TagIdx].MaxDistance > MaxAttackRange) )
		{
			MaxAttackRange = Attacks[TagIdx].MaxDistance;
		}
	}

	return MaxAttackRange;
}

/** Find the min/max range of each Tag (attack category) defined in my KFPawn_AnimGroup. This is per-Tag,
 *  not per attack animation, and is used to pre-determine if any of the attacks for a Tag is within range. */
function float GetMedianStrikeRange( byte MeleeAttackIndex, float StrikeRangePercentage, float CollisionRadius )
{
	local float MinMeleeRange, MaxMeleeRange;

	MaxMeleeRange = Attacks[MeleeAttackIndex].MaxDistance;
	MinMeleeRange = Attacks[MeleeAttackIndex].MinDistance;

	if( MinMeleeRange < CollisionRadius )
	{
		MinMeleeRange = CollisionRadius;
	}

	return MinMeleeRange + (MaxMeleeRange - MinMeleeRange) * StrikeRangePercentage;
}

function int GetAttackIndexByTag( name AttackTag )
{
	return Attacks.Find('Tag', AttackTag);
}

function name GetAttackAnimName( int AttackIndex, byte VariantIndex )
{
	return Attacks[AttackIndex].Anims[VariantIndex];
}

function byte GetStrikeFlags(int DesiredStrikeIndex)
{
	local int Variant;

	if( DesiredStrikeIndex > Attacks.length )
	{
		return 255;
	}

	// Get a random animation (random variant)
	Variant = Rand(Attacks[DesiredStrikeIndex].Anims.Length);
	return (DesiredStrikeIndex + (variant << 4));
}

/** Ensures that LastTimePlayed is never greater than world time */
function CheckForValidCooldown( int AtkIdx )
{
	if( class'WorldInfo'.static.GetWorldInfo().TimeSeconds < Attacks[AtkIdx].LastTimePlayed )
	{
		`log("[ANIMINFO] WorldInfo.TimeSeconds mismatch! Resetting cooldowns.");
		Attacks[AtkIdx].LastTimePlayed = 0.f;
	}
}

/** Checks the AttackAnimInfo to see if this attack is valid to perform */
function bool CanDoAttackAnim(int Idx, KFPawn P, optional Actor Target)
{
	local AttackAnimInfo Attack;

	// Solve edge case where world time has reset but LastUsedTime hasn't
	CheckForValidCooldown( Idx );

	Attack = Attacks[Idx];

	if ( Attack.Anims.Length <= 0 )
	{
		`log(self@"CanDoAttackAnim missing attack anim names for"@Attacks[Idx].Tag);
		return false;
	}

	if( Attack.bOnlyWhilePathClear && P.MyKFAIC.bIsBodyBlocked )
	{
		`log( P@GetFuncName()$"() rejecting attack idx "$idx$" because bOnlyWhilePathClear is true but Pawn is blocked", bDebugLog );
		return false;
	}

	if( Attack.bHasCloaking && (Attack.bOnlyWhileCloaked && !P.bIsCloaking) || (Attack.bOnlyWhileDeCloaked && P.bIsCloaking) )
	{
		`log( P@GetFuncName()$"() rejecting attack idx "$idx$" because it is not allowed in this cloaking state", bDebugLog );
		return false;
	}

	if( Attack.bIsBattlePhaseAttack && (P.GetCurrentBattlePhase() < Attack.BattlePhaseMinimum || P.GetCurrentBattlePhase() > Attack.BattlePhaseMaximum) )
	{
		`log( P@GetFuncName()$"() rejecting attack idx "$idx$" because not allowed in this Battle Phase", bDebugLog );
		return false;
	}

	if( P.MyKFAIC != none && !P.MyKFAIC.CheckOverallCooldownTimer())
	{
		`AILog_Ext( GetFuncName()$"() PREVENTING attack "$Attack.Tag$" because Overall Cooldown is active", 'Command_Attack_Melee', P.MyKFAIC );
		return false;
	}

	if ( Attack.GlobalCooldown > 0 && Attack.LastTimePlayed > 0.f
		&& `TimeSinceEx(P, Attack.LastTimePlayed) < Attack.GlobalCooldown )
	{
		`log( P@GetFuncName()$"() rejecting attack idx "$idx$" because GlobalCooldown ("$Attack.GlobalCooldown$") LastTimePlayed:"$`TimeSinceEx(P, Attack.LastTimePlayed), bDebugLog );
		return false;
	}
	if ( Attack.Chance < 1.f && FRand() > Attack.Chance )
	{
		`log( P@GetFuncName()$"() rejecting attack idx "$idx$" because random chance missed (Chance:"$Attack.Chance$")", bDebugLog );
		return false;
	}

	if( !AllowAttackByMovement( Idx, P ) )
	{
		return false;
	}

	if ( Attack.bOnlyWhileHeadless != P.ShouldPlayHeadlessMeleeAnims() )
	{
		`log( P@GetFuncName()$"() rejecting attack idx "$idx$" because bOnlyWhileHeadless is true but Pawn has a head", bDebugLog );
		return false;
	}

	if ( Attack.InstancedCooldown > 0 && IsAttackOnCooldown(P, Attack.Tag, Attack.InstancedCooldown) )
	{
		`log( P@GetFuncName()$"() rejecting attack idx "$idx$" because Cooldown is still active", bDebugLog );
		return false;
	}

	if ( Attack.bOnlyWhileSurrounded && !P.IsSurrounded(true, Attack.MinSurroundedBy, Attack.SurroundedRadius) )
	{
		`log( P@GetFuncName()$"() rejecting attack idx "$idx$" because pawn is not surrounded", bDebugLog );
		return false;
	}

	if ( Target != None )
	{
		if ( Attack.bOnlyWhileEnemyMoving && IsZero(Target.Velocity) )
		{
			`log( P@GetFuncName()$"() rejecting attack idx "$idx$" because target velocity is 0", bDebugLog );
			return false;
		}
		else if ( Attack.bOnlyWhileEnemyNotMoving && !IsZero(Target.Velocity) )
		{
			`log( P@GetFuncName()$"() rejecting attack idx "$idx$" because target velocity is not 0", bDebugLog );
			return false;
		}

		if ( Attack.MaxDistance > 0 && VSizeSq(P.Location - Target.Location) > Square(Attack.MaxDistance) )
		{
			`log( P@GetFuncName()$"() rejecting attack idx "$idx$" because target dist ("$VSize(P.Location - Target.Location)$") is greater than "$Attack.MaxDistance, bDebugLog );
			return false;
		}
		if ( Attack.MinDistance > 0 && VSizeSq(P.Location - Target.Location) < Square(Attack.MinDistance) )
		{
			`log( P@GetFuncName()$"() rejecting attack idx "$idx$" because target dist is less than "$Attack.MinDistance, bDebugLog );
			return false;
		}
	}

	if ( !AllowAttackByDifficulty(Idx) )
	{
		if( P.MyKFAIC != none )
		{
			`AILog_Ext( GetFuncName()$"() PREVENTING attack "$Attack.Tag$" because it has a DifficultyRating of "$Attack.DifficultyRating, 'Command_Attack_Melee', P.MyKFAIC );
		}
		return false; // do this last so perf is consistant
	}

	return true;
}

/** Return true if this attack was recently used and has a cooldown timer */
function bool IsAttackOnCooldown(KFPawn P, name CooldownTag, float CooldownTime)
{
	if ( P.MyKFAIC != None )
	{
		return !P.MyKFAIC.CheckCooldownTimer(CooldownTag);
	}

	return false;
}

/** Returns the range of an attack for AI behavior modification */
function Vector2D GetAttackRangeByName(name AttackName)
{
	local int idx;

	idx = Attacks.Find('Tag', AttackName);
	if ( idx != INDEX_NONE )
	{
		return vect2d(Attacks[Idx].MinDistance, Attacks[Idx].MaxDistance);
	}

	return vect2d(0,0);
}

/** Returns the range of an attack for AI behavior modification */
function Vector2D GetAttackRangeExtent(name AttackName)
{
	local int i;
	local float MinRange, MaxRange;

	MinRange = MAXINT;

	// Find smallest min and greatest max
	for(i = 0; i < Attacks.Length; i++)
	{
		if ( Attacks[i].Chance > 0.f )
		{
			MinRange = Min(MinRange, Attacks[i].MinDistance);
			MaxRange = Max(MaxRange, Attacks[i].MaxDistance);
		}
	}

	return vect2d(MinRange,MaxRange);
}

/*********************************************************************************************
 * @name	 Difficulty Scaling
 *********************************************************************************************/

/** Cache any values from the difficulty info that we may be using */
function SetDifficultyValues( KFGameDifficultyInfo DifficultyInfo )
{
	WeakAttackChance = DifficultyInfo.GetWeakAttackChance();
	MediumAttackChance = DifficultyInfo.GetMediumAttackChance();
	HardAttackChance = DifficultyInfo.GetHardAttackChance();
}

function bool AllowAttackByMovement( byte Idx, KFPawn P )
{
	if ( Attacks[Idx].bOnlyWhileSprinting && !P.bIsSprinting )
	{
		`log( P@GetFuncName()$"() rejecting attack idx "$idx$" because bOnlyWhileSprinting is true but Pawn is not sprinting", bDebugLog );
		return false;
	}
	else if ( Attacks[Idx].bOnlyWhileNotSprinting && P.bIsSprinting )
	{
		`log( P@GetFuncName()$"() rejecting attack idx "$idx$" because bOnlyWhileNotSprinting is true but Pawn is sprinting", bDebugLog );
		return false;
	}

	if( Attacks[Idx].bOnlyWhileInSpecializedMode && !P.ShouldPlaySpecialMeleeAnims() )
	{
		`log( P@GetFuncName()$"() rejecting attack idx "$idx$" because bOnlyWhileInSpecializedMode is true but Pawn not in SpecializedMode", bDebugLog );
		return false;
	}
	else if( Attacks[Idx].bOnlyWhileNotInSpecializedMode && P.ShouldPlaySpecialMeleeAnims() )
	{
		`log( P@GetFuncName()$"() rejecting attack idx "$idx$" because bOnlyWhileNotInSpecializedMode is true but Pawn is in SpecializedMode", bDebugLog );
		return false;
	}
	return true;
}

function bool AllowAttackByDifficulty( byte Index )
{
	if ( bEnableDifficultyScaling )
	{
 		switch ( Attacks[Index].DifficultyRating )
 		{
 	 		case AR_Weak:
				if ( MediumAttackChance >= WeakAttackChance && Attacks[Index].bSkipIfDifficultyIsExceeded )
					return false;
				return 	(WeakAttackChance >= 1.f || FRand() < WeakAttackChance);
 	 		case AR_Medium:
				if ( HardAttackChance >= MediumAttackChance && Attacks[Index].bSkipIfDifficultyIsExceeded )
					return false;
				return  (MediumAttackChance >= 1.f || FRand() < MediumAttackChance);
 	 		case AR_Strong:
				return  (HardAttackChance >= 1.f || FRand() < HardAttackChance);
 		}
	}

	return true;
}

/*********************************************************************************************
 * @name	 Death Animations
 *********************************************************************************************/

/**
 * Pick a random death animation from supplied list.
 * Also makes sure we don't pick up the same animation twice in a row.
 */
function Name ChooseDeathAnimation(KFPawn P, class<DamageType> DamageType, vector HitDir, optional name HitBoneName)
{
	local int idx;

	// First try to do a 'high kickback' death animation
	if ( ClassIsChildOf(damageType, class'KFDT_Explosive') )
	{
		return EvaulateDeathAnimList(ExplosiveDeathAnims, P, HitDir);
	}

	// Then look for a hit zone specific animation
	idx = BodyPartDeathAnims.Find('BoneName', HitBoneName);
	if ( idx != INDEX_NONE )
	{
		if ( BodyPartDeathAnims[idx].IgnoreChance > 0.f && FRand() < BodyPartDeathAnims[idx].IgnoreChance )
		{
			// use the default death animation list
			return EvaulateDeathAnimList(DefaultDeathAnims, P, HitDir);
		}

		return EvaulateDeathAnimList(BodyPartDeathAnims[idx], P, HitDir);
	}

	// Finally, use the default death animation list
	return EvaulateDeathAnimList(DefaultDeathAnims, P, HitDir);
}

/** Once a death type is selected, choose animation variant based on hit direction */
function Name EvaulateDeathAnimList(const out DeathAnimInfo DeathAnims, KFPawn P, vector HitDir)
{
	local EPawnOctant Region;

	// If this list has a ragdoll chance it may return NAME_None
	if ( DeathAnims.RagdollChance > 0.f && FRand() < DeathAnims.RagdollChance )
	{
		return '';
	}

	if ( DeathAnims.DismemberedAnims.Length > 0 && P.bHasBrokenConstraints && P.Mesh.IsBrokenConstraint(DeathAnims.BoneName) )
	{
		LastDeathAnimIndex = Rand(DeathAnims.DismemberedAnims.Length);
		return DeathAnims.DismemberedAnims[LastDeathAnimIndex];
	}

	// if this set has direction anims than calculate hit direction
	if ( DeathAnims.Anims_B.Length > 0 )
	{
		Region = P.CalcQuadRegion(P.Rotation, -HitDir);
		switch (Region)
		{
		case DIR_Backward:
			if ( DeathAnims.Anims_B.Length > 0 )
			{
				LastDeathAnimIndex = Rand(DeathAnims.Anims_B.Length);
				return DeathAnims.Anims_B[LastDeathAnimIndex];
			}
			break;
		case DIR_Left:
			if ( DeathAnims.Anims_L.Length > 0 )
			{
				LastDeathAnimIndex = Rand(DeathAnims.Anims_L.Length);
				return DeathAnims.Anims_L[LastDeathAnimIndex];
			}
			break;
		case DIR_Right:
			if ( DeathAnims.Anims_R.Length > 0 )
			{
				LastDeathAnimIndex = Rand(DeathAnims.Anims_R.Length);
				return DeathAnims.Anims_R[LastDeathAnimIndex];
			}
			break;
		}
	}

	LastDeathAnimIndex = Rand(DeathAnims.Anims_F.Length);
	return DeathAnims.Anims_F[LastDeathAnimIndex];
}

/*********************************************************************************************
 * @name	 Hit Reactions
 *********************************************************************************************/

function bool PlayHitReactionAnim(KFPawn P, EHitReactionAnimType Type, EPawnOctant Dir)
{
	local name AnimName;
	local float Duration;

	if ( !bCanPlayAnimHitReactions )
	{
		return false;
	}

	if ( Dir == DIR_None && DmgOverTimeHitAnims.Length > 0 )
	{
		AnimName = DmgOverTimeHitAnims[Rand(DmgOverTimeHitAnims.Length)];
		Duration = P.PlayBodyAnim(AnimName, EAS_Additive, 1.f, 0.1f);
		P.NextHitReactionAnim_ActorTime = P.GetActorTimeSeconds() + RandRange(0.15f, 0.33f);
	}
	else if ( Type == HIT_Light && LightHitAnims[Dir].Anims.Length > 0 )
	{
		AnimName = LightHitAnims[Dir].Anims[Rand(LightHitAnims[Dir].Anims.Length)];
		Duration = P.PlayBodyAnim(AnimName, EAS_Additive, 1.f, 0.1f);
		P.NextHitReactionAnim_ActorTime = P.GetActorTimeSeconds() + RandRange(0.15f, 0.33f);
	}
	else if ( Type == HIT_Medium && MediumHitAnims[Dir].Anims.Length > 0 )
	{
		AnimName = MediumHitAnims[Dir].Anims[Rand(MediumHitAnims[Dir].Anims.Length)];
		Duration = P.PlayBodyAnim(AnimName, EAS_UpperBody);
		P.NextHitReactionAnim_ActorTime = P.GetActorTimeSeconds() + 0.33f;//RandRange(0.0f, 0.1f);

		P.SoundGroupArch.PlayPainSound(P);
	}
	else if ( Type == HIT_Heavy && HeavyHitAnims[Dir].Anims.Length > 0 )
	{
		AnimName = HeavyHitAnims[Dir].Anims[Rand(HeavyHitAnims[Dir].Anims.Length)];
		Duration = P.PlayBodyAnim(AnimName, EAS_UpperBody);
		P.NextHitReactionAnim_ActorTime = P.GetActorTimeSeconds() + 0.33f;//RandRange(0.5f, 1.5f);

		P.SoundGroupArch.PlayPainSound(P);
	}

	return ( Duration > 0 );
}

defaultproperties
{
	bCanPlayDeathAnimations=true
	bCanPlayAnimHitReactions=true

	LightHitAnims(DIR_Forward)=(Anims=(ADD_Bullet_F_V1, ADD_Bullet_F_V2, ADD_Bullet_F_V3))
	LightHitAnims(DIR_Backward)=(Anims=(ADD_Bullet_B_V1, ADD_Bullet_B_V2, ADD_Bullet_B_V3))
	LightHitAnims(DIR_ForwardLeft)=(Anims=(ADD_Bullet_FL_V1, ADD_Bullet_FL_V2, ADD_Bullet_FL_V3))
	LightHitAnims(DIR_ForwardRight)=(Anims=(ADD_Bullet_FR_V1, ADD_Bullet_FR_V2, ADD_Bullet_FR_V3))
	LightHitAnims(DIR_BackwardLeft)=(Anims=(ADD_Bullet_BL_V1, ADD_Bullet_BL_V2, ADD_Bullet_BL_V3))
	LightHitAnims(DIR_BackwardRight)=(Anims=(ADD_Bullet_BR_V1, ADD_Bullet_BR_V2, ADD_Bullet_BR_V3))
	LightHitAnims(DIR_Left)=(Anims=(ADD_Bullet_L_V1, ADD_Bullet_L_V2, ADD_Bullet_L_V3))
	LightHitAnims(DIR_Right)=(Anims=(ADD_Bullet_R_V1, ADD_Bullet_R_V2, ADD_Bullet_R_V3))

	MediumHitAnims(DIR_Forward)=(Anims=(Hit_F_V1, Hit_F_V2, Hit_F_V3))
	MediumHitAnims(DIR_Backward)=(Anims=(Hit_B_V1, Hit_B_V2, Hit_B_V3))
	MediumHitAnims(DIR_ForwardLeft)=(Anims=(Hit_FL_V1, Hit_FL_V2, Hit_FL_V3))
	MediumHitAnims(DIR_ForwardRight)=(Anims=(Hit_FR_V1, Hit_FR_V2, Hit_FR_V3))
	MediumHitAnims(DIR_BackwardLeft)=(Anims=(Hit_BL_V1, Hit_BL_V2, Hit_BL_V3))
	MediumHitAnims(DIR_BackwardRight)=(Anims=(Hit_BR_V1, Hit_BR_V2, Hit_BR_V3))
	MediumHitAnims(DIR_Left)=(Anims=(Hit_L_V1, Hit_L_V2, Hit_L_V3))
	MediumHitAnims(DIR_Right)=(Anims=(Hit_R_V1, Hit_R_V2, Hit_R_V3))

	HeavyHitAnims(DIR_Forward)=(Anims=(Hit_Hard_F_V1, Hit_Hard_F_V2, Hit_Hard_F_V3))
	HeavyHitAnims(DIR_Backward)=(Anims=(Hit_Hard_B_V1, Hit_Hard_B_V2, Hit_Hard_B_V3))
	HeavyHitAnims(DIR_ForwardLeft)=(Anims=(Hit_Hard_FL_V1, Hit_Hard_FL_V2, Hit_Hard_FL_V3))
	HeavyHitAnims(DIR_ForwardRight)=(Anims=(Hit_Hard_FR_V1, Hit_Hard_FR_V2, Hit_Hard_FR_V3))
	HeavyHitAnims(DIR_BackwardLeft)=(Anims=(Hit_Hard_BL_V1, Hit_Hard_BL_V2, Hit_Hard_BL_V3))
	HeavyHitAnims(DIR_BackwardRight)=(Anims=(Hit_Hard_BR_V1, Hit_Hard_BR_V2, Hit_Hard_BR_V3))
	HeavyHitAnims(DIR_Left)=(Anims=(Hit_Hard_L_V1, Hit_Hard_L_V2, Hit_Hard_L_V3))
	HeavyHitAnims(DIR_Right)=(Anims=(Hit_Hard_R_V1, Hit_Hard_R_V2, Hit_Hard_R_V3))

	DmgOverTimeHitAnims=(ADD_Bullet_F_V1, ADD_Bullet_F_V2, ADD_Bullet_F_V3, ADD_Bullet_FL_V1, ADD_Bullet_FL_V2, ADD_Bullet_FL_V3, ADD_Bullet_FR_V1, ADD_Bullet_FR_V2, ADD_Bullet_FR_V3)

	DefaultDeathAnims={( IgnoreChance=0.f,
		Anims_F=(Death_F_V1, Death_F_V2, Death_F_V3, Death_F_V4, Death_F_V5, Death_F_V6, Death_F_V7, Death_F_V8),
		Anims_B=(Death_B_V1, Death_B_V2, Death_B_V3, Death_B_V4, Death_B_V5, Death_B_V6),
		Anims_L=(Death_L_V1, Death_L_V2, Death_L_V3, Death_L_V4, Death_L_V5, Death_L_V6),
		Anims_R=(Death_R_V1, Death_R_V2, Death_R_V3, Death_R_V4, Death_R_V5, Death_R_V6) )}
	ExplosiveDeathAnims={( IgnoreChance=0.f,
		Anims_F=(DeathEXP_F_V1, DeathEXP_F_V2, DeathEXP_F_V3, DeathEXP_F_V4, DeathEXP_Up_V1, DeathEXP_Up_V2),
		Anims_B=(DeathEXP_B_V1, DeathEXP_B_V2, DeathEXP_B_V3, DeathEXP_Up_V1, DeathEXP_Up_V2),
		Anims_L=(DeathEXP_L_V1, DeathEXP_L_V2, DeathEXP_L_V3, DeathEXP_L_V4),
		Anims_R=(DeathEXP_R_V1, DeathEXP_R_V2, DeathEXP_R_V3, DeathEXP_R_V4) )}

	// Hit zone specific death anims
	BodyPartDeathAnims.Add((BoneName=Head, RagdollChance=0.25f, Anims_F=(Death_Head_V1, Death_Head_V2, Death_Head_V3, Death_Head_V4, Death_Head_V5, Death_Head_V6, Death_Head_V7, Death_Head_V8, Death_Convulsion_V1, Death_Convulsion_V2, Death_Neck_V4, Death_Neck_V5, Death_Neck_V6))
	BodyPartDeathAnims.Add((BoneName=Neck, Anims_F=(Death_Neck_V1, Death_Neck_V2, Death_Neck_V3, Death_Neck_V4, Death_Neck_V5, Death_Neck_V6, Death_Neck_V7))
	BodyPartDeathAnims.Add((BoneName=Hips, RagdollChance=0.20f, Anims_F=(Death_Stomach_V1, Death_Stomach_V2, Death_Stomach_V3, Death_Stomach_V4, Death_Stomach_V5, Death_Stomach_V6, Death_Stomach_V7, Death_Neck_V1, Death_Neck_V2, Death_Neck_V7))
	BodyPartDeathAnims.Add((BoneName=Spine1, RagdollChance=0.20f, Anims_F=(Death_Stomach_V1, Death_Stomach_V2, Death_Stomach_V3, Death_Stomach_V4, Death_Stomach_V5, Death_Stomach_V6, Death_Stomach_V7, Death_Neck_V1, Death_Neck_V2, Death_Neck_V7))
	BodyPartDeathAnims.Add((BoneName=Spine2, IgnoreChance=0.50f, RagdollChance=0.1f, Anims_F=(Death_FL_V5, Death_FL_V6, Death_FR_V6, Death_Head_V5, Death_Head_V7, Death_Head_V8, Death_Neck_V5, Death_Neck_V6, Death_Neck_V7, Death_Stomach_V5, Death_Convulsion_V2, Death_Convulsion_V4))
	BodyPartDeathAnims.Add((BoneName=LeftUpLeg, Anims_F=(Death_LegL_V1, Death_LegL_V2, Death_LegL_V3, Death_LegL_V4))
	BodyPartDeathAnims.Add((BoneName=LeftLeg, Anims_F=(Death_LegL_V1, Death_LegL_V2, Death_LegL_V3, Death_LegL_V4))
	BodyPartDeathAnims.Add((BoneName=LeftFoot, Anims_F=(Death_LegL_V1, Death_LegL_V2, Death_LegL_V3, Death_LegL_V4))
	BodyPartDeathAnims.Add((BoneName=RightUpLeg, Anims_F=(Death_LegR_V1, Death_LegR_V2, Death_LegR_V3, Death_LegR_V4))
	BodyPartDeathAnims.Add((BoneName=RightLeg, Anims_F=(Death_LegR_V1, Death_LegR_V2, Death_LegR_V3, Death_LegR_V4))
	BodyPartDeathAnims.Add((BoneName=RightFoot, Anims_F=(Death_LegR_V1, Death_LegR_V2, Death_LegR_V3, Death_LegR_V4))
	BodyPartDeathAnims.Add((BoneName=LeftShoulder, Anims_F=(Death_FL_V1, Death_FL_V2, Death_FL_V3, Death_LegL_V2, Death_LegR_V1), Anims_B=(Death_BL_V1, Death_BL_V2, Death_BL_V3))
	BodyPartDeathAnims.Add((BoneName=RightShoulder, Anims_F=(Death_FR_V1, Death_FR_V2, Death_FR_V3, Death_LegL_V1), Anims_B=(Death_BR_V1, Death_BR_V2, Death_BR_V3))
	BodyPartDeathAnims.Add((BoneName=LeftArm, Anims_F=(Death_FL_V1, Death_FL_V2, Death_FL_V3, Death_FL_V4, Death_FL_V5), Anims_B=(Death_BL_V1, Death_BL_V2, Death_BL_V3))
	BodyPartDeathAnims.Add((BoneName=LeftForearm, Anims_F=(Death_FL_V1, Death_FL_V2, Death_FL_V3, Death_FL_V4, Death_FL_V5), Anims_B=(Death_BL_V1, Death_BL_V2, Death_BL_V3))
	BodyPartDeathAnims.Add((BoneName=LeftHand, Anims_F=(Death_FL_V1, Death_FL_V2, Death_FL_V3, Death_FL_V4, Death_FL_V5), Anims_B=(Death_BL_V1, Death_BL_V2, Death_BL_V3))
	BodyPartDeathAnims.Add((BoneName=RightArm, Anims_F=(Death_FR_V1, Death_FR_V2, Death_FR_V3, Death_FR_V4), Anims_B=(Death_BR_V1, Death_BR_V2, Death_BR_V3))
	BodyPartDeathAnims.Add((BoneName=RightForearm, Anims_F=(Death_FR_V1, Death_FR_V2, Death_FR_V3, Death_FR_V4), Anims_B=(Death_BR_V1, Death_BR_V2, Death_BR_V3))
	BodyPartDeathAnims.Add((BoneName=RightHand, Anims_F=(Death_FR_V1, Death_FR_V2, Death_FR_V3, Death_FR_V4), Anims_B=(Death_BR_V1, Death_BR_V2, Death_BR_V3))

	DeathPhysMotorStrength=(X=70000,Y=2000)

	WeakAttackChance=1.f
	MediumAttackChance=1.f
	HardAttackChance=1.f
	bEnableDifficultyScaling=true
	bDebugLog=false

	// Taunts
	TauntAnims.Add(Taunt_V1)
	TauntAnims.Add(Taunt_V2)
	TauntKillAnims.Add(Taunt_Kill_V1)
	TauntKillAnims.Add(Taunt_Kill_V2)

	// KFSM_Stumble
	StumbleAnims(ESA_Body_Forward)=(Anims=(Stumble_F_V1, Stumble_F_V2, Stumble_F_V3, Stumble_F_V4))
	StumbleAnims(ESA_Body_Backward)=(Anims=(Stumble_B_V1, Stumble_B_V2, Stumble_B_V3, Stumble_B_V4))
	StumbleAnims(ESA_Body_Left)=(Anims=(Stumble_L_V1, Stumble_L_V2, Stumble_L_V3, Stumble_L_V4))
	StumbleAnims(ESA_Body_Right)=(Anims=(Stumble_R_V1, Stumble_R_V2, Stumble_R_V3, Stumble_R_V4))
	StumbleAnims(ESA_Leg_L_Forward)=(Anims=(Stumble_L_Leg_F_V1, Stumble_L_Leg_F_V2))
	StumbleAnims(ESA_Leg_L_Backward)=(Anims=(Stumble_L_Leg_B_V1, Stumble_L_Leg_B_V2))
	StumbleAnims(ESA_Leg_L_Left)=(Anims=(Stumble_L_Leg_L_V1, Stumble_L_Leg_L_V2))
	StumbleAnims(ESA_Leg_L_Right)=(Anims=(Stumble_L_Leg_R_V1, Stumble_L_Leg_R_V2))
	StumbleAnims(ESA_Leg_R_Forward)=(Anims=(Stumble_R_Leg_F_V1, Stumble_R_Leg_F_V2))
	StumbleAnims(ESA_Leg_R_Backward)=(Anims=(Stumble_R_Leg_B_V1, Stumble_R_Leg_B_V2))
	StumbleAnims(ESA_Leg_R_Left)=(Anims=(Stumble_R_Leg_L_V1, Stumble_R_Leg_L_V2))
	StumbleAnims(ESA_Leg_R_Right)=(Anims=(Stumble_R_Leg_R_V1, Stumble_R_Leg_R_V2))
	StumbleAnims(ESA_Parry)=(Anims=(Stumble_F_V1, Stumble_F_V2, Stumble_F_V3, Stumble_F_V4))
}

