//=============================================================================
// KFPawn_ZedFleshpoundKing
//=============================================================================
// Fleshpound King pawn class
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//  - Matt 'Squirrlz' Farber
//=============================================================================
class KFPawn_ZedFleshpoundKing extends KFPawn_ZedFleshpound
    implements(KFInterface_MonsterBoss);

/** Explosion templates for our rage pound */
var protected KFGameExplosion RagePoundExplosionTemplate, RagePoundFinalExplosionTemplate;

/** Additional chest plate/lighting/FX settings for beam attack state */
var const LinearColor BeamAttackGlowColor;
var transient PointLightComponent BattlePhaseLightTemplateBlue;

/** Current phase of battle */
var int CurrentPhase;

/** Min phase at which the rage explosions can occur */
var const int RageExplosionMinPhase;

/** Waves to summon at each stage by difficulty level*/
var	BossMinionWaveInfo				SummonWaves[4];

/** The base amount of minions to spawn when boss goes into hunt and heal mode */
var vector2D                        NumMinionsToSpawn;

/** Component used by the beam special move to play a hit location sound effect */
var AkComponent                     BeamHitAC;

/** Shield Vars */
/** Amount of health shield has remaining */
var float                           ShieldHealth;
var float                           ShieldHealthMax;
var const array<float>              ShieldHealthMaxDefaults;
var float							ShieldHealthScale;

/** Replicated shield health percentage */
var repnotify   byte                ShieldHealthPctByte;

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

//Localization
var localized array<string> BossCaptionStrings;

//Intro Camera
var bool bUseAnimatedCamera;
var vector AnimatedBossCameraOffset;

replication
{
    if (bNetDirty)
        CurrentPhase, ShieldHealthPctByte;
}

/************************************
* @name	KFInterface_MonsterBoss
************************************/
//Quick access to a pawn reference
simulated function KFPawn_Monster GetMonsterPawn()
{
    return self;
}

//Localization Accessors
simulated function string GetRandomBossCaption()
{
    if (default.BossCaptionStrings.Length <= 0)
    {
        return "";
    }

    return default.BossCaptionStrings[Rand(default.BossCaptionStrings.Length)];
}

//Status Accessors
static simulated event bool IsABoss()
{
    return true;
}

simulated function float GetHealthPercent()
{
    return float(Health) / float(HealthMax);
}

//Intro functionality
/** Turn on the boss camera animation mode */
simulated function SetAnimatedBossCamera(bool bEnable, optional vector CameraOffset)
{
    bUseAnimatedCamera = bEnable;
    if (bUseAnimatedCamera)
    {
        AnimatedBossCameraOffset = CameraOffset;
    }
    else
    {
        AnimatedBossCameraOffset = vect(0, 0, 0);
    }
}

/** Whether this pawn is in theatric camera mode */
simulated function bool UseAnimatedBossCamera()
{
    return bUseAnimatedCamera;
}

/** The name of the socket to use as a camera base for theatric sequences */
simulated function name GetBossCameraSocket()
{
    return 'TheatricCameraRootSocket';
}

/** The relative offset to use for the cinematic camera */
simulated function vector GetBossCameraOffset()
{
    return AnimatedBossCameraOffset;
}

function OnZedDied(Controller Killer)
{
    super.OnZedDied(Killer);

	StopBossWave();
    KFGameInfo(WorldInfo.Game).BossDied(Killer);
}

function KFAIWaveInfo GetWaveInfo(int BattlePhase, int Difficulty)
{
    switch (BattlePhase)
    {
    case 1:
        return SummonWaves[Difficulty].PhaseTwoWave;
        break;
    case 2:
        return SummonWaves[Difficulty].PhaseThreeWave;
        break;
    case 3:
        return SummonWaves[Difficulty].PhaseFourWave;
        break;
    case 0:
    default:
        return SummonWaves[Difficulty].PhaseOneWave;
    }

    return none;
}

