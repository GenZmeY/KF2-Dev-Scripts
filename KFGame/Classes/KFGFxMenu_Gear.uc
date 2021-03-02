//=============================================================================
// KFGFxMenu_Gear
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Greg Felber 7/23/2013
//=============================================================================

class KFGFxMenu_Gear extends KFGFxObject_Menu
	dependson(KFEmoteList)
	native(UI);

/** The customization option we want alter */
enum ECustomizationOption
{
	CO_Character,
	CO_Head,
	CO_Body,
	CO_Attachment
};

var KFGFxObject_Container CustomizationComponent;
var KFPlayerReplicationInfo MyKFPRI;

var const string HeadMeshKey; 
var const string HeadSkinKey; 
var const string HeadFunctionKey;
var const string BodyMeshKey;
var const string BodySkinKey;
var const string BodyFunctionKey;
var const string AttachmentKey; 
var const string AttachmentSkinKey; 
var const string AttachmentFunctionKey;
var const string KFCharacterInfoString; 
var const string KFEmoteInfoString;

var KFCharacterInfo_Human CurrentCharInfo;
var string CharInfoPath;

var localized string GearHeaderString;
var localized string CharacterString;
var localized string BioString;
var localized string HeadString;
var localized string BodyString;
var localized string AttachmentsString;
var localized string Attachment0String;
var localized string Attachment1String;
var localized string Attachment2String;
var localized string SkinsString;
var localized string BackString;
var localized string NoneString;

var KFGFxObject_TraderItems TraderItems;

var const int ControllerRotationRate;
var const float ControllerRotationThreshold;

var int CurrentPerkIndex;

var string ClearImagePath;

var array<Emote> EmoteList;

function InitializeMenu( KFGFxMoviePlayer_Manager InManager )
{
	super.InitializeMenu(InManager);

	CheckForCustomizationPawn( GetPC() );

	MyKFPRI = KFPlayerReplicationInfo( GetPC().PlayerReplicationInfo );
	LocalizeText();

	EmoteList = class'KFEmoteList'.static.GetEmoteArray();

	// Set the list of usable characters
	UpdateCharacterList();	
	UpdateGear();
	TraderItems = KFGameReplicationInfo( KFPlayerController(GetPC()).WorldInfo.GRI ).TraderItems;
}

function OnOpen()
{
	local PlayerController PC;

	PC = GetPC();
	if( PC == none )
	{
		return;
	}

	CheckForCustomizationPawn( PC );

	// @hack: moved from KFGfxMoviePlayer_Manager because this causes a crash while 
	// bink (e.g. KFII-25456) are playing.  Don't use HandleInputAxis with Bink! (for now) :) 
	GetGameViewportClient().HandleInputAxis = OnAxisModified;

	if ( class'WorldInfo'.static.IsMenuLevel() )
	{
		Manager.ManagerObject.SetBool("backgroundVisible", false);
	}
	else if ( PC.PlayerReplicationInfo.bReadyToPlay && PC.WorldInfo.GRI.bMatchHasBegun )
	{
		// Players cannot change characters if they are in a game
		SetBool("characterButtonEnabled", false);
		return;
	}
	UpdateCharacterList();
	UpdateGear();
}

/** The customization pawn won't exist if this menu was opened mid-match */
function CheckForCustomizationPawn( PlayerController PC )
{
	local KFPlayerController KFPC;

	if( PC.Pawn == none || (!PC.Pawn.IsAliveAndWell() && KFPawn_Customization(PC.Pawn) == none) )
	{
		KFPC = KFPlayerController( PC );
		if( KFPC != none )
		{
			KFPC.SpawnMidGameCustomizationPawn();
		}
	}	
}

//@HSL_MOD_BEGIN - amiller 4/1/2016 - Force game to resave game.ini when a gear piece changes
function SaveChanges()
{	
	local KFPlayerController KFPC; 

	KFPC = KFPlayerController(GetPC());
	KFPC.SaveConfig();

	Manager.CachedProfile.Save(LocalPlayer(KFPC.Player).ControllerId);
}
//@HSL_MOD_END

