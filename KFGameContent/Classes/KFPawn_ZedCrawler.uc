//=============================================================================
// KFPawn_ZedCrawler
//=============================================================================
// Crawler
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedCrawler extends KFPawn_Monster;

var protected Actor LastBumpLevelActor;
var protected float LastBumpLevelTime;

/** Template used by special crawlers when exploding during death */
var protected const KFGameExplosion DeathExplosionTemplate;

/** How much of an impulse to apply to crawler if gore settings prevent dismemberment */
var protected const float LowGoreExplosionImpulse;

event PossessedBy( Controller C, bool bVehicleTransition )
{
	local KFAIController_ZedCrawler CrawlerController;

	super.PossessedBy( C, bVehicleTransition );

	LastBumpLevelActor = none;

	CrawlerController = KFAIController_ZedCrawler( MyKFAIC );
	if( CrawlerController != none )
	{
		CrawlerController.OriginalMeshTranslation = Mesh.Translation;
	}
}

// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
//simulated event BaseChange()
//{
//	Super.BaseChange();
//
//	if( Base != None && Pawn(Base) == none ) // Added pawn check 3/18
//	{
//		if (Role == ROLE_Authority)
//		{
//			ReplicatedFloor = Floor;
//		}
//		else
//		{
//			Floor = ReplicatedFloor;
//		}
//	}
//}

/**
 * SpecialMoveTo() - Called by NavigationPoint SuggestMovePreparation event,
 * provides option for pawn to do something special (but not necessarily a real
 * KFSpecialMove) for this reachspec.
 *
 * @param	Start	Starting node
 * @param	End		Ending node
 * @param	Next	Which node is currently next (need to check if Start != End)
 */
// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
//function bool SpecialMoveTo( NavigationPoint Start, NavigationPoint End, Actor Next )
//{
//	local ReachSpec	CurrentPath;
//	local vector EndLocation;
//	local AICommand ActiveCommand;
////	local int i;
//	//local KFDebugLines KFDL;
//
//	if( Start == End  )
//	{
//		return false;
//	}
//
//	CurrentPath = Start.GetReachSpecTo( End );
//	if( CurrentPath == none )
//	{
//		`AILog_Ext( GetFuncName()$"() WARNING - Can't find ReachSpec from start "$Start$" to End "$End$" (Next: "$Next$")", 'Crawler', MyKFAIC );
//	}
//	EndLocation = CurrentPath.End.Actor.Location;
//	`AILog_Ext( GetFuncName()$" CurrentPath: "$CurrentPath$" Start: "$Start$" End: "$End$" Next: "$Next$" Phys: "$GetPhysicsName()$" Velocity: "$VSize(Velocity)$" Dist From Start "$VSize(Start.Location - Location)$" Dist From End: "$VSize(End.Location - Location), 'Crawler', MyKFAIC );
//	`AILog_Ext( GetFuncName()$" MoveGoal: "$MyKFAIC.MoveGoal$" Dist from: "$VSize(MyKFAIC.MoveGoal.Location - Location), 'Crawler', MyKFAIC );
//
//	if( CurrentPath.BlockedBy != none )
//	{
//		`log( "CurrentPath "$CurrentPath$" blockedBy was "$CurrentPath.BlockedBy );
//	}
//
//	if( WallToFloorReachSpec(CurrentPath) != none && WallToFloorReachSpec(CurrentPath).bJumpDownTo ) // && !End.IsA('KFWallPathNode') )
//	{
//		MyKFAIC.AIActionStatus = "Falling from wall using "$CurrentPath$" ("$Start$")";
//		SetPhysics( PHYS_Falling );
//		return false;
//	}
//	// JC: Temp
//	if( !NavigationPoint(CurrentPath.End.Actor).bWallNode && CurrentPath.Start.bWallNode )
//	{
//		if( (Location.Z - EndLocation.Z > 0.f) && ((Location.Z - EndLocation.Z) <= KFWallPathNode(CurrentPath.End.Actor).MaxDropFromWallDistance) )
//		{
//			if( VSize2D(EndLocation - Location) <=  KFWallPathNode(CurrentPath.End.Actor).Max2DDistToFloorNodes )
//			{
//				MyKFAIC.AIActionStatus = "Falling from wall using "$CurrentPath$" ("$Start$")";
//				SetPhysics( PHYS_Falling );
//				return false;
//			}
//		}
//	}
//
//	if( KFPathnode( End ) != none )
//	{
//		if( CurrentPath != none && CurrentPath.IsA( 'WallToFloorReachSpec' ) && Physics == PHYS_Spider )
//		{
//			if( WallToFloorReachSpec(CurrentPath).bJumpDownTo )
//			{
//				SetPhysics( PHYS_Falling );
//			}
//		}
//	}
//
//	if( CurrentPath != None && Physics == PHYS_Walking && End.IsA('KFWallPathNode') )
//	{
//		if( KFWallPathNode(End).bMustJumpTo )
//		{
//			ActiveCommand = AICommand( MyKFAIC.GetActiveCommand() );
//			if( WallReachSpec(CurrentPath) != none && (ActiveCommand == none || !ActiveCommand.IsA('AICommand_Crawler_LeapToWall')) )
//			{
//				return	SpecialMoveTo_Leap( Start, End, KFPathnode(Start).JumpTime );
//			}
//			else if( (ActiveCommand == none || !ActiveCommand.IsA('AICommand_Crawler_LeapToWall')) )
//			{
//				return	SpecialMoveTo_Leap( Start, End );
//			}
//		}
//		else if( !CurrentPath.Start.IsA('KFDoorMarker') && !Next.IsA('KFDoorMarker') )
//		{
//			//KFDL = class'KFDebugLines'.static.GetDebugLines();
//			//if( KFDL != none )
//			//{
//			//	KFDL.AddDebugSphere( Start.Location, 24, 8, 0, 255, 0, true, 200, name, 1 );
//			//	KFDL.AddDebugSphere( End.Location, 24, 8, 255, 0, 0, true, 200, name, 2 );
//			//	KFDL.AddDebugSphere( Next.Location, 18, 6, 255, 255, 0, true, 200, name, 3 );
//			//}
//			`AILog_Ext( GetFuncName()$" Setting PHYS to PHYS_SPIDER DIST: "$VSize(End.Location-Location), 'Crawler', MyKFAIC );
//			SetPhysics(PHYS_Spider);
//		//	MyKFAIC.ForcePauseAndRepath(); 2.5.2014
//		//	MyKFAIC.PauseAndShowMsg( "SpecialMoveTo Setting PHYS to Spider Start: "$Start$" End: "$End );
//			return false;
//		}
//		return true;
//	}
//	return false;
//}

function bool SpecialMoveTo_Leap( NavigationPoint Start, NavigationPoint End, optional float JumpTime=0.45f )
{
	class'AICommand_Crawler_LeapToWall'.static.LeapToWall( KFAIController_ZedCrawler(MyKFAIC), Start, End, JumpTime );
	return TRUE;
}

/**
 * BumpLevel() - Event called by KFPawn_Monster NotifyBumpLevel() when bumping
 * geometry (this includes when landing on the ground).
 *
 * @param	HitLocation		World location where the level was bumped
 * @param	HitNormal		The normal generated at collision
 * @param	Wall			The actor, if any, that's considered to be the wall
 */
