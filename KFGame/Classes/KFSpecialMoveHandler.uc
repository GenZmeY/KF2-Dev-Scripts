//=============================================================================
// KFSpecialMoveHandler
//=============================================================================
// Manages starting and stopping special moves for pawns
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================
class KFSpecialMoveHandler extends Object within KFPawn
	config(Game);

/** Array matching above enumeration. List of classes to Instance */
var Array<class<KFSpecialMove> >	SpecialMoveClasses;

/** Special move pending, activated after the current one terminates. */
var KFSpecialMoveStruct	PendingSpecialMoveStruct;

/*********************************************************************************************
 * Functions
 *********************************************************************************************/

/**
 * Start a special move.
 * @Note this doesn't handle replication to owning client if called from server.
 * See ServerDoSpecialMove() and LocalDoSpecialMove() for alternatives.
 * @network: local player and server
 */
simulated event DoSpecialMove(ESpecialMove NewMove, optional bool bForceMove, optional Pawn InInteractionPawn, optional INT InSpecialMoveFlags, optional bool bSkipReplication, optional bool bIsPendingMove)
{
	local ESpecialMove			PrevMove;

	`Log("New special move requested:" @ NewMove @ InInteractionPawn @ InSpecialMoveFlags @ "bForceMove:" @ bForceMove, bLogSpecialMove);

	// Make sure NewMove is instanced.
	if( NewMove != SM_None && !VerifySpecialMoveInstance(NewMove) )
	{
		`Warn(WorldInfo.TimeSeconds @ Self @ GetFuncName() @ "couldn't instance special move" @ NewMove);
		return;
	}

	// If we are starting our pending special move, clear pending move struct
	if( bIsPendingMove )
	{
		`Log("- PendingSpecialMove is being started.", bLogSpecialMove);
		PendingSpecialMoveStruct.SpecialMove = SM_None;
		PendingSpecialMoveStruct.InteractionPawn = None;
		PendingSpecialMoveStruct.Flags = 0;
	}

	// Ignore redundant calls to the same move
	if( NewMove == SpecialMove )
	{
		ReassignSpecialMove(InInteractionPawn, InSpecialMoveFlags, bSkipReplication);
		return;
	}

	PrevMove = SpecialMove;

	if ( !bIsPendingMove )
	{
		// If doing a special move transition, see if we can have an override or a chaining.
		if( !bForceMove && SpecialMove != SM_None && NewMove != SM_None )
		{
			if ( !CanOverrideSpecialMove(NewMove, InInteractionPawn, InSpecialMoveFlags) )
			{
				return;
			}

			bForceMove = TRUE;	// Override successful!
		}

		// Stop previous special move
		if( SpecialMove != SM_None )
		{
			`Log("- leaving move:" @ SpecialMove, bLogSpecialMove);

			// clear the special move so that checks like IsDoingSpecialMove and IsEvading no longer pass
			SpecialMove = SM_None;
			SpecialMoveEnded(PrevMove, NewMove);
		}

		// If we're ending a specialmove, and we have a pending one. Start it now.
		if( NewMove == SM_None && PendingSpecialMoveStruct.SpecialMove != SM_None )
		{
			if ( DoPendingSpecialMove(bForceMove) )
			{
				return;	// success, we can leave
			}
		}
	}

	// Check that we can do special move and special move has been/can be instanced
	if( NewMove != SM_None && !bForceMove && !CanDoSpecialMove(NewMove) )
	{
		`Warn(WorldInfo.TimeSeconds @ Self @ GetFuncName() @ "cannot do requested special move" @ NewMove);
		return;
	}

	// Set new special move
	SpecialMove = NewMove;
	InteractionPawn = KFPawn(InInteractionPawn);
	SpecialMoveFlags = InSpecialMoveFlags;

	if ( !bSkipReplication &&
		 (((WorldInfo.NetMode != NM_Standalone || WorldInfo.IsRecordingDemo()) && Role == ROLE_Authority) &&
		  (SpecialMove == SM_None || SpecialMoves[SpecialMove].ShouldReplicate())) )
	{
		ReplicateSpecialMove(NewMove, InInteractionPawn, InSpecialMoveFlags);
	}

	// if it's a valid special move
	if( SpecialMove != SM_None )
	{
		// notify the special move it should start
		SpecialMoveStarted(SpecialMove, PrevMove, bForceMove);

		// if this was a forced move clear any pending moves since this was an interrupt of the current move
		if( bForceMove )
		{
			PendingSpecialMoveStruct.SpecialMove = SM_None;
			PendingSpecialMoveStruct.InteractionPawn = None;
			PendingSpecialMoveStruct.Flags = 0;
		}
	}
}

/** helper for DoSpecialMove */
simulated private function bool CanOverrideSpecialMove(ESpecialMove NewMove, Pawn InInteractionPawn, int InSpecialMoveFlags)
{
	local name SpecialMoveName, NewMoveName;	

	NewMoveName = SpecialMoves[NewMove].Handle;
	SpecialMoveName = SpecialMoves[SpecialMove].Handle;

	// See if we can override current special move, otherwise just queue new one until current is finished.
	if( SpecialMoves[SpecialMove].CanOverrideMoveWith(NewMoveName) || SpecialMoves[NewMove].CanOverrideSpecialMove(SpecialMoveName) )
	{
		`Log("- Overriding" @ SpecialMove @ "with" @ NewMove @ "(previous pending:" @ PendingSpecialMoveStruct.SpecialMove $ ")", bLogSpecialMove);
		return true;
	}
	else
	{
		// extra check to see if we can chain since non-owning clients can call DoSpecialMove directly in certain cases
		if( SpecialMoves[SpecialMove].CanChainMove(NewMoveName) )
		{
			`Log("- chaining" @ NewMove @ "after" @ SpecialMove @ "(previous pending:" @ PendingSpecialMoveStruct.SpecialMove $ ")", bLogSpecialMove);
			PendingSpecialMoveStruct.SpecialMove = NewMove;
			PendingSpecialMoveStruct.InteractionPawn = InInteractionPawn;
			PendingSpecialMoveStruct.Flags = InSpecialMoveFlags;
		}
		else
		{
			`Warn(WorldInfo.TimeSeconds @ Self @ GetFuncName() @ "Cannot override, cannot chain." @ NewMove @ "is lost! SpecialMove:" @ SpecialMove @ "Pending:" @ PendingSpecialMoveStruct.SpecialMove );
		}
		return false;
	}
}

