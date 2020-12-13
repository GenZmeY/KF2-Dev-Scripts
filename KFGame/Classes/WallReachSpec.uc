///=============================================================================
// WallReachSpec
//=============================================================================
// 
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class WallReachSpec extends KFReachSpec
	native(Waypoint);

var() editconst bool bMustJump;

cpptext
{
		/*
	supports() -
	returns true if it supports the requirements of aPawn.  Distance is not considered.
	*/
	virtual UBOOL supports (INT iRadius, INT iHeight, INT moveFlags, INT iMaxFallVelocity)
	{
#if 0
		UBOOL bSupports = CollisionRadius >= iRadius * 0.5 && CollisionHeight >= iHeight;
		if( !bSupports )
		{
			debugf( TEXT("%s SUPPORTS returning FALSE 1 [radii failure][ColRadius: %i ColHeight: %i] [iRadius: %i iHeight: %i moveFlags: %i iMaxFallVelocity: %i]"), *GetName(), CollisionRadius, CollisionHeight, iRadius, iHeight, moveFlags, iMaxFallVelocity );
			return FALSE;
		}

		INT Test = (reachFlags & moveFlags);
		bSupports = ((reachFlags & moveFlags) == reachFlags);
		if( !bSupports )
		{
			debugf( TEXT("%s SUPPORTS returning FALSE 2 [reachflags failure, test: %i] [iRadius: %i iHeight: %i moveFlags: %i iMaxFallVelocity: %i]"), *GetName(), Test, iRadius, iHeight, moveFlags, iMaxFallVelocity );
			return FALSE;
		}

		bSupports = (MaxLandingVelocity <= iMaxFallVelocity); 
		if( !bSupports )
		{
			debugf( TEXT("%s SUPPORTS  returning FALSE [MaxLandingVelocity failure (MaxLandingVelocity: %i)] [iRadius: %i iHeight: %i moveFlags: %i iMaxFallVelocity: %i]"), *GetName(), MaxLandingVelocity, iRadius, iHeight, moveFlags, iMaxFallVelocity );
		}
		else
		{
			debugf( TEXT("%s SUPPORTS returning TRUE"), *GetName() );
		}
		return bSupports;
#else
		return ( (CollisionRadius >= iRadius * 0.5 )
			&& (CollisionHeight >= iHeight)
			&& ((reachFlags & moveFlags) == reachFlags)
			&& (MaxLandingVelocity <= iMaxFallVelocity) );
#endif
	}

	virtual UBOOL IsForced() { return bManuallyForced; }
	virtual INT CostFor( APawn* P );
	virtual INT AdjustedCostFor( APawn* P, const FVector& StartToGoalDir, ANavigationPoint* Goal, INT Cost );
	virtual FPlane PathColor()
	{
		if( bMustJump )
		{
			return FPlane( 0.545f, 0.909f, 0.137f, 1.f );
		}
		else if( !bManuallyForced )
		{
			return FPlane( 0.89f, 0.565f, 0.294f, 1.f );
		}
		else
		{
			return FPlane( 0.909f, 0.709f, 0.137f, 1.f );
		}
	}
	virtual UBOOL CanBeSkipped(APawn* P)
	{
		return FALSE;
	}
}

DefaultProperties
{
	bSkipPrune=false
	bCanCutCorners=false
	bCheckForObstructions=true
}
