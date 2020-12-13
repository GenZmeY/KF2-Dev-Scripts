//=============================================================================
// KFGFxMenu_Inventory
//=============================================================================
// This menu is used to show the player's inventory and crafting.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  Zane Gholson -  09/30/2015
//=============================================================================

class KFGFxMenu_Inventory extends KFGFxObject_Menu;

var localized string RecycleOneString;
var localized string RecycleDuplicatesString;

var localized string NoItemsString;
var localized string InventoryPopulatingString;
var localized string InventoryString;
var localized string EquipString;
var localized string UnequipString;
var localized string UseString;
var localized string RecycleString;
var localized string CraftString;

var localized string AllString;
var localized string WeaponSkinString;
var localized string CosmeticString;
var localized string EmotesString;
var localized string CraftingMatsString;
var localized string ItemString;
var localized string FiltersString;
var localized string CraftWeaponString;
var localized string CraftCosmeticString;
var localized string CraftItemString;
var localized string ConfirmCraftItemString;
var localized string RecycleWarningString;
var localized string RecycleItemString;
var localized array<string> CraftWeaponStrings;
var localized array<string> CraftCosmeticStrings;

var localized string FailedToExchangeString;
var localized string MoreItemsString;

var localized string ItemExchangeTimeOutString;
var localized string TryAgainString;

var localized string FailedToCraftItemString;
var localized string CraftRequirementString;

var localized string CraftCosmeticDescriptionString;
var localized string CraftWeaponDescriptionString;
var localized string RequiresString;

var localized string PurchaseKeyString;
var localized string LookUpOnMarketString;

var localized string RarityFilterString;
var localized string WeaponTypeFilterString;
var localized string PerkFilterString;


var GFxObject CraftingSubMenu;
var GFxObject ItemListContainer;
var GFxObject ItemDetailsContainer;
var GFxObject EquipButton; //item deatils container
var GFxObject CraftWeaponButton;
var GFxObject CraftCosmeticButton;


var OnlineSubsystem OnlineSub;
var PlayfabInterface PlayfabInter;
var KFPawn_Customization KFPH;
var bool bInitialInventoryPassComplete;
var int TempItemIdHolder; //used to cache id when crafting / recycling (pop ups)

var int UncommonCosmeticID;
var int RareCosmeticID;
var int ExceptionalCosmeticID;
var int MasterCosmeticID;

var int UncommonWeaponID;
var int RareWeaponID;
var int ExceptionalWeaponID;
var int MasterWeaponID;

var name SoundEvent_Common;
var name SoundEvent_Uncommon;
var name SoundEvent_Rare;
var name SoundEvent_Legendary;
var name SoundEvent_ExceedinglyRare;
var name SoundEvent_Mythical;
var name SoundThemeName;

var KFPlayerController KFPC;

var int ValueToPromptDuplicateRecycle;
var array<int> SpecialEventItemIDs;
var array<int> KeylessCrateIDs;

var AkEvent KillThatDangSoundEvent;

enum EINventory_Filter
{
	EInv_WeaponSkins,
	EInv_Cosmetics,
	EInv_Consumables,
	EInv_Items,
	EInv_CraftingMats,
	EInv_Emotes,
	EInv_SFX,
	EInv_All,
};

enum EInventoryWeaponType_Filter
{
	EInvWT_Pistol,
	EInvWT_Shotgun,
	EInvWT_Rifle,
	EInvWT_Projectile,
	EInvWT_Fire,
	EInvWT_Tech,
	EInvWT_Launcher,
	EInvWT_AssaultRifle,
	EInvWT_Melee,
	EInvWT_SMG,
	EInvWT_None
};

struct InventoryHelper
{
	var int ItemDefinition;
	var int ItemIndex;
	var int ItemCount;
	var GFxObject GfxItemObject;
};

var EInventoryWeaponType_Filter CurrentWeaponTypeFilter;
var int CurrentPerkIndexFilter;
var ItemRarity CurrentRarityFilter;

var EINventory_Filter CurrentInventoryFilter;

var ExchangeRuleSets RuleToExchange;

function InitializeMenu( KFGFxMoviePlayer_Manager InManager )
{
	super.InitializeMenu( InManager );
	KFPC = KFPlayerController(GetPC());
	CurrentPerkIndexFilter = KFPC.PerkList.length; //default value

	LocalizeText();

	OnlineSub = class'GameEngine'.static.GetOnlineSubsystem();
	PlayfabInter = class'GameEngine'.static.GetPlayfabInterface();

	//@SABER_EGS IsEosBuild() case added
	if( class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEosBuild() )
	{
		PlayfabInter.AddInventoryReadCompleteDelegate( OnReadPlayfabInventoryComplete );
	}
	else
	{
		OnlineSub.AddOnInventoryReadCompleteDelegate(OnInventoryReadComplete);
	}

	KFPH = KFPawn_Customization(KFPC.Pawn);
	CraftingSubMenu = GetObject("craftingPanelContainer");
	ItemDetailsContainer = GetObject("itemDetailsContainer");
	EquipButton = ItemDetailsContainer.GetObject("equipButton");
	UpdateCraftButtons();
}

function UpdateCraftButtons()
{
	ItemListContainer = GetObject("inventoryListContainer");
	if(ItemListContainer != none)
	{
		CraftWeaponButton = ItemListContainer.GetObject("craftWeaponsButton");
		if(CraftWeaponButton != none)
		{
			CraftWeaponButton.SetBool("enabled", class'WorldInfo'.static.IsMenuLevel());
		}
		CraftCosmeticButton = ItemListContainer.GetObject("craftCosmeticsButton");
		if(CraftCosmeticButton != none)
		{
			CraftCosmeticButton.SetBool("enabled", class'WorldInfo'.static.IsMenuLevel());
		}
	}
}

