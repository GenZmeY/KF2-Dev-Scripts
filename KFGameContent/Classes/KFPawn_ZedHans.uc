//=============================================================================
// KFPawn_ZedHans
//=============================================================================
// Hans Boss Pawn Class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFPawn_ZedHans extends KFPawn_ZedHansBase;

var() AnimSet MeleeAnimSet;
var() AnimSet GunsAnimSet;

/** SkelControl guns to the hip so they don't move when we play aims or additives */
var SkelControlSingleBone RightHolsterSkelCtrl;
var SkelControlSingleBone LeftHolsterSkelCtrl;

/** Explosion burst template to use for surrounded AoE nerve gas attack */
var KFGameExplosion NerveGasExplosiveBlastTemplate;

/** Lingering explosion template to use for surrounded AoE nerve gas attack */
var KFGameExplosion NerveGasAttackTemplate;

/** The damage type to use when sprinting and bumping zeds */
var class<KFDamageType> HeavyBumpDamageType;

/** Info for minion wave spawning */
struct ProjectileTossInfo
{
    /** The toss velocity used to throw the projectile*/
    var	vector				TossVelocity;
    /** The location the projectile was spawned from*/
    var	vector				TossFromLocation;
    /** The location the projectile was tossed to*/
    var	vector				TossTargetLocation;
    /** The speed the projectile was tossed at*/
    var	float				TossSpeed;
    /** The Z percent the projectile was tossed at*/
    var	float				TossZPct;
    /** The time the projectile was thrown at*/
    var	float				TossTime;
};

/** Waves to summon at each stage by difficulty level*/
var	ProjectileTossInfo				CachedGoodGrenadeToss;

/** Events for looping ambient breathing like Darth Vader */
var AkEvent AmbientBreathingEvent;
var AkEvent LowHealthAmbientBreathingEvent;

/** Restricts how often tickdialog can be called */
var float TickDialogInterval;

/** Backpack vent particle system (used when in hunt and heal mode) */
var ParticleSystem					BackPackSmokeEffectTemplate;
var ParticleSystemComponent 		BackPackSmokePSC;

/*********************************************************************************************
* Battle damage phases
**********************************************************************************************/
var name BattlePhaseLightFrontSocketName;
var name BattlePhaseLightBackSocketName;
var transient PointLightComponent BattlePhaseLightTemplateGreen;
var transient PointLightComponent BattlePhaseLightTemplateYellow;
var transient PointLightComponent BattlePhaseLightTemplateRed;
var transient PointLightComponent BattlePhaseLightTemplateBlinking;
var transient PointLightComponent BattlePhaseLightFront;
var transient PointLightComponent BattlePhaseLightBack;

var LinearColor BattlePhaseGlowColorParamGreen;
var LinearColor BattlePhaseGlowColorParamYellow;
var LinearColor BattlePhaseGlowColorParamRed;
var LinearColor BattlePhaseGlowColorParamBlinking;

var name BattleDamageFXSocketName_LegR;
var name BattleDamageFXSocketName_LegL;
var name BattleDamageFXSocketName_ArmR;
var name BattleDamageFXSocketName_ArmL;
var name BattleDamageFXSocketName_Chest;
var name BattleDamageFXSocketName_TorsoR;
var name BattleDamageFXSocketName_TorsoL;
var name BattleDamageFXSocketName_Back;

var ParticleSystemComponent BattleDamagePSC_LegR;
var ParticleSystemComponent BattleDamagePSC_LegL;
var ParticleSystemComponent BattleDamagePSC_ArmR;
var ParticleSystemComponent BattleDamagePSC_ArmL;
var ParticleSystemComponent BattleDamagePSC_Chest;
var ParticleSystemComponent BattleDamagePSC_TorsoR;
var ParticleSystemComponent BattleDamagePSC_TorsoL;
var ParticleSystemComponent BattleDamagePSC_Back;

var ParticleSystem BattleDamageFX_Sparks_Low;
var ParticleSystem BattleDamageFX_Sparks_Mid;
var ParticleSystem BattleDamageFX_Sparks_High;
var ParticleSystem BattleDamageFX_Sparks_Chest_Mid;
var ParticleSystem BattleDamageFX_Sparks_Chest_High;
var ParticleSystem BattleDamageFX_Sparks_Back_Mid;
var ParticleSystem BattleDamageFX_Sparks_Back_High;
var ParticleSystem BattleDamageFX_Blood_Mid;
var ParticleSystem BattleDamageFX_Blood_High;

/** Shield */
var float LastShieldHealthPct;
var ParticleSystem InvulnerableShieldFX;
var ParticleSystemComponent InvulnerableShieldPSC;
var name ShieldSocketName;

var KFSkinTypeEffects ShieldImpactEffects;
var KFGameExplosion ShieldShatterExplosionTemplate;

var const color ShieldColorGreen;
var const color ShieldCoreColorGreen;
var const color ShieldColorYellow;
var const color ShieldCoreColorYellow;
var const color ShieldColorOrange;
var const color ShieldCoreColorOrange;
var const color ShieldColorRed;
var const color ShieldCoreColorRed;

simulated event ReplicatedEvent(name VarName)
{
	if( VarName == nameof(bGunsEquipped) )
	{
		// Replicated for the case when SM_ChangeWeapons is skipped on the client.
		// If the special move is in progress, delay until SpecialMoveEnded
		if ( SpecialMove != SM_ChangeStance )
		{
			SetWeaponStance(bGunsEquipped);
		}
	}
    else
    {
        Super.ReplicatedEvent(VarName);
    }
}

simulated event PostBeginPlay()
{
	Super.PostBeginPlay();

	// Give Hans his weapon
	AddDefaultInventory();

	// PostBeginPlay is called before we do our first audio update, so we need to set a valid initial position so the ambient sound works right
    AmbientAkComponent.CachedObjectPosition = Location;
	SetPawnAmbientSound( AmbientBreathingEvent );

	// Disable the KFPawn optimization because Hans uses weapon bones to spawn projectiles :(
	// @todo: Do something else to get the bones like ForceUpdateSkel() or SetForceRefPose()
	if ( WorldInfo.NetMode == NM_DedicatedServer )
	{
		Mesh.bPauseAnims = false;
	}

    // Start the dialog timer
    if( WorldInfo.NetMode != NM_Client )
    {
        SetTimer( 2.f, false, nameOf(Timer_TickHansDialog) );
    }
}

/** Cache weapon holster skel controls */
simulated event PostInitAnimTree(SkeletalMeshComponent SkelComp)
{
	Super.PostInitAnimTree(SkelComp);

	RightHolsterSkelCtrl = SkelControlSingleBone(SkelComp.FindSkelControl('RightWeapon_Hip'));
	LeftHolsterSkelCtrl = SkelControlSingleBone(SkelComp.FindSkelControl('LeftWeapon_Hip'));
}

/** Setup animation and ragdoll here */
simulated function SetCharacterAnimationInfo()
{
	Super.SetCharacterAnimationInfo();

	// Hack so that designers can set Hans' melee and gun animsets from editor archetype
	// Assumes archetype animsets slot 3 is melee and slot 4 is gun
	// Assigns them and then then removes them from pawn animsets
	if (Mesh.AnimSets.Length == 5)
	{
		MeleeAnimSet = Mesh.AnimSets[3];
		GunsAnimSet = Mesh.AnimSets[4];
		Mesh.AnimSets.Remove(3, 2);
	}

	// Initialize weapon type AnimSet
	SetWeaponStance(bGunsEquipped, true);
}

/** Called when hans is switching between melee & ranged */
simulated function SetWeaponStance(bool bInEquipWeapons, optional bool bForce)
{
	local byte WeapAnimSetIdx;
	local bool bUsingGunAnimSet;

	// the weapon anim set appends to the end of the character base set
	WeapAnimSetIdx = CharacterArch.AnimSets.Length;

	// Since bAreGunsEquipped is replicated the client can check AnimSets to find out if bWasAlreadyEquipped
	if ( Mesh.AnimSets.Length > WeapAnimSetIdx && Mesh.AnimSets[WeapAnimSetIdx] == GunsAnimSet )
	{
		bUsingGunAnimSet = true;
	}

	if ( bUsingGunAnimSet != bInEquipWeapons || bForce )
	{
		bGunsEquipped = bInEquipWeapons;

		if ( bGunsEquipped )
		{
			Mesh.AnimSets[WeapAnimSetIdx] = GunsAnimSet;
			// If equipping guns at the same time as UpdateAnimations, then override
			// SkelControl's BlendOutTime so that it matches with animation
			RightHolsterSkelCtrl.SetSkelControlStrength(0.f, 0.f);
			LeftHolsterSkelCtrl.SetSkelControlStrength(0.f, 0.f);

			PlayExtraVFX('GunMode');
		}
		else
		{
			Mesh.AnimSets[WeapAnimSetIdx] = MeleeAnimSet;
			// Use SkelControl's default, editor set, BlendInTime
			RightHolsterSkelCtrl.SetSkelControlActive(true);
			LeftHolsterSkelCtrl.SetSkelControlActive(true);

			StopExtraVFX('GunMode');
		}

		// Apply new anim set and refresh animtree
		Mesh.UpdateAnimations();
	}
}

