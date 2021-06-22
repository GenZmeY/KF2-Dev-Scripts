class KFGFxHUD_ObjectiveConatiner extends GFxObject;

var float UpdateRate;
var KFInterface_MapObjective CurrentObjectiveInterface;

var Texture2d LastIcon;

var KFPlayerController KFPC;

var name SoundThemeName;
var name SoundCueName;

var float LastProgress;
var bool bLastMissionCritical;

var bool bPrevCompleted;

function InitializeHUD()
{
	KFPC = KFPlayerController(GetPC());
	SetVisible(false);
	LocalizeContainer();
}

function LocalizeContainer()
{
	local GFxObject TextObject;

	TextObject = CreateObject("Object");

	if (CurrentObjectiveInterface != none)
	{
		TextObject.SetString("failedString", Localize("Objectives", "FailedString", "KFGame"));
		TextObject.SetString("objectiveTitle", Localize("Objectives", "ObjectiveTitle", "KFGame"));
		TextObject.SetString("objectiveDesc", CurrentObjectiveInterface.GetLocalizedShortDescription());
	}


	SetObject("localizedText", TextObject);
}

simulated function SetActive(bool bActive)
{
	SetVisible(bActive);
	if (bActive)
	{
		CurrentObjectiveInterface = KFGameReplicationInfo(GetPC().WorldInfo.GRI).ObjectiveInterface;
		if (CurrentObjectiveInterface != none && CurrentObjectiveInterface.ShouldShowObjectiveContainer())
		{
			SetFailState(CurrentObjectiveInterface.HasFailedObjective());
			SetCurrentProgress(CurrentObjectiveInterface.GetProgress());
			LocalizeContainer();
			UpdateIcon();
			SetCompleted(CurrentObjectiveInterface.IsComplete());
			SetMissionCritical(CurrentObjectiveInterface.GetIsMissionCritical());
		}
		else
		{
			CurrentObjectiveInterface = none;
			SetVisible(false);
		}
	}
	else
	{
		CurrentObjectiveInterface = none;
		//hide actor count
		GetObject("objectiveNumberMC").SetVisible(false);
	}
	//SetBool("isActive", bActive); //nothing supporting this atm
}

function SetCompleted(bool bComplete)
{
	local GFxObject DataObject;

	DataObject = CreateObject("Object");

	DataObject.SetBool("bComplete", bComplete);
	DataObject.SetString("completeString", bComplete ? Localize("Objectives", "SuccessString", "KFGame") : "");
	SetObject("completeStatus", DataObject);

	if (!bComplete)
	{
		bPrevCompleted = false;
	}

	//play sound queue
	if (KFPC != none && KFPC.MyGFxHUD != none && bComplete && bComplete != bPrevCompleted)
	{
		KFPC.MyGFxHUD.PlaySoundFromTheme(SoundCueName, SoundThemeName);
		bPrevCompleted = true;
	}
}

function SetMissionCritical(bool bMissionCritical)
{
	bMissionCritical = false; //not using this for now
	if (bMissionCritical != bLastMissionCritical)
	{
		Setbool("missionCriticalStatus", bMissionCritical);
		bLastMissionCritical = bMissionCritical;
	}	
}

function SetCurrentIcon(string iconPath)
{
	if(iconPath == "")
	{
		SetString("currentIcon", "");
	}
	else
	{
		SetString("currentIcon", "img://"$iconPath);
	}
}

function TickHud(float DeltaTime)
{
	local int bStatusWarning, bStatusNotification;
	local string StatusMessage;
	local GFxObject DataObject;

	if (CurrentObjectiveInterface != none)
	{
		if (!CurrentObjectiveInterface.HasFailedObjective() && !CurrentObjectiveInterface.IsComplete())
		{
			SetString("currentProgressText", CurrentObjectiveInterface.GetProgressText());
			SetBool("currentProgressIsDosh", CurrentObjectiveInterface.GetProgressTextIsDosh());
		}

		CurrentObjectiveInterface.GetLocalizedStatus(StatusMessage, bStatusWarning, bStatusNotification);
		DataObject = CreateObject("Object");
		DataObject.SetBool("bStatusWarning", bool(bStatusWarning));
		DataObject.SetBool("bStatusNotification", bool(bStatusNotification));
		DataObject.SetString("StatusMessage", StatusMessage);
		SetObject("currentStatus", DataObject);

		SetInt("rewardValue", CurrentObjectiveInterface.GetDoshReward());
		SetCurrentProgress(CurrentObjectiveInterface.GetProgress());
		SetFailState(CurrentObjectiveInterface.HasFailedObjective());

		//UpdateRequirements();
		if (LastIcon != CurrentObjectiveInterface.GetIcon())
		{
			UpdateIcon();
		}
		SetMissionCritical(CurrentObjectiveInterface.GetIsMissionCritical());
	}
}

function UpdateIcon()
{
	LastIcon = CurrentObjectiveInterface.GetIcon();
	SetCurrentIcon(PathName(LastIcon));
}

function UpdateRequirements()
{
	/*local GFxObject DataObject;
	if (CurrentObjectiveInterface != none && CurrentObjectiveInterface.UsesProgress())
	{
		DataObject = CreateObject("Object");

	}*/
}

function SetFailState(bool bFailed)
{
	local GFxObject DataObject;

	DataObject = CreateObject("Object");

	DataObject.SetBool("bFailed", bFailed);
	DataObject.SetString("failedString", bFailed ? Localize("Objectives", "FailedString", "KFGame") : "");
	SetObject("failed", DataObject);
	if(bFailed)
	{
		//GetPC().SetTimer(10.0f, false, nameof(ClearObjectiveUI), self); //leave this out for now
	}
}

function ClearObjectiveUI()
{
	SetActive(false);
}

//pass a value from 0-1
function SetCurrentProgress(float CurrentProgress)
{
	if (LastProgress != CurrentProgress)
	{
		CurrentProgress = FClamp(CurrentProgress, 0, 1);
		LastProgress = CurrentProgress;
		SetInt("currentProgress", 100 * CurrentProgress);
		SetCompleted(CurrentObjectiveInterface.IsComplete());
	}
}

DefaultProperties
{
	LastProgress=-0.0f
	UpdateRate=0.1f
	bPrevCompleted=false
	SoundThemeName=UI
	SoundCueName=TraderTime_Countdown
}