/** helper for DoSpecialMove */
simulated private function bool DoPendingSpecialMove(bool bForceMove)
{
	local ESpecialMove	NextMove;

	`Log("- triggering pending special move:" @ PendingSpecialMoveStruct.SpecialMove, bLogSpecialMove);

	NextMove = PendingSpecialMoveStruct.SpecialMove;
	DoSpecialMove(PendingSpecialMoveStruct.SpecialMove, bForceMove, PendingSpecialMoveStruct.InteractionPawn, PendingSpecialMoveStruct.Flags, false, true);

	if( SpecialMove == NextMove )
	{
		`Log("- PendingSpecialMove trigger successful for" @ NextMove, bLogSpecialMove);
		// success, we can leave
		return true;
	}
	else
	{
		`Log("- PendingSpecialMove trigger failed for" @ NextMove @ "Proceeding to clear SpecialMove", bLogSpecialMove);
		return false;
	}
}

/** helper for DoSpecialMove */
simulated private function ReassignSpecialMove(Pawn InInteractionPawn, int InSpecialMoveFlags, bool bSkipReplication)
{
	if (InSpecialMoveFlags != SpecialMoveFlags)
	{
		`Log("- updating special move flags", bLogSpecialMove);
		SpecialMoveFlags = InSpecialMoveFlags;
		if (Role == ROLE_Authority && !bSkipReplication)
		{
			ReplicatedSpecialMove.Flags = SpecialMoveFlags;
			bForceNetUpdate = true;
		}
		if ( SpecialMove != SM_None )
		{
			SpecialMoves[SpecialMove].SpecialMoveFlagsUpdated();
		}
	}

	// In JIP situations, InteractionPawn will show up late
	if (InInteractionPawn != InteractionPawn)
	{
		`Log("- updating interaction pawn", bLogSpecialMove);
		InteractionPawn = KFPawn(InInteractionPawn);

		if( Role == ROLE_Authority && !bSkipReplication )
		{
			ReplicatedSpecialMove.InteractionPawn = InteractionPawn;
			bForceNetUpdate = true;
		}

		if( SpecialMove != SM_None )
		{
			SpecialMoves[SpecialMove].InteractionPawnUpdated();
		}
	}

	`Log("- ignoring redundant call", bLogSpecialMove);
}

