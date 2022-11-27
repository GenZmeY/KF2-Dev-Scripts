//=============================================================================
// KFGFxWidget_VIP
//=============================================================================
// HUD Widget that displays VIP messages to the player
//=============================================================================
// Killing Floor 2
// Copyright (C) 2022 Tripwire Interactive LLC
//
//=============================================================================

class KFGFxWidget_VIP extends GFxObject;

function SetVIP()
{
    SetString("VIPSetLocalised", Class'KFCommon_LocalizedStrings'.default.VIPString);
    SetString("VIPObjectiveSetLocalised", Class'KFCommon_LocalizedStrings'.default.VIPObjectiveBString);
    SetString("VIPPlayerSet", Class'KFCommon_LocalizedStrings'.default.VIPObjectiveCString);

    SetBool("VIPPlayerNameSetVisibility", true);
    SetBool("VIPHideHealthBar", true);
}

function SetNOVIP(string VIPPlayerName, int VIPCurrentHealth, int VIPMaxHealth)
{
    SetString("VIPSetLocalised", Class'KFCommon_LocalizedStrings'.default.VIPString);
    SetString("VIPObjectiveSetLocalised", Class'KFCommon_LocalizedStrings'.default.VIPObjectiveAString);
    SetString("VIPPlayerSet", VIPPlayerName);

    SetBool("VIPPlayerNameSetVisibility", true);

    UpdateHealth(VIPCurrentHealth, VIPMaxHealth);
}

function UpdateVIPVisibility(bool visible)
{
    if (visible)
    {
        SetBool("VIPSetVisibility", true);
    }
    else
    {
        SetBool("VIPSetVisibility", false);
    }
}

function UpdateHealth(int VIPCurrentHealth, int VIPMaxHealth)
{
    SetFloat("VIPHealthBarPercentage", VIPMaxHealth != 0 ? (float(VIPCurrentHealth) / VIPMaxHealth) : 0.0f);
}