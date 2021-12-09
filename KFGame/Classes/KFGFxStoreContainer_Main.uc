//=============================================================================
// KFGFxStoreContainer_Main
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Zane Gholson 9/18/2015
//=============================================================================

class KFGFxStoreContainer_Main extends KFGFxObject_Container;

var localized string WeaponSkinsRotationString;
var localized string WeaponSkinsString;
var localized string MarketConsumablesString;
var localized string MarketCosmeticsString;
var localized string MarketEmotesString;
var localized string LookUpOnMarketString;
var localized string ThankYouString;
var localized string FeaturedString;
var localized string MarketSFXString;
var localized string WeaponBundlesString;
var localized string CharacterBundlesString;
var localized string OutfitBundlesString;
var localized string TicketCratesUSBBundlesString;
var localized string CosmeticBundlesString;
var localized string WeaponSkinBundlesString;
var localized string HeadshotFxBundlesString;
var localized string SelectWeaponSkinsString;
var localized string SelectCosmeticsString;
var localized string SelectEmotesString;
var localized string SelectKeysAndTicketsString;

var array<int> FilterIndexConversion;
var array<int> ItemTypeIndexConversion;
var array<int> MarketItemTypeIndexConversion;

var array<string> XboxFilterExceptions;

var array<int> FeaturedItemIDs;
var array<int> ConsoleFeaturedItemIDs;

var int MaxFeaturedItems;

var KFGFxMenu_Store StoreMenu;

enum EStore_Filter
{
	EStore_WeaponBundles,			//EStore_WeaponSkins,
	EStore_CharactersBundles,		//EStore_Cosmetics,
	EStore_OutfitBundles,			//EStore_Consumables,
	EStore_TicketCratesUSBBundles,	//EStore_Items,
	EStore_CosmeticBundles,			//EStore_CraftingMats,
	EStore_WeaponSkinBundles,		//EStore_Emotes,
	EStore_HeadshotFXBundles,		//EStore_SFX,
	EStore_SelectWeaponSkins,		//EStore_Market_WeaponSkins,
	EStore_SelectCosmetics,			//EStore_Market_Cosmetics,
	EStore_SelectEmotes,			//EStore_Market_Items,
	EStore_SelectKeysAndTickets,	//EStore_Market_CraftingMats,
	EStore_MarketWeaponSkins,		//EStore_Market_Consumables,
	EStore_MarketCosmetics,			//EStore_Market_Emotes,
	EStore_MarketEmotes,			//EStore_Market_SFX,
	EStore_MarketCratesAndUSB,
	EStore_Featured,
	EStore_All,
	EStore_Max
};

var EStore_Filter CurrentStoreFilter;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
	super.Initialize( NewParentMenu );
	StoreMenu = KFGFxMenu_Store(NewParentMenu);
	LocalizeText();
	TweakFiltersVisibility(); //@SABER_EGS Hide Epic unrelated filters
}

function LocalizeText()
{
	local GFxObject LocalizedObject;

	LocalizedObject = CreateObject( "Object" );
	
	LocalizedObject.SetString("back", 				Class'KFCommon_LocalizedStrings'.default.BackString); 
	LocalizedObject.SetString("featured",			FeaturedString);
	LocalizedObject.SetString("all",				class'KFGFxMenu_Inventory'.default.AllString);

	LocalizedObject.SetString("weaponBundles",				WeaponBundlesString);
	LocalizedObject.SetString("characterBundles",			CharacterBundlesString);
	LocalizedObject.SetString("outfitBundles",				OutfitBundlesString);
	LocalizedObject.SetString("ticketCratesUSBBundles",		TicketCratesUSBBundlesString);
	LocalizedObject.SetString("cosmeticBundles",			CosmeticBundlesString);
	LocalizedObject.SetString("weaponSkinBundles",			WeaponSkinBundlesString);
	LocalizedObject.SetString("headshotFxBundles",			HeadshotFxBundlesString);
	LocalizedObject.SetString("selectWeaponSkins",			SelectWeaponSkinsString);
	LocalizedObject.SetString("selectCosmetics",			SelectCosmeticsString);
	LocalizedObject.SetString("selectEmotes",				SelectEmotesString);
	LocalizedObject.SetString("selectKeysAndTickets",		SelectKeysAndTicketsString);
	LocalizedObject.SetString("marketWeaponSkins",			WeaponSkinsString);
	LocalizedObject.SetString("marketCosmetics",			MarketCosmeticsString);
	LocalizedObject.SetString("marketEmotes",				MarketEmotesString);
	LocalizedObject.SetString("marketCratesAndUSBSs",		MarketConsumablesString);

	
	LocalizedObject.SetString("thankYouString",		ThankYouString);
	
	SetObject("localizedText", LocalizedObject);
}

