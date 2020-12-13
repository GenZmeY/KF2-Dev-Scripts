//=============================================================================
// KFGFxMenu_DoshVault
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 6/27/2017
//=============================================================================

class KFGFxMenu_DoshVault extends KFGFxObject_Menu;

var name PopUpCrateEventName;
var name PileDisappearEventName;

var name DoshVaultSoundThemeName;

var localized string YourDoshString;
var localized string NextRewardString;
var localized string DoshVaultString;
var localized string YourCratesString;
var localized string OpenCratesString;
var localized string CrateUnlockedString;
var localized string DelayedCrateString;

var bool bSeenAllDoshAnimation;

var int ItemID;

var OnlineSubsystem OnlineSub;
var ItemProperties RewardItemDetailsHolder;

var KFPlayerController KFPC;

var bool bPausedForCrate;

function InitializeMenu( KFGfxMoviePlayer_Manager InManager )
{
	super.InitializeMenu(InManager);

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();

	InitialRewardItem();
 	LocalizeContainer();

 	UpdatePlayerCrateCount();

    KFPC = KFPlayerController(GetPC());
    InitStart();
}

function InitStart()
{
	local KFGameInfo_Entry KFEntry;
	if(class'WorldInfo'.static.IsMenuLevel())
	{
		KFEntry = KFGameInfo_Entry(GetPC().WorldInfo.Game);
		KFEntry.InitVault();
		if(KFPC.GetLastSeenDoshCount() == KFPC.GetTotalDoshCount())
		{
			DelayedInit();
		}
		else
		{
			SetVisible(false);
		}
	}
}

//menu will not open correctly due to animation timeline if this is done on init
function DelayedInit()
{
	UpdatePlayerDoshMeter();
	SetVisible(true);
	//UpdatePlayerCrateCount();
}


function OnOpen()
{
	super.OnOpen();
	bPausedForCrate = false;
	bSeenAllDoshAnimation = false;
	if ( class'WorldInfo'.static.IsMenuLevel() )
	{
		Manager.ManagerObject.SetBool("backgroundVisible", false);
	}

	KFPC.CheckHasViewedDoshVault();
	if(KFPC.GetTotalDoshCount() == KFPC.GetLastSeenDoshCount())
	{
		KFPC.TriggerGlobalEventClass(class'KFSeqEvent_DoshVault', KFPC, DVE_IdleNoDosh);
	}
	else
	{
		KFPC.TriggerGlobalEventClass(class'KFSeqEvent_DoshVault', KFPC, DVE_Idle);
	}

	KFPC.VerifyDoshVaultCrates();

    if(!bSeenAllDoshAnimation)
    {
    	InitializeMenu(Manager);
    }
}

function OnClose()
{
	if (class'WorldInfo'.static.IsMenuLevel())
	{
		Manager.ManagerObject.SetBool("backgroundVisible", true);
	}

    AbortSquence();
}

function AbortSquence()
{
	KFPC.TriggerGlobalEventClass(class'KFSeqEvent_DoshVault', KFPC, DVE_ABORT);
    KFPC.ResetCustomizationCamera();
    KFPC.ClearTimer(nameof(DelayedInit));
    bPausedForCrate = false; //sanity
}

function LocalizeContainer()
{
	local GFxObject LocalizedObject;

	LocalizedObject = CreateObject("Object");

	LocalizedObject.SetString("yourDosh", 		YourDoshString);
	LocalizedObject.SetString("nextReward", 	NextRewardString);
	LocalizedObject.SetString("nextUnlock", 	GetNextUnlockName());
	LocalizedObject.SetString("titleString",	DoshVaultString);
	LocalizedObject.SetString("yourCrates", 	YourCratesString);
	LocalizedObject.SetString("openCrate", 		OpenCratesString);
	LocalizedObject.SetString("crateUnlocked", 	CrateUnlockedString);
	LocalizedObject.SetString("iconLocation", 	"img://"$GetCrateIcon());
	LocalizedObject.SetString("crateDelayed", 	DelayedCrateString);


	SetObject("localizedText", LocalizedObject);
}

function InitialRewardItem()
{
	local int ItemIndex;

	ItemIndex = OnlineSub.ItemPropertiesList.Find('Definition', ItemID);

	if( ItemIndex != INDEX_NONE )
	{
		RewardItemDetailsHolder = OnlineSub.ItemPropertiesList[ItemIndex];
	}
}

