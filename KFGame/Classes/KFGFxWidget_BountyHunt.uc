

//=============================================================================
// KFGFxWidget_BountyHunt
//=============================================================================
// HUD Widget that displays bounty hunt messages to the player
//=============================================================================
// Killing Floor 2
// Copyright (C) 2023 Tripwire Interactive LLC
//
//=============================================================================

class KFGFxWidget_BountyHunt extends GFxObject;

function SetData(int Bounties, int Dosh, int DoshNoAssist)
{
	local string BountyHuntString, BountyHuntStringDosh;

    BountyHuntString = Localize("Objectives", "BountyHuntDescriptionShort", "KFGame")@Bounties;
    SetString("BountyHuntDescSetLocalised", BountyHuntString);

    BountyHuntStringDosh = ""$Dosh;
    SetString("BountyHuntDoshSetLocalised", BountyHuntStringDosh);	
}

function UpdateBountyHuntVisibility(bool visible)
{
    if (visible)
    {
        SetBool("BountyHuntSetVisibility", true);
    }
    else
    {
        SetBool("BountyHuntSetVisibility", false);
    }
}