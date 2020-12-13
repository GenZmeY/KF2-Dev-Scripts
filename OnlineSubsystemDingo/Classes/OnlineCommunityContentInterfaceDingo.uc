/**
 * Copyright 1998-2012 Epic Games, Inc. All Rights Reserved.
 */

/**
 * Class that implements a Dingo version of the game interface
 */
class OnlineCommunityContentInterfaceDingo extends Object within OnlineSubsystemDingo
	native
	implements(OnlineCommunityContentInterface)
	config(Engine);

/** The owning subsystem that this object is providing an implementation for */
var OnlineSubsystemDingo OwningSubsystem;

var array<delegate<OnReadContentListComplete> > ReadContentListCompleteDelegates;
var array<delegate<OnUploadContentComplete> >   UploadContentCompleteDelegates;
var array<delegate<OnDownloadContentComplete> > DownloadContentCompleteDelegates;
var array<delegate<OnDeleteContentComplete> >   DeleteContentCompleteDelegates;

/**
 * Initializes the community content object
 *
 * @return true if the initialization succeeded, false otherwise
 */
native event bool Init();

/**
 * Shuts down the community content object
 */
native event Exit();

/**
 * Starts the async task that reads the list of content that this person can download. The resulting
 * data includes the information for that file (meta data and rating/download information)
 *
 * @param PlayerNum the player doing the request
 * @param NetId the player who's data will be read
 * @param StartAt used to read from a list starting a known offset
 * @param NumToRead the number of items to retrieve (0 means all)
 *
 * @return true if the async task succeeded in starting up, false otherwise
 */
native function bool ReadContentList(byte PlayerNum,UniqueNetId NetId,optional string Path="",optional int StartAt = 0,optional int NumToRead = 0);

/**
 * Delegate fired when the async read task has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnReadContentListComplete(bool bWasSuccessful, array<CommunityContentFile> ContentFiles);


/**
 * Adds the delegate to the list that will be notified when the task completes
 *
 * @param ReadContentListCompleteDelegate the delegate to use for notifications
 */
function AddReadContentListCompleteDelegate(delegate<OnReadContentListComplete> ReadContentListCompleteDelegate)
{
	`AddUniqueItemToArray(ReadContentListCompleteDelegates, ReadContentListCompleteDelegate);
}

/**
 * Removes the delegate from the list of notifications
 *
 * @param ReadContentListCompleteDelegate the delegate to use for notifications
 */
function ClearReadContentListCompleteDelegate(delegate<OnReadContentListComplete> ReadContentListCompleteDelegate)
{
	ReadContentListCompleteDelegates.RemoveItem(ReadContentListCompleteDelegate);
}

/**
 * Uploads the contents of the blob to the content server(s)
 *
 * @param PlayerNum the controller number associated with the player
 * @param Payload the data that is being uploaded
 * @param Metadata metadata describing the content
 *
 * @return true if the async upload task started successfully, false otherwise
 */
native function bool UploadContent(byte PlayerNum,const out array<byte> Payload,const out CommunityContentMetadata Metadata);

/**
 * Delegate fired when the async upload task has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 * @param UploadedFile the corresponding meta data that was associated with the content
 */
delegate OnUploadContentComplete(bool bWasSuccessful,CommunityContentFile UploadedFile);

/**
 * Adds the delegate to the list that will be notified when the task completes
 *
 * @param UploadContentCompleteDelegate the delegate to use for notifications
 */
function AddUploadContentCompleteDelegate(delegate<OnUploadContentComplete> UploadContentCompleteDelegate)
{
	`AddUniqueItemToArray(UploadContentCompleteDelegates, UploadContentCompleteDelegate);
}

/**
 * Removes the delegate from the list of notifications
 *
 * @param UploadContentCompleteDelegate the delegate to use for notifications
 */
function ClearUploadContentCompleteDelegate(delegate<OnUploadContentComplete> UploadContentCompleteDelegate)
{
	UploadContentCompleteDelegates.RemoveItem(UploadContentCompleteDelegate);
}

/**
 * Downloads the contents of the specified file
 *
 * @param PlayerNum the controller number associated with the player
 * @param FileToDownload the file information that tells the system what to download
 *
 * @return true if the async Download task started successfully, false otherwise
 */
native function bool DownloadContent(byte PlayerNum,const out CommunityContentFile FileToDownload);

/**
 * Delegate fired when the async download task has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 * @param FileDownloaded the information for the file that was downloaded
 */
delegate OnDownloadContentComplete(bool bWasSuccessful,CommunityContentFile FileDownloaded, array<byte> Payload);

/**
 * Adds the delegate to the list that will be notified when the task completes
 *
 * @param DownloadContentCompleteDelegate the delegate to use for notifications
 */
