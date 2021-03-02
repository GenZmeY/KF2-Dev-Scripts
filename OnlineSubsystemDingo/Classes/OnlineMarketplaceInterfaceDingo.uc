/**
 * Class that implements a Dingo version of the Marketplace interface
 */
 class OnlineMarketplaceInterfaceDingo extends Object within OnlineSubsystemDingo
	native
	implements(OnlineMarketplaceInterface);

/** The owning subsystem that this object is providing an implementation for */
var OnlineSubsystemDingo OwningSubsystem;

/** Since the static array of dynamic array syntax appears to be broken */
struct native PerUserMarketplaceDelegates
{
	/** the array of delegates for notifying when an available product read has completed */
	var array<delegate<OnReadAvailableProductsComplete> > AvailableProductReadDelegates;
	/** the array of delegates for notifying when an additional product detail read has completed */
	var array<delegate<OnReadAdditionalProductDetailsComplete> > AdditionalProductDetailsReadDelegates;
	/** the array of delegates for notifying when an inventory read has completed */
	var array<delegate<OnReadInventoryItemsComplete> > InventoryItemReadDelegates;
	/** the array of delegates for notifying when an inventory consume request has completed */
	var array<delegate<OnConsumeInventoryItemComplete> > ConsumeInventoryItemDelegates;
};

/** Per user array of array of delegates */
var PerUserMarketplaceDelegates PerUserDelegates[`MAX_NUM_PLAYERS];

/** Holds the cached marketplace products for a single player */
struct native CachedMarketplaceProducts
{
	/** The list of products for this player */
	var init array<MarketplaceProductDetails> Products;
	/** Indicates the state of the async read */
	var EOnlineEnumerationReadState ReadState;

	structcpptext
	{
		FCachedMarketplaceProducts () : ReadState(OERS_NotStarted) {}
	}
};

struct native UserMarketplaceCache
{
	var CachedMarketplaceProducts ProductCaches[EMediaItemType.MIT_MAX];
};

/** Holds the cached list of marketplace products that have been read */
var native map{QWORD, FUserMarketplaceCache} MarketplaceProductsCache;

/** Holds the cached inventory items for a single player */
struct native CachedInventoryItems
{
	/** The inventory for this player */
	var init array<MarketplaceInventoryItem> Items;
	/** The native WinRT items used to consume inventory items */
	var native pointer PlatformItems{TWinRTObject<Windows::Foundation::Collections::IVectorView<Microsoft::Xbox::Services::Marketplace::InventoryItem^> >};
	/** Indicates the state of the async read */
	var EOnlineEnumerationReadState ReadState;

	structcpptext
	{
		FCachedInventoryItems ()
		: PlatformItems(NULL)
		, ReadState(OERS_NotStarted) {}

		~FCachedInventoryItems()
		{
			if (PlatformItems != NULL)
			{
				delete PlatformItems;
			}
		}
	}
};

struct native UserInventoryCache
{
	var CachedInventoryItems InventoryCaches[EMediaItemType.MIT_MAX];
};

/** Holds the cached player inventories that have been read */
var native map{QWORD, FUserInventoryCache} InventoryItemsCache;

var array<delegate<OnMarketplaceItemPurchased> > OnMarketplaceItemPurchasedDelegates;

/** How many consumables and durables are for sale. MUST BE UPDATED EACH UPDATE. */
var int ConsumablesCount;
var int DurablesCount;

/**
 * Starts an async read of all available products
 *
 * @param LocalUserNum - the controller number of the associated user
 * @param ParentId - if not empty, read products who are children of this product id
 * @param ParentMediaType - if set, read products who are children of products of this type
 * @param ChildMediaType - if set, read products who are parents of products of this type
 * @param SortOrder - what order to sort the returned products in
 */
native function bool ReadAvailableProducts(byte LocalUserNum, string ParentId, optional EMediaItemType ParentMediaType = MIT_Game, optional EMediaItemType ChildMediaType = MIT_Game, optional ECatalogSortOrder SortOrder = CSO_FreeAndPaidCountDaily);

/**
 * Called when the async product read for the given media type has completed
 */
delegate OnReadAvailableProductsComplete(EMediaItemType MediaType);

/**
 * Sets the delegate used to notify the gameplay code that the product read request has completed
 */
function AddReadAvailableProductsCompleteDelegate(byte LocalUserNum, delegate<OnReadAvailableProductsComplete> ReadAvailableProductsCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		`AddUniqueItemToArray(PerUserDelegates[LocalUserNum].AvailableProductReadDelegates, ReadAvailableProductsCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to AddReadAvailableProductsCompleteDelegate()");
	}
}