/** Returns the number of minions to spawn based on number of players */
function byte GetNumMinionsToSpawn()
{
    if (KFGameInfo(WorldInfo.Game) != none)
    {
        return byte(Lerp(NumMinionsToSpawn.X, NumMinionsToSpawn.Y, KFGameInfo(WorldInfo.Game).GetLivingPlayerCount() / float(WorldInfo.Game.MaxPlayers)));
    }

    //Backup if we're in a weird state
    return byte(Lerp(NumMinionsToSpawn.X, NumMinionsToSpawn.Y, fMax(WorldInfo.Game.NumPlayers, 1) / float(WorldInfo.Game.MaxPlayers)));
}

//
simulated event ReplicatedEvent(name VarName)
{
    if (VarName == nameof(ShieldHealthPctByte))
    {
        UpdateShield();
    }
    else
    {
        super.ReplicatedEvent(VarName);
    }
}

/** Called from Possessed event when this controller has taken control of a Pawn */
function PossessedBy(Controller C, bool bVehicleTransition)
{
    Super.PossessedBy(C, bVehicleTransition);

    PlayBossMusic();
    class'KFPawn_MonsterBoss'.static.PlayBossEntranceTheatrics(self);
}

/** Play music for this boss (overridden for each boss) */
function PlayBossMusic()
{
    if (KFGameInfo(WorldInfo.Game) != none)
    {
        KFGameInfo(WorldInfo.Game).ForceKingFPMusicTrack();
    }
}

//Skip for boss
function CauseHeadTrauma(float BleedOutTime = 5.f)
{
    return;
}

simulated function bool PlayDismemberment(int InHitZoneIndex, class<KFDamageType> InDmgType, optional vector HitDirection)
{
    return false;
}

//Skip if boss
simulated function PlayHeadAsplode()
{
    return;
}

//Skip if boss
simulated function ApplyHeadChunkGore(class<KFDamageType> DmgType, vector HitLocation, vector HitDirection)
{
    return;
}

/** Turns the chest beam ON */
simulated function ANIMNOTIFY_ChestBeamStart()
{
    ToggleSMBeam( true );
}

/** Turns the chest beam OFF */
simulated function ANIMNOTIFY_ChestBeamEnd()
{
	ToggleSMBeam( false );
}

/** Toggles chest beam while special move active */
simulated function ToggleSMBeam( bool bEnable )
{
	local KFSM_FleshpoundKing_ChestBeam BeamSM;

	if( SpecialMove != SM_HoseWeaponAttack )
	{
		return;
	}

	BeamSM = KFSM_FleshpoundKing_ChestBeam( SpecialMoves[SpecialMove] );
	if( BeamSM != none )
	{
		BeamSM.ToggleBeam( bEnable );
	}
}

/** Use our custom glow for the chestbeam attack when necessary */
simulated function UpdateGameplayMICParams()
{
	local MaterialInstanceConstant MIC;

	// If dead just go with the super
    if( !IsAliveAndWell() )
    {
    	super.UpdateGameplayMICParams();
    	return;
    }

	if ( WorldInfo.NetMode != NM_DedicatedServer )
	{
		// We're using our chest beam attack, apply our custom color
		if( IsDoingSpecialMove(SM_HoseWeaponAttack) )
		{
			super(KFPawn_Monster).UpdateGameplayMICParams();
			UpdateBattlePhaseLights();

			MIC = CharacterMICs[0];
			MIC.SetVectorParameterValue( 'Vector_GlowColor', BeamAttackGlowColor );
			return;
		}
	}

    super.UpdateGameplayMICParams();
}

