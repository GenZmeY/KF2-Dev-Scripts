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

var localized string SearchText;
var localized string ClearSearchText;

var int SearchMaxChars;

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
	var ItemType Type;
	var GFxObject GfxItemObject;
	var string FullName;
	// For ordering in weapon skins
	var int WeaponDef;
	var int Price;
	var int SkinType; // also used in Cosmetics
	var ItemRarity Rarity;
	var int Quality;

	// For ordering cosmetics
	var string CosmeticType;

	// For ordering crafting
	var int CraftingType;
	var int CraftingRarity;
	var int CraftingTicketType;

	// For ordering items
	var bool IsKey;
};

struct WeaponSkinListCacheState
{
	var array<InventoryHelper> SearchCache;

	var array<InventoryHelper> OrderedCache;

	var bool NeedToRegenerate;

	var EInventoryWeaponType_Filter WeaponTypeFilter;
	var int PerkIndexFilter;
	var ItemRarity RarityFilter;

	structdefaultproperties
	{
		NeedToRegenerate = false

		WeaponTypeFilter = EInvWT_None
		PerkIndexFilter = 0
		RarityFilter = ITR_NONE
	}
};

var WeaponSkinListCacheState WeaponSkinListCache;

var array<InventoryHelper> CosmeticSkinListSearchCache;

var array<InventoryHelper> CraftingListSearchCache;

var array<InventoryHelper> ItemListSearchCache;

struct ByTypeItemsHelper
{
  var() array<InventoryHelper> ItemsOnType;
};

var ByTypeItemsHelper ByTypeItems[7];

var EInventoryWeaponType_Filter CurrentWeaponTypeFilter;
var int CurrentPerkIndexFilter;
var ItemRarity CurrentRarityFilter;

var EINventory_Filter CurrentInventoryFilter;

var ExchangeRuleSets RuleToExchange;

var private int CrcTable[256];

var transient string SearchKeyword;