function OnOpen()
{
	//@SABER_EGS IsEosBuild() case added
	if( class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEosBuild() )
	{
		PlayfabInter.AddInventoryReadCompleteDelegate( OnReadPlayfabInventoryComplete );
	}
	else if( OnlineSub != none )
	{
		OnlineSub.AddOnInventoryReadCompleteDelegate(OnInventoryReadComplete);
	}

	InitInventory();
	if ( class'WorldInfo'.static.IsMenuLevel() )
	{
		Manager.ManagerObject.SetBool("backgroundVisible", false);
	}

	KFPC.ConsoleCommand("CE Idle");
}

function OnClose()
{
	ClearMatinee();

	//@SABER_EGS IsEosBuild() case added
	if( class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEosBuild() )
	{
		PlayfabInter.ClearInventoryReadCompleteDelegate( OnReadPlayfabInventoryComplete );
	}
	else if( OnlineSub != none )
	{
		OnlineSub.ClearOnInventoryReadCompleteDelegate(OnInventoryReadComplete);
	}

	if ( class'WorldInfo'.static.IsMenuLevel() )
	{
		Manager.ManagerObject.SetBool("backgroundVisible", true);
	}
}

function InitInventory()
{
	local int i, ItemIndex, HelperIndex;
	local ItemProperties TempItemDetailsHolder;
	local GFxObject ItemArray, ItemObject;
	local bool bActiveItem;
	local array<InventoryHelper> ActiveItems;
	local InventoryHelper HelperItem;
	local array<ExchangeRuleSets> ExchangeRules;

	local GFxObject PendingItem;

	ItemArray = CreateArray();

	if(OnlineSub == none)
	{
		// If there is no OnlineSubsystem just send an empty array.  HSL_BB
		SetObject("inventoryList", ItemArray);
		return;
	}
	for (i = 0; i < OnlineSub.CurrentInventory.length; i++)
	{
		//look item up to get info on it.
		ItemIndex = OnlineSub.ItemPropertiesList.Find('Definition', OnlineSub.CurrentInventory[i].Definition);

		// BWJ - 12-21-16 - Hide items that have no definition
		if(ItemIndex != INDEX_NONE && OnlineSub.CurrentInventory[i].Definition != 0 )
		{
			TempItemDetailsHolder = OnlineSub.ItemPropertiesList[ItemIndex];

			if (((CurrentInventoryFilter == EInv_All || Int(CurrentInventoryFilter) == Int(TempItemDetailsHolder.Type)) && DoesMatchFilter(TempItemDetailsHolder)) || bool(OnlineSub.CurrentInventory[i].NewlyAdded))
			{
				ItemObject = CreateObject("Object");
				HelperIndex = ActiveItems.Find('ItemDefinition', onlineSub.CurrentInventory[i].Definition);

				if(HelperIndex == INDEX_NONE)
				{
					HelperItem.ItemDefinition = onlineSub.CurrentInventory[i].Definition;
					HelperItem.ItemCount = onlineSub.CurrentInventory[i].Quantity;
					ActiveItems.AddItem(HelperItem);
					HelperIndex = ActiveItems.length - 1;
				}
				else
				{
					ActiveItems[HelperIndex].ItemCount += onlineSub.CurrentInventory[i].Quantity;
				}

				OnlineSub.IsExchangeable(onlineSub.CurrentInventory[i].Definition, ExchangeRules);

				ItemObject.SetInt("count", ActiveItems[HelperIndex].ItemCount);
				ItemObject.SetString("label", TempItemDetailsHolder.Name);
				ItemObject.SetString("price", TempItemDetailsHolder.price);
				ItemObject.Setstring("typeRarity", TempItemDetailsHolder.ShortDescription);
				ItemObject.SetInt("type", TempItemDetailsHolder.Type);
				ItemObject.SetBool("exchangeable", IsItemExchangeable(TempItemDetailsHolder, ExchangeRules) && class'WorldInfo'.static.IsMenuLevel() );
				ItemObject.SetBool("recyclable", IsItemRecyclable(TempItemDetailsHolder, ExchangeRules) && class'WorldInfo'.static.IsMenuLevel());
				bActiveItem = IsItemActive(onlineSub.CurrentInventory[i].Definition) || IsSFXActive(onlineSub.CurrentInventory[i].Definition);
				ItemObject.SetBool("active", bActiveItem );
				ItemObject.SetInt("rarity", TempItemDetailsHolder.Rarity);
				ItemObject.SetString("description", TempItemDetailsHolder.Description);
				ItemObject.SetString("iconURLSmall", "img://"$TempItemDetailsHolder.IconURL);
				ItemObject.SetString("iconURLLarge", "img://"$TempItemDetailsHolder.IconURLLarge);
				ItemObject.SetInt("definition", TempItemDetailsHolder.Definition);
				ItemObject.SetBool("newlyAdded", bool(OnlineSub.CurrentInventory[i].NewlyAdded) );

				ActiveItems[HelperIndex].GfxItemObject = ItemObject;

				if(onlineSub.CurrentInventory[i].Definition == Manager.SelectIDOnOpen)
				{
					PendingItem = ItemObject;
				}

				if(bool(OnlineSub.CurrentInventory[i].NewlyAdded) && bInitialInventoryPassComplete)
				{
					SetMatineeColor(TempItemDetailsHolder.Rarity);
					KFPC.ConsoleCommand("CE gotitem");

					SetObject("details", ItemObject);
				}
			}
		}
	}

	OnlineSub.ClearNewlyAdded();

	for (i = 0; i < ActiveItems.length; i++)
	{
		ItemArray.SetElementObject(i, ActiveItems[i].GfxItemObject);
	}

	SetObject("inventoryList", ItemArray);

	if(Manager.SelectIDOnOpen != INDEX_NONE )
	{
		CallBack_ItemDetailsClicked(Manager.SelectIDOnOpen);
		SetObject("details", PendingItem);
		Manager.SelectIDOnOpen = INDEX_NONE;
	}

	bInitialInventoryPassComplete = true;
}

