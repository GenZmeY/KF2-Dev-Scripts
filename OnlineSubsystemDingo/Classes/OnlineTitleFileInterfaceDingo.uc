/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Class that implements a Dingo version of the game interface
 */
class OnlineTitleFileInterfaceDingo extends Object within OnlineSubsystemDingo
	native
	implements(OnlineTitleFileInterface)
	config(Engine);

/** The owning subsystem that this object is providing an implementation for */
var OnlineSubsystemDingo OwningSubsystem;

var array<delegate<OnReadTitleFileComplete> >        ReadTitleFileCompleteDelegates;
var array<delegate<OnRequestTitleFileListComplete> > RequestTitleFileListCompleteDelegates;

/** Add the file size for our tracking purposes */
struct native TitleFileDingo extends OnlineSubsystem.TitleFile
{
	var int FileSize;
};

var array<TitleFileDingo> TitleManagedFiles;

/**
 * Delegate fired when a file read from the network platform's title specific storage is complete
 *
 * @param bWasSuccessful whether the file read was successful or not
 * @param FileName the name of the file this was for
 */
delegate OnReadTitleFileComplete(bool bWasSuccessful,string FileName);

/**
 * Starts an asynchronous read of the specified file from the network platform's
 * title specific file store
 *
 * @param FileToRead the name of the file to read
 *
 * @return true if the calls starts successfully, false otherwise
 */
native function bool ReadTitleFile(string FileToRead, optional EOnlineFileType FileType = OFT_Binary);

/**
 * Adds the delegate to the list to be notified when a requested file has been read
 *
 * @param ReadTitleFileCompleteDelegate the delegate to add
 */
function AddReadTitleFileCompleteDelegate(delegate<OnReadTitleFileComplete> ReadTitleFileCompleteDelegate)
{
	`AddUniqueItemToArray(ReadTitleFileCompleteDelegates, ReadTitleFileCompleteDelegate);
}

/**
 * Removes the delegate from the notify list
 *
 * @param ReadTitleFileCompleteDelegate the delegate to remove
 */
function ClearReadTitleFileCompleteDelegate(delegate<OnReadTitleFileComplete> ReadTitleFileCompleteDelegate)
{
	ReadTitleFileCompleteDelegates.RemoveItem(ReadTitleFileCompleteDelegate);
}

/**
 * Copies the file data into the specified buffer for the specified file
 *
 * @param FileName the name of the file to read
 * @param FileContents the out buffer to copy the data into
 *
 * @return true if the data was copied, false otherwise
 */
native function bool GetTitleFileContents(string FileName,out array<byte> FileContents);

/**
 * Determines the async state of the tile file read operation
 *
 * @param FileName the name of the file to check on
 *
 * @return the async state of the file read
 */
function EOnlineEnumerationReadState GetTitleFileState(string FileName)
{
	local int FileIndex;
	FileIndex = TitleManagedFiles.Find('FileName',FileName);
	if (FileIndex != INDEX_NONE)
	{
		return TitleManagedFiles[FileIndex].AsyncState;
	}
	return OERS_Failed;
}

/**
 * Empties the set of downloaded files if possible (no async tasks outstanding)
 *
 * @return true if they could be deleted, false if they could not
 */
native function bool ClearDownloadedFiles();

/**
 * Empties the cached data for this file if it is not being downloaded currently
 *
 * @param FileName the name of the file to remove from the cache
 *
 * @return true if it could be deleted, false if it could not
 */
native function bool ClearDownloadedFile(string FileName);

/**
 * Async call to request a list of files (returned as string) from EMS
 */
native function bool RequestTitleFileList();

/**
 * Delegate fired when the request for a list of files completes
 *
 * @param bWasSuccessful whether the request completed successfully
 * @param ResultStr contains the list of files and associated meta data
 */
delegate OnRequestTitleFileListComplete(bool bWasSuccessful, array<string> FilePaths);

/**
 * Adds the delegate to the list to be notified when the list of requested files has been received
 *
 * @param RequestTitleFileListDelegate the delegate to add
 */
function AddRequestTitleFileListCompleteDelegate(delegate<OnRequestTitleFileListComplete> RequestTitleFileListDelegate)
{
	`AddUniqueItemToArray(RequestTitleFileListCompleteDelegates, RequestTitleFileListDelegate);
}

/**
 * Removes the delegate from the notify list
 *
 * @param RequestTitleFileListDelegate the delegate to remove
 */
function ClearRequestTitleFileListCompleteDelegate(delegate<OnRequestTitleFileListComplete> RequestTitleFileListDelegate)
{
	RequestTitleFileListCompleteDelegates.RemoveItem(RequestTitleFileListDelegate);
}

cpptext
{
	Microsoft::Xbox::Services::XboxLiveContext^ GetContext();
	UBOOL TitleFileExists(const FString& FileName, FTitleFileDingo*& TitleFileData);
	FTitleFileDingo& GetOrCreateTitleFileData(const FString& FileName);
}