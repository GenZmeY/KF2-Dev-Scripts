//=============================================================================
// KFDT_Krampus_ChipperPit
//=============================================================================
// Special case KFDT for tracking damage caused by the chipper pit in Krampus'
//		Lair map.  Forwards special event tracking to all player controllers
//		for the special event objective.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================

class KFDT_Krampus_ChipperPit extends KFDT_Bludgeon
	abstract;

var const SeasonalEventIndex SeasonIndex;
var const int ObjectiveIndex;

static function ApplyKillResults(KFPawn KilledPawn)
{
	local KFPlayerController KFPC;
	local WorldInfo WI;

	super.ApplyKillResults(KilledPawn);

	if (KFPawn_Monster(KilledPawn) != none)
	{
		WI = class'WorldInfo'.static.GetWorldInfo();
		if (WI != None)
		{
			foreach WI.AllControllers(class'KFPlayerController', KFPC)
			{
				// @todo: hook up seasonal event here if/when desired
			}
		}
	}
}

defaultproperties
{
	SeasonIndex=SEI_Winter
	ObjectiveIndex=1
	bIsTrapDamage=true
}