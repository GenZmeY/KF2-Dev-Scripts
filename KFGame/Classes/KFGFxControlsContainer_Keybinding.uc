//=============================================================================
// KFGFxOptionsContainer_Keybinding
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Greg Felber -  9/10/2014
//=============================================================================

class KFGFxControlsContainer_Keybinding extends KFGFxObject_Container
	config(UI);


var KFGfxMoviePlayer_Manager Manager;

/** Populated from DefaultUI.ini */
var config array<string> MovementBindList;
var config array<string> CombatBindList;
var config array<string> WeaponSelectBindList;
var config array<string> InteractionBindList;
var config array<string> VoiceCommBindList;
var config array<string> OtherBindList;

var KeyBind PendingKeyBind;
var KeyBind OldKeyBind;

/** The name of the command we are trying to bind */
var string BindCommand;

var byte CurrentlySelectedSection;

/** These are set true if ctrl, shift, or alt are being held down */
var bool bModCtrl;
var bool bModShift;
var bool bModAlt;

var bool bWaitForInput;

var const string SectionName;
const MAX_SECTIONS = 6;
var byte TotalBindSections;

var localized array<string> SectionHeaders;
var localized string ResetString, ApplyString, KeyAlreadyBoundString, PressKeyString;
var localized string WarningString, RebindString, ClearedString, CancelString, AcceptString, IgnoredKeyString;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
	local GFxObject LocalizedObject;

	super.Initialize( NewParentMenu );

	Manager = NewParentMenu.Manager;

	LocalizedObject = CreateObject( "Object" );
	LocalizedObject.SetString("resetLabel", ResetString);
	LocalizedObject.SetString("applyLabel", ApplyString);
	SetObject("localizedText", LocalizedObject);

	LocalizedObject = CreateObject( "Object" );
	LocalizedObject.SetString("warningLabel", WarningString);
	LocalizedObject.SetString("rebindLabel", RebindString);
	LocalizedObject.SetString("clearedLabel", ClearedString);
	LocalizedObject.SetString("cancelLabel", CancelString);
	LocalizedObject.SetString("acceptLabel", AcceptString);
	SetObject("localizedPopup", LocalizedObject);

 	InitalizeCommandList(MovementBindList);
 	InitalizeCommandList(InteractionBindList);
 	InitalizeCommandList(CombatBindList);
 	InitalizeCommandList(WeaponSelectBindList);
 	InitalizeCommandList(VoiceCommBindList);
 	InitalizeCommandList(OtherBindList);

 	UpdateAllBindings();
}

function InitalizeCommandList( out array<string> BindList )
{
	local byte i;
	local GFxObject CommandSlot;
	local GFxObject DataProvider;

	if( TotalBindSections < MAX_SECTIONS )
	{
		DataProvider = CreateArray();
		DataProvider.SetInt("sectionIndex", TotalBindSections);
		DataProvider.SetString("bindingHeader", SectionHeaders[TotalBindSections]); 
		DataProvider.SetString("pressKeyString", PressKeyString);
		for (i = 0; i < BindList.Length; i++)
		{
			CommandSlot = CreateObject( "Object" );
			CommandSlot.SetString("label",  Localize(SectionName, BindList[i], "KFGame"));

			DataProvider.SetElementObject(i, CommandSlot);			
		}

		SetObject("commandList", DataProvider);
		TotalBindSections++;
	}
}

function UpdateAllBindings()
{
	UpdateBindList( MovementBindList, 0 );
 	UpdateBindList( InteractionBindList, 1 );
 	UpdateBindList( CombatBindList, 2 );
 	UpdateBindList( WeaponSelectBindList, 3 );
 	UpdateBindList( VoiceCommBindList, 4 );
	UpdateBindList( OtherBindList, 5);

	Manager.UpdateDynamicIgnoreKeys();
}

/************************************************************************
* Binding
*************************************************************************/

/** Populates the binding list */
function UpdateBindList( out array<string> BindList, int SectionIndex )
{
	local byte i;
	local GFxObject DataProvider;
	local GFxObject BindSlot;
	local KeyBind MyKeyBind;
	local KFPlayerInput KFInput;

	if (GetPC() == None || KFPlayerInput(GetPC().PlayerInput) == none)
	{
		return;
	}

	DataProvider = CreateArray();
	KFInput = KFPlayerInput(GetPC().PlayerInput);
	for (i = 0; i < BindList.Length; i++)
	{
		BindSlot = CreateObject("Object");
		KFInput.GetKeyBindFromCommand(MyKeyBind, BindList[i], false);
		BindSlot.SetString("command", BindList[i]);
		if (MyKeyBind.Name != 'None')
		{
			BindSlot.SetString("label", KFInput.GetBindDisplayName(MyKeyBind));	
		}
		else
		{
 			BindSlot.SetString("label", "");
		}
		DataProvider.SetElementObject(i, BindSlot);
	}

	SetSectionBindings( SectionIndex, DataProvider );
}

function SetSectionBindings( int i, GFxObject bindData )
{
	ActionscriptVoid("setSectionBindings");
}

