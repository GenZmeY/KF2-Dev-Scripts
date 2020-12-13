//=============================================================================
// KFSteamWebAPICall
//=============================================================================
// Base class for Steamworks Web API functionality. Copypasta from KF1
//=============================================================================
// Copyright (C) 2015 Tripwire Interactive LLC
// - Joshua "Josh" Rowan
// Based off of KFSteamWebApi Copyright 2007 Tripwire Interactive, Inc.
// All Rights Reserved.
//=============================================================================

class KFSteamWebAPICall extends Object
	native
	abstract
	inherits(FTickableObject);

var float RequestTimeout;
var string steamAPIAddr;
var string Format;
var native pointer Downloader{class FHttpDownloadString};

/** Used to toggle debug logging */
var bool bDebug;

//Used by concrete subclasses
var string APICall;

cpptext
{
	/**
	 * Allows per frame work to be done
	 *
	 * @param DeltaTime the amount of time that has passed since the last tick
	 */
	virtual void Tick(FLOAT);

	/**
	 * Returns whether it is okay to tick this object. E.g. objects being loaded in the background shouldn't be ticked
	 * till they are finalized and unreachable objects cannot be ticked either.
	 *
	 * @return	TRUE if tickable, FALSE otherwise
	 */
	virtual UBOOL IsTickable() const
	{
		// We cannot tick objects that are unreachable or are in the process of being loaded in the background.
		return Downloader && !HasAnyFlags( RF_Unreachable | RF_AsyncLoading );
	}
	
	/** Call CleanUp on GC */
	virtual void FinishDestroy();

	/** Destroy HttpDownloader */
	void CleanUp();
}

function CallWebProcedure(string FunctionCall, string Parameters)
{
	local string URL;
	local string Payload;

	URL = "http://" $ steamAPIAddr $ FunctionCall;
	Payload = Parameters;
	if (Len(payload) > 0)
	{
		Payload = Payload $ "&";
	}
	Payload = Payload $ Format; 

	SendHTTPGet(steamAPIAddr, URL, Payload, RequestTimeout);
}

native function SendHTTPGet(string Domain, string URL, string Payload, float Timeout);

event Finished(bool success, string ReturnStr)
{
	local JsonObject response;

	if (!success)
	{
		`log(Class.Name @ "did not get HTTP response.", bDebug);
		return;
	}
	response = class'JsonObject'.static.DecodeJson(ReturnStr);

	if ( response == none )
	{
		`log(Class.Name @ "could not parse HTTP response.", bDebug);
		return;
	}

	ProcessResponse(response);
}

function ProcessResponse(JsonObject response);

defaultproperties
{
     //bHidden=true
     steamAPIAddr="api.steampowered.com"
     RequestTimeout=10.f
     Format="format=json"
}
