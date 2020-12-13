/**
 * Copyright 1998-2013 Epic Games, Inc. All Rights Reserved.
 *
 * Provides access to user generated content downloading
 */

class TWOnlineUGCInterface extends Object dependson(OnlineSubsystem)
	abstract
	native;

/*
 *  Checks UGC subscribed to by PlayerID, starts downloading if it's out of date, and copies it to the
 *  working directory if done.
 */
function EnumerateWorkshopFiles();

delegate UGCDownloadProgressDelegate(string ItemName, Float PercentComplete, int ItemsRemaining);

function SetUGCDownloadProgressDelegate(delegate<UGCDownloadProgressDelegate> ProgressDelegate);

function ClearUGCDownloadProgressDelegate();

native function UniqueNetId GetUGCForPackage(string Package);