function SetSprinting( bool bNewSprintStatus )
{
    local bool bWasSprinting;

    bWasSprinting = bIsSprinting;

	super.SetSprinting( bNewSprintStatus );

	if( !bIsSprinting && !bNewSprintStatus && bWasSprinting != bIsSprinting )
	{
        // Make Hans delay for a moment after finishing sprinting
        if( MyHansController != none )
        {
            MyHansController.LastAttackMoveFinishTime = WorldInfo.TimeSeconds;
        }
	}
}


/*********************************************************************************************
* Attack phase related
********************************************************************************************* */

/** Called by PawnAnimInfo when determining whether an attack with bSpecializedMode TRUE can be performed. This makes the
	Hans use attacks from his PawnAnimInfo that are configured as "specialized" only if he's in the right battle phase. */
simulated function bool ShouldPlaySpecialMeleeAnims()
{
	return BattlePhases[CurrentBattlePhase -1].bCanFrenzy;
}

/*********************************************************************************************
* Animation Notifies
**********************************************************************************************/

/** Animation notify for Hans's right-hand grenade throw */
simulated function ANIMNOTIFY_TossGrenade_RightHand()
{
	StartThrowingGrenade( false );
}

/** Animation notify for Hans's left-hand grenade throw */
simulated function ANIMNOTIFY_TossGrenade_LeftHand()
{
	StartThrowingGrenade( true );
}

/** AnimNotify which triggers an explosive AoE blast */
simulated function ANIMNOTIFY_AoEBlast()
{
    local KFExplosionActor ExplosionActor;

    // spawn initial nerve gas burst explosion
    ExplosionActor = Spawn( class'KFExplosionActor', self,, Location, rotator(vect(0,0,1)) );
    if( ExplosionActor != none )
    {
        ExplosionActor.Explode( NerveGasExplosiveBlastTemplate );
    }
}

/** AnimNotify which starts during Hans's AoE melee attack */
simulated function ANIMNOTIFY_AoENerveGas()
{
    local KFExplosion_HansNerveGasGrenade ExplosionActor;

    // spawn nerve gas explosion using nerve gas grenade class defaults
    if( NerveGasGrenadeClass != none )
    {
        ExplosionActor = KFExplosion_HansNerveGasGrenade( Spawn(NerveGasGrenadeClass.default.ExplosionActorClass, self,, mesh.GetBoneLocation('Root'), rotator(vect(0,0,1))) );
        if( ExplosionActor != none )
        {
            ExplosionActor.bDoFullDamage = true;
            ExplosionActor.MaxTime = 4.f;
            ExplosionActor.Interval = 0.5f;
            ExplosionActor.Explode( NerveGasAttackTemplate );
        }
    }
}

/*********************************************************************************************
* Grenade Tossing
**********************************************************************************************/

