//=============================================================================
// KFDT_Freeze_DualHRGWinterbiteImpact
//=============================================================================
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFDT_Freeze_DualHRGWinterbiteImpact extends KFDT_Freeze_HRGWinterbiteImpact
	abstract
	hidedropdown;

defaultproperties
{
	ModifierPerkList.Empty
	ModifierPerkList(0)=class'KFPerk_Firebug'
    ModifierPerkList(1)=class'KFPerk_Gunslinger'
}