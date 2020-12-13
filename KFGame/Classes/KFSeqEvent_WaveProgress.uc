//=============================================================================
// KFSeqEvent_WaveProgress
//=============================================================================
// Event telling Kismet a zed was killed
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeqEvent_WaveProgress extends SequenceEvent;

/** How many zeds must be killed to trigger a "Zeds Killed" event */
var() const int ZedsKilledTrigger;

/** How many zeds must be remaining to trigger a "Zeds Remaining" event */
var() const int ZedsRemainingTrigger;

/** What percentage of zeds must be killed to trigger a "Wave Progress Pct" event */
var() const float WaveProgressPctTrigger;

function SetWaveProgress( int ZedsRemaining, int TotalZeds, Actor InOriginator )
{
	local int ZedsKilled;
	local float OldPct, NewPct;
	local array<int> OutputLinksToActivate;

	ZedsKilled = TotalZeds - ZedsRemaining;
	if (ZedsKilled == ZedsKilledTrigger)
	{
		OutputLinksToActivate.AddItem(0);
	}

	if (ZedsRemaining == ZedsRemainingTrigger)
	{
		OutputLinksToActivate.AddItem(1);
	}

	OldPct = 100.f * (float(ZedsKilled - 1) / float(TotalZeds));
	NewPct = 100.f * (float(ZedsKilled) / float(TotalZeds));

	if (OldPct < WaveProgressPctTrigger && NewPct >= WaveProgressPctTrigger)
	{
		OutputLinksToActivate.AddItem(2);
	}

	if (OutputLinksToActivate.Length > 0)
	{
		CheckActivate(InOriginator, InOriginator,, OutputLinksToActivate);
	}
}

DefaultProperties
{
	ObjName="Wave Progress Event"
	bPlayerOnly=false
	OutputLinks(0)=(LinkDesc="Zeds Killed")
	OutputLinks(1)=(LinkDesc="Zeds Remaining")
	OutputLinks(2)=(LinkDesc="Wave Progress Pct")
}