//@SABER_EGS_BEGIN
function TweakFiltersVisibility()
{
	if (class'WorldInfo'.static.isEOSBuild())
	{
		// Hide Epic unrelated filters
		// Filter button names declared in StoreMainContainer.as

		//GetObject("featuredButton").SetVisible(true);
		//GetObject("allButton").SetVisible(true);

		//GetObject("weaponBundlesButton").SetVisible(true);
		//GetObject("characterBundlesButton").SetVisible(true);
		//GetObject("outfitBundlesButton").SetVisible(true);
		//GetObject("ticketCratesUSBBundlesButton").SetVisible(true);
		//GetObject("cosmeticBundlesButton").SetVisible(true);
		//GetObject("weaponSkinBundlesButton").SetVisible(true);
		//GetObject("headshotFxBundlesButton").SetVisible(true);

		GetObject("selectWeaponSkinsButton").SetVisible(false);
		GetObject("selectCosmeticsButton").SetVisible(false);
		GetObject("selectEmotesButton").SetVisible(false);
		GetObject("selectKeysAndTicketsButton").SetVisible(false);
		GetObject("marketWeaponSkinsButton").SetVisible(false);
		GetObject("marketCosmeticsButton").SetVisible(false);
		GetObject("marketEmotesButton").SetVisible(false);
		GetObject("marketCratesAndUSBsButton").SetVisible(false);
	}
}
//@SABER_EGS_END

function UpdateFilter(int NewFilterIndex)
{
	local EStore_Filter NewFilter;

	switch (NewFilterIndex)
	{
		case 0:			NewFilter = EStore_Featured;				break;
		case 1:			NewFilter = EStore_All;						break;
		case 2:			NewFilter = EStore_WeaponBundles;			break;
		case 3:			NewFilter = EStore_CharactersBundles;		break;
		case 4:			NewFilter = EStore_OutfitBundles;			break;
		case 5:			NewFilter = EStore_TicketCratesUSBBundles;	break;
		case 6:			NewFilter = EStore_CosmeticBundles;			break;
		case 7:			NewFilter = EStore_WeaponSkinBundles;		break;	
		case 8:			NewFilter = EStore_HeadshotFXBundles;		break;
		case 9:			NewFilter = EStore_SelectWeaponSkins;		break;
		case 10:		NewFilter = EStore_SelectCosmetics;			break;
		case 11:		NewFilter = EStore_SelectEmotes;			break;
		case 12:		NewFilter = EStore_SelectKeysAndTickets;	break;
		case 13:		NewFilter = EStore_MarketWeaponSkins;		break;
		case 14:		NewFilter = EStore_MarketCosmetics;			break;
		case 15:		NewFilter = EStore_MarketEmotes;			break;
		case 16:		NewFilter = EStore_MarketCratesAndUSB;		break;
	}

	if(CurrentStoreFilter != NewFilter)
	{
		CurrentStoreFilter = NewFilter;
		SendItems(StoreMenu.OnlineSub.ItemPropertiesList);
	}
}

