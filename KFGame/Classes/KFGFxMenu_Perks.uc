//=============================================================================
// KFGFxMenu_Perks
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 5/31/2013
//=============================================================================

class KFGFxMenu_Perks extends KFGFxObject_Menu;

`include(KFProfileSettings.uci)

var KFGFxPerksContainer_Selection 		SelectionContainer;
var KFGFxPerksContainer_Header			HeaderContainer;
var KFGFxPerksContainer_Details			DetailsContainer;
var KFGFxPerksContainer_Prestige		PrestigeContainer;
var KFGFxPerksContainer_Skills			SkillsContainer;
var KFGFxPerksContainer_SkillsSummary   SkillsSummaryContainer;

var KFPlayerController KFPC;

var const string  LockIconPath;
var byte LastPerkIndex;
VAR byte LastPerkLevel;
var class<KFPerk> PreviousPerk;
var localized string TierUnlockedText;
var localized string TierUnlockedSecondaryText;


//prestige strings
var localized string CurrentPrestigeLevelString;
var localized string PrestigeString;

var KFPlayerReplicationInfo MyKFPRI;

/** Set to true if we change one of our skills */
var bool bModifiedSkills;
var bool bModifiedPerk;
var bool bChangesMadeDuringLobby;
var bool bModifiedWeaponIndexes;

var name PerkLevelupSound;

var byte SelectedSkillsHolder[`MAX_PERK_SKILLS];

var const private float StickInputThreshold;
var const private float StickResetThreshold;

var transient bool bAxisResetLeft, bAxisResetRight;

function InitializeMenu(KFGFxMoviePlayer_Manager InManager)
{
	super.InitializeMenu(InManager);

	KFPC = KFPlayerController(GetPC());
}

/** Ties the GFxClikWidget variables to the .swf containers and handles events */
event bool WidgetInitialized(name WidgetName, name WidgetPath, GFxObject Widget)
{
	local class<KFPerk> PerkClass;
	PerkClass = KFPC.PerkList[KFPC.SavedPerkIndex].PerkClass;
	switch(WidgetName)
	{		
		case ('HeaderContainer'):
			if ( HeaderContainer == none )
			{
			    HeaderContainer = KFGFxPerksContainer_Header(Widget);
				HeaderContainer.Initialize( self );
		    }
         break;
		case ('SelectionContainer'):
			if ( SelectionContainer == none )
			{
			    SelectionContainer = KFGFxPerksContainer_Selection(Widget);
			    SelectionContainer.Initialize( self );
		    }
         break;
        case ('DetailsContainer'):
			if ( DetailsContainer == none )
			{
			    DetailsContainer = KFGFxPerksContainer_Details(Widget);//some reason this is coming out to none!
			    DetailsContainer.Initialize( self );
			    DetailsContainer.UpdateDetails(PerkClass, SelectedSkillsHolder, false, false);
				DetailsContainer.UpdatePassives(PerkClass);
		    }
         break;
         case ('SkillsContainer'):
			if ( SkillsContainer == none )
			{
			    SkillsContainer = KFGFxPerksContainer_Skills(Widget);
			    SkillsContainer.Initialize( self );
			    SkillsContainer.UpdateSkills(PerkClass, SelectedSkillsHolder);
		    }
			break;
		 case ('PerkPrestigeContainer'):
			 if (PrestigeContainer == none)
			 {
				 PrestigeContainer = KFGFxPerksContainer_Prestige(Widget);//some reason this is coming out to none!
				 PrestigeContainer.Initialize(self);
			 }
         break;

         case ('SelectedPerkSummaryContainer'):
         	if( SkillsSummaryContainer == none)
         	{
         		SkillsSummaryContainer = KFGFxPerksContainer_SkillsSummary(Widget);
         		SkillsSummaryContainer.Initialize( self );
				SkillsSummaryContainer.UpdateSkills(PerkClass, SelectedSkillsHolder);
         	}
         break;
	}

	return true;
}

