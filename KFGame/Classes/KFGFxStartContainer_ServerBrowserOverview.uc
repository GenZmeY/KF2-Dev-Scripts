//=============================================================================
// KFGFxStartContainer_ServerBrowserOverview
//=============================================================================
// Class Description
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//  - Greg Felber 4/23/2014
//=============================================================================

class KFGFxStartContainer_ServerBrowserOverview extends KFGFxObject_Container;

var localized string DescriptionString;
var localized string OverviewString;

function Initialize( KFGFxObject_Menu NewParentMenu )
{
 	LocalizeContainer();
}

function LocalizeContainer()
{
	SetString("overviewString", OverviewString);
}

function SetDescriptionString(string LeaderName)
{
	SetString("descriptionString", LeaderName@DescriptionString);
}

