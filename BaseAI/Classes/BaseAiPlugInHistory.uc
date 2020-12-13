//=============================================================================
// BaseAiPlugInHistory
//=============================================================================
//
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================
class BaseAiPlugInHistory extends Object
	native(Plugin)
	dependson(PluginBase);


struct native BaseAIPlugInHistoryItem
{
	var class<AICommandBase>	PlugInClass;
	var string				    PlugInName;
	var float				    TimeStamp;		// World time command was started
	var float				    Duration;		// Total time spent in the command
	var bool				    bAborted;		// Command was aborted (which is often fine and intentional depending on the context) (TODO:Change to bytes)
	var bool				    bFailure;		// Command failed (this is also not necessarily bad, at times it's expected)
	var bool				    bSuccess;		// Command succeeded
	var string				    VerboseString;	// Optional extra info that can be added

};

var transient array<BaseAIPlugInHistoryItem> PlugInHistory;
var int PlugInHistoryNum;

var BaseAIController CtrlOwner;

cpptext
{
	virtual void StorePlugInHistory( UPluginBase* ThePlugIn );
}

event Setup( int InPlugInHistoryNum, BaseAIController InCtrlOwner )
{
	PlugInHistoryNum = InPlugInHistoryNum;
	CtrlOwner = InCtrlOwner;
}

simulated function DrawDebugToHud( HUD HUD, name Category )
{
	//local KFHUDBase kfHUD;
	local int plugInCnt;
	local Canvas canToUse;
	//local BaseAICommand Cmd;
	local BaseAIPlugInHistoryItem plugInItem;
	//local bool bDrawDebugCommandStack, bDrawDebugCommandHistory;
	//local bool bDrawDebugAllPlugins, bDrawDebugPlugInHistory;
	//local string AddTxt, NullTxt;
	//local AICommand AC;

	//kfHUD = KFHUDBase(kfHud);
	////local float Aggression;
	//bDrawDebugCommandStack = false;
	//bDrawDebugCommandHistory = false;

// 	if( Category == 'Default' || Category == 'All' || Category == 'OverheadNames' )
// 	{
// 		bDrawDebugCommandStack = false;
// 		bDrawDebugCommandHistory = false;
// 		Icon = Texture2D'ENG_EditorResources_TEX.AI.S_AI';
// 		DrawIconOverhead(HUD, Icon);
// 		return;
// 	}
// 	if( bDebug_ShowViewCone )
// 	{
// 		if( MyKFPawn != None )
// 		{
// 			tmp = MyKFPawn.GetPawnViewLocation();
// 			rot = MyKFPawn.GetBaseAimRotation();
// 		}
// 		DrawDebugCone(tmp ,vector( rot),Pawn .SightRadius, Acos(Pawn .PeripheralVision), Acos(Pawn .PeripheralVision),16,MakeColor(255,0,0,255));
// 	}

	//return;
//	NullTxt = "None";
	// Draw list of commands down the side of the screen
	if( /*Pawn != None && Category == 'All'*/ true )
	{
		canToUse = HUD.Canvas;
		canToUse.SetOrigin(0,0);
		canToUse.Font = class'Engine'.Static.GetSmallFont();
		canToUse.SetPos(canToUse.SizeX * 0.05f, canToUse.SizeY * 0.25f);

		// WRITE OUT COMMAND HISTORY
	//	C.SetDrawColor(255, 255, 255, 255);
		CtrlOwner.DrawDebugTextToHud( HUD, "************************************************************" );
		//C.SetDrawColor(0, 0, 255, 255);
		CtrlOwner.DrawDebugTextToHud( HUD, "PLUG IN HISTORY (Count:"@PlugInHistoryNum$")" );
		plugInCnt = 0;
		foreach PlugInHistory( plugInItem )
		{
			plugInCnt++;
	//		C.SetDrawColor(255, 0, 0, 255);
			CtrlOwner.DrawDebugTextToHud( HUD, "PlugIn"@plugInCnt$":"@String(plugInItem.PlugInClass)@"Time:"@plugInItem.TimeStamp);
			if( Len(plugInItem.VerboseString) > 0 )
			{
		//		C.SetDrawColor(255, 64, 64, 255);
				CtrlOwner.DrawDebugTextToHud( HUD, ".............."@plugInItem.VerboseString );
			}
		}
	}
}

defaultproperties
{
	PlugInHistoryNum=25
}
