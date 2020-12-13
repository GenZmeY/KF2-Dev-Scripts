//=============================================================================
// KFAISpawnSquad
//=============================================================================
// A squad definition used by the spawning manager
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
//=============================================================================

class KFAISpawnSquad extends Object
	dependson(KFSpawnVolume)
	hidecategories(Object);

/** Type and amount of AI and spawn behavior */
struct AISquadElement
{
	var()	EAIType			Type;
	var()	byte			Num <ClampMin=1 | ClampMax=6>;

	/** Override AIType with custom class reference (this loads it into memory) */
	var class<KFPawn_Monster> CustomClass;

	structdefaultproperties
	{
		Num=1
	}
};

var() ESquadType					MinVolumeType;
var() const array<AISquadElement>	MonsterList;

defaultproperties
{
	MinVolumeType=EST_Medium
}