function SendItems(const out Array<ItemProperties> StoreItemArray)
{
	local int i, ItemCount, j;
	local GFxObject DataProvider;
	local Array<ItemProperties> FilteredItemsArray;
	local ItemProperties TempItemProps; //since we can't push elements of an array
	local bool AlreadyFiltered;

	ItemCount = 0;
	DataProvider = CreateArray();
	
	for (i = 0; i < StoreItemArray.Length; i++)
	{
		// Hide console items
		if(StoreItemArray[i].ProductId != "" && StoreItemArray[i].SignedOfferId == "" && CurrentStoreFilter != EStore_Featured)
		{
			continue;
		}

		// Skip exceptions
		if(!IsItemValidForThisPlatform(StoreItemArray[i].Name))
		{
			continue;
		}

		if((CurrentStoreFilter > EStore_HeadshotFXBundles && CurrentStoreFilter < EStore_MarketWeaponSkins) || CurrentStoreFilter == EStore_All)
		{
			if(StoreItemArray[i].Price != "" && IsItemTypeIndexSame(StoreItemArray[i].Type, CurrentStoreFilter))
			{
				TempItemProps = StoreItemArray[i];
				FilteredItemsArray[ItemCount]=TempItemProps;
				ItemCount++;
			}
		}
		else if (CurrentStoreFilter == EStore_Featured)
		{
			if (class'WorldInfo'.static.IsConsoleBuild())
			{
				for (j = 0; j < ConsoleFeaturedItemIDs.length; j++)
				{
					if (StoreItemArray[i].Definition == ConsoleFeaturedItemIDs[j])
					{
						TempItemProps = StoreItemArray[i];
						FilteredItemsArray[ItemCount] = TempItemProps;
						ItemCount++;
					}
				}
			}
			else
			{
				for (j = 0; j < FeaturedItemIDs.length; j++)
				{
					if (StoreItemArray[i].Definition == FeaturedItemIDs[j])
					{
						TempItemProps = StoreItemArray[i];
						FilteredItemsArray[ItemCount] = TempItemProps;
						ItemCount++;
					}
				}
			}
		}
		else
		{
			AlreadyFiltered = false;
			if(StoreItemArray[i].FilterIdIndex > 0 && IsFilterIndexSame(StoreItemArray[i].FilterIdIndex, CurrentStoreFilter))
			{
				TempItemProps = StoreItemArray[i];
				FilteredItemsArray[ItemCount] = TempItemProps;
				ItemCount++;
				AlreadyFiltered = true;
			}

			if(!AlreadyFiltered && StoreItemArray[i].Price == "" && IsMarketItemTypeIndexSame(StoreItemArray[i].Type, CurrentStoreFilter) && StoreItemArray[i].Marketable)
			{
				TempItemProps = StoreItemArray[i];
				FilteredItemsArray[ItemCount] = TempItemProps;
				ItemCount++;
			}
		}		
	}

	ItemCount = 0;

	if (FilteredItemsArray.length > 0)
	{
		//too slow to sort all
		if (CurrentStoreFilter == EStore_All)
		{
			//filter by price high to low
			FilteredItemsArray.Sort(SortItemsByType);
		}
		else
		{
			//filter by price high to low
			FilteredItemsArray.Sort(SortItemsByPrice);
		}

		if (CurrentStoreFilter == EStore_Featured)
		{
			ShuffleFeaturedItems(FilteredItemsArray);
			//@SABER_EGS FilteredItemsArray.Length sometimes lesser MaxFeaturedItems. min prevent "array out of range" crash
			for (i = 0; i < min(MaxFeaturedItems, FilteredItemsArray.Length); i++)
			{
				DataProvider.SetElementObject(ItemCount, CreateStoreItem(FilteredItemsArray[i]));
				ItemCount++;
			}
		}
		else
		{
			for (i = 0; i < FilteredItemsArray.Length; i++)
			{
				DataProvider.SetElementObject(ItemCount, CreateStoreItem(FilteredItemsArray[i]));
				ItemCount++;
			}
		}
	}

	if (CurrentStoreFilter == EStore_Featured)
	{
		SetObject("storeItemFeaturedData", DataProvider);
	}
	else
	{
		SetObject("storeItemData", DataProvider);
	}
}

function ShuffleFeaturedItems(out Array<ItemProperties> FeaturedItemArray)
{
	local int CurrentIndex;
	local int RandomIndex;
	local ItemProperties TempValue;
	CurrentIndex = FeaturedItemArray.length;

	while (0 != CurrentIndex)
	{
		RandomIndex = Rand(FeaturedItemArray.length);
		CurrentIndex -= 1;

		TempValue = FeaturedItemArray[CurrentIndex];
		FeaturedItemArray[CurrentIndex] = FeaturedItemArray[RandomIndex];
		FeaturedItemArray[RandomIndex] = TempValue;
	}
}

delegate int SortItemsByType(ItemProperties A, ItemProperties B)
{
	return A.Type > B.Type? -1 : 0;
}

delegate int SortItemsByPrice(ItemProperties A, ItemProperties B)
{
	local string AString, BString;
	
	AString = Mid(A.Price, 1);
	BString = Mid(B.Price, 1);	
	return Int(AString) < Int(BString) ? -1 : 0;
}


