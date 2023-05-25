//=============================================================================
// KFGFxWidget_VoiceComms
//=============================================================================
// HUD Widget that displays options for voice communication
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 09/11/2014
//=============================================================================

class KFGFxWidget_VoiceComms extends GFxObject
dependson(KFLocalMessage_VoiceComms);


var private bool bPlayedVoiceComm;

var Vector RawJoyVector;
var PlayerController PC;

var array<string> IconPaths;
var bool bActive;

var const float MouseDampening;
var const float ControllerDampening;

var private int SavedSelectionIndex;
var private float DeselectTime;

function InitializeHUD()
{
	SetLocalizedText();
	PC = GetPC();
}

function SetLocalizedText()
{
	local GFxObject DataProvider, TempObj;
	local byte i;

	DataProvider = CreateArray();
	for (i = 0; i < class'KFLocalMessage_VoiceComms'.default.VoiceCommsOptionStrings.length; i++)
	{
		TempObj = CreateObject("Object");
		TempObj.SetString("text", class'KFLocalMessage_VoiceComms'.default.VoiceCommsOptionStrings[i]);
		TempObj.SetString("iconPath", "img://"$IconPaths[i]);

		DataProvider.SetElementObject(i,TempObj);
	}

	SetObject("textOptions", DataProvider);

	TempObj = CreateObject("Object");
	TempObj.SetString("text", class'KFLocalMessage_VoiceComms'.default.ToggleFriendlyHUDString);
	SetObject("toggleFriendlyText", TempObj);

	SetBool("toggleFriendlyVisibility", GetPC().WorldInfo.NetMode != NM_StandAlone);
}

function SaveVoiceCommSelection( int CommsIndex )
{
	if( CommsIndex >= 0 )
	{
		SavedSelectionIndex = CommsIndex;
	}
	else
	{
		DeselectTime = PC.WorldInfo.RealTimeSeconds;		
	}
}

function EnableComm()
{
	DeselectTime = 0.f;
	bPlayedVoiceComm = false;
	SavedSelectionIndex = -1;

	//Don't allow the user to open voice comms if they are dead. 
	if(!PC.IsDead() && PC.Pawn != none)
	{
		bActive = true;
		if(PC.IsTimerActive('HandleInputChange',self))
		{
			// Clear the timer and reset the ignore look input because it goes up incrementally.  HSL_BB
			PC.ClearTimer('HandleInputChange',self);
			PC.IgnoreLookInput( false );
		}
		//Disable player rotate and click
		PC.IgnoreLookInput( true );  // Calling this instead of SetCinematicMode so we can avoid the Performance issue associated with opening comms on Console.
		GetGameViewportClient().HandleInputAxis = OnAxisModified;
		SetBool("bUsingGamePad", PC.PlayerInput.bUsingGamepad);
		ActionScriptVoid("enableComm");
		UpdateEmoteState();

		// Need to keep our emote state constantly updated
		PC.SetTimer( 0.15f, true, nameOf(UpdateEmoteState), self );
	}
}