/**
 * Clears the delegate used to notify the gameplay code that the product read request has completed
 */
function ClearReadAvailableProductsCompleteDelegate(byte LocalUserNum, delegate<OnReadAvailableProductsComplete> ReadAvailableProductsCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		PerUserDelegates[LocalUserNum].AvailableProductReadDelegates.RemoveItem(ReadAvailableProductsCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to ClearReadAvailableProductsCompleteDelegate()");
	}
}

/**
 * Copies the list of available products for the specified player
 *
 * @param LocalUserNum - the user to read the available products for
 * @param MediaType - the type of media to return products for
 * @param AvailableProducts - the out array that receives the copied data
 *
 * @return OERS_Done if the read has completed, otherwise one of the other states
 */
native function EOnlineEnumerationReadState GetAvailableProducts(byte LocalUserNum, EMediaItemType MediaType, out array<MarketplaceProductDetails> AvailableProducts);

/**
 * Resets the list of available products for the specified player
 *
 * @param LocalUserNum - the user to reset available products for
 * @param MediaType - the type of media to reset products for
 *
 */
native function ResetAvailableProducts(byte LocalUserNum, EMediaItemType MediaType);

/**
 * Starts an async read of additional product details
 *
 * @param LocalUserNum - the controller number of the associated user
 * @param MediaType - the type of media items to retrieve additional details for
 */
native function bool ReadAdditionalDetailsForProducts(byte LocalUserNum, EMediaItemType MediaType);

/**
 * Called when the async additional detail read for the given media type has completed
 */
delegate OnReadAdditionalProductDetailsComplete(EMediaItemType MediaType);

/**
 * Sets the delegate used to notify the gameplay code that the product additional detail read request has completed
 */
function AddReadAdditionalProductDetailsCompleteDelegate(byte LocalUserNum, delegate<OnReadAdditionalProductDetailsComplete> ReadAdditionalProductDetailsCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		`AddUniqueItemToArray(PerUserDelegates[LocalUserNum].AdditionalProductDetailsReadDelegates, ReadAdditionalProductDetailsCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to AddReadAdditionalProductDetailsCompleteDelegate()");
	}
}

/**
 * Clears the delegate used to notify the gameplay code that the product additional detail read request has completed
 */
function ClearReadAdditionalProductDetailsCompleteDelegate(byte LocalUserNum, delegate<OnReadAdditionalProductDetailsComplete> ReadAdditionalProductDetailCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		PerUserDelegates[LocalUserNum].AdditionalProductDetailsReadDelegates.RemoveItem(ReadAdditionalProductDetailCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to ClearReadAdditionalProductDetailsCompleteDelegate()");
	}
}

/**
 * Starts an async read of all inventory items for a given user and media type
 *
 * @param LocalUserNum - the controller number of the associated user
 * @param MediaType - media type of the inventory items to retrieve
 */
native function bool ReadInventoryItems(byte LocalUserNum, optional EMediaItemType MediaType = MIT_GameConsumable);

/**
 * Called when the async inventory read has completed
 */
delegate OnReadInventoryItemsComplete(EMediaItemType MediaType);

/**
 * Sets the delegate used to notify the gameplay code that the inventory read request has completed
 */
function AddReadInventoryItemsCompleteDelegate(byte LocalUserNum, delegate<OnReadInventoryItemsComplete> ReadInventoryItemsCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		`AddUniqueItemToArray(PerUserDelegates[LocalUserNum].InventoryItemReadDelegates, ReadInventoryItemsCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to AddReadInventoryItemsCompleteDelegate()");
	}
}

/**
 * Clears the delegate used to notify the gameplay code that the inventory read request has completed
 */
