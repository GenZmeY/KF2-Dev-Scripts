//=============================================================================
// KFSeqAct_SetTraderEnabled
//=============================================================================
// Action that enables or disables a trader trigger
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFSeqAct_SetTraderEnabled extends SequenceAction;

// Whether list of traders should be reset to contain all currently-enabled traders
var() bool bReinitializeTraderList;

event Activated()
{
	local SeqVar_Object ObjVar;
	local KFTraderTrigger Trader;
	local KFGameInfo KFGI;
	local bool bEnable;

	KFGI = KFGameInfo(class'WorldInfo'.static.GetWorldInfo().Game);
	if (KFGI == none)
	{
		`warn("KFSeqAct_SetTraderEnabled only supported for KFGameInfo types");
		return;
	}

	bEnable = InputLinks[0].bHasImpulse;

	foreach LinkedVariables(class'SeqVar_Object', ObjVar, "KF Trader Trigger")
	{
		Trader = KFTraderTrigger(ObjVar.GetObjectValue());
		if (!Trader.bEnabled && bEnable)
		{
			if (KFGI.TraderList.Find(Trader) == INDEX_NONE)
			{
				KFGI.TraderList.AddItem(Trader);
			}
		}
		else if (Trader.bEnabled && !bEnable)
		{
			KFGI.TraderList.RemoveItem(Trader);
		}

		Trader.bEnabled = bEnable;
	}

	if (KFGI.TraderList.Length == 0 || bReinitializeTraderList)
	{
		KFGI.InitTraderList();
	}
}

defaultproperties
{
	ObjCategory="Killing Floor"
	ObjName="Set Trader Enabled"

	InputLinks(0)=(LinkDesc="Enable")
	InputLinks(1)=(LinkDesc="Disable")
	VariableLinks(0)=(ExpectedType=class'SeqVar_Object',LinkDesc="KF Trader Trigger")
	bCallHandler=false
}