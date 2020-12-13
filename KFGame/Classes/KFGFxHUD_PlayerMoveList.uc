class KFGFxHUD_PlayerMoveList extends GFxObject;

/** cached info for tick/update */
struct HUDMoveInfo
{
	var GFxObject GfxObj;

	var int 	AtkIndex;
	var float 	Cooldown;
	var int 	Charges;
	var int 	ButtonPriority;

	StructDefaultProperties
	{
		Cooldown=-1
		Charges=-1
		ButtonPriority=-1
	}
};

/** cached GfxObjects for perf */
var protected array<HUDMoveInfo> CurrentMoves;
/** Cached object array */
var protected GFxObject MoveListObjectArray;

var Texture2D ZedIconTexture;

var protected KFPawn_Monster MyKFPM;
var protected KFPlayerInput MyInput;

/*********************************************************************************************
 * @name	Controls
 ********************************************************************************************* */

/** information to look up Game Bind Actions by move */
var array<string> PlayerMoveKeyBinds;
/** Gamepad scheme (aligned to EPlayerZedGamepadMove) */
var array<string> GamepadMoveKeyBinds;

/** Listed of key names in order they should appear on HUD */
var array<name> GamepadKeyPriority;

/** Whether we're currently displaying gamepad controls */
var bool bUsingGamepadControls;

function InitializeHUD()
{
	MyKFPM = KFPawn_Monster(GetPC().Pawn);    
    MyInput = KFPlayerInput(GetPC().PlayerInput);

   // MoveListObjectArray = CreateArray();
    InitializeMoveList();
}

function ChangeOwner(KFPawn_Monster P)
{
	if ( P != None && P != MyKFPM )
	{
		MyKFPM = P;
		InitializeMoveList();
	}
}

function TickHud(float DeltaTime)
{
	if ( MyKFPM == none )
	{
		return;
	}

	// If user changed input devices re-initialize
	if ( MyInput != None && bUsingGamepadControls != MyInput.bUsingGamepad )
	{
		InitializeMoveList();
	}
	// otherwise, do a normal/fast update
	else
	{
		
		UpdateMoveList();
	}
}

/** Called once when a new pawn is possessed */
function InitializeMoveList()
{
	local int i, j;
	local GFxObject MoveObject;
	local Array<SpecialMoveCooldownInfo> AttackArray;
	local KeyBind MyKeyBind;
	local int LookupIndex;
	local int ButtonPriority;
	local HUDMoveInfo SavedMoveInfo;
    local string BindName;

	// No monster pawn, no moves
	if( MyKFPM == none )
	{
		return;
	}

	CurrentMoves.Remove(0, CurrentMoves.Length);
	AttackArray = MyKFPM.GetSpecialMoveCooldowns();
	
	//@TODO Find a better way to empty out the MoveListObjectArray (the method call here insures there are no phantom slots)
	MoveListObjectArray = CreateArray();
	
	for (i = 0; i < AttackArray.length; i++)
	{
		if( AttackArray[i].SMHandle != SM_None && AttackArray[i].bShowOnHud )
		{
			MoveObject = CreateObject("Object");

			//set icon
			if(AttackArray[i].SpecialMoveIcon != none)
			{
				MoveObject.SetString("image", "img://"$PathName(AttackArray[i].SpecialMoveIcon));
			}
			else
			{
				MoveObject.SetString("image", "img://"$PathName(ZedIconTexture));
			}
			
			//set key
			ButtonPriority = -1;
			bUsingGamepadControls = MyInput.bUsingGamepad;
			if ( bUsingGamepadControls )
			{
				// Find special move
				LookupIndex = MyKFPM.MoveListGamepadScheme.Find(AttackArray[i].SMHandle);
				if ( LookupIndex != INDEX_NONE )
				{
					MyInput.GetKeyBindFromCommand(MyKeyBind, GamepadMoveKeyBinds[LookupIndex], false);
					MoveObject.SetString("buttonString", MyInput.GetBindDisplayName(MyKeyBind) );
					ButtonPriority = GamepadKeyPriority.Find(MyKeyBind.Name);
				}
			}
			else
			{
				LookupIndex = AttackArray[i].SMHandle - SM_PlayerZedMove_LMB;
				if(LookupIndex >= 0 && LookupIndex < PlayerMoveKeyBinds.Length)
				{
					MyInput.GetKeyBindFromCommand(MyKeyBind, PlayerMoveKeyBinds[LookupIndex], false);
                    BindName = MyInput.GetBindDisplayName(MyKeyBind);
                    if (BindName ~= "None")
                    {
                        MyInput.GetKeyBindFromCommand(MyKeyBind, GetAlternateBindName(PlayerMoveKeyBinds[LookupIndex]), false);
                        BindName = MyInput.GetBindDisplayName(MyKeyBind);
                    }
					MoveObject.SetString("buttonString", BindName );
				}
			}
							
			if(AttackArray[i].NameLocalizationKey != "")
			{
				MoveObject.SetString("moveName", Localize("ZedMoves", AttackArray[i].NameLocalizationKey, "KFGame"));		
			}

			// clear charges in case index changed (e.g. controller/keyboard sort)
			if ( AttackArray[i].Charges == -1 )
			{
				MoveObject.SetString("count", "" );
			}

			// cache for UpdateMoveList
			SavedMoveInfo.GfxObj = MoveObject;
			SavedMoveInfo.AtkIndex = i;
			SavedMoveInfo.ButtonPriority = ButtonPriority;

			// insert into sorted list
			for (j = 0; j < CurrentMoves.length; j++)
			{
				if ( ButtonPriority < CurrentMoves[j].ButtonPriority )
				{
					CurrentMoves.InsertItem(j, SavedMoveInfo);
					break;
				}
			}

			// otherwise add to end
			if ( j == CurrentMoves.Length )
			{
				CurrentMoves.AddItem(SavedMoveInfo);
			}
		}
	}

	// finally (after sorting) assign the ObjectArray
	BuildObjectArray();
}

