/**
 * Class that implements a Dingo version of the Content interface
 */
 class OnlineContentInterfaceDingo extends Object within OnlineSubsystemDingo
	native
	implements(OnlineContentInterface);

/** The owning subsystem that this object is providing an implementation for */
var OnlineSubsystemDingo OwningSubsystem;

struct native OnlineSaveGame extends OnlineSubsystem.OnlineContent
{
	/** The data of the save game */
	var init array<byte> SaveGameData;
	/** The Read/Write state of this content */
	var EOnlineEnumerationReadState ReadWriteState;
};

struct native OnlineDownloadableContent extends OnlineSubsystem.OnlineContent
{
	/** The native WinRT Package pointer used for mounting/unmounting */
	var native hatpointer		DLCPackage{Windows::Xbox::Management::Deployment::IDownloadableContentPackage};
	/** The event token key for the LicenseTerminated event */
	var native QWORD			LicenseTerminatedTokenKey;
	/** Have we enumerated the files in the package? */
	var native bool				bHasEnumeratedContent;
};

struct native OnlineCrossTitleDownloadableContent extends OnlineSubsystem.OnlineCrossTitleContent
{
	/** The native WinRT Package pointer used for mounting/unmounting */
	var native hatpointer		DLCPackage{Windows::Xbox::Management::Deployment::IDownloadableContentPackage};
	/** The event token key for the LicenseTerminated event */
	var native QWORD			LicenseTerminatedTokenKey;
	/** Have we enumerated the files in the package? */
	var native bool				bHasEnumeratedContent;
};

/** Holds all the cached online content for a user */
struct native OnlineContentCache
{
	/** ConnectedStorageSpace for this user */
	var native hatpointer									UserConnectedStorageSpace{Windows::Xbox::Storage::ConnectedStorageSpace};
	/** The list of returned savegame content */
	var init array<OnlineSaveGame>							SaveGameContent;

	structcpptext
	{
		FOnlineContentCache()
		: UserConnectedStorageSpace(nullptr) {}
	}
};

/** Maps from user id to that user's OnlineContentCache */
var native map{QWORD, FOnlineContentCache} ContentCache;

/** The list of available DLC content */
var init array<OnlineDownloadableContent>				DLCContent;
/** The list of cross-title DLC content */
var init array<OnlineCrossTitleDownloadableContent>		CrossTitleDLCContent;

var init array<OnlineCrossTitleContent>					CrossTitleContent;

/** the array of delegates for notifying when content has changed */
var array<delegate<OnContentChange> > ContentChangeDelegates;

var array<delegate<OnReadCrossTitleContentComplete> > CrossTitleContentChangeDelegates;
var bool bHasEnumeratedCrossTitleContent;

/** Since the static array of dynamic array syntax appears to be broken */
struct native PerUserOnlineContentDelegates
{
	/** the array of delegates for notifying when content has changed */
	var array<delegate<OnContentChange> >								ContentChangeDelegates;
	/** the array of delegates for notifying when a downloadable content read has completed */
	var array<delegate<OnReadDownloadableContentComplete> >				ReadDLCDelegates;
	/** the array of delegates for notifying when a cross-title downloadable content read has completed */
	var array<delegate<OnReadCrossTitleDownloadableContentComplete> >	ReadCrossTitleDLCDelegates;
	/** the array of delegates for notifying when a save game read has completed */
	var array<delegate<OnReadSaveGameDataComplete> >					ReadSaveGameDelegates;
	/** the array of delegates for notifying when a save game write has completed */
	var array<delegate<OnWriteSaveGameDataComplete> >					WriteSaveGameDelegates;
	/** the array of delegates for notifying when a save game delete has been completed */
	var array<delegate<OnDeleteSaveGameDataComplete> >					DeleteSaveGameDelegates;
};