function bool DoesMatchFilter(ItemProperties InventoryItem)
{
	if(CurrentInventoryFilter == EInv_All || CurrentInventoryFilter == EInv_WeaponSkins)
	{
		if ((CurrentWeaponTypeFilter != EInvWT_None || CurrentPerkIndexFilter != KFPC.PerkList.length) && InventoryItem.Type != ITP_WeaponSkin )
		{
			return false;
		}

		if (CurrentWeaponTypeFilter != EInvWT_None && CurrentWeaponTypeFilter != InventoryItem.WeaponType )
		{
			return false;
		}

		// doesn't match filter if the perk id doesn't match (unless it's set to any or survivalist)
		if (CurrentPerkIndexFilter != KFPC.PerkList.length && !(CurrentPerkIndexFilter == InventoryItem.PerkId || CurrentPerkIndexFilter == InventoryItem.AltPerkId) && KFPC.PerkList[CurrentPerkIndexFilter].PerkClass != class'KFPerk_Survivalist') //perk
		{
			return false;
		}
	}

	if (CurrentRarityFilter != ITR_NONE && InventoryItem.Rarity != CurrentRarityFilter && CurrentInventoryFilter != EInv_Consumables)
	{
		if ((CurrentInventoryFilter == EInv_CraftingMats || CurrentInventoryFilter == EInv_Consumables) && (CurrentInventoryFilter == InventoryItem.Type + 1))
		{
			return true;
		}
		return false;
	}

	return true;
}

function OnItemExhangeTimeOut()
{
	if( !class'WorldInfo'.static.IsConsoleBuild() )
	{
		Manager.DelayedOpenPopup(ENotification, EDPPID_Misc, ItemExchangeTimeOutString, TryAgainString, class'KFCommon_LocalizedStrings'.default.OKString);
		SetVisible(true);
	}
}

function FinishCraft()
{
	SetVisible(true);
}

function SetMatineeColor(int ItemRarity)
{
	switch (ItemRarity)
	{
		case ITR_Common:
			KFPC.ConsoleCommand("CE rarityCommon");
			break;

		case ITR_Uncommon:
			KFPC.ConsoleCommand("CE rarityUncommon");
			break;
		case ITR_Rare:
			KFPC.ConsoleCommand("CE rarityRare");
			break;
		case ITR_Legendary:
			KFPC.ConsoleCommand("CE rarityMasterCrafted");
			break;
		case ITR_ExceedinglyRare:
			KFPC.ConsoleCommand("CE rarityPrecious");
			break;
		case ITR_Mythical:
			KFPC.ConsoleCommand("CE rarityExceptional");
			break;
		default:
			KFPC.ConsoleCommand("CE rarityCommon");
	}
}

function ClearMatinee()
{
	KFPC.PlaySoundBase(KillThatDangSoundEvent);
	KFPC.ConsoleCommand("CE Abort");
	KFPC.ResetCustomizationCamera();
}

function OnReadPlayfabInventoryComplete( bool bSuccess )
{
	if( bSuccess )
	{
		LocalizeText();
		InitInventory();
	}
	else
	{
		Manager.DelayedOpenPopup(ENotification, EDPPID_Misc, class'KFCommon_LocalizedStrings'.default.NoticeString, class'KFCommon_LocalizedStrings'.default.FailedToReachInventoryServerString, class'KFCommon_LocalizedStrings'.default.OKString);
	}
}

function OnInventoryReadComplete()
{
	InitInventory();
}

function bool IsItemRecyclable( ItemProperties ItemDetailsHolder, out const array<ExchangeRuleSets> ExchangeRules )
{
	local int i;

	for( i = 0; i < ExchangeRules.Length; i++ )
	{
		if ( ExchangeRules[i].Type == ITP_CraftingComponent )
		{
			//`log("recycle Yes ["$ItemDetailsHolder.Definition$"] ");

			return true;
		}
	}

	//`log("recycle No ["$ItemDetailsHolder.Definition$"] ");

	return false;
}

function bool IsItemExchangeable( out ItemProperties ItemDetailsHolder, out const array<ExchangeRuleSets> ExchangeRules )
{
	local int i;
	for( i = 0; i < ExchangeRules.Length; i++ )
	{
		if (OnlineSub.ExchangeReady(ExchangeRules[i]))
		{
			//`log("exchange Yes ["$ItemDetailsHolder.Definition$"] ");

			return true;
		}
	}

	//`log("exchange no ["$ItemDetailsHolder.Definition$"] ");

	return false;
}

function bool IsSpecialEventItem(int ItemID)
{
	return SpecialEventItemIDs.Find(ItemID) != INDEX_NONE;
}

function bool IsKeylessCrate(int ItemID)
{
	return KeylessCrateIDs.Find(ItemID) != INDEX_NONE;
}