/** Find a good velocity to throw a grenade at to hit our enemy, and cache it for later use. Returns true if we found a good place */
function bool CacheGrenadeThrowLocation( optional bool bLeftHand )
{
    local vector StartThrowLocation, TargetLocation, UsedEnemyLocation;
	local name HandSocketName;
	local vector TossVelocity, Extent, Offset;
	local bool bFoundVel;
	local float XYExtent, ZExtent;
	local float TossZPct;
	local bool bUsingCachedValues;
	local class<KFProj_Grenade> UsedGrenadeClass;
    local int RandIdx, i;
    local array<TrackedEnemyInfo> TargetCandidates;

    if( !bLeftHand )
    {
        HandSocketName = RightHandSocketName;
    }
    else
    {
        HandSocketName = LeftHandSocketName;
    }

    Mesh.GetSocketWorldLocationAndRotation( HandSocketName, StartThrowLocation );

    // Set a default grenade class in case one hasn't been set yet (like when Hans is calling this function to figure out if he wants to attack)
    if( ActiveGrenadeClass == none )
    {
        UsedGrenadeClass = ExplosiveGrenadeClass;
    }
    else
    {
        UsedGrenadeClass = ExplosiveGrenadeClass;
    }

    // Randomly throw the grenades at other enemies :)
    if( MyHansController != none && MyHansController.RecentlySeenEnemyList.Length > 0 )
    {
    	// Validate targets to throw grenades at
        for( i = MyHansController.RecentlySeenEnemyList.Length-1; i >= 0; i-- )
    	{
            if( MyHansController.RecentlySeenEnemyList[i].TrackedEnemy == none
                || !MyHansController.RecentlySeenEnemyList[i].TrackedEnemy.IsAliveAndWell()
                || !MyHansController.RecentlySeenEnemyList[i].TrackedEnemy.CanAITargetThisPawn(MyHansController) )
            {
                MyHansController.RecentlySeenEnemyList.Remove(i,1);
                continue;
            }
            else if( !NeedToTurnEx(MyHansController.RecentlySeenEnemyList[i].LastVisibleLocation, 0.0) )
            {
                TargetCandidates[TargetCandidates.Length] = MyHansController.RecentlySeenEnemyList[i];
            }
    	}

    	// Clear out this pawn if it was the last one we fired at and it was engaged recently
        for( i = TargetCandidates.Length-1; i >= 0; i-- )
    	{
            if( TargetCandidates.Length > 1 && TargetCandidates[i].TrackedEnemy == MyHansController.LastRecentlySeenEnemyGrenaded
                && `TimeSince(TargetCandidates[i].LastTimeGrenadeAttacked) < 5.0 )
            {
                TargetCandidates.Remove(i,1);
            }
    	}

        // Debug drawing of our view area for selecting grenade targets
    	// Get camera location/rotation
//    	MyHansController.GetPlayerViewPoint( CamLoc, CamRot );
//    	GetAxes( CamRot, X, Y, Z );
//      FlushPersistentDebugLines();
//    	DrawDebugCone(CamLoc,X,500.0, Acos(0.0), Acos(0.0),16,MakeColor(0,255,0,255),true);

        // Get a random visible enemy to pitch a grenade at
        if( TargetCandidates.Length > 0 )
        {
            RandIdx = Rand(TargetCandidates.Length);
            //`log("Selected random grenade target index "$RandIdx$" Pawn: "$TargetCandidates[RandIdx].TrackedEnemy);
            UsedEnemyLocation = TargetCandidates[RandIdx].LastVisibleLocation;
            // Store that we recently planned to pitch a nade at this guy
            MyHansController.LastRecentlySeenEnemyGrenaded = TargetCandidates[RandIdx].TrackedEnemy;
            MyHansController.RecentlySeenEnemyList[RandIdx].LastTimeGrenadeAttacked = WorldInfo.TimeSeconds;
        }
        else
        {
            UsedEnemyLocation = MyKFAIC.Enemy.Location;
        }
    }
    else
    {
        UsedEnemyLocation = MyKFAIC.Enemy.Location;
    }

	/** Lead my target a little */
	Offset = UsedGrenadeClass.static.StaticGetTimeToLocation( UsedEnemyLocation, StartThrowLocation, MyKFAIC ) * MyKFAIC.Enemy.Velocity;

    TargetLocation = UsedEnemyLocation + Offset;
	/** Grenade collision extent */
	XYExtent = UsedGrenadeClass.default.CylinderComponent.CollisionRadius;
	ZExtent = UsedGrenadeClass.default.CylinderComponent.CollisionHeight;

	Extent.X = XYExtent;
	Extent.Y = XYExtent;
	Extent.Z = ZExtent;

    // Try a normal throw
    TossZPct = 0.55;
    bFoundVel = SuggestTossVelocity(TossVelocity, TargetLocation, StartThrowLocation, UsedGrenadeClass.default.Speed,, TossZPct, Extent);

    // Try a high throw
    if( !bFoundVel )
    {
         TossZPct = 0.85;
         bFoundVel = SuggestTossVelocity(TossVelocity, TargetLocation, StartThrowLocation, UsedGrenadeClass.default.Speed,, TossZPct, Extent);
    }

    // Scale resulting toss velocity a little
    // @NOTE: TossVelocity() is pretty shitty. Does not really give accurate velocity predictions. -MattF
    if( Velocity == vect(0,0,0) )
    {
        // Scale velocity down 10% if enemy is standing still
        TossVelocity *= 0.9f;
    }
    TossVelocity.X *= 0.75f;
    TossVelocity.Y *= 0.75f;

    // Add velocity modifier. We're scaling this up because we want the grenade to explode
    // around the time the player runs over it.
    TossVelocity += MyKFAIC.Enemy.Velocity * 1.5f;

    // Subtract our own velocity
    TossVelocity -= Velocity;

    // Used cached grenade throw values if we can't find any good ones
    if( !bFoundVel && `TimeSince(CachedGoodGrenadeToss.TossTime) < 5.0 )
    {
        TossVelocity = CachedGoodGrenadeToss.TossVelocity;
        TargetLocation = CachedGoodGrenadeToss.TossTargetLocation;
        bUsingCachedValues = true;
        //`log("Using Cached values to throw a grenade Timesince: "$`TimeSince(CachedGoodGrenadeToss.TossTime));
    }

	if( bFoundVel || bUsingCachedValues )
	{
        // Only cache the values if this is an actual good real throw
        if( !bUsingCachedValues )
        {
            CachedGoodGrenadeToss.TossVelocity = TossVelocity;
            CachedGoodGrenadeToss.TossFromLocation = StartThrowLocation;
            CachedGoodGrenadeToss.TossTargetLocation = TargetLocation;
            CachedGoodGrenadeToss.TossSpeed = UsedGrenadeClass.default.Speed*1.2f;
            CachedGoodGrenadeToss.TossZPct = TossZPct;
            CachedGoodGrenadeToss.TossTime = WorldInfo.TimeSeconds;
        }

		return true;
	}

	return false;
}

/** Start the process for throwing a grenade from the appropriate mesh socket */
function StartThrowingGrenade( optional bool bLeftHand )
{
	if( Health > 0 && IsThrowingGrenade() )
	{
		if( CacheGrenadeThrowLocation( bLeftHand ) )
		{
            ThrowGrenade();
		}
	}
}

/** Spawns a grenade projectile at the cached throw speed and location */
simulated function bool ThrowGrenade()
{
	local rotator DirToEnemy;
	local KFProj_Grenade MyGrenade;
	local float TossSpeed;

	MyGrenade = Spawn( ActiveGrenadeClass, self,, CachedGoodGrenadeToss.TossFromLocation );

	if( MyGrenade == none )
	{
        return false;
	}

	/** Found a trajectory that's good enough, so let the grenade fly */
	MyGrenade.Instigator			= self;
	MyGrenade.InstigatorController	= Controller;

	TossSpeed = VSize(CachedGoodGrenadeToss.TossVelocity);
	DirToEnemy = Rotator(normal(CachedGoodGrenadeToss.TossVelocity));
	DirToEnemy = AddGrenadeSpread(DirToEnemy);
	MyGrenade.Init( vector(DirToEnemy) );

	if( bDoingBarrage && BarrageTossCount == 0 && ActiveGrenadeClass == SmokeGrenadeClass )
	{
        // Hans is doing a smoke grenade barrage, throw one grenade straight down to obscure Hans
        MyGrenade.Velocity = vect(0,0,-1) * TossSpeed;
    }
    else
    {
        // Throw the grenade at the enemy
        MyGrenade.Velocity = vector(DirToEnemy) * TossSpeed;
    }

    // Store the last time we threw each type of grenade or barrage
    if( bDoingBarrage )
    {
        if( ActiveGrenadeClass == ExplosiveGrenadeClass )
        {
            LastHENadeBarrageTime = WorldInfo.TimeSeconds;
            LastOffensiveNadeTime = WorldInfo.TimeSeconds;
        }
        else if( ActiveGrenadeClass == NerveGasGrenadeClass )
        {
            LastNerveGasBarrageTime = WorldInfo.TimeSeconds;
            LastOffensiveNadeTime = WorldInfo.TimeSeconds;
        }
        else if( ActiveGrenadeClass == SmokeGrenadeClass )
        {
            // For now count a smoke grenade barrage as a smoke toss, so we don't immeditately toss a couple of smoke right after a barrage
            LastSmokeTossTime = WorldInfo.TimeSeconds;
        }
    }
    else
    {
        if( ActiveGrenadeClass == ExplosiveGrenadeClass )
        {
            LastHENadeTossTime = WorldInfo.TimeSeconds;
            LastOffensiveNadeTime = WorldInfo.TimeSeconds;
        }
        else if( ActiveGrenadeClass == NerveGasGrenadeClass )
        {
            LastNerveGasTossTime = WorldInfo.TimeSeconds;
            LastOffensiveNadeTime = WorldInfo.TimeSeconds;
        }
        else if( ActiveGrenadeClass == SmokeGrenadeClass )
        {
            LastSmokeTossTime = WorldInfo.TimeSeconds;
        }
    }

	BarrageTossCount++;

	`DialogManager.PlaySpotGrenadeDialog( self );

	return true;
}

/**
 * Adds any fire spread offset to the passed in rotator
 * @param Aim the base aim direction
 * @return the adjusted aim direction
 */
simulated function rotator AddGrenadeSpread(rotator BaseAim)
{
	local vector X, Y, Z;
	local float RandY, RandZ;

	// Add in any spread.
	GetAxes(BaseAim, X, Y, Z);
	RandY = FRand() - 0.5;
	RandZ = Sqrt(0.5 - Square(RandY)) * (FRand() - 0.5);
	return rotator(X + RandY * GrenadeTossSpread.Y * Y + RandZ * GrenadeTossSpread.Z * Z);
}

/** Return true if busy throwing grenade(s) or using AICommand_ThrowGrenade */
function bool IsThrowingGrenade()
{
	if( Health <= 0 || MyKFAIC == none )
	{
		return false;
	}
	return IsDoingSpecialMove(SM_Hans_ThrowGrenade)
            || IsDoingSpecialMove(SM_Hans_GrenadeBarrage)
            || IsDoingSpecialMove(SM_Hans_GrenadeHalfBarrage)
		    || AICommand_ThrowGrenade(MyKFAIC.GetActiveCommand()) != none;
}


function DrawDebugOverheadText( KFHUDBase HUD, Out Vector2d ScreenPos )
{
	local Canvas			Canvas;
	local Vector			ScreenLoc;
	local bool				bShowAllCategories;

    Super.DrawDebugOverheadText( HUD, ScreenPos );

	if( !IsAliveAndWell() )
	{
		return;
	}

	Canvas = HUD.Canvas;
	ScreenLoc = Canvas.Project( Location + vect(0,0,1) * GetCollisionHeight() * 1.5f );
	if( ScreenLoc.X < 0 || ScreenLoc.X >= HUD.Canvas.ClipX || ScreenLoc.Y < 0 && ScreenLoc.Y >= HUD.Canvas.ClipY )
	{
		return;
	}

	if( HUD.ShouldDisplayDebug('All') )
	{
		bShowAllCategories = true;
	}

	if( MyHansController != none && (bShowAllCategories || HUD.ShouldDisplayDebug('RangedCombat')) )
	{
		MyHansController.DrawRangedAttackInfo( HUD );
	}
}

/*********************************************************************************************
* Dialog / Audio
**********************************************************************************************/
/** Returns (hardcoded) dialog event ID for when players kills this zed type */
function int GetKillerDialogID()
{
	return 67;//KILL_Boss
}

/** Returns (hardcoded) dialog event ID for when players spots this zed type */
function int GetSpotterDialogID()
{
	return 127;//SPOTZ_BossGeneric
}

/** Returns (hardcoded) dialog event ID for when trader gives advice to player who was killed by this zed type */
static function int GetTraderAdviceID()
{
	return 47;//TRAD_AdviceHans
}

/** Players dialog such as taunts at regular intervals */
function Timer_TickHansDialog()
{
    if( !IsAliveAndWell() )
    {
        return;
    }

    if( !IsDoingSpecialMove() )
    {
        `DialogManager.PlayHansTickDialog( self );
    }

    SetTimer( TickDialogInterval, false, nameOf(Timer_TickHansDialog) );
}

/** Play music for this boss (overridden for each boss) */
function PlayBossMusic()
{
	if( KFGameInfo(WorldInfo.Game) != none )
	{
		KFGameInfo(WorldInfo.Game).ForceHansMusicTrack();
	}
}

/*********************************************************************************************
* Damage
**********************************************************************************************/
event TakeDamage(int Damage, Controller InstigatedBy, vector HitLocation, vector Momentum, class<DamageType> DamageType, optional TraceHitInfo HitInfo, optional Actor DamageCauser)
{
	local float OldHealthPct;

	OldHealthPct = GetHealthPercentage();

	super.TakeDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType, HitInfo, DamageCauser );

	// change ambient breathing event to "low health"
	if( OldHealthPct > 0.25f && GetHealthPercentage() <= 0.25f )
	{
		SetPawnAmbientSound( LowHealthAmbientBreathingEvent );
	}
}

`if(`__TW_)
event bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType, optional bool bCanRepairArmor=true, optional bool bMessageHealer=true)
`else
event bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
`endif
{
	local bool retval;
	local float OldHealthPct;

	OldHealthPct = GetHealthPercentage();

	retval = super.HealDamage( Amount, Healer, DamageType );

	// change ambient breathing back to normal
	if( OldHealthPct <= 0.25f && GetHealthPercentage() > 0.25f )
	{
		SetPawnAmbientSound( AmbientBreathingEvent );
	}

	return retval;
}

/** Overridden so Hans doesn't get his head damaged while he is alive */
function TakeHitZoneDamage(float Damage, class<DamageType> DamageType, int HitZoneIdx, vector InstigatorLocation)
{
	// Only damage head if Hans is dead
    if( HitZoneIdx != HZI_HEAD || Health <= 0 )
	{
	   Super.TakeHitZoneDamage(Damage, DamageType, HitZoneIdx, InstigatorLocation);
	}
}

/** Overridden so that Hans head doesn't take gore damage while he's alive */
function bool CanInjureHitZone(class<DamageType> DamageType, int HitZoneIdx)
{
	local class<KFDamageType> KFDmgType;
	local name HitZoneName;

    if ( bPlayedDeath )
	{
		KFDmgType = class<KFDamageType>(DamageType);
		HitZoneName = HitZones[HitZoneIdx].ZoneName;
		if ( KFDmgType != none && KFDmgType.static.CanDismemberHitZone( HitZoneName ) )
		{
			return true;
		}
	}

	return false;
}

function class<KFDamageType> GetBumpAttackDamageType()
{
	return HeavyBumpDamageType;
}

/** Turns hunt and heal FX on or off */
simulated function SetHuntAndHealMode( bool bOn )
{
    super.SetHuntAndHealMode( bOn );

    if( WorldInfo.NetMode == NM_DedicatedServer )
    {
        return;
    }

    if( bOn )
    {
        PlayHuntAndHealModeFX();
    }
    else
    {
        StopHuntAndHealModeFX();
    }
}

/** Turns hunt and heal backpack vent smoke on */
simulated function PlayHuntAndHealModeFX()
{
    BackPackSmokePSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BackPackSmokeEffectTemplate, Mesh, BattleDamageFXSocketName_Back, true);

    InvulnerableShieldPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(InvulnerableShieldFX, Mesh, ShieldSocketName, true);
    InvulnerableShieldPSC.SetAbsolute(false, true, true);
    if( ShieldHealthPctByte > 0 )
    {
        UpdateShieldColor();
    }
}

/** Updates the color of the shield based on its health */
simulated function UpdateShieldColor()
{
    local float ShieldHealthPct;

    // Not on dedicated servers
    if( WorldInfo.NetMode == NM_DedicatedServer )
    {
        return;
    }

    ShieldHealthPct = ByteToFloat( ShieldHealthPctByte );

    // Break the shield if it has no health left
    if( ShieldHealthPct == 0.f
        && InvulnerableShieldPSC != none
        && InvulnerableShieldPSC.bIsActive
        && InvulnerableShieldPSC.bAttached )
    {
        BreakShield();
    }
    else if( InvulnerableShieldPSC != none )
    {
        if( ShieldHealthPct >= 0.75f ) // Green
        {
            if( LastShieldHealthPct < 0.75f )
            {
                InvulnerableShieldPSC.SetVectorParameter( 'Shield_Color', MakeVectorFromColor(ShieldColorGreen) );
                InvulnerableShieldPSC.SetVectorParameter( 'Shield_CoreColor', MakeVectorFromColor(ShieldCoreColorGreen) );
            }
        }
        else if( ShieldHealthPct >= 0.5f ) // Yellow
        {
            if( LastShieldHealthPct >= 0.75f || LastShieldHealthPct < 0.5f )
            {
                InvulnerableShieldPSC.SetVectorParameter( 'Shield_Color', MakeVectorFromColor(ShieldColorYellow) );
                InvulnerableShieldPSC.SetVectorParameter( 'Shield_CoreColor', MakeVectorFromColor(ShieldCoreColorYellow) );
            }
        }
        else if( ShieldHealthPct >= 0.25f ) // Orange
        {
            if( LastShieldHealthPct >= 0.5f || LastShieldHealthPct < 0.25f )
            {
                InvulnerableShieldPSC.SetVectorParameter( 'Shield_Color', MakeVectorFromColor(ShieldColorOrange) );
                InvulnerableShieldPSC.SetVectorParameter( 'Shield_CoreColor', MakeVectorFromColor(ShieldCoreColorOrange) );
            }
        }
        else if( LastShieldHealthPct >= 0.25f ) // Red
        {
            InvulnerableShieldPSC.SetVectorParameter( 'Shield_Color', MakeVectorFromColor(ShieldColorRed) );
            InvulnerableShieldPSC.SetVectorParameter( 'Shield_CoreColor', MakeVectorFromColor(ShieldCoreColorRed) );
        }

        // Scale the invulnerable material param
        CharacterMICs[0].SetScalarParameterValue( 'Scalar_DamageResist', ShieldHealthPct );

        // Cache off so we know whether the material params need to change
        LastShieldHealthPct = ShieldHealthPct;

        UpdateShieldUIOnLocalController(LastShieldHealthPct);
    }
}

simulated function UpdateShieldUIOnLocalController(float ShieldPercent)
{
    if(!KFPC.IsLocalController())
    {
        return;
    }

    if(KFPC != none && KFPC.MyGFxHUD != none && KFPC.MyGFxHUD.bossHealthBar != none)
    {
        KFPC.MyGFxHUD.bossHealthBar.UpdateBossShield(ShieldPercent);
    }
}


/** Creates a vector parameter from a standard color */
simulated function vector MakeVectorFromColor( color InColor )
{
    local LinearColor LinColor;
    local vector ColorVec;

    LinColor = ColorToLinearColor( InColor );
    ColorVec.X = LinColor.R;
    ColorVec.Y = LinColor.G;
    ColorVec.Z = LinColor.B;

    return ColorVec;
}

/** Breaks the shield */
simulated function BreakShield()
{
    local KFExplosionActor ExplosionActor;

    if( WorldInfo.NetMode != NM_DedicatedServer )
    {
        // Detach shield and zero out material params
        DetachShieldFX();
        CharacterMICs[0].SetScalarParameterValue( 'Scalar_DamageResist', 0.0 );

        // Spawn a shatter explosion
        ExplosionActor = Spawn( class'KFExplosionActor', self,, Location, rotator(vect(0,0,1)) );
        if( ExplosionActor != None )
        {
            ExplosionActor.Explode( ShieldShatterExplosionTemplate );
        }
    }

    super.BreakShield();
}

/** Turns hunt and heal backpack vent smoke off */
simulated function StopHuntAndHealModeFX()
{
	DetachEmitter( BackPackSmokePSC );
    DetachShieldFX();

	CharacterMICs[0].SetScalarParameterValue( 'Scalar_DamageResist', 0.0 );
}

simulated function DetachShieldFX()
{
    LastShieldHealthPct = 0.f;
    DetachEmitter( InvulnerableShieldPSC );
    UpdateShieldUIOnLocalController(LastShieldHealthPct);
}

/** Turns hunt and heal backpack vent smoke off on termination */
simulated function TerminateEffectsOnDeath()
{
    SetHuntAndHealMode( false );

    super.TerminateEffectsOnDeath();
}

/** Overloaded to call OnBattlePhaseChanged */
function IncrementBattlePhase()
{
	super.IncrementBattlePhase();

	OnBattlePhaseChanged();
}

/** Updates battle damage cosmetics */
simulated function OnBattlePhaseChanged()
{
    if( WorldInfo.NetMode == NM_DedicatedServer )
    {
        return;
    }
    super.OnBattlePhaseChanged();

    UpdateBattlePhaseLights();
    UpdateBattlePhaseMaterials();
    UpdateBattlePhaseParticles();
}

/** Updates dynamic lights based on battle phase */
simulated function UpdateBattlePhaseLights()
{
    local PointLightComponent LightTemplate;

    if( BattlePhaseLightFront != none )
    {
        BattlePhaseLightFront.DetachFromAny();
        BattlePhaseLightFront = none;
    }

    if( BattlePhaseLightBack != none )
    {
        BattlePhaseLightBack.DetachFromAny();
        BattlePhaseLightBack = none;
    }

    switch( CurrentBattlePhase )
    {
    case 1:
        LightTemplate = BattlePhaseLightTemplateGreen;
        break;

    case 2:
        LightTemplate = BattlePhaseLightTemplateYellow;
        break;

    case 3:
        LightTemplate = BattlePhaseLightTemplateRed;
        break;

    case 4:
		// don't activate lights after death
    	if( IsAliveAndWell() )
    	{
        	LightTemplate = BattlePhaseLightTemplateBlinking;
        }
        break;
    };

    if( LightTemplate != none )
    {
	    BattlePhaseLightFront = new(self) Class'PointLightComponent' (LightTemplate);
	    BattlePhaseLightBack = new(self) Class'PointLightComponent' (LightTemplate);
	}

    if( BattlePhaseLightFront != none )
    {
        Mesh.AttachComponentToSocket(BattlePhaseLightFront, BattlePhaseLightFrontSocketName);
        BattlePhaseLightFront.SetEnabled( true );
    }

    if( BattlePhaseLightBack != none )
    {
        Mesh.AttachComponentToSocket(BattlePhaseLightBack, BattlePhaseLightBackSocketName);
        BattlePhaseLightBack.SetEnabled( true );
    }
}

/** Updates battle damage on material instance based on battle phase */
simulated function UpdateBattlePhaseMaterials()
{
	local MaterialInstanceConstant MIC;

	MIC = CharacterMICs[0];

    switch( CurrentBattlePhase )
    {
    case 1:
        MIC.SetScalarParameterValue( 'Scalar_BattleGrime', 0.0 );
        MIC.SetScalarParameterValue( 'Scalar_Damage_Blood_Contrast', 1.0 );
        MIC.SetScalarParameterValue( 'Scalar_GlowFlashing', 0.0 );
        MIC.SetVectorParameterValue( 'Vector_GlowColor', BattlePhaseGlowColorParamGreen );
        break;

    case 2:
        MIC.SetScalarParameterValue( 'Scalar_BattleGrime', 0.25 );
        MIC.SetScalarParameterValue( 'Scalar_Damage_Blood_Contrast', 1.48 );
        MIC.SetScalarParameterValue( 'Scalar_GlowFlashing', 0.0 );
        MIC.SetVectorParameterValue( 'Vector_GlowColor', BattlePhaseGlowColorParamYellow );
        break;

    case 3:
        MIC.SetScalarParameterValue( 'Scalar_BattleGrime', 0.25 );
        MIC.SetScalarParameterValue( 'Scalar_Damage_Blood_Contrast', 1.49 );
        MIC.SetScalarParameterValue( 'Scalar_GlowFlashing', 0.0 );
        MIC.SetVectorParameterValue( 'Vector_GlowColor', BattlePhaseGlowColorParamRed );
        break;

    case 4:
        MIC.SetScalarParameterValue( 'Scalar_BattleGrime', 0.5 );
        MIC.SetScalarParameterValue( 'Scalar_Damage_Blood_Contrast', 1.6 );
		// don't activate blinking after death
        MIC.SetScalarParameterValue( 'Scalar_GlowFlashing', IsAliveAndWell() ? 1.0 : 0.0 );
        MIC.SetVectorParameterValue( 'Vector_GlowColor', BattlePhaseGlowColorParamBlinking );
        break;
    };
}

/** Updates battle damage emitters based on battle phase */
simulated function UpdateBattlePhaseParticles()
{
	switch( CurrentBattlePhase )
	{
	case 1:
		// no emitters
		break;

	case 2:
		DetachEmitter( BattleDamagePSC_LegR );
		DetachEmitter( BattleDamagePSC_ArmL );
		DetachEmitter( BattleDamagePSC_Chest );

		BattleDamagePSC_LegR = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Sparks_Low, Mesh, BattleDamageFXSocketName_LegR, true);
		BattleDamagePSC_ArmL = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Sparks_Low, Mesh, BattleDamageFXSocketName_ArmL, true);
		BattleDamagePSC_Chest = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Sparks_Low, Mesh, BattleDamageFXSocketName_Chest, true);
		break;

	case 3:
		DetachEmitter( BattleDamagePSC_LegR );
		DetachEmitter( BattleDamagePSC_LegL );
		DetachEmitter( BattleDamagePSC_ArmR );
		DetachEmitter( BattleDamagePSC_ArmL );
		DetachEmitter( BattleDamagePSC_Chest );
		DetachEmitter( BattleDamagePSC_TorsoR );
		DetachEmitter( BattleDamagePSC_TorsoL );
		DetachEmitter( BattleDamagePSC_Back );

		BattleDamagePSC_LegR = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Sparks_Mid, Mesh, BattleDamageFXSocketName_LegR, true);
		BattleDamagePSC_LegL = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Sparks_Low, Mesh, BattleDamageFXSocketName_LegL, true);
		BattleDamagePSC_ArmR = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Sparks_Low, Mesh, BattleDamageFXSocketName_ArmR, true);
		BattleDamagePSC_ArmL = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Sparks_Mid, Mesh, BattleDamageFXSocketName_ArmL, true);
		BattleDamagePSC_Chest = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Sparks_Chest_Mid, Mesh, BattleDamageFXSocketName_Chest, true);
		BattleDamagePSC_TorsoR = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Blood_Mid, Mesh, BattleDamageFXSocketName_TorsoR, true);
		BattleDamagePSC_TorsoL = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Blood_Mid, Mesh, BattleDamageFXSocketName_TorsoL, true);
		BattleDamagePSC_Back = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Sparks_Back_Mid, Mesh, BattleDamageFXSocketName_Back, true);
		break;

	case 4:
		DetachEmitter( BattleDamagePSC_LegR );
		DetachEmitter( BattleDamagePSC_LegL );
		DetachEmitter( BattleDamagePSC_ArmR );
		DetachEmitter( BattleDamagePSC_ArmL );
		DetachEmitter( BattleDamagePSC_Chest );
		DetachEmitter( BattleDamagePSC_TorsoR );
		DetachEmitter( BattleDamagePSC_TorsoL );
		DetachEmitter( BattleDamagePSC_Back );

		// don't spawn emitters after death
		if( IsAliveAndWell() )
		{
			BattleDamagePSC_LegR = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Sparks_High, Mesh, BattleDamageFXSocketName_LegR, true);
			BattleDamagePSC_LegL = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Sparks_High, Mesh, BattleDamageFXSocketName_LegL, true);
			BattleDamagePSC_ArmR = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Sparks_High, Mesh, BattleDamageFXSocketName_ArmR, true);
			BattleDamagePSC_ArmL = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Sparks_High, Mesh, BattleDamageFXSocketName_ArmL, true);
			BattleDamagePSC_Chest = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Sparks_Chest_High, Mesh, BattleDamageFXSocketName_Chest, true);
			BattleDamagePSC_TorsoR = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Blood_High, Mesh, BattleDamageFXSocketName_TorsoR, true);
			BattleDamagePSC_TorsoL = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Blood_High, Mesh, BattleDamageFXSocketName_TorsoL, true);
			BattleDamagePSC_Back = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(BattleDamageFX_Sparks_Back_High, Mesh, BattleDamageFXSocketName_Back, true);
		}
		break;
	};
}

/** Gets skin effects associated with hit zone (allows pawns to override) */
simulated function KFSkinTypeEffects GetHitZoneSkinTypeEffects( int HitZoneIdx )
{
    if( bInHuntAndHealMode && ShieldHealthPctByte > 0 )
    {
        return ShieldImpactEffects;
    }
    else
    {
        return super.GetHitZoneSkinTypeEffects( HitZoneIdx );
    }
}

DefaultProperties
{
    LocalizationKey=KFPawn_ZedHans
    bLargeZed=true
	// ---------------------------------------------
	// Stats
	XPValues(0)=1291
	XPValues(1)=1694
	XPValues(2)=1790
	XPValues(3)=1843

	// ---------------------------------------------
	// Content
    MonsterArchPath="ZED_ARCH.ZED_Hans_Archetype"
	PawnAnimInfo=KFPawnAnimInfo'ZED_Hans_ANIM.Hans_AnimGroup'

	MeleeAnimSet=AnimSet'ZED_Hans_ANIM.Hans_Melee_Master'
	GunsAnimSet=AnimSet'ZED_Hans_ANIM.Hans_Gun_Master'
	ExplosiveGrenadeClass=class'KFGameContent.KFProj_HansHEGrenade'
	SeasonalExplosiveGrenadeClasses(SEI_None)=class'KFGameContent.KFProj_HansHEGrenade'
	SeasonalExplosiveGrenadeClasses(SEI_Spring)=class'KFGameContent.KFProj_HansHEGrenade'
	SeasonalExplosiveGrenadeClasses(SEI_Summer)=class'KFGameContent.KFProj_HansHEGrenade'
	SeasonalExplosiveGrenadeClasses(SEI_Fall)=class'KFGameContent.KFProj_HansHEGrenade_Halloween'
	SeasonalExplosiveGrenadeClasses(SEI_Winter)=class'KFGameContent.KFProj_HansHEGrenade'
	NerveGasGrenadeClass=class'KFGameContent.KFProj_HansNerveGasGrenade'
	SeasonalNerveGasGrenadeClasses(SEI_None)=class'KFGameContent.KFProj_HansNerveGasGrenade'
	SeasonalNerveGasGrenadeClasses(SEI_Spring)=class'KFGameContent.KFProj_HansNerveGasGrenade'
	SeasonalNerveGasGrenadeClasses(SEI_Summer)=class'KFGameContent.KFProj_HansNerveGasGrenade'
	SeasonalNerveGasGrenadeClasses(SEI_Fall)=class'KFGameContent.KFProj_HansNerveGasGrenade_Halloween'
	SeasonalNerveGasGrenadeClasses(SEI_Winter)=class'KFGameContent.KFProj_HansNerveGasGrenade'
	SmokeGrenadeClass=class'KFGameContent.KFProj_HansSmokeGrenade'
	SeasonalSmokeGrenadeClasses(SEI_None)=class'KFGameContent.KFProj_HansSmokeGrenade'
	SeasonalSmokeGrenadeClasses(SEI_Spring)=class'KFGameContent.KFProj_HansSmokeGrenade'
	SeasonalSmokeGrenadeClasses(SEI_Summer)=class'KFGameContent.KFProj_HansSmokeGrenade'
	SeasonalSmokeGrenadeClasses(SEI_Fall)=class'KFGameContent.KFProj_HansSmokeGrenade_Halloween'
	SeasonalSmokeGrenadeClasses(SEI_Winter)=class'KFGameContent.KFProj_HansSmokeGrenade'
	HeavyBumpDamageType=class'KFGameContent.KFDT_HeavyZedBump'
    DifficultySettings=class'KFDifficulty_Hans'

	// ---------------------------------------------
	// Special Moves
	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_GrappleAttack)=class'KFSM_GrappleAttack_Hans'
		SpecialMoveClasses(SM_ChangeStance) = class'KFSM_Hans_WeaponSwitch'
		SpecialMoveClasses(SM_Hans_ThrowGrenade)=class'KFSM_Hans_ThrowGrenade'
		SpecialMoveClasses(SM_Hans_GrenadeHalfBarrage)=class'KFSM_Hans_GrenadeHalfBarrage'
		SpecialMoveClasses(SM_Hans_GrenadeBarrage)=class'KFSM_Hans_GrenadeBarrage'
		SpecialMoveClasses(SM_Evade_Fear)=class'KFSM_Evade_Fear'
		SpecialMoveClasses(SM_Block)=class'KFSM_Block'

	End Object


    // for reference: Vulnerability=(default, head, legs, arms, special)
    IncapSettings(AF_Stun)=     (Vulnerability=(0.1, 0.55, 0.1, 0.1, 0.55), Cooldown=17.0, Duration=1.25) //1.0   //0.5, 0.55, 0.5, 0.4, 0.55
    IncapSettings(AF_Knockdown)=(Vulnerability=(0.1, 0.4, 0.1, 0.1, 0.25),  Cooldown=20.0)                 //0.2, 0.2, 0.4, 0.2, 0.25
    IncapSettings(AF_Stumble)=  (Vulnerability=(0.1, 0.3, 0.1, 0.1, 0.4),   Cooldown=10.0)                  //0.2, 0.2, 0.2, 0.2, 0.4   Cooldown=5.0)
    IncapSettings(AF_GunHit)=   (Vulnerability=(0.1, 0.1, 0.1, 0.1, 0.5),   Cooldown=1.7)                  //0.1, 0.1, 0.1, 0.1, 0.5
    IncapSettings(AF_MeleeHit)= (Vulnerability=(0.5, 0.95, 0.5, 0.5, 0.75), Cooldown=2.0)                  //1.0    Cooldown=1.2
    IncapSettings(AF_Poison)=   (Vulnerability=(0))
    IncapSettings(AF_Microwave)=(Vulnerability=(0.08),                      Cooldown=10.0, Duration=3.0)   //0.08
    IncapSettings(AF_FirePanic)=(Vulnerability=(0.65),                      Cooldown=15.0, Duration=1.2)   //0.65
    IncapSettings(AF_EMP)=      (Vulnerability=(0.95),                      Cooldown=10.0, Duration=2.5)   //0.95
    IncapSettings(AF_Freeze)=   (Vulnerability=(0.5),                       Cooldown=10.0, Duration=1.0)   //0.95
    IncapSettings(AF_Snare)=    (Vulnerability=(1.0, 2.0, 1.0, 1.0, 2.0),   Cooldown=10.5, Duration=3.0)
    IncapSettings(AF_Bleed)=    (Vulnerability=(0.20),                      Cooldown=10.0)
    IncapSettings(AF_Shrink)=   (Vulnerability=(1.0))
    
	ShrinkEffectModifier = 0.15f

	ParryResistance=4

	// ---------------------------------------------
	// Gameplay
	bCanGrabAttack=true

	Begin Object Name=MeleeHelper_0
		BaseDamage=70.0 //62 //40 //55
		MaxHitRange=275.f
		MomentumTransfer=40000.f
		MyDamageType=class'KFDT_Slashing_Hans'
	End Object

	Health=7420 //8000 //6600 //6000 //6250 //6500
	DoshValue=500
	Mass=275.f
	RightHandSocketName=RightHandSocket
	LeftHandSocketName=LeftHandSocket
	bEnableAimOffset=true

    // Resistant damage types
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun',    DamageScale=(0.8))) //0.6
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle',     DamageScale=(0.8)))  //0.6
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun',          DamageScale=(0.8)))  //0.6
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun',          DamageScale=(0.8)))  //0.6
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle',            DamageScale=(0.9)))  //0.7
    DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing',                   DamageScale=(1.0)))  //0.8
    DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon',                   DamageScale=(1.0)))  //0.8
    DamageTypeModifiers.Add((DamageType=class'KFDT_Fire',                       DamageScale=(1.1)))  //1.1
    DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave',                  DamageScale=(1.0)))  //1.5 //1.2
    DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive',                  DamageScale=(1.0)))  //1.0
    DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing',                   DamageScale=(0.8)))  //0.6
    DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic',                      DamageScale=(0.1)))  //0.1

    //special case
    DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive_RPG7',             DamageScale=(1.2))) //1.2
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_RailGun',          DamageScale=(0.9))) //1.2 0.4 //0.75
    DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_HRGHealthrower',       DamageScale=(0.9)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_Ground_DragonsBreath',  DamageScale=(0.9)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRGTeslauncher',   DamageScale=(0.7)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Minigun',          DamageScale=(0.7)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_MineReconstructorExplosion',           DamageScale=(1.2)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGenerator_Beam',       				DamageScale=(1.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGeneratorSphereImpact',       		DamageScale=(2)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGenerator_DefaultFiremodeZapDamage', 	DamageScale=(1.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGenerator_AltFiremodeZapDamage',		DamageScale=(1.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Shrink_ShrinkRayGun',						DamageScale=(3.0)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRGScorcherLightingImpact', 	    DamageScale=(0.6)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_HRGScorcherDoT',		                DamageScale=(0.9)))

    //DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRG_Vampire_BloodBallImpact',		DamageScale=(0.3)))
	//DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRG_Vampire_BloodBallHeavyImpact',	DamageScale=(0.3)))
	//DamageTypeModifiers.Add((DamageType=class'KFDT_Bleeding_HRG_Vampire_BloodSuck',				DamageScale=(0.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRG_Vampire_BloodBallImpact',		DamageScale=(0.4)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRG_Vampire_BloodBallHeavyImpact',	DamageScale=(0.4)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bleeding_HRG_Vampire_BloodSuck',				DamageScale=(0.7)))


	// ---------------------------------------------
	// Block Settings
	MinBlockFOV=0.1f

	// Penetration
    PenetrationResistance=4.0

	// Custom Hit Zones (HeadHealth, SkinTypes, etc...)
	HeadlessBleedOutTime=6.f
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=MaxInt, DmgScale=1.2, SkinID=1)  //1.1
	HitZones[3]       =(ZoneName=heart,	    BoneName=Spine2,	   Limb=BP_Special,  GoreHealth=150, DmgScale=1.05, SkinID=2)  //1.3 //1.2
	HitZones[4]		  =(ZoneName=lupperarm, BoneName=LeftArm,	   Limb=BP_LeftArm,  GoreHealth=50,  DmgScale=1.0, SkinID=3)  //0.3
	HitZones[5]		  =(ZoneName=lforearm,  BoneName=LeftForearm,  Limb=BP_LeftArm,  GoreHealth=20,  DmgScale=0.2, SkinID=3)   //0.3
    HitZones[6]       =(ZoneName=lhand,     BoneName=LeftForearm,  Limb=BP_LeftArm,  GoreHealth=20,  DmgScale=0.2, SkinID=3)
	HitZones[7]		  =(ZoneName=rupperarm, BoneName=RightArm,	   Limb=BP_RightArm, GoreHealth=50,  DmgScale=1.0, SkinID=3)  //0.3
	HitZones[8]		  =(ZoneName=rforearm,  BoneName=RightForearm, Limb=BP_RightArm, GoreHealth=20,  DmgScale=0.2, SkinID=3)  //0.3
    HitZones[9]       =(ZoneName=rhand,     BoneName=LeftForearm,  Limb=BP_LeftArm,  GoreHealth=20,  DmgScale=0.2, SkinID=3)
	HitZones[12]	  =(ZoneName=lthigh,	BoneName=LeftUpLeg,	   Limb=BP_LeftLeg,  GoreHealth=75,  DmgScale=1.0, SkinID=3)  //0.3
	HitZones[13]	  =(ZoneName=lcalf,	    BoneName=LeftLeg,	   Limb=BP_LeftLeg,  GoreHealth=25,  DmgScale=1.0, SkinID=3)  //0.3
	HitZones[15]	  =(ZoneName=rthigh,	BoneName=RightUpLeg,   Limb=BP_RightLeg, GoreHealth=75,  DmgScale=1.0, SkinID=3)  //0.3
	HitZones[16]	  =(ZoneName=rcalf,     BoneName=RightLeg,	   Limb=BP_RightLeg, GoreHealth=25,  DmgScale=1.0, SkinID=3)  //0.3
	// unique zone for backpack / armor plates
	HitZones.Add((ZoneName=armor, BoneName=Spine2, Limb=BP_Special, GoreHealth=MaxInt, DmgScale=0.8, SkinID=3)  //0.3

    WeakSpotSocketNames.Add(Chest_FX) // Chest
    WeakSpotSocketNames.Add(WeakPointSocket1) // Backpack

	// ---------------------------------------------
	// Movement / Physics
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0055.000000
	End Object

    RotationRate=(Pitch=50000,Yaw=50000,Roll=50000)

	GroundSpeed=285.f //210  //265
	SprintSpeed=675.f //650
	ReachedEnemyThresholdScale=1.f
	KnockdownImpulseScale=1.0f

	// ---------------------------------------------
	// AI / Navigation
	ControllerClass=class'KFGame.KFAIController_Hans'
	BumpDamageType=class'KFDT_NPCBump_Large'
	DamageRecoveryTimeHeavy=0.7f
	DamageRecoveryTimeMedium=0.85f   //0.09f

	DefaultInventory(0)=class'KFWeap_AssaultRifle_DualMKb42_Hans'

	// Summon squads by difficulty
	SummonWaves(0)=(PhaseOneWave=KFAIWaveInfo'GP_Spawning_ARCH.Special.Hans_Minions_Normal_One',PhaseTwoWave=KFAIWaveInfo'GP_Spawning_ARCH.Special.Hans_Minions_Normal_Two',PhaseThreeWave=KFAIWaveInfo'GP_Spawning_ARCH.Special.Hans_Minions_Normal_Three')
	SummonWaves(1)=(PhaseOneWave=KFAIWaveInfo'GP_Spawning_ARCH.Special.Hans_Minions_Hard_One',PhaseTwoWave=KFAIWaveInfo'GP_Spawning_ARCH.Special.Hans_Minions_Hard_Two',PhaseThreeWave=KFAIWaveInfo'GP_Spawning_ARCH.Special.Hans_Minions_Hard_Three')
	SummonWaves(2)=(PhaseOneWave=KFAIWaveInfo'GP_Spawning_ARCH.Special.Hans_Minions_Suicidal_One',PhaseTwoWave=KFAIWaveInfo'GP_Spawning_ARCH.Special.Hans_Minions_Suicidal_Two',PhaseThreeWave=KFAIWaveInfo'GP_Spawning_ARCH.Special.Hans_Minions_Suicidal_Three')
	SummonWaves(3)=(PhaseOneWave=KFAIWaveInfo'GP_Spawning_ARCH.Special.Hans_Minions_HOE_One',PhaseTwoWave=KFAIWaveInfo'GP_Spawning_ARCH.Special.Hans_Minions_HOE_Two',PhaseThreeWave=KFAIWaveInfo'GP_Spawning_ARCH.Special.Hans_Minions_HOE_Three')
	NumMinionsToSpawn=(X=1, Y=18)

    // Battle phases
    BattlePhases(0)={(bCanFrenzy=false,
                    bSprintingBehavior=false,
                    //grenades
                    GlobalOffensiveNadePhaseCooldown=25, //12
                    bCanTossNerveGas=true,
                    bCanBarrageNerveGas=false,
                    bCanTossGrenade=false,
                    bCanBarrageGrenades=false,
                    bCanMoveWhileThrowingGrenades={(false, false, false, false)}, // Normal,Hard,Suicidal,HoE
                    //guns
                    bCanUseGuns=true,
                    GunAttackPhaseCooldown=0,
                    GunAttackLengthPhase=99999,
                    //hunt and heal
                    HealThresholds={(0.6f, 0.6f, 0.6f, 0.6f)}, // Normal,Hard,Suicidal,HoE
                    HealAmounts={(0.325f, 0.325f, 0.325f, 0.325f)}, // Normal,Hard,Suicidal,HoE
                    MaxShieldHealth={(686, 980, 1400, 1820)}, // Normal,Hard,Suicidal,HoE  //1500  1400, 1500, 1500, 1500  //400, 900, 2000, 1100
                    )}

    BattlePhases(1)={(bCanFrenzy=false, //true
                    //grenades
                    GlobalOffensiveNadePhaseCooldown=25, //15 //35
                    HENadeTossPhaseCooldown=20,
                    NerveGasTossPhaseCooldown=20,
                    bCanTossNerveGas=true,
                    bCanBarrageNerveGas=false,
                    bCanTossGrenade=true,
                    bCanBarrageGrenades=false,
                    bCanMoveWhileThrowingGrenades={(false, false, false, true)}, // Normal,Hard,Suicidal,HoE
                    //guns
                    bCanUseGuns=true,
                    GunAttackPhaseCooldown=20, //30
                    GunAttackLengthPhase=10,
                    //hunt and heal
                    HealThresholds={(0.41f, 0.41f, 0.41f, 0.41f)}, // Normal,Hard,Suicidal,HoE
                    HealAmounts={(0.275f, 0.275f, 0.275f, 0.275f)}, // Normal,Hard,Suicidal,HoE
                    MaxShieldHealth={(860, 1225, 1750, 2275)}, // Normal,Hard,Suicidal,HoE   //400, 900, 2500, 1100
                    )}

    BattlePhases(2)={(bCanFrenzy=true,
                    bSprintingBehavior=true,
                    //grenades
                    GlobalOffensiveNadePhaseCooldown=20, //55 //25 //30
                    bCanTossNerveGas=false,
                    bCanBarrageNerveGas=true,
                    bCanTossGrenade=true,
                    bCanBarrageGrenades=false,
                    bCanMoveWhileThrowingGrenades={(false, false, true, true)}, // Normal,Hard,Suicidal,HoE
                    //guns
                    bCanUseGuns=true,
                    GunAttackPhaseCooldown=20, //30 //15
                    GunAttackLengthPhase=5,  //10
                    //hunt and heal
                    HealThresholds={(0.25f, 0.25f, 0.25f, 0.25f)}, // Normal,Hard,Suicidal,HoE
                    HealAmounts={(0.125f, 0.125f, 0.125f, 0.125f)}, // Normal,Hard,Suicidal,HoE
                    MaxShieldHealth={(1030, 1470, 2100, 2730)}, // Normal,Hard,Suicidal,HoE   //400, 900, 3000, 1100
                    )}

    BattlePhases(3)={(bCanFrenzy=true,
                    bSprintingBehavior=true,
                    //grenades
                    GlobalOffensiveNadePhaseCooldown=10, //15 //35 //30
                    bCanTossNerveGas=false,
                    bCanBarrageNerveGas=false,
                    bCanTossGrenade=false,
                    bCanBarrageGrenades=true,
                    bCanMoveWhileThrowingGrenades={(false, false, true, true)},
                    // guns
                    bCanUseGuns=true,
                    GunAttackPhaseCooldown=30, //55 //40
                    GunAttackLengthPhase=4,  //15  //3
                    )}

    CurrentBattlePhase=1

    GrenadeTossSpread=(Y=0.2, Z=0.04)
    SmokeTossCooldown=5

    AmbientBreathingEvent=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_Breathing_Base'
    LowHealthAmbientBreathingEvent=AkEvent'WW_VOX_NPC_HansVolter.Play_HANS_BreathHurt_Base'

    TickDialogInterval=0.5f

    /** Used for nerve gas attack explosions */
    Begin Object Class=KFGameExplosion Name=ExploTemplate0
        Damage=70
        DamageRadius=450
        DamageFalloffExponent=1.f
        DamageDelay=0.f

        // Damage Effects
        MyDamageType=class'KFDT_Explosive_HansHEGrenade'
        KnockDownStrength=0
        FractureMeshRadius=200.0
        FracturePartVel=500.0
        ExplosionEffects=none
        ExplosionSound=none
        // Dynamic Light
        ExploLight=none
        ExploLightStartFadeOutTime=0.0
        ExploLightFadeOutTime=0.2
        MomentumTransferScale

        // Camera Shake
        CamShake=none
        CamShakeInnerRadius=0
        CamShakeOuterRadius=0
        CamShakeFalloff=1.f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    NerveGasExplosiveBlastTemplate=ExploTemplate0

    // Nerve gas AoE explosion light
    Begin Object Class=PointLightComponent Name=ExplosionPointLight
        LightColor=(R=200,G=200,B=0,A=255)
        Brightness=4.f
        Radius=500.f
        FalloffExponent=10.f
        CastShadows=False
        CastStaticShadows=FALSE
        CastDynamicShadows=True
		bCastPerObjectShadows=false
        bEnabled=FALSE
        LightingChannels=(Indoor=TRUE,Outdoor=TRUE,bInitialized=TRUE)
    End Object

    /** Used for nerve gas AOE attack "explosion" template */
    Begin Object Class=KFGameExplosion Name=ExploTemplate1
        Damage=8
        DamageRadius=450
        DamageFalloffExponent=0.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Toxic_HansGrenade'

        // Damage Effects
        KnockDownStrength=0
        KnockDownRadius=0
        FractureMeshRadius=0
        FracturePartVel=0
        ExplosionEffects=KFImpactEffectInfo'ZED_Hans_EMIT.NerveGasAoEAttack_Explosion'
        ExplosionSound=AkEvent'WW_ZED_Hans.ZED_Hans_SFX_Grenade_Poison'
        MomentumTransferScale=0

        // Dynamic Light
        ExploLight=ExplosionPointLight
        ExploLightStartFadeOutTime=7.0
        ExploLightFadeOutTime=1.0
        ExploLightFlickerIntensity=5.f
        ExploLightFlickerInterpSpeed=15.f

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
        CamShakeInnerRadius=450
        CamShakeOuterRadius=900
        CamShakeFalloff=1.f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    NerveGasAttackTemplate=ExploTemplate1

    // ---------------------------------------------
    // damage phase lights and effects
    Begin Object Class=PointLightComponent Name=PointLightComponent0
        Brightness=1.f
        Radius=128.f
        LightColor=(R=168,G=222,B=173,A=255)
        CastShadows=false
		bCastPerObjectShadows=false
        LightingChannels=(Indoor=true,Outdoor=true,bInitialized=TRUE)
    End Object
    BattlePhaseLightTemplateGreen=PointLightComponent0

    Begin Object Class=PointLightComponent Name=PointLightComponent1
        Brightness=1.f
        Radius=128.f
        LightColor=(R=231,G=215,B=161,A=255)
        CastShadows=false
		bCastPerObjectShadows=false
        LightingChannels=(Indoor=true,Outdoor=true,bInitialized=TRUE)
    End Object
    BattlePhaseLightTemplateYellow=PointLightComponent1

    Begin Object Class=PointLightComponent Name=PointLightComponent2
        Brightness=1.f
        Radius=128.f
        LightColor=(R=231,G=144,B=0,A=255)
        CastShadows=false
		bCastPerObjectShadows=false
        LightingChannels=(Indoor=true,Outdoor=true,bInitialized=TRUE)
    End Object
    BattlePhaseLightTemplateRed=PointLightComponent2

    Begin Object Class=PointLightComponent Name=PointLightComponent3
        Brightness=2.f
        Radius=128.f
        LightColor=(R=255,G=64,B=64,A=255)
        CastShadows=false
		bCastPerObjectShadows=false
        LightingChannels=(Indoor=true,Outdoor=true,bInitialized=TRUE)

        // light anim
        AnimationType=1 // LightAnim_Flicker
        AnimationFrequency=5.f
        MinBrightness=1.f
        MaxBrightness=2.f
    End Object
    BattlePhaseLightTemplateBlinking=PointLightComponent3

    BattlePhaseLightFrontSocketName=Light_Front
    BattlePhaseLightBackSocketName=Light_Back

    BattlePhaseGlowColorParamGreen=(R=0.1, G=1.0)
    BattlePhaseGlowColorParamYellow=(R=1.0, G=0.5)
    BattlePhaseGlowColorParamRed=(R=1.0, G=0.1)
    BattlePhaseGlowColorParamBlinking=(R=2.0)

    BattleDamageFXSocketName_LegR=LegVent_R
    BattleDamageFXSocketName_LegL=LegVent_L
    BattleDamageFXSocketName_ArmR=ArmVent_R
    BattleDamageFXSocketName_ArmL=ArmVent_L
    BattleDamageFXSocketName_Chest=Chest_FX
    BattleDamageFXSocketName_TorsoR=Implant_FX_R
    BattleDamageFXSocketName_TorsoL=Implant_FX_L
    BattleDamageFXSocketName_Back=BackPackVent

    BattleDamageFX_Sparks_Low=ParticleSystem'ZED_Hans_EMIT.FX_Hans_Sparks_LowD_01'
    BattleDamageFX_Sparks_Mid=ParticleSystem'ZED_Hans_EMIT.FX_Hans_Sparks_MidD_01'
    BattleDamageFX_Sparks_High=ParticleSystem'ZED_Hans_EMIT.FX_Hans_Sparks_HighD_01'
    BattleDamageFX_Sparks_Chest_Mid=ParticleSystem'ZED_Hans_EMIT.FX_Chest_electricity_HighD_01'
    BattleDamageFX_Sparks_Chest_High=ParticleSystem'ZED_Hans_EMIT.FX_Hans_Paralyze_01'
    BattleDamageFX_Sparks_Back_Mid=ParticleSystem'ZED_Hans_EMIT.FX_Back_sparks_MidD_01'
    BattleDamageFX_Sparks_Back_High=ParticleSystem'ZED_Hans_EMIT.FX_Back_sparks_HighD_01'

    BattleDamageFX_Blood_Mid=ParticleSystem'ZED_Hans_EMIT.FX_Hans_Blood_Spray_02'
    BattleDamageFX_Blood_High=ParticleSystem'ZED_Hans_EMIT.FX_Hans_Blood_Spray_01'

    // invulnerable effects
    Begin Object Class=KFSkinTypeEffects_InvulnerabilityShield Name=ShieldEffects
		ImpactFXArray[0]={(
			Type=FXG_Ballistic,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[1]={(
			Type=FXG_Bludgeon,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[2]={(
			Type=FXG_Piercing,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[3]={(
			Type=FXG_Slashing,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[4]={(
			Type=FXG_Fire,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[5]={(
			Type=FXG_Toxic,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[6]={(
			Type=FXG_Healing,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[7]={(
			Type=FXG_Sawblade,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[8]={(
			Type=FXG_DrainLife,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[9]={(
			Type=FXG_IncendiaryRound,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[10]={(
			Type=FXG_UnexplodedGrenade,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[11]={(
			Type=FXG_MicrowaveBlast,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[12]={(
			Type=FXG_ShieldBash,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[13]={(
			Type=FXG_MetalMace,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[14]={(
			Type=FXG_Flare,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[15]={(
			Type=FXG_Freeze,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[16]={(
			Type=FXG_Bludgeon_Chains,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[17]={(
			Type=FXG_MicrowaveProj,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[18]={(
			Type=FXG_Electricity,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
		ImpactFXArray[19]={(
			Type=FXG_Slashing_Ion,
			DefaultParticle=ParticleSystem'ZED_Hans_EMIT.FX_Hans_invulnerable_Hit',
			DefaultSound=AkEvent'WW_Skin_Impacts.Play_IMP_Ballistic_Machine_Local')}
    End Object

    // Damage/incap scalars
    HuntAndHealModeDamageReduction=0.f
    IncapPowerScaleWhenHealing=0.f

    // Hunt and heal backpack FX
    BackPackSmokeEffectTemplate=ParticleSystem'ZED_Hans_EMIT.FX_Life_Drain_Smoke_01'

    // Shield FX
    ShieldImpactEffects=ShieldEffects
    InvulnerableShieldFX=ParticleSystem'ZED_Hans_EMIT.FX_Hans_Hunt_Shield'
    ShieldSocketName=Hips

    // Shield colors
    ShieldColorGreen=(R=50, G=255, B=50)
    ShieldCoreColorGreen=(R=0, G=255, B=0)
    ShieldColorYellow=(R=255, G=255, B=20)
    ShieldCoreColorYellow=(R=255, G=255, B=0)
    ShieldColorOrange=(R=255, G=110, B=10)
    ShieldCoreColorOrange=(R=255, G=105, B=0)
    ShieldColorRed=(R=255, G=20, B=20)
    ShieldCoreColorRed=(R=255, G=10, B=10)

    // Shield shatter explosion template
    Begin Object Class=KFGameExplosion Name=ShatterExploTemplate0
        Damage=30
        DamageRadius=500
        DamageFalloffExponent=1.f
        DamageDelay=0.f

        // Damage Effects
        KnockDownStrength=0
        KnockDownRadius=0
        FractureMeshRadius=500.0
        FracturePartVel=500.0
        ExplosionEffects=KFImpactEffectInfo'ZED_Hans_EMIT.ShieldShatter_Explosion'
        ExplosionSound=AkEvent'WW_ZED_Hans.Play_Hans_Shield_Break'

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
        CamShakeInnerRadius=450
        CamShakeOuterRadius=900
        CamShakeFalloff=0.5f
        bOrientCameraShakeTowardsEpicenter=true
        bUseOverlapCheck=false
    End Object
    ShieldShatterExplosionTemplate=ShatterExploTemplate0

	// ---------------------------------------------
	// Spawning
    MinSpawnSquadSizeType=EST_Boss

    OnDeathAchievementID=KFACHID_DieVolter

	// Only used in Volter Castle for now when the spawn volume has bForceUseMapReplacePawn set to true
	// If we need to reuse it more we'll have to connect map to zed here (here defaults to this same class)
	MapReplacePawnClass.Add(class'KFPawn_ZedHans')
}
