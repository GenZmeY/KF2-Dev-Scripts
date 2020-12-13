//=============================================================================
// KFGameplayPoolManager
//=============================================================================
// Manages pools for puke mines, c4, etc... Unlike most pools this
// is managed server-side, typically for replicated actors.
//=============================================================================
// Killing Floor 2
// Copyright (C) 2016 Tripwire Interactive LLC
//  - Matt 'Squirrlz' Farber
//=============================================================================
class KFGameplayPoolManager extends Actor;

enum eProjectilePoolType
{
	PPT_C4,
	PPT_PukeMine
};

/** The maximum global number of C4 that can be active in play */
var protected const byte MAX_ACTIVE_C4;

/** The maximum global number of puke mines that can be active in play */
var protected const byte MAX_ACTIVE_PUKE_MINES;

/** C4 spawned by players */
var transient protected array<KFProjectile> ActiveC4;

/** Puke mines spawned by players */
var transient protected array<KFProjectile> ActivePukeMines;

/** Returns instance to the pool manager */
static function KFGameplayPoolManager GetPoolManager()
{
	return KFGameplayPoolManager( class'WorldInfo'.static.GetWorldInfo().MyGameplayPoolManager );
}

/** Determines the pool type and adds a new projectile to that pool */
function AddProjectileToPool( KFProjectile Proj, eProjectilePoolType PoolType )
{
	switch( PoolType )
	{
		case PPT_C4:
			AddProjectileToPool_Internal( ActiveC4, Proj, MAX_ACTIVE_C4 );
			break;

		case PPT_PukeMine:
			AddProjectileToPool_Internal( ActivePukeMines, Proj, MAX_ACTIVE_PUKE_MINES );
			break;
	}
}

/** Determines the pool type and removes a projectile from the pool */
function RemoveProjectileFromPool( KFProjectile Proj, eProjectilePoolType PoolType )
{
	switch( PoolType )
	{
		case PPT_C4:
			RemoveProjectileFromPool_Internal( ActiveC4, Proj );
			break;

		case PPT_PukeMine:
			RemoveProjectileFromPool_Internal( ActivePukeMines, Proj );
			break;
	}
}

/** Add a projectile to its respective pool, removing the oldest if we are at the pool limit */
private function AddProjectileToPool_Internal( out array<KFProjectile> PoolProjectiles, KFProjectile Proj, byte MaxActiveProjectiles )
{
	if( PoolProjectiles.Length == MaxActiveProjectiles )
	{
		if( PoolProjectiles[0] != none )
		{
			PoolProjectiles[0].Detonate();
		}
		PoolProjectiles.Remove( 0, 1 );
	}

	PoolProjectiles.AddItem( Proj );
}

/** Remove a projectile from the pool (it's been destroyed) */
private function RemoveProjectileFromPool_Internal( out array<KFProjectile> PoolProjectiles, KFProjectile Proj )
{
	PoolProjectiles.RemoveItem( Proj );
}

/** Clears the pool arrays */
event Reset()
{
	ActivePukeMines.Length = 0;
	ActiveC4.Length = 0;
}

defaultproperties
{
	bTickIsDisabled=true
	Physics=PHYS_None
	RemoteRole=ROLE_None

	MAX_ACTIVE_C4=24
	MAX_ACTIVE_PUKE_MINES=24
}