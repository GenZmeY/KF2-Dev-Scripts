//=============================================================================
// KFCollectibleActor
//=============================================================================
// Collection estructible used to unlock achievements
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Jeff Robinson
//=============================================================================

class KFCollectibleActor extends KFDestructibleActor
	placeable
	hidecategories(Navigation,NavMesh);

/** Whether this collectible has been found or not */
var private bool bFound;

/** Overridden to call OnCollect */
protected event TriggerDestroyedEvent( Controller EventInstigator )
{
	local KFMapInfo KFMI;
	local KFPlayerController KFPC;

	super.TriggerDestroyedEvent( EventInstigator );

	KFMI = KFMapInfo( WorldInfo.GetMapInfo() );
	if( !bFound && KFMI != none )
	{
		bFound = true;
		KFMI.OnCollectibleFound( self, EventInstigator );

		KFPC = KFPlayerController(EventInstigator);
		If (KFPC != none)
		{
			KFPC.AddCollectibleFound(KFMI.CollectiblesToFind);
		}
	}

	// Used on network to tell clients who join late that this collectible is destroyed
	bShutDown = true;
}

/** Overridden to prevent AI from damaging collectibles */
function AdjustDamage(out int InDamage, Controller EventInstigator, class<DamageType> DamageType)
{
	if( EventInstigator == none || !EventInstigator.bIsPlayer )
	{
		InDamage = 0;
		return;
	}

	super.AdjustDamage( InDamage, EventInstigator, DamageType );
}

/** Collectible actors should not reset */
simulated function Reset();

defaultproperties
{
	// KFDestructibleActor
	ReplicationMode=RT_ServerOptimized
	bAllowBumpDamageFromAI=False
	INSTAKILL_DAMAGE=1

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh=StaticMesh'ENV_Collectible_MESH.Env_Dosh_Collectible'
		LightingChannels=(bInitialized=True,Dynamic=True,Indoor=True,Outdoor=True)
		bNeverBecomeDynamic=true
	End Object
	Components.Add(StaticMeshComponent0)

	//@todo: update default AmbientSound

	SubObjects(0)={(
		Mesh=StaticMeshComponent0,
		DamageMods=((Sounds=(AkEvent'WW_UI_PlayerCharacter.Play_UI_Collectible_Hit'),
			bSelfDestruct=True,
			ParticleEffects=((ParticleEffect=ParticleSystem'FX_Gameplay_EMIT_TWO.FX_Collectible_pickup_01')))),
			DefaultHealth=1.000000,
			Health=1)}
}
