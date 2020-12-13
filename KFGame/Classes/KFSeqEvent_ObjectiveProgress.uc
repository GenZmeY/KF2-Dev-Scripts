//=============================================================================
// KFSeqEvent_ObjectiveProgress
//=============================================================================
// Event telling Kismet that objective progress has been made
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================
class KFSeqEvent_ObjectiveProgress extends SequenceEvent
	native(Sequence)
	abstract;

/** Thresholds associated with output links (a link will be added for each threshold) */
var() bool bUseReverseProgress;
var() array<float> ProgressThresholds;

var editoronly const string OutputLinkText;
var const int ProgressOutputStartIndex;

cpptext
{
	virtual void PostEditChangeProperty(FPropertyChangedEvent& PropertyChangedEvent)
	{
		const FName PropertyName = PropertyChangedEvent.Property ?
			PropertyChangedEvent.Property->GetFName() : NAME_None;

		if ((PropertyName == FName(TEXT("bUseReverseProgress"))) ||
			(PropertyName == FName(TEXT("ProgressThresholds")) && PropertyChangedEvent.ChangeType == EPropertyChangeType::ArrayAdd))
		{
			INT NumThresholds = ProgressThresholds.Num();
			for (INT i = 1; i <= NumThresholds; ++i)
			{
				if (bUseReverseProgress)
				{
					ProgressThresholds[i-1] = float(NumThresholds - i) / float(NumThresholds);
				}
				else
				{
					ProgressThresholds[i-1] = float(i) / float(NumThresholds);
				}
			}
		}

		for (INT i = 0; i < ProgressThresholds.Num(); ++i)
		{
			ProgressThresholds[i] = Clamp(ProgressThresholds[i], 0.f, 1.f);
		}

		INT NumProgressOutputs = OutputLinks.Num() - ProgressOutputStartIndex;
		if (NumProgressOutputs < ProgressThresholds.Num())
		{
			while (NumProgressOutputs < ProgressThresholds.Num())
			{
				OutputLinks.AddZeroed();
				NumProgressOutputs++;
			}
		}
		else if (NumProgressOutputs > ProgressThresholds.Num())
		{
			while (NumProgressOutputs > ProgressThresholds.Num())
			{
				OutputLinks.Remove(OutputLinks.Num()-1);
				NumProgressOutputs--;
			}
		}

#if WITH_EDITORONLY_DATA
		for (INT i = ProgressOutputStartIndex; i < OutputLinks.Num(); ++i)
		{
			OutputLinks[i].LinkDesc = FString::Printf(TEXT("%s: %1.2f"), *OutputLinkText, ProgressThresholds[i-ProgressOutputStartIndex]);
		}
#endif

		Super::PostEditChangeProperty(PropertyChangedEvent);
	}

	virtual void OnCreated()
	{
		Super::OnCreated();

		const INT NumDefaultThresholds = 4;
		for (INT i = 1; i <= NumDefaultThresholds; ++i)
		{
			if (bUseReverseProgress)
			{
				ProgressThresholds.AddItem(float(NumDefaultThresholds - i) / float(NumDefaultThresholds));
				OutputLinks.AddZeroed();
#if WITH_EDITORONLY_DATA
				for (INT i = ProgressOutputStartIndex; i < OutputLinks.Num(); ++i)
				{
					OutputLinks[i].LinkDesc = FString::Printf(TEXT("%s: %1.2f"), *OutputLinkText, ProgressThresholds[i-ProgressOutputStartIndex]);
				}
#endif
			}
			else
			{
				ProgressThresholds.AddItem(float(i) / float(NumDefaultThresholds));
				OutputLinks.AddZeroed();
#if WITH_EDITORONLY_DATA
				for (INT i = ProgressOutputStartIndex; i < OutputLinks.Num(); ++i)
				{
					OutputLinks[i].LinkDesc = FString::Printf(TEXT("%s: %1.2f"), *OutputLinkText, ProgressThresholds[i-ProgressOutputStartIndex]);
				}
#endif
			}
		}
	};
}

defaultproperties
{
	ObjCategory="KF"
	ObjName="Objective Progress"
	VariableLinks.Empty
	bPlayerOnly=false
	MaxTriggerCount=0

	OutputLinks.Empty
	VariableLinks.Empty

	OutputLinkText="Progress Percent"
	ProgressOutputStartIndex=0
}