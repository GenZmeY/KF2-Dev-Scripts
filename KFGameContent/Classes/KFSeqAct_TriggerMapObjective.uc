//=============================================================================
// KFSeqAct_TriggerMapObjective
//=============================================================================
// Sequence action to allow a map to specifically set the active objective.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2017 Tripwire Interactive LLC
// - Dan Weiss
//=============================================================================

class KFSeqAct_TriggerMapObjective extends SequenceAction;

var Actor Objective;

event Activated()
{
    local KFGameReplicationInfo KFGRI;
    if (KFInterface_MapObjective(Objective) != none)
    {
        KFGRI = KFGameReplicationInfo(GetWorldInfo().GRI);
        if (KFGRI != none)
        {
            if (InputLinks[0].bHasImpulse)
            {
                KFGRI.ActivateObjective(KFInterface_MapObjective(Objective));
            }
            else if (InputLinks[1].bHasImpulse)
            {
                KFGRI.DeactivateObjective();
            }
        }        
    }
}

defaultproperties
{
    ObjName="Activate Map Objective"
    ObjCategory="Killing Floor"

    InputLinks.Empty()
    InputLinks(0)=(LinkDesc="Activate")
    InputLinks(1)=(LinkDesc="Deactivate")

    VariableLinks.Empty()
    VariableLinks(0)=(ExpectedType=class'SeqVar_Object', LinkDesc="Objective", PropertyName=Objective)
}