function LocalizeText()
{
	local GFxObject LocalizedObject;

	LocalizedObject = CreateObject("Object");

	LocalizedObject.SetString("header", GearHeaderString);
	LocalizedObject.SetString("listButton", BackString);
	LocalizedObject.SetString("bioStringText", BioString);
	LocalizedObject.SetString("charactersString", CharacterString);
	LocalizedObject.SetString("headsString", HeadString);
	LocalizedObject.SetString("emoteString", Class'KFLocalMessage_VoiceComms'.default.VoiceCommsOptionStrings[8]);
	LocalizedObject.SetString("bodiesString", BodyString);
	LocalizedObject.SetString("skinsString", SkinsString);
	LocalizedObject.SetString("attachmentsString", AttachmentsString);
	LocalizedObject.SetString("attachment0String", Attachment0String);
	LocalizedObject.SetString("attachment1String", Attachment1String);
	LocalizedObject.SetString("attachment2String", Attachment2String);

	SetObject("localizeText", LocalizedObject);
}

function UpdateEmoteList()
{
	local int ItemIndex, i;
	local GFxObject DataProvider, SlotObject;
	local string TexturePath;

	ItemIndex = 0;
	DataProvider = CreateArray();

	for (i = 0; i < EmoteList.length; i++)
	{
		if ( class'KFEmoteList'.static.GetUnlockedEmote(EmoteList[i].Id) != 'NONE')
		{
			SlotObject = CreateObject( "Object" );
			SlotObject.SetInt("ItemIndex", i);
			SlotObject.SetString("label", Localize(EmoteList[i].ItemName, "EmoteName", KFCharacterInfoString));
			TexturePath = "img://"$EmoteList[i].IconPath;
			SlotObject.SetBool("enabled", true);
			SlotObject.SetString("source", TexturePath);
			DataProvider.SetElementObject(ItemIndex, SlotObject);
			ItemIndex++;
		}
		else
		{
			//`log(MyKFPRI.EmoteList[i] @ "is not purchased.");
		}
	}
	
	SetObject("emoteArray", DataProvider);
}

function UpdateCharacterList()
{
	local int i, ItemIndex;
	local GFxObject DataProvider, SlotObject;
	local string TexturePath;

	ItemIndex = 0;
	DataProvider = CreateArray();
	for (i = 0; i < MyKFPRI.CharacterArchetypes.length; i++)
	{
		if (class'KFUnlockManager'.static.GetAvailable(MyKFPRI.CharacterArchetypes[i]))
		{
			SlotObject = CreateObject( "Object" );
			SlotObject.SetInt("ItemIndex", i);
			SlotObject.SetString("label", Localize(String(MyKFPRI.CharacterArchetypes[i].Name), "CharacterName", KFCharacterInfoString));
			TexturePath = "img://"$PathName(MyKFPRI.CharacterArchetypes[i].DefaultHeadPortrait);
			SlotObject.SetBool("enabled", true);
			SlotObject.SetString("source", TexturePath);
			DataProvider.SetElementObject(ItemIndex, SlotObject);
			ItemIndex++;
		}
		else
		{
			//`log(MyKFPRI.CharacterArchetypes[i] @ "is not purchased.");
		}
	}
	
	SetObject("characterArray", DataProvider);
}

function UpdateGear()
{
	CurrentCharInfo = MyKFPRI.CharacterArchetypes[MyKFPRI.RepCustomizationInfo.CharacterIndex];
	if(CurrentCharInfo != none)
	{
		CharInfoPath = String(CurrentCharInfo.Name);
		// Set the list of usable bodies for this character
		UpdateMeshList(BodyMeshKey, BodySkinKey, CurrentCharInfo.BodyVariants, "bodyArray");
		// Set the list of usable heads for this character
		UpdateMeshList(HeadMeshKey, HeadSkinKey, CurrentCharInfo.HeadVariants, "headsArray");
		// Set the list of usable attachments for this character
		UpdateAttachmentsList(CurrentCharInfo.CosmeticVariants);

		UpdateEmoteList();

		SetCurrentCharacterButtons();
	}
	else
	{
		//it was null so we need to reinit the menu in a short time
		GetPC().SetTimer(0.25, false, nameof(ReInitMenu), self);
	}
}