/** Use our custom glow for the chestbeam attack when necessary */
simulated function UpdateBattlePhaseLights()
{
    local PointLightComponent LightTemplate;

	// If dead just go with the super
    if( !IsAliveAndWell() )
    {
    	super.UpdateBattlePhaseLights();
    	return;
    }

    if( IsDoingSpecialMove(SM_HoseWeaponAttack) )
    {
	    if( BattlePhaseLightFront != none )
	    {
	        BattlePhaseLightFront.DetachFromAny();
	        BattlePhaseLightFront = none;
	    }

	    LightTemplate = BattlePhaseLightTemplateBlue;

        if( LightTemplate != none )
        {
    	    BattlePhaseLightFront = new(self) class'PointLightComponent'( LightTemplate );
    	}

        if( BattlePhaseLightFront != none )
        {
            Mesh.AttachComponentToSocket( BattlePhaseLightFront, BattlePhaseLightFrontSocketName );
            BattlePhaseLightFront.SetEnabled( true );
        }
        return;
    }

    super.UpdateBattlePhaseLights();
}

/** Do our radial stumble on the first few pounds */
simulated function ANIMNOTIFY_RagePoundLeft()
{
	local vector ExploLocation;

    if (CurrentPhase < RageExplosionMinPhase)
    {
        return;
    }

	Mesh.GetSocketWorldLocationAndRotation( 'FX_Root', ExploLocation );
	TriggerRagePoundExplosion( ExploLocation );
}

/** Do our radial stumble on the first few pounds */
simulated function ANIMNOTIFY_RagePoundRight()
{
	local vector ExploLocation;

    if (CurrentPhase < RageExplosionMinPhase)
    {
        return;
    }

	Mesh.GetSocketWorldLocationAndRotation( 'FX_Root', ExploLocation );
	TriggerRagePoundExplosion( ExploLocation );
}

/** Do our radial knockdown on the final pound */
simulated function ANIMNOTIFY_RagePoundRightFinal()
{
	local vector ExploLocation;

    if (CurrentPhase < RageExplosionMinPhase)
    {
        return;
    }

	Mesh.GetSocketWorldLocationAndRotation( 'FX_Root', ExploLocation );
	TriggerRagePoundExplosion( ExploLocation, true );
}

function SpawnSubWave()
{
    local KFAIWaveInfo SpawnInfo;
    local KFGameInfo KFGI;

    KFGI = KFGameInfo(WorldInfo.Game);

    SpawnInfo = GetWaveInfo(CurrentPhase, KFGI.GetModifiedGameDifficulty());
    KFGI.SpawnManager.SummonBossMinions(SpawnInfo.Squads, GetNumMinionsToSpawn(), false);

    //King fleshpound summons once and stops.  Force the stop a couple seconds after spawn.
    SetTimer(2.f, true, nameof(PauseBossWave));
}

function PauseBossWave()
{
    local KFGameInfo KFGI;

    KFGI = KFGameInfo(WorldInfo.Game);

    if (KFGI.SpawnManager.GetNumAINeeded() <= 0)
    {
		StopBossWave();
    }
}

function StopBossWave()
{
	local KFGameInfo KFGI;

	KFGI = KFGameInfo(WorldInfo.Game);

	Cleartimer(nameof(PauseBossWave));
	KFGI.SpawnManager.StopSummoningBossMinions();
}

simulated function TriggerRagePoundExplosion( vector ExploLocation, optional bool bIsFinalPound=false )
{
	local KFExplosionActor ExploActor;

	// Boom
	ExploActor = Spawn( class'KFExplosionActor', self,, ExploLocation );
	ExploActor.InstigatorController = Controller;
	ExploActor.Instigator = self;
	ExploActor.Explode( bIsFinalPound ? RagePoundFinalExplosionTemplate : RagePoundExplosionTemplate, vect(0,0,1) );
}

/** Reduce damage when in hunt and heal mode */
function AdjustDamage(out int InDamage, out vector Momentum, Controller InstigatedBy, vector HitLocation, class<DamageType> DamageType, TraceHitInfo HitInfo, Actor DamageCauser)
{
    super.AdjustDamage(InDamage, Momentum, InstigatedBy, HitLocation, DamageType, HitInfo, DamageCauser);

    if (ShieldHealth > 0)
    {
        ShieldHealth -= InDamage;

        if (ShieldHealth < 0)
        {
            InDamage = Abs(ShieldHealth);
            ShieldHealth = 0;
        }
        else
        {
            InDamage = 0;
        }

        ShieldHealthPctByte = FloatToByte(FClamp(ShieldHealth / ShieldHealthMax, 0.f, 1.f));
        UpdateShield();
    }
}