function DisableComm()
{
	if(bActive)
	{
		bActive = false;
		if ( !PC.PlayerInput.bUsingGamepad )
		{
			PC.IgnoreLookInput( false );  // Since we are no longer toggling CinematicMode return lookInput to normal.
		}
		else
		{
			// Adding 0.25 second delay when using controller so you aren't whipped into the direction of your comms.  HSL_BB
			PC.SetTimer(0.25f,false,'HandleInputChange',self);
		}
		GetGameViewportClient().HandleInputAxis = None;
		ActionScriptVoid("disableComm");

		// Play the last selection if it was made just before the widget was closed. This makes the
		// comms menu still work properly if the selection stick/mouse was released/moved just before
		// the menu was closed. -MattF
		if( !bPlayedVoiceComm && SavedSelectionIndex >= 0 && DeselectTime > 0.f && `RealTimeSinceEx(PC, DeselectTime) <= 0.15f )
		{
			SayVoiceCommms( SavedSelectionIndex );
		}

		PC.ClearTimer( nameOf(UpdateEmoteState), self );
	}
}

function UpdateEmoteState()
{
	local bool bEnabled;
	local KFPawn KFP;

	bEnabled = false;
	if( PC != none && PC.Pawn != none && PC.Pawn.IsAliveAndWell() )
	{
		KFP = KFPawn( PC.Pawn );
		if( KFP != none && class'KFEmoteList'.static.GetEquippedEmoteId() != INDEX_NONE && KFP.CanDoSpecialMove(SM_Emote) )
		{
			bEnabled = true;
		}
	}

	UpdateGFxEmoteState( bEnabled );
}

function UpdateGFxEmoteState( bool bEnabled )
{
	ActionScriptVoid( "setEmoteEnabled" );
}

function HandleInputChange()
{
	PC.IgnoreLookInput( false );  // Since we are no longer toggling CinematicMode return lookInput to normal.
}

function SayVoiceCommms(int CommsIndex)
{    
    local KFPlayerController KFPC;

    KFPC = KFPlayerController(PC);
    if( KFPC == none )
    {
    	return;
    }

    if( CommsIndex == VCT_EMOTE )
    {
        //do emote
        KFPC.DoEmote();
        return;
    }
    
    KFPlayerController(PC).ServerPlayVoiceCommsDialog(CommsIndex);
    bPlayedVoiceComm = true;
}

//==============================================================
//@name Mouse/Controller Support
//==============================================================

function bool OnAxisModified( int ControllerId, name Key, float Delta, float DeltaTime, bool bGamepad )
{
	local Vector MouseVector;
	if ( PC.PlayerInput.bUsingGamepad )
	{
	 	UpdateJoystickDirection( Key, Delta );
		// Pass the raw values and let scaleform determine the position of the selector. -HSL_BB
		UpdateUICursorPosition(RawJoyVector.X, RawJoyVector.Y, false);
	}
	else
	{
		if(Key == 'MouseX')
		{
			MouseVector.X = Delta;
		}
		else if(Key == 'MouseY')
		{
			MouseVector.Y = Delta;
		}
		
		UpdateUICursorPosition( MouseVector.X * MouseDampening, -MouseVector.Y * MouseDampening,true);
	}
	return false;
}

function UpdateJoystickDirection( name Key, float Delta )
{
	if ( Key == 'XboxTypeS_RightX')
	{
    	RawJoyVector.X = Delta;
	}
	if ( Key == 'XboxTypeS_RightY')
	{
		RawJoyVector.Y = Delta;
	}
}

function UpdateUICursorPosition(float newX, float newY, bool bMouseInput)
{
	ActionScriptVoid("setNormalizedMousePosition");
}

function SetToggleFriendlyButtonActive(bool IsActive)
{
	ActionScriptVoid("toggleFriendlyActive");
}

DefaultProperties
{
	ControllerDampening=2.5f
	MouseDampening=0.2f
	//defaults
	bActive=false
	IconPaths[VCT_REQUEST_HEALING]="UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Heal"
	IconPaths[VCT_REQUEST_DOSH]="UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Dosh"
	IconPaths[VCT_REQUEST_HELP]="UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Help"
	IconPaths[VCT_TAUNT_ZEDS]="UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Taunt"
	IconPaths[VCT_FOLLOW_ME]="UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Follow"
	IconPaths[VCT_GET_TO_THE_TRADER]="UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Trader"
	IconPaths[VCT_AFFIRMATIVE]="UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Affirmative"
	IconPaths[VCT_NEGATIVE]="UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Negative"
	IconPaths[VCT_EMOTE]="UI_VoiceComms_TEX.UI_VoiceCommand_Icon_Emote"
	IconPaths[VCT_THANK_YOU]="UI_VoiceComms_TEX.UI_VoiceCommand_Icon_ThankYou"
}