function ReInitMenu()
{
	InitializeMenu(Manager);
}

function UpdateMeshList(string OutfitKey, string SkinKey, array<OutfitVariants> Outfits, string DataArrayString)
{
	local int i, ItemIndex;
	local GFxObject DataProvider, SlotObject;
	local string TexturePath;
	local OutfitVariants Outfit;
	local SkinVariant FirstSkin;
	
	ItemIndex = 0;
	DataProvider = CreateArray();
	for (i = 0; i < Outfits.length; i++)
	{
		Outfit = Outfits[i];
		if (class'KFUnlockManager'.static.GetAvailableOutfit(Outfit))
		{
			SlotObject = CreateObject( "Object" );
			SlotObject.SetInt("ItemIndex", i);
			SlotObject.SetString("label", Localize(CharInfoPath, OutfitKey$i, KFCharacterInfoString));
			SlotObject.SetBool("enabled", true);
			FirstSkin = UpdateOutfitVariants( OutfitKey, SkinKey, Outfit.SkinVariations, i, SlotObject );
			TexturePath = "img://"$PathName(FirstSkin.UITexture);
			SlotObject.SetString("source", TexturePath);

			

			DataProvider.SetElementObject(ItemIndex, SlotObject);
			ItemIndex++;
		}
		else
		{
			//`log("Outfit" @ Outfit.MeshName @ "is not purchased.");
		}
	}
	
	SetObject(DataArrayString, DataProvider);
}

function UpdateAttachmentsList(array<AttachmentVariants> Attachments)
{
	local int i, ItemIndex;
	local GFxObject DataProvider, SlotObject;
	local string TexturePath;
	local AttachmentVariants Variant;
	local Pawn MyPawn;
	local SkinVariant FirstSkin;
	local string AttachmentName;
	ItemIndex = 0;
	DataProvider = CreateArray();
	MyPawn = GetPC().Pawn;

	// Insert blank object
	SlotObject = CreateObject( "Object" );
	SlotObject.SetString("label", NoneString);
	SlotObject.SetString("source", "img://"$ClearImagePath);
	SlotObject.SetInt("ItemIndex", INDEX_NONE);
	SlotObject.SetBool("enabled", true);
	DataProvider.SetElementObject(ItemIndex, SlotObject);
	ItemIndex++;

	for (i = 0; i < Attachments.length; i++)
	{
		Variant = Attachments[i];
		if ( CurrentCharInfo.IsAttachmentAvailable(Variant, MyPawn) )
		{
			SlotObject = CreateObject( "Object" );
			SlotObject.SetInt("ItemIndex", i);
			FirstSkin = UpdateCosmeticVariants( AttachmentKey, AttachmentSkinKey, Variant.AttachmentItem, i, SlotObject );
			AttachmentName = Localize(string(Variant.AttachmentItem.Name), AttachmentKey,  KFCharacterInfoString);
			//Asc return the Unicode value of the first character in the String
			//Use it to check if the first character is ?, which is the case when a localization isn't found
			SlotObject.SetString("label", AttachmentName);
			SlotObject.SetBool("enabled", true);
			TexturePath = "img://"$PathName(FirstSkin.UITexture);
			SlotObject.SetString("source", TexturePath);
			
			DataProvider.SetElementObject(ItemIndex, SlotObject);
			ItemIndex++;
		}
	}
	
	SetObject("attachmentsArray", DataProvider);
}

