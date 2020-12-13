//=============================================================================
// KFAIWaveInfo
//=============================================================================
// The AI group setup for a wave
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================

class KFAIWaveInfo extends Object
	hidecategories(Object);

/** Once a squad is dead, do not reuse them */
var() const bool	bRecycleWave;

/** List of available squads to spawn for each wave */
var() const array<KFAISpawnSquad>		Squads;

/** The special squads - spawned once per wave */
var() const array<KFAISpawnSquad>		SpecialSquads;

/** Total number of AI that spawn for 1 player on Normal */
var() const	int	MaxAI<ClampMin=1|ClampMax=200|DisplayName=TotalAIBase>;	// make this max=42 for release

/** Squads that can be triggered to spawn */
var() const array<KFAISpawnSquad>		EventSquads;

/** Copy the list of squads for this wave type */
function GetNewSquadList(out array<KFAISpawnSquad> out_SquadList)
{
	local int i;

    // Clear our AvailableSquadList and repopulate it
	out_SquadList.Length = 0;
	for ( i = 0; i < Squads.Length; i++ )
	{
		if ( Squads[i] != none )
		{
			out_SquadList.AddItem(Squads[i]);
		}
	}
}

/** Add the special squad for this wave type */
function GetSpecialSquad(out array<KFAISpawnSquad> out_SquadList)
{
	if ( SpecialSquads.Length > 0 )
	{
		out_SquadList.AddItem( SpecialSquads[Rand(SpecialSquads.Length)] );
	}
}

/** Copy the list of squads for this wave type */
function GetEventSquadList(out array<KFAISpawnSquad> out_SquadList)
{
	local int i;

    // Clear our AvailableSquadList and repopulate it
	out_SquadList.Length = 0;
	for ( i = 0; i < EventSquads.Length; i++ )
	{
		if ( EventSquads[i] != none )
		{
			out_SquadList.AddItem(EventSquads[i]);
		}
	}
}

defaultproperties
{
	bRecycleWave=true
	MaxAI=32
}