function UpdatePlayerDoshMeter()
{
	local int CurrentTier;

	CurrentTier = int(KFPC.GetLastSeenDoshCount() / KFPC.GetDoshVaultTierValue());
				//Last seen dosh, 				total dosh 					starting tier, 					amount in tier, 								crate number
	SendDoshInfo(KFPC.GetLastSeenDoshCount(), KFPC.GetTotalDoshCount(), KFPC.GetDoshVaultTierValue() * CurrentTier,	KFPC.GetDoshVaultTierValue(),			 GetCrateCount());
}


function int GetCrateCount()
{
	local int CrateCount;
	local int i;
	if(OnlineSub == none)
	{
		return INDEX_NONE;
	}
	for (i = 0; i < OnlineSub.CurrentInventory.length; i++)
	{
		if(OnlineSub.CurrentInventory[i].Definition == ItemID )
		{
			CrateCount++;
		}
	}

	return CrateCount;
}

function UpdatePlayerCrateCount()
{
	SetInt("storedCratesValue", GetCrateCount());
}

function string GetCrateIcon()
{
	//"img://"$TempItemDetailsHolder.IconURL);
	return RewardItemDetailsHolder.IconURL;
}

function string GetNextUnlockName()
{
	//return crate name
	return RewardItemDetailsHolder.Name;
}

function SendDoshInfo(int OldDosh, int NewDosh, int TierBase, int TierLength, int CrateNum)
{
	local GFxObject DataObject;

	if (OldDosh == INDEX_NONE || NewDosh == INDEX_NONE)
	{
		Manager.DelayedOpenPopup(ENotification, EDPPID_Misc, class'KFCommon_LocalizedStrings'.default.NoticeString, class'KFCommon_LocalizedStrings'.default.FailedToReachInventoryServerString, class'KFCommon_LocalizedStrings'.default.OKString);
		`log("something isn't right.  Connection issue may be present.  To prevent angry Reddit mobs, just don't animate");
		bSeenAllDoshAnimation = true;
		return;
	}

	if (NewDosh < OldDosh)
	{
		NewDosh = OldDosh;
		//Out of sync saves.  Players still get their crates.
	}

	//start particles if not the same
	if(OldDosh == NewDosh)
	{
		`log("no new Vosh!");
		bSeenAllDoshAnimation = true;
	}

	DataObject = CreateObject("Object");

	DataObject.SetInt("oldDosh", 	OldDosh);
	DataObject.SetInt("newDosh", 	NewDosh);
	DataObject.SetInt("tierBase", 	TierBase);
	DataObject.SetInt("tierLength",	TierLength);
	DataObject.SetInt("crateNum", 	CrateNum);

	SetObject("doshData", DataObject);
}

function bool CanCloseVaultMenu()
{
	return bSeenAllDoshAnimation;
}

function Callback_UpdateDosh(int NewValue)
{
	local KFGameInfo_Entry KFGIE;

	KFGIE = KFGameInfo_Entry(GetPC().WorldInfo.Game);

    if (KFGIE != none)
    {
      	KFGIE.UpdateDoshPiles(NewValue);
      	if(bPausedForCrate)
      	{
      		KFPC.TriggerGlobalEventClass(class'KFSeqEvent_DoshVault', KFPC, DVE_ResumeFill);
      		bPausedForCrate = false;
      	}

    }
}

function Callback_FinalAnimationComplete()
{
	local KFGameInfo_Entry KFGIE;

	KFGIE = KFGameInfo_Entry(GetPC().WorldInfo.Game);

	if (KFGIE != none)
	{
		KFGIE.FinalAnimationPlayed(KFPC);
	}

	KFPC.TriggerGlobalEventClass(class'KFSeqEvent_DoshVault', KFPC, DVE_FillComplete);

	if(KFPC != none)
	{
		KFPC.MarkDoshVaultSeen();
	}

	//save last seen amount
	bSeenAllDoshAnimation = true;
}

function Callback_DoshAnimationComplete()
{
	//unlocked crate
	Manager.PlaySoundFromTheme(PopUpCrateEventName, DoshVaultSoundThemeName);
	KFPC.CheckUnlockDoshVaultReward();
	KFPC.TriggerGlobalEventClass(class'KFSeqEvent_DoshVault', KFPC, DVE_PauseFill);
	bPausedForCrate = true;
}

function Callback_AnimationBegin()
{

}

function Callback_OpenCrateClicked()
{
	Manager.SelectIDOnOpen = ItemID;
	Manager.OpenMenu(UI_Inventory);
}


DefaultProperties
{
	DoshVaultSoundThemeName=SoundTheme_DoshVault
	PopUpCrateEventName=PopUpCrate
	PileDisappearEventName=DoshPileOut
	ItemID=5313 //hozine supply crate 12
}