function bool IsItemActive(int ItemDefinition)
{
	local class<KFWeaponDefinition> WeaponDef;
	local int ItemIndex;

	ItemIndex = class'KFWeaponSkinList'.default.Skins.Find('Id', ItemDefinition);

	if(ItemIndex == INDEX_NONE)
	{
		return false;
	}

	WeaponDef = class'KFWeaponSkinList'.default.Skins[ItemIndex].WeaponDef;

	if(WeaponDef != none)
	{
		return class'KFWeaponSkinList'.Static.IsSkinEquip(WeaponDef, ItemDefinition);
	}


	return false;
}


function bool IsSFXActive(int ItemDefinition)
{
	local int ItemIndex;

	ItemIndex = class'KFHeadShotEffectList'.static.GetHeadShotEffectIndex(ItemDefinition);

	if (ItemIndex == INDEX_NONE)
	{
		return false;
	}

	return class'KFHeadShotEffectList'.Static.IsHeadShotEffectEquipped(ItemDefinition);
}

function LocalizeText()
{
	local GFxObject LocalizedObject;
	local GFxObject WeaponTypeList;
	local GFxObject RarityList;
	local GFxObject PerkList;
	local GFxObject TempObject;

	local int i;

	LocalizedObject = CreateObject( "Object" );

	LocalizedObject.SetString("noItems", 					KFGameEngine(class'Engine'.static.GetEngine()).bReadingPlayfabStoreData ? InventoryPopulatingString : NoItemsString);
	LocalizedObject.SetString("inventory", 					InventoryString);
	LocalizedObject.SetString("back", 						Class'KFCommon_LocalizedStrings'.default.BackString);
	LocalizedObject.SetString("ok", 						Class'KFCommon_LocalizedStrings'.default.OKString);
	LocalizedObject.SetString("equip", 						EquipString);
	LocalizedObject.SetString("unequip", 					UnequipString);
	LocalizedObject.SetString("useString", 					UseString);
	LocalizedObject.SetString("recycle", 					RecycleString);
	LocalizedObject.SetString("sfx",						Class'KFCommon_LocalizedStrings'.default.SpecialEffectsString);

	LocalizedObject.SetString("all", 						AllString);
	LocalizedObject.SetString("weaponSkins", 				WeaponSkinString);
	LocalizedObject.SetString("cosmetics", 					CosmeticString);
	LocalizedObject.SetString("emotes", 					EmotesString);
	LocalizedObject.SetString("craftingMats", 				CraftingMatsString);
	LocalizedObject.SetString("items", 						ItemString);
	LocalizedObject.SetString("filters", 					FiltersString);

	LocalizedObject.SetString("craftWeapon", 				CraftWeaponString);
	LocalizedObject.SetString("craftCosmetic", 				CraftCosmeticString);

	LocalizedObject.SetString("filterName_0", 				RarityFilterString);
	LocalizedObject.SetString("filterName_1", 				PerkFilterString);
	LocalizedObject.SetString("filterName_2", 				WeaponTypeFilterString);


	RarityList = CreateArray();
	for (i = 0; i <= ITR_NONE; i++)
	{
		TempObject = CreateObject("Object");
		if(i == ITR_NONE)
		{
			//dont forget the no preference string
			TempObject.SetString("label", class'KFCommon_LocalizedStrings'.default.NoPreferenceString);
		}
		else
		{
			TempObject.SetString("label", class'KFCommon_LocalizedStrings'.default.RarityStrings[i]);
		}
		RarityList.SetElementObject(i, TempObject);
	}

	PerkList = CreateArray();
	for (i = 0; i <= KFPC.PerkList.length; i++)
	{
		TempObject = CreateObject("Object");
		if(i == KFPC.PerkList.length)
		{
			//dont forget the no preference string
			TempObject.SetString("label", class'KFCommon_LocalizedStrings'.default.NoPreferenceString);
		}
		else
		{
			TempObject.SetString("label", KFPC.PerkList[i].PerkClass.default.PerkName);
		}
		PerkList.SetElementObject(i, TempObject);
	}


	WeaponTypeList = CreateArray();
	for (i = 0; i <= EInvWT_None; i++)
	{
		TempObject = CreateObject("Object");
		if(i == EInvWT_None)
		{
			//dont forget the no preference string
			TempObject.SetString("label", class'KFCommon_LocalizedStrings'.default.NoPreferenceString);
		}
		else
		{
			TempObject.SetString("label", class'KFCommon_LocalizedStrings'.default.WeaponTypeStrings[i]);
		}
		WeaponTypeList.SetElementObject(i, TempObject);
	}

	LocalizedObject.SetInt("filterIndex_0", int(CurrentRarityFilter) );
	LocalizedObject.SetInt("filterIndex_1", CurrentPerkIndexFilter );
	LocalizedObject.SetInt("filterIndex_2", int(CurrentWeaponTypeFilter) );

	LocalizedObject.SetObject("filterData_0", RarityList);
	LocalizedObject.SetObject("filterData_1", PerkList);
	LocalizedObject.SetObject("filterData_2", WeaponTypeList);

	SetObject("localizedText", LocalizedObject);
}

