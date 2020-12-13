//=============================================================================
// AICommand_Hans_GunStance
//=============================================================================
// AI Command to handle Hans pulling out/putting away his weapons
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// John "Ramm-Jaeger" Gibson
//=============================================================================

class AICommand_Hans_GunStance extends AICommand_SpecialMove
	within KFAIController_Hans;

var byte StanceType;

/** Simple constructor that pushes a new instance of the command for the AI */
static function bool SetGunStance( KFAIController_Hans AI, byte StanceChangeType )
{
	local AICommand_Hans_GunStance Cmd;

	if( AI != None )
	{
		Cmd = new(AI) default.class;
		if( Cmd != None )
		{
			AI.PushCommand( Cmd );
			Cmd.StanceType = StanceChangeType;
			AI.LastStanceChangeTime=AI.WorldInfo.TimeSeconds;
			if( KFPawn(AI.Pawn) != none && KFPawn(AI.Pawn).bIsSprinting )
            {
                KFPawn(AI.Pawn).SetSprinting( false );
            }
			return true;
		}
	}

	return false;
}

function Pushed()
{
	Super.Pushed();

	if( bUsePluginsForMovement && MovementPlugin != none )
	{
		MovementPlugin.DisablePlugin();
	}

	DisableMeleeRangeEventProbing();
}

function Popped()
{
	if( bUsePluginsForMovement && MovementPlugin != none )
	{
		MovementPlugin.EnablePlugin();
	}

	Super.Popped();
	EnableMeleeRangeEventProbing();
}

state Command_SpecialMove
{
	function ESpecialMove GetSpecialMove()
	{
		return SM_ChangeStance;
	}

	/** Begin executing the special move */
	function bool ExecuteSpecialMove()
	{
		SpecialMove = GetSpecialMove();

		`AILog( GetFuncName()@SpecialMove, 'AICommand_Hans_GunStance' );

		if( SpecialMove != SM_None && (!bShouldCheckSpecialMove || MyKFPawn.CanDoSpecialMove( SpecialMove )) )
		{
            MyKFPawn.DoSpecialMove(SpecialMove, true, GetInteractionPawn(), StanceType);
			return true;
		}
		else
		{
			return false;
		}
	}
}

DefaultProperties
{
	bShouldCheckSpecialMove=true
	bAllowedToAttack=false
	bIgnoreNotifies=true
	bIgnoreStepAside=true
}