function SkinVariant UpdateCosmeticVariants(string OutfitKey, string KeyName, KFCharacterAttachment Attachment, int OutfitIndex, out GFxObject MeshObject)
{
	local int i, ItemIndex;
	local GFxObject DataProvider, SlotObject;
	local SkinVariant Skin;
	local SkinVariant FirstSkin;
	local string TexturePath;
	local bool bFoundFirst;
	local string SkinName;

	ItemIndex = 0;
	DataProvider = CreateArray();

	for (i = 0; i < Attachment.SkinVariations.length; i++)
	{
		Skin = Attachment.SkinVariations[i];
		if (class'KFUnlockManager'.static.GetAvailableSkin(Skin))
		{
			if(!bFoundFirst)
			{
				FirstSkin = Skin;
				bFoundFirst = true;
			}
			SlotObject = CreateObject( "Object" );
			SlotObject.SetInt("ItemIndex", i);
			SkinName = Localize(string(Attachment.Name), KeyName$i, KFCharacterInfoString);
			SlotObject.SetString("label", SkinName);
			TexturePath = "img://"$PathName(Skin.UITexture);
			SlotObject.SetBool("enabled", true);
			SlotObject.SetString("source", TexturePath);

			DataProvider.SetElementObject(ItemIndex, SlotObject);
			ItemIndex++;
		}
		else
		{
			//`log("Skin" @ Skin.UITexture.Name @ "is not purchased.");
		}
	}
	MeshObject.SetObject("skinInfo", DataProvider);

	return FirstSkin;
}

function SkinVariant UpdateOutfitVariants(string OutfitKey, string KeyName, out array<SkinVariant> SkinVariations, int OutfitIndex, out GFxObject MeshObject)
{
	local int i, ItemIndex;
	local GFxObject DataProvider, SlotObject;
	local SkinVariant Skin;
	local SkinVariant FirstSkin;
	local string SectionPath;
	local string TexturePath;
	local bool bFoundFirst;

	ItemIndex = 0;
	DataProvider = CreateArray();
	SectionPath = CharInfoPath$"."$OutfitKey$OutfitIndex;	

	for (i = 0; i < SkinVariations.length; i++)
	{
		Skin = SkinVariations[i];
		if (class'KFUnlockManager'.static.GetAvailableSkin(Skin))
		{
			if(!bFoundFirst)
			{
				FirstSkin = Skin;
				bFoundFirst = true;
			}
			SlotObject = CreateObject( "Object" );
			SlotObject.SetInt("ItemIndex", i);
			SlotObject.SetString("label", Localize(SectionPath, KeyName$i, KFCharacterInfoString));
			TexturePath = "img://"$PathName(Skin.UITexture);
			SlotObject.SetBool("enabled", true);
			SlotObject.SetString("source", TexturePath);

			DataProvider.SetElementObject(ItemIndex, SlotObject);
			ItemIndex++;
		}
		else
		{
			//`log("Skin" @ Skin.UITexture.Name @ "is not purchased.");
		}
	}
	MeshObject.SetObject("skinInfo", DataProvider);

	return FirstSkin;
}

function SetCurrentCharacterButtons()
{
	local GFxObject DataObject;

	DataObject = CreateObject("Object");

	DataObject.SetString( "selectedCharacter", Localize(CharInfoPath, "CharacterName", KFCharacterInfoString) );
	DataObject.SetString( "characterBio", Localize(CharInfoPath, "Description", KFCharacterInfoString) );
	DataObject.SetInt( "selectedCharacterIndex", MyKFPRI.RepCustomizationInfo.CharacterIndex );

	SetObject( "selectedCharacter", DataObject);
	
	//set head
	SetGearButtons(MyKFPRI.RepCustomizationInfo.HeadMeshIndex, MyKFPRI.RepCustomizationInfo.HeadSkinIndex, HeadMeshKey, HeadSkinKey, HeadFunctionKey);
	//set body
	SetGearButtons(MyKFPRI.RepCustomizationInfo.BodyMeshIndex, MyKFPRI.RepCustomizationInfo.BodySkinIndex, BodyMeshKey, BodySkinKey, BodyFunctionKey);
	//set attachments
	SetAttachmentButtons(AttachmentKey, AttachmentFunctionKey);

	SetEmoteButton();
}

