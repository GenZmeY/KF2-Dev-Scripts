//=============================================================================
// KFWorkshopSteamworks
//=============================================================================
// Steam workshop downloading functionality for Killing Floor 2
//=============================================================================
// Killing Floor 2
// Copyright (C) 2013 Tripwire Interactive LLC
//  - Joshua Rowan 8/27/2014
//=============================================================================

class KFWorkshopSteamworks extends TWOnlineUGCInterface within OnlineSubsystemCommonImpl
	config(Engine)
	inherits(FTickableObject)
	native;

var config array<string> ServerSubscribedWorkshopItems;

var native array<UniqueNetId> CurrentDownloads;

var const native map{PublishedFileId_t, FString} WorkshopIDItemNames;

var const native map{FString, PublishedFileId_t} PackageWorkshopIDs;

var const native map{ QWORD, uint32 } InstallTimestamps;

var delegate<UGCDownloadProgressDelegate> ProgressDelegate;

var transient array<UniqueNetId> ServerSubscribedCopy;

var transient bool ServerFilesDirty;

var transient bool NeedsTicking;
var float TickInterval;
var transient float TickTime;

var native transient pointer WorkshopDownloader{class USteamWorkshopDownload};

delegate UGCDownloadProgressDelegate(string ItemName, Float PercentComplete, int ItemsRemaining);

function SetUGCDownloadProgressDelegate(delegate<UGCDownloadProgressDelegate> InProgressDelegate)
{
	ProgressDelegate = InProgressDelegate;
	NeedsTicking = true;
}

function ClearUGCDownloadProgressDelegate()
{
	ProgressDelegate = none;
	NeedsTicking = false;

}

native function UniqueNetId GetUGCForPackage(string Package);

native function Initialize();

native function UpdateWorkshopFiles();

native function InstallAllItems();

cpptext
{
	static const AppId_t EditorAppID = 232150;
 	/**
	 * Interface initialization
	 *
	 * @param InSubsystem	Reference to the initializing subsystem
	 */
	void InitInterface(UOnlineSubsystemSteamworks* InSubsystem);

	void DownloadingItemStarted(PublishedFileId_t Id);
	void DownloadingItemFinished(PublishedFileId_t Id);

	UBOOL InstallItem(PublishedFileId_t Id);
	UBOOL InstallConfig(const FString& WorkshopItemPath);
	UBOOL InstallLocalization(const FString& WorkshopItemPath);
	UBOOL InstallPackages(const FString& WorkshopItemPath, PublishedFileId_t Id);

	UBOOL CheckAppId(AppId_t AppId);

	void EnumerateClientWorkshopFiles(TArray<FUniqueNetId>& PublishedFileIds);
	void EnumerateServerWorkshopFiles(TArray<FUniqueNetId>& PublishedFileIds);
	void ServerDownloadNextFile();

	void ServerDownloadFinished(FOnlineAsyncEventSteamUGCDownloadComplete* DownloadTask);

	virtual void Tick(FLOAT DeltaSeconds);
	virtual UBOOL IsTickable() const;

	private:

	void CallDownloadUpdateDelegate(FString* Name, uint64 BytesDownloaded, uint64 BytesTotal, INT ItemsLeft);
}

defaultproperties
{
	NeedsTicking=false
	TickInterval=1.0
	TickTime=0.0
	ServerFilesDirty=false
}