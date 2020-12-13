//=============================================================================
// KFTraderTrigger
//=============================================================================
// Trigger used to start Trader interaction
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================
class KFTraderTrigger extends Trigger_PawnsOnly
	config(Game)
	native
	implements(KFInterface_Usable)
	dependsOn(KFSeqAct_ShowPath);

/** reference to actor to play open/close animations */
var() SkeletalMeshActor	TraderMeshActor;

/** Anim to play when trader is opened or closed (play reverse) */
var() name OpenAnimName;
/** Looping anim to play while trader is open */
var() name IdleLoopAnimName;

/** Sounds for Trader Pod */
var() 	AkEvent					TraderOpenSound;
var() 	AkEvent					TraderCloseSound;

var bool bEnabled;

/** current state of the trader */
var	transient bool  bOpened;

/** Debugging */
var	config bool bLogTrader;
var	const float DistanceOffNavMeshTheTragerIsAllowedToBe;

cpptext
{
#if WITH_EDITOR
	// Suppress "Trigger is not referenced by anything, should be deleted."
	virtual void CheckForErrors() {}
#endif
}

/** KFInterface_Usable */
simulated function bool GetIsUsable( Pawn User )
{
	return bOpened;
}

/** KFInterface_Usable */
function int GetInteractionIndex( Pawn User )
{
	return IMT_UseTrader;
}

/** HUD and Dialog */
event Touch(Actor Other, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal)
{
	local Pawn P;

	`log("KFTrigger_Trader::Touch! Trader:" @ self, bLogTrader);

	Super.Touch(Other, OtherComp, HitLocation, HitNormal);

	class'KFPlayerController'.static.UpdateInteractionMessages( Other );
	P = Pawn(Other);
	if ( P != None )
	{
		// no KFTraderDialogManager object on dedicated server, so use static function
		class'KFTraderDialogManager'.static.PlayApproachTraderDialog( P.Controller );
	}
}

/** HUD */
event UnTouch(Actor Other)
{
	super.UnTouch( Other );
	class'KFPlayerController'.static.UpdateInteractionMessages( Other );
}

/** Handles trigger interaction */
function bool UsedBy(Pawn User)
{
	local KFPawn_Human KFPH;
	local KFPlayerController KFPC;

   	`log("KFTrigger_Trader::UsedBy! Trader:" @ self, bLogTrader);

 	KFPH = KFPawn_Human(User);

	if ( KFPH == none  )
	{
		return false;
	}

	KFPC = KFPlayerController(User.Controller);

	if ( KFPC != none )
	{
		KFPC.OpenTraderMenu();
	}

	return false;
}

/** Open shop at the start of trader time */
simulated function OpenTrader()
{
	local float AnimDuration;
	local Pawn P;

	SetCollision(true, false);
	bOpened = true;

	if ( WorldInfo.NetMode != NM_DedicatedServer)
	{
		if ( TraderMeshActor != None )
		{
			TraderMeshActor.SkeletalMeshComponent.PlayAnim(OpenAnimName);
			AnimDuration = TraderMeshActor.SkeletalMeshComponent.GetAnimLength(OpenAnimName);
			// Need to run this timer on the GRI since this trigger doesn't tick on clients.
			WorldInfo.GRI.SetTimer(AnimDuration, false, nameof(StartTraderLoopAnim), self);
			TraderMeshActor.PlaySoundBase( TraderOpenSound );
		}

		ShowTraderPath();
	}

	foreach TouchingActors(class'Pawn',  P)
	{
		class'KFPlayerController'.static.UpdateInteractionMessages( P );
	}
}

/** Play a looping animation on the active trader mesh */
simulated function StartTraderLoopAnim()
{
	if ( WorldInfo.NetMode != NM_DedicatedServer && TraderMeshActor != None && bOpened )
	{
		TraderMeshActor.SkeletalMeshComponent.PlayAnim(IdleLoopAnimName,,true);
	}
}

