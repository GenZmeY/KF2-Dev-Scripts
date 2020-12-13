//=============================================================================
// KFReplicatedShowPathActor
//=============================================================================
// Low-impact replicated actor that creates a trail path to any actor.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFReplicatedShowPathActor extends Actor
	dependsOn(KFSeqAct_ShowPath);

/** Team number to check against */
var byte PathTeamNum;

/** Volume to check against, if any, for displaying the path to players */
var Volume CheckVolume;

/** Volume check type for path displaying */
var byte VolumeCheckType;

/** Target actor, set once and replicated at spawn */
var repnotify Actor Target;

/** The Template to use for this emitter */
var ParticleSystem EmitterTemplate;

replication
{
	if( bNetInitial )
		CheckVolume, VolumeCheckType, PathTeamNum, Target;
}

simulated event ReplicatedEvent( name VarName )
{
	if( VarName == nameOf(Target) )
	{
		InitPath();
	}
	else
	{
		super.ReplicatedEvent( VarName );
	}
}

function SetPathTarget( Actor NewTarget, optional Volume NewVolume, optional eVolumeCheckType NewVolumeCheckType=VCT_None, optional byte NewPathTeamNum=0 )
{
	Target = NewTarget;
	CheckVolume = NewVolume;
	VolumeCheckType = NewVolumeCheckType;
	PathTeamNum = NewPathTeamNum;
	if( WorldInfo.NetMode != NM_DedicatedServer )
	{
		InitPath();
	}
}

simulated function InitPath()
{
	if (Target != none)
	{
		ShowPath();
		SetTimer( 2.f, true, nameOf(Timer_ShowPath) );
	}
	else
	{
		ClearTimer(nameof(Timer_ShowPath));
	}
}

simulated function Timer_ShowPath()
{
	if( !bDeleteMe && Target != none )
	{
		ShowPath();
	}
}

simulated function ShowPath()
{
	local PlayerController PC;
	local bool bInsideVolume;
	local EPathSearchType OldSearchType;
	local KFEmit_ScriptedPath Path;
	local Actor nodePathRoot;
	local bool bPathFound;

	foreach Target.WorldInfo.LocalPlayerControllers( class'PlayerController', PC )
	{
		if( PC.Pawn == none || PC.GetTeamNum() != PathTeamNum || !PC.Pawn.IsAliveAndWell() )
		{
			continue;
		}

		if( VolumeCheckType != VCT_None && CheckVolume != none )
		{
			bInsideVolume = class'KFSeqAct_SetTraderVolumeIgnore'.static.IsActorInVolume( PC.Pawn, CheckVolume );
			if( VolumeCheckType == VCT_InVolume )
			{
				if( !bInsideVolume )
				{
					continue;
				}
			}
			else if( VolumeCheckType == VCT_NotInVolume )
			{
				if( bInsideVolume )
				{
					continue;
				}
			}
		}

		OldSearchType = PC.Pawn.PathSearchType;
		PC.Pawn.PathSearchType = PST_Constraint;
		class'Path_ToTrader'.static.ToTrader( PC.Pawn );
		class'Goal_AtActor'.static.AtActor( PC.Pawn, Target,, false );

		nodePathRoot = PC.FindPathToward( Target );
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
			Path = Target.Spawn(class'KFGame.KFEmit_ScriptedPath', PC,, PC.Pawn.Location);
			Path.SetTemplate(EmitterTemplate, true);

			if (Path != none)
			{
				// instead of using the routecache for the last waypoint, use the trader pod mesh
				Path.SetDestination(Target.Location + vect(0, 0, 50));
			}
		}
		else
		{
			`log( "[KFReplicatedShowPathActor] ShowScriptedPath - No Path Found" );
		}

		PC.Pawn.ClearConstraints();
		PC.Pawn.PathSearchType = OldSearchType;
	}
}

simulated function SetEmitterTemplate(ParticleSystem NewTemplate)
{
	EmitterTemplate = NewTemplate;
}

DefaultProperties
{
	// Actor
	bGameRelevant=true
	bNoDelete=false
	bIgnoreEncroachers=true
	bPushedByEncroachers=false

	// Network
	RemoteRole=ROLE_SimulatedProxy
	NetUpdateFrequency=0.1f
	bAlwaysRelevant=true
	bOnlyDirtyReplication=true
	bReplicateMovement=false
	bSkipActorPropertyReplication=true
	bIgnoreNetRelevancyCollision=true

	// KFReplicatedShowPathActor
	VolumeCheckType=0
	PathTeamNum=0
	EmitterTemplate=ParticleSystem'FX_Gameplay_EMIT.FX_Trader_Trail'
}