//=============================================================================
// KFSeqEvent_TraderClosed
//=============================================================================
// Event telling Kismet the trader closed
//=============================================================================
// Killing Floor 2
// Copyright (C) 2019 Tripwire Interactive LLC
//=============================================================================
class KFSeqEvent_TraderClosed extends SequenceEvent;

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
	ObjName="On Trader Closed Event"
	bPlayerOnly = false
	VariableLinks.Empty
	VariableLinks(0)=(ExpectedType=class'SeqVar_Int',LinkDesc="Wave Number",bWriteable=true)
	VariableLinks(1)=(ExpectedType=class'SeqVar_Int',LinkDesc="Wave Max",bWriteable=true)
	VariableLinks(2)=(ExpectedType=class'SeqVar_Float',LinkDesc="Wave Pct Complete",bWriteable=true)
}