function SetWeaponCraftDetails()
{
	local GFxObject CraftOptionsObject;
	local ItemProperties CommonItemDetailsHolder, RareItemDetailsHolder, ExceptionalItemDetailsHolder, MasterItemDetailsHolder;
	local int ItemIndex, i;
	local array<ItemProperties> ItemArray;

	ItemIndex = OnlineSub.ItemPropertiesList.Find('Definition', UncommonWeaponID);
	if(ItemIndex != INDEX_NONE)
	{
		CommonItemDetailsHolder = OnlineSub.ItemPropertiesList[ItemIndex];
		ItemArray.AddItem(CommonItemDetailsHolder);
	}

	ItemIndex = OnlineSub.ItemPropertiesList.Find('Definition', RareWeaponID);
	if(ItemIndex != INDEX_NONE)
	{
		RareItemDetailsHolder = OnlineSub.ItemPropertiesList[ItemIndex];
		ItemArray.AddItem(RareItemDetailsHolder);
	}

	ItemIndex = OnlineSub.ItemPropertiesList.Find('Definition', ExceptionalWeaponID);
	if(ItemIndex != INDEX_NONE)
	{
		ExceptionalItemDetailsHolder = OnlineSub.ItemPropertiesList[ItemIndex];
		ItemArray.AddItem(ExceptionalItemDetailsHolder);
	}

	ItemIndex = OnlineSub.ItemPropertiesList.Find('Definition', MasterWeaponID);
	if(ItemIndex != INDEX_NONE)
	{
		MasterItemDetailsHolder = OnlineSub.ItemPropertiesList[ItemIndex];
		ItemArray.AddItem(MasterItemDetailsHolder);
	}

	CraftOptionsObject = CreateObject("Object");
	CraftOptionsObject.SetString("title", 				CraftWeaponString);
	CraftOptionsObject.SetString("description", 		CraftWeaponDescriptionString);
	CraftOptionsObject.SetString("craft", 				CraftString);

	for (i = 0; i < ItemArray.length; i++)
	{
		CraftOptionsObject.SetString("label_"$i, 			CraftWeaponStrings[i]);
		CraftOptionsObject.SetString("requirement_"$i,		RequiresString$"10"@ItemArray[i].Name);
		CraftOptionsObject.SetInt("itemCount_"$i, 			GetCountOfItem(ItemArray[i].Definition));
		CraftOptionsObject.SetString("itemImage_"$i, 		"img://"$ItemArray[i].IconURL);
		CraftOptionsObject.SetInt("itemID_"$i, 				ItemArray[i].Definition);
	}

	SetObject("craftOptions", CraftOptionsObject);
}

function SetCosmeticCraftDetails()
{

	local GFxObject CraftOptionsObject;
	local ItemProperties CommonItemDetailsHolder, RareItemDetailsHolder, ExceptionalItemDetailsHolder, MasterItemDetailsHolder;
	local int ItemIndex, i;
	local array<ItemProperties> ItemArray;

	ItemIndex = OnlineSub.ItemPropertiesList.Find('Definition', UncommonCosmeticID);
	if(ItemIndex != INDEX_NONE)
	{
		CommonItemDetailsHolder = OnlineSub.ItemPropertiesList[ItemIndex];
		ItemArray.AddItem(CommonItemDetailsHolder);
	}

	ItemIndex = OnlineSub.ItemPropertiesList.Find('Definition', RareCosmeticID);
	if(ItemIndex != INDEX_NONE)
	{
		RareItemDetailsHolder = OnlineSub.ItemPropertiesList[ItemIndex];
		ItemArray.AddItem(RareItemDetailsHolder);
	}

	ItemIndex = OnlineSub.ItemPropertiesList.Find('Definition', ExceptionalCosmeticID);
	if(ItemIndex != INDEX_NONE)
	{
		ExceptionalItemDetailsHolder = OnlineSub.ItemPropertiesList[ItemIndex];
		ItemArray.AddItem(ExceptionalItemDetailsHolder);
	}

	ItemIndex = OnlineSub.ItemPropertiesList.Find('Definition', MasterCosmeticID);
	if(ItemIndex != INDEX_NONE)
	{
		MasterItemDetailsHolder = OnlineSub.ItemPropertiesList[ItemIndex];
		ItemArray.AddItem(MasterItemDetailsHolder);
	}

	CraftOptionsObject = CreateObject("Object");
	CraftOptionsObject.SetString("title", 				CraftCosmeticString);
	CraftOptionsObject.SetString("description", 		CraftCosmeticDescriptionString);
	CraftOptionsObject.SetString("craft", 				CraftString);

	for (i = 0; i < ItemArray.length; i++)
	{
		CraftOptionsObject.SetString("label_"$i, 			CraftCosmeticStrings[i]);
		CraftOptionsObject.SetString("requirement_"$i,		RequiresString$"10"@ItemArray[i].Name);
		CraftOptionsObject.SetInt("itemCount_"$i, 			GetCountOfItem(ItemArray[i].Definition));
		CraftOptionsObject.SetString("itemImage_"$i, 		"img://"$ItemArray[i].IconURL);
		CraftOptionsObject.SetInt("itemID_"$i, 				ItemArray[i].Definition);
	}

	SetObject("craftOptions", CraftOptionsObject);
}

function int GetCountOfItem(int ItemDefinition)
{
	local int i;
	local int Count;

	for (i = 0; i < onlineSub.CurrentInventory.length; i++)
	{
		if( onlineSub.CurrentInventory[i].Definition == ItemDefinition)
		{
			count += onlineSub.CurrentInventory[i].Quantity;
		}
	}

	return count;
}

function PerformExchange( ExchangeRuleSets ForRuleset, optional bool AllButOne =false )
{
	//@SABER_EGS IsEosBuild() case added
	if( class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.IsEosBuild() )
	{
		PlayfabInter.PerformRuleExchange( ForRuleset, AllButOne );
	}
	else
	{
		OnlineSub.Exchange( ForRuleset, AllButOne );
	}
}


