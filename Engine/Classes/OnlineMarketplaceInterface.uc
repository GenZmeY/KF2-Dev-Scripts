/**
 * This interface provides accessors to the platform specific marketplace methods.
 */
interface OnlineMarketplaceInterface dependson(OnlineSubsystem);

/**
 * Starts an async read of all available products 
 *
 * @param LocalUserNum - the controller number of the associated user
 * @param ParentId - if not empty, read products who are children of this product id
 * @param ParentMediaType - if set, read products who are children of products of this type
 * @param ChildMediaType - if set, read products who are parents of products of this type
 * @param SortOrder - what order to sort the returned products in
 */
function bool ReadAvailableProducts(byte LocalUserNum, string ParentId, optional EMediaItemType ParentMediaType = MIT_Game, optional EMediaItemType ChildMediaType = MIT_Game, optional ECatalogSortOrder SortOrder = CSO_FreeAndPaidCountDaily);

/**
 * Called when the async product read for the given media type has completed
 */
delegate OnReadAvailableProductsComplete(EMediaItemType MediaType);

/**
 * Sets the delegate used to notify the gameplay code that the product read request has completed
 */
function AddReadAvailableProductsCompleteDelegate(byte LocalUserNum, delegate<OnReadAvailableProductsComplete> ReadAvailableProductsCompleteDelegate);

/**
 * Clears the delegate used to notify the gameplay code that the product read request has completed
 */
function ClearReadAvailableProductsCompleteDelegate(byte LocalUserNum, delegate<OnReadAvailableProductsComplete> ReadAvailableProductsCompleteDelegate);

/**
 * Copies the list of available products for the specified player
 *
 * @param LocalUserNum - the user to read the available products for
 * @param MediaType - the type of media to return products for
 * @param AvailableProducts - the out array that receives the copied data
 *
 * @return OERS_Done if the read has completed, otherwise one of the other states
 */
function EOnlineEnumerationReadState GetAvailableProducts(byte LocalUserNum, EMediaItemType MediaType, out array<MarketplaceProductDetails> AvailableProducts);

/**
 * Resets the list of available products for the specified player
 *
 * @param LocalUserNum - the user to reset available products for
 * @param MediaType - the type of media to reset products for
 *
 */
function ResetAvailableProducts(byte LocalUserNum, EMediaItemType MediaType);

/**
 * Starts an async read of additional product details
 *
 * @param LocalUserNum - the controller number of the associated user
 * @param MediaType - the type of media items to retrieve additional details for
 */
function bool ReadAdditionalDetailsForProducts(byte LocalUserNum, EMediaItemType MediaType);

/**
 * Called when the async additional detail read for the given media type has completed
 */
delegate OnReadAdditionalProductDetailsComplete(EMediaItemType MediaType);

/**
 * Sets the delegate used to notify the gameplay code that the product additional detail read request has completed
 */
function AddReadAdditionalProductDetailsCompleteDelegate(byte LocalUserNum, delegate<OnReadAdditionalProductDetailsComplete> ReadAdditionalProductDetailsCompleteDelegate);

/**
 * Clears the delegate used to notify the gameplay code that the product additional detail read request has completed
 */
function ClearReadAdditionalProductDetailsCompleteDelegate(byte LocalUserNum, delegate<OnReadAdditionalProductDetailsComplete> ReadAdditionalProductDetailsCompleteDelegate);

/**
 * Starts an async read of all inventory items for a given user and media type
 *
 * @param LocalUserNum - the controller number of the associated user
 * @param MediaType - media type of the inventory items to retrieve
 */
function bool ReadInventoryItems(byte LocalUserNum, optional EMediaItemType MediaType = MIT_GameConsumable);

/**
 * Called when the async inventory read has completed
 */
delegate OnReadInventoryItemsComplete(EMediaItemType MediaType);

/**
 * Sets the delegate used to notify the gameplay code that the inventory read request has completed
 */
function AddReadInventoryItemsCompleteDelegate(byte LocalUserNum, delegate<OnReadInventoryItemsComplete> ReadInventoryItemsCompleteDelegate);

/**
 * Clears the delegate used to notify the gameplay code that the inventory read request has completed
 */
function ClearReadInventoryItemsCompleteDelegate(byte LocalUserNum, delegate<OnReadInventoryItemsComplete> ReadInventoryItemsCompleteDelegate);

/**
 * Copies the list of inventory items for the specified player
 *
 * @param LocalUserNum - the user to read the inventory for
 * @param MediaType - the type of inventory item to read
 * @param AvailableProducts - the out array that receives the copied data
 *
 * @return OERS_Done if the read has completed, otherwise one of the other states
 */
function EOnlineEnumerationReadState GetInventoryItems(byte LocalUserNum, EMediaItemType MediaType, out array<MarketplaceInventoryItem> InventoryItems);

/**
 * Resets the list of inventory items for the specified player
 *
 * @param LocalUserNum - the user to reset inventory items for
 * @param MediaType - the type of inventory items to reset
 *
 */
function ResetInventoryItems(byte LocalUserNum, EMediaItemType MediaType);

/**
 * Consumes the given number of inventory items, if able
 *
 * @param LocalUserNum - the user to consume items for
 * @param ProductId - the product identifier of the item to consume
 * @param Quantity - the number of items to consume
 * @param TransactionId - the transaction id of this consume request (NOTE: this needs to be unique to this request)
 */
function bool ConsumeInventoryItem(byte LocalUserNum, string ProductId, int Quantity, string TransactionId);

/*
 * Called when the async consume request completes 
 */
delegate OnConsumeInventoryItemComplete(string ProductId, bool bDidSucceed, int NewQuantity);

/**
 * Sets the delegate used to notify the gameplay code that the inventory consume request has completed
 */
function AddConsumeInventoryItemCompleteDelegate(byte LocalUserNum, delegate<OnConsumeInventoryItemComplete> ConsumeInventoryItemCompleteDelegate);

/**
 * Clears the delegate used to notify the gameplay code that the inventory consume request has completed
 */
function ClearConsumeInventoryItemCompleteDelegate(byte LocalUserNum, delegate<OnConsumeInventoryItemComplete> ConsumeInventoryItemCompleteDelegate);

//@HSL_BEGIN_XBOX - BWJ - 3-12-15 - Support for purchase item callback
delegate OnMarketplaceItemPurchased();
function AddMarketplaceItemPurchasedDelegate( delegate<OnMarketplaceItemPurchased> InDelegate );
function ClearMarketplaceItemPurchasedDelegate( delegate<OnMarketplaceItemPurchased> InDelegate );
//@HSL_END_XBOX