/** helper for DoSpecialMove */
simulated private function ReplicateSpecialMove(ESpecialMove NewMove, Pawn InInteractionPawn, int InSpecialMoveFlags)
{
	`Log("- Replicating New SM" @ SpecialMove, bLogSpecialMove);

	// Force replication now to non-owning clients
	// If previous replicated SM and new one are the SM,
	// we have to make sure something is different so it is correctly replicated.
	if( ReplicatedSpecialMove.SpecialMove == NewMove )
	{
		// If SM_None, we can just bump up the flags, they don't matter in that case.
		if( ReplicatedSpecialMove.SpecialMove == SM_None )
		{
			ReplicatedSpecialMove.Flags++;
		}
		else if( ReplicatedSpecialMove.InteractionPawn == InInteractionPawn
			&& ReplicatedSpecialMove.Flags == InSpecialMoveFlags )
		{
			// Report an error, so it can be fixed.
			`Warn("Special Move cannot be replicated properly!!!");
			ScriptTrace();
		}
		else
		{
			// SMs are different, so they can be replicated properly.
			ReplicatedSpecialMove.SpecialMove = NewMove;
			ReplicatedSpecialMove.InteractionPawn = InInteractionPawn;
			ReplicatedSpecialMove.Flags = InSpecialMoveFlags;
		}
	}
	else
	{
		// SMs are different, so they can be replicated properly.
		ReplicatedSpecialMove.SpecialMove = NewMove;
		ReplicatedSpecialMove.InteractionPawn = InInteractionPawn;
		ReplicatedSpecialMove.Flags = InSpecialMoveFlags;
	}
	bForceNetUpdate = TRUE;
}