function HandleAfflictionsOnHit(Controller DamageInstigator, vector HitDir, class<DamageType> DamageType, Actor DamageCauser)
{
	if (ShieldHealthPctByte == 0)
	{
		super.HandleAfflictionsOnHit(DamageInstigator, HitDir, DamageType, DamageCauser);
	}
}

function SetShieldScale(float InScale)
{
	ShieldHealthScale = InScale;
}

function ActivateShield()
{
    local KFGameInfo KFGI;
    local float HealthMod;
    local float HeadHealthMod;

    KFGI = KFGameInfo(WorldInfo.Game);
    if (KFGI != None)
    {
        HealthMod = 1.f;
        KFGI.DifficultyInfo.GetAIHealthModifier(self, KFGI.GetModifiedGameDifficulty(), KFGI.GetLivingPlayerCount(), HealthMod, HeadHealthMod);

        ShieldHealth = ShieldHealthMaxDefaults[KFGI.GetModifiedGameDifficulty()] * HealthMod * ShieldHealthScale;
        ShieldHealthMax = ShieldHealth;
        ShieldHealthPctByte = 1;
        UpdateShield();
    }
}

simulated function ActivateShieldFX()
{
    InvulnerableShieldPSC = WorldInfo.MyEmitterPool.SpawnEmitterMeshAttachment(InvulnerableShieldFX, Mesh, ShieldSocketName, true);
    InvulnerableShieldPSC.SetAbsolute(false, true, true);
}

simulated function UpdateShield()
{
    local float ShieldHealthPct;

    // Not on dedicated servers
    if (WorldInfo.NetMode == NM_DedicatedServer)
    {
        return;
    }

    ShieldHealthPct = ByteToFloat(ShieldHealthPctByte);

    if (ShieldHealthPct > 0.f && LastShieldHealthPct <= 0.f)
    {
        ActivateShieldFX();
    }

    // Break the shield if it has no health left
    if (ShieldHealthPct == 0.f
        && InvulnerableShieldPSC != none
        && InvulnerableShieldPSC.bIsActive
        && InvulnerableShieldPSC.bAttached)
    {
        BreakShield();
    }
    else if (InvulnerableShieldPSC != none)
    {
        if (ShieldHealthPct >= 0.75f) // Green
        {
            if (LastShieldHealthPct < 0.75f)
            {
                InvulnerableShieldPSC.SetVectorParameter('Shield_Color', MakeVectorFromColor(ShieldColorGreen));
                InvulnerableShieldPSC.SetVectorParameter('Shield_CoreColor', MakeVectorFromColor(ShieldCoreColorGreen));
            }
        }
        else if (ShieldHealthPct >= 0.5f) // Yellow
        {
            if (LastShieldHealthPct >= 0.75f || LastShieldHealthPct < 0.5f)
            {
                InvulnerableShieldPSC.SetVectorParameter('Shield_Color', MakeVectorFromColor(ShieldColorYellow));
                InvulnerableShieldPSC.SetVectorParameter('Shield_CoreColor', MakeVectorFromColor(ShieldCoreColorYellow));
            }
        }
        else if (ShieldHealthPct >= 0.25f) // Orange
        {
            if (LastShieldHealthPct >= 0.5f || LastShieldHealthPct < 0.25f)
            {
                InvulnerableShieldPSC.SetVectorParameter('Shield_Color', MakeVectorFromColor(ShieldColorOrange));
                InvulnerableShieldPSC.SetVectorParameter('Shield_CoreColor', MakeVectorFromColor(ShieldCoreColorOrange));
            }
        }
        else if (LastShieldHealthPct >= 0.25f) // Red
        {
            InvulnerableShieldPSC.SetVectorParameter('Shield_Color', MakeVectorFromColor(ShieldColorRed));
            InvulnerableShieldPSC.SetVectorParameter('Shield_CoreColor', MakeVectorFromColor(ShieldCoreColorRed));
        }

        // Scale the invulnerable material param
        CharacterMICs[0].SetScalarParameterValue('Scalar_DamageResist', ShieldHealthPct);

        // Cache off so we know whether the material params need to change
        LastShieldHealthPct = ShieldHealthPct;

        UpdateShieldUI();
    }
}