function string GetAlternateBindName(string OriginalName)
{
    if (OriginalName ~= "GBA_IronsightsToggle")
    {
        return "GBA_IronsightsHold";
    }
    else if (OriginalName ~= "GBA_SwitchFireMode")
    {
        return "GBA_AltFire";
    }
    else if (OriginalName ~= "GBA_QuickHeal")
    {
        return "GBA_Reload_GamePad";
    }

    return OriginalName;
}

/** Called each tick to update modified values */
function UpdateMoveList()
{
	local int i;
	local int Charges;
	local float Cooldown;
	local SpecialMoveCooldownInfo AttackInfo;
	local bool bUpdated;

	for (i = 0; i < CurrentMoves.length; i++)
	{
		AttackInfo = MyKFPM.SpecialMoveCooldowns[CurrentMoves[i].AtkIndex];

		Cooldown = MyKFPM.GetSpecialMoveCooldownPercent(AttackInfo);
		if ( Cooldown != CurrentMoves[i].Cooldown )
		{
			CurrentMoves[i].GfxObj.SetFloat("progressPercent", Cooldown);
			CurrentMoves[i].Cooldown = Cooldown;
			bUpdated = true;
		}

		Charges = AttackInfo.Charges;
		if( Charges != -1 && Charges != CurrentMoves[i].Charges )
		{
			CurrentMoves[i].GfxObj.SetString("count", string(Charges) );
			CurrentMoves[i].Charges = Charges;
			bUpdated = true;
		}
	}

	if ( bUpdated )
	{
		SetObject("Data", MoveListObjectArray);
	}
}

/** Rebuild the ObjectArray */
function BuildObjectArray()
{
	local int i;

	for (i = 0; i < CurrentMoves.length; i++)
	{
		MoveListObjectArray.SetElementObject(i, CurrentMoves[i].GfxObj);
	}

	SetObject("Data", MoveListObjectArray);
}

function ClearMoveList()
{
	local int i; 

	MyKFPM = None;
	CurrentMoves.Remove(0, CurrentMoves.Length);

	for (i = 0; i < 6; i++)
	{
		MoveListObjectArray.SetElementObject(i, None);	
	}
	
	SetObject("Data", MoveListObjectArray);
}

DefaultProperties
{
	// PC Bindable Commands (aligned by special move #)
	PlayerMoveKeyBinds.Add("GBA_Fire") 	// SM_PlayerZedMove_LMB
	PlayerMoveKeyBinds.Add("GBA_IronsightsToggle")
	PlayerMoveKeyBinds.Add("GBA_TertiaryFire")
	PlayerMoveKeyBinds.Add("GBA_SwitchFireMode")
	PlayerMoveKeyBinds.Add("GBA_QuickHeal")
	PlayerMoveKeyBinds.Add("GBA_Grenade")

	// Gamepad Bindable Commands (aligned by EPlayerZedGamepadMove/FireMode)
	GamepadMoveKeyBinds(ZGM_Attack_R2)="GBA_Fire"
	GamepadMoveKeyBinds(ZGM_Attack_L2)="GBA_IronsightsHold"
	GamepadMoveKeyBinds(ZGM_Special_R3)="GBA_TertiaryFire"
	GamepadMoveKeyBinds(ZGM_Melee_Square)="GBA_Reload_Gamepad"
	GamepadMoveKeyBinds(ZGM_Melee_Triangle)="GBA_WeaponSelect_Gamepad"
	GamepadMoveKeyBinds(ZGM_Block_R1)="GBA_AltFire_Gamepad"
	GamepadMoveKeyBinds(ZGM_Explosive_Ll)="GBA_Grenade"

    // Listed of key names in order they should appear on HUD 
	GamepadKeyPriority.Add(XboxTypeS_A)
	GamepadKeyPriority.Add(XboxTypeS_X)
	GamepadKeyPriority.Add(XboxTypeS_Y)
	GamepadKeyPriority.Add(XboxTypeS_B)
	GamepadKeyPriority.Add(XboxTypeS_LeftTrigger)
	GamepadKeyPriority.Add(XboxTypeS_RightTrigger)
	GamepadKeyPriority.Add(XboxTypeS_LeftShoulder)
	GamepadKeyPriority.Add(XboxTypeS_RightShoulder)
	GamepadKeyPriority.Add(XboxTypeS_RightThumbStick)
}