function ConfirmRecycle()
{
	local array<ExchangeRuleSets> ExchangeRules;
	local int RuleIndex;

	//`log("confirming ["$TempItemIdHolder$"] ");

	OnlineSub.IsExchangeable( TempItemIdHolder, ExchangeRules );

	for (RuleIndex = 0; RuleIndex < ExchangeRules.length; RuleIndex++)
	{
		if( OnlineSub.ExchangeReady(ExchangeRules[RuleIndex]) && ExchangeRules[RuleIndex].Type == ITP_CraftingComponent )
		{
			OnlineSub.ClearInFlight();
			PerformExchange( ExchangeRules[RuleIndex], false );
			SetVisible(false);
			KFPC.ConsoleCommand( "CE Recycle_Start" );
			return;
		}
	}
}

function ConfirmDuplicatesRecycle()
{
	local array<ExchangeRuleSets> ExchangeRules;
	local int RuleIndex;

	OnlineSub.IsExchangeable( TempItemIdHolder, ExchangeRules );

	for (RuleIndex = 0; RuleIndex < ExchangeRules.length; RuleIndex++)
	{
		if( OnlineSub.ExchangeReady(ExchangeRules[RuleIndex]) && ExchangeRules[RuleIndex].Type == ITP_CraftingComponent )
		{
			OnlineSub.ClearInFlight();
			PerformExchange( ExchangeRules[RuleIndex], true );
			SetVisible(false);
			KFPC.ConsoleCommand( "CE Recycle_Start" );
			return;
		}
	}
}

function CancelRecycle()
{
	TempItemIdHolder=INDEX_NONE;
}

function ConfirmCraft()
{
	local array<ExchangeRuleSets> ExchangeRules;
	local int RuleIndex;

	OnlineSub.IsExchangeable(TempItemIdHolder, ExchangeRules);

	for (RuleIndex = 0; RuleIndex < ExchangeRules.length; RuleIndex++)
	{
		if(OnlineSub.ExchangeReady(ExchangeRules[RuleIndex]))
		{
			OnlineSub.ClearInFlight();
			PerformExchange( ExchangeRules[RuleIndex], false );
			SetVisible(false);
			KFPC.ConsoleCommand("CE Craft_Start");
			return;
		}
	}

	`log("CRAFTING == SAD");
}

//Only do this on one item, this is too expensive to do in a loop
function int GetItemCount(int ItemDefinition)
{
	local int i, ItemCount;

	if(OnlineSub == none)
	{
		// If there is no OnlineSubsystem just send an empty array.  HSL_BB
		return 0;
	}

	for (i = 0; i < OnlineSub.CurrentInventory.length; i++)
	{
		//look item up to get info on it.
		if(OnlineSub.CurrentInventory[i].Definition != ItemDefinition)
		{
			continue;
		}

		ItemCount += onlineSub.CurrentInventory[i].Quantity;
	}

	return ItemCount;
}

function Callback_CrateOpenComplete(int Rarity)
{
	local name EventName;

	switch (Rarity)
	{
		case ITR_Common:
				EventName=SoundEvent_Common;
			break;
		case ITR_Uncommon:
				EventName=SoundEvent_Uncommon;
			break;
		case ITR_Rare:
				EventName=SoundEvent_Rare;
			break;
		case ITR_Legendary:
				EventName=SoundEvent_Legendary;
			break;
		case ITR_ExceedinglyRare:
				EventName=SoundEvent_ExceedinglyRare;
			break;
		case ITR_Mythical:
				EventName=SoundEvent_Mythical;
			break;

		default:
			EventName=SoundEvent_Common;
	}

	Manager.PlaySoundFromTheme(EventName, SoundThemeName);
}

function Callback_RequestInitialnventory()
{
	InitInventory();
}

function Callback_InventoryFilter( int FilterIndex )
{
	local EINventory_Filter NewFilter;

	switch (FilterIndex)
	{
		case 0:
			NewFilter = EInv_All;
			break;
		case 1:
			NewFilter = EInv_WeaponSkins;
			break;
		case 2:
			NewFilter = EInv_Cosmetics;
			break;
		case 3:
			NewFilter = EInv_Consumables;
			break;
		case 4:
			NewFilter = EInv_CraftingMats;
			break;
		case 5:
			NewFilter = EInv_Emotes;
			break;
		case 6:
			NewFilter = EInv_SFX;
			break;

	}

	if(NewFilter != CurrentInventoryFilter)
	{
		CurrentInventoryFilter = NewFilter;
		InitInventory();
	}
}

function Callback_Equip( int ItemDefinition )
{
	local class<KFWeaponDefinition> WeaponDef;
	local int ItemIndex;

	ItemIndex = class'KFWeaponSkinList'.default.Skins.Find('Id', ItemDefinition);

	if(ItemIndex == INDEX_NONE)
	{
		return;
	}

	WeaponDef = class'KFWeaponSkinList'.default.Skins[ItemIndex].WeaponDef;

	if(WeaponDef != none)
	{
		if(IsItemActive(ItemDefinition))
		{
			class'KFWeaponSkinList'.Static.SaveWeaponSkin(WeaponDef, 0);

			if(class'WorldInfo'.static.IsConsoleBuild( ))
			{
				Manager.CachedProfile.ClearWeaponSkin(WeaponDef.default.WeaponClassPath);
			}
		}
		else
		{
			class'KFWeaponSkinList'.Static.SaveWeaponSkin(WeaponDef, ItemDefinition);
			if(class'WorldInfo'.static.IsConsoleBuild( ))
			{
				Manager.CachedProfile.SaveWeaponSkin(WeaponDef.default.WeaponClassPath, ItemDefinition);
			}
		}
	}

	//refresh inventory
	InitInventory();
}

function Callback_EquipSFX(int ItemDefinition)
{
	local int ItemIndex;

	ItemIndex = class'KFHeadShotEffectList'.static.GetHeadShotEffectIndex(ItemDefinition);

	if (ItemIndex == INDEX_NONE)
	{
		return;
	}

	if (IsSFXActive(ItemDefinition))
	{
		class'KFHeadShotEffectList'.Static.SaveEquippedHeadShotEffect(0);
	}
	else
	{
		class'KFHeadShotEffectList'.Static.SaveEquippedHeadShotEffect(ItemDefinition);
	}

	//refresh inventory
	InitInventory();
}

function CallBack_ItemDetailsClicked(int ItemDefinition)
{
	//get the item and then set the use button label based on if the exchange rule is ready
	local array<ExchangeRuleSets> ExchangeRules;
	local ItemProperties NeededItem, CurrItem;
	local Int NeededItemID;

	CurrItem = OnlineSub.ItemPropertiesList[OnlineSub.ItemPropertiesList.Find('Definition', ItemDefinition)];

	if( CurrItem.RequiredKeyId != "" )
	{
		OnlineSub.HasKeyForItem( ItemDefinition, NeededItemID );
	}
	else
	{
		OnlineSub.IsExchangeable(ItemDefinition, ExchangeRules);

		if(ExchangeRules.length <= 0)
		{
			//`log("NO RULES EXIST FOR THIS ITEM!" @ItemDefinition);
			return;
		}

		if(!OnlineSub.ExchangeReady(ExchangeRules[0]))
		{
			///get needed item from rule set
			if(ExchangeRules[0].Sources[0].Definition == ItemDefinition)
			{
				if(ExchangeRules[0].Sources.length > 1)
				{
					NeededItemID = ExchangeRules[0].Sources[1].Definition;
				}
			}
			else
			{
				NeededItemID = ExchangeRules[0].Sources[0].Definition;
			}
		}
	}

	// Set equip button if we need an item
	if( NeededItemID > 0 )
	{
		NeededItem = OnlineSub.ItemPropertiesList[OnlineSub.ItemPropertiesList.Find('Definition', NeededItemID)];
		if(NeededItem.Price == "")
		{
			EquipButton.SetString("label", LookUpOnMarketString);
		}
		else
		{
			EquipButton.SetString("label", PurchaseKeyString @ ((class'WorldInfo'.static.IsConsoleBuild() || class'WorldInfo'.static.isEosBuild()) ? "" : (":"@NeededItem.Price)));
		}
	}
}

