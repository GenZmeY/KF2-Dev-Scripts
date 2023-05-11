//=============================================================================
// KFGamepadLayoutManager
//=============================================================================
// This class is responsible for setting up the key binding/input system given
// a requested layout scheme for a gamepad layout (Default, South Paw, etc).
// A user interfaces with this class via GetGamepadLayout() to receive
// an GamepadLayout struct containing button mappings.
//=============================================================================
// Killing Floor 2
// Created by Adam Pawlowski 2/25/16
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================

class KFGamepadLayoutManager extends Object
	abstract
	native;

const  NUM_OVERRIDDEN_BUTTONS = 12; // The layouts don't change all of the default controller buttons. No need to store unchanged buttons.
const  NUM_LAYOUTS = 4;
const  NUM_CONTROLLER_BINDINGS = 20;

enum EGamepadLayoutType { LAYOUT_Default, LAYOUT_JUMPER, LAYOUT_QUICKDRAW, LAYOUT_SOUTHPAW};

struct native GamepadButtonCommand 
{
    var name    Name;	 // The button name.
	var string  Command; // The command string.
};

struct native GamepadLayout
{
	var string DisplayName; // The name that the player sees.
	var GamepadButtonCommand ButtonCommands[NUM_OVERRIDDEN_BUTTONS];
	
};

var private GamepadLayout GamepadLayouts[NUM_LAYOUTS];
var private name GamepadButtonNames[NUM_CONTROLLER_BINDINGS]; // The bind names of all the controller bindings.


static native function GetGamepadLayout(EGamepadLayoutType GamepadLayoutType, out GamepadLayout Layout);
static native function GetGamepadButtonNames(out name Names[NUM_CONTROLLER_BINDINGS]);
static native function string GetLayoutName(int index);

static native function int GetNumLayouts();

