//=============================================================================
// KFMapMutator
//=============================================================================
// Base map mutator class for KF2. Allows map to modify content/logic.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2018 Tripwire Interactive LLC
//=============================================================================

class KFMapMutator extends Object
	abstract;

static simulated function ModifyGameClassBossAIClassList(out array< class<KFPawn_Monster> > GameClassBossAIClassList);
static simulated function ModifyAIDoshValue(out float AIDoshValue);