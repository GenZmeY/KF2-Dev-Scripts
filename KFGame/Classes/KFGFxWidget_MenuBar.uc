//=============================================================================
// KFGFxWidget_MenuBar
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 1/10/2014
//=============================================================================

class KFGFxWidget_MenuBar extends KFGFxObject_Menu;

var localized array<string> MenuStrings;
var localized string ExitString;
var localized string CancelString;

var localized string ServerBrowserString;
var localized string MatchmakingString;
var localized string CreateGameString;
var localized string SoloString;
var localized string OverviewString;

var localized array<string> TitleStrings;
var localized array<string> DescriptionStrings;

var string LastHomeString;

//@HSL_BEGIN - JRO - 4/28/2016 - Disable certain features for PlayGo
var GFxObject InventoryButton, StoreButton, VaultButton, GearButton;
var int SaveCurrentMenuIndex;
var bool bCachedGameFullyInstalled;
//@HSL_END

var bool bAllowBumper;

/** Used for mid-match gear changes */
var bool bGearButtonEnabled;

function InitializeCurrentMenu(byte CurrentMenuIndex)
{
	UpdateMenu(CurrentMenuIndex);
}


function CalloutButtonBumperPress(int Delta)
{
	if(bAllowBumper)
	{
		SetInt("calloutButtonBumperPress", Delta);
		bAllowBumper= false;
		`TimerHelper.SetTimer(0.1, false, 'UnblockBumper', self);
	}
}

function UnblockBumper()
{
	bAllowBumper = true;
}

function  UpdateMenu(byte CurrentMenuIndex)
{
	local GFxObject DataProvider;
	local GFxObject TempObj;
	local byte i;
	DataProvider = CreateArray();

	GetObject("menuButtonBar").GetObject("dataProvider");

	for (i = 0; i < MenuStrings.length; i++)
	{
		if ( i == MenuStrings.length -1 && class'WorldInfo'.static.IsMenuLevel() && class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Orbis) )
		{
			// Console doesn't show exit game in the main menu.
			break;
		}

	    TempObj = CreateObject( "Object" );
		HandleButtonSpecialCase(i, TempObj);
		DataProvider.SetElementObject(i, TempObj);
	}

	//@HSL_BEGIN - JRO - 4/28/2016 - Update the buttons if the game is finished installing while sitting in the main menus
	SaveCurrentMenuIndex = CurrentMenuIndex;
	if(InventoryButton != None && StoreButton != None && !class'WorldInfo'.static.IsE3Build() && class'WorldInfo'.static.IsConsoleBuild())
	{
		CheckGameFullyInstalled();
	}
	//@HSL_END

	DataProvider.SetInt("selectedIndex", CurrentMenuIndex);
	SetObject("dataObject", DataProvider);
}

function HandleButtonSpecialCase(byte ButtonIndex, out GFxObject GfxButton)
{
	GfxButton.SetInt( "index", ButtonIndex );

	// For XB1, we change the EXIT button to logout while in the menus
	if (ButtonIndex == UI_Exit_Menu && class'WorldInfo'.static.IsMenuLevel() && class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Durango))
	{
		GfxButton.SetString( "label",  ConsoleLocalize("LogoutTitle") );
	}
	else
	{
		GfxButton.SetString( "label", MenuStrings[ButtonIndex] );
	}

	switch (ButtonIndex)
	{
		case UI_Dosh_Vault:
			GfxButton.SetBool( "enabled", CanUseDoshVault() );
			VaultButton = GfxButton;
			return;
		case UI_GEAR:
			// Disable the gear button if we're a spectator (must be done through data provider since buttons don't exist yet)
			bGearButtonEnabled = CanUseGearButton( GetPC(), Manager );
			GfxButton.SetBool( "enabled", bGearButtonEnabled );
			GearButton = GfxButton;
			return;
		case UI_Start:
			GfxButton.SetString( "label",  GetHomeButtonName());
			GfxButton.SetBool( "bPulsing", ShouldStartMenuPulse() );
			break;
		//@HSL_BEGIN - JRO - 4/28/2016 - Disable these buttons for certain scenarios. Including PlayGo
		case UI_Inventory:
			GfxButton.SetBool( "enabled", CanUseInventory() ); // Disabled for E3 build
			InventoryButton = GfxButton;
			return;
		case UI_Store:
			// XB1 needs Xbox Store terminology
			if( class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Durango) )
			{
				GfxButton.SetString( "label", ConsoleLocalize("StoreStringXB1", "KFGFxMenu_Store") );
			}
			GfxButton.SetBool("enabled", CanUseStore() ); // Disabled for E3 build
			StoreButton = GfxButton;
			return;
		//@HSL_END
	}

	GfxButton.SetBool( "enabled", true );
}

function UpdateInventoryButtonState()
{
	if(InventoryButton != none)
	{
		InventoryButton.SetBool( "enabled", CanUseInventory() );
	}
}

function UpdateGearButtonState()
{
	local bool bCanChangeGear;

	bCanChangeGear = CanUseGearButton( GetPC(), Manager );
	if( bCanChangeGear != bGearButtonEnabled )
	{
		SetGearMenuEnabled( bCanChangeGear );
		bGearButtonEnabled = bCanChangeGear;
	}
}

function SetGearMenuEnabled( bool bEnabled )
{
    ActionScriptVoid( "setGearButtonEnabled" );
}

//@HSL_BEGIN - JRO - 4/28/2016 - Disable certain features for PlayGo
function CheckGameFullyInstalled()
{
	if(!bCachedGameFullyInstalled)
	{
		if( class'GameEngine'.static.IsGameFullyInstalled() )
		{
			bCachedGameFullyInstalled = true;
			InventoryButton.SetBool("enabled", CanUseInventory());
			StoreButton.SetBool("enabled", CanUseStore());
			VaultButton.SetBool("enabled", CanUseDoshVault());
			GearButton.SetBool("enabled", CanUseGearButton(GetPC(), Manager));
			UpdateMenu(SaveCurrentMenuIndex);
		}
		else
		{
			InventoryButton.SetBool("enabled", false);
			StoreButton.SetBool("enabled", false);
			VaultButton.SetBool("enabled", false);
			GearButton.SetBool("enabled", false);
			`TimerHelper.SetTimer(1.0f, false, nameof(CheckGameFullyInstalled), self);
		}
	}
}
//@HSL_END