function Callback_UseItem( int ItemDefinition )
{
	local array<ExchangeRuleSets> ExchangeRules;
	local string ItemSeriesCommand;
	local ItemProperties NeededItem, CurrItem;
	local Int NeededItemID;
	//local bool bExchangeFound;
	local int RuleIndex;

	//`log("using item ["$ItemDefinition$"]");

	// Some playfab items require keys
	TempItemIdHolder = ItemDefinition;
	CurrItem = OnlineSub.ItemPropertiesList[OnlineSub.ItemPropertiesList.Find('Definition', ItemDefinition)];

	if (CurrItem.Type == ITP_CraftingComponent)
	{
		Callback_CraftOption(ItemDefinition);
		return;
	}

	if( IsSpecialEventItem(TempItemIdHolder) )
	{
		//`log("is special");
		Callback_CraftOption(TempItemIdHolder);
		return;
	}

	// any recipes involving this item? return only those
	if ( OnlineSub.IsExchangeable(TempItemIdHolder, ExchangeRules) == 0 )
	{
		//`log("is not exchangeable");
		return;
	}

	// run through the rules (there will typically be only one) and
	// pick the one that is NOT the recycle recipe, as defined by
	// having a CraftingComponent target
	for (RuleIndex = 0; RuleIndex < ExchangeRules.length; RuleIndex++)
	{
		if ( ExchangeRules[RuleIndex].Type == ITP_CraftingComponent )
		{
			//`log("crafting, no go ["$ExchangeRules[RuleIndex].Type$"]" );
			continue;
		}

		// Check to see if we have the key, if not, record what we DO
		// need and prompt the user to spend money
		if ( OnlineSub.ExchangeReady(ExchangeRules[RuleIndex]) )
		{
			//`log("ready");
			SetVisible(false);
			PerformExchange( ExchangeRules[RuleIndex], false );
			ItemSeriesCommand = "CE open_"$class'KFInventoryCatalog'.static.GetItemSeries(ItemDefinition);

			KFPC.ConsoleCommand( ItemSeriesCommand );
		}
		else if ( ExchangeRules[RuleIndex].Sources.length > 1 )
		{
			//`log("not ready <1> length ["$ExchangeRules[RuleIndex].Sources.length$"]" );
			if( ExchangeRules[RuleIndex].Sources[0].Definition == ItemDefinition )
			{
				NeededItemID = ExchangeRules[RuleIndex].Sources[1].Definition;
				//`log("need <1> ["$NeededItemID$"]");
			}
			else
			{
				NeededItemID = ExchangeRules[RuleIndex].Sources[0].Definition;
				//`log("need <2> ["$NeededItemID$"]");
			}
		}
		else
		{
			//`log("not ready <2>");
		}
	}

	if( NeededItemID > 0 )
	{
		NeededItem = OnlineSub.ItemPropertiesList[OnlineSub.ItemPropertiesList.Find('Definition', NeededItemID)];
		if(NeededItem.Price == "" || NeededItem.SignedOfferId != "")
		{
			if( class'WorldInfo'.static.IsConsoleBuild( CONSOLE_Durango ) )
			{
				OnlineSub.PlayerInterfaceEx.ShowProductDetailsUI( GetLP().ControllerId, NeededItem.ProductID );
			}
			else
			{
				if (OnlineSub.IsGameOwned())
				{
					//open market place item
					OnlineSub.OpenMarketPlaceSearch(NeededItem);
				}
				else
				{
					Manager.DisplayFreeTrialFeatureBlockedPopUp();
				}
			}
		}
		else
		{
			if (OnlineSub.IsGameOwned())
			{
				//open key purchase
				OnlineSub.OpenItemPurchaseOverlay(NeededItemID);
			}
			else
			{
				Manager.DisplayFreeTrialFeatureBlockedPopUp();
			}
		}
	}
}