/** Creates a vector parameter from a standard color */
simulated function vector MakeVectorFromColor(color InColor)
{
    local LinearColor LinColor;
    local vector ColorVec;

    LinColor = ColorToLinearColor(InColor);
    ColorVec.X = LinColor.R;
    ColorVec.Y = LinColor.G;
    ColorVec.Z = LinColor.B;

    return ColorVec;
}

/** Breaks the shield */
simulated function BreakShield()
{
    local KFExplosionActor ExplosionActor;

    if (WorldInfo.NetMode != NM_DedicatedServer)
    {
        // Detach shield and zero out material params
        DetachShieldFX();
        CharacterMICs[0].SetScalarParameterValue('Scalar_DamageResist', 0.0);

        // Spawn a shatter explosion
        ExplosionActor = Spawn(class'KFExplosionActor', self, , Location, rotator(vect(0, 0, 1)));
        if (ExplosionActor != None)
        {
            ExplosionActor.Explode(ShieldShatterExplosionTemplate);
        }
    }
}

simulated function DetachShieldFX()
{
    LastShieldHealthPct = 0.f;
    DetachEmitter(InvulnerableShieldPSC);
    UpdateShieldUI();
}

simulated function UpdateShieldUI()
{
    local KFPlayerController KFPC;

    KFPC = KFPlayerController(GetALocalPlayerController());
    if (KFPC != none && KFPC.IsLocalController())
    {
        if (KFPC.MyGFxHUD != none && KFPC.MyGFxHUD.bossHealthBar != none)
        {
            KFPC.MyGFxHUD.bossHealthBar.UpdateBossShield(LastShieldHealthPct);
        }
    }
}

simulated function string GetIconPath()
{
	return "ZED_Patriarch_UI.ZED-VS_Icon_Boss";
}

