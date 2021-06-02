//=============================================================================
// KFPhysicsDamageByPawnVolume
//=============================================================================
// PhysicsVolume are, by default, used for traps on all maps. This KFPhysicsDamageByPawnVolume
// gives the ability to make different damage values for Humans and Monsters.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2021 Tripwire Interactive LLC
// Roberto Moreno
//=============================================================================
class KFPhysicsDamageByPawnVolume extends PhysicsVolume
    placeable;

var()		float				DamagePerSecMultiplierForHuman;				
var()		float				DamagePerSecMultiplierForMonster;			

function CausePainTo(Actor Other)
{
    local float DamagePerSecModified;

    DamagePerSecModified = DamagePerSec;

    if (KFPawn_Human(Other) != None)
    {
        DamagePerSecModified *= DamagePerSecMultiplierForHuman;
    }
    else if (KFPawn_Monster(Other) != None)
    {
        DamagePerSecModified *= DamagePerSecMultiplierForMonster;
    }

	if (DamagePerSecModified > 0)
	{
		if ( WorldInfo.bSoftKillZ && (Other.Physics != PHYS_Walking) )
			return;
		if ( (DamageType == None) || (DamageType == class'DamageType') )
			`log("No valid damagetype ("$DamageType$") specified for "$PathName(self));
		Other.TakeDamage(DamagePerSecModified*PainInterval, DamageInstigator, Location, vect(0,0,1), DamageType,, self);
	}
	else
	{
		Other.HealDamage(-DamagePerSecModified * PainInterval, DamageInstigator, DamageType);
	}
}


DefaultProperties
{
    DamagePerSecMultiplierForHuman=1.0
    DamagePerSecMultiplierForMonster=1.0
}