function Callback_CharacterSkin( int ItemDefinition )
{

}

function Callback_RecycleItem( int ItemDefinition )
{
	local int MatchingItemCount;

	TempItemIdHolder = ItemDefinition;
	//Get how man we have.
	MatchingItemCount = GetItemCount(ItemDefinition);
	//If we have more than X number,
	if(MatchingItemCount >= ValueToPromptDuplicateRecycle)
	{
		//give a third choice to recycle duplicates
		Manager.DelayedOpenPopup( EConfirmation,EDPPID_Misc,
								  RecycleItemString,
								  RecycleWarningString,
								  RecycleDuplicatesString,
								  class'KFCommon_LocalizedStrings'.default.CancelString,
								  ConfirmDuplicatesRecycle,
								  CancelRecycle,
								  RecycleOneString,
								  ConfirmRecycle );
	}
	else
	{
		//else give standard recycle pop up
		Manager.DelayedOpenPopup( EConfirmation,EDPPID_Misc,
								  RecycleItemString,
								  RecycleWarningString,
								  class'KFCommon_LocalizedStrings'.default.ConfirmString,
								  class'KFCommon_LocalizedStrings'.default.CancelString,
								  ConfirmRecycle );
	}
}

function Callback_CraftOption(int ItemDefinition)
{
	local array<ExchangeRuleSets> ExchangeRules;
	local int RuleIndex;
	TempItemIdHolder = ItemDefinition;

	//`log("CRAFT OPTION CALLED!");
	OnlineSub.IsExchangeable(TempItemIdHolder, ExchangeRules);

	for (RuleIndex = 0; RuleIndex < ExchangeRules.length; RuleIndex++)
	{
		if(OnlineSub.ExchangeReady(ExchangeRules[RuleIndex]))
		{
			//`log("FOUND THE RULES!!");
			Manager.DelayedOpenPopup(EConfirmation,EDPPID_Misc, CraftItemString, ConfirmCraftItemString, class'KFCommon_LocalizedStrings'.default.ConfirmString, class'KFCommon_LocalizedStrings'.default.CancelString, ConfirmCraft );
			return;
		}
	}
	//`log("NO DICE SHOW BAD POP UP!");
	Manager.DelayedOpenPopup(ENotification,EDPPID_Misc, FailedToCraftItemString, CraftRequirementString, class'KFCommon_LocalizedStrings'.default.OKString);
}

function Callback_WeaponTypeFilterChanged(int NewFilterIndex)
{
	CurrentWeaponTypeFilter = EInventoryWeaponType_Filter(NewFilterIndex);
	//refresh
	InitInventory();
}

function Callback_RarityTypeFilterChanged(int NewFilterIndex)
{
	CurrentRarityFilter = ItemRarity(NewFilterIndex);
	InitInventory();
}

function Callback_PerkTypeFilterChanged(int NewFilterIndex)
{
	CurrentPerkIndexFilter = NewFilterIndex;
	InitInventory();
}


function CallBack_RequestCosmeticCraftInfo()
{
	SetCosmeticCraftDetails();
}

function CallBack_RequestWeaponCraftInfo()
{
	SetWeaponCraftDetails();
}

function Callback_PreviewItem( int ItemDefinition )
{
	if(KFPH != none)
	{
		//KFPH.AttachWeaponByItemDefinition(ItemDefinition);
	}
}

defaultproperties
{
	CurrentWeaponTypeFilter = EInvWT_None;
	CurrentRarityFilter = ITR_NONE;


	ValueToPromptDuplicateRecycle=3
	SoundEvent_Common=Crate_End_Common
	SoundEvent_Uncommon=Crate_End_Uncommon
	SoundEvent_Rare=Crate_End_Rare
	SoundEvent_Legendary=Crate_End_Lengendary
	SoundEvent_ExceedinglyRare=Crate_End_ExeedinglyRare
	SoundEvent_Mythical=Crate_End_Mythical
	SoundThemeName=SoundTheme_Crate

	UncommonCosmeticID=3708
	RareCosmeticID=3709
	ExceptionalCosmeticID=3710
	MasterCosmeticID=3711

	UncommonWeaponID=3712
	RareWeaponID=3713
	ExceptionalWeaponID=3714
	MasterWeaponID=3715

	SpecialEventItemIDs(0)=4896
	SpecialEventItemIDs(1)=4928
	SpecialEventItemIDs(2)=4929
	SpecialEventItemIDs(3)=5247
	SpecialEventItemIDs(4)=5246
	SpecialEventItemIDs(5)=5245
	SpecialEventItemIDs(6)=5304
	SpecialEventItemIDs(7)=5587
	SpecialEventItemIDs(8)=5588
	SpecialEventItemIDs(9)=5589
	SpecialEventItemIDs(10)=5802
	SpecialEventItemIDs(11)=5803
	SpecialEventItemIDs(12)=5804

	KeylessCrateIDs(0)=5313

	KillThatDangSoundEvent=AkEvent'WW_UI_Menu.Play_UI_Trader_Build_Stop_No_Sound'
}