event SpiderBumpLevel( vector HitLocation, vector HitNormal, optional actor Wall )
{
	local AICommand ActiveCommand;

	if( MyKFAIC != none )
	{
		if( LastBumpLevelTime == 0.f || `TimeSince(LastBumpLevelTime) > 0.1f )
		{
			LastBumpLevelTime = WorldInfo.TimeSeconds;
			ActiveCommand = AICommand( MyKFAIC.GetActiveCommand() );
			if( Physics != PHYS_Falling || (ActiveCommand != none && AICommand_Crawler_LeapToWall(ActiveCommand) != none) )
			{
				if( Wall != none && LastBumpLevelActor != Wall )
				{
					`AILog_Ext( "(Pawn) "$GetFuncName()$" Wall: "$Wall$" HitNormal: "$HitNormal, 'Crawler', MyKFAIC );
					LastBumpLevelActor = Wall;
					MyKFAIC.NotifyHitWall( HitNormal, Wall );
				}
			}
			else
			{
				`AILog_Ext( "(Pawn) [PHYS_FALLING] "$GetFuncName()$" Wall: "$Wall$" HitNormal: "$HitNormal, 'Crawler', MyKFAIC );
			}
		}
	}
}

// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
//simulated event RootMotionProcessed(SkeletalMeshComponent SkelComp)
//{
//	if( Mesh.RootMotionVelocity != vect(0,0,0) )
//	{
//		//MyKFAIC.LastCrawlerX = Mesh.RootMotionVelocity;
//		//MyKFAIC.SetFocalPoint( Location + normal(Mesh.RootMotionVelocity) * 512.f );
//		KFAIController_ZedCrawler(MyKFAIC).LastRMVelocity = Mesh.RootMotionVelocity;
//	}
//}

/*********************************************************************************************
* Debugging
********************************************************************************************* */

/** Render some Fleshpound specific debug text over his head */
/**
 * GetOverheadDebugText() - Called by KFAIController if rendering debug text is enabled.
 * Gives Pawn a chance to include some debug text of its own.
 *
 * @param	ModifyTextColor		Optionally override the default text color
 */
simulated function GetOverheadDebugText( KFHUDBase HUD, out array<string> OverheadTexts, out array<Color> OverheadColors )
{
	local string DebugText;

    Super.GetOverheadDebugText(HUD, OverheadTexts, OverheadColors);

	if( MyKFAIC != none )
	{
		DebugText = DebugText$"\nPhys:"$GetPhysicsName()$" Floor:"$Floor$" Rot:"$Rotation$" Desired:"$DesiredRotation;

		if( Base != none )
		{
			DebugText = DebugText$"\nBase:"$Base;
		}
	}

	OverheadTexts[OverheadTexts.Length] = DebugText;
}

/**
 * DrawDebugRotation() - Draw Pawn's rotation information in front
 */
simulated function DrawDebugRotation()
{
	local vector vExtent, StartLoc;

	if ( Mesh!=none )
	{
		// draw cylinder around them
		vExtent = vect( 0,0,1 ) * GetCollisionHeight();
		DrawDebugCylinder(Location-vExtent, Location+vExtent, GetCollisionRadius(), 10, 100, 100, 0);
		// Draw Pawn's rotation coordinate in front/top of their cylinder, so it's more visible - red being exactly yaw
		StartLoc = Location+vExtent*GetCollisionRadius();
		DrawDebugCoordinateSystem(StartLoc, Rotation, 75);
		if ( ReachedDesiredRotation()==false )
		{
			// if pawn is rotating, please draw desired rotation with yellow
			DrawDebugLine(Location, Location+Vector(DesiredRotation)*750, 0, 100, 255);
		}
	}
}

simulated function Tick( float DeltaTime )
{
	Super.Tick( DeltaTime );

	if( bDebugCrawlerPhysics )
	{
		DrawDebugRotation();
	}
}

/** Returns (hardcoded) dialog event ID for when players spots this zed type */
function int GetSpotterDialogID()
{
	local int EmergeType;

	if( IsDoingSpecialMove(SM_Emerge) )
    {
        EmergeType = SpecialMoveFlags & 0x0f;
        switch( EmergeType )
        {
        case EMERGE_Floor:
            return 142;//SPOTZ_EmergeFloor

        case EMERGE_Wall248UU:
        case EMERGE_WallHigh:
            return 140;//SPOTZ_EmergeVent

        case EMERGE_Ceiling:
            return 141;//SPOTZ_EmergeCeiling

        default:
        	return 125;//SPOTZ_Generic
        };
    }

    if( Floor.Z > 0.7 )
    {
        // floor
        return 125;//SPOTZ_Generic
    }
    else if( Floor.Z < -0.7 )
    {
        // ceiling
        return 139;//SPOTZ_Ceiling
    }
    else
    {
        // wall?
        return 138;//SPOTZ_Wall
    }

	return 125;//SPOTZ_Generic
}

/** Added knockdown when jumped on */


defaultproperties
{
	LocalizationKey=KFPawn_ZedCrawler
	// Third person body component
	Begin Object Name=KFPawnSkeletalMeshComponent
		Translation=(Z=-40)	// based on CollisionHeight
		bPerBoneMotionBlur=false
	End Object

	Begin Object Name=CollisionCylinder
		// Use collision cube to make it easier when we orient the crawler to the
		// wall.  Otherwise, we would need to dynamically adjust Mesh Translation
		CollisionHeight=40.0
		CollisionRadius=+47.0
	End Object

	// ---------------------------------------------
	// Stats
	XPValues(0)=8
	XPValues(1)=10
	XPValues(2)=10
	XPValues(3)=10

	bIsCrawlerClass=true

	// ---------------------------------------------
	// Content
	MonsterArchPath="ZED_ARCH.ZED_Crawler_Archetype"
	PawnAnimInfo=KFPawnAnimInfo'ZED_Crawler_ANIM.Crawler_AnimGroup'
	DifficultySettings=class'KFDifficulty_Crawler'

	// ---------------------------------------------
	// Gameplay
	Begin Object Name=MeleeHelper_0
		BaseDamage=7.f
		MaxHitRange=180.f
		MomentumTransfer=25000.f
		MyDamageType=class'KFDT_Slashing_ZedWeak'
	End Object

	Health=55
	DoshValue=10
	Mass=50.f
	bKnockdownWhenJumpedOn=true

	// Penetration
    PenetrationResistance=0.5

	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Submachinegun', 	DamageScale=(1.5))) //2.25
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_AssaultRifle', 	DamageScale=(1.5)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Shotgun', 	        DamageScale=(1.0)))  //0.75 //0.8
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Handgun', 	        DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Ballistic_Rifle', 	        DamageScale=(1.0)))   //0.45
	DamageTypeModifiers.Add((DamageType=class'KFDT_Slashing', 	                DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Bludgeon', 	                DamageScale=(0.9)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Fire', 	                    DamageScale=(0.9))) //0.6
	DamageTypeModifiers.Add((DamageType=class'KFDT_Microwave', 	                DamageScale=(0.2)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Explosive',   	            DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Piercing', 	                DamageScale=(1.0)))
	DamageTypeModifiers.Add((DamageType=class'KFDT_Toxic', 		                DamageScale=(1.0)))

	// ---------------------------------------------
	// Movement / Physics
	// Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
	ReachedGoalThresh_Walking=0.f//=30.f
	//ReachedGoalThresh_Spider=30.f
	RotationRate=(Pitch=90000,Yaw=45000,Roll=90000)
	GroundSpeed=400.f //280
	SprintSpeed=500.f
	bCrawler=false//true - // Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
	bCanClimbCeilings=false//true - // Disabled for Early Access 1/14/15 as part of disabling wall walking - Ramm
	MaxFallSpeed=6000
	JumpZ=750
	bUseQuadrupedFloorConform=true

	// ---------------------------------------------
	// AI / Navigation
	EliteAIType.Add(14); // AT_EliteCrawler
	ElitePawnClass.Add(class'KFPawn_ZedCrawlerKing')
	ControllerClass=class'KFAIController_ZedCrawler'
	bDebugCrawlerPhysics=false
	bDisableTurnInPlace=true
	bBlocksNavigation=true
	//ExtraCostForPath=2000
	DamageRecoveryTimeHeavy=0.75f
	DamageRecoveryTimeMedium=1.0f

	KnockdownImpulseScale=1.0f

	// ---------------------------------------------
	// Special Moves
	Begin Object Name=SpecialMoveHandler_0
		SpecialMoveClasses(SM_Emerge)=class'KFSM_Emerge_Crawler'
		SpecialMoveClasses(SM_Evade)=class'KFSM_Evade'
		SpecialMoveClasses(SM_Evade_Fear)=class'KFSM_Evade_Fear'
	End Object

	// for reference: Vulnerability=(default, head, legs, arms, special)
	IncapSettings(AF_Stun)=		(Vulnerability=(2.0, 2.0, 1.0, 1.0, 1.0), Cooldown=5.0,  Duration=2.5)
	IncapSettings(AF_Knockdown)=(Vulnerability=(2.f),                     Cooldown=1.0)
	IncapSettings(AF_Stumble)=	(Vulnerability=(2.f),                     Cooldown=0.2)
	IncapSettings(AF_GunHit)=	(Vulnerability=(2.5),                     Cooldown=0.2)
	IncapSettings(AF_MeleeHit)=	(Vulnerability=(2.0),                     Cooldown=0.0)
	IncapSettings(AF_Poison)=	(Vulnerability=(10.0),                    Cooldown=7.5, Duration=5.5)
	IncapSettings(AF_Microwave)=(Vulnerability=(0.5),                     Cooldown=7.5,  Duration=3.0)
	IncapSettings(AF_FirePanic)=(Vulnerability=(3),                       Cooldown=7.0,  Duration=5)
	IncapSettings(AF_EMP)=		(Vulnerability=(2.5),                     Cooldown=5.0,  Duration=5.0)
	IncapSettings(AF_Freeze)=	(Vulnerability=(2.5),                     Cooldown=1.5,  Duration=4.5)
	IncapSettings(AF_Snare)=	(Vulnerability=(10.0, 10.0, 10.0, 10.0),  Cooldown=5.5,  Duration=4.0)
    IncapSettings(AF_Bleed)=    (Vulnerability=(2.0))
    IncapSettings(AF_Shrink)=   (Vulnerability=(1.0))
	
	ShrinkEffectModifier = 2.0f

	ParryResistance=1

    // Used for special crawler gas AOE attack "explosion" template
    Begin Object Class=KFGameExplosion Name=ExploTemplate0
        Damage=4
        DamageRadius=450 //600
        DamageFalloffExponent=0.f
        DamageDelay=0.f
        MyDamageType=class'KFDT_Toxic_PlayerCrawlerSuicide'

        // Damage Effects
        KnockDownStrength=0
        KnockDownRadius=0
        FractureMeshRadius=0
        FracturePartVel=0
        ExplosionEffects=KFImpactEffectInfo'ZED_Crawler_ARCH.ToxicGasAoE_Explosion'
        ExplosionSound=AkEvent'WW_WEP_EXP_Dynamite.Play_WEP_EXP_Dynamite_Explosion'
        MomentumTransferScale=100

        // Dynamic Light
        ExploLight=none

        // Camera Shake
        CamShake=CameraShake'FX_CameraShake_Arch.Grenades.Default_Grenade'
        CamShakeInnerRadius=450
        CamShakeOuterRadius=900
        CamShakeFalloff=1.f
        bOrientCameraShakeTowardsEpicenter=true
    End Object
    DeathExplosionTemplate=ExploTemplate0

	LowGoreExplosionImpulse=5000.f

`if(`notdefined(ShippingPC))
	DebugRadarTexture=Texture2D'UI_ZEDRadar_TEX.MapIcon_Crawler';
`endif

	// ---------------------------------------------
	// Spawning
    MinSpawnSquadSizeType=EST_Crawler

	ZEDCowboyHatAttachName=Hat_Attach

	// Only used in Volter Castle for now when the spawn volume has bForceUseMapReplacePawn set to true
	// If we need to reuse it more we'll have to connect map to zed here
	MapReplacePawnClass.Add(class'KFPawn_ZedHansClot')
}
