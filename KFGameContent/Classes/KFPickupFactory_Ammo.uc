//=============================================================================
// KFPickupFactory_Ammo
//=============================================================================
// Pickup that gives some ammo for all weapons in inventory
//=============================================================================
// Killing Floor 2
// Copyright (C) 2015 Tripwire Interactive LLC
// - Andrew "Strago" Ladenberger
//=============================================================================

class KFPickupFactory_Ammo extends KFPickupFactory;

/** Sound to play when picking up ammo */
var() AkEvent AmmoPickupSound;

/** Overloaded to add this pickup to its proper list in the gameinfo */
simulated function InitializePickup()
{
	local KFGameInfo KFGI;

	if( bKismetDriven )
	{
		return;
	}

	KFGI = KFGameInfo( WorldInfo.Game );
	if ( KFGI != none )
	{
     	KFGI.AmmoPickups.AddItem( self );
	}
}

/** Bypass PickupFactory implementation. This class doesn't use InventoryType. */
simulated event SetInitialState()
{
	super.SetInitialState();

	bScriptInitialized = true;
}

/** give pickup to player */
function GiveTo( Pawn P )
{
	local KFInventoryManager KFIM;

	KFIM = KFInventoryManager(P.InvManager);
	if ( KFIM != None )
	{
		if( KFIM.GiveWeaponsAmmo( true ) )
		{
			`BalanceLog(class'KFGameInfo'.const.GBE_Pickup, P.PlayerReplicationInfo, "Ammo");
			`AnalyticsLog(( "pickup", P.PlayerReplicationInfo, "ammo"));
			PickedUpBy( P );
		}
	}
}

/** Activate a different pickup after the 'RespawnDelay' has finished */
function PickedUpBy(Pawn P)
{
	local KFGameInfo KFGI;

	if( bKismetDriven )
	{
		super.PickedUpBy( P );
		return;
	}

	KFGI = KFGameInfo( WorldInfo.Game );
	if ( KFGI != none )
	{
		KFGI.EnableNewPickup( KFGI.AmmoPickups, KFGI.DifficultyInfo.GetAmmoPickupInterval(KFGI.GetLivingPlayerCount()), self );
	}
}

/** Determine what kind of pickup is visible. Used for dialog. */
function bool CurrentPickupIsAmmo()
{
	return true;
}

defaultproperties
{
	AmmoPickupSound=AkEvent'WW_UI_PlayerCharacter.Play_UI_Pickup_Ammo'

	Begin Object Class=StaticMeshComponent Name=StaticMeshComponent0
		StaticMesh=StaticMesh'ENV_Horzine_MESH.crates.ENV_Horzine_Equiptment_Crate_02'
		Materials(0)=MaterialInstanceConstant'GP_Mat_Lib.GP_Ammo_MIC'
		Scale=0.5f
		bCastDynamicShadow=FALSE
		CollideActors=FALSE
		Translation=(Z=-50)
	End Object
	PickupMesh=StaticMeshComponent0
	Components.Add(StaticMeshComponent0)

	Begin Object NAME=CollisionCylinder
		CollisionRadius=100.f
		CollisionHeight=50.f
	End Object

	bNotBased=TRUE
}
