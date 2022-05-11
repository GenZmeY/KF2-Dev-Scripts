//=============================================================================
// KFInterface_MapObjective
//=============================================================================
// Interface common to any type of map objective.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

interface KFInterface_MapObjective;

// Status
simulated function bool CanActivateObjectiveByWeekly();
simulated function ActivateObjective();
simulated function DeactivateObjective();
simulated function GrantReward(KFPlayerReplicationInfo KFPRI, KFPlayerController KFPC);
simulated function bool IsActive();
simulated function bool UsesProgress();
simulated function int GetDoshReward();
simulated function int GetMaxDoshReward();
simulated function int GetVoshReward();
simulated function int GetMaxVoshReward();
simulated function int GetXPReward();
simulated function int GetMaxXPReward();
simulated function bool IsBonus();
function string GetLocalizedName();
function string GetLocalizedShortName();
function bool CanActivateObjective();
simulated function float GetProgress();
simulated function bool IsComplete();
simulated function bool HasFailedObjective();
simulated function float GetActivationPctChance();
simulated function float GetSpawnRateMod();

simulated function string GetProgressText();
simulated function bool GetProgressTextIsDosh();

simulated function string GetLocalizedDescription();
simulated function string GetLocalizedShortDescription();
simulated function string GetLocalizedRequirements();
simulated function GetLocalizedStatus(out string statusMessage, out int bWarning, out int bNotification);

simulated function bool GetIsMissionCritical();
simulated function float GetDoshValueModifier();
function NotifyZedKilled(Controller Killer, Pawn KilledPawn, bool bIsBoss);
simulated function NotifyObjectiveSelected();

// HUD
simulated function bool ShouldDrawIcon();
simulated function Vector GetIconLocation();
simulated function Texture2D GetIcon();
simulated function color GetIconColor();
simulated function DrawHUD(KFHUDBase hud, Canvas drawCanvas);
simulated function bool HasObjectiveDrawDistance();
simulated function bool ShouldShowObjectiveHUD();
simulated function bool ShouldShowObjectiveContainer();

// Kismet
simulated function TriggerObjectiveProgressEvent(optional int EventType = -1, optional float ProgressMade = -1.f);