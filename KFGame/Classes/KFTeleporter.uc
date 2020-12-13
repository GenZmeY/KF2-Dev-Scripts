//=============================================================================
// KFTeleporter
//=============================================================================
// Teleporter that supports an array of URLs.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFTeleporter extends Teleporter
	placeable;

var transient int URLNum;
var() array<string> URLs;

/**	Handling set URL num event from Kismet */
function OnSetURLNum( KFSeqAct_SetTeleporterURLNum Action )
{
	local SeqVar_Int IntVar;

	if( Action.VariableLinks[0].LinkedVariables.Length > 0 )
	{
		IntVar = SeqVar_Int( Action.VariableLinks[1].LinkedVariables[0] );
		if( IntVar != none )
		{
			URLNum = IntVar.IntValue;
		}
	}
}

event PostBeginPlay()
{
	if( URL ~= "" && URLs.Length == 0 )
	{
		SetCollision(false, false); //destination only
	}

	Super(NavigationPoint).PostBeginPlay();
}

/** Duplicated from Teleporter.uc, need to replace URL with our array element */
simulated event PostTouch( actor Other )
{
	local Teleporter D,Dest[16];
	local int i;
	local string TempURL;

	if( URLs.Length > 0 && URLNum < URLs.Length )
	{
		TempURL = URLs[URLNum];
	}
	else
	{
		TempURL = URL;
	}

	if( (InStr( TempURL, "/" ) >= 0) || (InStr( TempURL, "#" ) >= 0) )
	{
		// Teleport to a level on the net.
		if( (Role == ROLE_Authority) && (Pawn(Other) != None)
			&& Pawn(Other).IsHumanControlled() )
			WorldInfo.Game.SendPlayer(PlayerController(Pawn(Other).Controller), TempURL);
	}
	else
	{
		// Teleport to a random teleporter in this local level, if more than one pick random.

		foreach AllActors( class 'Teleporter', D )
			if( string(D.tag)~=TempURL && D!=Self )
			{
				Dest[i] = D;
				i++;
				if ( i > arraycount(Dest) )
					break;
			}

		i = rand(i);
		if( Dest[i] != None )
		{
			// Teleport the actor into the other teleporter.
			if ( Other.IsA('Pawn') )
			{
				Other.PlayTeleportEffect(true, true);
			}
			Dest[i].Accept( Other, self );
		}
	}
}

/** Duplicated from Teleporter.uc, need to replace URL with our array element */
event Actor SpecialHandling( Pawn Other )
{
	local string TempURL;

	if( URLs.Length > 0 && URLNum < URLs.Length )
	{
		TempURL = URLs[URLNum];
	}
	else
	{
		TempURL = URL;
	}

	if ( bEnabled && (Other.Controller.RouteCache.Length > 1) && (Teleporter(Other.Controller.RouteCache[1]) != None)
		&& (string(Other.Controller.RouteCache[1].tag)~=TempURL) )
	{
		if(IsOverlapping(Other))
		{
			PostTouch(Other);
		}

		return self;
	}
	return None;
}

defaultproperties
{
	//defaults
}