/** Per user array of array of delegates */
var PerUserOnlineContentDelegates PerUserDelegates[`MAX_NUM_PLAYERS];

/**
 * Delegate used in content change (add or deletion) notifications
 * for any user
 */
delegate OnContentChange();

/**
 * Adds the delegate used to notify the gameplay code that (downloaded) content changed
 *
 * @param Content Delegate the delegate to use for notifications
 * @param LocalUserNum whether to watch for changes on a specific slot or all slots
 */
function AddContentChangeDelegate(delegate<OnContentChange> ContentDelegate, optional byte LocalUserNum = 255)
{
	if (LocalUserNum == 255)
	{
		`AddUniqueItemToArray(ContentChangeDelegates, ContentDelegate);
	}
	else
	{
		// Make sure the user is valid
		if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
		{
			`AddUniqueItemToArray(PerUserDelegates[LocalUserNum].ContentChangeDelegates, ContentDelegate);
		}
		else
		{
			`warn("Invalid index ("$LocalUserNum$") passed to AddContentChangeDelegate()");
		}
	}
}

/**
 * Removes the delegate from the set of delegates that are notified
 *
 * @param Content Delegate the delegate to use for notifications
 * @param LocalUserNum whether to watch for changes on a specific slot or all slots
 */
function ClearContentChangeDelegate(delegate<OnContentChange> ContentDelegate, optional byte LocalUserNum = 255)
{
	if (LocalUserNum == 255)
	{
		ContentChangeDelegates.RemoveItem(ContentDelegate);
	}
	else
	{
		// Make sure the user is valid
		if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
		{
			PerUserDelegates[LocalUserNum].ContentChangeDelegates.RemoveItem(ContentDelegate);
		}
		else
		{
			`warn("Invalid index ("$LocalUserNum$") passed to ClearContentChangeDelegate()");
		}
	}
}

/**
 * Delegate used when the content read request has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnReadDownloadableContentComplete(bool bWasSuccessful);

/**
 * Adds the delegate used to notify the gameplay code that the downloadable content read request has completed
 *
 * @param LocalUserNum The user to read the content list of
 * @param ReadContentCompleteDelegate the delegate to use for notifications
 */
function AddReadDownloadableContentComplete(byte LocalUserNum, delegate<OnReadDownloadableContentComplete> ReadDLCCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		`AddUniqueItemToArray(PerUserDelegates[LocalUserNum].ReadDLCDelegates, ReadDLCCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to AddReadDownloadableContentComplete()");
	}
}

/**
 * Clears the delegate used to notify the gameplay code that the downloadable content read request has completed
 *
 * @param LocalUserNum The user to read the content list of
 * @param ReadContentCompleteDelegate the delegate to use for notifications
 */
function ClearReadDownloadableContentComplete(byte LocalUserNum, delegate<OnReadDownloadableContentComplete> ReadDLCCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		PerUserDelegates[LocalUserNum].ReadDLCDelegates.RemoveItem(ReadDLCCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to ClearReadDownloadableContentComplete()");
	}
}

/**
 * Starts an async task that retrieves the list of downloaded content for the player.
 *
 * @param LocalUserNum The user to read the content list of
 *
 * @return true if the read request was issued successfully, false otherwise
 */
native function bool ReadDownloadableContentList(byte LocalUserNum);

/**
 * Starts an async task that frees any downloaded content resources for that player
 *
 * @param LocalUserNum The user to clear the content list for
 */
native function ClearDownloadableContentList(byte LocalUserNum);

/**
 * Retrieve the list of content the given user has downloaded
 * to the local console.

 * @param LocalUserNum The user to read the content list of
 * @param ContentList The out array that receives the list of all content
 *
 * @return OERS_Done if the read has completed, otherwise one of the other states
 */
native function EOnlineEnumerationReadState GetDownloadableContentList(byte LocalUserNum, out array<OnlineContent> ContentList);

/**
 * Starts an async task that retrieves the list of downloaded content for the player across all titles
 *
 * @param LocalUserNum The user to read the content list of
 * @param TitleId the title id to filter on. Zero means all titles
 *
 * @return true if the read request was issued successfully, false otherwise
 */
native function bool ReadCrossTitleDownloadableContentList(byte LocalUserNum, optional int TitleId = 0);

/**
 * Starts an async task that frees any downloaded content resources for that player
 *
 * @param LocalUserNum The user to clear the content list for
 */
native function ClearCrossTitleDownloadableContentList(byte LocalUserNum);

/**
 * Retrieve the list of content the given user has downloaded
 * to the local console.

 * @param LocalUserNum The user to read the content list of
 * @param ContentList The out array that receives the list of all content
 *
 * @return OERS_Done if the read has completed, otherwise one of the other states
 */
native function EOnlineEnumerationReadState GetCrossTitleDownloadableContentList(byte LocalUserNum, out array<OnlineCrossTitleContent> ContentList);

/**
 * Delegate used when the content read request has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnReadCrossTitleDownloadableContentComplete(bool bWasSuccessful);

/**
 * Adds the delegate used to notify the gameplay code that the content read request has completed
 *
 * @param LocalUserNum The user to read the content list of
 * @param ReadContentCompleteDelegate the delegate to use for notifications
 */
function AddReadCrossTitleDownloadableContentComplete(byte LocalUserNum, delegate<OnReadCrossTitleDownloadableContentComplete> ReadCrossTitleDLCCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		`AddUniqueItemToArray(PerUserDelegates[LocalUserNum].ReadCrossTitleDLCDelegates, ReadCrossTitleDLCCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to AddReadCrossTitleContentCompleteDelegate()");
	}
}

/**
 * Clears the delegate used to notify the gameplay code that the content read request has completed
 *
 * @param LocalUserNum The user to read the content list of
 * @param ReadContentCompleteDelegate the delegate to use for notifications
 */
function ClearReadCrossTitleDownloadableContentComplete(byte LocalUserNum, delegate<OnReadCrossTitleDownloadableContentComplete> ReadCrossTitleDLCCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		PerUserDelegates[LocalUserNum].ReadCrossTitleDLCDelegates.RemoveItem(ReadCrossTitleDLCCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to ClearReadCrossTitleContentCompleteDelegate()");
	}
}

/**
 * Reads a player's cross title save game data from the specified content bundle
 *
 * @param LocalUserNum the user that is initiating the data read (also used in validating ownership of the data)
 * @param DeviceId the device to read the same game from
 * @param TitleId the title id the save game is from
 * @param FriendlyName the friendly name of the save game that was returned by enumeration
 * @param FileName the file to read from inside of the content package
 * @param SaveFileName the file name of the save game inside the content package
 *
 * @return true if the async read was started successfully, false otherwise
 */
function bool ReadCrossTitleSaveGameData(byte LocalUserNum,int DeviceId,int TitleId,string FriendlyName,string FileName,string SaveFileName);

/**
 * Copies a player's cross title save game data from the cached async read data
 *
 * @param LocalUserNum the user that is initiating the data read (also used in validating ownership of the data)
 * @param DeviceId the device to read the same game from
 * @param TitleId the title id the save game is from
 * @param FriendlyName the friendly name of the save game that was returned by enumeration
 * @param FileName the file to read from inside of the content package
 * @param SaveFileName the file name of the save game inside the content package
 * @param bIsValid out value indicating whether the save is corrupt or not
 * @param SaveGameData the array that is filled with the save game data
 *
 * @return true if the async read was started successfully, false otherwise
 */
function bool GetCrossTitleSaveGameData(byte LocalUserNum,int DeviceId,int TitleId,string FriendlyName,string FileName,string SaveFileName,out byte bIsValid,out array<byte> SaveGameData);

/**
 * Delegate used when the cross title content read request has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 * @param LocalUserNum the user that was initiating the data read
 * @param DeviceId the device that the read was on
 * @param TitleId the title id the save game is from
 * @param FriendlyName the friendly name of the save game that was returned by enumeration
 * @param FileName the file to read from inside of the content package
 * @param SaveFileName the file name of the save game inside the content package
 */
delegate OnReadCrossTitleSaveGameDataComplete(bool bWasSuccessful,byte LocalUserNum,int DeviceId,int TitleId,string FriendlyName,string FileName,string SaveFileName);

/**
 * Adds the delegate used to notify the gameplay code that a cross title save game read request has completed
 *
 * @param LocalUserNum The user that was reading a save game
 * @param ReadSaveGameDataCompleteDelegate the delegate to use for notifications
 */
function AddReadCrossTitleSaveGameDataComplete(byte LocalUserNum,delegate<OnReadCrossTitleSaveGameDataComplete> ReadSaveGameDataCompleteDelegate);

/**
 * Clears the delegate used to notify the gameplay code that a cross title save game read request has completed
 *
 * @param LocalUserNum The user that was reading a save game
 * @param ReadSaveGameDataCompleteDelegate the delegate to use for notifications
 */
function ClearReadCrossTitleSaveGameDataComplete(byte LocalUserNum,delegate<OnReadCrossTitleSaveGameDataComplete> ReadSaveGameDataCompleteDelegate);

/**
 * Clears any cached save games
 *
 * @param LocalUserNum the user that is deleting data
 *
 * @return true if the clear succeeded, false otherwise
 */
function bool ClearCrossTitleSaveGames(byte LocalUserNum);

/**
 * Asks the online system for the number of new and total content downloads
 *
 * @param LocalUserNum the user to check the content download availability for
 * @param CategoryMask the bitmask to use to filter content by type
 *
 * @return TRUE if the call succeeded, FALSE otherwise
 */
function bool QueryAvailableDownloads(byte LocalUserNum,optional int CategoryMask = -1);

/**
 * Called once the download query completes
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnQueryAvailableDownloadsComplete(bool bWasSuccessful);

/**
 * Adds the delegate used to notify the gameplay code that the content download query has completed
 *
 * @param LocalUserNum the user to check the content download availability for
 * @param ReadContentCompleteDelegate the delegate to use for notifications
 */
function AddQueryAvailableDownloadsComplete(byte LocalUserNum,delegate<OnQueryAvailableDownloadsComplete> QueryDownloadsDelegate);

/**
 * Clears the delegate used to notify the gameplay code that the content download query has completed
 *
 * @param LocalUserNum the user to check the content download availability for
 * @param ReadContentCompleteDelegate the delegate to use for notifications
 */
function ClearQueryAvailableDownloadsComplete(byte LocalUserNum,delegate<OnQueryAvailableDownloadsComplete> QueryDownloadsDelegate);

/**
 * Returns the number of new and total downloads available for the user
 *
 * @param LocalUserNum the user to check the content download availability for
 * @param NewDownloads out value of the number of new downloads available
 * @param TotalDownloads out value of the number of total downloads available
 */
function GetAvailableDownloadCounts(byte LocalUserNum,out int NewDownloads,out int TotalDownloads);

/**
 * Reads a player's save game data from the specified content bundle
 *
 * @param LocalUserNum the user that is initiating the data read (also used in validating ownership of the data)
 * @param SaveFileName the file name of the save game inside the content package
 *
 * @return true if the async read was started successfully, false otherwise
 */
native function bool ReadSaveGameData(byte LocalUserNum,int DeviceId,string FriendlyName,string FileName,string SaveFileName);

/**
 * Copies a player's save game data from the cached async read data
 *
 * @param LocalUserNum the user that is initiating the data read (also used in validating ownership of the data)
 * @param SaveFileName the file name of the save game inside the content package
 * @param bIsValid out value indicating whether the save is corrupt or not
 * @param SaveGameData the array that is filled with the save game data
 *
 * @return true if the async read was started successfully, false otherwise
 */
native function bool GetSaveGameData(byte LocalUserNum,int DeviceId,string FriendlyName,string FileName,string SaveFileName,out byte bIsValid,out array<byte> SaveGameData);

/**
 * Delegate used when the content read request has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 * @param LocalUserNum the user that was initiating the data read
 * @param SaveFileName the file name of the save game inside the content package
 */
delegate OnReadSaveGameDataComplete(bool bWasSuccessful,byte LocalUserNum,int DeviceId,string FriendlyName,string FileName,string SaveFileName);

/**
 * Adds the delegate used to notify the gameplay code that a save game read request has completed
 *
 * @param LocalUserNum The user that was reading a save game
 * @param ReadSaveGameDataCompleteDelegate the delegate to use for notifications
 */
function AddReadSaveGameDataComplete(byte LocalUserNum,delegate<OnReadSaveGameDataComplete> ReadSaveGameDataCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		`AddUniqueItemToArray(PerUserDelegates[LocalUserNum].ReadSaveGameDelegates, ReadSaveGameDataCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to AddReadSaveGameDataComplete()");
	}
}

/**
 * Clears the delegate used to notify the gameplay code that a save game read request has completed
 *
 * @param LocalUserNum The user that was reading a save game
 * @param ReadSaveGameDataCompleteDelegate the delegate to use for notifications
 */
function ClearReadSaveGameDataComplete(byte LocalUserNum,delegate<OnReadSaveGameDataComplete> ReadSaveGameDataCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		PerUserDelegates[LocalUserNum].ReadSaveGameDelegates.RemoveItem(ReadSaveGameDataCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to ClearReadSaveGameDataComplete()");
	}
}

/**
 * Writes a player's save game data to the specified content bundle and file
 *
 * @param LocalUserNum the user that is initiating the data write
 * @param SaveFileName the file name of the save game inside the content package
 * @param SaveGameData the data to write to the save game file
 *
 * @return true if the async write was started successfully, false otherwise
 */
native function bool WriteSaveGameData(byte LocalUserNum,int DeviceId,string FriendlyName,string FileName,string SaveFileName,const out array<byte> SaveGameData);

/**
 * Delegate used when the content write request has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 * @param LocalUserNum the user that was initiating the data write
 * @param SaveFileName the file to write to inside of the content package
 */
delegate OnWriteSaveGameDataComplete(bool bWasSuccessful,byte LocalUserNum,int DeviceId,string FriendlyName,string FileName,string SaveFileName);

/**
 * Adds the delegate used to notify the gameplay code that a save game write request has completed
 *
 * @param LocalUserNum The user that was writing a save game
 * @param WriteSaveGameDataCompleteDelegate the delegate to use for notifications
 */
function AddWriteSaveGameDataComplete(byte LocalUserNum,delegate<OnWriteSaveGameDataComplete> WriteSaveGameDataCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		`AddUniqueItemToArray(PerUserDelegates[LocalUserNum].WriteSaveGameDelegates, WriteSaveGameDataCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to AddWriteSaveGameDataComplete()");
	}
}

/**
 * Clears the delegate used to notify the gameplay code that a save game write request has completed
 *
 * @param LocalUserNum The user that was writing a save game
 * @param WriteSaveGameDataCompleteDelegate the delegate to use for notifications
 */
function ClearWriteSaveGameDataComplete(byte LocalUserNum,delegate<OnWriteSaveGameDataComplete> WriteSaveGameDataCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		PerUserDelegates[LocalUserNum].WriteSaveGameDelegates.RemoveItem(WriteSaveGameDataCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to ClearWriteSaveGameDataComplete()");
	}
}

/**
 * Deletes a player's save game data
 *
 * @param LocalUserNum the user that is deleting data
 * @param SaveFileName the file name of the content package to delete
 *
 * @return true if the delete succeeded, false otherwise
 */
native function bool DeleteSaveGameData(byte LocalUserNum,string SaveFileName);

/**
 * Delegate used when the content delete request has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 * @param LocalUserNum the user that was initiating the data write
 * @param FileName the save file that was deleted
 */
delegate OnDeleteSaveGameDataComplete(bool bWasSuccessful,byte LocalUserNum,string SaveFileName);

/**
 * Adds the delegate used to notify the gameplay code that a save game delete request has completed
 *
 * @param LocalUserNum The user that was writing a save game
 * @param DeleteSaveGameDataCompleteDelegate the delegate to use for notifications
 */
function AddDeleteSaveGameDataCompleteDelegate(byte LocalUserNum,delegate<OnDeleteSaveGameDataComplete> DeleteSaveGameDataCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		`AddUniqueItemToArray(PerUserDelegates[LocalUserNum].DeleteSaveGameDelegates, DeleteSaveGameDataCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to AddDeleteSaveGameDataComplete()");
	}
}

/**
 * Clears the delegate used to notify the gameplay code that a save game delete request has completed
 *
 * @param LocalUserNum The user that was writing a save game
 * @param DeleteSaveGameDataCompleteDelegate the delegate to use for notifications
 */
function ClearDeleteSaveGameDataCompleteDelegate(byte LocalUserNum,delegate<OnDeleteSaveGameDataComplete> DeleteSaveGameDataCompleteDelegate)
{
	// Make sure the user is valid
	if (LocalUserNum >= 0 && LocalUserNum < ArrayCount(PerUserDelegates))
	{
		PerUserDelegates[LocalUserNum].DeleteSaveGameDelegates.RemoveItem(DeleteSaveGameDataCompleteDelegate);
	}
	else
	{
		`warn("Invalid index ("$LocalUserNum$") passed to ClearDeleteSaveGameDataComplete()");
	}
}

/**
* Deletes a player's save game data
*
* @param LocalUserNum the user that is deleting data
* @param DeviceId the device to delete the same game from
* @param FriendlyName the friendly name of the save game that was returned by enumeration
* @param FileName the file name of the content package to delete
*
* @return true if the delete succeeded, false otherwise
*/
function bool DeleteSaveGame(byte LocalUserNum,int DeviceId,string FriendlyName,string FileName)
{
	return DeleteSaveGameData( LocalUserNum, FileName );
}

/**
* Clears any cached save games
*
* @param LocalUserNum the user that is deleting data
*
* @return true if the clear succeeded, false otherwise
*/
function bool ClearSaveGames(byte LocalUserNum);

/**
 * Clears any cached save games
 *
 * @param LocalUserNum the user that is deleting data
 *
 * @return true if the clear succeeded, false otherwise
 */
native function bool ClearCachedSaveGames(byte LocalUserNum);

/**
* Delegate used when the content read request has completed
*
* @param bWasSuccessful true if the async action completed without error, false if there was an error
*/
delegate OnReadContentComplete(bool bWasSuccessful);

/**
* Adds the delegate used to notify the gameplay code that the content read request has completed
*
* @param LocalUserNum The user to read the content list of
* @param ContentType the type of content being read
* @param ReadContentCompleteDelegate the delegate to use for notifications
*/
function AddReadContentComplete(byte LocalUserNum,EOnlineContentType ContentType,delegate<OnReadContentComplete> ReadContentCompleteDelegate);

/**
* Clears the delegate used to notify the gameplay code that the content read request has completed
*
* @param LocalUserNum The user to read the content list of
* @param ContentType the type of content being read
* @param ReadContentCompleteDelegate the delegate to use for notifications
*/
function ClearReadContentComplete(byte LocalUserNum,EOnlineContentType ContentType,delegate<OnReadContentComplete> ReadContentCompleteDelegate);

/**
* Starts an async task that retrieves the list of downloaded/savegame content for the player.
*
* @param LocalUserNum The user to read the content list of
* @param ContentType the type of content being read
* @param DeviceId optional value to restrict the enumeration to a particular device
*
* @return true if the read request was issued successfully, false otherwise
*/
function bool ReadContentList(byte LocalUserNum,EOnlineContentType ContentType,optional int DeviceId = -1);

/**
* Starts an async task that frees any downloaded content resources for that player
*
* @param LocalUserNum The user to clear the content list for
* @param ContentType the type of content being read
*/
function ClearContentList(byte LocalUserNum,EOnlineContentType ContentType);

/**
* Retrieve the list of content the given user has downloaded or otherwise retrieved
* to the local console.

* @param LocalUserNum The user to read the content list of
* @param ContentType the type of content being read
* @param ContentList The out array that receives the list of all content
*
* @return OERS_Done if the read has completed, otherwise one of the other states
*/
function EOnlineEnumerationReadState GetContentList(byte LocalUserNum,EOnlineContentType ContentType,out array<OnlineContent> ContentList);

/**
* Starts an async task that retrieves the list of downloaded/savegame content for the player across all titles
*
* @param LocalUserNum The user to read the content list of
* @param ContentType the type of content being read
* @param TitleId the title id to filter on. Zero means all titles
* @param DeviceId optional value to restrict the enumeration to a particular device
*
* @return true if the read request was issued successfully, false otherwise
*/
native function bool ReadCrossTitleContentList(byte LocalUserNum,EOnlineContentType ContentType,optional int TitleId = 0,optional int DeviceId = -1);

/**
* Starts an async task that frees any downloaded content resources for that player
*
* @param LocalUserNum The user to clear the content list for
* @param ContentType the type of content being read
*/
native function ClearCrossTitleContentList(byte LocalUserNum,EOnlineContentType ContentType);

/**
* Retrieve the list of content the given user has downloaded or otherwise retrieved
* to the local console.

* @param LocalUserNum The user to read the content list of
* @param ContentType the type of content being read
* @param ContentList The out array that receives the list of all content
*
* @return OERS_Done if the read has completed, otherwise one of the other states
*/
native function EOnlineEnumerationReadState GetCrossTitleContentList(byte LocalUserNum,EOnlineContentType ContentType,out array<OnlineCrossTitleContent> ContentList);

/**
* Delegate used when the content read request has completed
*
* @param bWasSuccessful true if the async action completed without error, false if there was an error
*/
delegate OnReadCrossTitleContentComplete(bool bWasSuccessful);

/**
* Adds the delegate used to notify the gameplay code that the content read request has completed
*
* @param LocalUserNum The user to read the content list of
* @param ContentType the type of content being read
* @param ReadContentCompleteDelegate the delegate to use for notifications
*/
function AddReadCrossTitleContentCompleteDelegate(byte LocalUserNum, EOnlineContentType ContentType, delegate<OnReadCrossTitleContentComplete> ReadContentCompleteDelegate)
{
	`AddUniqueItemToArray(CrossTitleContentChangeDelegates, ReadContentCompleteDelegate);
}

/**
* Clears the delegate used to notify the gameplay code that the content read request has completed
*
* @param LocalUserNum The user to read the content list of
* @param ContentType the type of content being read
* @param ReadContentCompleteDelegate the delegate to use for notifications
*/
function ClearReadCrossTitleContentCompleteDelegate(byte LocalUserNum, EOnlineContentType ContentType, delegate<OnReadCrossTitleContentComplete> ReadContentCompleteDelegate)
{
	CrossTitleContentChangeDelegates.RemoveItem(ReadContentCompleteDelegate);
}


cpptext
{
	void Init();

	/**
	 * Handles updating of any async tasks that need to be performed
	 *
	 * @param DeltaTime the amount of time that has passed since the last tick
	 */
	virtual void Tick(FLOAT DeltaTime);

	FOnlineContentCache& GetOnlineContentCache(QWORD PlayerUid);

	UBOOL HasCachedSaveGameContent(QWORD PlayerUid, const FString& ContentFilename);

	FOnlineSaveGame& GetCachedSaveGameContent(QWORD PlayerUid, const FString& ContentFilename);

	void ClearCachedSaveGameContent(QWORD PlayerUid, const FString& ContentFilename);

private:
	static Windows::Xbox::Management::Deployment::DownloadableContentPackageManager^ DLCPackageManager;

	static FCriticalSection ContentChangeCriticalSection;

	static UBOOL bDLCContentStatusUpdated;

	static void OnPackageInstallCompleted();

	void OnLicenseTerminated(const FString& PackageFullname, INT Reason, const FString& UserXuid);
}
