

//=============================================================================
// KFGFxWidget_GunGame
//=============================================================================
// HUD Widget that displays gun game messages to the player
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//
//=============================================================================

class KFGFxWidget_GunGame extends GFxObject;

function SetData( int score, int max_score, int level, int max_level )
{
    SetString("WeaponLevelSetLocalised", Class'KFCommon_LocalizedStrings'.default.WeaponLevelString);
    SetString("GunPointsSetLocalised", Class'KFCommon_LocalizedStrings'.default.GunPointsString);

	SetInt("GunGameSetLevel", level);
	SetInt("GunGameSetMaxLevel", max_level);
	SetInt("GunGameSetScore", score);
	SetInt("GunGameSetMaxScore", max_score);
}

function UpdateGunGameVisibility(bool visible)
{
    if (visible)
    {
        SetBool("GunGameSetVisibility", true);
    }
    else
    {
        SetBool("GunGameSetVisibility", false);
    }
}