function AddDownloadContentCompleteDelegate(delegate<OnDownloadContentComplete> DownloadContentCompleteDelegate)
{
	`AddUniqueItemToArray(DownloadContentCompleteDelegates, DownloadContentCompleteDelegate);
}

/**
 * Removes the delegate from the list of notifications
 *
 * @param DownloadContentCompleteDelegate the delegate to use for notifications
 */
function ClearDownloadContentCompleteDelegate(delegate<OnDownloadContentComplete> DownloadContentCompleteDelegate)
{
	DownloadContentCompleteDelegates.RemoveItem(DownloadContentCompleteDelegate);
}

/**
 * Delete the contents of the blob on the content server(s)
 *
 * @param PlayerNum the controller number associated with the player
 * @param Metadata metadata describing the content
 *
 * @return true if the async delete task started successfully, false otherwise
 */
native function bool DeleteContent(byte PlayerNum,const out CommunityContentMetadata Metadata);

/**
 * Delegate fired when the async delete task has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 * @param UploadedFile the corresponding meta data that was associated with the content
 */
delegate OnDeleteContentComplete(bool bWasSuccessful);

/**
 * Adds the delegate to the list that will be notified when the task completes
 *
 * @param DeleteContentCompleteDelegate the delegate to use for notifications
 */
function AddDeleteContentCompleteDelegate(delegate<OnDeleteContentComplete> DeleteContentCompleteDelegate)
{
	`AddUniqueItemToArray(DeleteContentCompleteDelegates, DeleteContentCompleteDelegate);
}

/**
 * Removes the delegate from the list of notifications
 *
 * @param DeleteContentCompleteDelegate the delegate to use for notifications
 */
function ClearDeleteContentCompleteDelegate(delegate<OnDeleteContentComplete> DeleteContentCompleteDelegate)
{
	DeleteContentCompleteDelegates.RemoveItem(DeleteContentCompleteDelegate);
}

/**
 * Supplies a player defined rating for the specified content
 *
 * @param PlayerNum the controller number associated with the player
 * @param FileToRate the information for the file that is being rated
 * @param NewRating the new rating the player has given for this content
 *
 * @return true if the rating was successfully started, false otherwise (still in progress, can't find, etc.)
 */
function RateContent(byte PlayerNum,const out CommunityContentFile FileToRate,int NewRating);

/**
 * Copies the content file information for the specified player
 *
 * @param PlayerNum the controller number associated with the player
 * @param ContentFiles out array that is populated with the file list
 *
 * @return true if the copy succeeded, false otherwise (still in process, etc.)
 */
function bool GetContentList(byte PlayerNum,out array<CommunityContentFile> ContentFiles);

/**
 * Starts the async task that reads the list of content that this person can download. The resulting
 * data includes the information for that file (meta data and rating/download information)
 *
 * @param PlayerNum the controller number associated with the player
 * @param Friends the set of friends to read the content files for
 * @param StartAt used to read from a list starting a known offset
 * @param NumToRead the number of items to retrieve (-1 means all)
 *
 * @return true if the async task succeeded in starting up, false otherwise
 */
function bool ReadFriendsContentList(byte PlayerNum,const out array<OnlineFriend> Friends,optional int StartAt = 0,optional int NumToRead = -1);

/**
 * Delegate fired when the async read task has completed
 *
 * @param bWasSuccessful true if the async action completed without error, false if there was an error
 */
delegate OnReadFriendsContentListComplete(bool bWasSuccessful);

/**
 * Adds the delegate to the list that will be notified when the task completes
 *
 * @param ReadFriendsContentListCompleteDelegate the delegate to use for notifications
 */
function AddReadFriendsContentListCompleteDelegate(delegate<OnReadFriendsContentListComplete> ReadFriendsContentListCompleteDelegate);

/**
 * Removes the delegate from the list of notifications
 *
 * @param ReadFriendsContentListCompleteDelegate the delegate to use for notifications
 */
function ClearReadFriendsContentListCompleteDelegate(delegate<OnReadFriendsContentListComplete> ReadFriendsContentListCompleteDelegate);
/**
 * Copies the content file information for the specified player
 *
 * @param PlayerNum the controller number associated with the player
 * @param Friend the friend to copy the file list for
 * @param ContentFiles out array that is populated with the file list
 *
 * @return true if the copy succeeded, false otherwise (still in process, etc.)
 */
function bool GetFriendsContentList(byte PlayerNum,const out OnlineFriend Friend,out array<CommunityContentFile> ContentFiles);

/**
* Copies the contents of the payload into the specified array for the specified file owned
* by the specified player
*
* @param PlayerNum the controller number associated with the player
* @param FileDownloaded the information for the file that was downloaded
*
* @return true if the async Download task started successfully, false otherwise
*/
function bool GetContentPayload(byte PlayerNum,const out CommunityContentFile FileDownloaded);

/**
* Delegate fired when the async get content payload task has completed
*
* @param bWasSuccessful true if the async action completed without error, false if there was an error
* @param FileDownloaded the information for the file that was downloaded
* @param Payload the out array that receives contents of the file/blob data that was downloaded
*/
delegate OnGetContentPayloadComplete(bool bWasSuccessful,CommunityContentFile FileDownloaded,const out array<byte> Payload);

/**
* Adds the delegate to the list that will be notified when the task completes
*
* @param GetContentPayloadCompleteDelegate the delegate to use for notifications
*/
function AddGetContentPayloadCompleteDelegate(delegate<OnGetContentPayloadComplete> GetContentPayloadCompleteDelegate);

/**
* Removes the delegate from the list of notifications
*
* @param GetContentPayloadCompleteDelegate the delegate to use for notifications
*/
function ClearGetContentPayloadCompleteDelegate(delegate<OnGetContentPayloadComplete> GetContentPayloadCompleteDelegate);
