//=============================================================================
// KFSeqEvent_TraderOpened
//=============================================================================
// Event telling Kismet the trader opened
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Christian "schneidzekk" Schneider
//=============================================================================
class KFSeqEvent_TraderOpened extends SequenceEvent;

function SetWaveNum( int WaveNum, int WaveMax )
{
	local SeqVar_Int SeqInt;
	local SeqVar_Float SeqFloat;

	foreach LinkedVariables( class'SeqVar_Int', SeqInt, "Wave Number" )
	{
		SeqInt.IntValue = WaveNum;
	}

	foreach LinkedVariables( class'SeqVar_Int', SeqInt, "Wave Max" )
	{
		SeqInt.IntValue = WaveMax;
	}

	foreach LinkedVariables( class'SeqVar_Float', SeqFloat, "Wave Pct Complete" )
	{
		SeqFloat.FloatValue = 100.f * ( float(WaveNum) / float(WaveMax) );
	}
}

DefaultProperties
{
	ObjName="On Trader Opened Event"
	VariableLinks.Empty
	bPlayerOnly=false
	OutputLinks(0)=(LinkDesc="Normal Wave")
	OutputLinks(1)=(LinkDesc="Boss Wave")
	VariableLinks(0)=(ExpectedType=class'SeqVar_Int',LinkDesc="Wave Number",bWriteable=true)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="Wave Max",bWriteable=true)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Float',LinkDesc="Wave Pct Complete",bWriteable=true)
}