/** Spawn emitter path to the active trader */
simulated function ShowTraderPath()
{
	local PlayerController PC;
	local KFGameReplicationInfo KFGRI;
	local EPathSearchType OldSearchType;
	local KFEmit_TraderPath Path;
	local Actor nodePathRoot;
	local bool bInsideVolume, bPathFound;

	KFGRI = KFGameReplicationInfo(WorldInfo.GRI);

	if( bCollideActors && KFGRI != none && KFGRI.bTraderIsOpen && KFGRI.OpenedTrader == self )
	{
		foreach LocalPlayerControllers( class'PlayerController', PC )
		{
			if( PC.Pawn == none || PC.GetTeamNum() == 255 || !PC.Pawn.IsAliveAndWell() )
			{
				continue;
			}

			if( KFGRI.TraderVolumeCheckType != VCT_None && KFGRI.TraderVolume != none )
			{
				bInsideVolume = class'KFSeqAct_SetTraderVolumeIgnore'.static.IsActorInVolume( PC.Pawn, KFGRI.TraderVolume );
				if( KFGRI.TraderVolumeCheckType == VCT_InVolume )
				{
					if( !bInsideVolume )
					{
						continue;
					}
				}
				else if( KFGRI.TraderVolumeCheckType == VCT_NotInVolume )
				{
					if( bInsideVolume )
					{
						continue;
					}
				}
			}

			// Cache off our previous path search type
			OldSearchType = PC.Pawn.PathSearchType;

			// Generate a path network that excludes bIgnoredByTraderTrail navpoints
			PC.Pawn.PathSearchType = PST_Constraint;
			class'Path_ToTrader'.static.ToTrader( PC.Pawn );
			class'Goal_AtActor'.static.AtActor( PC.Pawn, self,, false );

			// Generate path
			nodePathRoot = PC.FindPathToward(self);
			if( nodePathRoot != none )
			{
				bPathFound = true;
			}
			else
			{
				bPathFound = false;
			}

			if( bPathFound )
			{
				Path = Spawn(class'KFEmit_TraderPath', PC,, PC.Pawn.Location);

				// instead of using the routecache for the last waypoint, use the trader pod mesh
				Path.SetDestination(TraderMeshActor != None ? TraderMeshActor.Location + vect(0,0,100): Location);
			}
			else
			{
				if( class'KFEmit_TraderPath'.default.bShowEmitPathDebugArtifacts )
				{
					DrawDebugLine( PC.Pawn.Location, Location, 255, 0, 0, true);
				}
				`log("ShowTraderPath - No Path Found, KFGRI.OpenedTrader: " @ KFGRI.OpenedTrader @ " trader trigger loc: " @ Location @ " - player loc: " @ PC.Pawn.Location, bLogTrader);
			}

			// Clear path constraints and restore previous path search type
			PC.Pawn.ClearConstraints();
			PC.Pawn.PathSearchType = OldSearchType;
		}

		// This timer only needs to run once, not on all controllers
		WorldInfo.GetALocalPlayerController().SetTimer( 2.0, false, nameOf(ShowTraderPath), self );
	}
}

/** Close shop when trader time is over */
simulated function CloseTrader()
{
	local KFPlayerController KFPC;

	SetCollision(false, false);
	bOpened = false;

	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		if ( TraderMeshActor != None )
		{
			TraderMeshActor.SkeletalMeshComponent.PlayAnim(OpenAnimName,,,,, true);
			TraderMeshActor.PlaySoundBase( TraderCloseSound );
		}
		foreach LocalPlayerControllers(class'KFPlayerController', KFPC)
		{
		 	KFPC.CloseTraderMenu();
		 	if( KFPC.Pawn != none )
		 	{
				class'KFPlayerController'.static.UpdateInteractionMessages( KFPC.Pawn );
			}
		}
	}
}

/** Called by CheatManager */
simulated function HideTraderPath()
{
	local KFPlayerController KFPC;
	foreach LocalPlayerControllers(class'KFPlayerController', KFPC)
	{
		KFPC.ClearTimer(nameof(ShowTraderPath), self);
	}
}

defaultproperties
{
	Begin Object NAME=CollisionCylinder LegacyClassName=Trigger_TriggerCylinderComponent_Class
		CollisionRadius=+00400.000000
		CollisionHeight=+00160.000000
		BlockZeroExtent=false
	End Object

	// the GRI turns collision on during trader time
	bCollideActors=false

	OpenAnimName=Open
	IdleLoopAnimName=Printing
	DistanceOffNavMeshTheTragerIsAllowedToBe=500
	TraderOpenSound=AkEvent'WW_UI_Menu.Play_UI_Trader_Build_Start'
	TraderCloseSound=AkEvent'WW_UI_Menu.Play_UI_Trader_Build_Stop'

	bEnabled=true
}