/** helper for DoSpecialMove */
simulated final event bool CanDoSpecialMove(ESpecialMove AMove, optional bool bForceCheck)
{
	// Can always end special moves.
	if( AMove == SM_None )
	{
		return TRUE;
	}

	// if it is a valid move and we have a class for the move
	if (AMove != SM_None && SpecialMoveClasses.length > AMove && SpecialMoveClasses[AMove] != None)
	{
		// Make sure special move is instanced
		if( VerifySpecialMoveInstance(AMove) )
		{
			// and check the instance
			return (CanChainSpecialMove(AMove) && SpecialMoves[AMove].CanDoSpecialMove(bForceCheck));
		}
		`log(GetFuncName() @ "Failed with special move:" @ AMove @ "class:" @ SpecialMoveClasses[AMove] @ Self);
	}
	return FALSE;
}

/** Returns TRUE if the pawn can chain this special move after the current one finishes (or if there currently isn't a special move) */
simulated final private function bool CanChainSpecialMove(ESpecialMove NextMove)
{
	local name SpecialMoveName, NextMoveName;	
	
	NextMoveName = SpecialMoves[NextMove].Handle;
	if ( SpecialMove != SM_None )
	{
		SpecialMoveName = SpecialMoves[SpecialMove].Handle;
	}

	return (SpecialMove == SM_None || SpecialMoves[SpecialMove].CanChainMove(NextMoveName) || SpecialMoves[SpecialMove].CanOverrideMoveWith(NextMoveName) || SpecialMoves[NextMove].CanOverrideSpecialMove(SpecialMoveName));
}

/** Event called when A new special move has started */
simulated final private function SpecialMoveStarted(ESpecialMove NewMove, ESpecialMove PrevMove, bool bForced)
{
	local name PrevMoveName;

	`Log("NewMove:" @ NewMove @ "PrevMove:" @ PrevMove, bLogSpecialMove);

	if( NewMove != SM_None )
	{
		// forward notification to special move instance
		if( SpecialMoves[NewMove] != None )
		{
			if ( PrevMove != SM_None )
			{
				PrevMoveName = SpecialMoves[PrevMove].Handle;
			}

			SpecialMoves[NewMove].SpecialMoveStarted(bForced, PrevMoveName);
		}
	}
}

/** Event called when A new special move has stopped */
simulated final function SpecialMoveEnded(ESpecialMove PrevMove, ESpecialMove NextMove)
{
	local name NextMoveName;

	`Log("PrevMove:" @ PrevMove, bLogSpecialMove);

	if( PrevMove != SM_None && SpecialMoves[PrevMove] != None )
	{
		if ( NextMove != SM_None )
		{
			NextMoveName = SpecialMoves[NextMove].Handle;
		}

		SpecialMoves[PrevMove].SpecialMoveEnded(SpecialMoves[PrevMove].Handle, NextMoveName);
	}
}

/** helper for DoSpecialMove */
simulated function bool VerifySpecialMoveInstance(ESpecialMove AMove)
{
	if( AMove != SM_None )
	{
		if( AMove >= SpecialMoves.Length || SpecialMoves[AMove] == None )
		{
			if( AMove < SpecialMoveClasses.Length && SpecialMoveClasses[AMove] != None )
			{
				SpecialMoves[AMove] = new(Outer) SpecialMoveClasses[AMove];
				
				// Cache a reference to the owner to avoid passing parameters around.
				SpecialMoves[AMove].InitSpecialMove(Outer, 'MoveName');
			}
			else
			{
				`log(GetFuncName() @ "Failed with special move:" @ AMove @ "class:" @ SpecialMoveClasses[AMove] @ Self);
				SpecialMoves[AMove] = None;
				return FALSE;
			}
		}
		return TRUE;
	}
	return FALSE;
}

/**  */
simulated function ClearPendingSpecialMove()
{
	`Log("- Clearing PendingSpecialMove:", bLogSpecialMove);

	PendingSpecialMoveStruct.SpecialMove = SM_None;
	PendingSpecialMoveStruct.InteractionPawn = None;
	PendingSpecialMoveStruct.Flags = 0;
}

/**
 * Request to abort/stop current SpecialMove
 * @bForceNetSync - (deprecated) we're now sending ReplicatedSpecialMove to the owning client
 */
simulated final function EndSpecialMove(optional ESpecialMove SpecialMoveToEnd, optional bool bForceNetSync)
{
	`Log("SpecialMoveToEnd:" @ SpecialMoveToEnd, bLogSpecialMove);

	if( IsDoingSpecialMove() )
	{
		// clear the pending move
		if( SpecialMoveToEnd != SM_None && PendingSpecialMoveStruct.SpecialMove == SpecialMoveToEnd )
		{
			ClearPendingSpecialMove();
		}

		// if no move specified, or it matches the current move
		if( SpecialMoveToEnd == SM_None || IsDoingSpecialMove(SpecialMoveToEnd) )
		{
			// force it to end
			DoSpecialMove(SM_None, TRUE);
		}
	}
}

defaultproperties
{
}
