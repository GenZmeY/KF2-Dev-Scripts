//=============================================================================
// KFSM_PlayerPatriarch_TentacleGrab
//=============================================================================
// Player-controlled Patriarch's tentacle attack
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class KFSM_PlayerPatriarch_TentacleGrab extends KFSM_Patriarch_Grapple;

/** The minimum FOV required for a target */
var float MinGrabTargetFOV;

protected function bool InternalCanDoSpecialMove()
{
	local KFPawn KFP, BestTarget;
	local vector CameraNormal, Projection;
	local float FOV;
	local float DistSQ, BestDistSQ;
	local float TentacleRangeSQ;

	if( PCOwner == none || PCOwner.PlayerCamera == none )
	{
		return false;
	}

	if( KFPOwner != none && KFPOwner.IsLocallyControlled() )
	{
		CameraNormal = vector( PCOwner.PlayerCamera.CameraCache.POV.Rotation );
		TentacleRangeSQ = Square(MaxRange + TentacleEndBoneOffset);

		foreach KFPOwner.WorldInfo.AllPawns( class'KFPawn', KFP )
		{
			if( CanInteractWithPawn(KFP) )
			{
				Projection = KFP.Location - KFPOwner.Location;
				DistSQ = VSizeSQ( Projection );
				if( DistSQ <= TentacleRangeSQ )
				{
					FOV = CameraNormal dot Normal( Projection );

					if( FOV > MinGrabTargetFOV )
					{
						if( !IsPawnPathClear(KFPOwner, KFP, KFP.Location, KFPOwner.Location, vect(1,1,1), true) )
						{
							continue;
						}

						if( BestTarget == none || DistSQ < BestDistSQ )
						{
							BestDistSQ = DistSQ;
							BestTarget = KFP;
						}					
					}
				}
			}
		}

		// If we have an interaction pawn to start, use it
		if( BestTarget != none )
		{
			KFPOwner.InteractionPawn = BestTarget;
		}

		// Execute the move regardless of whether there's a follower
		return true;
	}

	return super.InternalCanDoSpecialMove();
}

function SpecialMoveStarted( bool bForced, name PrevMove )
{
	local KFPawn_ZedPatriarch MyPatPawn;

	if( KFPOwner != none )
	{
		MyPatPawn = KFPawn_ZedPatriarch( KFPOwner );
	}

	if( MyPatPawn != none )
	{
		TentacleDamage = MyPatPawn.TentacleDamage;
		TentacleDmgType = MyPatPawn.TentacleDamageType;
	}

	super.SpecialMoveStarted( bForced, PrevMove );
}

/** StartInteraction */
function StartInteraction() 
{
    super.StartInteraction();

    if( Follower != none )
    {
        ++KFPlayerReplicationInfoVersus(KFPOwner.PlayerReplicationInfo).ZedGrabs;
    }
}

/** Script Tick function. */
function Tick( float DeltaTime )
{
	local rotator DesiredRotation;

    super.Tick( DeltaTime );

    if( KFPOwner != none && Follower != none && KFPOwner.SpecialMoveFlags >= EGS_GrabSuccess )
    {
        // Set pawn rotation
        DesiredRotation = KFPOwner.Rotation;
        DesiredRotation.Yaw = FInterpTo( KFPOwner.Rotation.Yaw, rotator(Follower.Location - KFPOwner.Location).Yaw, DeltaTime, 1.f );
        ForcePawnRotation( KFPOwner, DesiredRotation, false );
    }
}

/** Lock view rotation when grabbing */
function ProcessViewRotation( float DeltaTime, out rotator out_ViewRotation, out Rotator out_DeltaRot )
{
    if( KFPOwner != none && Follower != none && KFPOwner.SpecialMoveFlags >= EGS_GrabSuccess )
    {
		out_ViewRotation = RInterpTo( out_ViewRotation, KFPOwner.Rotation, DeltaTime, 1.f );
		out_DeltaRot = rot(0,0,0);
    }
}

defaultproperties
{
	Handle=KFSM_PlayerPatriarch_TentacleGrab
	MinGrabTargetFOV=0.85f
}