/** Wait for player input to modify the current bind command */
function ChangeBind( string ChangedCommand, byte SelectedSection )
{
	`Log("Change BIND Command " $ChangedCommand);
	BindCommand = ChangedCommand;
	CurrentlySelectedSection = SelectedSection;
	bWaitForInput = true;
}

/** Receives the key we want to bind for a particular command and adds any modifiers (ctrl, shift ) */
function BindKey( name KeyPressed, EInputEvent EventType)
{
	local KeyBind NewKeyBind;

	if ( !bWaitForInput )
	{
	 	return;
	}

	NewKeyBind.Name = KeyPressed;

    if (EventType == EInputEvent.IE_Pressed)
	{
		// If Ctrl, shift, or alt are pressed wait for a second input to modify the binding
		UpdateModKeys(KeyPressed, EventType);
	}
	// If we release a mod key before pressing anything else
	if (EventType == EInputEvent.IE_Released)
	{
		// If Ctrl, shift, or alt are pressed wait for a second input to modify the binding
		UpdateModKeys(KeyPressed, EventType);

		NewKeyBind.Control = bModCtrl;
		NewKeyBind.Shift = bModShift;
		NewKeyBind.Alt = bModAlt;
 		
		bWaitForInput = false;
		
   		SetKeyBind( NewKeyBind );
   		ResetModKeys();
	}
	//reset ignores
	Manager.ClearFocusIgnoreKeys();
}

function UpdateModKeys(name KeyPressed, EInputEvent EventType)
{
	switch (KeyPressed)
	{
		case 'LeftControl':
			ResetModKeys();
			bModCtrl = EventType == EInputEvent.IE_Pressed;
			break;
	
		case 'LeftShift':
			ResetModKeys();
			bModShift = EventType == EInputEvent.IE_Pressed;
			break;

		case 'LeftAlt':
			ResetModKeys();
			bModAlt = EventType == EInputEvent.IE_Pressed;
			break;			
	}
}

function ResetModKeys()
{
	bModCtrl = false;
	bModShift = false;
	bModAlt = false;
}


function SetKeyBind(KeyBind NewKeyBind)
{
	local KFPlayerInput KFInput;
	local string OldKeyCommand;

	if ( GetPC() == None || KFPlayerInput(GetPC().PlayerInput) == none )
	{
		return;
	}

	//The escape key does not have a gba.  We want it to be a constant command.  Esc cancels bind.
	if(NewKeyBind.name == 'Escape')
	{
		UpdateAllBindings();
		return;
	}

	//prevent loss of mouse click or controller selection 
	if( (NewKeyBind.name == 'XboxTypeS_A' || NewKeyBind.name == 'LeftMouseButton') && Manager.IsFocusIgnoreKey(BindCommand))
	{
		//reject and show pop up
		Manager.DelayedOpenPopup(ENotification, EDPPID_Misc, default.WarningString, NewKeyBind.name @default.IgnoredKeyString, class'KFCommon_LocalizedStrings'.default.OKString);	
		UpdateAllBindings();
		return;
	}

	KFInput = KFPlayerInput( GetPC().PlayerInput );
	OldKeyCommand = KFInput.GetGameBindableAction( NewKeyBind.Name );
	
	// If this key is already bound, create a popup to confirm we want to switch
	if ( NewKeyBind.Name != 'Delete' && OldKeyCommand != "" && OldKeyCommand != BindCommand )
	{
		PendingKeyBind = NewKeyBind;
		OldKeyBind.Command = OldKeyCommand;
		OldKeyBind.Name = 'Delete';
		SetConflictMessage( string(NewKeyBind.Name), OldKeyCommand, BindCommand, CurrentlySelectedSection );
	}
	else
	{
		`Log("BIND BindCommand " $BindCommand);

		KFInput.BindKey( NewKeyBind, BindCommand, false );
		UpdateAllBindings();
	}
}

function SetConflictMessage( String KeyString, String OldCommand, String NewCommand, byte SelectedSection )
{
	KeyString = Repl(KeyAlreadyBoundString, "%x%", KeyString, true);
 	OldCommand = Localize(SectionName, OldCommand, "KFGame");
 	NewCommand = Localize(SectionName, NewCommand, "KFGame");

	ActionscriptVoid("setConflictMessage");
}

function AcceptBind()
{
	KFPlayerInput( GetPC().PlayerInput ).BindKey( OldKeyBind, OldKeyBind.Command, false );
	KFPlayerInput( GetPC().PlayerInput ).BindKey( PendingKeyBind, BindCommand, false );
	UpdateAllBindings();
}

function ResetControls()
{
	if (GetPC() != None && GetPC().PlayerInput != None)
	{
		KFPlayerInput(GetPC().PlayerInput).ResetKeysToDefault();
		UpdateAllBindings();
	}
}

function ClearInputOnContainer()
{
	UpdateAllBindings();
	bWaitForInput = false;
}

DefaultProperties
{
	SectionName="LocalizedControls"
}