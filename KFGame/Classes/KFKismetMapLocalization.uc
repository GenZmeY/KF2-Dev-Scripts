//=============================================================================
// KFKismetMapLocalization
//=============================================================================
// Base class for Kismet localization
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
//=============================================================================
class KFKismetMapLocalization extends Object within KFSeqAct_DrawLocalizedText
	hidedropdown;

var Font TextFont;

static simulated function string GetLocalization(int Id);

static simulated function Font GetFont()
{
	return default.TextFont;
}