function OnOpen()
{
	local KFGameReplicationInfo KFGRI;

	GetGameViewportClient().HandleInputAxis = OnAxisModified;

	LastPerkIndex = KFPC.SavedPerkIndex;

	MyKFPRI = KFPlayerReplicationInfo( GetPC().PlayerReplicationInfo );
	if (KFPC == none)
	{
		`log("NO KFPC!!");
		KFPC = KFPlayerController(GetPC());
	}

		// Current Perk not allowed, search for the first one
	KFGRI = KFGameReplicationInfo( KFPC.WorldInfo.GRI );
	if( KFGRI != none && !KFGRI.IsPerkAllowed(KFPC.PerkList[LastPerkIndex].PerkClass) )
	{
		if (KFGRI.PerksAvailableData.bBerserkerAvailable)          LastPerkIndex=0;
		else if (KFGRI.PerksAvailableData.bCommandoAvailable)      LastPerkIndex=1;
		else if (KFGRI.PerksAvailableData.bSupportAvailable)       LastPerkIndex=2;
		else if (KFGRI.PerksAvailableData.bFieldMedicAvailable)    LastPerkIndex=3;
		else if (KFGRI.PerksAvailableData.bDemolitionistAvailable) LastPerkIndex=4;
		else if (KFGRI.PerksAvailableData.bFirebugAvailable)       LastPerkIndex=5;
		else if (KFGRI.PerksAvailableData.bGunslingerAvailable)    LastPerkIndex=6;
		else if (KFGRI.PerksAvailableData.bSharpshooterAvailable)  LastPerkIndex=7;
		else if (KFGRI.PerksAvailableData.bSwatAvailable)          LastPerkIndex=8;
		else if (KFGRI.PerksAvailableData.bSurvivalistAvailable)   LastPerkIndex=9;
		else 													   LastPerkIndex=0;
		KFPC.SavedPerkIndex = LastPerkIndex;
	}
	
	UpdateSkillsHolder(KFPC.PerkList[KFPC.SavedPerkIndex].PerkClass);
    UpdateContainers(KFPC.PerkList[KFPC.SavedPerkIndex].PerkClass); 

    UpdateLock();
    CheckTiersForPopup();

    if(SelectionContainer != none)
    {
    	SelectionContainer.SetPerkListEnabled(!KFPlayerReplicationInfo(KFPC.PlayerReplicationInfo).bReadyToPlay);
    }

    ActionScriptVoid("updatePrompts");
}

function CheckTiersForPopup()
{
	local array<string> UnlockedPerkNames;
	local byte bTierUnlocked;
	local string SecondaryPopupText;
	local byte i; 
	local class<KFPerk> PerkClass;
	local int UnlockedPerkLevel;
	
	for (i = 0; i < KFPC.PerkList.Length; i++)
	{
		PerkClass = KFPC.PerkList[i].PerkClass;
		class'KFPerk'.static.LoadTierUnlockFromConfig(PerkClass, bTierUnlocked, UnlockedPerkLevel);
		if( bool(bTierUnlocked) && KFPC.PerkList[i].PerkLevel >= UnlockedPerkLevel )
		{
			UnlockedPerkNames.AddItem(PerkClass.default.PerkName);
		}
	}

	if(UnlockedPerkNames.length > 0)
	{
		for (i = 0; i < UnlockedPerkNames.length; i++)
		{
			if( i > 0 )
			{
				SecondaryPopupText = SecondaryPopupText $"," @UnlockedPerkNames[i];
			}
			else
			{
				SecondaryPopupText = TierUnlockedSecondaryText @UnlockedPerkNames[i];
			}
		}

		KFPC.MyGFxManager.DelayedOpenPopup(ENotification, EDPPID_ExitToMainMenu, TierUnlockedText, SecondaryPopupText, class'KFCommon_LocalizedStrings'.default.OKString,,,,,,PerkLevelupSound);
	}
}

event OnClose()
{
	local bool bShouldUpdatePerk;

	GetGameViewportClient().HandleInputAxis = none;

  	if( KFPC != none )
  	{
  		if( bModifiedPerk || bModifiedSkills || bModifiedWeaponIndexes)
  		{
			bShouldUpdatePerk = bModifiedPerk && LastPerkIndex != KFPC.SavedPerkIndex;

			SavePerkData();

			if( !bChangesMadeDuringLobby && (bShouldUpdatePerk || bModifiedSkills) && KFPC.CanUpdatePerkInfo() )
			{
				KFPC.NotifyPerkUpdated();
  			}

			if( bShouldUpdatePerk )
			{
	  			SelectionContainer.SavePerk( LastPerkIndex );
				Manager.CachedProfile.SetProfileSettingValueInt( KFID_SavedPerkIndex, LastPerkIndex );
			}

			if (bModifiedWeaponIndexes)
			{
				Manager.CachedProfile.SetProfileSettingValueInt( KFID_SurvivalStartingWeapIdx, KFPC.SurvivalPerkWeapIndex );
				Manager.CachedProfile.SetProfileSettingValueInt( KFID_SurvivalStartingGrenIdx, KFPC.SurvivalPerkGrenIndex );
			}

  			bModifiedPerk = false;
  			bModifiedSkills = false;
			bModifiedWeaponIndexes = false;
  		}
  	}

	Manager.CachedProfile.Save( GetLP().ControllerId );
	super.OnClose();
}

event OnTraderTimeStart()
{
    UpdateLock();
}

function OnRoundOver()
{
	UpdateLock();
}

function bool IsMatchStarted()
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo(GetPC().WorldInfo.GRI);

	return KFGRI != none && KFGRI.bMatchHasBegun;
}

function PerkChanged( byte NewPerkIndex, bool bClickedIndex)
{
	local KFGameReplicationInfo KFGRI;

  	if( KFPC != none )
  	{
		KFGRI = KFGameReplicationInfo( KFPC.WorldInfo.GRI );

		// If the perk is not allowed stop the change process
		if( KFGRI != none && !KFGRI.IsPerkAllowed(KFPC.PerkList[NewPerkIndex].PerkClass) )
		{
			return;
		}

		// We aren't actually changing our selected perk so don't save stuff.
		UpdateSkillsHolder( KFPC.PerkList[NewPerkIndex].PerkClass );
  		
  		bChangesMadeDuringLobby = !IsMatchStarted();
		
		// Again don't save stuff if we are only looking at another perk.
		if( bClickedIndex )
		{
			LastPerkIndex = NewPerkIndex;
	  		bModifiedPerk = true;

	  		// Only update perk immediately if we don't have a valid pawn
	  		if( KFPC.Pawn == none || !KFPC.Pawn.IsAliveAndWell() || KFGRI.bTraderIsOpen )
	  		{
				SavePerkData();
	  			SelectionContainer.SavePerk( NewPerkIndex );
				Manager.CachedProfile.SetProfileSettingValueInt( KFID_SavedPerkIndex, NewPerkIndex );
			}
		}

  		UpdateContainers( KFPC.PerkList[NewPerkIndex].PerkClass, bClickedIndex );
	}
}

//@TODO: Change this to change on level up.  Irrelevant if perk is selected, the menu will need to update on all perk level ups
function OneSecondLoop()
{
	if(KFPC != none)
	{
		if( PreviousPerk == KFPC.PerkList[KFPC.SavedPerkIndex].PerkClass && LastPerkLevel != KFPC.PerkList[KFPC.SavedPerkIndex].PerkLevel )
		{
			UpdateContainers(KFPC.PerkList[KFPC.SavedPerkIndex].PerkClass);
			PreviousPerk = KFPC.PerkList[KFPC.SavedPerkIndex].PerkClass;
			LastPerkLevel = KFPC.PerkList[KFPC.SavedPerkIndex].PerkLevel;			
			return;
		}		
	}
}

function UpdateLock()
{
	local WorldInfo TempWorldInfo;
	local KFGameReplicationInfo KFGRI;

	TempWorldInfo = class'WorldInfo'.static.GetWorldInfo();
	if ( TempWorldInfo != none && TempWorldInfo.GRI != none )
	{
		KFGRI = KFGameReplicationInfo(TempWorldInfo.GRI);
		if ( KFGRI != none && KFPC != none )
		{
			SetBool( "locked", (KFGRI.CanChangePerks() && KFPC.WasPerkUpdatedThisRound()) );
		}
	}
}

function UpdateContainers( class<KFPerk> PerkClass, optional bool bClickedIndex=true )
{
	if( KFPC != none )
	{
		if( HeaderContainer != none )
		{
			HeaderContainer.UpdatePerkHeader( PerkClass );
		}
		
		if( DetailsContainer != none )
		{
			DetailsContainer.UpdateDetails( PerkClass, SelectedSkillsHolder, false, false );
			DetailsContainer.UpdatePassives( PerkClass );
		}
		
		// Don't change the perk selection since we just selected another index to look at.
		if( SelectionContainer != none && bClickedIndex )
		{
			SelectionContainer.UpdatePerkSelection( LastPerkIndex );
		}

		if (PrestigeContainer != none)
		{
			PrestigeContainer.SendPerkData();
		}
		UpdateSkillsUI( PerkClass );
	}
}

/** Update which skills we have selected when our perk build has been updated
*   or skills have changed */
function UpdateSkillsUI( Class<KFPerk> PerkClass )
{
	if( SkillsContainer != none )
	{
		SkillsContainer.UpdateSkills( PerkClass, SelectedSkillsHolder );
	}
	if( SkillsSummaryContainer != none )
	{
		SkillsSummaryContainer.UpdateSkills( PerkClass, SelectedSkillsHolder );
	}
}

function UpdateSkillsHolder(class<KFPerk> PerkClass)
{
	local int PerkBuild;
	

	PerkBuild = KFPC.GetPerkBuildByPerkClass( PerkClass );
	KFPC.GetPerk().GetUnpackedSkillsArray( PerkClass, PerkBuild,  SelectedSkillsHolder);
}

/** Saves the modified perk data */
function SavePerkData()
{
	if( KFPC != none )
  	{
		if( bModifiedSkills )
		{
			// Update our previous build
			KFPC.CurrentPerk.UpdatePerkBuild( SelectedSkillsHolder, KFPC.PerkList[LastPerkIndex].PerkClass );

			// Send a notify if we can't currently switch our build
			if( !KFPC.CanUpdatePerkInfo() )
			{
				KFPC.NotifyPendingPerkChanges();
			}
			
			bModifiedSkills = false;
		}

  		KFPC.ClientWriteAndFlushStats();
	}
}

function ConfirmPrestige()
{
	if (KFPC != none )
	{
		ActionScriptVoid("playPrestigeAnimation");
		KFPC.PerformPrestigeReset(KFPC.CurrentPerk.class);
		class'KFMusicStingerHelper'.static.PlayPerkPrestigeStinger(KFPC);
		OnOpen();		
	}
}

//==============================================================
// ActionScript Callbacks
//==============================================================
function Callback_ConfirmPerkReset()
{
	//if main menu, return and do nothing
	if (!class'WorldInfo'.static.IsMenuLevel())
	{
		return;
	}

	if (KFPC != none)
	{
		if (KFPC.CurrentPerk.GetLevel() < `MAX_PERK_LEVEL)
		{
			Manager.DelayedOpenPopup(ENotification, EDPPID_Misc, Class'KFCommon_LocalizedStrings'.default.NoticeString, Class'KFGFxPerksContainer_Prestige'.default.NotHightenoughLevelString,
				Class'KFCommon_LocalizedStrings'.default.ConfirmString);
		}
		else if (KFPC.CurrentPerk.GetCurrentPrestigeLevel() >= `MAX_PRESTIGE_LEVEL)
		{
			//show confirmation pop up here
			Manager.DelayedOpenPopup(ENotification, EDPPID_Misc, Class'KFCommon_LocalizedStrings'.default.NoticeString, Class'KFGFxPerksContainer_Prestige'.default.AtMaxPrestigeLevelString,
				Class'KFCommon_LocalizedStrings'.default.ConfirmString);
		}
		else
		{
			//show confirmation pop up here
			Manager.DelayedOpenPopup(EConfirmation, EDPPID_Misc, Class'KFCommon_LocalizedStrings'.default.NoticeString, Class'KFCommon_LocalizedStrings'.default.PrestigeWarningString,
				Class'KFCommon_LocalizedStrings'.default.ConfirmString, Class'KFCommon_LocalizedStrings'.default.CancelString, ConfirmPrestige);
		}	
	}
}


function Callback_ReadyClicked( bool bReady )
{
	SavePerkData();

	super.Callback_ReadyClicked( bReady );
}

function Callback_PerkSelected(byte NewPerkIndex, bool bClickedIndex)
{
	local KFGameReplicationInfo KFGRI;

	KFGRI = KFGameReplicationInfo( KFPC.WorldInfo.GRI );
	if (KFGRI != none && KFGRI.IsRandomPerkMode())
	{
		return;
	}

	// bClickedIndex let's us know if the index was clicked and needs to be changed or if it was just selected and we should look at other perk info.
	PerkChanged(NewPerkIndex,bClickedIndex);
}

function Callback_SkillSelected( byte TierIndex, byte SkillIndex )
{
	if ( KFPC != none )
  	{
  		bModifiedSkills = true;
  		bChangesMadeDuringLobby = !IsMatchStarted();
		SelectedSkillsHolder[TierIndex] = SkillIndex;
		UpdateSkillsUI(KFPC.PerkList[LastPerkIndex].PerkClass);
		SavePerkData();

		if ( KFPC.PerkList[LastPerkIndex].PerkClass.Name == 'KFPerk_Survivalist' )
		{
			DetailsContainer.UpdateDetails( KFPC.CurrentPerk.Class, SelectedSkillsHolder, false, false );
		}
  	}
}

/** @Todo Zane check if this callback is necessary */
function Callback_SkillSelectionOpened()
{
	if( SkillsContainer != none)
	{
		SkillsContainer.UpdateTierUnlockState(KFPC.PerkList[LastPerkIndex].PerkClass);
	}
}

function OnPrevWeaponPressed()
{
	local byte NewIndex;

	NewIndex = KFPC.CurrentPerk.OnPrevWeaponSelected();
	KFPC.SurvivalPerkWeapIndex = NewIndex;

	DetailsContainer.UpdateDetails( KFPC.CurrentPerk.Class, SelectedSkillsHolder, true, false );
	bModifiedWeaponIndexes=true;
}

function OnNextWeaponPressed()
{
	local byte NewIndex;

	NewIndex = KFPC.CurrentPerk.OnNextWeaponSelected();
	KFPC.SurvivalPerkWeapIndex = NewIndex;

	DetailsContainer.UpdateDetails( KFPC.CurrentPerk.Class, SelectedSkillsHolder, false, true );
	bModifiedWeaponIndexes=true;
}

function OnPrevGrenadePressed()
{
	local byte NewIndex;

	NewIndex = KFPC.CurrentPerk.OnPrevGrenadeSelected();
	KFPC.SurvivalPerkGrenIndex = NewIndex;
	
	DetailsContainer.UpdateDetails( KFPC.CurrentPerk.Class, SelectedSkillsHolder, true, false );
	bModifiedWeaponIndexes=true;
}

function OnNextGrenadePressed()
{
	local byte NewIndex;

	NewIndex = KFPC.CurrentPerk.OnNextGrenadeSelected();
	KFPC.SurvivalPerkGrenIndex = NewIndex;

	DetailsContainer.UpdateDetails( KFPC.CurrentPerk.Class, SelectedSkillsHolder, false, true );
	bModifiedWeaponIndexes=true;
}

event bool OnAxisModified( int ControllerId, name Key, float Delta, float DeltaTime, bool bGamepad )
{
	if (GetPC().PlayerInput.bUsingGamepad )
	{	
		if (DetailsContainer != none && bGamepad)
		{
			OnGamepadAxisModified(ControllerId, Key, Delta, DeltaTime, bGamepad);
		}
	}

	return false;
}

function OnGamepadAxisModified( int ControllerId, name Key, float Delta, float DeltaTime, bool bGamepad )
{
	local float AbsDelta;
	
	AbsDelta = Abs(Delta);

	if ( KFPC.CurrentPerk.static.CanChoosePrimaryWeapon() && Key == 'XboxTypeS_LeftX' )
	{
		if (bAxisResetLeft && AbsDelta > StickInputThreshold)
		{			
			if (Delta < 0)
			{
				OnPrevWeaponPressed();
			}
			else
			{
				OnNextWeaponPressed();
			}
			bAxisResetLeft = false;
		}
		else if (!bAxisResetLeft && AbsDelta  < StickResetThreshold)
		{
			bAxisResetLeft = true;
		}
	}
	else if (KFPC.CurrentPerk.static.CanChooseGrenade() && Key == 'XboxTypeS_RightX')
	{
		if (bAxisResetRight && AbsDelta > StickInputThreshold)
		{			
			if (Delta < 0)
			{
				OnPrevGrenadePressed();
			}
			else
			{
				OnNextGrenadePressed();
			}
			bAxisResetRight = false;
		}
		else if (!bAxisResetRight && AbsDelta  < StickResetThreshold)
		{
			bAxisResetRight = true;
		}
	}
}


defaultproperties
{
	PerkLevelupSound=LevelUp_Popup
	LockIconPath="ui_perktalent_tex.UI_PerkTalent_Locked"
	SubWidgetBindings.Add((WidgetName="PerkPrestigeContainer",WidgetClass=class'KFGFxPerksContainer_Prestige'))
    SubWidgetBindings.Add((WidgetName="SelectionContainer",WidgetClass=class'KFGFxPerksContainer_Selection'))
    SubWidgetBindings.Add((WidgetName="HeaderContainer",WidgetClass=class'KFGFxPerksContainer_Header'))
    SubWidgetBindings.Add((WidgetName="SkillsContainer",WidgetClass=class'KFGFxPerksContainer_Skills'))
    SubWidgetBindings.Add((WidgetName="DetailsContainer",WidgetClass= class'KFGFxPerksContainer_Details'))
	SubWidgetBindings.Add((WidgetName="SelectedPerkSummaryContainer",WidgetClass=class'KFGFxPerksContainer_SkillsSummary'))
	LastPerkIndex=255
	LastPerkLevel=255
	
	bAxisResetLeft=true
	bAxisResetRight=false
	StickInputThreshold=0.5
	StickResetThreshold=0.5
}