function SetEmoteButton()
{
	local GFxObject DataObject;
	local int EmoteIndex;

	EmoteIndex = class'KFEmoteList'.static.GetEmoteIndex( class'KFEmoteList'.static.GetEquippedEmoteId());

	DataObject = CreateObject("Object");
	if(EmoteIndex == 255)
	{
		DataObject.SetString( "selectedEmote", "");
		DataObject.SetInt( "selectedEmoteIndex", 0 );
	}
	else
	{
		DataObject.SetString( "selectedEmote", Localize(EmoteList[EmoteIndex].ItemName, "EmoteName", KFCharacterInfoString));
		DataObject.SetInt( "selectedEmoteIndex", 0 );
	}
	

	SetObject("selectedEmote", DataObject);
}

/** Update the labels for our gear buttons */
function SetGearButtons(int MeshIndex, int SkinIndex, string MeshKey, string SkinKey, string sectionFunctionName)
{
	local string SectionPath;
	local string CurrentMesh;
	local string SkinName, MeshName;
	local GFxObject DataObject;

	DataObject = CreateObject("Object");

	if(MeshIndex == `CLEARED_ATTACHMENT_INDEX)
	{
		DataObject.SetString( sectionFunctionName, NoneString );
	}
	else
	{
		CurrentMesh = MeshKey$MeshIndex;
		SectionPath = CharInfoPath$"."$CurrentMesh;

		SkinName = Localize(SectionPath, SkinKey$SkinIndex, KFCharacterInfoString);
		MeshName = Localize(CharInfoPath, CurrentMesh, KFCharacterInfoString);
		DataObject.SetString( sectionFunctionName,  MeshName @"\n" @SkinName );
	}

	DataObject.SetInt( (sectionFunctionName$"Index"), MeshIndex);
	DataObject.SetInt( (sectionFunctionName$"SkinIndex"), SkinIndex);

	SetObject( sectionFunctionName, DataObject);
}

/** Update the labels for our currently equipped attachments */
function SetAttachmentButtons(string AttachmentMeshKey, string sectionFunctionName)
{
	local GFxObject DataObject;
	local int i, AttachmentIndex;
	DataObject = CreateObject("Object");

	for(i = 0; i < `MAX_COSMETIC_ATTACHMENTS; i++)
	{
		AttachmentIndex = MyKFPRI.RepCustomizationInfo.AttachmentMeshIndices[i];
		if( AttachmentIndex == `CLEARED_ATTACHMENT_INDEX )
		{
			DataObject.SetString("selectedAttachment_"$i, "----");
		}
		else
		{
			DataObject.SetString("selectedAttachment_"$i, Localize(string(CurrentCharInfo.CosmeticVariants[AttachmentIndex].AttachmentItem.Name), AttachmentMeshKey, KFCharacterInfoString));
		}
	}	

	SetObject( sectionFunctionName, DataObject);
}

event OnClose()
{
	local PlayerController PC;
	local KFPlayerController KFPC;

	super.OnClose();

	Manager.CachedProfile.Save( GetLP().ControllerId );

	GetGameViewportClient().HandleInputAxis = none;

	if ( class'WorldInfo'.static.IsMenuLevel() )
	{
		Manager.ManagerObject.SetBool("backgroundVisible", true);
	}

	// If we are alive, in game, with a playable pawn. switch back to first person view when leaving this menu
	PC = GetPC();
	if( PC != none )
	{
		KFPC = KFPlayerController( PC );
		if( KFPC != none )
		{
			KFPC.ReturnToViewTarget();
			if( PC.WorldInfo.GRI.bMatchHasBegun && PC.Pawn != none && !PC.Pawn.IsA('KFPawn_Customization') )
			{
				PC.ServerCamera( 'FirstPerson' );
			}
		}
	}
}

event bool OnAxisModified( int ControllerId, name Key, float Delta, float DeltaTime, bool bGamepad )
{
	if ( GetPC().PlayerInput.bUsingGamepad )
	{
		if ( Key == 'XboxTypeS_RightX' && Abs(Delta) > ControllerRotationThreshold)
		{
	    	Callback_RotateCamera(Delta * ControllerRotationRate);
		}
	}
	return false;
}

//==============================================================
// ActionScript Callbacks
//==============================================================

function Callback_RotateCamera( int RotationDirection )
{
	local KFPlayerCamera PlayerCamera;
	
	PlayerCamera = KFPlayerCamera( GetPC().PlayerCamera );
	if ( PlayerCamera != none )
	{
		PlayerCamera.CustomizationCam.RotatedCamera( RotationDirection );
	}
}

function Callback_EndRotateCamera()
{
	local KFPlayerCamera PlayerCamera;

	PlayerCamera = KFPlayerCamera( GetPC().PlayerCamera );
	if ( PlayerCamera != none )
	{
		PlayerCamera.CustomizationCam.StartFadeRotation();
	}
}

function Callback_BodyCamera()
{
	if ( KFPlayerCamera( GetPC().PlayerCamera ) != none )
	{
		KFPlayerCamera( GetPC().PlayerCamera ).CustomizationCam.SetBodyView( 0 );
	}
}

function Callback_HeadCamera()
{
	if ( KFPlayerCamera( GetPC().PlayerCamera ) != none )
	{
		KFPlayerCamera( GetPC().PlayerCamera ).CustomizationCam.SetBodyView( 1 );
	}
}

private function Callback_Emote(int Index)
{
	local KFPlayerController KFPC;

	KFPC = KFPlayerController(GetPC());
	if( KFPC != none )
	{
		class'KFEmoteList'.static.SaveEquippedEmote(EmoteList[Index].ID);

		if ( KFPawn_Customization(KFPC.Pawn) != none )
		{
			KFPawn_Customization(KFPC.Pawn).PlayEmoteAnimation();
		}
	}

	SetEmoteButton();
}

private function Callback_Character(int Index)
{
	local Pawn P;

	P = GetPC().Pawn;
	if( P != none )
	{
		// only allowed during gear preview
		if ( KFPawn_Customization(P) != none )
		{
			SelectCharacter(P, Index);
		}
	}

	UpdateGear();
}

private function Callback_Head( int MeshIndex, int SkinIndex )
{
	local Pawn P;
	local KFPawn KFP;

	P = GetPC().Pawn;
	if( P != none )
	{
		KFP = KFPawn( P );
		if ( KFP != none )
		{
			SelectCustomizationOption(KFP, CO_Head, MeshIndex, SkinIndex);
		}
	}
	
	SetGearButtons(MeshIndex, SkinIndex, HeadMeshKey, HeadSkinKey, HeadFunctionKey);
}

private function Callback_Body( int MeshIndex, int SkinIndex )
{
	local Pawn P;
	local KFPawn KFP;

	P = GetPC().Pawn;
	if( P != none )
	{
		KFP = KFPawn( P );
		if ( KFP != none )
		{
			SelectCustomizationOption(KFP, CO_Body, MeshIndex, SkinIndex);

			// When assigning a new body mesh we may need to remove certain attachments
			// refresh filters, and update the equipped accessories list
			UpdateAttachmentsList(CurrentCharInfo.CosmeticVariants);
			SetAttachmentButtons(AttachmentKey, AttachmentFunctionKey);
		}
	}

	SetGearButtons(MeshIndex, SkinIndex, BodyMeshKey, BodySkinKey, BodyFunctionKey);
}

private function Callback_Attachment1( int MeshIndex, int SkinIndex )
{
	Callback_AttachmentNumbered(MeshIndex, SkinIndex, 0);
}
private function Callback_Attachment2( int MeshIndex, int SkinIndex )
{
	Callback_AttachmentNumbered(MeshIndex, SkinIndex, 1);
}
private function Callback_Attachment3( int MeshIndex, int SkinIndex )
{
	Callback_AttachmentNumbered(MeshIndex, SkinIndex, 2);
}

private function Callback_AttachmentNumbered(int MeshIndex, int SkinIndex, int SlotIndex)
{
	local Pawn P;
	local KFPawn KFP;
	local array<int> RemovedAttachments;
	P = GetPC().Pawn;
	if( P != none )
	{
		KFP = KFPawn( P );

		if ( KFP != none && MyKFPRI != None )
		{
			//CurrentCharInfo.RemoveAttachmentMeshAndSkin(SlotIndex, KFP, MyKFPRI);
			CurrentCharInfo.DetachConflictingAttachments(MeshIndex, KFP, MyKFPRI, RemovedAttachments);

			SelectCustomizationOption(KFP, CO_Attachment, MeshIndex, SkinIndex, SlotIndex);

		}
	}
	SetAttachmentButtons(AttachmentKey, AttachmentFunctionKey);
}

private function Callback_Attachment( int MeshIndex, int SkinIndex )
{
	local Pawn P;
	local KFPawn KFP;
	local int SlotIndex;
	P = GetPC().Pawn;
	if( P != none )
	{
		KFP = KFPawn( P );

		if ( KFP != none && MyKFPRI != None )
		{
			
			CurrentCharInfo.DetachConflictingAttachments(MeshIndex, KFP, MyKFPRI);
			SlotIndex = CurrentCharInfo.GetAttachmentSlotIndex(MeshIndex, KFP, MyKFPRI);
			SelectCustomizationOption(KFP, CO_Attachment, MeshIndex, SkinIndex, SlotIndex);
		}
	}

	SetAttachmentButtons(AttachmentKey, AttachmentFunctionKey);
}

function RelayFromCheatManager(Pawn P, ECustomizationOption CustomizationOption, int MeshIndex, int SkinIndex, int AttachmentIndex, optional bool bIgnoreConflictingSlots = false)
{
	if(!bIgnoreConflictingSlots)
	{
		CurrentCharInfo.DetachConflictingAttachments(MeshIndex, KFPawn(P), MyKFPRI);
	}
	SelectCustomizationOption(P, CustomizationOption, MeshIndex, SkinIndex, AttachmentIndex);
	Manager.CachedProfile.SetCharacterGear(MyKFPRI.RepCustomizationInfo);
}

/** Update our character parts when the UI is being used */
native private function SelectCharacter(Pawn P, byte CharacterIndex);
native private function SelectCustomizationOption(Pawn P, ECustomizationOption CustomizationOption, int MeshIndex, int SkinIndex, optional int AttachmentIndex);

defaultproperties
{
	CurrentPerkIndex=INDEX_NONE

	ControllerRotationThreshold=.25
	ControllerRotationRate=15
	KFEmoteInfoString="KFEmoteInfo"
	KFCharacterInfoString="KFCharacterInfo"
	HeadFunctionKey="selectedHead"
	BodyFunctionKey="selectedBody"
	AttachmentFunctionKey="selectedAttachment"
	BodyMeshKey="BodyMesh"
	BodySkinKey="BodySkin"
	HeadMeshKey="HeadMesh"
	HeadSkinKey="HeadSkin"
	AttachmentKey="Attachment"
	AttachmentSkinKey="AttachmentSkin"
	ClearImagePath="CHR_Shared_TEX.NoItem_Selection"
	SubWidgetBindings.Add((WidgetName="customizationComponent",WidgetClass=class'KFGFxObject_Container'))
	SubWidgetBindings.Add((WidgetName="perkSelectionContainer",WidgetClass=class'KFGFxGearContainer_PerksSelection'))
}