defaultproperties
{
	GamepadButtonNames(0)="XboxTypeS_A"
	GamepadButtonNames(1)="XboxTypeS_B"
	GamepadButtonNames(2)="XboxTypeS_Y"
	GamepadButtonNames(3)="XboxTypeS_X"
	GamepadButtonNames(4)="XboxTypeS_LeftX"
	GamepadButtonNames(5)="XboxTypeS_LeftY"
	GamepadButtonNames(6)="XboxTypeS_LeftThumbStick"
	GamepadButtonNames(7)="XboxTypeS_RightX"
	GamepadButtonNames(8)="XboxTypeS_RightY"
	GamepadButtonNames(9)="XboxTypeS_RightThumbStick"
	GamepadButtonNames(10)="XboxTypeS_LeftShoulder"
	GamepadButtonNames(11)="XboxTypeS_RightShoulder"
	GamepadButtonNames(12)="XboxTypeS_LeftTrigger"
	GamepadButtonNames(13)="XboxTypeS_RightTrigger"
	GamepadButtonNames(14)="XboxTypeS_DPad_Left"
	GamepadButtonNames(15)="XboxTypeS_DPad_Right"
	GamepadButtonNames(16)="XboxTypeS_DPad_Down"
	GamepadButtonNames(17)="XboxTypeS_DPad_Up"
	GamepadButtonNames(18)="XboxTypeS_Back"
	GamepadButtonNames(19)="XboxTypeS_Start"


	// DEFAULT LAYOUT!!!, This MUST match the KFInput.ini defaults! 
	GamepadLayouts(LAYOUT_Default)={(
						ButtonCommands[0]=(Name="XboxTypeS_A",Command="GBA_Jump | OnVoteYesPressed | OnRelease OnVoteYesRelease"),
						ButtonCommands[1]=(Name="XboxTypeS_Y",Command="GBA_WeaponSelect_Gamepad"),
						ButtonCommands[2]=(Name="XboxTypeS_LeftX",Command="GBA_StrafeLeft_Gamepad"),
						ButtonCommands[3]=(Name="XboxTypeS_LeftY",Command="GBA_MoveForward_Gamepad"),
						ButtonCommands[4]=(Name="XboxTypeS_LeftThumbStick",Command="GBA_SprintAndCrouch"),
						ButtonCommands[5]=(Name="XboxTypeS_RightX",Command="GBA_TurnLeft_Gamepad"),
						ButtonCommands[6]=(Name="XboxTypeS_RightY",Command="GBA_Look_Gamepad"),
						ButtonCommands[7]=(Name="XboxTypeS_RightThumbStick",Command="GBA_TertiaryFire"),
						ButtonCommands[8]=(Name="XboxTypeS_LeftShoulder",Command="GBA_Grenade | GBA_ToggleFriendlyUIFromHUD"),
						ButtonCommands[9]=(Name="XboxTypeS_RightShoulder",Command="GBA_AltFire_Gamepad"),
						ButtonCommands[10]=(Name="XboxTypeS_LeftTrigger",Command="GBA_IronsightsHold"),
						ButtonCommands[11]=(Name="XboxTypeS_RightTrigger",Command="GBA_Fire")
					)}

	// Jumper
	GamepadLayouts(LAYOUT_JUMPER)={(
						ButtonCommands[0]=(Name="XboxTypeS_A",Command="GBA_TertiaryFire | OnVoteYesPressed | OnRelease OnVoteYesRelease"),
						ButtonCommands[1]=(Name="XboxTypeS_Y",Command="GBA_WeaponSelect_Gamepad"),
						ButtonCommands[2]=(Name="XboxTypeS_LeftX",Command="GBA_StrafeLeft_Gamepad"),
						ButtonCommands[3]=(Name="XboxTypeS_LeftY",Command="GBA_MoveForward_Gamepad"),
						ButtonCommands[4]=(Name="XboxTypeS_LeftThumbStick",Command="GBA_SprintAndCrouch"),
						ButtonCommands[5]=(Name="XboxTypeS_RightX",Command="GBA_TurnLeft_Gamepad"),
						ButtonCommands[6]=(Name="XboxTypeS_RightY",Command="GBA_Look_Gamepad"),
						ButtonCommands[7]=(Name="XboxTypeS_RightThumbStick",Command="GBA_Grenade"),
						ButtonCommands[8]=(Name="XboxTypeS_LeftShoulder",Command="GBA_Jump | GBA_ToggleFriendlyUIFromHUD"),
						ButtonCommands[9]=(Name="XboxTypeS_RightShoulder",Command="GBA_AltFire_Gamepad"),
						ButtonCommands[10]=(Name="XboxTypeS_LeftTrigger",Command="GBA_IronsightsHold"),
						ButtonCommands[11]=(Name="XboxTypeS_RightTrigger",Command="GBA_Fire"),
					)}


	// Quick Draw
	GamepadLayouts(LAYOUT_QUICKDRAW)={(
						ButtonCommands[0]=(Name="XboxTypeS_A",Command="GBA_Jump | OnVoteYesPressed | OnRelease OnVoteYesRelease"),
						ButtonCommands[1]=(Name="XboxTypeS_Y",Command="GBA_TertiaryFire"),
						ButtonCommands[2]=(Name="XboxTypeS_LeftX",Command="GBA_StrafeLeft_Gamepad"),
						ButtonCommands[3]=(Name="XboxTypeS_LeftY",Command="GBA_MoveForward_Gamepad"),
						ButtonCommands[4]=(Name="XboxTypeS_LeftThumbStick",Command="GBA_SprintAndCrouch"),
						ButtonCommands[5]=(Name="XboxTypeS_RightX",Command="GBA_TurnLeft_Gamepad"),
						ButtonCommands[6]=(Name="XboxTypeS_RightY",Command="GBA_Look_Gamepad"),
						ButtonCommands[7]=(Name="XboxTypeS_RightThumbStick",Command="GBA_Grenade"),
						ButtonCommands[8]=(Name="XboxTypeS_LeftShoulder",Command="GBA_WeaponSelect_Gamepad | GBA_ToggleFriendlyUIFromHUD"),
						ButtonCommands[9]=(Name="XboxTypeS_RightShoulder",Command="GBA_AltFire_Gamepad"),
						ButtonCommands[10]=(Name="XboxTypeS_LeftTrigger",Command="GBA_IronsightsHold"),
						ButtonCommands[11]=(Name="XboxTypeS_RightTrigger",Command="GBA_Fire"),
					)}

	// Southpaw
	GamepadLayouts(LAYOUT_SOUTHPAW)={(
						ButtonCommands[0]=(Name="XboxTypeS_A",Command="GBA_Jump | OnVoteYesPressed | OnRelease OnVoteYesRelease"),
						ButtonCommands[1]=(Name="XboxTypeS_Y",Command="GBA_WeaponSelect_Gamepad"),
						ButtonCommands[2]=(Name="XboxTypeS_LeftX",Command="GBA_TurnLeft_Gamepad"),
						ButtonCommands[3]=(Name="XboxTypeS_LeftY",Command="GBA_Look_GamepadSouthpaw"),
						ButtonCommands[4]=(Name="XboxTypeS_LeftThumbStick",Command="GBA_TertiaryFire"),
						ButtonCommands[5]=(Name="XboxTypeS_RightX",Command="GBA_StrafeLeft_Gamepad"),
						ButtonCommands[6]=(Name="XboxTypeS_RightY",Command="GBA_MoveForward_GamepadSouthpaw"),
						ButtonCommands[7]=(Name="XboxTypeS_RightThumbStick",Command="GBA_SprintAndCrouch"),
						ButtonCommands[8]=(Name="XboxTypeS_LeftShoulder",Command="GBA_AltFire_Gamepad | GBA_ToggleFriendlyUIFromHUD"),
						ButtonCommands[9]=(Name="XboxTypeS_RightShoulder",Command="GBA_Grenade"),
						ButtonCommands[10]=(Name="XboxTypeS_LeftTrigger",Command="GBA_Fire"),
						ButtonCommands[11]=(Name="XboxTypeS_RightTrigger",Command="GBA_IronsightsHold"),
					)}
}