// Opens the "Are you sure you want to quit" Confirmation
function OpenQuitPopUp()
{
	local string TitleString, DescriptionString;
	TitleString         = TitleStrings[Rand(TitleStrings.length)];
    DescriptionString   = DescriptionStrings[Rand(DescriptionStrings.length)];
    if(Manager != none)
    {
        Manager.DelayedOpenPopup(EConfirmation, EDPPID_Misc, TitleString, DescriptionString, ExitString, Class'KFCommon_LocalizedStrings'.default.CancelString, OnQuitConfirm );
    }
}

//called from delegate for popups
function OnQuitConfirm()
{
	consolecommand("quit");
}


function OpenLogoutPopup()
{
	if (Manager != none)
	{
		Manager.DelayedOpenPopup(EConfirmation, EDPPID_Misc, ConsoleLocalize("LogoutDialogTitle"), ConsoleLocalize("LogoutDialogMessage"), ConsoleLocalize("LogoutTitle"), Class'KFCommon_LocalizedStrings'.default.CancelString, OnLogoutConfirm);
	}
}


function OnLogoutConfirm()
{
	KFGameEngine(class'Engine'.static.GetEngine()).PerformLogout();
}


function string GetHomeButtonName()
{
	local byte StartMenuState;

	if(Manager != none && Manager.StartMenu != none)
	{
		if(Manager.CurrentMenuIndex == UI_ServerBrowserMenu)
		{
			LastHomeString = ServerBrowserString;
			return LastHomeString;
		}

		StartMenuState = Manager.StartMenu.GetStartMenuState();
		if( Manager.CurrentMenuIndex == UI_Start )
		{
			switch (StartMenuState)
			{
				case EMatchmaking:
					LastHomeString = MatchmakingString;
					break;
				case ECreateGame:
					LastHomeString = CreateGameString;
					break;
				case EServerBrowser:
					LastHomeString = ServerBrowserString;
					break;
				case ESoloGame:
					LastHomeString = SoloString;
					break;
				case EOverview:
				case EServerBrowserOverview:
					LastHomeString = OverviewString;
					break;
				Default:
					LastHomeString = MenuStrings[0];
			}
		}
	}
	return LastHomeString;
}

function bool ShouldStartMenuPulse()
{
	if(Manager != none &&
		class'WorldInfo'.static.IsMenuLevel() &&
			OnlineLobby != none )
	{
		return Manager.CurrentMenuIndex != UI_Start && OnlineLobby.IsInLobby();
	}
	return false;
}

static function bool CanUseGearButton( PlayerController PC, KFGfxMoviePlayer_Manager GfxManager )
{
	if (class'WorldInfo'.static.IsConsoleBuild() && !class'GameEngine'.static.IsGameFullyInstalled())
	{
		return false;
	}

	if( !GfxManager.bAfterLobby && (!PC.PlayerReplicationInfo.bOnlySpectator)
		|| class'WorldInfo'.static.IsMenuLevel() )
	{
		return true;
	}
	return false;
}

//Duplicate function because Gear menu override in VS class
function bool CanUseInventory()
{
	if( class'WorldInfo'.static.IsE3Build() )
	{
		return false;
	}

	if (class'WorldInfo'.static.IsConsoleBuild() && !class'GameEngine'.static.IsGameFullyInstalled())
	{
		return false;
	}

	if( GetPC().Pawn != none && !Manager.bAfterLobby ||class'WorldInfo'.static.IsMenuLevel() )
	{
		return true;
	}
	return false;
}

function bool CanUseDoshVault()
{
	if (class'WorldInfo'.static.IsConsoleBuild() && !class'GameEngine'.static.IsGameFullyInstalled())
	{
		return false;
	}

	return class'WorldInfo'.static.IsMenuLevel();
}


function bool CanUseStore()
{
	if( class'WorldInfo'.static.IsE3Build() )
	{
		return false;
	}

	if( class'WorldInfo'.static.IsConsoleBuild() && class'GameEngine'.static.GetOnlineSubsystem().PlayerInterface.GetLoginStatus( GetLP().ControllerId ) != LS_LoggedIn || !class'GameEngine'.static.GetOnlineSubsystem().IsGameOwned())
	{
		return false;
	}

	return true;
}

DefaultProperties
{
	bAllowBumper=true
}