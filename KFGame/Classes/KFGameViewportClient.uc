//=============================================================================
// KFGameViewportClient
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Author 12/3/2012
//=============================================================================

class KFGameViewportClient extends GameViewportClient
	native(UI);
var array<string> TripWireOfficialMaps;
var array<string> CommunityOfficialMaps;
var LinearColor BackgroundColor;
/** The message that the front ends pop up will display if there is a connection issue */
var string ErrorTitle;
var string ErrorMessage;

var string LastConnectionAttemptAddress;

var localized array<string> RandomLoadingStrings;
var localized string OfficialCommunityString;
var localized string TripWireOfficialString;
var localized string CommunityCustomString;
var FONT MessageFont;
var float FontScale;

/** Keep track of whether we have seen the Initial Interaction Screen. */
var bool bSeenIIS;
var bool bNeedDisconnectMessage;
var bool bNeedSignoutMessage;
var bool bHandlePlayTogether;

var bool bDownloadingContent;
var string CurrentDownloadName;
var int CurrentDownloadProgress;

cpptext
{
	virtual void ShowSpawnVolumes( ESetMode SetMode );
};

function NotifyConnectionError(EProgressMessageType MessageType, optional string Message=Localize("Errors", "ConnectionFailed", "Engine"), optional string Title=Localize("Errors", "ConnectionFailed_Title", "Engine") )
{
	local KFGameEngine KFGEngine;
	KFGEngine = KFGameEngine( Class'KFGameEngine'.static.GetEngine() );
	
	// Don't override cached error messages until we've dealt with them
	if ( ErrorTitle == "" )
	{
		// localize our strings
		ErrorTitle = class'KFLocalMessage'.static.getLocalized(Title);
		ErrorMessage = class'KFLocalMessage'.static.getLocalized(Message);
		KFGEngine.SetLastConnectionError(Message, Title);
	}

	super.NotifyConnectionError(MessageType, Message, Title);
}

event NotifyDownloadProgress ( EProgressMessageType ProgressType, string ProgressTitle, string ProgressDescription, bool SuppressPasswordRetry = false)
{	
	if(ProgressType == PMT_DownloadProgress )
	{
		bDownloadingContent = true;
		CurrentDownloadName = ProgressTitle;
		CurrentDownloadProgress = int(float(ProgressDescription) * 100);
	}
}

event ClearDownloadInfo()
{
	CurrentDownloadName = "";
	CurrentDownloadProgress = 0;
	bDownloadingContent = false;
}

//Ported from RO2, storing last address that we attempted to connect to.
event PreBrowse(string Address)
{
	LastConnectionAttemptAddress = Address;
}

/** Returns the error message related to any disconnects */
function GetErrorMessage(out string outTitle, out string outMessage)
{
	outTitle = ErrorTitle;
	outMessage = ErrorMessage;

	ErrorTitle = "";
	ErrorMessage = "";
}

/**
 * Displays the transition screen.
 * @param Canvas - The canvas to use for rendering.
 */
function DrawTransition(Canvas Canvas)
{
	local string RandomLoadingString;
	switch(Outer.TransitionType)
	{
		case TT_Loading:
			RandomLoadingString = GetRandomLoadingMessage();
			DrawTransitionMessage(Canvas,RandomLoadingString);
			break;

	}
}

function string GetRandomLoadingMessage()
{
	return RandomLoadingStrings[Rand(RandomLoadingStrings.length)];
}

/**
 * Print a centered transition message with a drop shadow.
 */
function DrawTransitionMessage(Canvas Canvas,string Message)
{
	local String MapName;

	FontScale = float(Canvas.SizeY) / float(1080);

	MapName = KFGameEngine(Class'Engine'.static.GetEngine()).TransitionDescription;
	DrawMapInfo(Canvas, MapName);
	if(!class'WorldInfo'.static.IsConsoleBuild())
	{
		if(bDownloadingContent)
		{
			DrawDownloadingString(Canvas);
		}
		if(MapName != "" && MapName != "KFMainMenu")
		{
			DrawCancelString(Canvas);
		}
	}
	
	Class'Engine'.static.AddOverlay(MessageFont, message, 0.15, 0.85, FontScale, FontScale, true);
	
`if(`isdefined(ShippingPC) || `isdefined(FINAL_RELEASE))
	return;
`endif

	Super.DrawTransitionMessage(Canvas, Message);
}

