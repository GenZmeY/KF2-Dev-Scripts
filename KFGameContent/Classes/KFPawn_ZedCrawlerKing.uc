//=============================================================================
// KFPawn_ZedCrawlerKing
//=============================================================================
// Crawler King
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//=============================================================================
class KFPawn_ZedCrawlerKing extends KFPawn_ZedCrawler;

/** Tells clients to try to spawn an explosion */
var protected bool bShouldExplode;

replication
{
	if( bTearOff )
		bShouldExplode;
}

/** Called on server when pawn should has been crippled (e.g. Headless) */
function CauseHeadTrauma( float BleedOutTime=5.f )
{
	super.CauseHeadTrauma( BleedOutTime );

	CancelExplosion();
}

/** Reliably play any gore effects related to a zone/limb being dismembered */
simulated function PlayHeadAsplode()
{
	super.PlayHeadAsplode();

	CancelExplosion();
}

/** Set our gib flag on the server, replicate it with bTearOff */
function bool Died(Controller Killer, class<DamageType> DamageType, vector HitLocation)
{
	if( !bPlayedDeath && DamageType != class'KFSM_PlayerCrawler_Suicide'.default.SuicideDamageType )
	{
		bShouldExplode = true;
	}

	return super.Died( Killer, DamageType, HitLocation );
}

simulated function PlayDying(class<DamageType> DamageType, vector HitLoc)
{
	super.PlayDying( DamageType, HitLoc );

	// Set a timer to check if we should spawn our gas cloud (wait a single frame to allow hitzone damage to process)
	if( bShouldExplode )
	{
		SetTimer( WorldInfo.DeltaSeconds, false, nameOf(Timer_CheckForExplode) );
	}
}

/** Stops a special crawler from spawning a poison gas cloud */
simulated function CancelExplosion()
{
	bShouldExplode = false;
	if( IsTimerActive(nameOf(Timer_CheckForExplode)) )
	{
		ClearTimer( nameOf(Timer_CheckForExplode) );
	}
}

simulated function Timer_CheckForExplode()
{
	local KFGoreManager GoreManager;
	local array<name> OutGibBoneList;
	local int NumGibs;
	local vector Impulse;

	if( bShouldExplode )
	{
		class'KFSM_PlayerCrawler_Suicide'.static.TriggerExplosion( self, DeathExplosionTemplate, true );

		if( WorldInfo.NetMode != NM_DedicatedServer )
		{
			GoreManager = KFGoreManager( WorldInfo.MyGoreEffectManager );
			if( GoreManager != none && GoreManager.AllowMutilation() )
			{
				// Enable alternate bone weighting and gore skeleton
				if( !bIsGoreMesh )
				{
					SwitchToGoreMesh();
				}

				// Apply gore only if we were able to successfully switch to the gore mesh
				if( bIsGoreMesh )
				{
					NumGibs = 10 + Rand(4);
					NumGibs *= GetCharacterMonsterInfo().ExplosionGibScale;
					GetClosestHitBones( NumGibs, Location, OutGibBoneList );

					GoreManager.CauseGibsAndApplyImpulse( self,
														Class'KFSM_PlayerCrawler_Suicide'.default.SuicideDamageType,
														Location,
														OutGibBoneList,
														none,
														Mesh.GetBoneLocation(Mesh.GetBoneName(0)) );
					return;
				}
			}

			// If we didn't gib, add a ragdoll impulse
			if( NumGibs == 0 && Physics == PHYS_RigidBody )
			{
				Impulse = vect(0,0,1) * LowGoreExplosionImpulse * PhysRagdollImpulseScale;
				Mesh.AddImpulse( Impulse, Location );
			}
		}
	}
}

defaultproperties
{
	LocalizationKey=KFPawn_ZedCrawlerKing
	MonsterArchPath="ZED_ARCH.ZED_CrawlerKing_Archetype"
	ControllerClass=class'KFAIController_ZedCrawlerKing'
	DifficultySettings=class'KFDifficulty_CrawlerKing'
}