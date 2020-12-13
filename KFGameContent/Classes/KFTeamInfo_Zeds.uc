//=============================================================================
// KFTeamInfo_Zeds
//=============================================================================
// KFTeamInfo_Zeds
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Zane Gholson
//=============================================================================
class KFTeamInfo_Zeds extends KFTeamInfo_Human;

simulated function string GetHumanReadableName()
{
    // Temp team name hax - Ramm
    return class'KFCommon_LocalizedStrings'.default.ZedString @TeamName;
} 

DefaultProperties
{
	TeamIndex=255
}