function DrawDownloadingString(Canvas Canvas)
{
	local string DownloadingString;
	
	DownloadingString = class'KFGFxWidget_BaseParty'.default.DownLoadingString @CurrentDownloadName @"-" @CurrentDownloadProgress$"%";	

	Class'Engine'.static.AddOverlay(MessageFont, DownloadingString, 0.12, 0.70, FontScale, FontScale, true);	
}

function DrawCancelString(Canvas Canvas)
{
	local string CancelString;

	CancelString = "F10 -"@class'KFCommon_LocalizedStrings'.default.CancelConnectionString;	
	Class'Engine'.static.AddOverlay(MessageFont, CancelString, 0.12, 0.75, FontScale, FontScale, true);
}

function DrawMapInfo(Canvas Canvas, String MapName)
{
	local KFMapSummary MapData;
	local String GameModeString;
	local array<string> GamemModeStringArray;

	ParseStringIntoArray(KFGameEngine(Class'Engine'.static.GetEngine()).TransitionGameType, GamemModeStringArray, ".", true);

	if( GamemModeStringArray.Length > 0 )
	{
		if(Caps(GamemModeStringArray[0]) == Caps("KFGameContent"))
		{
			GameModeString = Localize(GamemModeStringArray[1], "GameName", "KFGameContent" );
		}
		else if( GamemModeStringArray.Length > 1 )
		{
			GameModeString = GamemModeStringArray[1];
		}
	}

	MapData = class'KFUIDataStore_GameResource'.static.GetMapSummaryFromMapName(MapName);
	if ( MapData == none )
	{
		MapData = class'KFUIDataStore_GameResource'.static.GetMapSummaryFromMapName("KF-Default");
    }
    if(MapData.DisplayName != "")
    {
    	Class'Engine'.static.AddOverlay(MessageFont, Class'KFCommon_LocalizedStrings'.default.LoadingString, 0.12, 0.12, FontScale, FontScale, false);
		Class'Engine'.static.AddOverlay(MessageFont, MapData.DisplayName@"-"@GetAssociationIdentifier(MapData), 0.135, 0.15, FontScale, FontScale, false);
		if( GameModeString != "" )
		{
			Class'Engine'.static.AddOverlay(MessageFont, GameModeString, 0.135, 0.18, FontScale, FontScale, false);
		}
    }
}

function string GetAssociationIdentifier(KFMapSummary MapData)
{
	switch (MapData.MapAssociation)
	{
				
		case EAI_OfficialCustom:
			return OfficialCommunityString;
		case EAI_TripwireOfficial:
			return TripWireOfficialString;
		case EAI_Custom:
			return CommunityCustomString;
		default:
			return CommunityCustomString;
	}
}

DefaultProperties
{
	TripWireOfficialMaps=("KF-BioticsLab","KF-BlackForest","KF-BurningParis","KF-Catacombs","KF-EvacuationPoint","KF-Farmhouse","KF-VolterManor","KF-Outpost","KF-Prison","KF-ZedLanding","KF-TheDescent","KF-Nuked","KF-TragicKingdom", "KF-Nightmare","KF-KrampusLair","KF-DieSector")
	CommunityOfficialMaps=("KF-ContainmentStation","KF-HostileGrounds","KF-InfernalRealm","KF-PowerCore_Holdout","KF-LockDown")
	//defaults
	MessageFont=Font'UI_Canvas_Fonts.Font_Main'
	FontScale=1.0f
	BackgroundColor=(R=1.0,G=1.0,B=1.0,A=1.0)
}