function ClearReadInventoryItemsCompleteDelegate(byte LocalUserNum, delegate<OnReadInventoryItemsComplete> ReadInventoryItemsCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		PerUserDelegates[LocalUserNum].InventoryItemReadDelegates.RemoveItem(ReadInventoryItemsCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to ClearReadInventoryItemsCompleteDelegate()");
	}
}

/**
 * Copies the list of inventory items for the specified player
 *
 * @param LocalUserNum - the user to read the inventory for
 * @param MediaType - the type of inventory item to read
 * @param AvailableProducts - the out array that receives the copied data
 *
 * @return OERS_Done if the read has completed, otherwise one of the other states
 */
native function EOnlineEnumerationReadState GetInventoryItems(byte LocalUserNum, EMediaItemType MediaType, out array<MarketplaceInventoryItem> InventoryItems);

/**
 * Resets the list of inventory items for the specified player
 *
 * @param LocalUserNum - the user to reset inventory items for
 * @param MediaType - the type of inventory items to reset
 *
 */
native function ResetInventoryItems(byte LocalUserNum, EMediaItemType MediaType);

/**
 * Consumes the given number of inventory items, if able
 *
 * @param LocalUserNum - the user to consume items for
 * @param ProductId - the product identifier of the item to consume
 * @param Quantity - the number of items to consume
 * @param TransactionId - the transaction id of this consume request (NOTE: this needs to be unique to this request)
 */
native function bool ConsumeInventoryItem(byte LocalUserNum, string ProductId, int Quantity, string TransactionId);

/*
 * Called when the async consume request completes
 */
delegate OnConsumeInventoryItemComplete(string ProductId, bool bDidSucceed, int NewQuantity);

/**
 * Sets the delegate used to notify the gameplay code that the inventory consume request has completed
 */
function AddConsumeInventoryItemCompleteDelegate(byte LocalUserNum, delegate<OnConsumeInventoryItemComplete> ConsumeInventoryItemCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		`AddUniqueItemToArray(PerUserDelegates[LocalUserNum].ConsumeInventoryItemDelegates, ConsumeInventoryItemCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to AddConsumeInventoryItemCompleteDelegate()");
	}
}

/**
 * Clears the delegate used to notify the gameplay code that the inventory consume request has completed
 */
function ClearConsumeInventoryItemCompleteDelegate(byte LocalUserNum, delegate<OnConsumeInventoryItemComplete> ConsumeInventoryItemCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		PerUserDelegates[LocalUserNum].ConsumeInventoryItemDelegates.RemoveItem(ConsumeInventoryItemCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to ClearConsumeInventoryItemCompleteDelegate()");
	}
}

delegate OnMarketplaceItemPurchased();

function AddMarketplaceItemPurchasedDelegate( delegate<OnMarketplaceItemPurchased> InDelegate )
{
    `AddUniqueItemToArray(OnMarketplaceItemPurchasedDelegates, InDelegate);
}

function ClearMarketplaceItemPurchasedDelegate( delegate<OnMarketplaceItemPurchased> InDelegate )
{
    OnMarketplaceItemPurchasedDelegates.RemoveItem(InDelegate);
}

cpptext
{
	/* Finds the cached marketplace products for this player. If not found,
	 * it creates an empty one with the state to OERS_NotStarted
	 *
	 * @param PlayerNum the number of the player that the products are cached for
	 * @param MediaType the type of media item to retrieve
	 *
	 * @return The set of cached products for the player
	 */
	FCachedMarketplaceProducts& GetCachedMarketplaceProducts(DWORD PlayerNum, EMediaItemType MediaType);

	/* Finds the cached inventory items for this player. If not found,
	 * it creates an empty one with the state to OERS_NotStarted
	 *
	 * @param PlayerNum the number of the player that the inventory is cached for
	 * @param MediaType the type of inventory item to retrieve
	 *
	 * @return The set of cached inventory items for the player
	 */
	FCachedInventoryItems& GetCachedInventoryItems(DWORD PlayerNum, EMediaItemType MediaType);
}

defaultproperties
{
	// as of January 2021
	ConsumablesCount=80
	DurablesCount=54
}