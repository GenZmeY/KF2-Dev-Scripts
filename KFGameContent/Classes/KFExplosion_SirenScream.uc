//=============================================================================
// KFExplosion_SirenScream
//=============================================================================
// Explosion actor class for ground fire
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// Greg Felber
//=============================================================================

class KFExplosion_SirenScream extends KFExplosionActor;

protected function SpecialCringeEffectsFor(Actor Victim, float VictimDist)
{
	local KFProjectile KFProj;
	
	KFProj = KFProjectile(Victim);
	if( KFProj != none && !KFProj.bDeleteMe && KFProj.bCanDisintegrate && !KFProj.bHasDisintegrated )
	{
		KFProj.Disintegrate( rotator(-Velocity) );
		return;
	}
}

function HandleIgnoredVictim(Actor Victim)
{
    if (Victim != Instigator && KFPawn_Monster(Victim) != none)
    {
        if (KFGameInfo(WorldInfo.Game) != none)
        {
            KFGameInfo(WorldInfo.Game).NotifyIgnoredScream(KFPawn_Monster(Victim));
        }
    }    
}

DefaultProperties
{
	bExplodeMoreThanOnce=true
}