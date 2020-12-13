//=============================================================================
// KFInterface_TriggerOwner
//=============================================================================
// Interface for actors to receive Touch and UnTouch notifications from 
// triggers they own (if the triggers are KFTrigger_NotifyOwner)
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
interface KFInterface_TriggerOwner;

function NotifyTriggerTouch(KFTrigger_NotifyOwner Sender, Actor Toucher, PrimitiveComponent OtherComp, vector HitLocation, vector HitNormal);
function NotifyTriggerUnTouch(KFTrigger_NotifyOwner Sender, Actor UnToucher);