function GFxObject CreateStoreItem(ItemProperties StoreItem)
{
	local GFxObject DataObject;

	DataObject = CreateObject( "Object" );
				
	DataObject.SetString("label", StoreItem.Name);
	DataObject.SetString("description", StoreItem.Description);
	//`log("Price"@StoreItem.Price@"- BasePrice"@StoreItem.BasePrice@"- DiscountRate"@StoreItem.DiscountRate@"- ItemOnSale"@StoreItem.ItemOnSale);

	if( StoreItem.ItemOnSale && StoreItem.BasePrice != StoreItem.Price)
	{
		DataObject.SetString("itemOnSale", StoreItem.ItemOnSale ? "1" : "0");
		DataObject.SetString("itemPriceBase", StoreItem.BasePrice);
		
		if(StoreItem.DiscountRate != "" && StoreItem.DiscountRate != "0")
		{
			DataObject.SetString("discountRate", StoreItem.DiscountRate);
		}
	}

	DataObject.SetString("price", class'WorldInfo'.static.IsConsoleBuild() ? "" : StoreItem.Price);
	DataObject.SetString("imageURL", "img://"$StoreItem.IconURL);
	DataObject.SetString("imageURLLarge", "img://"$StoreItem.IconURLLarge);
	DataObject.SetInt("SKU", StoreItem.Definition);

	return DataObject;
}

function bool IsItemTypeIndexSame(ItemType FirstType, EStore_Filter SecondType)
{	
	if (SecondType == EStore_All)
	{
		return true;
	}

	return ItemTypeIndexConversion[int(FirstType)] == int(SecondType);
}

function bool IsMarketItemTypeIndexSame(ItemType FirstType, EStore_Filter SecondType)
{	
	if (SecondType == EStore_All)
	{
		return true;
	}
	
	return MarketItemTypeIndexConversion[int(FirstType)] == int(SecondType);
}

function bool IsFilterIndexSame(int FilterIndexId, EStore_Filter SecondType)
{	
	if (SecondType == EStore_All)
	{
		return true;
	}

	return FilterIndexConversion[FilterIndexId] == int(SecondType);
}

function bool IsItemValidForThisPlatform(string ItemName)
{
	local int index;

	// Check only if the build runs in the Xbox
	if( class'WorldInfo'.static.IsConsoleBuild(CONSOLE_Durango) )
	{
		for(index = 0 ; index<XboxFilterExceptions.length ; index++)
		{
			// This item is not valid for Xbox
			if(XboxFilterExceptions[index] == ItemName)
			{
				return false;
			}
		}
	}

	return true;
}

DefaultProperties
{
	//defaults
	CurrentStoreFilter=EStore_Featured

	//GetStoreData parameter "tw_xtype" from Backend <-> EStore_Filter (KFGFxStoreContainer_Main)
	FilterIndexConversion[0]=-1 //None
	FilterIndexConversion[1]=0
	FilterIndexConversion[2]=1
	FilterIndexConversion[3]=2
	FilterIndexConversion[4]=3
	FilterIndexConversion[5]=5
	FilterIndexConversion[6]=6
	FilterIndexConversion[7]=4

	//ItemType (OnlineSubsystem) <-> EStore_Filter (KFGFxStoreContainer_Main)
	ItemTypeIndexConversion[0]=7 //None
	ItemTypeIndexConversion[1]=8
	ItemTypeIndexConversion[2]=10
	ItemTypeIndexConversion[3]=-1
	ItemTypeIndexConversion[4]=-1
	ItemTypeIndexConversion[5]=9
	ItemTypeIndexConversion[6]=-1
	ItemTypeIndexConversion[7]=-1 //None

	//ItemType (OnlineSubsystem) <-> EStore_Filter (KFGFxStoreContainer_Main). Market tabs.
	MarketItemTypeIndexConversion[0]=11 //None
	MarketItemTypeIndexConversion[1]=12
	MarketItemTypeIndexConversion[2]=-1
	MarketItemTypeIndexConversion[3]=-1
	MarketItemTypeIndexConversion[4]=14
	MarketItemTypeIndexConversion[5]=13
	MarketItemTypeIndexConversion[6]=-1
	MarketItemTypeIndexConversion[7]=-1 //None

	XboxFilterExceptions[0]="Wasteland Bundle" // Wasteland Outfit Bundle

	FeaturedItemIDs[0]=7944			//Whatsnew Gold Ticket
	FeaturedItemIDs[1]=9262
	FeaturedItemIDs[2]=9263
	FeaturedItemIDs[3]=9264
	FeaturedItemIDs[4]=9265
	FeaturedItemIDs[5]=9266
	FeaturedItemIDs[6]=9267

	ConsoleFeaturedItemIDs[0]=7947	//Whatsnew Gold Ticket PSN
	ConsoleFeaturedItemIDs[1]=9262
	ConsoleFeaturedItemIDs[2]=9263
	ConsoleFeaturedItemIDs[3]=9264
	ConsoleFeaturedItemIDs[4]=9265
	ConsoleFeaturedItemIDs[5]=9266
	ConsoleFeaturedItemIDs[6]=9267

	MaxFeaturedItems=5
}