function InitializeMenu( KFGFxMoviePlayer_Manager InManager )
{
	super.InitializeMenu( InManager );

	CrcInit();

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

final function CrcInit() {
 
  const CrcPolynomial = 0xedb88320;
 
  local int CrcValue;
  local int IndexBit;
  local int IndexEntry;
 
  for (IndexEntry = 0; IndexEntry < 256; IndexEntry++) {
    CrcValue = IndexEntry;
 
    for (IndexBit = 8; IndexBit > 0; IndexBit--)
      if ((CrcValue & 1) != 0)
        CrcValue = (CrcValue >>> 1) ^ CrcPolynomial;
      else
        CrcValue = CrcValue >>> 1;
 
    CrcTable[IndexEntry] = CrcValue;
    }
  }

final function int Crc(coerce string Text)
{
  local int CrcValue;
  local int IndexChar;
  local int StrLen;
 
  CrcValue = 0xffffffff;
  StrLen = Len(Text);
  for (IndexChar = 0; IndexChar < StrLen; IndexChar++)
    CrcValue = (CrcValue >>> 8) ^ CrcTable[(Asc(Mid(Text, IndexChar, 1)) ^ CrcValue) & 0xff];
 
  return CrcValue;
}

delegate int SortWeaponSkinList(InventoryHelper A, InventoryHelper B)
{
	/** Format: Compare lower ? -1 : (Compare upper) : 1 : (Equal case, repeat formula with the next sort condition)  */
	return  A.Price > B.Price ? -1 : (A.Price < B.Price ? 1 : (
				A.WeaponDef < B.WeaponDef ? -1 : (A.WeaponDef > B.WeaponDef ? 1 : (
					A.Rarity > B.Rarity ? -1 : (A.Rarity < B.Rarity ? 1 : (
						A.SkinType > B.SkinType ? -1 : (A.SkinType < B.SkinType ? 1 : (
							A.Quality < B.Quality ? -1 : 1
						))
					))
				))
	));
}

delegate int SortCosmeticsList(InventoryHelper A, InventoryHelper B)
{
	/** Format: Compare lower ? -1 : (Compare upper) : 1 : (Equal case, repeat formula with the next sort condition)  */
	return  A.CosmeticType > B.CosmeticType ? -1 : (A.CosmeticType < B.CosmeticType ? 1 : (
				A.SkinType < B.SkinType ? -1 : (A.SkinType > B.SkinType ? 1 : (
					A.Rarity > B.Rarity ? -1 : (A.Rarity < B.Rarity ? 1 : 1)
				))
	));
}

delegate int SortCraftingList(InventoryHelper A, InventoryHelper B)
{
	/** Format: Compare lower ? -1 : (Compare upper) : 1 : (Equal case, repeat formula with the next sort condition)  */
	return  A.CraftingType > B.CraftingType ? -1 : (A.CraftingType < B.CraftingType ? 1 : (
				A.CraftingRarity > B.CraftingRarity ? -1 : (A.CraftingRarity < B.CraftingRarity ? 1 : (
					A.CraftingTicketType > B.CraftingTicketType ? -1 : (A.CraftingTicketType < B.CraftingTicketType ? 1 : 1)
				))
	));
}

delegate int SortItemList(InventoryHelper A, InventoryHelper B)
{
	if (A.IsKey && B.IsKey)
	{
		return 0;
	}

	if (A.IsKey == false && B.IsKey == false)
	{
		return 0;
	}

	if (A.IsKey)
	{
		return 1;
	}

	return -1;
}

function InitInventory()
{
	local int i, j, z, ItemIndex, HelperIndex, ItemID, SearchIndex;
	local ItemProperties TempItemDetailsHolder;
	local GFxObject ItemArray, ItemObject;
	local bool bActiveItem;
	local InventoryHelper HelperItem;
	local array<ExchangeRuleSets> ExchangeRules;
	local class<KFWeaponDefinition> WeaponDef;
	local string SkinType, CosmeticType, KeyType;

	local GFxObject PendingItem;

	for (i = 0; i < ArrayCount(ByTypeItems); ++i)
	{
		ByTypeItems[i].ItemsOnType.Length = 0;
	}

	ItemArray = CreateArray();

	if(OnlineSub == none)
	{
		// If there is no OnlineSubsystem just send an empty array.  HSL_BB
		SetObject("inventoryList", ItemArray);
		return;
	}

	// While reading from the profile we also order by type, then we might want to order again some stuff that's inside the same item type later

	//`Log("NEW MENU OPEN: " $CurrentInventoryFilter);

	for (i = 0; i < OnlineSub.CurrentInventory.length; i++)
	{
		//look item up to get info on it.
		ItemIndex = OnlineSub.ItemPropertiesList.Find('Definition', OnlineSub.CurrentInventory[i].Definition);

		// BWJ - 12-21-16 - Hide items that have no definition
		if(ItemIndex != INDEX_NONE && OnlineSub.CurrentInventory[i].Definition != 0 )
		{
			TempItemDetailsHolder = OnlineSub.ItemPropertiesList[ItemIndex];

			if (((CurrentInventoryFilter == EInv_All || Int(CurrentInventoryFilter) == Int(TempItemDetailsHolder.Type))
					&& DoesMatchFilter(TempItemDetailsHolder))
				|| bool(OnlineSub.CurrentInventory[i].NewlyAdded))
			{
				ItemObject 	= CreateObject("Object");
				HelperIndex = ByTypeItems[TempItemDetailsHolder.Type].ItemsOnType.Find('ItemDefinition', onlineSub.CurrentInventory[i].Definition);

				if (HelperIndex == INDEX_NONE)
				{
					HelperItem.Type				= TempItemDetailsHolder.Type;
					HelperItem.FullName			= TempItemDetailsHolder.Name;
					HelperItem.ItemDefinition 	= onlineSub.CurrentInventory[i].Definition;
					HelperItem.ItemCount 		= onlineSub.CurrentInventory[i].Quantity;

					if (TempItemDetailsHolder.Type == ITP_WeaponSkin)
					{
						HelperItem.Rarity 		= TempItemDetailsHolder.Rarity;
						HelperItem.Quality 		= TempItemDetailsHolder.Quality;

						if (bool(OnlineSub.CurrentInventory[i].NewlyAdded))
						{
							WeaponSkinListCache.NeedToRegenerate = true;
						}

						// Now find the name of the weapon skin

						// Search on the cache, to speed up
						ItemID = WeaponSkinListCache.SearchCache.Find('ItemDefinition', HelperItem.ItemDefinition);

						if (ItemID != INDEX_NONE)
						{
							HelperItem.WeaponDef 	= WeaponSkinListCache.SearchCache[ItemID].WeaponDef;
							HelperItem.Price 		= WeaponSkinListCache.SearchCache[ItemID].Price;
							HelperItem.SkinType 	= WeaponSkinListCache.SearchCache[ItemID].SkinType;
						}
						else
						{
							// Skin Type

							// Get right part of the string without from the first "| "
							SearchIndex 			= InStr(TempItemDetailsHolder.Name, "|");
							SkinType 				= Right(TempItemDetailsHolder.Name, Len(TempItemDetailsHolder.Name) - SearchIndex - 2);

							// Get the left part of the string without the next "| "
							SearchIndex				= InStr(SkinType, "|");
							// Store as CRC, that speeds up comparisons later
							HelperItem.SkinType 	= CrC(Left(SkinType, SearchIndex));

							ItemID = class'KFWeaponSkinList'.default.Skins.Find('Id', HelperItem.ItemDefinition);

							if (ItemID != INDEX_NONE)
							{
								WeaponDef = class'KFWeaponSkinList'.default.Skins[ItemID].WeaponDef;

								// All Weapons start by KFGameContent.KFWeap_ Skip that prefix.
								// Store as CRC, that speeds up comparisons later
								HelperItem.WeaponDef 	= CrC(Mid(WeaponDef.default.WeaponClassPath, 21));
								HelperItem.Price 		= WeaponDef.default.BuyPrice;
							}
							else
							{
								HelperItem.WeaponDef	= -1;
								HelperItem.Price 		= 0;
							}

							WeaponSkinListCache.SearchCache.AddItem(HelperItem);
						}
					}
					else if (TempItemDetailsHolder.Type == ITP_CharacterSkin)
					{
						// Search on the cache, to speed up
						ItemID = CosmeticSkinListSearchCache.Find('ItemDefinition', HelperItem.ItemDefinition);

						if (ItemID != INDEX_NONE)
						{
							HelperItem.Rarity 		= CosmeticSkinListSearchCache[ItemID].Rarity;
							HelperItem.CosmeticType = CosmeticSkinListSearchCache[ItemID].CosmeticType;
							HelperItem.SkinType 	= CosmeticSkinListSearchCache[ItemID].SkinType;
						}
						else
						{
							HelperItem.Rarity = TempItemDetailsHolder.Rarity;

							// Cosmetic Type

							// Get left part of the string from the first "| "
							SearchIndex = InStr(TempItemDetailsHolder.Name, "|");

							// If we can't find the substring the equipment doesn't fit the pattern, we use the whole string as Cosmetic Type
							if (SearchIndex < 0)
							{
								CosmeticType 			= TempItemDetailsHolder.Name;
								HelperItem.CosmeticType = CosmeticType;

								HelperItem.SkinType 	= 0;
							}
							else
							{
								CosmeticType 			= Left(TempItemDetailsHolder.Name, SearchIndex);
								HelperItem.CosmeticType = CosmeticType;

								// Skin Type

								// Get right part of the string without from the first "| "
								SearchIndex 			= InStr(TempItemDetailsHolder.Name, "|");
								SkinType 				= Right(TempItemDetailsHolder.Name, Len(TempItemDetailsHolder.Name) - SearchIndex - 2);

								// Get the left part of the string without the next "| "
								SearchIndex				= InStr(SkinType, "|");
								SkinType				= Left(SkinType, SearchIndex);

								// Store as CRC, that speeds up comparisons later
								HelperItem.SkinType 	= CrC(SkinType);
							}

							CosmeticSkinListSearchCache.AddItem(HelperItem);
						}
					}
					else if (TempItemDetailsHolder.Type == ITP_CraftingComponent)
					{
						ItemId = CraftingListSearchCache.Find('ItemDefinition', HelperItem.ItemDefinition);

						if (ItemID != INDEX_NONE)
						{
							HelperItem.CraftingType 		= CraftingListSearchCache[ItemID].CraftingType;
							HelperItem.CraftingRarity 		= CraftingListSearchCache[ItemID].CraftingRarity;
							HelperItem.CraftingTicketType 	= CraftingListSearchCache[ItemID].CraftingTicketType;
						}
						else
						{
							HelperItem.CraftingType = 999;
							HelperItem.CraftingRarity = 999;
							HelperItem.CraftingTicketType = 0;

							// We don't have information to stick to.. so we have to search on the Name.. we use KeyName, as it contains the unmodified language Key

							// Type

							SearchIndex = InStr(TempItemDetailsHolder.KeyName, ":");

							KeyType	= Left(TempItemDetailsHolder.KeyName, SearchIndex);

							SearchIndex = InStr(KeyType, "CosmeticMaterial");
							if (SearchIndex != -1)
							{
								HelperItem.CraftingType = 0;
							}
							else
							{
								SearchIndex = InStr(KeyType, "WeaponSkinMaterial");
								if (SearchIndex != -1)
								{
									HelperItem.CraftingType = 1;
								}
								else
								{
									SearchIndex = InStr(KeyType, "VaultCraftingMaterial");
									if (SearchIndex != -1)
									{
										HelperItem.CraftingType = 2;
									}
								}
							}

							// Rarity

							SearchIndex = InStr(KeyType, "Uncommon");
							if (SearchIndex != -1)
							{
								HelperItem.CraftingRarity = 1;
							}
							else
							{
								SearchIndex = InStr(KeyType, "Common");
								if (SearchIndex != -1)
								{
									HelperItem.CraftingRarity = 0;
								}
								else
								{
									SearchIndex = InStr(KeyType, "Rare");
									if (SearchIndex != -1)
									{
										HelperItem.CraftingRarity = 2;
									}
									else
									{
										SearchIndex = InStr(KeyType, "Exceptional");
										if (SearchIndex != -1)
										{
											HelperItem.CraftingRarity = 3;
										}								
									}
								}
							}

							// Ticket Type

							SearchIndex = InStr(KeyType, "CyberPunk");
							if (SearchIndex != -1)
							{
								HelperItem.CraftingTicketType = 0;
							}
							else
							{
								SearchIndex = InStr(KeyType, "Sideshow");
								if (SearchIndex != -1)
								{
									HelperItem.CraftingTicketType = 1;
								}
								else
								{
									SearchIndex = InStr(KeyType, "Hllwn");
									if (SearchIndex != -1)
									{
										HelperItem.CraftingTicketType = 2;
									}
									else
									{
										SearchIndex = InStr(KeyType, "Christmas");
										if (SearchIndex != -1)
										{
											HelperItem.CraftingTicketType = 3;
										}
									}									
								}
							}

							CraftingListSearchCache.AddItem(HelperItem);
						}
					}
					else if (TempItemDetailsHolder.Type == ITP_KeyCrate)
					{
						ItemId = ItemListSearchCache.Find('ItemDefinition', HelperItem.ItemDefinition);

						if (ItemID != INDEX_NONE)
						{
							HelperItem.IsKey = ItemListSearchCache[ItemID].IsKey;
						}
						else
						{
							// We have to distinguish if the Item is a KEY or not, we use KeyName, as it contains the unmodified language Key

							// KeyName is something like : "NameItem:KeyCrate", we first remove the part from the : to the right
							SearchIndex 		= InStr(TempItemDetailsHolder.KeyName, ":");
							KeyType			 	= Left(TempItemDetailsHolder.KeyName, SearchIndex);

							// Then we search if the name of the Item contains "Key"
							SearchIndex 		= InStr(KeyType, "Key");

							if (SearchIndex != -1)
							{
								HelperItem.IsKey = true;
							}
							else
							{
								HelperItem.IsKey = false;
							}

							ItemListSearchCache.AddItem(HelperItem);
						}
					}

					ByTypeItems[TempItemDetailsHolder.Type].ItemsOnType.AddItem(HelperItem);
					HelperIndex = ByTypeItems[TempItemDetailsHolder.Type].ItemsOnType.Length - 1;
				}
				else
				{
					ByTypeItems[TempItemDetailsHolder.Type].ItemsOnType[HelperIndex].ItemCount += onlineSub.CurrentInventory[i].Quantity;
				}

				OnlineSub.IsExchangeable(onlineSub.CurrentInventory[i].Definition, ExchangeRules);

				ItemObject.SetInt("count", ByTypeItems[TempItemDetailsHolder.Type].ItemsOnType[HelperIndex].ItemCount);
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

				ByTypeItems[TempItemDetailsHolder.Type].ItemsOnType[HelperIndex].GfxItemObject = ItemObject;

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

	if (CurrentInventoryFilter == EInv_All || CurrentInventoryFilter == EInv_WeaponSkins)
	{
		// If need to refresh... we regenerate the list, if not reuse our Cache

		if (WeaponSkinListCache.NeedToRegenerate
			|| WeaponSkinListCache.WeaponTypeFilter != CurrentWeaponTypeFilter
			|| WeaponSkinListCache.PerkIndexFilter != CurrentPerkIndexFilter
			|| WeaponSkinListCache.RarityFilter != CurrentRarityFilter
			|| ByTypeItems[ITP_WeaponSkin].ItemsOnType.Length != WeaponSkinListCache.OrderedCache.Length)
		{
			WeaponSkinListCache.NeedToRegenerate = false;

			WeaponSkinListCache.WeaponTypeFilter = CurrentWeaponTypeFilter;
			WeaponSkinListCache.PerkIndexFilter = CurrentPerkIndexFilter;
			WeaponSkinListCache.RarityFilter = CurrentRarityFilter;

			// We want to order by Price - Weapon Def - Rarity - Quality

			ByTypeItems[ITP_WeaponSkin].ItemsOnType.Sort(SortWeaponSkinList);

			WeaponSkinListCache.OrderedCache = ByTypeItems[ITP_WeaponSkin].ItemsOnType;

			/*`Log("----------");

			for (i = 0 ; i < ByTypeItems[ITP_WeaponSkin].ItemsOnType.Length; i++)
			{
				`Log("ID : " $ByTypeItems[ITP_WeaponSkin].ItemsOnType[i].ItemDefinition);
				`Log("Weapon Def : " $ByTypeItems[ITP_WeaponSkin].ItemsOnType[i].WeaponDef);
				`Log("Price : " $ByTypeItems[ITP_WeaponSkin].ItemsOnType[i].Price);
				`Log("Full Name : " $ByTypeItems[ITP_WeaponSkin].ItemsOnType[i].FullName);
				`Log("Skin : " $ByTypeItems[ITP_WeaponSkin].ItemsOnType[i].SkinType);
				`Log("Rarity : " $ByTypeItems[ITP_WeaponSkin].ItemsOnType[i].Rarity);
				`Log("Quality : " $ByTypeItems[ITP_WeaponSkin].ItemsOnType[i].Quality);
				`Log("----------");
			}

			`Log("----------");*/
		}
		else
		{
			//`Log("USING SKIN LIST CACHE!!!");

			ByTypeItems[ITP_WeaponSkin].ItemsOnType = WeaponSkinListCache.OrderedCache;
		}
	}

	if (CurrentInventoryFilter == EInv_All || CurrentInventoryFilter == EInv_Cosmetics)
	{
		ByTypeItems[ITP_CharacterSkin].ItemsOnType.Sort(SortCosmeticsList);

		/*`Log("----------");

		for (i = 0 ; i < ByTypeItems[ITP_CharacterSkin].ItemsOnType.Length; i++)
		{
			`Log("Cosmetic Name : " $ByTypeItems[ITP_CharacterSkin].ItemsOnType[i].CosmeticType);
			`Log("Skin : " $ByTypeItems[ITP_CharacterSkin].ItemsOnType[i].SkinType);
			`Log("Rarity : " $ByTypeItems[ITP_CharacterSkin].ItemsOnType[i].Rarity);			
			`Log("----------");
		}

		`Log("----------");*/
	}

	if (CurrentInventoryFilter == EInv_All || CurrentInventoryFilter == EInv_CraftingMats)
	{
		ByTypeItems[ITP_CraftingComponent].ItemsOnType.Sort(SortCraftingList);

		/*`Log("----------");

		for (i = 0 ; i < ByTypeItems[ITP_CraftingComponent].ItemsOnType.Length; i++)
		{
			`Log("Crafting Type : " $ByTypeItems[ITP_CraftingComponent].ItemsOnType[i].CraftingType);
			`Log("Rarity : " $ByTypeItems[ITP_CraftingComponent].ItemsOnType[i].CraftingRarity);
			`Log("Ticket Type : " $ByTypeItems[ITP_CraftingComponent].ItemsOnType[i].CraftingTicketType);			
			`Log("----------");
		}

		`Log("----------");*/
	}

	if (CurrentInventoryFilter == EInv_All || CurrentInventoryFilter == EInv_Consumables)
	{
		// Consumables is the type for the "Items" category on the UI
		ByTypeItems[ITP_KeyCrate].ItemsOnType.Sort(SortItemList);

		/*`Log("----------");

		for (i = 0 ; i < ByTypeItems[ITP_KeyCrate].ItemsOnType.Length; i++)
		{
			`Log("Is Key : " $ByTypeItems[ITP_KeyCrate].ItemsOnType[i].IsKey);
			`Log("----------");
		}

		`Log("----------");*/
	}

	//`Log("--------------------------------");

	z = 0;

	if (SearchKeyword != "")
	{
		InventorySearch(SearchKeyword);
	}
	else
	{
		for (i = 0; i < ArrayCount(ByTypeItems); i++)
		{
			for (j = 0 ; j < ByTypeItems[i].ItemsOnType.Length; j++)
			{
				ItemArray.SetElementObject(z, ByTypeItems[i].ItemsOnType[j].GfxItemObject);

				++z;
			}
		}
		
		SetObject("inventoryList", ItemArray);
	}

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

	WeaponSkinListCache.NeedToRegenerate = true;
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
		if (class'KFWeaponSkinList'.Static.IsSkinEquip(WeaponDef, ItemDefinition))
		{
			return true;
		}
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

	LocalizedObject.SetString("searchTitle",                SearchText);
	LocalizedObject.SetString("searchText",                 SearchText$"...");

	LocalizedObject.SetBool("bIsConsoleBuild", 				class'WorldInfo'.static.IsConsoleBuild());
	LocalizedObject.SetInt("searchMaxChars",                SearchMaxChars);

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

function Callback_InventorySearch(string searchStr)
{
	InventorySearch(searchStr, true);
}

function Callback_Log(string str)
{
	`Log("From AS: " $str);
}

function Callback_OpenKeyboard()
{
	OnlineSub = Class'GameEngine'.static.GetOnlineSubsystem();
	OnlineSub.PlayerInterface.AddKeyboardInputDoneDelegate(KeyboardInputComplete);
	OnlineSub.PlayerInterface.ShowKeyboardUI(0, "Search", "Search");
}

function KeyboardInputComplete(bool bWasSuccessful)
{
	local byte bWasCancelled;
	local string UserInput;

	OnlineSub = Class'GameEngine'.static.GetOnlineSubsystem();
	UserInput = OnlineSub.PlayerInterface.GetKeyboardInputResults(bWasCancelled);

	Callback_InventorySearch(UserInput);

	OnlineSub.PlayerInterface.ClearKeyboardInputDoneDelegate(KeyboardInputComplete);
}

function InventorySearch(string searchStr, bool bForceInitIfClear = false)
{
	local array<ItemType> ItemTypes;
	local int i, j, k, ItemCounter;
	local array<InventoryHelper> ItemsOnType;
	local GFxObject ItemArray;
	local array<string> SearchKeywords;
	local bool Accepted;

	SearchKeyword = searchStr;

	if (searchStr == "")
	{
		if (bForceInitIfClear)
		{
			InitInventory();
		}

		return;
	}

	SearchKeywords = SplitString( searchStr, " ", true);

	ItemCounter = 0;

	ItemArray = CreateArray();

	if (CurrentInventoryFilter == EInv_All || CurrentInventoryFilter == EInv_WeaponSkins)
	{
		ItemTypes.AddItem(ITP_WeaponSkin);
	}

	if (CurrentInventoryFilter == EInv_All || CurrentInventoryFilter == EInv_Cosmetics)
	{
		ItemTypes.AddItem(ITP_CharacterSkin);
	}

	if (CurrentInventoryFilter == EInv_All || CurrentInventoryFilter == EInv_Consumables)
	{
		ItemTypes.AddItem(ITP_KeyCrate);
	}

	if (CurrentInventoryFilter == EInv_All || CurrentInventoryFilter == EInv_CraftingMats)
	{
		ItemTypes.AddItem(ITP_CraftingComponent);
	}

	if (CurrentInventoryFilter == EInv_All || CurrentInventoryFilter == EInv_Emotes)
	{
		ItemTypes.AddItem(ITP_Emote);
	}

	if (CurrentInventoryFilter == EInv_All || CurrentInventoryFilter == EInv_SFX)
	{
		ItemTypes.AddItem(ITP_SFX);
	}

	for (i = 0; i < ItemTypes.Length; ++i)
	{
		ItemsOnType = ByTypeItems[ItemTypes[i]].ItemsOnType;
		for (j = 0; j < ItemsOnType.Length; ++j)
		{
			Accepted = true;
			for (k = 0; k < SearchKeywords.Length; ++k)
			{
				if (InStr(Locs(ItemsOnType[j].FullName), Locs(SearchKeywords[k])) == -1)
				{
					Accepted = false;
					break;
				}
			}

			if (Accepted)
			{
				ItemArray.SetElementObject(ItemCounter, ItemsOnType[j].GfxItemObject);
				++ItemCounter;
			}
		}
	}

	SetObject("inventoryList", ItemArray);
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
	WeaponSkinListCache.NeedToRegenerate = true; // need to regenerate as the equipped state changed

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

	SearchMaxChars=128
}