DefaultProperties
{
	LocalizationKey=KFPawn_ZedFleshpoundKing
	MonsterArchPath="ZED_ARCH.ZED_FleshpoundKing_Archetype"
	PawnAnimInfo=KFPawnAnimInfo'ZED_Fleshpound_ANIM.King_Fleshpound_AnimGroup'
	ControllerClass=class'KFAIController_ZedFleshpoundKing'
	DifficultySettings=class'KFDifficulty_FleshpoundKing'

	// ---------------------------------------------
    // Stats
    XPValues(0)=1291
    XPValues(1)=1694
    XPValues(2)=1790
    XPValues(3)=1843

	bIsFleshpoundClass=true

    RageExplosionMinPhase=1

	// ---------------------------------------------
	// Gameplay
	bAlwaysRelevant=true
    bCanRage=true
	bCanMeleeAttack=true
	ZedBumpDamageScale=0.f
	RageBumpDamageType=class'KFGameContent.KFDT_HeavyZedBump'

	Begin Object Name=MeleeHelper_0
		BaseDamage=75.f //55
		MaxHitRange=250.f
	    MomentumTransfer=55000.f
		MyDamageType=class'KFDT_Bludgeon_Fleshpound'
	End Object

	Health=8750 //1500
	Mass=200.f
    ShieldHealthMaxDefaults[0]=1800 //2000
    ShieldHealthMaxDefaults[1]=2700 //3000
    ShieldHealthMaxDefaults[2]=4000//2000 //3000
    ShieldHealthMaxDefaults[3]=5000
	ShieldHealthScale=1.1f //1.f

	// Penetration
    PenetrationResistance=5.0

    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(0.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(0.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(0.75)))  //0.75
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(0.75)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(0.75)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(0.5))) //0.3
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.6))) //0.4
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.3)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.9)))  //0.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive', 	                DamageScale=(0.8))) //1.5
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(0.75)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 	                    DamageScale=(0.25)))
    //DamageTypeModifiers.Add((DamageType=class'KFDamageType', 	DamageScale=(0.5))) // All others

    //special case
    DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_HRGHealthrower',       DamageScale=(0.6)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRGTeslauncher',   DamageScale=(0.7)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Minigun',          DamageScale=(0.6)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic_MineReconstructorExplosion',           DamageScale=(0.6)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGenerator_Beam',       				DamageScale=(1.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGeneratorSphereImpact',       		DamageScale=(2)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGenerator_DefaultFiremodeZapDamage', 	DamageScale=(1.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_EMP_ArcGenerator_AltFiremodeZapDamage',		DamageScale=(1.5)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRGScorcherLightingImpact', 	    DamageScale=(0.6)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Fire_HRGScorcherDoT',		                DamageScale=(0.4)))
    
    //DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRG_Vampire_BloodBallImpact',		DamageScale=(0.3)))
	//DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRG_Vampire_BloodBallHeavyImpact',	DamageScale=(0.3)))
	//DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing_HRG_Vampire_CrystalSpike',			DamageScale=(0.3)))
	//DamageTypeModifiers.Add((DamageType=class'KFDT_Bleeding_HRG_Vampire_BloodSuck',				DamageScale=(0.4)))
    DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRG_Vampire_BloodBallImpact',		DamageScale=(0.4)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_HRG_Vampire_BloodBallHeavyImpact',	DamageScale=(0.4)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing_HRG_Vampire_CrystalSpike',			DamageScale=(0.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bleeding_HRG_Vampire_BloodSuck',				DamageScale=(0.7)))

	Begin Object Class=KFGameExplosion Name=ExploTemplate0
		Damage=44 //40 //20
		DamageRadius=900 //600 //700
		DamageFalloffExponent=2.f
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_FleshpoundKingRage_Light'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'ZED_Fleshpound_King_EMIT.King_Pound_Explosion_Light'
		ExplosionSound=AkEvent'ww_zed_fleshpound_2.Play_King_FP_Rage_Hit'

        // Dynamic Light
        //ExploLight=ExplosionPointLight
        //ExploLightStartFadeOutTime=0.0
        //ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
		CamShakeInnerRadius=200
		CamShakeOuterRadius=1200 //900
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	RagePoundExplosionTemplate=ExploTemplate0

	Begin Object Class=KFGameExplosion Name=ExploTemplate1
		Damage=55 //50 //30
		DamageRadius=900 //600 //700
		DamageFalloffExponent=2.f
		DamageDelay=0.f

		// Damage Effects
		MyDamageType=class'KFDT_Explosive_FleshpoundKingRage_Heavy'
		KnockDownStrength=0
		FractureMeshRadius=200.0
		FracturePartVel=500.0
		ExplosionEffects=KFImpactEffectInfo'ZED_Fleshpound_King_EMIT.King_Pound_Explosion_Heavy'
		ExplosionSound=AkEvent'ww_zed_fleshpound_2.Play_King_FP_Rage_Hit'

        // Dynamic Light
        //ExploLight=ExplosionPointLight
        //ExploLightStartFadeOutTime=0.0
        //ExploLightFadeOutTime=0.2

		// Camera Shake
		CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
		CamShakeInnerRadius=200
		CamShakeOuterRadius=1200 //900
		CamShakeFalloff=1.5f
		bOrientCameraShakeTowardsEpicenter=true
	End Object
	RagePoundFinalExplosionTemplate=ExploTemplate1

	// ---------------------------------------------
	// Block Settings
	MinBlockFOV=0.2f

	// Custom Hit Zones (HeadHealth, SkinTypes, etc...)
	HeadlessBleedOutTime=7.f
    HitZones[HZI_HEAD]=(ZoneName=head, BoneName=Head, Limb=BP_Head, GoreHealth=MaxInt, DmgScale=1.1, SkinID=1) //GoreHealth=650
	HitZones[3]       =(ZoneName=heart,	   BoneName=Spine1,		  Limb=BP_Special,  GoreHealth=150, DmgScale=1.1, SkinID=2)
	HitZones[5]		  =(ZoneName=lforearm, BoneName=LeftForearm,  Limb=BP_LeftArm,  GoreHealth=20,  DmgScale=0.2, SkinID=3)
	HitZones[8]		  =(ZoneName=rforearm, BoneName=RightForearm, Limb=BP_RightArm, GoreHealth=20,  DmgScale=0.2, SkinID=3)

	DoshValue=500

	// ---------------------------------------------
	// Movement Physics
	Begin Object Name=CollisionCylinder
		CollisionRadius=+0055.000000
	End Object

	GroundSpeed=345.f //300.f //260
	SprintSpeed=805.f //700.f     //600
	ReachedEnemyThresholdScale=1.f
	PhysRagdollImpulseScale=1.5f
	KnockdownImpulseScale=2.0f

	// ---------------------------------------------
	// AI / Navigation
	BumpDamageType=class'KFDT_NPCBump_Large'
	BumpFrequency=0.1
	DamageRecoveryTimeHeavy=0.85f   //0.25f   melee hits
	DamageRecoveryTimeMedium=0.85   //0.09f  gunhits

	// ---------------------------------------------
	// Special Moves
	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_HoseWeaponAttack)=class'KFSM_FleshpoundKing_ChestBeam'
	End Object

	// for reference: Vulnerability=(default, head, legs, arms, special)
    IncapSettings(AF_Stun)=		(Vulnerability=(0.07, 0.41, 0.07, 0.07, 0.41),  Cooldown=17.0, Duration=1.25) //1.0  // 0.5, 0.55, 0.5, 0.4, 0.55
    IncapSettings(AF_Knockdown)=(Vulnerability=(0.07, 0.3,  0.07, 0.07, 0.18),  Cooldown=20.0)                 // 0.2, 0.2, 0.4, 0.2, 0.25
    IncapSettings(AF_Stumble)=  (Vulnerability=(0.07, 0.22, 0.07, 0.07, 0.3),   Cooldown=10.0)                  // 0.2, 0.2, 0.2, 0.2, 0.4
    IncapSettings(AF_GunHit)=	(Vulnerability=(0.07, 0.07, 0.07, 0.07, 0.5),   Cooldown=1.7)                  // 0.1, 0.1, 0.1, 0.1, 0.5
    IncapSettings(AF_MeleeHit)=	(Vulnerability=(0.07, 0.71, 0.07, 0.07, 0.56),  Cooldown=2.0)                  //1.0
    IncapSettings(AF_Poison)=	(Vulnerability=(0))
    IncapSettings(AF_Microwave)=(Vulnerability=(0.06),                          Cooldown=10.0, Duration=3.0)
    IncapSettings(AF_FirePanic)=(Vulnerability=(0.48),                     		Cooldown=15.0, Duration=1.2)
    IncapSettings(AF_EMP)=		(Vulnerability=(0.71),                      	Cooldown=10.0, Duration=2.2)
    IncapSettings(AF_Freeze)=   (Vulnerability=(0.37),                       	Cooldown=10.0, Duration=1.0)
    IncapSettings(AF_Snare)=    (Vulnerability=(0.75, 1.5, 0.75, 0.75, 1.5),   Cooldown=10.5, Duration=3.0)
    IncapSettings(AF_Bleed)=    (Vulnerability=(0.20),                      Cooldown=10.0)

	Begin Object Name=Afflictions_0
		FireFullyCharredDuration=5
		AfflictionClasses(AF_EMP)=class'KFAffliction_EMPDisrupt'
	End Object

	ParryResistance=4

    // ---------------------------------------------
    // Sounds
	RageLoopSound=AkEvent'ww_zed_fleshpound_2.Play_FleshPound_Rage_Start'
	RageStopSound=AkEvent'ww_zed_fleshpound_2.Play_FleshPound_Rage_Stop'

    // ---------------------------------------------
    // Effects
	BeamAttackGlowColor=(R=0.17f, G=0.22f, B=1.0f)

    Begin Object Class=PointLightComponent Name=PointLightComponent3
        Brightness=2.f
        Radius=128.f
        FalloffExponent=4.f
        LightColor=(R=148,G=168,B=255,A=255)
        CastShadows=false
        LightingChannels=(Indoor=true,Outdoor=true,bInitialized=TRUE)
    End Object
    BattlePhaseLightTemplateBlue=PointLightComponent3

	Begin Object Name=FootstepCameraShake0
		bSingleInstance=true
		OscillationDuration=0.25f
		RotOscillation={(Pitch=(Amplitude=120.f,Frequency=60.f),Roll=(Amplitude=60.f,Frequency=40.f))}
	End Object
	FootstepCameraShakePitchAmplitude=120.f
	FootstepCameraShakeRollAmplitude=60.f
	FootstepCameraShakeInnerRadius=200
	FootstepCameraShakeOuterRadius=900

	// ---------------------------------------------
	// Spawning
    MinSpawnSquadSizeType=EST_Large

    OnDeathAchievementID=KFACHID_ItsOnlyAFleshWound

    // Summon squads by difficulty - Note: Preserving difficulty/wave functionality in case we need to make use of it later, despite same wave for now
    SummonWaves(0)=(PhaseOneWave=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave',PhaseTwoWave=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave',PhaseThreeWave=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave',PhaseFourWave=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave')
    SummonWaves(1)=(PhaseOneWave=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave',PhaseTwoWave=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave',PhaseThreeWave=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave',PhaseFourWave=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave')
    SummonWaves(2)=(PhaseOneWave=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave',PhaseTwoWave=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave',PhaseThreeWave=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave',PhaseFourWave=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave')
    SummonWaves(3)=(PhaseOneWave=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave',PhaseTwoWave=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave',PhaseThreeWave=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave',PhaseFourWave=KFAIWaveInfo'GP_Spawning_ARCH.Outbreak.KingFleshpoundSubWave')
    NumMinionsToSpawn=(X=1,Y=6)

    // ---------------------------------------------
    // Shield

    //@TODO: Skin to FPK
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

    // Shield FX
    ShieldImpactEffects=ShieldEffects
    //@TODO: Skin to FPK
    InvulnerableShieldFX=ParticleSystem'ZED_Fleshpound_King_EMIT.FX_King_Fleshpound_Shield'
    ShieldSocketName=Hips

    // Shield colors
    ShieldColorGreen=(R=50,G=255,B=50)
    ShieldCoreColorGreen=(R=0,G=255,B=0)
    ShieldColorYellow=(R=255,G=255,B=20)
    ShieldCoreColorYellow=(R=255,G=255,B=0)
    ShieldColorOrange=(R=255,G=110,B=10)
    ShieldCoreColorOrange=(R=255,G=105,B=0)
    ShieldColorRed=(R=255,G=20,B=20)
    ShieldCoreColorRed=(R=255,G=10,B=10)

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
        ExplosionEffects=KFImpactEffectInfo'ZED_Fleshpound_King_EMIT.King_Pound_Shield_Explosion'
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

    Begin Object Class=AkComponent name=BeamHitAC0
        bStopWhenOwnerDestroyed=true
    End Object
    FootstepAkComponent= BeamHitAC0
    Components.Add(BeamHitAC0)
    BeamHitAC=BeamHitAC0

	bCanBePinned=false
}