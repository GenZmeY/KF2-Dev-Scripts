//=============================================================================
// KFGFxPostGameContainer_TeamAwards
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 05/19/2015
//=============================================================================

class KFGFxPostGameContainer_TeamAwards extends KFGFxObject_Container;

var localized string NoTeamAwardsGivenString;
var localized string TeamAwardsString;
var localized string PersonalBestsString;

var GFxObject NoAwardsTextField;


//==============================================================
// Initialization
//==============================================================
function Initialize( KFGFxObject_Menu NewParentMenu )
{
	local KFPlayerController KFPC;

	super.Initialize( NewParentMenu );
	LocalizeText();
	//send team awards
	NoAwardsTextField = GetObject("noAwardsTextField");
	SendTeamAwards();
	SendPersonalBests();

	// Record stats only after personal bests have been given
	if( GetPC() != none && GetPC().IsLocalPlayerController() )
	{
		KFPC = KFPlayerController( GetPC() );
		if( KFPC != none )
		{
			KFPC.ClientWriteAndFlushStats();
		}
	}
}

function LocalizeText()
{
	local GFxObject TextObject;
	

	TextObject = CreateObject("Object");

	TextObject.SetString("noAwards", 		NoTeamAwardsGivenString);
	TextObject.SetString("teamAwards", 		TeamAwardsString);
	TextObject.SetString("personalBests", 	PersonalBestsString);

	SetObject("localizedText", TextObject);
}

function SendPersonalBests()
{
	local GFxObject ObjectArray, TeamAWard;
	local KFPlayerController KFPC;
	local int i;
	local EphemeralMatchStats StatCollector;
	local array<AARAward>PersonalBests;

	KFPC = KFPlayerController(GetPC());

	if(KFPC == none)
	{
		return;
	}

	StatCollector = KFPC.MatchStats;

	StatCollector.GetPersonalBests(PersonalBests);

	ObjectArray = CreateArray();

	for (i = 0; i < PersonalBests.length; i++)
	{
		TeamAWard = CreateObject("Object");
		TeamAward.SetString("stat", Localize( "EphemeralMatchStats", PersonalBests[i].TitleIdentifier, "KFGame"));
		TeamAward.SetString("icon", "img://"$PersonalBests[i].IconPath);
		TeamAward.SetBool("highLight", PersonalBests[i].bHighLight);
		TeamAward.SetString("statValue", (PersonalBests[i].DisplayValue @Localize( "EphemeralMatchStats", PersonalBests[i].ValueIdentifier, "KFGame")));

		ObjectArray.SetElementObject(i, TeamAWard);
	}
	SetObject("personalBests", ObjectArray);
}

function SendTeamAwards()
{
	local GFxObject ObjectArray, TeamAWard;
	local KFPlayerController KFPC;
	local int i, ItemCount;
	local EphemeralMatchStats StatCollector;

	KFPC = KFPlayerController(GetPC());

	if(KFPC == none)
	{
		return;
	}

	StatCollector = KFPC.MatchStats;

	ObjectArray = CreateArray();

	ItemCount=0;
	for (i = 0; i < StatCollector.TeamAwardList.length; i++)
	{
		if(StatCollector.TeamAwardList[i].PRI != none && ItemCount < 8)
		{
			TeamAWard = CreateObject("Object");
			TeamAward.SetString("playerName", StatCollector.TeamAwardList[i].PRI.PlayerName);
			TeamAward.SetString("stat", Localize( "EphemeralMatchStats", StatCollector.TeamAwardList[i].TitleIdentifier, "KFGame"));
			TeamAward.SetString("icon", "img://"$StatCollector.TeamAwardList[i].IconPath);
			TeamAward.SetString("statValue", (StatCollector.TeamAwardList[i].DisplayValue @Localize( "EphemeralMatchStats", StatCollector.TeamAwardList[i].ValueIdentifier, "KFGame")));

			ObjectArray.SetElementObject(ItemCount, TeamAWard);
			ItemCount++;
		}
		else
		{
			TeamAWard = none;
		}
	}

	NoAwardsTextField.SetVisible(ItemCount == 0);

	SetObject("teamAwards", ObjectArray);

}